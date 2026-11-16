# Rojo checkpoint — Updated Tasks Guide v2.0

**Date:** 2026-11-14  
**Status:** READY FOR MANUAL TEST  
**Scope:** project/Rojo validation and place inventory only. No gameplay feature work or publish.

## Verified
- `default.project.json` is UTF-8 without BOM; first byte is `7B` (`{`).
- Rojo CLI 7.7.1 runs directly from Aftman's tool storage. The Aftman shim still reports `Home directory could not be found`; direct CLI works.
- Project JSON parses, project mappings are valid, and `rojo sourcemap` resolves shared/server/client source as expected.
- `rojo build` completed successfully; isolated `build/LaundryEmpire-test.rbxl` is non-empty (1,932 bytes).
- This project has its own Rojo server at `localhost:34873`. Port 34872 is already served by another Rojo process connected to the open Studio, so we did not terminate or reconfigure it.
- Studio root inventory is the default Baseplate/Terrain/SpawnLocation template plus scaffold/configs. No game UI, remotes, game models, or game scripts were found in the audited services.
- Shared config folders are case-collapsed by Roblox/Rojo on Windows. The existing `Config` and mapped `config` contained only GameConfig/EconomyConfig; they are consolidated under `ReplicatedStorage.Shared.config`.
- `ServerScriptService.LaundryEmpireScaffold` was retained outside mapped `ServerScriptService.Server`, avoiding accidental overwrite.
- `$ignoreUnknownInstances` is scoped to the three mapped roots to preserve Studio/MCP-added descendants; no whole-place mapping.

## Backups / limitations
- `build/LaundryEmpire-test.rbxl` and `backups/Place1-before-Rojo.rbxl` are Rojo template builds (1,932 bytes), **not** backups of the open live Studio place.
- Live plugin connection to port 34873 and create/update/delete smoke test have not been performed. Do not mark live sync or place integrity PASS yet.
- No place Save/Publish action performed.

## Current next step
1. In Studio's Rojo plugin, connect to this project's `localhost:34873` server (not the other server at 34872).
2. Verify the three project-owned roots populate; check the preserved helper and all unknown children remain.
3. Perform temporary create/update/delete smoke test only under `ReplicatedStorage.Shared.config`, then remove the temporary source file and confirm its removal in Studio.
4. Once Studio user saves a local `.rbxl` copy of the actual place to `backups/`, record that backup separately. Do not treat the template build as a place backup.
5. Only after sync and integrity pass, complete a deeper project audit and start Stage 1.

## Results
| Gate | Status |
|---|---|
| JSON/BOM + mappings | PASS |
| Rojo 7.7.1 static build | PASS |
| Rojo server | PASS on port 34873 |
| Studio plugin connection | NOT TESTED |
| Sync smoke test | NOT TESTED |
| Live Place1 backup | NOT TESTED |
| Place integrity after sync | NOT TESTED |
| Feature/gameplay tests | NOT RUN |
