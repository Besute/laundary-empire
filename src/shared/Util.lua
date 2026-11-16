-- Util: shared helpers (server + client). No Roblox-instance dependencies except workspace clock.
local Util = {}

-- ───────────── numbers ─────────────
function Util.clamp(x, lo, hi)
	if x < lo then return lo elseif x > hi then return hi end
	return x
end
function Util.round(x) return math.floor(x + 0.5) end
function Util.lerp(a, b, t) return a + (b - a) * t end
function Util.isFinite(n) return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge end
function Util.isInt(n) return Util.isFinite(n) and n == math.floor(n) end

-- ───────────── tables ─────────────
function Util.deepCopy(t)
	if type(t) ~= "table" then return t end
	local out = {}
	for k, v in pairs(t) do out[k] = Util.deepCopy(v) end
	return out
end
function Util.shallowCopy(t)
	local out = {}
	for k, v in pairs(t) do out[k] = v end
	return out
end
function Util.count(t)
	local n = 0
	for _ in pairs(t) do n += 1 end
	return n
end
function Util.keys(t)
	local out = {}
	for k in pairs(t) do table.insert(out, k) end
	return out
end
function Util.sortedKeys(t)
	local out = Util.keys(t)
	table.sort(out, function(a, b) return tostring(a) < tostring(b) end)
	return out
end
-- Fill missing keys of `target` from `template` (deep). Existing values win. Returns target.
function Util.reconcile(target, template)
	for k, v in pairs(template) do
		if target[k] == nil then
			target[k] = Util.deepCopy(v)
		elseif type(target[k]) == "table" and type(v) == "table" then
			Util.reconcile(target[k], v)
		end
	end
	return target
end
function Util.sum(t, fn)
	local s = 0
	for _, v in pairs(t) do s += (fn and fn(v) or v) end
	return s
end
function Util.shuffle(rng, arr)
	for i = #arr, 2, -1 do
		local j = rng:NextInteger(1, i)
		arr[i], arr[j] = arr[j], arr[i]
	end
	return arr
end
-- weights: array of {item=..., w=number}; returns item or nil
function Util.weightedPick(rng, weights)
	local total = 0
	for _, e in ipairs(weights) do total += math.max(0, e.w) end
	if total <= 0 then return nil end
	local r = rng:NextNumber() * total
	for _, e in ipairs(weights) do
		r -= math.max(0, e.w)
		if r <= 0 then return e.item end
	end
	return weights[#weights].item
end

-- ───────────── ids ─────────────
-- data.Counters = {Order=0,...}. Returns e.g. "O12". Deterministic, unique inside one player's data.
local PREFIX = { Order = "O", Object = "B", Machine = "M", Employee = "E", Tx = "T", Dirt = "D", Candidate = "C", Campaign = "A", Customer = "U", Thief = "H" }
function Util.nextId(data, kind)
	data.Counters = data.Counters or {}
	local n = (data.Counters[kind] or 0) + 1
	data.Counters[kind] = n
	return (PREFIX[kind] or "X") .. tostring(n)
end

-- ───────────── result convention ─────────────
-- Every service operation / remote handler returns a Result table.
function Util.ok(extra)
	local r = extra or {}
	r.ok = true
	return r
end
function Util.fail(code, extra)
	local r = extra or {}
	r.ok = false
	r.code = code
	return r
end

-- ───────────── formatting ─────────────
function Util.formatMoney(n)
	n = math.floor((n or 0) + 0.5)
	local neg = n < 0
	local s = tostring(math.abs(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then out = out:sub(2) end
	return (neg and "-$" or "$") .. out
end
function Util.formatDuration(sec)
	sec = math.max(0, math.floor(sec + 0.5))
	return string.format("%d:%02d", sec // 60, sec % 60)
end
-- minutes of day (0..1439) -> "HH:MM"
function Util.formatClock(minutes)
	minutes = math.floor(minutes) % 1440
	return string.format("%02d:%02d", minutes // 60, minutes % 60)
end

-- ───────────── signals ─────────────
-- Tiny synchronous signal. Handlers run via task.spawn so one failing handler cannot break others.
function Util.newSignal()
	local handlers = {}
	local sig = {}
	function sig:Connect(fn)
		local c = { fn = fn, Connected = true }
		function c:Disconnect()
			c.Connected = false
			for i, h in ipairs(handlers) do
				if h == c then table.remove(handlers, i) break end
			end
		end
		table.insert(handlers, c)
		return c
	end
	function sig:Fire(...)
		local snapshot = table.clone(handlers)
		for _, c in ipairs(snapshot) do
			if c.Connected then task.spawn(c.fn, ...) end
		end
	end
	function sig:DisconnectAll()
		for _, c in ipairs(handlers) do c.Connected = false end
		handlers = {}
	end
	return sig
end

-- ───────────── time ─────────────
-- Server-synchronized clock (seconds, unix-like). Identical on server and client.
function Util.now()
	return workspace:GetServerTimeNow()
end

return Util
