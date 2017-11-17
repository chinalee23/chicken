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




local _M = {}

local gameObject
local prefab
local hpBars = {}

local function onHpChange(id, p)
	if hpBars[id] then
		local go = LuaInterface.Clone(prefab, gameObject)
		local hpbar = classHpbar.new(go)
		hpBars[id] = hpbar
	end
	hpBars[id]:show(p)
end

function _M.init(go)
	gameObject = go
	prefab = LuaInterface.Find(go, 'HpBar')
	prefab:SetActive(false)

	events.battle.hpChange.addListener(onHpChange)
end

return _M