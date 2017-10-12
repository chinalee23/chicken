local function event( ... )
	local self = {
		handlers = {},
		rmlist = {},
		locked = false,
	}

	function self.add_listener(handler)
		assert(handler and type(handler) == 'function', 'handler is not valid, check it')
		self.handlers[handler] = true
	end

	function self.remove_listener(handler)
		if self.locked then
			self.handlers[handler] = nil
		else
			table.insert(self.rmlist, handler)
		end
	end

	local function broadcast(self, ...)
		self.locked = true
		for k, _ in pairs(self.handlers) do
			k(...)
		end
		for _, k in ipairs(self.rmlist) do
			self.handlers[k] = nil
		end
		self.rmlist = {}
		self.locked = false
	end

	setmetatable(self, {__call = broadcast})

	return self
end

local def = require 'util.event_def'
events = {}
for _, v in ipairs(def) do
	events[v] = event()
end