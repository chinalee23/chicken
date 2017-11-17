local world = require 'battle.world'
local sys = ecs.Sys.attack
local Com = ecs.Com

local _M = module()

function enter(entity)
	
end

function calc(entity)
	local comAttack = entity:getComponent(Com.attack)
	if world.frameNo - comAttack.startFrame < comAttack.totalFrame then return end

	local target = sys:getEntity(comAttack.target)
	local comAnim = entity:getComponent(Com.animation)
	if sys:checkTargetInRange(entity, target) then
		-- 目标仍然在攻击范围内
		comAnim.currAnim = nil
		return 'qianyao'
	else
		comAnim.tarAnim = nil
		return 'idle'
	end
end

return _M