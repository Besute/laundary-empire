-- BuildingConfig: plot geometry (plot-local studs), placement areas, placeable catalog, upgrades, annex properties.
--
-- PLOT-LOCAL FRAME: origin = lot centre on the ground (y = 0 = ground top), +Z points to the street, +X right when
-- looking from the street INTO the lot... (i.e. world X for the north row; mirrored for the south row, which is simply the
-- same frame rotated 180 deg). All persisted positions use this frame; PlotService converts to world.
local B = {}

B.Grid = 2 -- studs per grid cell
B.FloorHeight = 14
B.WallThickness = 1

-- Footprints are in cells {w, d} at rotation 0; odd rotations swap. Cell (cx,cz) covers studs [cx*G,(cx+1)*G] x [cz*G,(cz+1)*G].
-- ITEM FACING: rotation r gives yaw = rad(180 + 90*r) about +Y, so at r=0 the item's "front" (CFrame.LookVector) faces +Z (the street/door).
-- All item models must be built with their front toward -Z in model space (identity LookVector).
function B.yawFor(rot) return math.rad(180 + 90 * rot) end

B.Plot = {
	Lot = { MinX = -50, MaxX = 50, MinZ = -32, MaxZ = 32 },
	Building = { MinX = -20, MaxX = 20, MinZ = -26, MaxZ = 10 }, -- outer wall rectangle
	Interior = { MinX = -19, MaxX = 19, MinZ = -25, MaxZ = 9 },
	Door = { X = 0, Z = 10, Width = 6, Height = 9 },
	BackPartitionZ = -13, -- wall closing the Back room until upgrade "BackRoom"
	Forecourt = { MinX = -20, MaxX = 20, MinZ = 10, MaxZ = 32 },
	Annexes = {
		AnnexL = { MinX = -46, MaxX = -21, MinZ = -26, MaxZ = 10, DoorSide = "Right" }, -- shares a wall with the main building
		AnnexR = { MinX = 21, MaxX = 46, MinZ = -26, MaxZ = 10, DoorSide = "Left" },
	},
	SpawnLocal = Vector3.new(0, 3, 24), -- player spawn: forecourt, facing the building (-Z)
}

-- Placement areas. "Requires" is evaluated by BuildRules.getAreas(owned).
B.Areas = {
	Main = { Floor = 1, MinX = -18, MaxX = 18, MinZ = -12, MaxZ = 8 },
	Back = { Floor = 1, MinX = -18, MaxX = 18, MinZ = -24, MaxZ = -12, Requires = { Upgrade = "BackRoom" } },
	AnnexL = { Floor = 1, MinX = -44, MaxX = -22, MinZ = -24, MaxZ = 8, Requires = { Annex = "AnnexL", Purpose = "LaundryRoom" } },
	AnnexR = { Floor = 1, MinX = 22, MaxX = 44, MinZ = -24, MaxZ = 8, Requires = { Annex = "AnnexR", Purpose = "LaundryRoom" } },
	Upper = { Floor = 2, MinX = -18, MaxX = 18, MinZ = -24, MaxZ = 8, Requires = { Upgrade = "SecondFloor" } },
}
-- Keep-out rectangles (never buildable). Floor = nil means all floors.
B.Reserved = {
	{ Name = "Doorway", Floor = 1, MinX = -4, MaxX = 4, MinZ = 4, MaxZ = 8 },
	{ Name = "Stairs", MinX = -18, MaxX = -14, MinZ = -24, MaxZ = -12, Requires = { Upgrade = "SecondFloor" } },
}

B.Categories = { "Equipment", "Reception", "Storage", "Interior", "Lighting", "Sanitation", "Security", "Extras" }

-- Bonus keys used by services:
--   InteriorPoints (RatingService, capped per ItemId by RatingConfig), StorageCap (InventoryService), BinCap (CleanlinessService),
--   DetergentSaving (chance 0..1 a cycle consumes no detergent), QualityBonus (+quality), ExtraPay (+% payment),
--   SortAssist (halves wrong-mode penalty when auto settings are used), PackSpeed (employee packing speed mult), Light (PointLight)
-- Kind: Washer | Dryer | Rack | Counter | Storage | Decor | Lamp | Bin | Camera | Alarm | Register | Extra
-- Max: max instances of this ItemId per plot (nil = unlimited, but GameConfig.Limits applies). MaxKind: max instances of a Kind.
B.Items = {
	-- Equipment (washers/dryers/racks)
	Washer_Basic = { Category = "Equipment", Kind = "Washer", Price = 850, Level = 1, Footprint = { 2, 2 }, Capacity = 8, CycleMult = 1.0, QualityMult = 1.0, Tier = 1 },
	Washer_Large = { Category = "Equipment", Kind = "Washer", Price = 2600, Level = 8, Footprint = { 3, 2 }, Capacity = 14, CycleMult = 1.0, QualityMult = 1.05, Tier = 2 },
	Washer_Pro = { Category = "Equipment", Kind = "Washer", Price = 7200, Level = 15, Footprint = { 3, 3 }, Capacity = 22, CycleMult = 0.85, QualityMult = 1.10, Tier = 3 },
	Dryer_Basic = { Category = "Equipment", Kind = "Dryer", Price = 650, Level = 1, Footprint = { 2, 2 }, Capacity = 8, CycleMult = 1.0, QualityMult = 1.0, Tier = 1 },
	Dryer_Large = { Category = "Equipment", Kind = "Dryer", Price = 2100, Level = 8, Footprint = { 3, 2 }, Capacity = 14, CycleMult = 1.0, QualityMult = 1.05, Tier = 2 },
	Dryer_Pro = { Category = "Equipment", Kind = "Dryer", Price = 5600, Level = 15, Footprint = { 3, 3 }, Capacity = 22, CycleMult = 0.85, QualityMult = 1.10, Tier = 3 },
	DryingRack = { Category = "Equipment", Kind = "Rack", Price = 240, Level = 2, Footprint = { 3, 1 }, Capacity = 4, CycleMult = 2.0, QualityMult = 0.95, Tier = 0 },
	-- Reception
	Counter_Basic = { Category = "Reception", Kind = "Counter", Price = 280, Level = 1, Footprint = { 4, 2 }, MaxKind = 3, Bonus = { InteriorPoints = 1 } },
	Counter_Modern = { Category = "Reception", Kind = "Counter", Price = 900, Level = 6, Footprint = { 5, 2 }, MaxKind = 3, Bonus = { InteriorPoints = 3 } },
	-- Storage
	Shelf = { Category = "Storage", Kind = "Storage", Price = 180, Level = 2, Footprint = { 3, 1 }, Bonus = { StorageCap = 30 } },
	Cabinet = { Category = "Storage", Kind = "Storage", Price = 420, Level = 5, Footprint = { 2, 1 }, Bonus = { StorageCap = 70, InteriorPoints = 1 } },
	-- Interior decor (floor-standing in MVP)
	WaitingChair = { Category = "Interior", Kind = "Decor", Price = 70, Level = 1, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 1 } },
	Plant_Small = { Category = "Interior", Kind = "Decor", Price = 60, Level = 1, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 1 } },
	Plant_Large = { Category = "Interior", Kind = "Decor", Price = 120, Level = 2, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 2 } },
	Easel_Painting = { Category = "Interior", Kind = "Decor", Price = 90, Level = 2, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 2 } },
	Clock_Tall = { Category = "Interior", Kind = "Decor", Price = 120, Level = 3, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 2 } },
	Sofa = { Category = "Interior", Kind = "Decor", Price = 180, Level = 3, Footprint = { 3, 1 }, Bonus = { InteriorPoints = 3 } },
	TV_Stand = { Category = "Interior", Kind = "Decor", Price = 260, Level = 4, Footprint = { 2, 1 }, Bonus = { InteriorPoints = 3 } },
	Neon_Sign = { Category = "Interior", Kind = "Decor", Price = 210, Level = 5, Footprint = { 2, 1 }, Bonus = { InteriorPoints = 3, Light = true } },
	Rug = { Category = "Interior", Kind = "Decor", Price = 100, Level = 2, Footprint = { 4, 3 }, Flat = true, Bonus = { InteriorPoints = 2 } },
	-- Lighting
	Lamp_Floor = { Category = "Lighting", Kind = "Lamp", Price = 80, Level = 1, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 1, Light = true } },
	Light_Panel = { Category = "Lighting", Kind = "Lamp", Price = 140, Level = 4, Footprint = { 1, 1 }, Bonus = { InteriorPoints = 2, Light = true } },
	-- Sanitation
	TrashBin = { Category = "Sanitation", Kind = "Bin", Price = 50, Level = 1, Footprint = { 1, 1 }, Bonus = { BinCap = 10 } },
	TrashBin_Large = { Category = "Sanitation", Kind = "Bin", Price = 140, Level = 5, Footprint = { 2, 1 }, Bonus = { BinCap = 25 } },
	-- Security
	Camera = { Category = "Security", Kind = "Camera", Price = 220, Level = 6, Footprint = { 1, 1 }, Max = 4 },
	Alarm = { Category = "Security", Kind = "Alarm", Price = 280, Level = 6, Footprint = { 1, 1 }, Max = 1 },
	Register_Secure = { Category = "Security", Kind = "Register", Price = 420, Level = 7, Footprint = { 2, 1 }, Max = 1 },
	Floodlight = { Category = "Security", Kind = "Lamp", Price = 160, Level = 5, Footprint = { 1, 1 }, Max = 2, Bonus = { Light = true, InteriorPoints = 1 } },
	-- Extras (late equipment from the GDD shop list)
	Dispenser = { Category = "Extras", Kind = "Extra", Price = 1800, Level = 10, Footprint = { 1, 1 }, Max = 1, Bonus = { DetergentSaving = 0.25 } },
	SteamGenerator = { Category = "Extras", Kind = "Extra", Price = 3200, Level = 12, Footprint = { 2, 2 }, Max = 1, Bonus = { QualityBonus = 0.05 } },
	IroningStation = { Category = "Extras", Kind = "Extra", Price = 2400, Level = 11, Footprint = { 3, 2 }, Max = 1, Bonus = { ExtraPay = 0.08 } },
	Sorter = { Category = "Extras", Kind = "Extra", Price = 2800, Level = 13, Footprint = { 2, 2 }, Max = 1, Bonus = { SortAssist = 0.5 } },
	PackingMachine = { Category = "Extras", Kind = "Extra", Price = 3600, Level = 14, Footprint = { 3, 2 }, Max = 1, Bonus = { PackSpeed = 2.0 } },
}
for id, def in pairs(B.Items) do def.Id = id end

-- Display order inside categories (ids). Anything missing is appended alphabetically by the UI.
B.ItemOrder = {
	"Washer_Basic", "Dryer_Basic", "DryingRack", "Washer_Large", "Dryer_Large", "Washer_Pro", "Dryer_Pro",
	"Counter_Basic", "Counter_Modern", "Shelf", "Cabinet",
	"WaitingChair", "Plant_Small", "Plant_Large", "Easel_Painting", "Clock_Tall", "Sofa", "TV_Stand", "Neon_Sign", "Rug",
	"Lamp_Floor", "Light_Panel", "TrashBin", "TrashBin_Large",
	"Camera", "Alarm", "Register_Secure", "Floodlight",
	"Dispenser", "SteamGenerator", "IroningStation", "Sorter", "PackingMachine",
}

-- The three objects required to open the business (GDD §2)
B.RequiredKinds = { "Washer", "Dryer", "Counter" } -- Dryer may be satisfied by Rack? No: a real dryer is required to open.

-- Non-placed purchases. RequestPurchase(kind="Upgrade", id=...). Level = minimum player level. Requires = upgrade ids.
-- Group "Renovation" tracks each give +5 InteriorPoints (see RatingConfig). Effects are applied by PlotService.
B.Upgrades = {
	Walls_1 = { Group = "Renovation", Track = "Walls", Step = 1, Price = 300, Level = 1 },
	Walls_2 = { Group = "Renovation", Track = "Walls", Step = 2, Price = 800, Level = 5, Requires = { "Walls_1" } },
	Walls_3 = { Group = "Renovation", Track = "Walls", Step = 3, Price = 1800, Level = 10, Requires = { "Walls_2" } },
	Floor_1 = { Group = "Renovation", Track = "Floor", Step = 1, Price = 400, Level = 1 },
	Floor_2 = { Group = "Renovation", Track = "Floor", Step = 2, Price = 900, Level = 5, Requires = { "Floor_1" } },
	Floor_3 = { Group = "Renovation", Track = "Floor", Step = 3, Price = 2000, Level = 10, Requires = { "Floor_2" } },
	Lighting_1 = { Group = "Renovation", Track = "Lighting", Step = 1, Price = 250, Level = 1 },
	Lighting_2 = { Group = "Renovation", Track = "Lighting", Step = 2, Price = 700, Level = 5, Requires = { "Lighting_1" } },
	Lighting_3 = { Group = "Renovation", Track = "Lighting", Step = 3, Price = 1500, Level = 10, Requires = { "Lighting_2" } },
	Windows_1 = { Group = "Renovation", Track = "Windows", Step = 1, Price = 300, Level = 2 },
	Windows_2 = { Group = "Renovation", Track = "Windows", Step = 2, Price = 900, Level = 6, Requires = { "Windows_1" } },
	Windows_3 = { Group = "Renovation", Track = "Windows", Step = 3, Price = 1800, Level = 11, Requires = { "Windows_2" } },
	BackRoom = { Group = "Expansion", Price = 1800, Level = 4 },
	SecondFloor = { Group = "Expansion", Price = 9000, Level = 12, Requires = { "BackRoom" } },
	Parking_S = { Group = "Parking", Price = 350, Level = 3, Spots = 3 },
	Parking_M = { Group = "Parking", Price = 1400, Level = 7, Spots = 6, Requires = { "Parking_S" } },
	Parking_L = { Group = "Parking", Price = 4200, Level = 12, Spots = 12, Requires = { "Parking_M" } },
	DoorLock_1 = { Group = "Security", Price = 300, Level = 5 },
	DoorLock_2 = { Group = "Security", Price = 900, Level = 10, Requires = { "DoorLock_1" } },
}
for id, def in pairs(B.Upgrades) do def.Id = id end
B.UpgradeOrder = {
	"Walls_1", "Walls_2", "Walls_3", "Floor_1", "Floor_2", "Floor_3", "Lighting_1", "Lighting_2", "Lighting_3",
	"Windows_1", "Windows_2", "Windows_3", "BackRoom", "SecondFloor", "Parking_S", "Parking_M", "Parking_L", "DoorLock_1", "DoorLock_2",
}

-- Neighbouring abandoned buildings. States: Locked -> Available -> (ReservedForPurchase) -> Owned -> UnderRenovation -> Operational (+Disabled)
B.Properties = {
	AnnexL = { Id = "AnnexL", Price = 6500, Level = 8, RenovationCost = 1500, RenovationSeconds = 60 },
	AnnexR = { Id = "AnnexR", Price = 9000, Level = 12, RenovationCost = 2500, RenovationSeconds = 90 },
}
B.PropertyIds = { "AnnexL", "AnnexR" }
B.PropertyStates = { "Locked", "Available", "ReservedForPurchase", "Owned", "UnderRenovation", "Operational", "Disabled" }
B.Purposes = {
	LaundryRoom = { Bonus = {} }, -- opens a placement Area (Areas.AnnexL / Areas.AnnexR)
	Warehouse = { Bonus = { StorageCap = 150 } },
	Parking = { Bonus = { ParkingSpots = 4 } },
	Office = { Bonus = { EmployeeSlots = 2, InteriorPoints = 3 } },
}
B.PurposeOrder = { "LaundryRoom", "Warehouse", "Parking", "Office" }

-- Facade looks (WorldBuilder reads these; client previews them in the setup screen)
B.Facades = {
	Modern = { Wall = Color3.fromRGB(232, 238, 242), Accent = Color3.fromRGB(0, 170, 170), Roof = Color3.fromRGB(70, 80, 90), Awning = Color3.fromRGB(0, 170, 170) },
	Classic = { Wall = Color3.fromRGB(176, 92, 74), Accent = Color3.fromRGB(240, 226, 196), Roof = Color3.fromRGB(80, 58, 52), Awning = Color3.fromRGB(40, 90, 70) },
	Colorful = { Wall = Color3.fromRGB(255, 214, 120), Accent = Color3.fromRGB(240, 110, 170), Roof = Color3.fromRGB(110, 90, 190), Awning = Color3.fromRGB(110, 190, 240) },
}

B.Renovation = { Tracks = { "Walls", "Floor", "Lighting", "Windows" }, MaxStep = 3 }

return B
