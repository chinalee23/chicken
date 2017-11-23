local classHpbar = class()
function classHpbar:ctor(go)
	self.gameObject = go
	self.foe = LuaInterface.Find(go, 'Foe', 'Image')
	self.showing = false
	self.showtime = 0
end

function classHpbar:show(p)
	if not self.showing then
		self.gameObject:SetActive(true)
		self.showing = true
	end
	self.foe.fillAmount = p
	self.showtime = Time.time
end

function classHpbar:hide()
	if not self.showing then return end
	self.gameObject:SetActive(false)
	self.hidetime = Time.time
	self.showing = false
end

function classHpbar:setPos(pos)
	LuaInterface.SetPosition(self.gameObject, pos.x + 0.35, pos.y + 0.7, 0)
end

function classHpbar:destroy( ... )
	LuaInterface.DestroyGameObject(self.gameObject)
end




local ui = ecs.Single.ui
local Com = ecs.Com
local tuple = {
	{
		Com.property,
		Com.attackee,
		Com.behavior.transform,
	},
}
local sys = ecs.newsys('behavior.hpbar', tuple)

function sys:init( ... )
	events.battle.hpChange.addListener(function (id, dmg)
		self:onHpChange(id, dmg)
	end)
end

function sys:_onEntityDestroy(entity)
	if ui.hpbars[entity.id] then
		ui.hpbars[entity.id]:destroy()
		ui.hpbars[entity.id] = nil
	end
end

function sys:onHpChange(id, dmg)
	if not ui.hpbars[id] then
		local go = LuaInterface.Clone(ui.hpbarPrefab, ui.hpbarRoot)
		local hpbar = classHpbar.new(go)
		ui.hpbars[id] = hpbar
	end
	
	local comProperty = self:getEntity(id):getComponent(Com.property)
	local p = comProperty.hp/comProperty.hpmax
	ui.hpbars[id]:show(p)

	if comProperty.hp <= 0 then
		ui.hpbars[id]:destroy()
		ui.hpbars[id] = nil
	end
end

function sys:updatePos(id)
	local comTrans = self:getEntity(id):getComponent(Com.behavior.transform)
	local pos = LuaInterface.GetPosition(comTrans.gameObject)
	local v2 = LuaInterface.GetScreenPosFromWorld(ui.uiCamera, pos)
	if ui.hpbars[id] then
		ui.hpbars[id]:setPos(v2)
	end
end

function sys:update( ... )
	for k, v in pairs(ui.hpbars) do
		if v.showing then
			if (Time.time - v.showtime) > 5 then
				v:hide()
			else
				self:updatePos(k)
			end
		end
	end
end

sys:init()
