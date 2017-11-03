local input = require 'battle.input'
local BTN = require 'ui.btn'

local _M = module()

local gameObject
local txtTroopCount

local btns = {}

local init
local addBtn
local onBtnBlinkClick
local updateBtns

function init( ... )
	addBtn('BtnBlink', '瞬移', 3, 'blink')
	addBtn('BtnAccelerate', '加速', 3, 'accelerate')
	addBtn('BtnSlowdown', '减速', 3, 'slowdown')
	addBtn('BtnHighcamera', '拉高', 0, 'highcamera')
	addBtn('BtnLowcamera', '降低', 0, 'lowcamera')

	texTroopCount = LuaInterface.Find(gameObject, 'TextTroopCount', 'Text')
end

function addBtn(goName, name, interval, inputName)
	local go = LuaInterface.Find(gameObject, goName)
	local btn = BTN.new(go, name, interval, inputName)
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