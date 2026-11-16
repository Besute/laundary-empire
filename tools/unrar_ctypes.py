import ctypes, os, sys
lib = ctypes.CDLL("libarchive.so.13")
lib.archive_read_new.restype = ctypes.c_void_p
lib.archive_entry_pathname.restype = ctypes.c_char_p
lib.archive_entry_pathname.argtypes = [ctypes.c_void_p]
lib.archive_entry_size.restype = ctypes.c_int64
lib.archive_entry_size.argtypes = [ctypes.c_void_p]
lib.archive_entry_filetype.restype = ctypes.c_uint
lib.archive_entry_filetype.argtypes = [ctypes.c_void_p]
lib.archive_error_string.restype = ctypes.c_char_p
lib.archive_error_string.argtypes = [ctypes.c_void_p]
lib.archive_read_support_filter_all.argtypes=[ctypes.c_void_p]
lib.archive_read_support_format_all.argtypes=[ctypes.c_void_p]
lib.archive_read_open_filename.argtypes=[ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
lib.archive_read_next_header.argtypes=[ctypes.c_void_p, ctypes.POINTER(ctypes.c_void_p)]
lib.archive_read_data.argtypes=[ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t]
lib.archive_read_data.restype=ctypes.c_ssize_t
lib.archive_read_free.argtypes=[ctypes.c_void_p]

src, dst = sys.argv[1], sys.argv[2]
a = lib.archive_read_new()
lib.archive_read_support_filter_all(a)
lib.archive_read_support_format_all(a)
if lib.archive_read_open_filename(a, src.encode(), 65536) != 0:
    print("open error", lib.archive_error_string(a)); sys.exit(1)
entry = ctypes.c_void_p()
n=0
while True:
    r = lib.archive_read_next_header(a, ctypes.byref(entry))
    if r == 1: break
    if r < 0 and r != -20:
        print("hdr err", r, lib.archive_error_string(a))
        if r <= -25: break
    name = lib.archive_entry_pathname(entry).decode('utf-8','replace')
    ft = lib.archive_entry_filetype(entry)
    safe = os.path.normpath(name)
    if safe.startswith('..') or os.path.isabs(safe):
        print("skip unsafe", name); continue
    out = os.path.join(dst, safe)
    if ft == 0o040000:
        os.makedirs(out, exist_ok=True); continue
    os.makedirs(os.path.dirname(out), exist_ok=True)
    buf = ctypes.create_string_buffer(65536)
    with open(out,'wb') as f:
        while True:
            k = lib.archive_read_data(a, buf, 65536)
            if k <= 0:
                if k < 0: print("read err", name, lib.archive_error_string(a))
                break
            f.write(buf.raw[:k])
    n+=1
    print("extracted", name, os.path.getsize(out))
lib.archive_read_free(a)
print("files:", n)
