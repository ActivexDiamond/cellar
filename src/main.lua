------------------------------ Dependencies ------------------------------
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
local selected_automata = "automatas.hello_world"

------------------------------ Core API ------------------------------
local stateManager;
function love.load()
	--Slab init.
	Slab.SetINIStatePath(nil)
	Slab.Initialize()
	
	stateManager = stateManager(selected_automata)
end

function love.update(dt)
	Slab.Update(dt)
	stateManager:update(dt)
end

function love.draw()
	local g2d = love.graphics
	Slab.Draw()
	stateManager:draw(g2d)	--probably wont have this
end



