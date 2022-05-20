------------------------------ Boilerplate ------------------------------
local windowConfig = {}

local commons = {}

local rules = {}
local premade = arg1

local gui = arg2
local c = arg3

local colors = {}

------------------------------ Window Config ------------------------------
title = "Template Automata"
windowConfig = {
	w = 1150,							--Window width, in pixels.
	h = 1150,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	guiH = 600,							--Height of the GUI section of the window, in pixels.
}

------------------------------ Commons ------------------------------
commons = {
	gridW = 100,						--[=100]Width of the grid, in cells.
	gridH = 100,						--[=100]Height of the grid, in cells.
	seed = 10^9,						--[=12345678] Seed for the RNG. Defaults to.
	generations = 15,					--[=0] The number of generations to immediately compute after generation.
	outOfBOundsState = "alive",			--For cells near the edge of the grid; What state should anything outside the grid considered to be? Can either be a string with the name of a cell, or a function**.
	adjQuery = premade.hex,				--[Semi-Optional] A function to use when fetching the adjacent-cells of a cell.***
	gridIterator = premade.leftRightDown,	--[=TL_TO_BR]]A function defining the order in which to iterate over the grid.
}

--** A function in the form of; function(x, y, inquier, ix, iy)
--		@param x		;	number	;	The (supposed) x-coord of the out-of-bounds-cell being checked.
--		@param x		;	number	;	The (supposed) y-coord of the out-of-bounds-cell being checked.
--		@param inquier	;	string	;	The state of the cell that is checking outside of bounnds.
--		@param ix		;	number	;	The x-coord of the inquier.
--		@param iy		;	number	;	The y-coord of the inquier.
--		@return state	;	string	;	A string representing what state should be considered in the out-of-bounds-cell.

--*** If that cell's state defines it's own [adjQuery], than that takes priority over this. If ALL state's have a defined [adjQuery] field, then this will never be used (and can be left nil).
------------------------------ Rules ------------------------------
rules.states = {}

rules.initialLivingPercentage = 0.4
rules.survive = {min = 3, max = 5}
rules.born = {3}

--Called once for every cell in the grid, when the simulation is first created.
--Aka; this is where the logic to create the initial configuration goes.
function rules:generate(x, y)
	if math.random() > self.initialLivingPercentage then
		return "dead"
	else
		return "alive"
	end
end

---States

--Starting off with out first state, "alive", we declare a table that holds all data and logic for that state.
rules.states.alive = {
	
	--Called everytime a generation is iterated.
	update = function(self, rules, adj, countedAdj, generation)
		--Below is some example logic.
		--These are basically just "shorthands" to make the code a little neater.
		local n = countedAdj.dead
		local min = rules.survive.min
		local max = rules.survive.max
		
		
		if n < min or n > max then
			--By returning a string equal to the name of ANOTHER state, this cell will switch to that state.
			return "dead"
		else
			--[nil] basically means nothing.
			--By returning nothing, this cell will NOT change.
			return nil
		end
	end,
	
	--Called once when the cell is first created (called after the cell has already been decided to be this state).
	--	To define the logic for what states what cells are initialized into, use [rules.generate].
	init = function(self, x, y, generation)
	
	end,
}

--Same stuff here.
rules.states.dead = {
	--Called everytime a generation is iterated.
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
		--No shorthands here as the code is short enough as is.
		if countedNeighbors == rules.born then
			return "alive"
		else
			return nil
		end
	end,
	
	--Called once when the cell is first created (called after the cell has already been decided to be this state).
	--	To define the logic for what states what cells are initialized into, use [rules.generate].
	init = function(self, x, y, generation)
	
	end,
}



------------------------------ GUI ------------------------------
--I've already explained how this works to you. I just changed the Syntax a bit to make it cleaner.

gui:addControl("outOfBoundsState", c.CHECKBOX)
gui:addControl("initialLivingPercentage", c.SLIDER, {step = 2})
gui:addControl("generations", c.BUTTON_STEPPER, {steps = {5, 1}, min = 0, max = 250})
gui:addControl("survive", c.CHECKBOX_LIST, {count = 8})
gui:addControl("born", c.CHECKBOX_LIST, {count = 8})
	
--The colors of the states.
colors = {
alive = {0, 0, 0},	
	dead = {255, 255, 255},
}
	