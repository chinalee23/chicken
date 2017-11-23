local Vector2 = require 'math.vector2'
local world = require 'battle.world'

local Com = ecs.Com

local tuple = {
	general = {
		Com.general,
		Com.transform,
	},
	retinue = {
		Com.retinue,
		Com.transform,
	},
}
local sys = ecs.newsys('move', tuple)

local inputs = ecs.Single.inputs
local map = ecs.Single.map
local speed = 0.2
local retinueGap = 1


function sys:move(eGeneral, direction)
	local comTrans_g = eGeneral:getComponent(Com.transform)
	if direction.x ~= 0 or direction.y ~= 0 then
		comTrans_g.direction = direction:Clone()
		comTrans_g.position = comTrans_g.position + direction * speed
		map:modify(eGeneral.id, comTrans_g.position)
	end
	local pos_g = comTrans_g.position

	local comGeneral = eGeneral:getComponent(Com.general)
	local layer = 0
	local sideLen = 0
	local layerIndex = 0
	local x, y
	for i, v in ipairs(comGeneral.retinues) do
		local comTrans_r = self:getEntity(v, 'retinue'):getComponent(Com.transform)
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
		else
			comTrans_r.direction = direction:Clone()
			comTrans_r.position = comTrans_r.position + comTrans_r.direction * speed
		end
		map:modify(v, comTrans_r.position)
	end
end

function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		-- get input
		local input = inputs[k]
		if input and input.direction then
			self:move(v, input.direction)
		end
	end
end