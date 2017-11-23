local Com = ecs.Com
local tuple = {
	{
		Com.logic.animation,
		Com.behavior.animation,
	},
}
local sys = ecs.newsys('behavior.animation', tuple)

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local comAnim_l = v:getComponent(Com.logic.animation)
		local comAnim_b = v:getComponent(Com.behavior.animation)
		if comAnim_b.currAnim ~= comAnim_l.anim then
			comAnim_b.currAnim = comAnim_l.anim
			if comAnim_b.currAnim then
				LuaInterface.PlayAnimation(comAnim_b.gameObject, comAnim_b.currAnim)
			end
		end
	end
end