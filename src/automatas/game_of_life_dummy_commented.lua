--Note: Anything pre-fixed with "--" is a comment.
--Note: The way the different segments (the big blobs) of code are ordered is mostly just to keep it tidy,
--	and not snytactically-required.

------------------------------ Boilerplate ------------------------------
--Using different names than the classes themselves, to;
--	Simplify the API.
--	Decouple it from the code.
--	Make it more non-coder-friendly.

--A table holding window config paramaters, things like size, etc...
local windowConfig = {}

--A table holding paramters that are common to ALL cellular automata. Things like grid-size, etc...
local commons = {}

--A table holding all of the rules.
local rules = {}
--A table holding a bunch of pre-made functions useful for defining rules.
--Basically, a lot of places require a function as a value, to allow you to write your own logic however you want, giving you more power.
--	But also, to make it easier, I've pre-made a bunch of different "reasonably common" functions that you can use in those places, that you an pick from instead of having to make your own.
--TODO: Figure out a better name for this variable.
local premade = arg1

--An object with lots of pre-made functionality for designing GUI's specific to this application.
local gui = arg2
--The list of pre-defined widgets available. See [/conway/SmartController.lua] for a list of what's available.
local c = arg3

--A table that holds the colors to use for drawing the different states. Purely visual. Does not affect the simulation.
local colors = {}

------------------------------ Window Config ------------------------------
windowConfig = {
	w = 1150,							--Window width, in pixels.
	h = 1150,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	guiH = 600,							--Height of the GUI section of the window, in pixels.
}
--Note: The width/height of the grid section of the window is simply the remainder.
--	-> w - guiW and h - guiH
--Note: This is just the VIEW size of the grid. i.e. How big it looks on the screen.
--	This does not, in any way, effect the simulation itself. It's just a zoomed-in/out view.

------------------------------ Commons ------------------------------
commons = {
	gridW = 100,						--Width of the grid, in cells.
	gridH = 100,						--Height of the grid, in cells.
	seed = 10^9,						--[Optional] Seed for the RNG. Defaults to [12345678].
	generations = 15,					--[Optional] The number of generations to immediately compute after generation. Defaults to [0]. *
	outOfBOundsState = "alive",			--For cells near the edge of the grid; What state should anything outside the grid considered to be? Can either be a string with the name of a cell, or a function**.
	adjQuery = premade.HEX,				--[Semi-Optional] A function to use when fetching the adjacent-cells of a cell.***
	gridIterator = premade.TL_TO_BR,	--[fu$%#ng optional]]A function defining the order in which to iterate over the grid.
}

--* Zero means that not a single step will be computed, and the world will simply show its initial configuration.

--** A function in the form of; function(x, y, inquier, ix, iy)
--		@param x		;	number	;	The (supposed) x-coord of the out-of-bounds-cell being checked.
--		@param x		;	number	;	The (supposed) y-coord of the out-of-bounds-cell being checked.
--		@param inquier	;	string	;	The state of the cell that is checking outside of bounnds.
--		@param ix		;	number	;	The x-coord of the inquier.
--		@param iy		;	number	;	The y-coord of the inquier.
--		@return state	;	string	;	A string representing what state should be considered in the out-of-bounds-cell.

--*** If that cell's state defines it's own [adjQuery], than that takes priority over this. If ALL state's have a defined [adjQuery] field, then this will never be used (and can be left nil).
------------------------------ Rules ------------------------------
--Declare a table that will hold all possible states.
rules.states = {}

---Rule set data.
rules.initialLivingPercentage = 0.4
rules.survive = {min = 3, max = 5}
rules.born = {3}

--Called once for every cell in the grid, when the simulation is first created.
--Aka; this is where the logic to create the initial configuration goes.
function rules.generate(x, y)
	if math.random() > rules.initialLivingPercentage then
		return "dead"
	else
		return "alive"
	end
end

---States

--Starting off with out first state, "alive", we declare a table that holds all data and logic for that state.
rules.states.alive = {
	
	--Called everytime a generation is iterated.
	update = function(self, rules, world, adj, countedAdj, generation)
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
	