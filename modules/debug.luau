local debugLogModule = {}
debugLogModule.__index = debugLogModule

local function getTimestamp()
	local t = time()
	return string.format("%s.%03d",os.date("%Y-%m-%d %H:%M:%S", math.floor(t)),math.floor((t - math.floor(t)) * 1000))
end

function debugLogModule:initializeLog(category)
	local self = setmetatable({}, debugLogModule)

	self.logData = {}
	self.logSequence = 0
	self.initialized = getTimestamp()
	self.logCategory = category or "UNKNOWN"

	return self
end

function debugLogModule:log(args)
	args = args or {}
	
	if not self.logData then
		warn("Caller missing logData")
		return
	end

	self.logSequence += 1
	
	local level = typeof(args.Level) == "string" and args.Level:upper() or "UNKNOWN"
	local system = typeof(args.System) == "string" and args.System:upper() or "UNKNOWN"
	local message = args.Message or "NO MESSAGE PROVIDED"

	table.insert(self.logData, string.format("#%04d [%s] [%s] [%s] %s", self.logSequence, getTimestamp(), level, system, message))
end

function debugLogModule:exportLogs()
	if not self.logData or not self.initialized or not self.logCategory then
		warn("Caller missing indexs")
		return
	end
	
	local top = `=== LOG CATEGORY: {self.logCategory:upper()} ===`
	local initialized = `LOG INITIALIZED: {self.initialized}`
	local exported = `LOG EXPORTED: {getTimestamp()}`
	local bottom = string.rep("=", #top)
	local header = top .. "\n" .. initialized .. "\n" .. exported .. "\n" .. bottom
	
	return header .. "\n\n" .. table.concat(self.logData, "\n")
end

function debugLogModule:downloadLogs()
	if not writefile or not isfolder or not makefolder then
		warn("Executor missing functions")
		return
	end
	
	if not isfolder("Lerux-Debug") then
		makefolder("Lerux-Debug")
	end
	
	writefile("Lerux-Debug/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log", self:exportLogs())
end

return debugLogModule
