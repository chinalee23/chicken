local Com = ecs.Com
local concern = {
	Com.skill.normal,
}
local sys = ecs.newsys('skill.normal', concern)

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		
	end
end