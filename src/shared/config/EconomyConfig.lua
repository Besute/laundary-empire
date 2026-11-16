-- EconomyConfig: ALL numbers are playtest hypotheses (GDD §12), not final balance.
local E = {}

E.StartingCash = 3000
E.StartingGems = 0
E.MaxLevel = 30

-- Cumulative XP required to REACH level L (L=1 -> 0). floor(40 * (L-1)^1.7)
function E.xpForLevel(level)
	if level <= 1 then return 0 end
	return math.floor(40 * (level - 1) ^ 1.7)
end
function E.levelFromXP(xp)
	local lvl = 1
	while lvl < E.MaxLevel and xp >= E.xpForLevel(lvl + 1) do lvl += 1 end
	return lvl
end

E.XP = {
	OrderBase = 12,
	OrderPerUnit = 3,
	QualityBonusMax = 0.5, -- up to +50% for perfect quality
	CleanDirt = 2,
	CleanDirtDailyCap = 60, -- anti-farm cap per game day
	Repair = 6,
	CatchThief = 40,
}

E.Debt = {
	Limit = 1500, -- max unpaid expenses carried as Debt (never deletes the business)
	RepayShare = 0.30, -- share of every order payment that automatically repays Debt
	WarnAt = 300,
}

E.Settlement = {
	TaxRate = 0.06, -- of day's gross income
	TaxStartDay = 3, -- no taxes in days 1-2 (beginner protection)
	WaterPerCycle = 3, -- utilities billed at settlement
	PowerPerWash = 2,
	PowerPerDry = 4,
	FirstDaysWageDiscount = 0.5, -- wages halved on days 1-2
	MaxExpenseShareOfCashDayOne = 0.0, -- reserved
}

E.Orders = {
	TipChance = 0.25,
	TipMax = 0.20, -- of base payment, when quality >= TipQuality
	TipQuality = 0.9,
	LatePenalty = 0.20, -- applied once when the order missed its deadline / customer waited too long
	QualityPayFloor = 0.55, -- payment multiplier at quality 0
	SellRefund = 0.5, -- refund share when selling a placed object
}

E.Repair = {
	MaintenanceCostMult = 0.12, -- of machine price
	RepairCostMult = 0.30,
	MaintenanceSeconds = 8,
	RepairSeconds = 20,
	SparePartsDiscount = 0.30, -- consumes 1 SpareParts if present
}

E.Cleaning = {
	-- seconds of hold per tool (best owned tool is used)
	HoldSeconds = { Broom = 1.4, Mop = 1.1, Vacuum = 0.6 },
	BinEmptyCost = 0,
}

return E
