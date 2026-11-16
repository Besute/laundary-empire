-- OrderConfig: order states, transitions, generation, patience and payment parameters.
local O = {}

O.States = { "Offered", "Accepted", "WaitingForWash", "Washing", "WaitingForDryer", "Drying", "Finishing", "ReadyForPickup", "Completed", "Failed", "Cancelled" }
-- Allowed transitions (OrderService is the only writer). You can never jump Offered -> Completed.
-- Processing states (Accepted .. Finishing) may move freely between each other (batches can regress/advance).
O.ProcessingStates = { Accepted = true, WaitingForWash = true, Washing = true, WaitingForDryer = true, Drying = true, Finishing = true }
O.Transitions = {
	Offered = { Accepted = true, Cancelled = true },
	Accepted = { WaitingForWash = true, Failed = true },
	WaitingForWash = { Washing = true, Failed = true },
	Washing = { WaitingForWash = true, WaitingForDryer = true, Drying = true, Failed = true },
	WaitingForDryer = { Drying = true, Washing = true, WaitingForWash = true, Failed = true },
	Drying = { WaitingForDryer = true, Finishing = true, Washing = true, WaitingForWash = true, Failed = true },
	Finishing = { ReadyForPickup = true, Drying = true, WaitingForDryer = true, Washing = true, WaitingForWash = true, Failed = true },
	ReadyForPickup = { Completed = true, Failed = true },
	Completed = {},
	Failed = {},
	Cancelled = {},
}
function O.canTransition(from, to)
	if from == to then return true end
	local t = O.Transitions[from]
	return t ~= nil and t[to] == true
end

-- States that count toward UnfinishedUnits (accepted, not yet handed over)
O.UnfinishedStates = { Accepted = true, WaitingForWash = true, Washing = true, WaitingForDryer = true, Drying = true, Finishing = true, ReadyForPickup = true }

O.DeclineReasons = { "Busy", "NoCapacity", "Unsupported", "Other" }

-- Generation (OrderService.createOffer). Total Units is capped by the plot's largest single machine
-- only loosely: orders can be split across several loads.
O.Generate = {
	UnitsMin = 3,
	UnitsMaxByLevel = { { Level = 1, Max = 7 }, { Level = 5, Max = 10 }, { Level = 10, Max = 14 }, { Level = 20, Max = 20 } },
	TypesMin = 1,
	TypesMax = 3,
	SoilWeights = { Light = 0.35, Medium = 0.45, Heavy = 0.20 },
	ExtraRequirementChance = 0.15, -- chance of an extra "requirement" tag e.g. "NoBleach"
}

O.Patience = {
	Queue = 90, -- seconds a customer waits in line before leaving
	Offer = 60, -- seconds an offer may stay unanswered at the counter before the customer leaves (Cancelled)
	Pickup = 45, -- extra seconds a returned customer waits for an unfinished order
	ReturnFactor = 1.25, -- CustomerReturnAt = now + estimate * factor + slack
	ReturnSlack = 20,
	RetryDelay = 40, -- if the customer left angry, comes back this much later
	MaxReturnAttempts = 2, -- after this the order becomes Failed (never silently lost)
	MoodThresholds = { Calm = 0.66, Worried = 0.33, Annoyed = 0.12 }, -- remaining-patience fractions
}

-- Extra seconds added to the estimate per unit of laundry
O.Estimate = { Base = 70, PerUnit = 12 }

O.Pay = {
	ServiceMult = 1.0,
	RushBonus = 0.10, -- quick return within 60% of estimate
	Review = { PositiveQuality = 0.80, NegativeQuality = 0.50 },
}

O.CustomerTypes = {
	Walker = { Weight = 1.0 },
	Driver = { Weight = 0.0 }, -- dynamically set by ParkingService availability (see NPCConfig.DriverShare)
}

function O.maxUnitsForLevel(level)
	local best = O.Generate.UnitsMaxByLevel[1].Max
	for _, e in ipairs(O.Generate.UnitsMaxByLevel) do
		if level >= e.Level then best = e.Max end
	end
	return best
end

return O
