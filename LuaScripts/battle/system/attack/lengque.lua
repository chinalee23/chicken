local world = require 'battle.world'

local Com = ecs.Com
local concern_1 = {
	Com.property,
	Com.attack.lengque,
}
local concern_2 = {
	Com.transform,
	Com.attack.attackee,
}
local sys = ecs.newsys('attack.lengque', concern_1, concern_2)

function sys:checkTargetInRange(entity, eTarget)
	local attDist = entity:getComponent(Com.property).attDist
	local pos_e = entity:getComponent(Com.transform).position
	local pos_t = eTarget:getComponent(Com.transform).position
	return (pos_e - pos_t):SqrMagnitude() < attDist^2
end

function sys:attack(entity, target)
	entity:addComponent(Com.attack.qianyao, target, world.frameNo)
end

function sys:cancel(entity)
	entity:addComponent(Com.attack.idle)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	local tmp = {}
	for _, v in pairs(entities) do
		local comLengque = v:getComponent(Com.attack.lengque)
		local comProperty = v:getComponent(Com.property)
		local interval = math.ceil(200/(50+comProperty.attSpeed))
		if world.frameNo - comLengque.startFrame >= interval then
			-- 可以下次攻击
			local eTarget = self:getEntity(comLengque.target, 2)
			if eTarget and self:checkTargetInRange(v, eTarget) then
				self:attack(v, comLengque.target)
			else
				self:cancel(v)
			end
			table.insert(tmp, v)
		end
	end
	for _, v in ipairs(tmp) do
		v:removeComponent(Com.attack.lengque)
	end
end