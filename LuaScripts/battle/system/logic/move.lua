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
}
local sys = ecs.newsys('move', tuple)

local inputs = ecs.Single.inputs
local speed = 1
local retinueGap = 1


local function setAnim(comAnim, anim)
	if not comAnim.anim or comAnim.anim ~= 'skill1' then
		comAnim.anim = anim
	end
end

local function limitPos(pos)
	pos.x = math.max(pos.x, 0)
	pos.x = math.min(pos.x, 100)
	pos.y = math.max(pos.y, 0)
	pos.y = math.min(pos.y, 100)
end


function sys:move(eGeneral, direction)
	direction = direction or Vector2(0, 0)
	local comTrans_g = eGeneral:getComponent(Com.logic.transform)
	local comAnim_g = eGeneral:getComponent(Com.logic.animation)
	if direction.x ~= 0 or direction.y ~= 0 then
		comTrans_g.direction = direction:Clone()
		comTrans_g.position = comTrans_g.position + direction * speed
		limitPos(comTrans_g.position)
		setAnim(comAnim_g, 'run')
	else
		setAnim(comAnim_g, 'idle')
	end
	util.updateMap(eGeneral)
	local pos_g = comTrans_g.position

	local comGeneral = eGeneral:getComponent(Com.general)
	local layer = 0
	local sideLen = 0
	local layerIndex = 0
	local x, y
	for i, v in ipairs(comGeneral.retinues) do
		local eRetinue = self:getEntity(v, 'retinue')
		local comTrans_r = eRetinue:getComponent(Com.logic.transform)
		local comAnim_r = eRetinue:getComponent(Com.logic.animation)
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
		local tarPos = Vector2(x, y)
		local offset = tarPos - comTrans_r.position
		local distSq = offset:SqrMagnitude()
		if distSq > 0.0001 then
			comTrans_r.direction = offset:Normalize()
			local t = math.sqrt(distSq)/speed
			comTrans_r.position = Vector2.Lerp(comTrans_r.position, tarPos, 1/t)
			limitPos(comTrans_r.position)
			setAnim(comAnim_r, 'run')
		elseif direction.x ~= 0 or direction.y ~= 0 then
			comTrans_r.direction = direction:Clone()
			comTrans_r.position = comTrans_r.position + comTrans_r.direction * speed
			limitPos(comTrans_r.position)
			setAnim(comAnim_r, 'run')
		else
			setAnim(comAnim_r, 'idle')
		end
		util.updateMap(eRetinue)
	end
end

function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		-- get input
		local input = inputs[k]
		if input and input.direction then
			self:move(v, input.direction)
		else
			self:move(v)
		end
	end
end