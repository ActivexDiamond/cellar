local class = require "libs.middleclass"
local lovebird = require "libs.lovebird"

local utils = require "libs.utils"

local premade = require "premade"

------------------------------ Local Constants ------------------------------
local DEFAULT_COMMONS = {
	gridW = 100,
	gridH = 100,
	seed = 12345678,
	generations = 0,
	--outOfBoundsState = nil,
	--adjQuery = nil
	gridIterator = premade.iLeftRightDown,
}

---Rules
local DEFAULT_RULES = {
}

------------------------------ Helpers ------------------------------
--Creates a blank grid.
local gridMetatable = {__index = function(t, k)
	return {name = t.outOfBoundsState} 
end}

local function generateGrid(w, h, outOfBoundsState)
	local grid = setmetatable({outOfBoundsState = outOfBoundsState}, gridMetatable)
	for x = 1, w do
		grid[x] = {}
		for y = 1, h do
			grid[x][y] = {}
		end
	end
	
	return grid
end

local function cloneTable(t)
	local tc = {}
	for k, v in pairs(t) do
		tc[k] = v
		--If anything there was a table, it SHOULD be static.
		--tc[k] = type(v) == 'table' and cloneTable(v) or v
	end
	return tc
end

local function selfWrap(self, ...)
	local args = {...}
	assert(#args > 0, "No functions to wrap.")
	
	local funcs = {}
	for _, f in ipairs(args) do
		funcs[#funcs + 1] = function(...)
			return f(self, ...)
		end
	end
	return unpack(funcs)
end
------------------------------ Constructor ------------------------------
local CellularWorld = class("CellularWorld")
function CellularWorld:initialize(commons, rules)
	--Init defaults.
	self:change(DEFAULT_COMMONS)
	self:change(DEFAULT_RULES)
	
	--Init constructor params.
	--Done second so they take precedence over the defaults.
	self:change(commons or {})
	self:change(rules or {})
	
	--Debugging
	self.debug = {
		x = 0,
		y = 0,
		w = love.graphics.getWidth(),
		h = love.graphics.getHeight(),
	}
	
	--FIXME: Put this somewhere better.
	function love.keypressed(key, scancode, isrepeat)
		if key == 'escape' then
			love.event.quit()
		elseif key == 'space' then
			self:iterate()
		elseif key == 'backspace' then
			self:change({
				generations = self.generationCount - 1
			}, true)
		end
	end
end

------------------------------ Core API ------------------------------
function CellularWorld:update()
end

------------------------------ API ------------------------------
function CellularWorld:reset()
	local start = love.timer.getTime()
	--Reset state.
	self.generationCount = 0
	math.randomseed(self.seed)
	
	--Init grid.
	self.grid = generateGrid(self.gridW, self.gridH, self.outOfBoundsState)
	--Used to cache update mid-generation so the adjQuery and gridIterator do not get confused.
	self.bufferGrid = generateGrid(self.gridW, self.gridH, self.outOfBoundsState)
	
	if self.generateAll then
		--TODO: Should the last param be removed and newState made public, 
		--	as self is passed in anyways?
		self:generateAll(selfWrap(self, self._setCell, self._newState))
	elseif self.generate then
		for x, y, _ in self.gridIterator(self.grid) do
			local name, args = self:generate(x, y)
			local state = self:_newState(name, args)
			self:_setCell(x, y, state)
		end
	else
		error "No generator-function given!"
	end
	
	if self.generations > 0 then
		self:iterate(self.generations)
	end
	
	local dur = love.timer.getTime() - start
	local str = "Resetting up to `%d` generations took: %fs" 
	print(str:format(self.generations, dur))
end

function CellularWorld:iterate(count)
	self.generationCount = self.generationCount + 1
	
	if self.generationCount < self.generations then
		local str = "Simulating generation...\t\t[%d/%d]"  
		print(str:format(self.generationCount, self.generations))
	else
		local str = "Simulating generation...\t\t[%d]"
		print(str:format(self.generationCount))
	end
	--TODO: Wrap `iterate` in a proper coroutine so it dosn't block everything!
	lovebird.update()
	
	
	for x, y, cell in self.gridIterator(self.grid) do
		if cell.update then 
			local adj, countedAdj = self.adjQuery(self.states,self.grid, x, y)
			--TODO: Replace this with proper arg-catching.
			local name, a, b,  c, d = cell:update(adj, countedAdj, self.generationCount)
			--Actually have to set it back to `cell` in case of `nil` to keep buffer in sync.
			local val = name and self:_newState(name, a, b,  c, d) or cell
--			print("update", cell, name, a, b, x, y, val)
			self.bufferGrid[x][y] = val
		else
			self.bufferGrid[x][y] = cell
		end 
	end	
	
	--Swap buffers.
	self.grid, self.bufferGrid = self.bufferGrid, self.grid
	
	--Tail-call implementations of the `count` param..
	if count and count > 1 then return self:iterate(count - 1) end
end

------------------------------ Internals ------------------------------
function CellularWorld:_setCell(x, y, state)
	--Only use during initial generation as this does NOT respect buffer-swapping!!!
	--TODO: Move this to `_newState`, somehow.
	state.x = x
	state.y = y
	
	self.grid[x][y] = state
	self.bufferGrid[x][y] = state
end

function CellularWorld:_newState(name, ...)
	local inst = self.states[name](self, ...)
	--TODO: Better design on the name field.
	inst.name = inst.class.name
	return inst
end

------------------------------ Debugging ------------------------------
function CellularWorld:dSetDrawTransform(opt)
	self.debug.x = opt.x or self.debug.x
	self.debug.y = opt.y or self.debug.y
	self.debug.w = opt.w or self.debug.w
	self.debug.h = opt.h or self.debug.h
	
	print(self.debug.w, self.debug.h)
end

function CellularWorld:dSetDrawColors(colors)
	--Fill any missing colors with random ones.
	print("=> Echoing `debugDraw` colors.")
	for k, v in pairs(self.states) do
		if not colors[k] then
			colors[k] = {math.random(), math.random(), math.random(), 1}
		end
		print(k, unpack(colors[k]))
	end
	self.debug.colors = colors
end

function CellularWorld:dDraw(g2d)
	--FIXME: Magic number.
	local W = 4
	
	local t = self.debug
	local scale
	--FIXME: Scaling doesn't work correctly.
	if true then
		scale = t.w / self.gridW
	else
		scale = t.h / self.gridH
	end
	 
	--Disable to prevent potentil stretching.
	--TODO: Smarter scaling.
	g2d.push('all')
		g2d.translate(t.x, t.y)
		g2d.scale(scale)
		for x, y, cell in self.gridIterator(self.grid) do
			g2d.setColor(t.colors[cell.name] or {0.5, 0.5, 0.2, 1})
			g2d.rectangle('fill', x, y, W, W)
		end
	g2d.pop()
end

------------------------------ Accessors ------------------------------
function CellularWorld:change(opt, reset)
	local doTime = false
	for k, v in pairs(opt) do
		self[k] = v
	end
	
	if reset then
		self:reset()
	end
end

return CellularWorld