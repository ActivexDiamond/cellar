------------------------------ Dependencies ------------------------------
local lovebird = require "libs.lovebird"
lovebird.update()
local utils = require "libs.utils"
local Slab = require "libs.Slab"

local StateManager = require "StateManager"

--local World = require "examples.games.conway.CellularWorldGenerator"
--local SmartController = require "examples.games.conway.SmartController"

--controller:addControl("size", c.BUTTON_STEPPER, {steps = {256, 64, 8}, min = 0})
--controller:addControl("Screenshot", c.ACTION_BUTTON, {f = function() 
--	love.graphics.captureScreenshot(os.date("%Y-%m-%d @%HH-%MM-%Ss") .. ".png")
--end})	
--controller:addControl("seed", c.RANDOMIZE, {max = 1e9})

------------------------------ Config ------------------------------

--local selected_automata = "automatas/hello_world.lua"
--local selected_automata = "automatas/game_of_life.lua"
--local selected_automata = "automatas/covid/covid1.lua"
--local selected_automata = "automatas/quick_icon.lua"
local selected_automata = "automatas/fluid-dynamics/core.lua"

------------------------------ Core API ------------------------------
--TEMP: Should be more thoughtful of font mangement.
local robotoMonoFont;
local stateManager;
function love.load()
	lovebird.updateinterval = 0.001

	print("Running Lua version:\t" .. _VERSION)
	print("Running Love2D version:\t" .. love.getVersion())
	--Slab init.
	Slab.SetINIStatePath(nil)
	Slab.Initialize()

	robotoMonoFont = love.graphics.newFont("assets/fonts/roboto_mono/RobotoMono-Regular.ttf")
	Slab.PushFont(robotoMonoFont)
		
	stateManager = StateManager(selected_automata)
end

function love.update(dt)
	lovebird.update()
	Slab.Update(dt)
	stateManager:update(dt)
end

function love.draw()
	local g2d = love.graphics
	
	Slab.Draw()
	stateManager:draw(g2d)
end

