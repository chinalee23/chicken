local Com = ecs.Com
local concerns = {
	Com.transform,
	Com.troop,
}
local sys = ecs.newsys('move', concerns)

local retinueGap = 3
local input = ecs.Single.input

function sys:move(entity, direction)
	local troop_g = entity:getComponent(Com.troop)
	local trans_g = entity:getComponent(Com.transform)
	trans_g.direction = direction
	if direction.x ~= 0 or direction.y ~= 0 then
		trans_g.face:Set(direction.x, direction.y)
	end

	local range = retinueGap * (math.floor((#troop_g.retinues - 1) / 10) + 1)
	local sqrRange = range * range
	for _, v in ipairs(troop_g.retinues) do
		local retinue = self.entities[v]
		local trans_r = retinue:getComponent(Com.transform)
		local offset = trans_g.position - trans_r.position
		if offset:SqrMagnitude() > sqrRange then
			trans_r.direction = offset:Normalize()
		else
			trans_r.direction:Set(trans_g.direction.x, trans_g.direction.y)
		end
	end
end

function sys:accelerate(entity)
	local trans = entity:getComponent(Com.transform)
	trans.speed = trans.speed + 2
end

function sys:slowdown(entity)
	local trans = entity:getComponent(Com.transform)
	trans.speed = trans.speed - 2
end

function sys:frameCalc( ... )
	for _, v in ipairs(input.inputs) do
		self:move(self.entities[v.id], v.direction)
		if v.accelerate then
			self:accelerate(self.entities[v.id])
		end
		if v.slowdown then
			self:slowdown(self.entities[v.id])
		end
	end
end