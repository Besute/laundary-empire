# Rojo source ownership and conflict notes

Rojo 7.7.1 uses case-insensitive Roblox instance names. Therefore Windows source directory `src/shared/config` corresponds to `ReplicatedStorage.Shared.config`; do not also create a separate `Config` folder. The live place previously had both spellings. They were consolidated into the mapped lowercase folder; its two config ModuleScripts were preserved.

The Rojo project maps only source-owned roots. `$ignoreUnknownInstances: true` is scoped to these roots to preserve Studio/MCP-created descendants not present on disk. Before this was added, a test build showed only starter template content. The live place had an unmanaged `ServerScriptService.LaundryEmpireScaffold`; that script was preserved and marked in Studio before proceeding. Rojo-owned root scripts in Studio (`Server`, `Client`) are generated from the project sources; MCP-created children under them must be migrated into source or protected by the scoped ignore behavior.

Do not use a broad full-DataModel mapping. Keep a current `.rbxl` backup before connecting sync to a valuable place.
