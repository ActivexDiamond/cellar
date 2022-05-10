--[[
Usage:
	local gen = CellularWorldGenerator()		--Grab a world instance.
	gen:generate(dat)							--Reset the world and make it all over again,
												--Using 'dat' for configs.
												--The point of having a world instance, is that
												--any configs not passd into the current dat, will remain unaffected
												--(Uses the last non-nil value passed in.) (None of the configs accept nil.)
												--(If a config has never been passed, it will simply be equal to it's default value.)											
	
	gen:iterate(n = 1)								--Advance by n generations.
	gen:advance(dat)							--Update the world's configs and then process x more generations, using the new 
												--configs this time.	;	x = dat.generations or the last value passed for it.
	gen:iterate(dat)							--Shortcut for gen:advance({...	generations = 1,	...})

	TODO: Implement "advance" and "iterate(dat)"
	TODO: Make using the survive/born arrays a bit prettier by using a better form, adding syntactic sugar or both.
	TODO: Provide more gridSpawner options.
	TODO: Provide more getLivingNeighbors options.
	TODO: Implement a getNeighbors option and the ability to provide custom 'iterate' functions,
		which would open huge doors for making much more advanced forms of cells/rules.
	TODO: Custom world shapes/geometry (not just full rectangles),
		provide a few built-in ones and also functionality for providing custom ones.
	TODO: Move initialLivingPercentage into being inside a table for the "random" gridSpawner,
		so that similar vars for the other-todo gridSpawners can also be packed similary.
	
	Configs: Note: The defaults are setup to generate a pretty looking cave system.
		--The x/y params are used for overlaying different config-sets for different generations on top of each other.
		--E.g.: use (0,0 100, 100) for making a big blop of rock, 
		--then (30, 30, 70, 70) to dig out a cave system into the single rock.
		x = 0									--The start position of the world, not a particular unit.	;	{number}
		y = 0									--The start position of the world, not a particular unit.	;	{number}
		w = 100									--The width of the world, in cells.							;	{number}
		h = 100									--The width of the world, in cells.							;	{number}
		
		seed = os.time()						--The seed used by the random-based gridSpawners.			;	{number}
		
		initialLivingPercentage = 0.37			--Used by the random-based gridSpawners.					;	{number, from 0 to 1}
		generations = 4							--How many generations to initially process.				;	{number}

		survive = {0, 3}						--The rules for survival.									;	{An array, from 0 to 8, where each value is a bool}.
		born = {4 - 8}							--The rules for survival.									;	{An array, from 0 to 8, where each value is a bool}.
 
		gridSpawner = randomized				--The function used for generating the grid, if no grid was provided.
		->										--Called once-per-cell in grid of dims (dat.w, dat.h).		;	{function(gen, x, y)}
		
		getLivingNeighbors = 8-directional		--The function used for fetching the neighbors of a cell.	;	{function(gen, x, y)}
										
		
		grid = gridSpawner()					--The grid to be used. A pre-populated grid can be passed in. If none was provided,
		->										--One will be generated using the passed (or default) gridSpawner function.
		->										--Note that if a grid of an incorrect size is passed in, any missing cells will be initialized to false.
		->										--Note that the grid array should go from (x, y) to (x + w, y + h), and is in the form cell = grid[x][y].
		->										{array, where cell = grid[x][y], and (x, y) can go from (dat.x, dat.y) to (dat.x + dat.w, dat.y + dat.h)}  
--]]


return function()
	local self = {}
	------------------------------ Helpers ------------------------------
	function self:_copy(t2)
		local t1 = {}
		for k, v in pairs(t2) do
			if t2 ~= v and type(v) == 'table' then
				t1[k] = self:_copy(v)
			else
				t1[k] = v
			end
		end
		return t1
	end
	
	function self:_contains(t, val)
		for k, v in pairs(t) do
			if v == val then return true end
		end
		return false
	end
	
	------------------------------ Core Methods ------------------------------
	function self:generate(dat)
		dat = dat or {}
		--TODO: Implement those two.
		--self.viewW = dat.viewW or self.viewW or SW
		--self.viewH = dat.viewH or self.viewH or SH
		
		-- Basic vars
		self.x = dat.x or self.x or 0
		self.y = dat.y or self.y or 0
		self.w = dat.w or self.w or 100
		self.h = dat.h or self.h or 100
		self.size = dat.size or self.size or 0
		if self.size ~= 0 then
			self.w = self.size
			self.h = self.size
		end
		
		--Seed
		self.seed = dat.seed or self.seed or os.time()
		math.randomseed(self.seed)
		
		--Game configs
		self.initialLivingPercentage = dat.initialLivingPercentage or self.initialLivingPercentage or 0.37
		self.generations = dat.generations or self.generations or 4
		
		self.survive = dat.survive or self.survive	or {[0] = true, [3] = true}
		self.born = dat.born or self.born			or {[4] = true, [5] = true, [6] = true, [7] = true, [8] = true}
		if dat.outOfBoundsState ~= nil then
			self.outOfBoundsState = dat.outOfBoundsState
		elseif self.outOfBoundsState == nil then
			self.outOfBoundsState = true
		end
		
		--Generator and neighbor funcs.
		self.gridSpawner = dat.gridSpawner or self.gridSpawner or self.defaultGridSpawner
		self.getLivingNeighbors = dat.getLivingNeighbors or self.getLivingNeighbors or self.defaultGetLivingNeighbors
		
		if dat.grid then
			self.grid = dat.grid
			--Make sure all grid spots are actually valid, not nil. 
			--Make's sure the x-array is wide enough, 
			--and that the y-array is full of either true or false, no nil spots.
			if not self.grid then self.grid = {} end
			for x = self.x, self.x + self.w do
				if not self.grid[x] then self.grid[x] = {} end
				for y = self.y, self.y + self.h do
					if self.grid[x][y] == nil then self.grid[x][y] = false end
				end
			end
		else
			self.grid = {}
			for x = self.x, self.x + self.w do
				self.grid[x] = {}
				for y = self.y, self.y + self.h do
					self.grid[x][y] = self:gridSpawner(x, y)
				end
			end
		end
		
		self:iterate(self.generations)
	end
	
	---Single generation per call.
	function self:iterate(generations)
		for i = 1, generations do
			local newGrid = self:_copy(self.grid)
			for x = self.x, self.x + self.w do
				for y = self.y, self.y + self.h do
					local alive = self:getLivingNeighbors(x, y)
					if self.born[alive] then
						newGrid[x][y] = true
					elseif self.grid[x][y] and not self.survive[alive] then
						 newGrid[x][y] = false
					end
				end
			end
			self.grid = newGrid
		end
	end
	
	------------------------------ Default Spawners ------------------------------
	function self:defaultGridSpawner(x, y)
		return math.random() <= self.initialLivingPercentage
	end
	
	------------------------------ Default Border Getters ------------------------------
	function self:defaultGetLivingNeighbors(x, y)
		local alive = 0
		if self:getCell(x-1, y) then alive = alive + 1 end
		if self:getCell(x+1, y) then alive = alive + 1 end
		if self:getCell(x, y-1) then alive = alive + 1 end
		if self:getCell(x, y+1) then alive = alive + 1 end
		
		if self:getCell(x-1, y-1) then alive = alive + 1 end
		if self:getCell(x+1, y-1) then alive = alive + 1 end
		if self:getCell(x-1, y+1) then alive = alive + 1 end
		if self:getCell(x+1, y+1) then alive = alive + 1 end
		return alive	
	end

	------------------------------ Accessors ------------------------------
	function self:getCell(x, y)
		if x <= self.x or y <= self.y or x > self.x + self.w or y > self.y + self.h then
			return self.outOfBoundsState
		end
		return self.grid[x][y]
	end

	------------------------------ Debug Drawing ------------------------------
	function self:dSetDrawConfig(config)
		local sw, sh = love.window.getMode()
		
		self.dDrawConfig = {inv = {}}
		self.dDrawConfig.cellSize = config.cellSize or 2
		self.dDrawConfig.x = config.x or 0
		self.dDrawConfig.y = config.y or 0
		self.dDrawConfig.w = config.w or sw - self.window.w
		self.dDrawConfig.h = config.h or sh
		self.dDrawConfig.colors = config.colors or {}
		self.dDrawConfig.colorsFunc = self.dDrawConfig.colorsFunc or function(inv, state)
			if inv[state] then return inv[state] end
			local rng = math.random
			local r, g, b = rng(), rng(), rng()
			inv[state] = {r, g, b, 1}
			return inv[state]
		end
	end
	
	function self:dDraw(g2d)
		local config = self.dDrawConfig
		local cs = config.cellSize
		local scaleX = config.w / self.w / cs
		local scaleY = config.h / self.h / cs
		g2d.push('all')
			g2d.translate(config.x, config.y)
			g2d.scale(scaleX, scaleY)
			for x = self.x, self.x + self.w do
				for y = self.y, self.h + self.h do
					local state = self.grid[x][y]
					if state ~= nil then
						g2d.setColor(config.colors[state] or config.colorsFunc(config.inv, state))
						g2d.rectangle('fill', (x - 1) * cs, (y - 1) * cs, cs, cs)
					end
				end
			end
			g2d.setColor(1, 0, 0)
			g2d.rectangle('line', 0, 0, self.w * cs, self.h * cs)
		g2d.pop()	
	end

	return self	
end
