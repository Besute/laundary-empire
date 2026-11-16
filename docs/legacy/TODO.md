# TODO вЂ” staged against Laundry_Empire_GDD_RU.txt

Statuses: `[ ]` not started В· `[~]` in progress В· `[x]` verified in Studio В· `[!]` blocked.

## Stage 0 вЂ” Audit / scaffold
- [x] Read GDD and record approved decisions, MVP scope, and safety rules.
- [x] Set up Rojo mapping and initial server/client/shared source layout.\n- [x] Scope sync to intended roots and preserve unknown children within the mapped roots.\n- [x] Add bounded Rojo sync scopes and preserve unmapped Studio/MCP children.
- [~] Inventory built-in place content and root children; full script/UI/asset audit awaits a verified Rojo sync session.
- [x] Remove UTF-8 BOM risk from `default.project.json`; direct Rojo 7.7.1 build succeeds.\n- [ ] Verify live Rojo plugin sync and preservation behavior against the intended Studio place.

## Stage 1 вЂ” Starter world and player data
- [ ] Create the Downtown starting block and abandoned starter laundry.
- [ ] Assign each player an isolated plot; prevent cross-player ownership edits.
- [ ] Persist business name and one of three cosmetic facades.
- [ ] Implement versioned profile load/save and safe session locking.

## Stage 2 вЂ” Build and business setup
- [ ] Add build UI, grid preview, rotate/cancel/confirm, and hybrid camera.
- [ ] Place washer, dryer, and intake counter with server-side plot/bounds/overlap validation.
- [ ] Add business name, hours, and open/closed controls.
- [ ] Restore placement layout after rejoin.

## Stage 3 вЂ” One complete order (MVP core)
- [ ] Implement one customer/order offer with accept and polite decline.
- [ ] Enforce server-side order states and washer capacity across all unfinished orders.
- [ ] Add menu-driven item loading, detergent and wash mode selection.
- [ ] Implement wash в†’ transfer в†’ dry в†’ pack в†’ pickup workflow.
- [ ] Pay Cash and XP exactly once; preserve orders if customer/player leaves.

## Stage 4 вЂ” Queue and customers
- [ ] Queue limit, patience, departure, return-for-pickup, and feedback.
- [ ] Bounded NPC population, route timeout, and path retry.

## Stage 5 вЂ” Rating and cleanliness
- [ ] Service/cleanliness/interior/speed/review rating components.
- [ ] Event-driven dirt and manual cleaning; no per-frame dirt simulation.

## Stage 6 вЂ” Shop and inventory
- [ ] Server-validated consumable purchase, persistence, and one-time consumption.

## Stage 7 вЂ” Economy and progression
- [ ] Cash, XP, levels, unlocks, costs, wages, utilities, taxes, transaction ledger.
- [ ] Keep balance hypotheses in shared config; no offline production/income in MVP.

## Stage 8 вЂ” Equipment wear and repair
- [ ] Wear warnings, breakdown, repair, and preservation of in-flight orders/items.

## Stage 9 вЂ” Employees
- [ ] Hiring/firing, roles, zones, task queue, wage schedule, no duplicate task execution.

## Later stages (after MVP)
- [ ] Downtown pedestrians/traffic/day-night and parking.
- [ ] Night security, theft, alarms, police, bounded damage.
- [ ] Adjacent property purchase, renovation, horizontal/vertical expansion.
- [ ] Advertising, auctions, release polish, accessibility and multiplayer QA.
- [ ] Rebirth, additional districts, offline income, and complex multi-floor systems remain out of MVP.

## Verification gates
- [ ] New player completes tutorial and full first order.
- [ ] Returning player recovers profile and unfinished orders without duplicate payout.
- [ ] Reject forged/duplicate remotes, invalid item IDs, out-of-range builds, insufficient funds, broken machines, and over-capacity orders.
- [ ] Exercise DataStore failure, player departure, server shutdown, stuck NPC, and simultaneous requests.
- [ ] Test PC, mobile, gamepad, and multiplayer ownership isolation.
