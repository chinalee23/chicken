local Com = ecs.Com
local concern = {
	Com.animation,
	Com.view,
}
local sys = ecs.newsys('animation', concern)

function sys:_frameCalc( ... )
	local entities = self:getEntities()
	for _, v in pairs(entities) do
		local anim = v:getComponent(Com.animation)
		local view = v:getComponent(Com.view)
		if anim.tarAnim and anim.currAnim ~= anim.tarAnim then
			LuaInterface.PlayAnimation(view.gameObject, anim.tarAnim, anim.tarSpeed)
			anim.currAnim = anim.tarAnim
		end
	end
end