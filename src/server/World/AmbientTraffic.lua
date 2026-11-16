-- Centralized, bounded ambient NPC and vehicle presentation for the city block.
-- NPCs are built from simple anchored Parts; cars follow a deterministic anchored route.
local AmbientTraffic = {}
local CityReferences = require(script.Parent:WaitForChild("CityReferences"))

local CONFIG = CityReferences.Traffic
local rng = Random.new()
local running = false
local activeFolder: Folder? = nil
local activeVehicles: Folder? = nil
local activePedestrians: Folder? = nil
local spawnElapsed = 0
local spawnCountdown = 0
local heartbeatConnection: RBXScriptConnection? = nil
local vehicleCursor = 0
local pedestrianCursor = 0
local cars = {}
local walkers = {}

local SKIN_TONES = {
	Color3.fromRGB(255, 219, 172), Color3.fromRGB(241, 194, 125),
	Color3.fromRGB(198, 134, 66), Color3.fromRGB(141, 85, 36),
}
local SHIRT_COLORS = {
	Color3.fromRGB(235, 90, 90), Color3.fromRGB(90, 160, 235),
	Color3.fromRGB(110, 200, 130), Color3.fromRGB(245, 200, 70),
	Color3.fromRGB(170, 110, 220), Color3.fromRGB(240, 140, 60),
}
local PANTS_COLORS = {
	Color3.fromRGB(50, 60, 90), Color3.fromRGB(80, 80, 85),
	Color3.fromRGB(110, 90, 70), Color3.fromRGB(40, 40, 45),
}
local HAIR_COLORS = {
	Color3.fromRGB(40, 28, 20), Color3.fromRGB(90, 60, 30),
	Color3.fromRGB(200, 160, 80), Color3.fromRGB(30, 30, 30),
}

local function makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function rigBlock(parent: Instance, name: string, size: Vector3, root: CFrame, offset: CFrame, color: Color3): Part
	return makePart(parent, name, size, root * offset, color)
end

local function createPedestrian(parent: Instance, position: Vector3, index: number): Model
	local model = Instance.new("Model")
	model.Name = string.format("AmbientPedestrian_%02d", index)
	model:SetAttribute("LE_NPC", true)
	model:SetAttribute("Kind", "Ambient")
	model:SetAttribute("Mood", "Calm")
	model.Parent = parent
	local root = CFrame.new(position + Vector3.new(0, 0.1, 0))
	local skin = SKIN_TONES[rng:NextInteger(1, #SKIN_TONES)]
	local shirt = SHIRT_COLORS[rng:NextInteger(1, #SHIRT_COLORS)]
	local pants = PANTS_COLORS[rng:NextInteger(1, #PANTS_COLORS)]
	local hair = HAIR_COLORS[rng:NextInteger(1, #HAIR_COLORS)]
	local torso = rigBlock(model, "Torso", Vector3.new(1.5, 1.8, 0.8), root, CFrame.new(0, 2.85, 0), shirt)
	local head = rigBlock(model, "Head", Vector3.new(1.05, 1.05, 1.05), root, CFrame.new(0, 4.3, 0), skin)
	local hairPart = rigBlock(model, "Hair", Vector3.new(1.1, 0.42, 1.1), root, CFrame.new(0, 4.95, 0), hair)
	local leftArm = rigBlock(model, "LeftArm", Vector3.new(0.55, 1.7, 0.65), root, CFrame.new(-1.05, 2.85, 0), skin)
	local rightArm = rigBlock(model, "RightArm", Vector3.new(0.55, 1.7, 0.65), root, CFrame.new(1.05, 2.85, 0), skin)
	local leftLeg = rigBlock(model, "LeftLeg", Vector3.new(0.62, 1.8, 0.7), root, CFrame.new(-0.4, 1.05, 0), pants)
	local rightLeg = rigBlock(model, "RightLeg", Vector3.new(0.62, 1.8, 0.7), root, CFrame.new(0.4, 1.05, 0), pants)
	model.PrimaryPart = torso
	-- Small clothing/accessory variation without asset IDs or scripts.
	if index % 4 == 0 then
		local bag = rigBlock(model, "ShoulderBag", Vector3.new(0.65, 0.85, 0.35), root, CFrame.new(0.86, 2.65, 0.38), Color3.fromRGB(128, 96, 72))
		bag.CanCollide = false
	end
	if index % 3 == 0 then
		local hat = rigBlock(model, "Cap", Vector3.new(1.15, 0.22, 1.15), root, CFrame.new(0, 4.88, 0), Color3.fromRGB(54, 89, 124))
		hat.CanCollide = false
		hairPart.Transparency = 1
	end
	for _, limb in ipairs({ head, hairPart, leftArm, rightArm, leftLeg, rightLeg }) do limb.CanCollide = false end
	torso.CanCollide = false
	return model
end

local function createCar(parent: Instance, index: number): Model
	local model = Instance.new("Model")
	model.Name = string.format("AmbientCar_%02d", index)
	model:SetAttribute("Kind", "AmbientVehicle")
	model.Parent = parent
	local paint = CONFIG.VehicleColors[rng:NextInteger(1, #CONFIG.VehicleColors)]
	local body = makePart(model, "Body", Vector3.new(8, 2.1, 15), CFrame.new(), paint, Enum.Material.SmoothPlastic)
	local cabin = makePart(model, "Cabin", Vector3.new(6.2, 2.1, 7), CFrame.new(0, 1.85, -0.4), Color3.fromRGB(125, 178, 196), Enum.Material.Glass)
	cabin.Transparency = 0.22
	makePart(model, "Roof", Vector3.new(5.6, 0.25, 5.8), CFrame.new(0, 2.95, -0.2), paint)
	local windshield = makePart(model, "Windshield", Vector3.new(5.6, 1.45, 0.16), CFrame.new(0, 1.9, -3.95), Color3.fromRGB(179, 220, 229), Enum.Material.Glass)
	windshield.Transparency = 0.3
	local rearGlass = makePart(model, "RearWindow", Vector3.new(5.6, 1.35, 0.16), CFrame.new(0, 1.9, 3.2), Color3.fromRGB(179, 220, 229), Enum.Material.Glass)
	rearGlass.Transparency = 0.35
	for _, x in ipairs({ -3.1, 3.1 }) do
		for _, z in ipairs({ -4.7, 4.7 }) do
			local wheel = makePart(model, "Wheel", Vector3.new(1.15, 1.15, 0.7), CFrame.new(x, -0.55, z), Color3.fromRGB(37, 39, 42), Enum.Material.Rubber, Enum.PartType.Cylinder)
			wheel.Orientation = Vector3.new(0, 0, 90)
		end
	end
	for _, x in ipairs({ -2.8, 2.8 }) do
		local headlight = makePart(model, "Headlight", Vector3.new(1.3, 0.45, 0.15), CFrame.new(x, 0.35, -7.55), Color3.fromRGB(255, 241, 194), Enum.Material.Neon)
		local taillight = makePart(model, "Taillight", Vector3.new(1.2, 0.4, 0.15), CFrame.new(x, 0.35, 7.55), Color3.fromRGB(191, 63, 60), Enum.Material.Neon)
		headlight.CanCollide = false
		taillight.CanCollide = false
	end
	model.PrimaryPart = body
	return model
end

local function carRoute(): { CFrame }
	local eastboundZ = CONFIG.RouteLanes.EastboundZ
	local westboundZ = CONFIG.RouteLanes.WestboundZ
	local startX = CONFIG.RouteLanes.RoadStartX
	local endX = CONFIG.RouteLanes.RoadEndX
	-- Two continuous parallel loops; the cross street is pedestrian/public-service access only.
	return {
		CFrame.new(startX, 1.25, eastboundZ), CFrame.new(endX, 1.25, eastboundZ),
		CFrame.new(endX, 1.25, westboundZ), CFrame.new(startX, 1.25, westboundZ),
	}
end

local function placeModel(model: Model, cf: CFrame)
	if model.PrimaryPart then
		model:PivotTo(cf)
	end
end

local function moveCars(dt: number)
	local route = carRoute()
	for i = #cars, 1, -1 do
		local entry = cars[i]
		if not entry.Model.Parent then
			table.remove(cars, i)
		else
			entry.Distance += CONFIG.RouteSpeed * dt
			local segment = entry.Segment
			local a, b = route[segment], route[segment % #route + 1]
			local length = (b.Position - a.Position).Magnitude
			if length > 0 then
				while entry.Distance >= length do
					entry.Distance -= length
					entry.Segment = entry.Segment % #route + 1
					segment = entry.Segment
					a, b = route[segment], route[segment % #route + 1]
					length = (b.Position - a.Position).Magnitude
					if length <= 0 then break end
				end
				local alpha = math.clamp(entry.Distance / length, 0, 1)
				local position = a.Position:Lerp(b.Position, alpha)
				local direction = (b.Position - a.Position).Unit
				local orientation = CFrame.lookAt(position, position + direction)
				placeModel(entry.Model, orientation)
			end
		end
	end
end

local function moveWalkers(dt: number)
	for i = #walkers, 1, -1 do
		local entry = walkers[i]
		if not entry.Model.Parent then
			table.remove(walkers, i)
		else
			entry.Distance += CONFIG.RouteSpeed * 0.46 * dt
			local target = entry.Points[entry.Next]
			local delta = target - entry.Position
			local distance = delta.Magnitude
			if distance <= entry.Distance + 0.05 then
				entry.Position = target
				entry.Distance = 0
				entry.Next = entry.Next % #entry.Points + 1
				if entry.Next == 1 then
					entry.Direction = -entry.Direction
					entry.Points[2] = Vector3.new(entry.Direction > 0 and 325 or -325, entry.Position.Y, entry.Position.Z)
				end
			else
				local step = entry.Distance
				entry.Position = entry.Position + delta.Unit * step
				entry.Distance = 0
			end
			local facing = entry.Points[entry.Next] - entry.Position
			if facing.Magnitude > 0.01 then
				placeModel(entry.Model, CFrame.lookAt(entry.Position, entry.Position + facing.Unit))
			end
		end
	end
end

local function spawnCar()
	if not activeVehicles or #cars >= math.min(CONFIG.CarLimit, 8) then return end
	vehicleCursor += 1
	local car = createCar(activeVehicles, vehicleCursor)
	local route = carRoute()
	local segment = rng:NextInteger(1, #route)
	local start = route[segment]
	placeModel(car, start)
	table.insert(cars, { Model = car, Segment = segment, Distance = 0 })
end

local function spawnPedestrian()
	if not activePedestrians or #walkers >= math.min(CONFIG.PedestrianLimit, 10) then return end
	pedestrianCursor += 1
	local side = rng:NextInteger(1, 2)
	local z = CONFIG.PedestrianSidewalkZ[side]
	local x = rng:NextInteger(-300, 300)
	local direction = rng:NextInteger(1, 2) == 1 and 1 or -1
	local destinationX = direction > 0 and 325 or -325
	local start = Vector3.new(x, 0.1, z)
	local points = { start, Vector3.new(destinationX, 0.1, z) }
	local model = createPedestrian(activePedestrians, start, pedestrianCursor)
	table.insert(walkers, { Model = model, Position = start, Points = points, Next = 2, Distance = 0, Direction = direction })
end

function AmbientTraffic.Start(worldRoot: Instance?)
	if running then return end
	local root = worldRoot or workspace:FindFirstChild("LaundryWorld")
	if not root then
		warn("[LaundryEmpire] AmbientTraffic.Start skipped: LaundryWorld is not available")
		return
	end
	activeFolder = root:FindFirstChild("City")
	if activeFolder then
		local generated = activeFolder:FindFirstChild("Generated")
		local worldFolder = generated and generated:FindFirstChild("World")
		activeVehicles = root:FindFirstChild("ActiveVehicles") :: Folder?
		activePedestrians = root:FindFirstChild("ActiveNPCs") :: Folder?
		if not worldFolder or not activeVehicles or not activePedestrians then
			warn("[LaundryEmpire] AmbientTraffic.Start skipped: required generated folders missing")
			return
		end
	else
		warn("[LaundryEmpire] AmbientTraffic.Start skipped: city folder missing")
		return
	end
	running = true
	spawnElapsed = 0
	spawnCountdown = rng:NextNumber(CONFIG.SpawnInterval.Min, CONFIG.SpawnInterval.Max)
	for i = 1, 3 do spawnCar() end
	for i = 1, 4 do spawnPedestrian() end
	heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not running then return end
		local step = math.min(dt, 0.1)
		spawnElapsed += step
		moveCars(step)
		moveWalkers(step)
		if spawnElapsed >= spawnCountdown then
			spawnElapsed = 0
			spawnCountdown = rng:NextNumber(CONFIG.SpawnInterval.Min, CONFIG.SpawnInterval.Max)
			spawnCar()
			spawnPedestrian()
		end
	end)
end

function AmbientTraffic.Stop()
	running = false
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
	for _, entry in ipairs(cars) do if entry.Model.Parent then entry.Model:Destroy() end end
	for _, entry in ipairs(walkers) do if entry.Model.Parent then entry.Model:Destroy() end end
	table.clear(cars)
	table.clear(walkers)
	activeFolder, activeVehicles, activePedestrians = nil, nil, nil
end

return AmbientTraffic
