-- GameConfig: global switches and constants. Balance numbers live in EconomyConfig & friends.
local GameConfig = {}

GameConfig.Name = "Laundry Empire"
GameConfig.Version = "1.0.0"
GameConfig.SchemaVersion = 1

-- Late systems are isolated: each service is initialised under pcall and checks its flag.
GameConfig.Features = {
	DayNight = true,
	Advertising = true,
	Security = true,
	Traffic = true,
	Parking = true,
	Property = true,
	Employees = true,
	Wear = true,
	AmbientPedestrians = true,
	Gems = false, -- Gems HUD/shop stay hidden until monetisation is configured
}

GameConfig.DataStore = {
	Name = "LaundryEmpire_PlayerData_v1",
	AutosaveInterval = 90, -- seconds
	LockTimeout = 180, -- another server's session lock older than this is considered stale
	LoadRetries = 6,
	SaveRetries = 4,
	RetryBackoff = 1.5, -- seconds, multiplied per attempt
	StudioFallback = true, -- if DataStores are unavailable (Studio w/o API access) use in-memory data and warn
	LedgerSize = 80,
	ProcessedTxSize = 200,
	RequestIdMemory = 60, -- per-player remembered requestIds (duplicate-request protection)
}

GameConfig.Day = {
	RealSecondsPerDay = 2100, -- 35 real minutes = 24 game hours
	StartHour = 6, -- a new game day begins (and daily settlement runs) at 06:00
	InitialHour = 8, -- server boots at 08:00 of day 1
}

-- Periods from the GDD (hour ranges, end exclusive; Night wraps midnight)
GameConfig.Periods = {
	{ Name = "Morning", From = 6, To = 9 },
	{ Name = "Day", From = 9, To = 15 },
	{ Name = "Evening", From = 15, To = 19 },
	{ Name = "Late", From = 19, To = 22 },
	{ Name = "Night", From = 22, To = 26 }, -- 22:00-02:00
	{ Name = "Low", From = 2, To = 6 }, -- 02:00-06:00
}

GameConfig.Interaction = {
	Range = 14, -- studs: max distance between character and machine/counter/dirt for an action
	ShopRange = 16,
	BuildRange = 140, -- studs from plot centre for build requests
	PromptDistance = 9,
}

GameConfig.Limits = {
	NameMin = 3,
	NameMax = 24,
	MaxMachinesPerPlot = 16,
	MaxPlacedObjects = 120,
	MaxEmployees = 8,
	MaxActiveOrders = 24,
	MaxLightsPerPlot = 8,
}

-- Token bucket per remote: {rate = tokens/sec, burst = bucket size}. Remotes.lua may override per remote.
GameConfig.RateLimit = { rate = 6, burst = 12 }

GameConfig.Sounds = {
	-- Built-in client sounds (no marketplace dependency). Replace with your own asset ids if desired.
	Click = "rbxasset://sounds/clickfast.wav",
	Success = "rbxasset://sounds/electronicpingshort.wav",
	Error = "rbxasset://sounds/button-3.mp3",
	Coin = "rbxasset://sounds/electronicpingshort.wav",
}

GameConfig.Facades = { "Modern", "Classic", "Colorful" }

GameConfig.World = {
	FolderName = "LaundryWorld",
	PlotsPerSide = 5, -- 10 plots total. Increase after a load test.
	PlotSpacing = 104,
	RoadHalfWidth = 15,
	SidewalkWidth = 8,
	LotWidth = 100,
	LotDepth = 64,
}

return GameConfig
