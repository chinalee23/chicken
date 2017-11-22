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
local speed = 1
local retinueGap = 1

function sys:move(eGeneral, direction)
	local comTrans_g = eGeneral:getComponent(Com.transform)
	local pos_g = comTrans_g.position + direction * speed
	comTrans_g.position	= pos_g

	local comGeneral = eGeneral:getComponent(Com.general)
	local layer = 0
	local sideLen = 0
	local layerIndex = 0
	local x, y
	for i, v in ipairs(comGeneral.retinues) do
		local comTrans_r = self:getEntity(v, 'retinue'):getComponent(Com.transform)
		if i == 1 or i == (layer+2)^2 then
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
		local direction = (tarPos - comTrans_r.position):Normalize()
		comTrans_r.position = comTrans_r.position + direction * speed
	end
end

function sys:_frameCalc( ... )
	local generals = self:getEntities('general')
	for k, v in pairs(generals) do
		-- get input
		local input = inputs[k]
		if input.direction then
			self:move(v, input.direction)
		end
	end
end