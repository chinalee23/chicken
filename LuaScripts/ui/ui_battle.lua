local input = require 'battle.input'

local _M = module()

local gameObject

local blinkCover
local blinkText

local blinkInterval = 3
local blinkCountdown = 0

local init
local onBtnBlinkClick
local updateBlink

function init( ... )
	local btnBlink = LuaInterface.Find(gameObject, 'BtnBlink')
	LuaInterface.AddClick(btnBlink, onBtnBlinkClick)

	blinkCover = LuaInterface.Find(btnBlink, 'cover', 'Image')
	blinkText = LuaInterface.Find(btnBlink, 'Text', 'Text')
end

function onBtnBlinkClick( ... )
	if blinkCountdown > 0 then return end
	blinkCountdown = blinkInterval
	input.useBlink = true
end

function updateBlink( ... )
	if blinkCountdown == 0 then
		blinkCover.gameObject:SetActive(false)
		blinkText.text = '瞬移'
	else
		blinkCover.gameObject:SetActive(true)
		blinkCountdown = blinkCountdown - Time.deltaTime
		blinkCover.fillAmount = blinkCountdown / blinkInterval
		blinkText.text = math.ceil(blinkCountdown)
		if blinkCountdown < 0 then blinkCountdown = 0 end
	end
end

------------------------- unity callback ------------------
function awake(go)
	gameObject = go
end

function start( ... )
	init()
end

function update( ... )
	updateBlink()
end

function ondestroy( ... )
	-- body
end

function fixedupdate( ... )
	-- body
end

return _M