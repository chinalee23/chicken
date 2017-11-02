local input = require 'battle.input'
local BTN = require 'ui.btn'

local _M = module()

local gameObject

local btns = {}

local init
local onBtnBlinkClick
local updateBtns

function init( ... )
	local go = LuaInterface.Find(gameObject, 'BtnBlink')
	local btn = BTN.new(go, '瞬移', 3, 'blink')
	table.insert(btns, btn)
	
	local go = LuaInterface.Find(gameObject, 'BtnAccelerate')
	local btn = BTN.new(go, '加速', 2, 'accelerate')
	table.insert(btns, btn)

	local go = LuaInterface.Find(gameObject, 'BtnSlowdown')
	local btn = BTN.new(go, '减速', 2, 'slowdown')
	table.insert(btns, btn)

	local go = LuaInterface.Find(gameObject, 'BtnHighcamera')
	local btn = BTN.new(go, '拉高', 0, 'highcamera')
	table.insert(btns, btn)

	local go = LuaInterface.Find(gameObject, 'BtnLowcamera')
	local btn = BTN.new(go, '降低', 0, 'lowcamera')
	table.insert(btns, btn)
end

function updateBtns( ... )
	for _, v in ipairs(btns) do
		v:update()
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
	updateBtns()
end

function ondestroy( ... )
	-- body
end

function fixedupdate( ... )
	-- body
end

return _M