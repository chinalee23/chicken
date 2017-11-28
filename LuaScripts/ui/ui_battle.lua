local sui = ecs.Single.ui
local input = require 'battle.input'
local BTN = require 'ui.btn'

local _M = module()

local gameObject
local txtTroopCount

local btns = {}
local btnMap
local switchStatus = 'off'
local energy = 100
local accelerating = false
local accelerateTime = 0
local rootSpeed
local imgSpeed

local init
local initHpbar
local initCamera
local initDamage
local addBtn
local onBtnBlinkClick
local updateBtns
local updateAccelerate
local printMap

function init( ... )
	-- addBtn('BtnBlink', '瞬移', 3, 'blink')
	-- addBtn('BtnAccelerate', '加速', 3, 'accelerate')
	-- addBtn('BtnSlowdown', '减速', 3, 'slowdown')
	-- addBtn('BtnHighcamera', '拉高', 0, 'highcamera')
	-- addBtn('BtnLowcamera', '降低', 0, 'lowcamera')

	texTroopCount = LuaInterface.Find(gameObject, 'TextTroopCount', 'Text')

	local btnTime = LuaInterface.Find(gameObject, 'BtnTime')
	LuaInterface.AddClick(btnTime, function ( ... )
		local world = require 'battle.world'
		for k, v in pairs(ecs.Sys) do
			log.info(k, v.frameCalcTime)
		end
	end)

	local btnNet = LuaInterface.Find(gameObject, 'BtnNet')
	LuaInterface.AddClick(btnNet, function ( ... )
		local game = require 'game'
		log.info('max', game.frameMaxInterval)
		log.info('last', game.frameLastInterval)
	end)

	local btnSwitch = LuaInterface.Find(gameObject, 'BtnSwitch')
	LuaInterface.AddClick(btnSwitch, function ( ... )
		local cover = LuaInterface.Find(btnSwitch, 'cover')
		local text = LuaInterface.Find(btnSwitch, 'Text', 'Text')
		if switchStatus == 'on' then
			switchStatus = 'off'
			cover:SetActive(true)
			text.text = '开启\n远程'
			input.attType = 'jinzhan'
		else
			switchStatus = 'on'
			cover:SetActive(false)
			text.text = '关闭\n远程'
			input.attType = 'yuancheng'
		end
	end)

	local btnAccelerate = LuaInterface.Find(gameObject, 'BtnAccelerate')
	LuaInterface.AddEvent(btnAccelerate, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown, function ( ... )
		if accelerating then return end
		accelerating = true
		if energy > 0 then
			log.info('on accelerate')
			input.accelerate = 'on'
		end
	end)
	LuaInterface.AddEvent(btnAccelerate, CS.UnityEngine.EventSystems.EventTriggerType.PointerUp, function ( ... )
		if not accelerating then return end
		accelerating = false
		input.accelerate = 'off'
		log.info('off accelerate')
	end)
	-- LuaInterface.AddClick(btnAccelerate, function ( ... )
	-- 	if accelerating then
	-- 		accelerating = false
	-- 		log.info('off accelerate')
	-- 		input.accelerate = 'off'
	-- 	else
	-- 		accelerating = true
	-- 		if energy > 0 then
	-- 			input.accelerate = 'on'
	-- 		end
	-- 	end
	-- end)
	rootSpeed = LuaInterface.Find(gameObject, 'Speed')
	imgSpeed = LuaInterface.Find(rootSpeed, 'foe', 'Image')

	-- btnMap = LuaInterface.Find(gameObject, 'Debug/BtnMap')
	-- LuaInterface.AddClick(btnMap, printMap)

	initHpbar()
	initCamera()
	initDamage()
end

function initHpbar( ... )
	sui.hpbarRoot = LuaInterface.Find(gameObject, 'HpRoot')
	sui.hpbarPrefab = LuaInterface.Find(sui.hpbarRoot, 'HpBar')
	sui.hpbarPrefab:SetActive(false)
end

function initCamera( ... )
	sui.uiCamera = LuaInterface.Find(gameObject, 'UICamera')
end

function initDamage( ... )
	sui.damageRoot = LuaInterface.Find(gameObject, 'DamageRoot')
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

function updateAccelerate( ... )
	local now = Time.time
	if now - accelerateTime < 1 then return end
	accelerateTime = now

	if accelerating then
		rootSpeed:SetActive(true)
		energy = math.max(energy - 10, 0)
		imgSpeed.fillAmount = energy / 100
		if energy == 0 then
			accelerating = false
			input.accelerate = 'off'
			log.info('off accelerate')
		end
	else
		rootSpeed:SetActive(false)
		energy = math.min(energy + 5, 100)
	end
end

function printMap( ... )
	local Vector2 = require 'math.vector2'
	local txt = LuaInterface.Find(btnMap, 'TxtPos', 'Text')
	local map = ecs.Single.map
	local key = map:findCloestInRangeByKey(tonumber(txt), 2)
	if key then
		log.info('key', key)
	else
		log.info('no key', map:getKey(key))
	end
end

local csInput = CS.UnityEngine.Input
local keyCode = CS.UnityEngine.KeyCode
function updateInput( ... )
	if csInput.GetKey(keyCode.W) then
		input.direction.x = 0
		input.direction.y = 1
	elseif csInput.GetKey(keyCode.S) then
		input.direction.x = 0
		input.direction.y = -1
	elseif csInput.GetKey(keyCode.A) then
		input.direction.x = -1
		input.direction.y = 0
	elseif csInput.GetKey(keyCode.D) then
		input.direction.x = 1
		input.direction.y = 0
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
	updateInput()
	updateAccelerate()
end

function ondestroy( ... )
	-- body
end

function fixedupdate( ... )
	-- body
end

return _M