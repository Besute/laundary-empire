-- MachineConfig: states, wash/dry modes, quality tables, wear.
local M = {}

M.States = { "Idle", "Loading", "ReadyToStart", "Washing", "Drying", "CycleComplete", "Unloading", "NeedsMaintenance", "Broken", "Repairing", "Disabled" }
-- NeedsMaintenance is shown when the machine is otherwise idle and wear >= WearWarn (still usable, treated as Idle).
-- Broken: load and order data are PRESERVED. Items can be moved out via RequestTransferItems.

M.MachineTypes = { "Washer", "Dryer", "Rack" } -- Rack = drying rack (type compatible with Dryer operations)

M.LoadSeconds = 1.0 -- transient "Loading" lock after each load
M.UnloadSeconds = 1.0 -- transient "Unloading" lock after transfer/pack

M.WearWarn = 70
M.WearMax = 100
M.BreakChanceBase = 0.02 -- per cycle start once wear >= WearWarn, scaled by (wear-WearWarn)/10
M.WearAfterMaintenance = 5
M.WearAfterRepair = 20

-- Cycle base seconds at CycleMult 1.0 and mode Normal
M.BaseSeconds = { Washer = 40, Dryer = 36, Rack = 70 }

-- Modes: Time multiplier, base cleaning/drying quality factor, wear per cycle, power (soil removing ability)
M.WashModes = {
	Quick = { Time = 0.6, Quality = 0.88, Wear = 3, Power = 0.55 },
	Normal = { Time = 1.0, Quality = 1.0, Wear = 4, Power = 0.75 },
	Delicate = { Time = 1.3, Quality = 1.0, Wear = 3, Power = 0.55 },
	Intensive = { Time = 1.4, Quality = 1.05, Wear = 7, Power = 1.0 },
}
M.DryModes = {
	Quick = { Time = 0.6, Quality = 0.88, Wear = 3 },
	Normal = { Time = 1.0, Quality = 1.0, Wear = 4 },
	Delicate = { Time = 1.4, Quality = 1.0, Wear = 2 },
}
M.ModeOrder = { "Quick", "Normal", "Delicate", "Intensive" }

-- Fit of mode for fabric (multiplier on quality)
M.ModeFit = {
	Normal = { Quick = 0.88, Normal = 1.0, Delicate = 0.92, Intensive = 0.9 },
	Heavy = { Quick = 0.7, Normal = 0.9, Delicate = 0.6, Intensive = 1.0 },
	Delicate = { Quick = 0.6, Normal = 0.75, Delicate = 1.0, Intensive = 0.35 },
}
M.DryFit = {
	Normal = { Quick = 0.9, Normal = 1.0, Delicate = 0.95 },
	Heavy = { Quick = 0.8, Normal = 1.0, Delicate = 0.8 },
	Delicate = { Quick = 0.55, Normal = 0.7, Delicate = 1.0 },
}

-- Soil levels (random per order). Need = required cleaning power.
M.Soil = {
	Light = { Need = 0.45 },
	Medium = { Need = 0.7 },
	Heavy = { Need = 1.0 },
}
M.SoilPenaltyPerMissingPower = 0.6 -- quality loss = penalty * max(0, need - power)

-- Condition (0-100) of the machine scales quality: factor = 0.8 + 0.2 * condition/100
function M.conditionFactor(condition)
	return 0.8 + 0.2 * math.clamp((condition or 100) / 100, 0, 1)
end

-- Final order quality combines wash and dry stages
M.StageWeights = { Wash = 0.65, Dry = 0.35 }

-- Suggested ("Auto") settings by dominant fabric
M.AutoWash = { Normal = "Normal", Heavy = "Intensive", Delicate = "Delicate" }
M.AutoDry = { Normal = "Normal", Heavy = "Normal", Delicate = "Delicate" }
M.AutoDetergent = { Normal = "Detergent_Regular", Heavy = "Detergent_Regular", Delicate = "Detergent_Delicate" }

return M
