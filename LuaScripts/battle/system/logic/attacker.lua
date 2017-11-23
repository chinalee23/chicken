local util = require 'battle.system.logic.util'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	attacker = {
		Com.attacker,
		Com.logic.transform,
		Com.logic.animation,
		Com.property,
	},
	attackee = {
		Com.attackee,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('attacker', tuple)

local map = ecs.Single.map

local function findTarget(eAttacker)
	local pos = eAttacker:getComponent(Com.logic.transform).position
	local comProperty = eAttacker:getComponent(Com.property)
	return map.attackeeMap:findCloestInRangeByPos(pos, comProperty.attDist,
		function (key)
			return key ~= eAttacker.id and util.isHostile(eAttacker.id, key)
		end)
end

local function checkTargetInRange(eAttacker, eTarget)
	local pos_t = eTarget:getComponent(Com.logic.transform).position
	local pos_a = eAttacker:getComponent(Com.logic.transform).position
	local attDist = eAttacker:getComponent(Com.property).attDist
	return (pos_t - pos_a):SqrMagnitude() < attDist^2
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
	local target =  findTarget(eAttacker)
	if not target then return end
	-- log.info('find target', target, world.frameNo)

	local comAttacker = eAttacker:getComponent(Com.attacker)
	comAttacker.target = target
	self:enterQianyao(eAttacker)
end

function sys:enterQianyao(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	comAttacker.startFrame = world.frameNo
	comAttacker.status = 'qianyao'

	local comAnim = eAttacker:getComponent(Com.logic.animation)
	comAnim.anim = 'skill1'
end

function sys:qianyao(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	local eTarget = self:getEntity(comAttacker.target, 'attackee')
	if eTarget and checkTargetInRange(eAttacker, eTarget) then
		self:calcDirection(eAttacker, eTarget)
		local comProperty = eAttacker:getComponent(Com.property)
		if world.frameNo - comAttacker.startFrame >= comProperty.qianyaoFrame then
			-- log.info('qianyao over', world.frameNo)
			if comProperty.attType == 'jinzhan' then
				util.attackCalc(comProperty.att, eTarget)
			else
				-- 子弹
				local pos = eAttacker:getComponent(Com.logic.transform).position
				util.createBullet(comProperty.att, {pos.x, pos.y}, comAttacker.target)
			end
			comAttacker.status = 'houyao'
		end
	else
		-- log.info('cancel qianyao')
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
		if eTarget and checkTargetInRange(eAttacker, eTarget) then
			-- log.info('target still in range')
			self:enterQianyao(eAttacker)
		else
			-- log.info('no target anymore')
			self:enteridle(eAttacker)
		end
	end
end


function sys:calc(eAttacker)
	local comAttacker = eAttacker:getComponent(Com.attacker)
	self[comAttacker.status](self, eAttacker)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities('attacker')
	for _, v in pairs(entities) do
		self:calc(v)
	end
end