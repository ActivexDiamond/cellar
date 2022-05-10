local Slab = require 'libs.Slab'
local World = require 'examples.games.conway.CellularWorldGenerator'

Slab.SetINIStatePath(nil)
Slab.Initialize()

local windowStats = {
	windowW = 1150,
	windowH = 600,
	configW = 350,
	configH = 600,
	worldW = 800,
	worldH = 600,
}
love.window.setMode(windowStats.windowW, windowStats.windowH)

local SW, SH = love.window.getMode()

local function Controller(world)
	print("This class has been deprecated! Use `SmartController` instead.")
	local self = {}
	self.world = world
	
	--World Drawing Config
	self.worldDraw = {
		cellSize = 2,
		x = windowStats.configW,
		y = 0,
		livingColor = {0.3, 0.3, 0.3, 1},
		deadColor = {1, 1, 1, 1}
	}
		
	local window = {
		id = 'window',
		--Title = "Cellular Cave Generator",
		X = 0,
		Y = 0,
		W = windowStats.configW,
		H = windowStats.configH,
		
		AutoSizeWindow = false,
		AllowResize = false,
		AllowMove = false,
	}
	
	local header = {
		id = "                 +  Cellular Cave Generator  +",
		Align = 'center',						--broken?
	}
	
	local rules = {
		len = 8,								--including the zero-case
		survive = 	{[3] = true, [4] = true},
		born = 		{[4] = true, [5] = true, [6] = true, [7] = true, [8] = true},					
		label = {
			id = "Neighbors: 0    1     2    3    4    5     6    7    8", 
		},
		surviveLabel = {
			id = "Survive:\t",
		},
		bornLabel = {
			id = "Born:\t\t ",
		},
	}
	
	local generations = {
		stats = { 
			val = 4,
			min = 0,
			max = math.huge,
			step = 1,
			shiftStep = 4,
		},
		label = {
			id = "Generations: ",
		},
		buttons = {
			W = 25,
		},
		valDisplay = {
			W = 25,		--FIXME: Fixed text width doesn't work.
		},
	}
	
	local spawn = {
		stats = { 
			val = 0.4,
			min = 0,
			max = 1,
			step = 0.01,
			shiftStep = 0.05,
		},
		label = {
			id = "Spawn Chance: ",
		},
		buttons = {
			W = 25,
		},
		valDisplay = {
			W = 25,		--FIXME: Fixed text width doesn't work.
		},
	}
	
	local seed = {
		stats = {
			val = 1,
		},
		label = {
			id = "Seed: ",
		},
		button = {
			id = "Randomize",
		},
		valDisplay = {
		},
	}
	
	function self:update(dt)
		local change
		Slab.BeginWindow(window.id, window)
			--Header
			Slab.Text(header.id, header)
	
			--Rules
			Slab.Text(rules.label.id, rules.label)
			Slab.Text(rules.surviveLabel.id, rules.surviveLabel)
			Slab.SameLine()
			for i = 0, rules.len do
				if Slab.CheckBox(rules.survive[i]) then
					rules.survive[i] = not rules.survive[i]
					change = true
				end 
				Slab.SameLine()
			end
			Slab.NewLine()

			Slab.Text(rules.bornLabel.id, rules.bornLabel)
			Slab.SameLine()			
			for i = 0, rules.len do
				if Slab.CheckBox(rules.born[i]) then
					rules.born[i] = not rules.born[i]
					change = true
				end				
				Slab.SameLine()
			end
			Slab.NewLine()
				
			--Generations
			Slab.Text(generations.label.id, generations.label)
			Slab.SameLine()
			if Slab.Button("+", generations.buttons) then
				local step = love.keyboard.isDown('lshift') and generations.stats.shiftStep or generations.stats.step 
				generations.stats.val = math.min(generations.stats.val + step, generations.stats.max)
				change = true
			end
			Slab.SameLine()
			Slab.Text(generations.stats.val, generations.valDisplay)
			Slab.SameLine()
			if Slab.Button("-", generations.buttons) then
				local step = love.keyboard.isDown('lshift') and generations.stats.shiftStep or generations.stats.step
				generations.stats.val = math.max(generations.stats.val - step, generations.stats.min)
				change = true
			end

			--Spawn Probablity
			Slab.Text(spawn.label.id, spawn.label)
			Slab.SameLine()
			if Slab.Button("+", spawn.buttons) then
				local step = love.keyboard.isDown('lshift') and spawn.stats.shiftStep or spawn.stats.step
				spawn.stats.val = math.min(spawn.stats.val + step, spawn.stats.max)
				change = true
			end
			Slab.SameLine()
			Slab.Text(spawn.stats.val, spawn.valDisplay)
			Slab.SameLine()
			if Slab.Button("-", spawn.buttons) then
				local step = love.keyboard.isDown('lshift') and spawn.stats.shiftStep or spawn.stats.step
				spawn.stats.val = math.max(spawn.stats.val - step, spawn.stats.min)
				change = true
			end
			
			--Seed
			Slab.Text(seed.label.id, seed.label)
			Slab.SameLine()
			if Slab.Button(seed.button.id, seed.button) then
				seed.stats.val = math.random()
				change = true
			end
			Slab.SameLine()
			Slab.Text(seed.stats.val, seed.valDisplay)
			
		Slab.EndWindow()
		
		--Update
		if change then self:updateWorld() end
	end
	
	function self:updateWorld()
		local dat = {
			survive = rules.survive,
			born = rules.born,
			generations = generations.stats.val,
			initialLivingPercentage = spawn.stats.val,
			seed = seed.stats.val,
		}
		world:generate(dat)
	end
	
	function self:drawWorld(g2d)
		local world = self.world
		local cellSize = self.worldDraw.cellSize
		local scale = windowStats.worldW / world.w / cellSize
		g2d.push('all')
			g2d.translate(self.worldDraw.x, self.worldDraw.y)
			g2d.scale(scale)
			for x = world.x, world.x + world.w do
				for y = world.y, world.h + world.h do
					if world.grid[x][y] then
						g2d.setColor(self.worldDraw.livingColor)
					else
						g2d.setColor(self.worldDraw.deadColor)
					end
					g2d.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize, cellSize)
				end
			end
			g2d.setColor(1, 0, 0)
			g2d.rectangle('line', 0, 0, world.w * cellSize, world.h * cellSize)
		g2d.pop()	
	end
	
	return self
end

local world, controller;
function love.load()
	world = World()
	world:generate({
		w = math.floor(windowStats.worldW / 8),
		h = math.floor(windowStats.worldH / 8),
		seed = 1,
		
		survive = 	{[3] = true, [4] = true},
		born = 		{[4] = true, [5] = true, [6] = true, [7] = true, [8] = true},
		generations = 4,
		initialLivingPercentage = 0.4,
	})
	
	controller = Controller(world)
end
