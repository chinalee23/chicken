local util = require 'battle.system.util'

local Com = ecs.Com
local concern_1 = {
	Com.attack.attack,
}
local concern_2 = {
	Com.property,
	Com.transform,
	Com.attack.attacker,
}
local concern_3 = {
	Com.property,
	Com.attack.attackee,
}
local sys = ecs.newsys('attack.attack', concern_1, concern_2)

function sys:calc(entity)
	local comAttack = entity:getComponent(Com.attack.attack)
	local atter = self:getEntity(comAttack.atter, 2)
	local attee = self:getEntity(comAttack.attee, 3)
	local comProperty_er = atter:getComponent(Com.property)
	if comProperty.yuancheng then
		local e = ecs.Entity.new()
		e:addComponent(Com.attack.bullet, attee.id, comProperty_er.att, 1)

		local comTrans = atter:getComponent(Com.transform)
		e:addComponent(Com.transform, comTrans.position)
	else
		local comProperty_ee = attee:getComponent(Com.property)
		local dmg = comProperty_er.att^2 / (comProperty_er.att + comProperty_ee.def)
		comProperty_ee.hp = comProperty_ee.hp - dmg
		events.battle.hpChange(attee.id, dmg)
		if comProperty_ee.hp <= 0 then
			util.die(attee)
		end
	end
	entity:addComponent(Com.attack.houyao, eTarget.id, world.frameNo)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end