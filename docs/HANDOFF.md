# LAUNDRY EMPIRE — HANDOFF (read this first)

Date: 2026-11-16. Previous model: Claude Sonnet 5.5. You are continuing the work. Nothing below has been run in Roblox Studio.

## 0. Inputs (all in this package)
- `docs/GDD_RU.txt` — full game design doc (Russian). Source of truth for design.
- `docs/Updated_Tasks_Rojo_Guide.txt` — Rojo guide + MVP plan from the earlier agent (BOM root cause: UTF-8 BOM in default.project.json; fixed, file is BOM-free).
- `docs/concept.png` — concept art (Russian UI, "CleanWave" laundromat, 9 panels, roadmap).
- `docs/legacy/` — the earlier agent's md files + original .rar. **Finding: the original archive contained NO Luau code** (only Rojo scaffold + docs; its TODO.md/CHANGELOG are mojibake). Treat the game as a from-scratch build.
- Environment constraints I hit: no Roblox Studio, no Rojo, no Lua/Luau interpreter, no pip/npm installs. RAR extracted via libarchive+ctypes (`tools/unrar_ctypes.py`).
- Rules from the GDD/guide you must keep: server authoritative for money/XP/orders/ownership; never claim PASS for untested things (use READY FOR MANUAL TEST / NOT TESTED); no Toolbox models; no offline income/production; no irreversible business loss; late systems only after core loop (here: isolated behind `GameConfig.Features` flags + pcall); do not publish/overwrite Place1.

## 1. What exists now (DONE, unverified by any parser)
```
default.project.json        Rojo map: src/shared->ReplicatedStorage.Shared, src/server->ServerScriptService.Server (init.server.lua), src/client->StarterPlayerScripts.Client (init.client.lua)
src/shared/Util.lua         helpers, Util.ok/fail Result convention, nextId(data,kind), newSignal, formatMoney/Duration/Clock, weightedPick, reconcile
src/shared/Remotes.lua      full remote contract (all C2S = RemoteFunctions returning Result; S2C = NotifyClient/StateUpdate/FxEvent) + arg-spec validator (validateArgs)
src/shared/TimeUtil.lua     game clock from workspace attribute "LE_DayEpoch" (server sets it); getClock, periodOf, isWithinHours
src/shared/BuildRules.lua   PURE placement rules (areas, reserved zones, overlap, limits, cellToLocal/localToCell, missingRequired)
src/shared/config/          GameConfig, EconomyConfig, ItemConfig, MachineConfig, OrderConfig, EmployeeConfig, AdvertisingConfig,
                            BuildingConfig, RatingConfig, NPCConfig, EventConfig, TutorialConfig, ErrorCodes
```
Naming rule: never put a file and a folder whose names differ only by case in the same directory (Windows/Rojo case-collapse). Folder is `config` (lowercase). Planned localization folder is `locales` (NOT `loc`) next to `Loc.lua`.

NOT yet written: `docs/CONTRACT.md`, `Loc.lua` + `locales/`, `server/*`, `client/*`, tools (linter/simulator), tests, final docs (README/TODO/CHANGELOG/DECISIONS/CHECKPOINT rewritten in clean UTF-8), test plan, build.

## 2. Architecture decisions (keep)
- Everything procedural: world, plots, item models, NPC rigs (hand-built R6 from Parts + Motor6D), UI all built in code. No external assets (sounds use built-in `rbxasset://sounds/...`, replaceable in GameConfig.Sounds).
- Server: `init.server.lua` boots `Services/*.lua` through `ServiceLocator` (each service `Init(ctx)` then `Start()` under pcall; late systems check `GameConfig.Features`). Decoupling via `Core/Bus.lua` (`Bus.on/emit`). `Core/Net.lua` registers handlers: validates args via `Remotes.validateArgs`, token-bucket rate limit, pcall, duplicate `requestId` memory, passes `(player, session, ...)`, returns Result.
- Client→server are RemoteFunctions (deviation from GDD "RemoteEvents": gives clear replies; log in DECISIONS.md). Error codes in `ErrorCodes.lua`, client maps to Loc key `err.<Code>`.
- Server→client state: `StateService.register(channel, providerFn(player))`, `.mark(player, channel)` (debounced ~0.2s) → `StateUpdate(channel, payload)`. Channels: Profile, Business, Orders, Machines, Inventory, Employees, Finance, Build, Properties, Ads, Tutorial, Security. Client keeps a `ClientState` store; `RequestSync` pushes all.
- Timers use `workspace:GetServerTimeNow()` (absolute). Persisted data uses "freeze while offline": on load each service shifts its timestamps by `session.OfflineSeconds`.
- IDs: `Util.nextId(data,"Order")` -> "O12" (counters in `Data.Counters`). Money ops idempotent via TxId (`"OrderPay:"..orderId`), `Data.ProcessedTx` bounded.
- Persistence: DataStore with UpdateAsync session lock `{Data, Lock={JobId,Time}}`, stale after `LockTimeout`, retries/backoff, autosave, PlayerRemoving + BindToClose, SchemaVersion + migrations + `Util.reconcile` over a template; in-memory Studio fallback. Dictionaries keyed by id for Machines/Orders/Employees/PlacedObjects.
- Players: `Players.CharacterAutoLoads=false`; assign plot, then `LoadCharacter()` and pivot to plot spawn. Collision groups "NPC"/"Players" so NPCs don't block players. Business name must go through `TextService:FilterStringAsync` (fallback default name).
- Client prompts: interactables are CollectionService-tagged `LE_Interact` with attributes `Action, OwnerUserId, TargetId, PromptText, HoldDuration`; the CLIENT creates local ProximityPrompts only for own objects (+public shop/agency). Server re-validates distance/ownership on every request (`GameConfig.Interaction.Range`).
- Other tags/attrs: `LE_Dirt` (DirtId, DirtType, OwnerUserId), `LE_NPC` (Kind, Mood, OwnerUserId), `LE_Roof` (hidden locally in build mode via LocalTransparencyModifier), `LE_AdSlot` (SlotId); plot folder attrs `PlotIndex, OwnerUserId, Origin(CFrame), BusinessName, Facade, IsOpen`; machine models attrs `MachineId, State, CycleEnd, MachineType, OwnerUserId`. Workspace folder `LaundryWorld` with `City, PlayerPlots(Plot_01..10), ActiveNPCs, ActiveVehicles, WorldEvents`.
- Localization: `Loc.t(key, params)`, languages en+ru (default by LocaleId); server sends keys not text (`NotifyClient(kind,{key,params,level})`).
- Item models: `ItemModels.build(itemId)` -> Model facing -Z in model space, pivot = footprint bottom centre; placement `PivotTo(CFrame.new(BuildRules.cellToLocal(...)) * CFrame.Angles(0, BuildingConfig.yawFor(rot), 0))` converted by plot origin. At rot 0 the item front faces plot-local +Z (street).
- World layout: road along X at z=0 (half-width 15), sidewalks 8, 10 plots (5 per side, spacing 104; north row centre z=-55 identity rotation, south row z=+55 rotated 180°), cross road at x≈300 with Supply Shop (north) and Ad Agency (south) next to it, Mall at west end x≈-380. Ground top slightly above default Baseplate (y≈0.2+) to avoid z-fight. Plot: lot 100x64, main building x∈[-20,20] z∈[-26,10], door at z=10, forecourt/parking z∈[10,32], annexes L/R, back room behind partition z=-13, second floor (stairs reserved cells). Pedestrians walk sidewalk waypoints; cars use fixed lane waypoints (anchored CFrame movement, CanCollide=false, no physics).

## 3. Gameplay semantics to implement (decided)
**Order lifecycle**: customer reaches counter -> `OrderService.createOffer` (state Offered) -> Accept (capacity check: `UnfinishedUnits + new <= sum capacity of working washers`; Offered not counted; broken machines don't count) or polite Decline (reason shown; no failure penalty, ServiceSample 55) -> customer leaves, returns at `CustomerReturnAt = now + estimate*1.25 + 20` (estimate = 70+12*units, config `OrderConfig`). Order is its own entity (survives NPC/player leave).
Per-order stage pools: `Basket[type]`, `Wet[type]={n,q}`, `Clean[type]={n,q}` + in-machine loads. Status derived = least-advanced non-empty stage (WaitingForWash<Washing<WaitingForDryer<Drying<Finishing), transitions validated by `OrderConfig.canTransition`.
Flow: `RequestLoadItems(machine, order, selection)` (partial counts, machine capacity, multiple orders ok; state Loading ~1s then ReadyToStart) -> `RequestStartWash(mode, detergent, additives)` (consumes 1 detergent dose, can't start without it; wear/break chance) -> Washing until `CycleEnd` -> CycleComplete -> `RequestTransferItems(washer->dryer)` -> `RequestStartDry` -> CycleComplete -> `RequestPackOrder` (all units dried) -> ReadyForPickup -> `RequestCollectOrder` when customer present; pay Cash+XP **exactly once** (txId). Quality per group = fabricFit(mode) × detergentFit × soil factor (Soil.Need vs ModePower+detergent/additive Power) × conditionFactor(machine) + bonuses; order quality weights Wash .65/Dry .35. Pay = base × (QualityPayFloor + (1-floor)×quality) (+tip if q>=0.9, +rush, -20% late once). Review pos/neu/neg from quality & timeliness -> RatingService.
Late/angry customer: leaves, returns after RetryDelay, max 2 return attempts, then order Failed (not silently lost).
Machines: states per `MachineConfig`; NeedsMaintenance shown when idle & wear>=70 (still usable); Broken keeps load; items can be transferred out to a compatible idle machine; Repair/Maintenance cost = machine price × mult, time 20s/8s, SpareParts gives 30% discount; mechanic employee automates.
Customers (`CustomerService`): per-business spawn timer; FlowMultiplier from ChoiceScore (weights in NPCConfig), PeriodFlow, first customer after ~6s; states per GDD list; central tick (not per-NPC loops); Humanoid:MoveTo with 8s stuck timeout -> teleport fallback; caps Global 40/PerPlot 7; queue limit 6, slot positions in front of counter (`LookVector*(4+3i)`), patience 90s with moods Calm/Worried/Annoyed/Leaving (attribute `Mood` only on bucket change); litter spawned event-driven (`NPCConfig.Dirt`), bins catch some; 10 initial dirt pieces.
Rating (0-100): weights Service .30 Clean .20 Interior .15 Speed .20 Review .15 (`RatingConfig`), EMA smoothing, updated on events only.
Economy: start cash 3000, levels via `EconomyConfig.xpForLevel`, settlement at 06:00 game time (wages halved days 1-2, tax 6% of gross from day 3, utilities per cycle), shortfall -> Debt (limit 1500, 30% of order income auto-repays), never business deletion; Finance panel + ledger (80 entries).
Employees (roles/levels/wages in `EmployeeConfig`): server task queue with claim locks, walk to target (teleport fallback), PerformingTask duration = TaskSeconds/speed, apply the same service operation the player would; no endless retries on impossible tasks; wages at settlement.
Late systems (flags): Advertising (campaign types, physical slot ids fixed, countdown only while online, boost into ChoiceScore.Advertising), Security (thief state machine from `EventConfig`, bounded loss, camera/alarm/lock/guard protection, catch hold prompt, police arrival), Parking+Traffic (reserved spots, cars on waypoints, Driver customers), Property (AnnexL/AnnexR: Available->Owned->UnderRenovation->Operational with purpose), day/night lighting driven by `LE_DayEpoch`. NOT implementing (post-MVP per GDD): auctions (`RequestBid`), Rebirth, corporate/VIP orders, delivery, districts, lifts, offline income.
Tutorial: T0 setup (name+facade) ... T10 per `TutorialConfig`, advanced by bus events (`BusinessSetup, BuildMenuOpened(ReportUIEvent), ObjectPlaced{Kind}, BusinessMenuOpened, BusinessSettingsSaved, BusinessOpened, OrderAccepted, OrderReady, OrderCompleted`), client highlights targets, never blocks input; reward 400 cash + 30 XP.

## 4. Remaining work (planned module split; each was to be a separate parallel agent)
1. `docs/CONTRACT.md`: field-by-field PlayerData/Order/Machine/Employee/Property schemas, service function signatures (return Results), bus event names + payloads, state-channel payload shapes (see §3), tags/attrs (see §2). Write it before coding services so modules agree.
2. Tools: Python Luau parser + scope linter (undefined globals, use-before-declare, `continue`, types, `+=`, if-expr), remote-name/require cross-check, and (stretch) tree-walking interpreter + Roblox mock (Instance/Signals/CFrame/Humanoid:MoveTo/DataStore/task scheduler with virtual time + mini-Rojo loader) to run an end-to-end order test: place washer/dryer/counter -> open -> offer -> accept -> load -> wash -> transfer -> dry -> pack -> collect (assert single payout, capacity rejection, forged/duplicate remotes, broken-machine start rejected).
3. Server platform: `init.server.lua, Core/{Bus,ServiceLocator,Net}`, PlayerDataService (+template/migrations), StateService, NotificationService, BusinessService, BuildingService (uses BuildRules), TutorialService, DayNightService, AnalyticsService.
4. World: `World/WorldBuilder`, PlotService (assign/release plot, toWorld/toLocal, facade/sign/renovation/floors/annex visuals), `shared/ItemModels.lua`, NPC rig + vehicle factories.
5. Core loop: Economy, Inventory(+shop purchases), Order, Machine, Maintenance, Rating, Cleanliness services.
6. NPC & late: Customer, Employee, Parking, Traffic, Security, Advertising, Property services.
7. Client: `init.client.lua`, Net wrapper, ClientState, UI lib (Theme/Widgets, UIScale, mobile/gamepad, colour-independent state cues), HUD, Setup screen, Orders/Machine/Shop/Employees/Advertising/Security/Finance/Business menus, BuildingController+BuildMenu (ghost via ItemModels, grid, R rotate, confirm/cancel, move/sell), CameraController (hybrid, restore on exit), InteractionController, TutorialUI, NPC indicators, FX (clothes->drum), AudioController.
8. Integration: run linter/sim, fix; rewrite docs in clean UTF-8 (README, TODO, CHANGELOG, DECISIONS, CHECKPOINT, manual test plan, RELEASE checklist from GDD §25/§26); status must be READY FOR MANUAL TEST; optionally generate a ready `.rbxlx` from the source tree (script/module XML with CDATA) so the user can open without Rojo.

## 5. Known issues / checks to do on the existing files
- All files are unlinted; verify syntax by eye or with the linter once built. `Remotes.parseSpec` handles trailing `?`; enum split now skips empty parts (Luau gmatch returns empty matches).
- `EconomyConfig.E.Settlement.MaxExpenseShareOfCashDayOne` is an unused placeholder; remove if not used.
- `GameConfig.Sounds.Error` path is a guess; harmless if it fails to load.
- Plot-local frame comment in `BuildingConfig` header is slightly garbled; meaning: +Z faces the street, x mirrors for the south row.
- All balance numbers are playtest hypotheses (GDD §12).

## 6. Report template to the user (from the guide)
Aftman/Rojo version, BOM check, build, serve, plugin connection, smoke test, Place1 integrity, project audit — each PASS/FAIL/NOT TESTED. Never PASS without running.
