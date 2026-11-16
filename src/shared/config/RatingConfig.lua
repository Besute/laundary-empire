-- RatingConfig: 0-100 components and weights (GDD §11). All weights configurable.
local R = {}

R.Weights = { Service = 0.30, Cleanliness = 0.20, Interior = 0.15, Speed = 0.20, Review = 0.15 }
R.Start = { Service = 50, Cleanliness = 35, Interior = 5, Speed = 50, Review = 50 }

R.Smoothing = 0.20 -- exponential moving average weight for new samples
R.ReviewValue = { Positive = 100, Neutral = 60, Negative = 10 }
R.ServiceSample = { -- per completed/abandoned order
	Completed = 90,
	DeclinedPolitely = 55, -- not a penalty vs ignoring
	CustomerLeftQueue = 15,
	OrderFailed = 5,
}
R.Speed = { Fast = 1.0, Slow = 2.0 } -- ratio actual/estimate -> sample 100 at <=Fast, 20 at >=Slow

-- Cleanliness = 100 - sum(dirt penalties) - binOverflowPenalty, clamped. Recomputed on dirt add/remove only.
R.Dirt = { PenaltyPerPiece = 3.5, AgedAfterSeconds = 180, AgedExtraPenalty = 2.0, MaxPenalty = 90 }

-- Interior = min(100, RenovationSteps*PointsPerStep + decor points). Duplicate decor beyond MaxPerItem adds nothing.
R.Interior = { PointsPerStep = 5, MaxPerItem = 2, Base = 5, Cap = 100 }

R.StarsFromTotal = function(total) return math.clamp(total / 20, 0, 5) end

return R
