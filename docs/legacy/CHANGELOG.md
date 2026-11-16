# Changelog

## 2026-11-14
- Added the initial Rojo source layout for server, client, and replicated shared modules.
- Added a shared economy hypothesis config from the GDD; values are explicitly provisional until playtested.
- Added the staged GDD implementation checklist and Studio/MCP workflow notes.
- Added a minimal MCP marker script to the currently connected Studio place; no existing place content was changed.
- Rojo CLI validation remains pending: the installed Aftman shim currently fails to resolve its home directory.

- Added GDD-driven project scaffold checkpoint; gameplay tests are intentionally not claimed.


## 2026-11-14 — Rojo baseline
- Confirmed project JSON begins with { (no UTF-8 BOM); Rojo 7.7.1 static build now succeeds.
- Added scoped $ignoreUnknownInstances only beneath mapped roots and documented ownership boundaries.
- Created a template build and sourcemap under uild/; created a template backup under ackups/ (not a backup of the live Studio place).
- Found a Rojo server already listening on port 34872; launched this project's server on 34873 for safe plugin testing.
- Live plugin connection and sync smoke test not completed; no destructive sync or save/publish was performed.
