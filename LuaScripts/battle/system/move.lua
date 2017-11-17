local Com = ecs.Com
local concerns_1 = {
	Com.transform,
	Com.troop,
}
local concerns_2 = {
	Com.general,
}
local sys = ecs.newsys('move', concerns_1, concerns_2)

local retinueGap = 2
local input = ecs.Single.input


local function calcLayer(retinueCnt)
	if retinueCnt > 100 then
		return 5
	elseif retinueCnt > 70 then
		return 4
	elseif retinueCnt > 30 then
		return 3
	elseif retinueCnt > 10 then
		return 2
	else
		return 1
	end
end

function sys:move(id, direction)
	local comTrans_g = self:getEntity(id, 1):getComponent(Com.transform)
	comTrans_g.direction:Set(direction.x, direction.y)

	local comGeneral = self:getEntity(id, 2):getComponent(Com.general)
	local layer = calcLayer(#comGeneral.retinues)
	local sqrRange = (layer * retinueGap)^2
	for _, v in ipairs(comGeneral.retinues) do
		local comTrans_r = self:getEntity(v, 1):getComponent(Com.transform)
		local offset = comTrans_g.position - comTrans_r.position
		if offset:SqrMagnitude() > sqrRange then
			comTrans_r.direction = offset:Normalize()
		else
			comTrans_r.direction:Set(direction.x, direction.y)
		end
	end
end

function sys:accelerate(id)
	local trans = self:getEntity(id, 1):getComponent(Com.transform)
	trans.speed = trans.speed + 2
end

function sys:slowdown(id)
	local trans = self:getEntity(id, 1):getComponent(Com.transform)
	trans.speed = trans.speed - 2
end

function sys:_frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		self:move(v.id, v.direction)
		if v.accelerate then
			self:accelerate(v.id)
		end
		if v.slowdown then
			self:slowdown(v.id)
		end
	end
end