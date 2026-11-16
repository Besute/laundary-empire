# Laundry Empire --- Agent Instructions

**Purpose:** This file is the shared operating guide for every AI coding
agent working on Laundry Empire. Read it before inspecting, planning, or
changing the project.

**Project:** Roblox multiplayer Simulator + Tycoon + Management game\
**Engine / language:** Roblox Studio / Luau\
**Project date:** 2026-11-16\
**Status:** Early development; core gameplay systems are not yet
implemented or verified in Roblox Studio.

------------------------------------------------------------------------

## 1. Start here: required context

Before doing any work:

1.  Read this `AGENTS.md` completely.
2.  Read the task-relevant source documents listed below. Do not assume
    this file replaces them.
3.  Inspect the actual repository and current Rojo project mapping
    before editing.
4.  Check whether the requested feature already exists.
5.  Identify dependencies, ownership boundaries, risks, and a testable
    acceptance criterion.
6.  Make the smallest safe change that completes the task.

### Source documents and their authority

  --------------------------------------------------------------------------------
  Source                           Use it for              Authority
  -------------------------------- ----------------------- -----------------------
  `docs/GDD_RU.txt`                Game vision, approved   **Design source of
                                   gameplay decisions,     truth**
                                   mechanics, progression, 
                                   MVP, design             
                                   requirements            

  `docs/HANDOFF.md`                     Current implementation  **Current engineering
                                   inventory, technical    handoff**
                                   architecture decisions, 
                                   detailed gameplay       
                                   semantics, work split,  
                                   known issues,           
                                   continuation state      

  `docs/ROJO_GUIDE.md`                  Rojo/Aftman setup,      **Rojo operating
                                   build and sync          procedure**
                                   procedure, encoding     
                                   rules, smoke tests and  
                                   checkpoint criteria     

  `docs/ROJO_OWNERSHIP.md`              Rojo-owned vs           **Ownership and sync
                                   Studio-owned content,   safety rules**
                                   mapping boundaries,     
                                   preservation            
                                   constraints             

  `docs/Updated_Tasks_Rojo_Guide.txt`   Current milestone       **Operational
                                   order, Rojo checklist,  checklist**
                                   Place1 audit checklist  
                                   and reporting template  

  `docs/concept.png`               Visual direction,       **Visual reference, not
                                   high-level game         a technical
                                   fantasy, illustrative   specification**
                                   roadmap and feature     
                                   overview                
  --------------------------------------------------------------------------------

If a document is stored at a different path in the current checkout,
locate it rather than creating a duplicate. Preserve existing filenames
and paths unless the task explicitly requires a documentation
reorganization.

### Conflict resolution

Use this order:

1.  Preserve player data, place integrity, server authority, and
    security.
2.  Follow explicit approved decisions in the GDD.
3.  Follow current technical decisions and implementation details in
    `docs/HANDOFF.md`, provided they do not contradict the GDD's approved
    design or safety requirements.
4.  Follow Rojo-specific ownership and sync constraints in
    `docs/ROJO_OWNERSHIP.md` and `docs/ROJO_GUIDE.md`.
5.  For unresolved conflicts, stop and document the conflict. Do not
    silently invent a decision.

The GDD was originally drafted in Russian; its current English translation remains the design source. Preserve its approved meaning; do not assume this summary contains every detail. When implementing a
feature, read the relevant GDD section directly.

------------------------------------------------------------------------

## 2. Project vision

Laundry Empire is a multiplayer Roblox Simulator + Tycoon + Management
game. A player starts with a small, abandoned laundromat near a shopping
mall. They initially serve customers and process laundry themselves,
then improve equipment and the building, hire employees, expand into
nearby properties, and eventually build a laundromat empire.

The core player fantasy:

> I started with a dirty, empty room and washed the first clothes
> myself. Now I own a beautiful network of laundromats, employees serve
> customers, cars park outside my branches, and my business helps the
> district grow.

### Design pillars

-   Clear, satisfying, interactive customer-service loop.
-   Visible business growth, building upgrades, and customization.
-   A living city with NPCs, cars, shops, and a day/night cycle.
-   Meaningful management of cash, reputation, staff, and operating
    costs.
-   Manageable operational risks: queues, dirt, breakdowns, and theft.
-   Long-term progression through real estate, floors, branches, and
    eventual Rebirth.

### Visual direction

-   Full 3D Roblox world; **not** an isometric game.
-   Blocky Roblox avatars and low-poly environment.
-   Pastel palette with turquoise accents.
-   Freely explorable interiors.
-   Clean, readable, adaptive UI for PC, mobile, tablet, and gamepad.

Use `docs/concept.png` as a visual reference. Do not treat text or
labels embedded in the concept image as a substitute for the GDD.

------------------------------------------------------------------------

## 3. Approved design decisions --- do not change casually

-   **Laundry loading:** MENU-based. The player interacts with a basket
    or machine, selects item types and quantities in a UI, then confirms
    loading. The character plays a loading animation and clothing models
    move visually into the drum. Do not implement manual dragging of
    every clothing model.
-   **Camera:** HYBRID. Normal third-person Roblox camera during
    gameplay; separate top-down/angled camera in build mode; restore the
    normal camera on exit.
-   **Employees:** GRADUAL automation. The player performs tasks first;
    roles unlock progressively, and each role automates a specific
    operation.
-   The player chooses a business name and one of three cosmetic facade
    styles: `Modern`, `Classic`, or `Colorful`.
-   The starting laundromat is abandoned, dirty, empty, and poorly lit.
-   Opening the business requires a washer, dryer, and order counter.
-   The player manages the business name, opening status, and schedule
    through the Business menu.
-   Customers form a queue, lose patience, and may leave.
-   The player may accept or politely decline an offered order. A polite
    decline is not equivalent to neglecting a customer.
-   Accepted orders are independent entities and must survive the
    customer's departure and the player's session interruption.
-   MVP has **no offline production or offline income**. Do not complete
    order cycles while the player is offline.
-   Rebirth, complex police systems, auctions, multiple districts,
    corporate/VIP orders, delivery, and other late-game systems must not
    delay the stable core loop.

For exact mechanics and exceptions, consult the corresponding GDD
sections and `docs/HANDOFF.md`.

------------------------------------------------------------------------

## 4. Current development state

Treat this as a checkpoint, not as proof that every item in the
repository has been independently verified.

### Confirmed from the engineering handoff

The current source tree is intended to include:

-   `default.project.json`
-   `src/shared/Util.lua`
-   `src/shared/Remotes.lua`
-   `src/shared/TimeUtil.lua`
-   `src/shared/BuildRules.lua`
-   src/shared/config contains game, economy, item, machine, order, employee, advertising, building, rating, NPC, event, tutorial, and error-code configuration modules.
-   src/server/init.server.lua and src/client/init.client.lua are minimal no-op entry-point scripts added during the current review; they contain no gameplay systems or UI.

The handoff says these files were created but **were not verified by a
Luau parser** at the time of handoff. Inspect the actual working tree
before relying on this inventory.

Not yet implemented according to the handoff:

-   `docs/CONTRACT.md`
-   Localization module and locale files
-   Server services and gameplay bootstrap (only the no-op entry point exists)
-   Client controllers and UI (only the no-op entry point exists)
-   Automated linting/simulation tools and tests
-   Final clean documentation and full test plan

The original legacy archive contained no Luau gameplay implementation.
Treat the game as a from-scratch build unless inspection of the current
working tree proves otherwise.

### Rojo / Windows checkpoint

The following was observed during the current project conversation:

-   Rojo version: `7.7.1`.
-   Aftman version: `0.3.0`.
-   The initial JSONC parse failure was caused by a UTF-8 BOM
    (`EF BB BF`) at the start of `default.project.json`. The file was
    rewritten as UTF-8 without BOM.
-   `rojo build default.project.json --output test.rbxl` completed
    successfully when the Rojo executable was invoked directly from
    `C:\Users\Boris\.aftman\bin\rojo.exe`.
-   The `HOME` environment variable was absent. Setting the user-level
    `HOME` to `USERPROFILE` resolved the Aftman/Rojo home-directory
    startup problem for a new PowerShell session.
-   A previous serve attempt could not bind 127.0.0.1:34872 because the port was already in use. At the latest review, no Rojo listener was present. After the missing src/server and src/client roots were restored, sourcemap and build passed; the project server was started on localhost:34872 for verification and was stopped after verification. The Studio Plugin connection remains NOT VERIFIED.
-   The project .mcp.json now registers Roblox_Studio through the local Roblox MCP launcher. The JSON and launcher path were verified; the live Claude Code handshake remains NOT VERIFIED because the Claude CLI is unavailable in this shell.
-   A successful build does not prove live sync, Studio connection, or
    Place1 integrity.
-   The Place has not been published. Do not publish it or overwrite the
    user's working Place1.

Always re-check the current machine and process state rather than
assuming this checkpoint is still current.

------------------------------------------------------------------------

## 5. Architecture and engineering rules

### Server authority

The server is authoritative for:

-   Cash, Gems, XP, levels, rewards, costs, and financial transactions.
-   Orders, order state transitions, customer/order ownership, and
    completion.
-   Property ownership, plot assignment, placed-object ownership, and
    building validation.
-   Inventory, machine state, employee task assignment, and progression.
-   Any gameplay outcome that affects another player or persistent data.

The client is responsible for:

-   UI and presentation.
-   Input handling.
-   Camera control and local build previews.
-   Local-only visual effects and non-authoritative feedback.

Never trust the client to provide a price, payout, owner, inventory
quantity, completion result, distance check, or other authoritative
value. Validate all remote requests on the server, including types,
ranges, permissions, distance, object state, and rate limits.

### Intended source layout

Follow the actual `default.project.json` mapping. The handoff describes
this intended layout:

-   `src/shared/` → `ReplicatedStorage.Shared`
-   `src/server/` → `ServerScriptService.Server`
-   `src/client/` → `StarterPlayer.StarterPlayerScripts.Client`

The broader GDD architecture also assigns server-only templates/assets
to `ServerStorage`, UI to `StarterGui`, and the generated world to
`Workspace`. Do not change the current mapping or introduce new roots
without inspecting the project file and documenting the decision.

### Technical patterns recorded in HANDOFF.md

Preserve these decisions unless the current code or an explicit approved
change supersedes them:

-   Server bootstrap: `init.server.lua` starts services through
    `ServiceLocator`; each service exposes `Init(ctx)` and `Start()`,
    with guarded startup.
-   Cross-service decoupling: `Core/Bus.lua` with `Bus.on` / `Bus.emit`.
-   Networking: `Core/Net.lua` registers request handlers, validates
    arguments against `Remotes`, rate-limits requests, handles errors,
    and returns a consistent `Result`.
-   Client-to-server requests currently use **RemoteFunctions**
    returning `Result`. This is a deliberate implementation deviation
    from the GDD's generic RemoteEvent wording; do not casually convert
    it. Record any change in `DECISIONS.md`.
-   Server-to-client state uses `StateUpdate` channels and client-side
    `ClientState`; notifications/effects use their dedicated remotes.
-   Timers use server time (`workspace:GetServerTimeNow()` or the
    established shared time abstraction), never a client clock as the
    source of truth.
-   Persistent money operations are idempotent using unique transaction
    IDs. Order payout must never be granted twice.
-   Data persistence uses schema versions, migrations, safe update
    operations, session locking, retry/backoff, autosave, and
    shutdown/player-removal handling.
-   Use in-memory Studio fallback only as documented; never claim
    persistence was tested just because the fallback works.
-   NPCs and vehicles should be performance-conscious. Use
    waypoints/anchored movement where specified rather than expensive
    physics for large crowds.
-   Localization uses keys and parameters; do not hard-code user-facing
    text in server notifications.
-   Use typed Luau where it improves clarity and safety.

### Naming and Windows/Rojo constraints

-   Avoid two files/folders in the same directory whose names differ
    only by case. Windows and Roblox instance naming can collapse case
    distinctions.
-   The shared config folder is lowercase `config`. Do not create a
    sibling `Config` folder.
-   The planned localization folder is `locales`, alongside the
    localization module. Do not create `loc` as a competing folder.
-   Keep file/folder naming consistent with existing source and Rojo
    mapping.

------------------------------------------------------------------------

## 6. Gameplay invariants

These invariants are more important than implementation convenience.

### Orders and customers

-   Order lifecycle transitions are controlled by `OrderService` and
    validated against the configured transition rules.
-   An order is not deleted when its NPC leaves or the player exits.
-   Accepting an order requires a server-side capacity check.
-   Capacity accounts for all unfinished accepted orders, including
    items in baskets, washers, and dryers, according to the approved
    implementation semantics.
-   A polite decline before acceptance is not an order failure and must
    not receive the same penalty as ignoring a customer.
-   Customer return timing, retry attempts, patience, and failure
    handling must follow `docs/HANDOFF.md` and the relevant GDD sections.
-   Completing collection pays the order exactly once using an
    idempotent transaction ID.

### Laundry workflow

The approved workflow is:

1.  Accept the customer order.
2.  Load selected item quantities through the menu.
3.  Select a compatible detergent/additive and wash mode.
4.  Run the wash cycle.
5.  Transfer washed items to a compatible dryer.
6.  Run the dry cycle.
7.  Pack the completed order.
8.  Collect/hand over the order when the customer is present.
9.  Grant payment and XP exactly once.

Validate item quantities, machine ownership, machine state, capacity,
compatibility, inventory, and order state on the server.

### Machines and breakdowns

-   A broken machine keeps its load; a breakdown must not silently
    delete clothes or orders.
-   Prevent starting an invalid cycle.
-   Permit only valid transfers to compatible available machines.
-   Maintenance and repair must follow configured costs, durations, and
    states.
-   Manual operation remains possible even after employees are
    introduced.

### Economy and progression

-   Economy numbers in configuration are **playtest hypotheses**, not
    final balance.
-   No infinite XP from repeated interactions or duplicate requests.
-   No duplicate payouts or charges.
-   The player must not suffer irreversible business loss.
-   No offline income or offline production in MVP.
-   Gems must not become a mandatory barrier to the core loop.
-   Record financial operations and make them auditable.

### Multiplayer and security

-   Each player owns their own business, properties, orders, and placed
    objects.
-   Players must not modify another player's objects or collect another
    player's orders.
-   Validate simultaneous purchases, claims, reservations, and auction
    operations on the server.
-   Do not expose server-only data or assets to clients unnecessarily.

------------------------------------------------------------------------

## 7. Rojo ownership, build, and sync safety

**Never treat a successful build as proof that live sync is safe.**

### Ownership boundaries

-   The Rojo project should map only the intended source-owned roots.
-   Do not use a broad full-DataModel mapping.
-   `$ignoreUnknownInstances` is scoped to mapped roots to preserve
    Studio/MCP-created descendants not represented on disk. Do not
    broaden or remove this behavior without inspecting the mapping and
    understanding the consequences.
-   The live Place previously contained a Studio-managed
    `ServerScriptService.LaundryEmpireScaffold`; it was preserved and
    marked in Studio. Verify its current presence before changing
    anything.
-   Rojo-generated root scripts such as `Server` and `Client` are
    source-owned. Children created manually through Studio/MCP under
    those roots must be migrated into source or explicitly protected
    according to the ownership policy.
-   Preserve Studio-owned objects. Do not delete, recreate, or replace
    unknown objects merely to make the Explorer match a source tree.

### Before build or sync

1.  Work from the project root.
2.  Confirm the exact `default.project.json` being used.
3.  Confirm JSON/JSONC files read by Rojo are UTF-8 **without BOM**.
4.  Confirm the Rojo/Aftman executable and versions.
5.  Inspect the mapping and ownership rules.
6.  Create a separate test build output; never build over the user's
    working Place1.
7.  Before live sync, create and verify a backup of the current Place.
8.  Prefer a test copy of Place1 or a separate test Place for initial
    sync tests.

### Safe build example

``` powershell
New-Item -ItemType Directory -Force .\build
rojo build .\default.project.json --output .\build\LaundryEmpire-test.rbxl
```

Mark BUILD PASS only if the command succeeds and the output file exists
with a non-zero size.

### Live sync and smoke test

Run `rojo serve` only after confirming that the port is available or
identifying the process already listening on it. Do not kill an unknown
process just to free the default port.

Then:

1.  Connect the Rojo Plugin in Roblox Studio to the correct local
    server.
2.  Use a test copy/place first.
3.  Add a temporary `RojoSmokeTest.lua` under a mapped source folder.
4.  Confirm that the ModuleScript appears at the expected Explorer
    location.
5.  Change a visible value (for example `Version = 1` to `Version = 2`)
    and confirm it updates in Studio.
6.  Delete the temporary file and confirm the instance is removed as
    expected.
7.  Disconnect Rojo and confirm Studio remains usable.
8.  Compare the Place before and after. Verify Studio-owned objects
    remain intact.
9.  Remove temporary test artifacts from source and Studio.

Do not claim LIVE SYNC PASS until connection and create/update/delete
behavior have actually been tested.

------------------------------------------------------------------------

## 8. Development phases and priorities

Work in this order. Do not skip ahead because a later feature looks more
interesting.

### Phase 0 --- Audit and toolchain safety

-   Verify repository structure and current Place contents.
-   Verify Rojo build, live sync, and Place integrity separately.
-   Inventory scripts, modules, models, remotes, UI, and manually
    created objects.
-   Identify Rojo-owned and Studio-owned areas.
-   Record current systems, gaps, duplicates, risks, and reusable
    assets.
-   Maintain `README.md`, `TODO.md`, `CHANGELOG.md`, `DECISIONS.md`, and
    `CHECKPOINT.md`.

### Phase 1 --- Project foundation and starting world

-   Module/service scaffolding.
-   Starting city street and abandoned laundromat.
-   Unique player plots and spawn points.
-   Business name and facade selection.
-   Basic player data and persistence.

### Phase 2 --- Core customer/order loop

-   Customer NPC reaches the counter.
-   Offer, accept, or polite decline.
-   Queue, patience, order persistence, and return.
-   Completion and basic reward.

### Phase 3 --- Washing and drying

-   Washers and dryers.
-   Menu-based loading and visual animation.
-   Detergent/mode selection.
-   Wash and dry cycles.
-   Machine states and error handling.

### Phase 4 --- Economy and progression

-   Cash, XP, levels, unlocks, costs, and transaction ledger.
-   Safe persistent progress and server validation.

### Phase 5 --- Cleanliness, quality, and rating

-   Dirt generation and cleanup.
-   Service quality, reviews, rating, and their effects.

### Phase 6 --- Shop and upgrades

-   Shop, inventory, purchases, consumables, placement, machine
    upgrades.

### Phase 7 --- Employees

-   Gradual role unlocks, hiring, wages, task queues, work zones, and
    safe task claiming.

### Phase 8 --- Expansion and construction

-   Building mode, grid, placement previews, validation, additional
    areas/floors, and expansion.

### Phase 9 --- Late systems

Only after the core loop is stable: advertising, auctions,
security/thieves/police, day/night events, traffic, parking, advanced
property, multiple districts, corporate orders, delivery, and Rebirth.

The GDD contains a more detailed 0--14 checkpoint roadmap. Use it when
planning specific milestones. The phase summary here is a navigation
aid, not permission to omit GDD requirements.

------------------------------------------------------------------------

## 9. Multi-agent collaboration

Multiple agents may work in parallel only when their file and instance
ownership is explicit.

### Before delegating

The coordinating agent must provide each worker:

-   Exact task and expected deliverable.
-   Exact files/directories the worker may edit.
-   Files/directories the worker must not edit.
-   Required interfaces, types, events, and service signatures.
-   Dependencies and assumptions.
-   Acceptance criteria and verification commands.
-   Required report format.

Do not assign two agents to edit the same file or overlapping Roblox
instance trees concurrently unless one is explicitly the integrator.

### Recommended work split

Use the module split in `docs/HANDOFF.md` as the starting point:

1.  Contract/documentation agent: define `docs/CONTRACT.md` before
    parallel service implementation.
2.  Tooling agent: build Luau linting, remote/require cross-checks, and
    deterministic simulation tools.
3.  Server platform agent: bootstrap, bus, service locator, networking,
    player data, state, business, building, tutorial, notifications,
    analytics.
4.  World agent: world builder, plots, item models, NPC/vehicle
    factories.
5.  Core loop agent: economy, inventory, orders, machines, maintenance,
    rating, cleanliness.
6.  NPC/late systems agent: customers, employees, parking, traffic,
    security, advertising, property.
7.  Client agent: client bootstrap, networking wrapper, state store, UI,
    controllers, camera, tutorial, effects, audio.
8.  Integration agent: merge, cross-check contracts, lint/simulate,
    update documentation, prepare manual test plan.

This is a suggested division, not a claim that these modules already
exist.

### Integration rules

-   Agree on contracts before parallel implementation.
-   Use stable function signatures, payload schemas, error codes, and
    event names.
-   Do not independently invent a second version of a shared contract.
-   The integrator resolves conflicts and runs cross-module checks.
-   Do not merge unverified code while reporting it as tested.

------------------------------------------------------------------------

## 10. Coding standards and implementation workflow

For every task:

1.  Inspect relevant code and documentation.
2.  State the intended minimal change and acceptance criteria.
3.  Check existing utilities/configs before adding new abstractions.
4.  Implement in small, reviewable steps.
5.  Keep gameplay logic server-side and presentation client-side.
6.  Put tunable balance values in configuration modules.
7.  Use clear Luau types and consistent `Result`/error conventions.
8.  Validate remote input and handle failure paths.
9.  Consider duplicate requests, disconnects, shutdowns, and
    simultaneous players.
10. Run available static checks/builds/tests.
11. Update relevant documentation and checkpoint.
12. Report exactly what was and was not verified.

Do not:

-   Rewrite whole systems without a demonstrated need.
-   Create fake/inert UI buttons or claim an unimplemented action works.
-   Add unreviewed Toolbox models or models with unknown scripts.
-   Add per-frame work when event-driven updates are sufficient.
-   Create excessive NPCs, physics-heavy traffic, parts, lights, or
    replicated state.
-   Change architecture or approved gameplay decisions without
    documenting the rationale.
-   Perform broad encoding conversions or mass file moves without
    backups.
-   Publish, overwrite, or save over the user's working Place1 without
    explicit authorization and a verified backup.

------------------------------------------------------------------------

## 11. Testing and truthful status reporting

Never claim a test passed unless it was actually run and its result
observed.

Use these statuses consistently:

-   **PASS** --- executed and passed.
-   **FAIL** --- executed and failed.
-   **BLOCKED** --- could not execute because of a stated blocker.
-   **NOT TESTED** --- not executed.
-   **READY FOR MANUAL TEST** --- code/static checks are complete, but
    Roblox Studio behavior still needs a human/manual run.

A successful JSON parse is not a Rojo build. A successful Rojo build is
not a live sync. A live sync is not proof of Place integrity. A module
loading with `require` is not proof that gameplay works.

### Required report template

``` text
Task:
Files changed:
Roblox instances affected:
Design/architecture decisions:
Checks run:
- Static/lint:
- Rojo build:
- Rojo serve:
- Studio Plugin connection:
- Smoke test:
- Gameplay test:
- Persistence/multiplayer/security:
Results: PASS / FAIL / BLOCKED / NOT TESTED / READY FOR MANUAL TEST
Known limitations:
Backup / Place1 impact:
Next step:
```

For the Rojo checkpoint, report these separately:

``` text
Aftman version:
Rojo version:
default.project.json BOM check:
Rojo build:
Rojo serve:
Studio Plugin connection:
Smoke test create/update/delete:
Place1 backup:
Place1 integrity:
Project audit:
Errors / logs:
Next task:
```

------------------------------------------------------------------------

## 12. Documentation maintenance

Keep these project documents current:

-   `README.md` --- setup, toolchain, project structure, build, serve,
    and test instructions.
-   `TODO.md` --- actionable tasks with explicit status and
    dependencies.
-   `CHANGELOG.md` --- user-visible and engineering changes.
-   `DECISIONS.md` --- approved decisions, alternatives, rationale, and
    consequences.
-   `CHECKPOINT.md` --- exact current state, verified results, blockers,
    and next action.
-   `docs/CONTRACT.md` --- data schemas, service APIs, bus events, state
    payloads, remotes, tags, and attributes.

When a decision changes, update `DECISIONS.md` and the relevant source
document. Do not leave contradictory instructions in multiple places.

------------------------------------------------------------------------

## 13. How to give an agent the right context

Do not merely say "use the project context" or "read the files." Name
the exact files and explain which one governs which part of the task.

### Recommended prompt structure

``` text
Read AGENTS.md first and follow it.

Task:
[One precise task and expected outcome.]

Context sources:
- docs/GDD_RU.txt — authoritative gameplay/design requirements; read sections [X, Y].
- HANDOFF.md — current code inventory, architecture, implementation semantics; read sections [X, Y].
- ROJO_GUIDE.md — only if this task touches build/sync/toolchain.
- ROJO_OWNERSHIP.md — mandatory if this task touches Rojo mapping or Studio instances.
- [specific source files] — inspect the current implementation before editing.

Scope:
- You may edit: [exact files/directories].
- Do not edit: [protected files/directories/Studio-owned content].
- Do not change approved decisions unless you stop and propose a documented change.

Acceptance criteria:
1. [...]
2. [...]
3. [...]

Verification:
- Run: [...]
- If Roblox Studio is unavailable, do not claim gameplay PASS; provide a manual test plan.

Report:
List changed files, affected instances, tests actually run, results, limitations, and next step.
```

### Short prompts for common tasks

**Gameplay feature**

``` text
Read AGENTS.md. For design, use docs/GDD_RU.txt sections [sections].
For current architecture and semantics, use docs/HANDOFF.md sections [sections].
Inspect the existing source before editing. Implement only [feature] in [allowed paths].
Keep server authority and existing contracts. Add/update tests and docs.
Report exact verification status; do not claim Studio testing unless performed.
```

**Rojo / Studio synchronization**

``` text
Read AGENTS.md, ROJO_GUIDE.md, ROJO_OWNERSHIP.md, and the Rojo checkpoint in HANDOFF.md.
Do not publish or overwrite Place1. First verify backups, project mapping, BOM-free encoding,
and build output. Identify the process using the Rojo port before stopping anything.
Use a test Place for sync and verify create/update/delete plus preservation of Studio-owned objects.
```

**Code review / audit**

``` text
Read AGENTS.md and the relevant GDD/HANDOFF sections. Do not modify files yet.
Inspect [specific paths]. Report current behavior, missing requirements, security/data risks,
duplicate implementations, dependencies, and a prioritized remediation plan with file references.
Separate verified facts from assumptions and untested behavior.
```

**Parallel agent task**

``` text
Read AGENTS.md and [named context files]. You own only [exact files].
Do not edit shared contracts or files owned by another agent.
Use these interfaces: [signatures/schema]. If a required interface is missing, propose it
to the coordinator instead of inventing a conflicting contract.
Return changed files, tests, limitations, and integration notes.
```

### Context-loading rules

-   Prefer **specific sections and source paths** over asking an agent
    to reread every document for every small task.
-   For a new agent or a broad task, read the full `AGENTS.md`,
    `docs/HANDOFF.md`, and relevant design sections.
-   For a narrow task, read `AGENTS.md`, the relevant GDD sections, the
    relevant HANDOFF sections, and the actual code being changed.
-   If the task touches Rojo, always include both `docs/ROJO_GUIDE.md` and
    `docs/ROJO_OWNERSHIP.md`.
-   If documents disagree, quote the conflicting statements and ask the
    coordinator to resolve them; do not silently choose.
-   Treat prior agent summaries as navigation aids, not as a substitute
    for inspecting source files.
-   Never assume an attachment, file, Roblox instance, or test result
    exists just because another agent mentioned it. Verify it in the
    current checkout/session.
-   If an agent cannot access a referenced file or Roblox Studio, it
    must say so and identify what evidence is missing.

------------------------------------------------------------------------

## 14. Definition of MVP

The MVP is complete only when a player can:

1.  Start a new laundromat and retain their business setup.
2.  Place the three required objects: washer, dryer, and counter.
3.  Open the business and receive an NPC customer order.
4.  Accept the order and load items through the menu.
5.  Select detergent and wash mode.
6.  Complete washing and drying.
7.  Pack and hand over the order.
8.  Receive the correct payment and XP exactly once.
9.  Improve the business and retain progress after rejoining.

The game must preserve data, enforce ownership and server validation,
and pass the relevant functional, failure, multiplayer, and security
tests described in the GDD.

Do not call the MVP complete based on a visual prototype, successful
build, or isolated module `require`.

------------------------------------------------------------------------

## 15. Final rule

**Protect the project first; implement the smallest correct step second;
verify it honestly; document the result.**

When uncertain, inspect the source, preserve existing content, and ask
the coordinator before making irreversible or cross-system changes.
