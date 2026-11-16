-- TimeUtil: game clock derived from ONE server attribute so that every client agrees without per-frame replication.
-- Server (DayNightService) sets workspace attribute "LE_DayEpoch" = server time at which the game clock read InitialHour of day 1.
local GameConfig = require(script.Parent.config.GameConfig)

local TimeUtil = {}
local DAY = GameConfig.Day
local SECONDS_PER_MIN = DAY.RealSecondsPerDay / 1440

function TimeUtil.getEpoch()
	local e = workspace:GetAttribute("LE_DayEpoch")
	if type(e) ~= "number" then return nil end
	return e
end

-- Returns {Day=int>=1, Minutes=0..1439 (float), Hour=0..24 (float), Period=string, SecondsToDayEnd=number}
function TimeUtil.getClock(serverNow)
	serverNow = serverNow or workspace:GetServerTimeNow()
	local epoch = TimeUtil.getEpoch() or serverNow
	local totalMinutes = DAY.InitialHour * 60 + (serverNow - epoch) / SECONDS_PER_MIN
	local dayIndex = math.floor((totalMinutes - DAY.StartHour * 60) / 1440) + 1
	local minutes = totalMinutes % 1440
	local nextBoundary = (dayIndex) * 1440 + DAY.StartHour * 60 -- minute count at which the next day starts
	return {
		Day = math.max(1, dayIndex),
		Minutes = minutes,
		Hour = minutes / 60,
		Period = TimeUtil.periodOf(minutes / 60),
		SecondsToDayEnd = math.max(0, (nextBoundary - totalMinutes) * SECONDS_PER_MIN),
	}
end

function TimeUtil.periodOf(hour)
	for _, p in ipairs(GameConfig.Periods) do
		if p.To > 24 then
			if hour >= p.From or hour < (p.To - 24) then return p.Name end
		elseif hour >= p.From and hour < p.To then
			return p.Name
		end
	end
	return "Day"
end

-- Is `hour` inside [openHour, closeHour) (wrapping past midnight)? alwaysOpen => true
function TimeUtil.isWithinHours(hour, openHour, closeHour, alwaysOpen)
	if alwaysOpen then return true end
	if openHour == closeHour then return true end
	if openHour < closeHour then return hour >= openHour and hour < closeHour end
	return hour >= openHour or hour < closeHour
end

TimeUtil.SecondsPerGameMinute = SECONDS_PER_MIN

return TimeUtil
