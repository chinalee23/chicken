local Vector2 = require 'math.vector2'

local Com = ecs.Com
local concern_1 = {
	Com.attack.bullet,
	Com.transform,
}
local concern_2 = {
	Com.attack.attackee,
	Com.transform,
}
local sys = ecs.newsys('attack.bullet', concern_1)


local threshold = 0.1


function sys:updatePos(entity)
	local comBullet = entity:getComponent(Com.attack.bullet)
	local target = self:getEntity(comBullet.target, 2)
	if target then
		local comTrans_b = entity:getComponent(Com.transform)
		local comTrans_t = target:getComponent(Com.transform)
		comTrans_b.position = Vector2.Lerp(comTrans_b.position, comTrans_t.position, Time.deltaTime * comBullet.speed)
		local offset = comTrans_t.position - comTrans_b.position
		if offset:SqrMagnitude() < 0.1 then
			
		end
	else
	end
end

function sys:update( ... )
	local entities = self:getEntities(1)
	for _, v in pairs(entities) do
		v:updatePos(v)
	end
end

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do

	end
end