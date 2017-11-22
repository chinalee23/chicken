local function addRetinue(nid, tid)
	local eNpc = ecs.getEntity(nid)
	local eTroop = ecs.getEntity(tid)

	local comRetinue = eTroop:getComponent(Com.retinue)
	if eTroop:getComponent(Com.retinue) then
		local gid = 
	elseif eTroop:getComponent(Com.general) then
	else
		return
	end
end