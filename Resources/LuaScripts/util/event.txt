local function event( ... )
	local self = {}

	local handlers = {}
	local rmlist = {}
	local locked = false

	function self.addListener(handler)
		assert(handler and type(handler) == 'function', 'handler is not valid, check it')
		handlers[handler] = true
	end

	function self.removeListener(handler)
		if locked then
			handlers[handler] = nil
		else
			table.insert(rmlist, handler)
		end
	end

	local function broadcast(self, ...)
		locked = true
		for k, _ in pairs(handlers) do
			k(...)
		end
		for _, k in ipairs(rmlist) do
			handlers[k] = nil
		end
		rmlist = {}
		locked = false
	end

	setmetatable(self, {__call = broadcast})

	return self
end

local def = require 'util.event_def'
events = {}
for _, v in ipairs(def) do
	events[v] = event()
end