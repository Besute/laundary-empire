-- City layout and ambient-traffic configuration based on the supplied city reference.
-- Layout is intentionally single-district MVP scale; future districts are not generated here.
local CityReferences = {}

CityReferences.Districts = {
	Main = {
		Id = "Main",
		Name = "Main District",
		Buildable = true,
		Origin = Vector3.new(0, 0, 0),
		Size = Vector2.new(620, 150),
		BlockCount = 10,
	},
	Central = {
		Id = "Central",
		Name = "Central District",
		Buildable = false,
		Origin = Vector3.new(-380, 0, -70),
		Size = Vector2.new(130, 110),
		BlockCount = 0,
	},
	Residential = {
		Id = "Residential",
		Name = "Residential District",
		Buildable = false,
		Origin = Vector3.new(0, 0, 250),
		Size = Vector2.new(620, 210),
		BlockCount = 0,
	},
}

CityReferences.Traffic = {
	CarLimit = 8,
	PedestrianLimit = 10,
	RouteSpeed = 17,
	RouteLanes = {
		EastboundZ = -4.5,
		WestboundZ = 4.5,
		RoadStartX = -330,
		RoadEndX = 330,
	},
	PedestrianSidewalkZ = { -19, 19 },
	SpawnInterval = { Min = 8, Max = 15 },
	VehicleColors = {
		Color3.fromRGB(226, 93, 82),
		Color3.fromRGB(67, 123, 173),
		Color3.fromRGB(232, 190, 91),
		Color3.fromRGB(74, 151, 112),
		Color3.fromRGB(230, 226, 211),
		Color3.fromRGB(87, 91, 101),
	},
}

CityReferences.Visuals = {
	BuildingFloorHeight = 7,
	TypicalFloors = { Min = 3, Max = 6 },
	HighRiseFloors = { Min = 7, Max = 11 },
	FarBackdropFloors = { Min = 12, Max = 16 },
	BlockSpacing = 86,
	StreetTreesPerSide = 14,
	Palette = {
		Brick = Color3.fromRGB(164, 97, 76),
		Sandstone = Color3.fromRGB(206, 177, 137),
		Cream = Color3.fromRGB(229, 217, 189),
		GlassBlue = Color3.fromRGB(106, 163, 190),
		GlassDark = Color3.fromRGB(73, 108, 128),
		Iron = Color3.fromRGB(61, 71, 77),
		FlowerPink = Color3.fromRGB(235, 152, 183),
		Leaf = Color3.fromRGB(77, 142, 91),
	},
}

return CityReferences
