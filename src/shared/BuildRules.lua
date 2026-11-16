-- BuildRules: PURE placement rules shared by server (authoritative) and client (ghost colouring).
-- `owned` = { Upgrades = {[upgradeId]=true}, Annexes = {[annexId] = {State="Operational", Purpose="LaundryRoom"}} }
-- `placed` = { [objectId] = {ItemId=, CellX=, CellZ=, Rot=, Floor=} }
local Config = require(script.Parent.config.BuildingConfig)

local BuildRules = {}
local G = Config.Grid

BuildRules.FloorTopY = 0.4
function BuildRules.floorY(floor) return (floor - 1) * Config.FloorHeight + BuildRules.FloorTopY end

-- Footprint (w,d) in cells after rotation
function BuildRules.footprint(itemDef, rot)
	local w, d = itemDef.Footprint[1], itemDef.Footprint[2]
	if rot % 2 == 1 then return d, w end
	return w, d
end

-- Cell rectangle {x0,z0,x1,z1} END-EXCLUSIVE in cell coordinates
function BuildRules.cellRect(itemDef, cx, cz, rot)
	local w, d = BuildRules.footprint(itemDef, rot)
	return cx, cz, cx + w, cz + d
end

-- Plot-local centre of the footprint at the floor surface of `floor`. Model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, yawFor(rot), 0))
function BuildRules.cellToLocal(itemDef, cx, cz, rot, floor)
	local w, d = BuildRules.footprint(itemDef, rot)
	return Vector3.new((cx + w / 2) * G, BuildRules.floorY(floor or 1), (cz + d / 2) * G)
end

-- Inverse: nearest origin cell so that the footprint centre is closest to local (x,z)
function BuildRules.localToCell(itemDef, x, z, rot)
	local w, d = BuildRules.footprint(itemDef, rot)
	return math.floor(x / G - w / 2 + 0.5), math.floor(z / G - d / 2 + 0.5)
end

local function areaEnabled(area, owned)
	local req = area.Requires
	if not req then return true end
	owned = owned or {}
	if req.Upgrade then
		return owned.Upgrades ~= nil and owned.Upgrades[req.Upgrade] == true
	end
	if req.Annex then
		local a = owned.Annexes and owned.Annexes[req.Annex]
		return a ~= nil and a.State == "Operational" and (req.Purpose == nil or a.Purpose == req.Purpose)
	end
	return true
end

-- List of enabled placement areas: { {Id=, Floor=, MinX=, MaxX=, MinZ=, MaxZ=}, ... } (studs, plot-local)
function BuildRules.getAreas(owned)
	local out = {}
	for id, area in pairs(Config.Areas) do
		if areaEnabled(area, owned) then
			table.insert(out, { Id = id, Floor = area.Floor, MinX = area.MinX, MaxX = area.MaxX, MinZ = area.MinZ, MaxZ = area.MaxZ })
		end
	end
	table.sort(out, function(a, b) return a.Id < b.Id end)
	return out
end

function BuildRules.getReserved(owned)
	local out = {}
	for _, r in ipairs(Config.Reserved) do
		if areaEnabled(r, owned) then table.insert(out, r) end
	end
	return out
end

-- Is the cell (cx,cz) [cell lower-left corner in studs = cx*G] inside one of the areas on `floor`?
local function cellInAreas(areas, cx, cz, floor)
	local x0, z0 = cx * G, cz * G
	local x1, z1 = x0 + G, z0 + G
	for _, a in ipairs(areas) do
		if a.Floor == floor and x0 >= a.MinX and x1 <= a.MaxX and z0 >= a.MinZ and z1 <= a.MaxZ then return true end
	end
	return false
end

local function rectsOverlap(ax0, az0, ax1, az1, bx0, bz0, bx1, bz1)
	return ax0 < bx1 and bx0 < ax1 and az0 < bz1 and bz0 < az1
end

-- Returns ok:boolean, code:string?   codes: InvalidFloor | OutOfBounds | Reserved | Overlap
function BuildRules.validate(owned, placed, itemDef, cx, cz, rot, floor, ignoreObjectId)
	if rot < 0 or rot > 3 or rot ~= math.floor(rot) then return false, "OutOfBounds" end
	local areas = BuildRules.getAreas(owned)
	local hasFloor = false
	for _, a in ipairs(areas) do
		if a.Floor == floor then hasFloor = true break end
	end
	if not hasFloor then return false, "InvalidFloor" end

	local x0, z0, x1, z1 = BuildRules.cellRect(itemDef, cx, cz, rot)
	for ix = x0, x1 - 1 do
		for iz = z0, z1 - 1 do
			if not cellInAreas(areas, ix, iz, floor) then return false, "OutOfBounds" end
		end
	end
	-- reserved keep-out zones (studs)
	for _, r in ipairs(BuildRules.getReserved(owned)) do
		if r.Floor == nil or r.Floor == floor then
			if rectsOverlap(x0 * G, z0 * G, x1 * G, z1 * G, r.MinX, r.MinZ, r.MaxX, r.MaxZ) then return false, "Reserved" end
		end
	end
	-- overlap with other objects on the same floor
	for objectId, o in pairs(placed) do
		if objectId ~= ignoreObjectId and o.Floor == floor then
			local def = Config.Items[o.ItemId]
			if def then
				local flatA, flatB = itemDef.Flat == true, def.Flat == true
				if flatA == flatB then
					local ox0, oz0, ox1, oz1 = BuildRules.cellRect(def, o.CellX, o.CellZ, o.Rot)
					if rectsOverlap(x0, z0, x1, z1, ox0, oz0, ox1, oz1) then return false, "Overlap" end
				end
			end
		end
	end
	return true, nil
end

-- Per-item / per-kind instance limits. Returns ok, "MaxReached"?
function BuildRules.checkLimits(placed, itemDef, ignoreObjectId)
	local nItem, nKind = 0, 0
	for objectId, o in pairs(placed) do
		if objectId ~= ignoreObjectId then
			if o.ItemId == itemDef.Id then nItem += 1 end
			local def = Config.Items[o.ItemId]
			if def and def.Kind == itemDef.Kind then nKind += 1 end
		end
	end
	if itemDef.Max and nItem >= itemDef.Max then return false, "MaxReached" end
	if itemDef.MaxKind and nKind >= itemDef.MaxKind then return false, "MaxReached" end
	return true, nil
end

-- Which required kinds (Washer/Dryer/Counter) are still missing from `placed`? Returns array of kind strings.
function BuildRules.missingRequired(placed)
	local have = {}
	for _, o in pairs(placed) do
		local def = Config.Items[o.ItemId]
		if def then have[def.Kind] = true end
	end
	local missing = {}
	for _, kind in ipairs(Config.RequiredKinds) do
		if not have[kind] then table.insert(missing, kind) end
	end
	return missing
end

return BuildRules
