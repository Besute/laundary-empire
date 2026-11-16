-- Procedural, low-poly downtown built entirely from anchored Parts.
-- No Toolbox assets, external meshes, or physics-driven traffic are used.
local WorldBuilder = {}
local CityReferences = require(script.Parent:WaitForChild("CityReferences"))

local C = {
	WorldName = "LaundryWorld",
	CityName = "City",
	GroundY = 0.2,
	RoadLength = 620,
	RoadHalfWidth = 15,
	SidewalkWidth = 8,
	CrossStreetX = 300,
	PlotsPerSide = 5,
	PlotSpacing = 104,
	GroundSize = Vector3.new(760, 1, 480),
}

local P = CityReferences.Visuals.Palette
local COLORS = {
	Grass = Color3.fromRGB(137, 177, 126),
	Road = Color3.fromRGB(64, 70, 76),
	RoadLine = Color3.fromRGB(245, 222, 135),
	Concrete = Color3.fromRGB(194, 198, 191),
	Curb = Color3.fromRGB(224, 220, 205),
	Mint = Color3.fromRGB(148, 207, 188),
	Blue = Color3.fromRGB(133, 177, 205),
	Peach = Color3.fromRGB(224, 162, 133),
	Cream = Color3.fromRGB(230, 211, 163),
	Lilac = Color3.fromRGB(174, 154, 197),
	Window = Color3.fromRGB(171, 218, 229),
	Dark = Color3.fromRGB(54, 63, 70),
	Wood = Color3.fromRGB(126, 91, 65),
	Leaves = { Color3.fromRGB(93, 151, 104), Color3.fromRGB(117, 171, 107), Color3.fromRGB(156, 185, 112) },
	Flower = Color3.fromRGB(238, 174, 179),
}

local function folder(parent: Instance, name: string): Folder
	local current = parent:FindFirstChild(name)
	if current and current:IsA("Folder") then return current end
	local result = Instance.new("Folder")
	result.Name = name
	result.Parent = parent
	return result
end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local result = Instance.new("Part")
	result.Name = name
	result.Anchored = true
	result.Size = size
	result.CFrame = cf
	result.Color = color
	result.Material = material or Enum.Material.SmoothPlastic
	result.TopSurface = Enum.SurfaceType.Smooth
	result.BottomSurface = Enum.SurfaceType.Smooth
	result.CanCollide = true
	if shape then result.Shape = shape end
	result.Parent = parent
	return result
end

local function block(parent: Instance, name: string, size: Vector3, x: number, y: number, z: number, color: Color3, material: Enum.Material?): Part
	return part(parent, name, size, CFrame.new(x, y, z), color, material)
end

local function label(onPart: BasePart, text: string, color: Color3, textColor: Color3, width: number, height: number)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignSurface"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.LightInfluence = 0
	gui.CanvasSize = Vector2.new(width * 24, height * 24)
	gui.Parent = onPart
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = color
	textLabel.BorderSizePixel = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.Parent = gui
end

local function addBox(parent: Instance, name: string, size: Vector3, center: Vector3, color: Color3, material: Enum.Material?)
	return block(parent, name, size, center.X, center.Y, center.Z, color, material)
end

local function buildRoad(parent: Instance)
	local y = C.GroundY
	local half = C.RoadLength * 0.5
	-- A single continuous terrain slab avoids seams between roadside and plots.
	block(parent, "CityGround", C.GroundSize, 0, y - 0.6, 0, COLORS.Grass, Enum.Material.Grass)
	block(parent, "MainRoad", Vector3.new(C.RoadLength, 0.35, C.RoadHalfWidth * 2), 0, y - 0.05, 0, COLORS.Road, Enum.Material.Asphalt)
	for _, side in ipairs({ -1, 1 }) do
		local z = side * (C.RoadHalfWidth + C.SidewalkWidth * 0.5)
		local sidewalkLength = C.RoadLength * 0.5 - 12.5
		block(parent, "Sidewalk", Vector3.new(sidewalkLength, 0.5, C.SidewalkWidth), -C.CrossStreetX * 0.5 - 6.25, y + 0.2, z, COLORS.Concrete, Enum.Material.Concrete)
		block(parent, "Sidewalk", Vector3.new(C.RoadLength - C.CrossStreetX - 12.5, 0.5, C.SidewalkWidth), C.CrossStreetX + 6.25 + (C.RoadLength - C.CrossStreetX - 12.5) * 0.5, y + 0.2, z, COLORS.Concrete, Enum.Material.Concrete)
		local curbZ = side * (C.RoadHalfWidth + 0.35)
		local leftLength, rightLength = C.CrossStreetX - 23, C.RoadLength - C.CrossStreetX - 23
		block(parent, "Curb", Vector3.new(leftLength, 0.55, 0.7), -C.CrossStreetX * 0.5 - 11.5, y + 0.25, curbZ, COLORS.Curb, Enum.Material.Concrete)
		block(parent, "Curb", Vector3.new(rightLength, 0.55, 0.7), C.CrossStreetX + 11.5 + rightLength * 0.5, y + 0.25, curbZ, COLORS.Curb, Enum.Material.Concrete)
		part(parent, "CurbRamp", Vector3.new(12, 0.18, 2.5), CFrame.new(C.CrossStreetX, y + 0.22, side * (C.RoadHalfWidth + 0.5)) * CFrame.Angles(0, side * math.rad(8), 0), Color3.fromRGB(211, 208, 194), Enum.Material.Concrete)
	end
	for x = -half + 10, half - 10, 24 do
		block(parent, "CenterLine", Vector3.new(12, 0.08, 0.35), x, y + 0.16, 0, COLORS.RoadLine, Enum.Material.SmoothPlastic)
		block(parent, "CenterLine", Vector3.new(12, 0.08, 0.35), x, y + 0.16, 0.8, COLORS.RoadLine, Enum.Material.SmoothPlastic)
	end
	block(parent, "CrossStreet", Vector3.new(30, 0.37, 150), C.CrossStreetX, y - 0.04, 0, COLORS.Road, Enum.Material.Asphalt)
	for _, side in ipairs({ -1, 1 }) do
		block(parent, "CrossSidewalk", Vector3.new(8, 0.5, 150), C.CrossStreetX + side * 19, y + 0.2, 0, COLORS.Concrete, Enum.Material.Concrete)
		for i = -4, 4 do
			block(parent, "CrosswalkStripe", Vector3.new(1.25, 0.08, 2.1), C.CrossStreetX + i * 2.2, y + 0.17, side * 10.2, Color3.fromRGB(239, 239, 228), Enum.Material.SmoothPlastic)
		end
		block(parent, "StopLine", Vector3.new(0.6, 0.08, 10), C.CrossStreetX + side * 17, y + 0.17, side * 4.5, Color3.fromRGB(233, 232, 222), Enum.Material.SmoothPlastic)
	end
end

local function buildTree(parent: Instance, x: number, z: number, scale: number, index: number)
	local model = Instance.new("Model")
	model.Name = "StreetTree"
	model.Parent = parent
	local h = 5 * scale
	block(model, "Trunk", Vector3.new(1.15, h, 1.15), x, C.GroundY + h * 0.5, z, COLORS.Wood, Enum.Material.Wood)
	local lower = part(model, "Canopy_Lower", Vector3.new(5.2, 4.2, 5.2) * scale, CFrame.new(x, C.GroundY + h + 1.1 * scale, z), COLORS.Leaves[index], Enum.Material.Grass, Enum.PartType.Ball)
	local upper = part(model, "Canopy_Upper", Vector3.new(4.2, 3.8, 4.2) * scale, CFrame.new(x + 0.2 * scale, C.GroundY + h + 3.3 * scale, z - 0.15 * scale), COLORS.Leaves[index % 3 + 1], Enum.Material.Grass, Enum.PartType.Ball)
	lower.CanCollide = false
	upper.CanCollide = false
end

local function buildLamp(parent: Instance, x: number, z: number, facing: number)
	local model = Instance.new("Model")
	model.Name = "StreetLamp"
	model.Parent = parent
	block(model, "Base", Vector3.new(1.4, 0.5, 1.4), x, C.GroundY + 0.25, z, COLORS.Dark, Enum.Material.Metal)
	block(model, "Pole", Vector3.new(0.45, 12, 0.45), x, C.GroundY + 6.25, z, COLORS.Dark, Enum.Material.Metal)
	local pose = CFrame.new(x, C.GroundY + 12, z) * CFrame.Angles(0, facing, 0)
	local arm = part(model, "Arm", Vector3.new(4, 0.35, 0.35), pose * CFrame.new(1.6, 0, 0), COLORS.Dark, Enum.Material.Metal)
	local head = part(model, "LampHead", Vector3.new(1.8, 0.45, 1.2), pose * CFrame.new(3.3, -0.15, 0), Color3.fromRGB(255, 238, 184), Enum.Material.Neon)
	arm.CanCollide = false
	head.CanCollide = false
	local glow = Instance.new("PointLight")
	glow.Name = "StreetGlow"
	glow.Color = Color3.fromRGB(255, 226, 165)
	glow.Brightness = 0.8
	glow.Range = 20
	glow.Shadows = false
	glow.Parent = head
end

local function buildBench(parent: Instance, x: number, z: number, yaw: number)
	local model = Instance.new("Model")
	model.Name = "StreetBench"
	model.Parent = parent
	local pivot = CFrame.new(x, C.GroundY, z) * CFrame.Angles(0, yaw, 0)
	local function benchPart(name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?)
		return part(model, name, size, pivot * offset, color, material)
	end
	benchPart("Seat", Vector3.new(6, 0.35, 1.5), CFrame.new(0, 1.6, 0), COLORS.Wood, Enum.Material.Wood)
	benchPart("Back", Vector3.new(6, 1.8, 0.35), CFrame.new(0, 2.5, -0.58), COLORS.Wood, Enum.Material.Wood)
	for _, side in ipairs({ -2.35, 2.35 }) do
		benchPart("Leg", Vector3.new(0.35, 1.6, 1), CFrame.new(side, 0.8, 0), COLORS.Dark, Enum.Material.Metal)
	end
end

local function buildPlanter(parent: Instance, x: number, z: number, flowerColor: Color3)
	local model = Instance.new("Model")
	model.Name = "FlowerPlanter"
	model.Parent = parent
	block(model, "Planter", Vector3.new(5, 1.2, 2.5), x, C.GroundY + 0.6, z, COLORS.Curb, Enum.Material.Concrete)
	block(model, "Soil", Vector3.new(4.4, 0.25, 1.9), x, C.GroundY + 1.25, z, Color3.fromRGB(88, 72, 54), Enum.Material.Ground)
	for i = -1, 1 do
		local flower = part(model, "Flower", Vector3.new(0.8, 0.92, 0.8), CFrame.new(x + i * 1.25, C.GroundY + 2, z), flowerColor, Enum.Material.Grass, Enum.PartType.Ball)
		flower.CanCollide = false
	end
end

local function buildStreetFurniture(parent: Instance)
	for i, x in ipairs({ -260, -190, -120, -52, 52, 120, 190, 260, 340 }) do
		for _, side in ipairs({ -1, 1 }) do
			buildLamp(parent, x, side * 21, side == 1 and math.pi or 0)
			if i % 2 == 1 and math.abs(x - C.CrossStreetX) > 38 then
				buildTree(parent, x + 13, side * 24, i % 3 == 0 and 1.1 or 1, (i - 1) % 3 + 1)
			end
		end
	end
	buildBench(parent, -106, -21, math.pi)
	buildBench(parent, 150, 21, 0)
	buildPlanter(parent, -20, -20, COLORS.Flower)
	buildPlanter(parent, 20, 20, COLORS.Mint)
	buildPlanter(parent, C.CrossStreetX - 22, -21, COLORS.Flower)
	buildPlanter(parent, C.CrossStreetX + 22, 21, COLORS.Blue)
end

local function buildAbandonedProperty(parent: Instance, index: number, x: number, z: number, side: number)
	local walls = { COLORS.Mint, COLORS.Cream, COLORS.Lilac, COLORS.Peach, COLORS.Blue }
	local wall = walls[(index + (side < 0 and 0 or 2) - 1) % #walls + 1]
	local width, height, y = 42 + (index % 3) * 3, 19 + (index % 2) * 3, C.GroundY
	local model = Instance.new("Model")
	model.Name = string.format("AbandonedProperty_%02d_%s", index, side < 0 and "N" or "S")
	model:SetAttribute("PropertyState", "Available")
	model:SetAttribute("DistrictId", "Main")
	model.Parent = parent
	block(model, "Foundation", Vector3.new(width + 2, 1, 26), x, y + 0.5, z, Color3.fromRGB(142, 143, 136), Enum.Material.Concrete)
	block(model, "Facade", Vector3.new(width, height, 23), x, y + height * 0.5 + 1, z, wall, Enum.Material.Concrete)
	block(model, "FlatRoof", Vector3.new(width + 1.2, 1.1, 24), x, y + height + 1.55, z, COLORS.Dark, Enum.Material.Concrete)
	for _, offset in ipairs({ -width * 0.28, width * 0.28 }) do
		local window = block(model, "BrokenWindow", Vector3.new(width * 0.27, height * 0.34, 0.3), x + offset, y + height * 0.53, z - 11.65, COLORS.Window, Enum.Material.Glass)
		window.Transparency = 0.34
		window.CanCollide = false
		local board = block(model, "WindowBoard", Vector3.new(width * 0.3, 0.22, 0.5), x + offset, y + height * 0.52, z - 11.35, COLORS.Wood, Enum.Material.WoodPlanks)
		board.CanCollide = false
	end
	local door = block(model, "Door", Vector3.new(4, 7, 0.45), x, y + 4.5, z - 11.7, Color3.fromRGB(81, 82, 75), Enum.Material.Wood)
	local sign = block(model, "OldSign", Vector3.new(math.min(width - 4, 20), 2.2, 0.5), x, y + height - 1.5, z - 12, Color3.fromRGB(84, 78, 70), Enum.Material.Wood)
	label(sign, "AVAILABLE PROPERTY", Color3.fromRGB(84, 78, 70), Color3.fromRGB(235, 218, 181), math.min(width - 4, 20), 2.2)
	block(model, "CrackedPlaster", Vector3.new(0.35, 4.2, 0.25), x - width * 0.34, y + height * 0.4, z - 11.9, Color3.fromRGB(104, 98, 87), Enum.Material.Concrete)
	block(model, "PeelingPaint", Vector3.new(3.2, 1.1, 0.2), x + width * 0.32, y + height * 0.34, z - 11.8, Color3.fromRGB(174, 153, 119), Enum.Material.Concrete)
	block(model, "OldAwning", Vector3.new(width * 0.7, 0.5, 3), x, y + 8, z - 13.1, Color3.fromRGB(155, 116, 89), Enum.Material.Fabric)
	for i = -2, 2 do
		local weed = part(model, "Overgrowth", Vector3.new(0.35, 1.2 + (math.abs(i) % 2) * 0.4, 0.35), CFrame.new(x + i * 3.1, y + 0.7, z - 15), COLORS.Leaves[1], Enum.Material.Grass)
		weed.CanCollide = false
	end
	local trash = block(model, "DiscardedCrate", Vector3.new(2.2, 1.3, 1.8), x + width * 0.34, y + 0.65, z - 15, COLORS.Wood, Enum.Material.Wood)
	trash.Orientation = Vector3.new(0, 18, 0)
	model.PrimaryPart = door
end

local function buildServiceShop(parent: Instance, name: string, x: number, z: number, title: string, wall: Color3, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("PublicService", title)
	model.Parent = parent
	local y = C.GroundY
	block(model, "Foundation", Vector3.new(31, 1, 24), x, y + 0.5, z, Color3.fromRGB(178, 178, 166), Enum.Material.Concrete)
	block(model, "ShopBody", Vector3.new(28, 15, 21), x, y + 8.5, z, wall, Enum.Material.Concrete)
	block(model, "Roof", Vector3.new(29, 1.2, 22), x, y + 16.6, z, accent, Enum.Material.Metal)
	local window = block(model, "DisplayWindow", Vector3.new(10, 6, 0.35), x - 7, y + 7, z - 10.7, COLORS.Window, Enum.Material.Glass)
	window.Transparency = 0.2
	window.CanCollide = false
	block(model, "Door", Vector3.new(3.5, 7, 0.5), x + 8, y + 4.5, z - 10.7, COLORS.Wood, Enum.Material.Wood)
	local sign = block(model, "ShopSign", Vector3.new(22, 2.8, 0.5), x, y + 14, z - 11, accent, Enum.Material.SmoothPlastic)
	label(sign, title, accent, Color3.fromRGB(255, 255, 246), 22, 2.8)
	block(model, "Awning", Vector3.new(23, 0.5, 3), x, y + 9, z - 12, accent, Enum.Material.Fabric)
end

local function buildMall(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "Rivermall"
	model:SetAttribute("Landmark", true)
	model:SetAttribute("DistrictId", "Central")
	model.Parent = parent
	local x, z, width, depth, height, y = -380, -70, 92, 54, 32, C.GroundY
	block(model, "Foundation", Vector3.new(width + 6, 2, depth + 6), x, y + 1, z, Color3.fromRGB(172, 175, 165), Enum.Material.Concrete)
	block(model, "MainVolume", Vector3.new(width, height, depth), x, y + 2 + height * 0.5, z, COLORS.Blue, Enum.Material.Concrete)
	block(model, "Roof", Vector3.new(width + 3, 1.5, depth + 3), x, y + height + 3, z, Color3.fromRGB(74, 89, 103), Enum.Material.Metal)
	local glass = block(model, "GlassAtrium", Vector3.new(30, 24, 0.8), x, y + 14, z - depth * 0.5 - 0.5, COLORS.Window, Enum.Material.Glass)
	glass.Transparency = 0.18
	local sign = block(model, "MallSign", Vector3.new(30, 4, 0.8), x, y + height - 3, z - depth * 0.5 - 1, COLORS.Peach, Enum.Material.SmoothPlastic)
	label(sign, "RIVERMALL", COLORS.Peach, Color3.fromRGB(255, 249, 228), 30, 4)
	for i = -3, 3 do
		local frame = block(model, "AtriumFrame", Vector3.new(0.6, 24, 1.1), x + i * 4.5, y + 14, z - depth * 0.5 - 0.2, Color3.fromRGB(239, 236, 222), Enum.Material.Metal)
		frame.CanCollide = false
	end
	block(model, "EntryCanopy", Vector3.new(36, 1.2, 9), x, y + 12, z - depth * 0.5 - 5, Color3.fromRGB(241, 219, 165), Enum.Material.SmoothPlastic)
	for i = -1, 1 do
		local door = block(model, "MallEntranceDoor", Vector3.new(3, 8, 0.35), x + i * 4, y + 5, z - depth * 0.5 - 0.8, COLORS.Window, Enum.Material.Glass)
		door.Transparency = 0.25
		door.CanCollide = false
	end
	block(parent, "MallForecourt", Vector3.new(78, 0.35, 34), x, y + 0.05, z - depth * 0.5 - 28, COLORS.Concrete, Enum.Material.Concrete)
	for i = -5, 5 do
		local mark = block(parent, "MallParkingMark", Vector3.new(0.18, 0.1, 10), x + i * 6.2, y + 0.28, z - depth * 0.5 - 30, Color3.fromRGB(238, 234, 210), Enum.Material.SmoothPlastic)
		mark.CanCollide = false
	end
end

local function buildMainDistrict(parent: Instance)
	local properties = folder(parent, "Properties")
	for index, x in ipairs({ -292, -208, -124, -40, 44, 128, 212, 296, 380 }) do
		for _, side in ipairs({ -1, 1 }) do
			if math.abs(x - C.CrossStreetX) > 55 then
				buildAbandonedProperty(properties, index, x, side * 70, side)
			end
		end
	end
	local mall = folder(parent, "Landmarks")
	buildMall(mall)
end

local function buildCrossroadServices(parent: Instance)
	local shops = folder(parent, "Shops")
	buildServiceShop(shops, "SupplyShop", C.CrossStreetX - 37, -47, "SUPPLY SHOP", COLORS.Mint, Color3.fromRGB(26, 151, 134))
	buildServiceShop(shops, "AdAgency", C.CrossStreetX + 37, 47, "AD AGENCY", COLORS.Lilac, Color3.fromRGB(129, 96, 170))
end

local function buildPlots(parent: Instance)
	local plots = folder(parent, "PlayerPlots")
	for row = 1, 2 do
		local north = row == 1
		local z = north and -55 or 55
		for i = 1, C.PlotsPerSide do
			local x = (i - (C.PlotsPerSide + 1) * 0.5) * C.PlotSpacing
			local index = (row - 1) * C.PlotsPerSide + i
			local plot = folder(plots, string.format("Plot_%02d", index))
			plot:SetAttribute("PlotIndex", index)
			plot:SetAttribute("OwnerUserId", 0)
			local origin = CFrame.new(x, C.GroundY, z) * (north and CFrame.new() or CFrame.Angles(0, math.pi, 0))
			plot:SetAttribute("Origin", origin)
			local lot = Instance.new("Model")
			lot.Name = "Lot"
			lot.Parent = plot
			local center = origin.Position
			local drive = (origin * CFrame.new(0, 0, 32)).Position
			local ground = part(lot, "PlotGround", Vector3.new(100, 0.18, 64), CFrame.new(center.X, C.GroundY + 0.05, center.Z), COLORS.Grass, Enum.Material.Grass)
			lot.PrimaryPart = ground
			part(lot, "Driveway", Vector3.new(25, 0.2, 13), CFrame.new(drive.X, C.GroundY + 0.16, drive.Z) * origin.Rotation, Color3.fromRGB(179, 181, 170), Enum.Material.Concrete)
			for _, dx in ipairs({ -49, 49 }) do
				for _, dz in ipairs({ -31, 31 }) do
					local point = (origin * CFrame.new(dx, 0, dz)).Position
					local marker = part(lot, "BoundaryMarker", Vector3.new(0.65, 1.2, 0.65), CFrame.new(point.X, C.GroundY + 0.7, point.Z), Color3.fromRGB(206, 194, 154), Enum.Material.Wood)
					marker.CanCollide = false
				end
			end
		end
	end
end

local function buildRoadsideDetails(parent: Instance)
	for _, x in ipairs({ -236, -68, 108, 284 }) do
		for _, side in ipairs({ -1, 1 }) do
			block(parent, "UtilityCabinet", Vector3.new(2.2, 3, 1.5), x, C.GroundY + 1.7, side * 29, Color3.fromRGB(111, 133, 126), Enum.Material.Metal)
			for offset = -1, 1 do
				local bollard = block(parent, "Bollard", Vector3.new(0.65, 2, 0.65), x + offset * 2, C.GroundY + 1, side * 18.5, Color3.fromRGB(238, 199, 114), Enum.Material.Metal)
				bollard.CanCollide = false
			end
		end
	end
	for _, entry in ipairs({ { -154, -31 }, { 206, 31 }, { 370, -31 } }) do
		local board = block(parent, "AdBoard", Vector3.new(8, 5, 0.6), entry[1], C.GroundY + 3.3, entry[2], COLORS.Peach, Enum.Material.SmoothPlastic)
		label(board, "LOCAL\nBUSINESS", COLORS.Peach, Color3.fromRGB(255, 255, 245), 8, 5)
		local post = block(parent, "AdPost", Vector3.new(0.5, 3, 0.5), entry[1], C.GroundY + 1.5, entry[2] + (entry[2] < 0 and 0.5 or -0.5), COLORS.Dark, Enum.Material.Metal)
		post.CanCollide = false
	end
end

local function stage(parent: Instance, name: string): Folder
	local folderResult = Instance.new("Folder")
	folderResult.Name = name
	folderResult.Parent = parent
	return folderResult
end

function WorldBuilder.Build(worldParent: Instance?): Folder
	local world = worldParent or workspace
	local root = folder(world, C.WorldName)
	local city = folder(root, C.CityName)
	local generated = city:FindFirstChild("Generated")
	if generated and generated:GetAttribute("BuiltByWorldBuilder") == true then
		folder(root, "ActiveNPCs")
		folder(root, "ActiveVehicles")
		folder(root, "WorldEvents")
		return root
	end
	-- Construct an isolated staging generation and only swap after all parts are built.
	local oldStaging = city:FindFirstChild("Generated_Staging")
	if oldStaging then oldStaging:Destroy() end
	local staging = Instance.new("Folder")
	staging.Name = "Generated_Staging"
	staging.Parent = city
	local ok, buildError = pcall(function()
		local worldFolder = stage(staging, "World")
		buildRoad(stage(worldFolder, "Roads"))
		buildStreetFurniture(stage(worldFolder, "StreetFurniture"))
		buildRoadsideDetails(stage(worldFolder, "RoadsideDetails"))
		buildMainDistrict(stage(worldFolder, "MainDistrict"))
		buildCrossroadServices(stage(worldFolder, "PublicServices"))
		buildPlots(stage(worldFolder, "PlayerPlots"))
	end)
	if not ok then
		staging:Destroy()
		error("WorldBuilder.Build failed without replacing existing city: " .. tostring(buildError))
	end

	local oldGenerated = city:FindFirstChild("Generated")
	if oldGenerated then oldGenerated:Destroy() end
	staging.Name = "Generated"
	staging:SetAttribute("BuiltByWorldBuilder", true)
	folder(root, "ActiveNPCs")
	folder(root, "ActiveVehicles")
	folder(root, "WorldEvents")
	return root
end

return WorldBuilder
