local input = require 'battle.input'

local btn = class()

function btn:ctor(go, name, interval, inputName)
	self.gameObject = go
	self.name = name
	self.countdown = 0
	self.interval = interval
	self.inputName = inputName
	self.cover = LuaInterface.Find(go, 'cover', 'Image')
	self.text = LuaInterface.Find(go, 'Text', 'Text')

	LuaInterface.AddClick(go, function ( ... )
		self:onClick()
	end)
end

function btn:onClick( ... )
	if self.countdown > 0 then return end
	self.countdown = self.interval
	input[self.inputName] = true
end

function btn:update( ... )
	if self.countdown == 0 then
		self.cover.gameObject:SetActive(false)
		self.text.text = self.name
	else
		self.cover.gameObject:SetActive(true)
		self.countdown = self.countdown - Time.deltaTime
		self.cover.fillAmount = self.countdown / self.interval
		self.text.text = math.ceil(self.countdown)
		if self.countdown < 0 then
			self.countdown = 0
		end
	end
end

return btn