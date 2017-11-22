local world = require 'battle.world'
local sys = ecs.Sys.attack
local Com = ecs.Com

local _M = module()

function enter( ... )
	-- body
end

function calc(entity)
	local comAttack = entity:getComponent(Com.attack)
	local targetNode = sys:findTarget(entity)
	if targetNode then
		comAttack.target = targetNode.data
		return 'qianyao'
	end
end


return _M