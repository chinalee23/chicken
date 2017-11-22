local world = require 'battle.world'
local sys = ecs.Sys.attack
local Com = ecs.Com

local _M = module()

function enter(entity)
	local comAttack = entity:getComponent(Com.attack)
	comAttack.startFrame = world.frameNo

	local target = sys:getEntity(comAttack.target)
	local view = entity:getComponent(Com.view)
	view.lookPos = target:getComponent(Com.transform).position

	local anim = entity:getComponent(Com.animation)
	anim.tarAnim = 'skill1'
end

function calc(entity)
	local comAttack = entity:getComponent(Com.attack)
	if world.frameNo - comAttack.startFrame < comAttack.attFrame then return end
	
	-- 攻击结算

	return 'houyao'
end

return _M