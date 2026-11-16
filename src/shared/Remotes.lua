-- Remotes: the single network contract. Server creates every instance at boot under ReplicatedStorage.LE_Remotes.
-- All client->server calls are RemoteFunctions that return a Result table {ok=true,...} | {ok=false, code="<ErrorCodes>"}.
-- Server->client messages are RemoteEvents.
--
-- Arg spec grammar: "name:type[:a[:b]]"; a trailing "?" marks the arg optional (must be last args).
--   id            string 1..40 chars of [%w_%-:%.]
--   string[:max]  string up to max chars (default 64)
--   int[:min:max] integer in range (default -1000000..1000000)
--   num[:min:max] finite number
--   bool
--   enum:A|B|C
--   counts        table {[typeId:id]=int 1..99}, at most 12 entries
--   idlist        array of ids, at most 8 entries
local Remotes = {}

Remotes.FolderName = "LE_Remotes"

local FACADES = "Modern|Classic|Colorful"
local MODES = "Quick|Normal|Delicate|Intensive"

Remotes.Functions = {
	RequestSync = { args = {}, rate = 1, burst = 3 },
	ReportUIEvent = { args = { "name:enum:BuildMenuOpened|BusinessMenuOpened|OrdersMenuOpened|ShopOpened|FinanceOpened" }, rate = 3, burst = 6 },

	-- business
	RequestSetupBusiness = { args = { "name:string:48", "facade:enum:" .. FACADES }, rate = 1, burst = 2 },
	RequestSetBusinessName = { args = { "name:string:48" }, rate = 1, burst = 2 },
	RequestSetFacade = { args = { "facade:enum:" .. FACADES }, rate = 1, burst = 2 },
	RequestToggleBusiness = { args = { "open:bool" }, rate = 2, burst = 4 },
	RequestSetBusinessHours = { args = { "openHour:int:0:23", "closeHour:int:0:23", "alwaysOpen:bool" }, rate = 2, burst = 4 },

	-- economy / shop / progression
	RequestPurchase = { args = { "kind:enum:Supply|Upgrade|Property", "id:id", "qty:int:1:50", "requestId:id?" }, rate = 4, burst = 8 },
	RequestRenovateProperty = { args = { "propertyId:id", "purpose:enum:LaundryRoom|Warehouse|Parking|Office", "requestId:id?" }, rate = 1, burst = 2 },

	-- building
	RequestBuild = { args = { "itemId:id", "cellX:int:-200:200", "cellZ:int:-200:200", "rot:int:0:3", "floor:int:1:3", "requestId:id?" }, rate = 6, burst = 12 },
	RequestMoveObject = { args = { "objectId:id", "cellX:int:-200:200", "cellZ:int:-200:200", "rot:int:0:3", "floor:int:1:3" }, rate = 6, burst = 12 },
	RequestSellObject = { args = { "objectId:id" }, rate = 3, burst = 6 },

	-- orders and machines
	RequestAcceptOrder = { args = { "orderId:id" }, rate = 4, burst = 8 },
	RequestDeclineOrder = { args = { "orderId:id", "reason:enum:Busy|NoCapacity|Unsupported|Other" }, rate = 4, burst = 8 },
	RequestLoadItems = { args = { "machineId:id", "orderId:id", "selection:counts" }, rate = 6, burst = 12 },
	RequestUnloadItems = { args = { "machineId:id", "orderId:id?", "selection:counts?" }, rate = 6, burst = 12 },
	RequestStartWash = { args = { "machineId:id", "mode:enum:" .. MODES, "detergentId:id", "additives:idlist?" }, rate = 4, burst = 8 },
	RequestTransferItems = { args = { "fromMachineId:id", "toMachineId:id", "orderId:id?", "selection:counts?" }, rate = 6, burst = 12 },
	RequestStartDry = { args = { "machineId:id", "mode:enum:Quick|Normal|Delicate" }, rate = 4, burst = 8 },
	RequestPackOrder = { args = { "orderId:id" }, rate = 4, burst = 8 },
	RequestCollectOrder = { args = { "orderId:id" }, rate = 4, burst = 8 },
	RequestRepair = { args = { "machineId:id", "kind:enum:Maintenance|Repair", "requestId:id?" }, rate = 3, burst = 6 },

	-- cleaning
	RequestClean = { args = { "dirtId:id" }, rate = 4, burst = 6 },
	RequestEmptyBin = { args = { "objectId:id" }, rate = 3, burst = 6 },

	-- employees
	RequestHireEmployee = { args = { "candidateId:id", "requestId:id?" }, rate = 2, burst = 4 },
	RequestFireEmployee = { args = { "employeeId:id" }, rate = 2, burst = 4 },
	RequestAssignEmployee = { args = { "employeeId:id", "zone:enum:Auto|Front|Laundry|Floor|Back" }, rate = 3, burst = 6 },
	RequestRefreshCandidates = { args = {}, rate = 1, burst = 2 },

	-- advertising / security
	RequestBuyCampaign = { args = { "campaignType:id", "slotId:id?", "requestId:id?" }, rate = 2, burst = 4 },
	RequestCatchThief = { args = { "thiefId:id" }, rate = 2, burst = 4 },
	RequestCallPolice = { args = { "thiefId:id" }, rate = 2, burst = 4 },

	-- tutorial
	RequestTutorial = { args = { "action:enum:Skip|Replay" }, rate = 1, burst = 2 },
}

-- Server -> client
Remotes.Events = {
	NotifyClient = "S2C", -- (kind:string, payload:table)  kind: "Toast"|"Alert"|"Reward"; payload {key, params, level="info|good|warn|bad"}
	StateUpdate = "S2C", -- (channel:string, payload:any)  see docs/CONTRACT.md "State channels"
	FxEvent = "S2C", -- (kind:string, payload:table)    cosmetic cues: "ClothesToMachine","CashPop","Confetti","ThiefAlarm", ...
}

-- Names of state channels (Remotes.Events.StateUpdate)
Remotes.Channels = { "Profile", "Business", "Orders", "Machines", "Inventory", "Employees", "Finance", "Build", "Properties", "Ads", "Tutorial", "Security" }

-- ───────────── validation (shared; server is authoritative, client may pre-check) ─────────────
local function split(s, sep)
	local out = {}
	for part in string.gmatch(s, "[^" .. sep .. "]+") do table.insert(out, part) end -- skips empty parts
	return out
end

function Remotes.parseSpec(spec)
	local optional = false
	if spec:sub(-1) == "?" then
		optional = true
		spec = spec:sub(1, -2)
	end
	local parts = {}
	local i = 1
	-- manual split keeps empty trailing parts out and supports "enum:A|B"
	for token in string.gmatch(spec, "[^:]+") do
		parts[i] = token
		i += 1
	end
	return { name = parts[1], type = parts[2], a = parts[3], b = parts[4], optional = optional }
end

local ID_OK = "^[%w_%-:%.]+$"
local function isId(v) return type(v) == "string" and #v >= 1 and #v <= 40 and string.match(v, ID_OK) ~= nil end

function Remotes.validateOne(p, v)
	local t = p.type
	if t == "id" then
		return isId(v)
	elseif t == "string" then
		return type(v) == "string" and #v <= (tonumber(p.a) or 64)
	elseif t == "int" or t == "num" then
		if type(v) ~= "number" or v ~= v or v == math.huge or v == -math.huge then return false end
		if t == "int" and v ~= math.floor(v) then return false end
		local lo = tonumber(p.a) or -1000000
		local hi = tonumber(p.b) or 1000000
		return v >= lo and v <= hi
	elseif t == "bool" then
		return type(v) == "boolean"
	elseif t == "enum" then
		if type(v) ~= "string" then return false end
		for _, opt in ipairs(split(p.a or "", "|")) do
			if opt == v then return true end
		end
		return false
	elseif t == "counts" then
		if type(v) ~= "table" then return false end
		local n = 0
		for k, c in pairs(v) do
			n += 1
			if n > 12 or not isId(k) or type(c) ~= "number" or c ~= math.floor(c) or c < 1 or c > 99 then return false end
		end
		return true
	elseif t == "idlist" then
		if type(v) ~= "table" then return false end
		local n = 0
		for k, id in pairs(v) do
			n += 1
			if n > 8 or type(k) ~= "number" or not isId(id) then return false end
		end
		return true
	end
	return false
end

-- Returns ok:boolean, errOrNil. `args` is an array (use table.pack semantics: args.n optional).
function Remotes.validateArgs(specs, args)
	local parsed = Remotes.parsedCache and Remotes.parsedCache[specs]
	if not parsed then
		parsed = {}
		for _, s in ipairs(specs) do table.insert(parsed, Remotes.parseSpec(s)) end
		Remotes.parsedCache = Remotes.parsedCache or setmetatable({}, { __mode = "k" })
		Remotes.parsedCache[specs] = parsed
	end
	if #args > #parsed then return false, "TooManyArgs" end
	for i, p in ipairs(parsed) do
		local v = args[i]
		if v == nil then
			if not p.optional then return false, "Missing:" .. tostring(p.name) end
		elseif not Remotes.validateOne(p, v) then
			return false, "Bad:" .. tostring(p.name)
		end
	end
	return true, nil
end

return Remotes
