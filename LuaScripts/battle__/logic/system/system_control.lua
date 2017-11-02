local system = require 'ecs/system'

local COM_CONTROL = require 'battle.logic.component.control',
local COM_RVO = require 'battle.logic.component.rvo'
local concerns = {
	COM_CONTROL,
	COM_RVO,
}

local _M = system.new(concerns)

function onControlMsg(msg)
	for _, v in ipairs(msg) do
		if _M.entities[v.id] then
			local com = _M.entities[v.id][COM_CONTROL._name]
			com.direction = v.direction
		end
	end
end
events.controlMsg.addListener(onControlMsg)