local util = require 'battle.system.util'
local world = require 'battle.world'

local Com = ecs.Com
local tuple = {
	attacker = {
		Com.attacker,
		Com.transform,
		Com.property,
	},
	attackee = {
		Com.attackee,
		Com.transform,
	},
}
local sys = ecs.newsys('attack')

local map = ecs.Single.map

local function findTarget(eAttacker)
	local comTrans = eAttacker:getComponent(Com.transform)
	local comProperty = eAttacker:getComponent(Com.property)
	local targets = map:findKeysInRangeByPos(comTrans, comProperty.attDist)
	for _, v in ipairs(targets) do
		if isHostile(eAttacker.id, v) then
			local comAttack = eAttacker:getComponent(Com.eAttacker)
			comAttack.target = v
			return v
		end
	end
end

local function checkTargetInRange(eAttacker, eTarget)
	local pos_t = eTarget:getComponent(Com.transform).position
	local pos_a = eAttacker:getComponent(Com.transform).position
	local attDist = eAttacker:getComponent(Com.property).attDist
	return (pos_t - pos_a):SqrMagnitude() < attDist^2
end



function sys:idle(eAttacker)
	local target =  findTarget(eAttacker)
	if not target then return end

	local comAttack = eAttacker:getComponent(Com.attack)
	comAttack.startFrame = world.frameNo
	comAttack.status = 'qianyao'
end

function sys:qianyao(eAttacker)
	local comAttack = eAttacker:getComponent(Com.attack)
	local eTarget = self:getEntity(comAttack.target, 'attackee')
	if eTarget and checkTargetInRange(eAttacker, eTarget) then
		local comProperty = eAttacker:getComponent(Com.property)
		if world.frameNo - comAttack.startFrame >= comProperty.qianyaoFrame then
			if comProperty.attType == 'jinzhan' then
				util.attackCalc(comProperty.att, eTarget)
			else
				-- 子弹
			end
			self.status = 'houyao'
		end
	else
		comAttack.status = 'idle'
		comAttack.target = nil
	end
end

function sys:houyao(eAttacker)
	local comAttack = eAttacker:getComponent(Com.attack)
	local comProperty = eAttacker:getComponent(Com.property)
	if world.frameNo - comAttack.startFrame >= comProperty.houyaoFrame then
		self.status = 'lengque'
	end
end

function sys:lengque(eAttacker)
	local comAttack = eAttacker:getComponent(Com.attack)
	local comProperty = eAttacker:getComponent(Com.property)
	local interval = math.ceil(200/(50+comProperty.attSpeed))
	if world.frameNo - comAttack.startFrame >= comProperty.totalFrame + interval then
		local eTarget = self:getEntity(comAttack.target, 'attackee')
		if eTarget and checkTargetInRange(eAttacker, eTarget) then
			self.status = 'qianyao'
			self.startFrame = world.frameNo
		else
			self.status = 'idle'
		end
	end
end


function sys:calc(eAttacker)
	local comAttack = eAttacker:getComponent(Com.attack)
	self[comAttack.status](self, eAttacker)
end

function sys:_frameCalc( ... )
	local entities = self:getEntities('attacker')
	for _ v in pairs(entities) do
		self:calc(v)
	end
end