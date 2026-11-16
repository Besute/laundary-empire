# Laundry Empire — Roblox project

Rojo source project for implementing the supplied Laundry Empire GDD in small, verifiable phases.

## Structure
- `src/server/` → `ServerScriptService.Server` — authoritative game logic.
- `src/client/` → `StarterPlayer.StarterPlayerScripts.Client` — input, UI controllers, camera, presentation.
- `src/shared/` → `ReplicatedStorage.Shared` — shared configuration, types, and remote contracts.
- `TODO.md` — staged GDD checklist and verification gates.
- `DECISIONS.md` — approved design choices and implementation boundaries.
- `CHANGELOG.md` — change history.

## Studio/Rojo
1. Open this folder in a terminal and run `rojo serve` (Rojo CLI and the Studio Rojo plugin are required).
2. In the intended place, connect the plugin to the server shown in the terminal.
3. Keep Rojo serving while editing. Save/publish through Studio only when explicitly intended.

MCP inspects and verifies the live Studio DataModel; Rojo synchronizes mapped files. Do not concurrently edit a Rojo-owned script on disk and in Studio. The project does not configure the MCP server itself.

## Rojo ownership
Source-owned roots are `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayer.StarterPlayerScripts.Client`. Unmapped Studio/MCP objects remain outside those roots. `ROJO_OWNERSHIP.md` records the mapping, case rules, and preservation notes.

## Current status
The scaffold and GDD mapping are prepared. Feature systems have not yet been implemented. See `TODO.md`. Rojo 7.7.1 static build passes. Live plugin connection and sync preservation test remain pending; see `CHECKPOINT.md`.