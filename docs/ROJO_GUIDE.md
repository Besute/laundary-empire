# Laundry Empire — Updated Tasks and Rojo Guide

**Version:** 2.1 | **Date:** 2026-11-16

**Status:** The BOM issue and missing mapped source roots are fixed. Static Rojo checks pass. The local server was confirmed listening on localhost:34872 during the latest check and is stopped after verification. Studio plugin sync and Place1 integrity remain unverified.

## 1. Current status

### Historical cause of the earlier failure (fixed on 2026-11-14)

The beginning of `default.project.json` contained the bytes `EF BB BF` (a UTF-8 BOM), followed by the character `{` (`7B`). Rojo 7.7.1 rejected the BOM while parsing JSONC, so the file was saved as UTF-8 without a BOM.

**Fix command:**

```powershell
$content = Get-Content .\default.project.json -Raw
[System.IO.File]::WriteAllText(
    (Resolve-Path .\default.project.json),
    $content,
    [System.Text.UTF8Encoding]::new($false)
)
```

**Check:**

```powershell
Format-Hex .\default.project.json | Select-Object -First 2
```

Expected first byte: `7B` (not `EF BB BF`).

**Build for verification:**

```powershell
rojo build .\default.project.json --output .\build\LaundryEmpire-test.rbxl
```

The current static checks, rojo sourcemap and rojo build, pass. The shared source contains helpers and configuration modules. The server and client roots contain minimal English entry-point scripts only; gameplay systems have not been implemented. Rojo serve was tested on localhost:34872 and then stopped. Live Studio plugin sync and Place1 integrity have not been tested.

## 2. Immediate Rojo tasks

- [ ] **2.1.** Back up the project and the current Place1.
- [ ] **2.2.** From the project root, check the tools:

  ```powershell
  aftman --version
  rojo --version
  aftman list
  ```

  If the tools are not installed yet, run:

  ```powershell
  aftman install
  ```

  Aftman 0.3.0 does not support a `run` subcommand. After installation, open a new terminal and run `rojo --version` from the project root.

- [ ] **2.3.** Check that the project file has no BOM:

  ```powershell
  Format-Hex .\default.project.json | Select-Object -First 2
  ```

  The first bytes must start with `7B`, not `EF BB BF`.

- [ ] **2.4.** Build to a separate file:

  ```powershell
  New-Item -ItemType Directory -Force .\build
  rojo build .\default.project.json --output .\build\LaundryEmpire-test.rbxl
  ```

  Mark **BUILD PASS** only if the command finishes without errors and creates a non-empty file. Do not use the main Place1 as the output.

- [ ] **2.5.** Check the live server:

  ```powershell
  rojo serve .\default.project.json
  ```

  Leave PowerShell open. Confirm that Rojo reports a successful start and listens on a local address/port (often `localhost:34872`).

- [ ] **2.6.** Connect the Rojo plugin in Roblox Studio. Start with a test copy of Place1 or a separate test place. Do not connect to the main copy until a backup exists and the mapping has been checked.

- [ ] **2.7.** Run a smoke test in a folder already mapped by `default.project.json`. Create a temporary file named `RojoSmokeTest.lua`:

  ```lua
  local SmokeTest = {}

  SmokeTest.Status = "ROJO_SYNC_OK"
  SmokeTest.Version = 1

  return SmokeTest
  ```

  Check that:

  - [ ] The ModuleScript appears in the expected place in Explorer.
  - [ ] Changing `Version` from 1 to 2 syncs to Studio.
  - [ ] Deleting the file is reflected in Studio.
  - [ ] Studio works normally after disconnecting Rojo.

  Delete the temporary file after the test.

- [ ] **2.8.** Check Place1 integrity:
  - Compare Explorer before and after connecting.
  - Check important objects created manually or through MCP.
  - Confirm they were not removed or replaced.
  - Check `Workspace`, `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer`, and the other mapped nodes.
  - Clearly identify Rojo-owned and Studio-owned areas.
  - Review `$ignoreUnknownInstances` only in the context of the specific mapping. Do not add broad ignore rules without a clear reason.

## 3. How to avoid breaking Rojo again

**Main rule:** Save `default.project.json` and any other JSON/JSONC files read by Rojo as UTF-8 **without a BOM**.

### VS Code

1. Click the encoding indicator in the status bar.
2. Select **Save with Encoding**.
3. Select **UTF-8**.
4. Do not select **UTF-8 with BOM**.
5. After editing the project file, check its first bytes with `Format-Hex`.

### PowerShell: save one file without a BOM

```powershell
$path = (Resolve-Path .\default.project.json).Path
$content = Get-Content .\default.project.json -Raw
[System.IO.File]::WriteAllText(
    $path,
    $content,
    [System.Text.UTF8Encoding]::new($false)
)
```

Back up other files before converting them. Do not bulk-re-encode folders unless necessary.

### Before every build or sync

- [ ] Go to the project root.
- [ ] Confirm that you are using the intended `default.project.json`.
- [ ] Confirm that the file does not start with `EF BB BF`.
- [ ] Check JSON/JSONC syntax and mapping paths.
- [ ] Confirm that Aftman and Rojo run the expected versions.
- [ ] Build to a separate test file.
- [ ] Before live sync, confirm that a backup of Place1 exists.

### Do not

- Save project files as UTF-8 with a BOM.
- Assume that because PowerShell can read a file, the Rojo JSONC parser will accept it.
- Run Rojo from an arbitrary folder.
- Sync to the main Place1 before checking the backup and mapping.
- Build over the main working place file.
- Change the encoding, mapping, and tool versions all at once; it makes new errors harder to isolate.

### If the error happens again

1. Stop `rojo serve` with Ctrl+C.
2. Do not publish or save a questionable build over Place1.
3. Run `Format-Hex` on `default.project.json`.
4. If the file starts with `EF BB BF`, save it as UTF-8 without a BOM.
5. Build again to a separate file.
6. If there is no BOM, check JSON/JSONC syntax, mapping paths, tool versions, and the full error message.
7. Do not delete or recreate Studio objects blindly.

## 4. Next stage: Place1 audit

After **BUILD PASS**, **LIVE SYNC PASS**, and **PLACE1 INTEGRITY PASS**:

- [ ] Inventory services, folders, models, scripts, and UI.
- [ ] Mark objects created manually in Studio or through MCP.
- [ ] Find duplicate names, conflicts, and empty or unused nodes.
- [ ] Identify Rojo-owned and Studio-owned areas.
- [ ] Compare the current contents with the GDD architecture: `ReplicatedStorage.Shared.Config`, shared modules, server systems, client controllers, RemoteEvents/RemoteFunctions, UI, and models.
- [ ] List what to reuse, what to create, and what must not be changed.
- [ ] Record the results in `docs/legacy/TODO.md`, `docs/legacy/DECISIONS.md`, `docs/legacy/CHANGELOG.md`, and `docs/legacy/CHECKPOINT.md`.

## 5. Updated Laundry Empire MVP plan

### Decisions on record

- **Item loading: MENU** — choose the item type and quantity, play a loading animation, and visually move the clothes into the drum.
- **Camera: HYBRID** — use the normal Roblox third-person camera during gameplay and a separate angled/top-down view in build mode.
- **Hiring: GRADUAL** — the player does the work at first, then hires employees for specific roles.

### Stages

- [ ] **Stage 1: Project foundation and starting world**
  Module structure, a run-down starter laundry near a shopping center, player plots, spawn point, configs, and server/client startup.

- [ ] **Stage 2: Core gameplay loop**
  NPC customers, path to the counter, order, queue, patience, order pickup, completion, and a basic reward.

- [ ] **Stage 3: Washing and drying**
  Washers and dryers, loading menu, drum animation, wash/dry cycles, equipment states, and error handling.

- [ ] **Stage 4: Economy and progression**
  Money, expenses, XP, levels, unlocks, progress saving, and server-side validation of money transactions.

- [ ] **Stage 5: Cleanliness, quality, and rating**
  Room dirt, service quality, rating, and effects on customer traffic and income.

- [ ] **Stage 6: Shop and upgrades**
  Equipment purchases, inventory, placement, machine upgrades, prices, and unlock requirements.

- [ ] **Stage 7: Employees**
  Role-based hiring, wages, task assignment, and gradual automation.

- [ ] **Stage 8: Expansion and building**
  Room expansion, build camera, new areas/floors, parking, and additional objects.

- [ ] **Stage 9: Later systems, after the MVP is stable**
  Advertising, wear and breakdowns, day/night, thieves and police, transport, property, auctions, corporate orders, multiple districts, Rebirth, and late-game meta progression.

Do not start the later systems until the loop “customer → order → wash → dry → pickup → reward” works reliably and saves data.

## 6. Technical implementation rules

- The server is the source of truth for money, orders, rewards, inventory, and progress.
- The client handles UI, input, camera, and visual effects.
- Validate every RemoteEvent and RemoteFunction on the server.
- Do not trust the client for prices, reward amounts, item ownership, or confirmation that gameplay operations are complete.
- Implement DataStore with error handling and protection against data loss.
- Offline income is not part of the MVP.
- Rebirth, complex policing, auctions, and multiple districts are not part of the first release.
- Values in `EconomyConfig.lua` are still playtest hypotheses.
- Check NPC, machine, and UI performance with multiple players.

## 7. Criteria for the next checkpoint

### BUILD PASS

- [ ] `rojo build` completes successfully.
- [ ] A test RBXL is created and has a non-zero size.

### LIVE SYNC PASS

- [ ] `rojo serve` is running.
- [ ] The Studio plugin connects.
- [ ] The smoke-test ModuleScript appears.
- [ ] The `Version` change syncs.
- [ ] Deleting the file syncs.

### PLACE1 INTEGRITY PASS

- [ ] A backup exists.
- [ ] Important Place1 objects are preserved.
- [ ] The Rojo mapping has been checked.
- [ ] No Studio-owned objects were unintentionally removed or replaced.
- [ ] Studio works after disconnecting Rojo.

### PROJECT AUDIT PASS

- [ ] The Place1 inventory is recorded.
- [ ] Rojo-owned and Studio-owned areas are identified.
- [ ] Conflicts and gaps are listed in `docs/legacy/TODO.md`.
- [ ] `docs/legacy/CHECKPOINT.md` records the exact continuation point.

Start Stage 1 only after completing these checks.

## 8. Report template

```text
Aftman version:
Rojo version:
default.project.json BOM check: PASS / FAIL
Rojo build: PASS / FAIL
Rojo serve: PASS / FAIL
Studio plugin connection: PASS / FAIL
Smoke test create/update/delete: PASS / FAIL
Place1 integrity: PASS / FAIL / NOT TESTED
Project audit: PASS / FAIL / NOT STARTED
Errors and full logs:
Next task:
```

Do not mark a check **PASS** if it was not performed. If there is no confirmation, write **NOT TESTED**.

## 9. Claude Code project MCP

The project-level .mcp.json registers the Roblox_Studio MCP server by launching cmd.exe with /c %LOCALAPPDATA%\Roblox\mcp.bat. The JSON configuration parses and the Roblox launcher exists on this computer.

To connect from Claude Code, open this project folder, approve the project MCP server when prompted, then run /mcp and confirm Roblox_Studio is connected. In Roblox Studio, enable Studio as MCP server in Assistant → Settings → MCP Servers.

The configuration and launcher were checked, but a live Claude Code handshake was NOT VERIFIED because the Claude Code CLI is not available in this shell. This is separate from the Rojo Studio Plugin connection.
