local util = require 'battle.system.logic.util'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	general = {
		Com.general,
	},
	attacker = {
		Com.team,
		Com.attacker,
		Com.logic.transform,
		Com.logic.animation,
		Com.property,
	},
	attackee = {
		Com.attackee,
		Com.logic.transform,
	},
	weapon = {
		Com.logic.weapon,
	}
}
local sys = ecs.newsys('attacker', tuple)

local map = ecs.Single.map


function sys:checkTargetInAttRange(eAttacker, eTarget)
	local pos_t = eTarget:getComponent(Com.logic.transform).position
	local pos_a = eAttacker:getComponent(Com.logic.transform).position
	local attDist = util.getAttDist(eAttacker)
	local distSq = (pos_t - pos_a):SqrMagnitude()
	local attDistSq = attDist^2
	return distSq < attDistSq or math.approximate(distSq, attDistSq)
end

function sys:checkTargetInWarningRange(eAttacker, eTarget)
	local pos_t = eTarget:getComponent(Com.logic.transform).position
	local pos_a = eAttacker:getComponent(Com.logic.transform).position
	local comProperty = eAttacker:getComponent(Com.property)
	local distSq = (pos_t - pos_a):SqrMagnitude()
	local rangeSq = comProperty.warningRange^2
	return distSq < rangeSq or math.approximate(distSq, rangeSq)
end

function sys:checkTargetInTeamMaxRange(eAttacker, eTarget)
	local eGeneral
	local comTeam = eAttacker:getComponent(Com.team)
	if comTeam.id == eAttacker.id then
		eGeneral = eAttacker
	else
		eGeneral = self:getEntity(comTeam.id, 'general')
	end
	local maxRange = eGeneral:getComponent(Com.general).maxRange
	local pos_g = eGeneral:getComponent(Com.logic.transform).position
	local pos_t = eTarget:getComponent(Com.logic.transform).position
	local distSq = (pos_t - pos_g):SqrMagnitude()
	local rangeSq = maxRange^2
	return distSq < rangeSq or math.approximate(distSq, rangeSq)
end

function sys:findTarget(eAttacker, range)
	local pos = eAttacker:getComponent(Com.logic.transform).position
	return map.attackeeMap:findCloestInRangeByPos(pos, range,
		function (key)
			local eTarget = self:getEntity(key, 'attackee')
			return key ~= eAttacker.id and
					util.isHostile(eAttacker.id, key) and
					self:checkTargetInTeamMaxRange(eAttacker, eTarget)
		end)
end

function sys:calcDirection(eAttacker, eTarget)
	local comTrans_a = eAttacker:getComponent(Com.logic.transform)
	local comTrans_t = eTarget:getComponent(Com.logic.transform)
	comTrans_a.direction = (comTrans_t.position - comTrans_a.position):Normalize()
end

function sys:enteridle(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	comAttacker.target = nil
	comAttacker.status = 'idle'

	local comAnim = eAttacker:getComponent(Com.logic.animation)
	comAnim.anim = nil
end

function sys:idle(eAttacker)
	local target = self:findTarget(eAttacker, util.getAttDist(eAttacker))
	if target then
		local comAttacker = eAttacker:getComponent(Com.attacker)
		comAttacker.target = target
		self:enterQianyao(eAttacker)
	else
		target = self:findTarget(eAttacker, eAttacker:getComponent(Com.property).warningRange)
		if target then
			local comAttacker = eAttacker:getComponent(Com.attacker)
			comAttacker.target = target
			comAttacker.status = 'warning'
			return
		end
	end
end

function sys:warning(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	local eTarget = self:getEntity(comAttacker.target, 'attackee')
	if not eTarget then
		self:enteridle(eAttacker)
		return
	end
	if not self:checkTargetInTeamMaxRange(eAttacker, eTarget) or
		not self:checkTargetInWarningRange(eAttacker, eTarget) then
		self:enteridle(eAttacker)
	elseif self:checkTargetInAttRange(eAttacker, eTarget) then
		self:enterQianyao(eAttacker)
	end
end

function sys:enterQianyao(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	comAttacker.startFrame = world.frameNo
	comAttacker.status = 'qianyao'

	local comAnim = eAttacker:getComponent(Com.logic.animation)
	comAnim.anim = comAnim.skillName
end

function sys:qianyao(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	local eTarget = self:getEntity(comAttacker.target, 'attackee')
	if eTarget and
		self:checkTargetInTeamMaxRange(eAttacker, eTarget) and
		self:checkTargetInAttRange(eAttacker, eTarget) then
		self:calcDirection(eAttacker, eTarget)
		local comProperty = eAttacker:getComponent(Com.property)
		if world.frameNo - comAttacker.startFrame >= comProperty.qianyaoFrame then
			-- log.info('qianyao over', world.frameNo)
			if comAttacker.attType == 'jinzhan' then
				util.attackCalc(comProperty.att, eTarget)
			else
				-- 子弹
				local pos = eAttacker:getComponent(Com.logic.transform).position
				util.createBullet(comProperty.att, {pos.x, pos.y}, comAttacker.target)
			end
			comAttacker.status = 'houyao'
		end
	else
		self:enteridle(eAttacker)
	end
end

function sys:houyao(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	local comProperty = eAttacker:getComponent(Com.property)
	if world.frameNo - comAttacker.startFrame >= comProperty.totalFrame then
		-- log.info('houyao over', world.frameNo)
		comAttacker.status = 'lengque'
		local comAnim = eAttacker:getComponent(Com.logic.animation)
		comAnim.anim = nil
	end
end

function sys:lengque(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	local comProperty = eAttacker:getComponent(Com.property)
	-- local interval = math.ceil(200/(50+comProperty.attSpeed))
	if world.frameNo - comAttacker.startFrame >= comProperty.totalFrame + comProperty.lengqueFrame then
		-- log.info('lengque over', world.frameNo)
		local eTarget = self:getEntity(comAttacker.target, 'attackee')
		if eTarget and
			self:checkTargetInTeamMaxRange(eAttacker, eTarget) and
			self:checkTargetInAttRange(eAttacker, eTarget) then
			-- log.info('target still in range')
			self:enterQianyao(eAttacker)
		else
			-- log.info('no target anymore')
			self:enteridle(eAttacker)
		end
	end
end

function sys:changeAttType(entity, attType)
	local comAttacker = entity:getComponent(Com.attacker)
	if comAttacker.attType == attType then return end

	comAttacker.attType = attType
	self:enteridle(entity)
end

function sys:executeChangeAttType(eGeneral, attType)
	self:changeAttType(eGeneral, attType)

	local comGeneral = eGeneral:getComponent(Com.general)
	for _, v in ipairs(comGeneral.retinues) do
		local eRetinue = self:getEntity(v, 'attacker')
		self:changeAttType(eRetinue, attType)
	end
end


function sys:calc(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	self[comAttacker.status](self, eAttacker)
end

function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		local input = ecs.Single.inputs[k]
		if input and input.attType then
			self:executeChangeAttType(v, input.attType)
		end
	end

	local entities = self:getEntities('attacker')
	for _, v in pairs(entities) do
		self:calc(v)
	end
end