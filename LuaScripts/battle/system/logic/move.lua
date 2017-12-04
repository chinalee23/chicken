local Vector2 = require 'math.vector2'
local world = require 'battle.world'
local util = require 'battle.system.logic.util'

local Com = ecs.Com

local tuple = {
	general = {
		Com.general,
		Com.logic.transform,
		Com.logic.animation,
	},
	retinue = {
		Com.retinue,
		Com.logic.transform,
		Com.logic.animation,
	},
	attacker = {
		Com.attacker,
	},
}
local sys = ecs.newsys('move', tuple)

local normalSpeed = 0.7
local maxSpeed = 1.2
local retinueGap = 2


local function setAnim(comAnim, anim)
	if not comAnim.anim or comAnim.anim ~= comAnim.skillName then
		if anim == 'idle' then
			comAnim.anim = comAnim.idleName
		elseif anim == 'run' then
			comAnim.anim = comAnim.runName
		end
	end
end

local function limitPos(pos)
	pos.x = math.max(pos.x, -43)
	pos.x = math.min(pos.x, 57)
	pos.y = math.max(pos.y, -66)
	pos.y = math.min(pos.y, 34)
end

-- if 将军 then
--     if 玩家指令 then
--         按照指令移动
--     elseif 有警戒目标 then
--         向警戒目标移动
-- else
--     if 玩家指令 or 没有警戒目标 then
--         移动到阵型指定的点
--     else 有警戒目标 then
--         向警戒目标移动

function sys:getTarget(entity)
	if not self:getEntity(entity.id, 'attacker') then return end
	local comAttacker = entity:getComponent(Com.attacker)
	return comAttacker.target
	-- if comAttacker.status == 'warning' then
	-- 	return comAttacker.target
	-- end
end

function sys:move(eGeneral, direction, accelerate)
	self:moveGeneral(eGeneral, direction, accelerate)
	self:moveRetinue(eGeneral, direction)
end

function sys:moveGeneral(eGeneral, direction, accelerate)
	local comTrans = eGeneral:getComponent(Com.logic.transform)
	local comAnim = eGeneral:getComponent(Com.logic.animation)
	if accelerate then
		comTrans.speed = (accelerate == 'on' and maxSpeed or normalSpeed)
	end
	if direction then
		comTrans.direction = direction:Clone()
		-- comTrans.position = comTrans.position + direction * comTrans.speed
		limitPos(comTrans.position)
		setAnim(comAnim, 'run')

		comTrans.velocity = direction * comTrans.speed
	else
		local target = self:getTarget(eGeneral)
		if target then
			util.moveTowardToTarget(eGeneral.id, target)
			setAnim(comAnim, 'run')
		else
			setAnim(comAnim, 'idle')

			comTrans.velocity = Vector2(0, 0)
		end
	end
	util.updateMap(eGeneral)
end

function sys:moveRetinue(eGeneral, direction)
	local comTrans_g = eGeneral:getComponent(Com.logic.transform)
	local pos_g = comTrans_g.position
	local layer = 0
	local sideLen = 0
	local layerIndex = 0
	local x, y
	local comGeneral = eGeneral:getComponent(Com.general)
	for i, v in ipairs(comGeneral.retinues) do
		local eRetinue = self:getEntity(v, 'retinue')
		local comTrans_r = eRetinue:getComponent(Com.logic.transform)
		local comAnim_r = eRetinue:getComponent(Com.logic.animation)

		comTrans_r.speed = comTrans_g.speed

		if i == 1 or layerIndex == 8*layer then
			layer = layer + 1
			sideLen = 2*layer+1
			layerIndex = 1
			x = pos_g.x - layer*retinueGap
			y = pos_g.y - layer*retinueGap
		else
			layerIndex = layerIndex + 1
			if layerIndex >= 1 and layerIndex <= sideLen then
				y = y + retinueGap
			elseif layerIndex > sideLen and layerIndex <= 2*sideLen - 1 then
				x = x + retinueGap
			elseif layerIndex >= 2*sideLen and layerIndex <= 3*sideLen - 2 then
				y = y - retinueGap
			else
				x = x - retinueGap
			end
		end

		local target = self:getTarget(eRetinue)
		if direction or not target then
			-- self:retinueMoveToQueue(comTrans_r, comAnim_r, Vector2(x, y))
			self:retinueMoveToQueue(comTrans_r, direction, Vector2(x, y))
		else
			util.moveTowardToTarget(eRetinue.id, target)
			setAnim(comTrans_r, 'run')
		end
		util.updateMap(eRetinue)
	end
end

function sys:retinueMoveToQueue(comTrans, direction, tarPos)
	if direction then
		comTrans.direction = direction:Clone()
		comTrans.velocity = direction * comTrans.speed
	else
		local offset = tarPos - comTrans.position
		local distSq = offset:SqrMagnitude()
		if distSq > math.NE then
			log.info('not in position')
			comTrans.direction = offset:Normalize()
			if distSq > comTrans.speed^2 then
				comTrans.velocity = comTrans.direction * comTrans.speed
			else
				comTrans.velocity = comTrans.direction * math.sqrt(distSq)
			end
		else
			comTrans.velocity:Set(0, 0)
		end
	end
end

function sys:_retinueMoveToQueue(comTrans, comAnim, tarPos)
	local offset = tarPos - comTrans.position
	local distSq = offset:SqrMagnitude()
	if distSq > 0.0001 then
		comTrans.direction = offset:Normalize()
		if distSq > comTrans.speed^2 then
			-- comTrans.position = comTrans.position + comTrans.direction * comTrans.speed
			comTrans.velocity = comTrans.direction * comTrans.speed
		else
			-- comTrans.position = tarPos
			comTrans.velocity = comTrans.direction * math.sqrt(distSq)
		end
		limitPos(comTrans.position)
		setAnim(comAnim, 'run')
	else
		setAnim(comAnim, 'idle')
		comTrans.velocity:Set(0, 0)
	end
end

-- 先计算有移动指令的，确保玩家指令的及时性
function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	local tmp = {}
	for k, v in pairs(generals) do
		-- get input
		local input = ecs.Single.inputs[k]
		if input and (input.direction or input.accelerate) then
			self:move(v, input.direction, input.accelerate)
		else
			table.insert(tmp, v)
			-- self:move(v)
		end
	end

	for _, v in ipairs(tmp) do
		self:move(v)
	end
end