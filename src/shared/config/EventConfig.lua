-- EventConfig: security (thieves/police) and traffic. Thieves never cause irreversible loss (GDD §16).
local Ev = {}

Ev.Security = {
	MinLevel = 5, -- no thieves before this level
	RollInterval = 75, -- seconds between thief rolls per online business
	ChanceByPeriod = { Night = 0.30, Low = 0.15, Late = 0.05 }, -- other periods: 0
	CooldownSeconds = 420, -- per player after an event
	StealShare = 0.06, -- of current Cash
	StealMin = 40,
	StealMax = 350,
	DamageCondition = 25, -- condition points lost by one machine if the thief vandalises
	VandalChance = 0.35, -- chance a thief vandalises instead of stealing
	BreakInSeconds = 6,
	ApproachSpeed = 12,
	EscapeSeconds = 14, -- time before the thief gets away once the theft is done
	DetectedEscapeSeconds = 9,
	CaptureHoldSeconds = 2.0,
	CaptureRange = 12,
	PoliceArriveSeconds = 16,
	-- Protection (aggregated by SecurityService)
	Protection = {
		Camera = { DetectChance = 0.35, Max = 0.8 }, -- each camera adds, capped
		Alarm = { DetectChance = 1.0, BreakInExtra = 2 },
		Register_Secure = { StealMult = 0.25 },
		DoorLock_1 = { BreakInExtra = 3 },
		DoorLock_2 = { BreakInExtra = 5 },
		Guard = { DetectChance = 1.0, CatchChance = 0.85 },
	},
	States = { "Spawned", "Approaching", "BreakingIn", "Stealing", "Destroying", "Detected", "Escaping", "Captured", "PoliceCalled", "Arrested", "Despawned" },
}

Ev.Traffic = {
	AmbientCarInterval = 9,
	CarSpeed = 18,
	LaneOffset = 7, -- lane centre distance from road centre line
	CarColors = { Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 120, 220), Color3.fromRGB(240, 220, 90), Color3.fromRGB(240, 240, 240), Color3.fromRGB(40, 40, 45), Color3.fromRGB(80, 180, 120) },
	ParkSeconds = 2.5, -- seconds a car takes to settle into its spot
	ParkingSpotStates = { "Free", "Reserved", "Occupied", "Leaving", "Disabled" },
}

return Ev
