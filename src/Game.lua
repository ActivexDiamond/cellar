local utils = require "libs.utils"

local Slab = require "libs.Slab"

local World = require "examples.games.conway.CellularWorldGenerator"
local SmartController = require "examples.games.conway.SmartController"

local automatas = {
	classes = {},
	names = {},
	objects = {},
	active = 1,
	activeName = "",
}
do
	local files, snFiles = utils.listFiles("examples/games/conway/automatas")
	print(files, #files)
	for k, v in ipairs(files) do
		local class = require(v:sub(1, -5))
		table.insert(automatas.classes, class)
		table.insert(automatas.names, class.__name__:sub(3))
	end	
end

local controller, activeAutomata;
local windowStats = {
	windowW = 1150,
	windowH = 600,
	configW = 350,
	configH = 600,
	worldW = 800,
	worldH = 600,
}
love.window.setMode(1150, 600)

local SW, SH = love.window.getMode()
local function commonControls(world, controller, group)
	local c = controller.Controls
	
	--global
	controller:setGroup(group)
	controller:setTarget(automatas)
	controller:setUpdateFunc(function (varName, newVal, oldVal, target)
		target[varName] = newVal
		target.activeName = target.names[target.active]
	end)		
	
	controller:addControl("active", c.BUTTON_STEPPER, {min = 1, max = #automatas.classes})
	controller:addControl("activeName", c.LABEL)
	--common
	controller:setGroup(group)
	controller:setTarget(world)
	controller:setUpdateFunc(function (varName, newVal, oldVal, target)
		if varName == "iterate" then
			target:iter()
		else
			target:generate({
				[varName] = newVal
			})
		end
	end)	
	
	controller:addControl("size", c.BUTTON_STEPPER, {steps = {256, 64, 8}, min = 0})
	controller:addControl("Screenshot", c.ACTION_BUTTON, {f = function() 
		love.graphics.captureScreenshot(os.date("%Y-%m-%d @%HH-%MM-%Ss") .. ".png")
	end})	
	controller:addControl("seed", c.RANDOMIZE, {max = 1e9})
end

function love.load()
	--Slab init.
	Slab.SetINIStatePath(nil)
	Slab.Initialize()
	
	--Controller config.
	local windowConfig = {
		x = 0,
		y = 0,
		w = windowStats.configW,
		h = windowStats.configH,
	}	
	--World Config
	local worldDrawConfig = {
		x = windowStats.configW,
		y = 0,
		w = windowStats.worldW,
		h = windowStats.worldH,
		colors = {
			[true] = {.3, .3, .3, 1},
			[false] = {1, 1, 1, 1},
		}
	}

	local worldConfig = {
		size = math.floor(windowStats.worldW / 8),
		seed = 1e9,
		
		survive = 	{[3] = true, [4] = true},
		born = 		{[4] = true, [5] = true, [6] = true, [7] = true, [8] = true},
		generations = 4,
		initialLivingPercentage = 0.4,
	} 
	
	--Controller init.
	controller = SmartController("Cellular Cave Generator", windowConfig)
	

	
	--World init.
	for k, v in ipairs(automatas.classes) do
		local world = World()
		world:dSetDrawConfig(worldDrawConfig)
		world:generate(worldConfig)
		commonControls(world, controller, world)
		automatas.objects[k] = v(world, controller)
	end
		
	automatas.active = 1
	automatas.activeName = automatas.names[1]
end

function love.update(dt)
	Slab.Update(dt)
	automatas.objects[automatas.active]:update(dt)
	controller:update(dt)
end

function love.draw()
	local g2d = love.graphics
	Slab.Draw()
	automatas.objects[automatas.active]:draw(g2d)
end



