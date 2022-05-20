local class = require "libs.cruxclass"

local Checker = require "libs.Checker"

local premade = require "premade"

local SmartController = require "SmartController"
local CellularWorld = require "CellularWorld" 

------------------------------ Automata Environment ------------------------------
local _SANDBOXES_OS = {
	clock = os.clock,
	date = os.date,
	difftime = os.difftime,
	time = os.time,
}

local AUTOMATA_ENV = {
	--Lua metadata.
	_VERSION = _VERSION,
	
	--Basics
	print = print,
	type = type,
	tonumber = tonumber,
	tostring = tostring,
	
	
	--Lua control and loops.
	pairs = pairs,
	ipairs = ipairs,
	next = next,
	select = select,
	unpack = unpack,
	
	--Lua error handling.
	assert = assert,
	error = error,
	pcall = pcall,
	xpcall = xpcall,
	
	--Lua metatables.
	rawset = rawset,
	rawget = rawget,
	rawequal = rawequal,
	setmetatable = setmetatable,
	getmetatable = getmetatable,
	
	--Lua core libs.
	table = table,
	math = math,
	string = string,
	os = _SANDBOXES_OS,	--Only includes time-related functions!
	bit = bit,
		
	--Love.
	love = {
		audio = love.audio,
		graphics = love.graphics,
		image = love.image,
		joystick = love.joystick,
		keyboard = love.keyboard,
		math = love.math,
		mouse = love.mouse,
		physics = love.physics,
		sound = love.sound,
		timer = love.timer,						--TODO: Remove sleep.
		touch = love.touch,
		video = love.video,
		window = love.window,					--TODO: Remove mutating functions.
		
	},
	
	--Libs.
	Checker = Checker,
	
	--Automata-related.
	premade = premade
}

------------------------------ Helpers ------------------------------
local function copyTable(t1, t2)
	for k, v in pairs(t2) do
		if not t1[k] then
			t1[k] = v
		end
	end
end

local function updateFunc(varName, newVal, oldVal, target)
	local str = "Changing %s from %s to %s."
	print(str:format(varName, oldVal, newVal))
	target:change({[varName] = newVal}, true)
end

------------------------------ Locals ------------------------------
local AUTOMATA_ERROR = "An error was raised during execution of your automata.\nPath: %s.\nError: %s"

--CWD trick thanks to Kikito.
local CWD = (...):match("(.+)%.[^%.]+$") or (...)	

------------------------------ Constructor ------------------------------
local StateManager = class("StateManager")
function StateManager:init(automataPath)
	self:_loadAutomata(automataPath)
end

------------------------------ Core API ------------------------------
function StateManager:update(dt)
	self.controller:update(dt)
	self.world:update(dt)
end

function StateManager:draw(g2d)
	self.world:dDraw(g2d)
end

------------------------------ Internals ------------------------------
function StateManager:_loadAutomata(automataPath)
	--Grab state.
	self.world = CellularWorld()
	self.controller = SmartController()
	self.controller:setTarget(self.world)
	self.controller:setUpdateFunc(updateFunc)
	
	--Setup env.
	local env = {
		--Stateful API (static API is defined in AUTOMATA_ENV).
		gui = self.controller,
		c = self.controller.Controls,
		
		--Blanks (allows the userr to jump right into dot-syntax init.
		title = "",
		windowConfig = {},
		commons = {},
		colors = {},
		
		--Main
		rules = {states = {}},
	}
	copyTable(env, AUTOMATA_ENV)
	
	--Execute automata.
	
	local f, msg = love.filesystem.load(automataPath)
	assert(f, msg)
	setfenv(f, env)
	local succ, msg = pcall(f)
	assert(succ, AUTOMATA_ERROR:format(automataPath, msg))
	
	--Fetch results.
	if env.windowConfig.w and env.windowConfig.h then
		love.window.setMode(env.windowConfig.w, env.windowConfig.h)
	end
	self.controller:setConfig{w = env.windowConfig.guiW, h = env.windowConfig.guiH}

	self.controller:setHeaderText(env.title)
	
	self.world:change(env.commons)
	self.world:change(env.rules)
	self.world:reset()
	
	self.world:dSetDrawTransform{
		x = env.windowConfig.guiW,
		y = 0,
		w = env.windowConfig.w - env.windowConfig.guiW,
		h = env.windowConfig.h
	}
	self.world:dSetDrawColors(env.colors)
	
end

------------------------------ Getters / Setters ------------------------------

return StateManager
