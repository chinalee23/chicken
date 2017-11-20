local world = require 'battle.world'

local Com = ecs.Com
local concern_1 = {
	Com.property,
	Com.attack.qianyao,
	Com.animation,
}
local concern_2 = {
	Com.property,
	Com.transform,
	Com.attack.attackee,
	Com.animation,
}
local concern_3 = {
	Com.general,
}
local concern_4 = {
	Com.troop,
}
local sys = ecs.newsys('attack.qianyao', concern_1, concern_2, concern_3, concern_4)

function sys:checkTargetInRange(entity, eTarget)
	local attDist = entity:getComponent(Com.property).attDist
	local pos_e = entity:getComponent(Com.transform).position
	local pos_t = eTarget:getComponent(Com.transform).position
	return (pos_e - pos_t):SqrMagnitude() < attDist^2
end

function sys:updateFace(entity, eTarget)
	local face_e = entity:getComponent(Com.transform).face
	local pos_t = eTarget:getComponent(Com.transform).position
	face_e:Set(pos_t.x, pos_t.y)
end

function sys:updateAnimation(entity)
	local comAnim = entity:getComponent(Com.animation)
	comAnim.tarAnim = 'skill1'
	comAnim.tarSpeed = 1
end

function sys:attack(entity, eTarget)
	local comProperty_atter = entity:getComponent(Com.property)
	local comProperty_attee = eTarget:getComponent(Com.property)
	local dmg = comProperty_atter.att^2 / (comProperty_atter.att + comProperty_attee.def)
	comProperty_attee.hp = comProperty_attee.hp - dmg

	events.battle.hpChange(eTarget.id, dmg)

	if comProperty_attee.hp <= 0 then
		-- die
		self:die(eTarget)
	end
	entity:addComponent(Com.attack.houyao, eTarget.id, world.frameNo)
end

function sys:die(entity)
	entity:addComponent(Com.attack.die)

	-- if general, dismiss retinues
	if self:getEntity(entity.id, 3) then
		local comGeneral = entity:getComponent(Com.general)
		for _, v in ipairs(comGeneral.retinues) do
			local retinue = self:getEntity(v, 4)
			retinue:addComponent(Com.attack.dismiss)
		end
	end
end

function sys:cancel(entity)
	entity:addComponent(Com.attack.idle)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities(1)
	local tmp = {}
	for _, v in pairs(entities) do
		local comQianyao = v:getComponent(Com.attack.qianyao)
		local eTarget = self:getEntity(comQianyao.target, 2)
		if eTarget and self:checkTargetInRange(v, eTarget) then
			-- 目标在攻击范围
			self:updateFace(v, eTarget)
			self:updateAnimation(v)
			local comProperty = v:getComponent(Com.property)
			if world.frameNo - comQianyao.startFrame >= comProperty.qianyaoFrame then
				-- 攻击
				self:attack(v, eTarget)
				table.insert(tmp, v)
			end
		else
			-- 目标不在，取消
			self:cancel(v)
			table.insert(tmp, v)
		end
	end
	for _, v in ipairs(tmp) do
		v:removeComponent(Com.attack.qianyao)
	end
end