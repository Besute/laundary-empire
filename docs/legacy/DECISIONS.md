# Decisions and accepted GDD choices

## Approved by the supplied GDD
- Genre: multiplayer 3D Roblox simulator/tycoon/management; free exploration, blocky Roblox characters, low-poly pastel world with turquoise accents.
- MVP is the manual laundry loop first: build washer/dryer/intake counter, accept NPC order, menu-load items, choose detergent/mode, wash, dry, pack, hand off, receive reward, persist progress.
- Item loading uses UI/menu and automatic character animation; no manual drag-and-drop of individual clothing models.
- Camera is hybrid: normal third-person outside build mode; angled/top-down construction view; restore gameplay camera on exit.
- Employees unlock gradually; every role automates a distinct operation. Manual control remains available.
- Starter room begins dirty, empty, worn, and dim. Three cosmetic facade choices: Modern, Classic, Colorful.
- Server is authoritative for cash, XP, rating, ownership, orders, placement validation, purchases, and machine/order state. Client handles UI, input, camera, previews, and cosmetic effects.
- No offline production or income in MVP. No irreversible loss of the player's business.
- Existing unfinished orders survive NPC departure/player exit and machine failure; payout/transactions are idempotent.
- Balance numbers in `EconomyConfig.lua` are playtest hypotheses, not final constants.
- Auctions, complex policing, additional districts, Rebirth, corporate orders, delivery, industrial factory, complex multi-floor systems, and offline income are later than MVP.

## Implementation boundaries
- The attached image is a visual roadmap/reference, not a request to build all depicted systems immediately.
- The GDD contains AI-agent workflow instructions; those are project requirements, not permission to skip audit, invent tests, publish, or alter MCP configuration.
- No existing Studio content is replaced until audited. Rojo owns only mapped source paths once sync is enabled.

## Rojo ownership decision (2026-11-14)
- Only ReplicatedStorage.Shared, ServerScriptService.Server, and StarterPlayer.StarterPlayerScripts.Client are source-owned.
- Source root directories are case-sensitive in intent; Roblox child names may not be. Use lowercase config consistently, matching src/shared/config.
- Retain unmanaged Studio/MCP instances outside mapped roots. Sync unknown children within mapped roots are ignored; don't widen mapping to the whole DataModel.
