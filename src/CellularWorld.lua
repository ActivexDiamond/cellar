local class = require "libs.cruxclass"

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

------------------------------ Constructor ------------------------------
local CellularWorld = class("CellularWorld")
function CellularWorld:init(commons, rules)
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
end

------------------------------ Core API ------------------------------
function CellularWorld:update()
end

------------------------------ API ------------------------------
function CellularWorld:reset()
	--Reset state.
	self.generationCount = 0
	math.randomseed(self.seed)
	
	--Init grid.
	self.grid = generateGrid(self.gridW, self.gridH, self.outOfBoundsState)
	--Used to cache update mid-generation so the adjQuery and gridIterator do not get confused.
	self.bufferGrid = generateGrid(self.gridW, self.gridH, self.outOfBoundsState)
	
	for x, y, _ in self.gridIterator(self.grid) do
		local name, args = self:generate(x, y)
		local state = self:_newState(name, args)
		self.grid[x][y] = state
		self.bufferGrid[x][y] = state 
	end
	
	if self.generations > 0 then
		self:iterate(self.generations)
	end
	
end

function CellularWorld:iterate(count)
	self.generationCount = self.generationCount + 1
	
	for x, y, cell in self.gridIterator(self.grid) do
		local adj, countedAdj = self.adjQuery(self.states,self.grid, x, y)
		if cell.update then 
			local name, args = cell:update(self, adj, countedAdj, self.generationCount)
			--Actually have to set it back to `cell` in case of `nil` to keep buffer in sync.
			self.bufferGrid[x][y] = name and self:_newState(name, args) or cell
		end
	end	
	
	--Swap buffers.
	self.grid, self.bufferGrid = self.bufferGrid, self.grid
	
	--Tail-call implementations of the `count` param..
	if count and count > 0 then return self:iterate(count - 1) end
end

------------------------------ Internals ------------------------------
function CellularWorld:_newState(name, args)
	local state = cloneTable(self.states[name])
	state.name = name
	if state.init then state:init(unpack(args or {})) end
	return state
end

------------------------------ Debugging ------------------------------
function CellularWorld:dSetDrawTransform(opt)
	self.debug.x = opt.x or self.debug.x
	self.debug.y = opt.y or self.debug.y
	self.debug.w = opt.w or self.debug.w
	self.debug.h = opt.h or self.debug.h
end

function CellularWorld:dSetDrawColors(colors)
	--Fill any missing colors with random ones.
	for k, v in pairs(self.states) do
		if not colors[k] then
			colors[k] = {math.random(), math.random(), math.random(), 1}
		end
	end
	self.debug.colors = colors
end

function CellularWorld:dDraw(g2d)
	local t = self.debug
	local sx = t.w / self.gridW 
	--Disable to prevent potentil stretching.
	--TODO: Smarter scaling.
	g2d.push('all')
		g2d.translate(t.x, t.y)
		g2d.scale(sx)
		for x, y, cell in self.gridIterator(self.grid) do
			g2d.setColor(t.colors[cell.name])
			g2d.rectangle('fill', x, y, 4, 4)
		end
	g2d.pop()
end

------------------------------ Accessors ------------------------------
function CellularWorld:change(opt, reset)
	for k, v in pairs(opt) do
		print(k, v)
		self[k] = v
	end
	if reset then
		self:reset()
	end
end

return CellularWorld