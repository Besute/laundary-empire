-- Server entry point. Procedurally creates the shared city block at server startup.
local WorldBuilder = require(script:WaitForChild("World"):WaitForChild("WorldBuilder"))

local ok, worldOrError = pcall(WorldBuilder.Build)
if ok then
	local AmbientTraffic = require(script:WaitForChild("World"):WaitForChild("AmbientTraffic"))
	local trafficOk, trafficError = pcall(AmbientTraffic.Start, worldOrError)
	if not trafficOk then
		warn("[LaundryEmpire] Ambient traffic failed to start: " .. tostring(trafficError))
	end
else
	warn("[LaundryEmpire] World generation failed: " .. tostring(worldOrError))
end
