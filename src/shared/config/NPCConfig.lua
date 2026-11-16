-- NPCConfig: customers, queue, spawn flow, ChoiceScore weights, dirt generation (GDD §5, §7, §11).
local N = {}

N.Caps = { Global = 40, PerPlot = 7, Ambient = 10, Cars = 8 } -- hard limits for active NPC models / vehicles

-- GDD §7 customer states
N.States = {
	"Spawned", "Walking", "Browsing", "Interested", "ApproachingBusiness", "Entering", "JoiningQueue", "Waiting", "Impatient", "Leaving",
	"OrderAccepted", "AwayWithOrder", "Returning", "WaitingForPickup", "Satisfied", "Dissatisfied", "Completed", "Despawned",
}
N.Moods = { "Calm", "Worried", "Annoyed", "Leaving" }

-- ChoiceScore = sum(weight * component[0..1]) - DistancePenalty (GDD §7). Weights are normalised.
N.ChoiceWeights = { Attractiveness = 0.25, Reputation = 0.25, Advertising = 0.15, Accessibility = 0.15, Cleanliness = 0.10, Parking = 0.10 }
N.DistancePenaltyPerSlot = 0.0 -- plots are equidistant in MVP
N.Flow = {
	BaseInterval = 24, -- seconds between customer spawns for a business with FlowMultiplier = 1
	MinInterval = 7,
	FlowMin = 0.5, -- FlowMultiplier = FlowMin + (FlowMax-FlowMin) * ChoiceScore
	FlowMax = 2.2,
	PeriodFlow = { Morning = 1.2, Day = 1.0, Evening = 1.3, Late = 0.7, Night = 0.25, Low = 0.1 },
	FirstCustomerDelay = 6, -- first customer arrives quickly after opening (GDD target feeling)
	StartQueueTarget = 2, -- ensure 2 customers early on
}
N.DriverShare = 0.35 -- chance a customer arrives by car when a free parking spot exists

N.Queue = { Limit = 6, SlotSpacing = 3.2, ServicePointMax = 3 }
N.Speeds = { Walk = 11, Run = 14, Car = 16 }
N.StuckTimeout = 8 -- seconds without progress -> repath / teleport fallback
N.ArriveRadius = 3.0

N.Appearance = {
	Skin = { Color3.fromRGB(255, 219, 172), Color3.fromRGB(241, 194, 125), Color3.fromRGB(198, 134, 66), Color3.fromRGB(141, 85, 36), Color3.fromRGB(224, 172, 105), Color3.fromRGB(255, 205, 148) },
	Shirt = { Color3.fromRGB(235, 90, 90), Color3.fromRGB(90, 160, 235), Color3.fromRGB(110, 200, 130), Color3.fromRGB(245, 200, 70), Color3.fromRGB(170, 110, 220), Color3.fromRGB(240, 140, 60), Color3.fromRGB(240, 240, 240), Color3.fromRGB(60, 60, 70) },
	Pants = { Color3.fromRGB(50, 60, 90), Color3.fromRGB(80, 80, 85), Color3.fromRGB(110, 90, 70), Color3.fromRGB(40, 40, 45), Color3.fromRGB(60, 100, 120) },
	Hair = { Color3.fromRGB(40, 28, 20), Color3.fromRGB(90, 60, 30), Color3.fromRGB(200, 160, 80), Color3.fromRGB(30, 30, 30), Color3.fromRGB(150, 70, 40), Color3.fromRGB(220, 220, 225) },
	HairStyles = { "Short", "Cap", "Long", "Bun", "None" },
	Names = { "Alex", "Sam", "Mia", "Leo", "Nina", "Max", "Zoe", "Ivan", "Kate", "Omar", "Lena", "Tom", "Ruby", "Dan", "Eva", "Ben", "Ava", "Noah", "Liam", "Emma", "Olga", "Igor", "Anya", "Pavel" },
}

-- Litter left by customers (event-driven, never per-frame). Tool = best tool that cleans it fast; any owned tool works.
N.Dirt = {
	Types = {
		Paper = { Weight = 3, Tool = "Broom", Trash = true },
		Cup = { Weight = 2, Tool = "Broom", Trash = true },
		Wrapper = { Weight = 3, Tool = "Broom", Trash = true },
		Footprints = { Weight = 2, Tool = "Mop", Trash = false },
		Stain = { Weight = 1, Tool = "Mop", Trash = false },
	},
	PerVisitChance = 0.45, -- chance a leaving customer drops litter
	BinCatchChance = 0.55, -- chance a Trash type goes into a bin instead (if a bin with room exists)
	MaxPerPlot = 24,
	InitialPieces = 10, -- the abandoned shop starts dirty
}

return N
