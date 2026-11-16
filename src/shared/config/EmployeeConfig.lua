-- EmployeeConfig: roles unlock gradually (GDD GRADUAL). Each role automates exactly one operation.
local Emp = {}

Emp.Roles = {
	Cashier = { Level = 3, Wage = 90, Color = Color3.fromRGB(80, 160, 220), TaskSeconds = 3 }, -- serve queue front: accept/decline, deliver ready orders
	Cleaner = { Level = 4, Wage = 70, Color = Color3.fromRGB(120, 200, 140), TaskSeconds = 4 }, -- clean dirt, empty bins
	Washer = { Level = 5, Wage = 100, Color = Color3.fromRGB(100, 120, 230), TaskSeconds = 4 }, -- load basket items into washers & start
	Dryer = { Level = 6, Wage = 100, Color = Color3.fromRGB(230, 150, 90), TaskSeconds = 4 }, -- transfer washed items to dryers & start
	Packer = { Level = 7, Wage = 90, Color = Color3.fromRGB(200, 120, 200), TaskSeconds = 4 }, -- pack finished orders
	Mechanic = { Level = 8, Wage = 130, Color = Color3.fromRGB(220, 200, 80), TaskSeconds = 6 }, -- maintenance/repair
	SecurityGuard = { Level = 10, Wage = 140, Color = Color3.fromRGB(60, 60, 70), TaskSeconds = 3 }, -- catches thieves
	Manager = { Level = 20, Wage = 220, Color = Color3.fromRGB(240, 200, 60), TaskSeconds = 5, Reserved = true }, -- reserved for post-MVP (hireable, no automation yet)
}
Emp.RoleOrder = { "Cashier", "Cleaner", "Washer", "Dryer", "Packer", "Mechanic", "SecurityGuard", "Manager" }

Emp.Zones = { "Auto", "Front", "Laundry", "Floor", "Back" }

Emp.Candidate = {
	PoolSize = 4, -- candidates offered per role refresh
	SpeedMin = 0.8,
	SpeedMax = 1.4,
	WageSpeedFactor = 0.6, -- wage = Wage * (1 + (speed-1)*factor)
	SigningFeeDays = 1, -- hire cost = wage * SigningFeeDays
	RefreshSeconds = 300,
	Names = { "Alex", "Sam", "Mia", "Leo", "Nina", "Max", "Zoe", "Ivan", "Kate", "Omar", "Lena", "Tom", "Ruby", "Dan", "Eva", "Ben" },
}

Emp.Levels = { MaxLevel = 5, XPPerTask = 1, XPPerLevel = { 20, 50, 100, 180 }, SpeedPerLevel = 0.05 }

Emp.Status = { "Available", "Working", "MovingToTask", "PerformingTask", "Waiting", "OnBreak", "Disabled", "Fired" }

function Emp.slotsForLevel(level)
	return math.min(8, 1 + math.floor(level / 3))
end

return Emp
