local Com = ecs.Com
local tuple = {
	{
		Com.attackee,
		Com.logic.transform,
	},
}
local sys = ecs.newsys('attackee', tuple)

local map = ecs.Single.map

function sys:calc(entity)
	local comTrans = entity:getComponent(Com.logic.transform)
	
end

function sys:_frameCalc( ... )
	local entities = selt:getEntities()
	for _, v in pairs(entities) do
		self:calc(v)
	end
end