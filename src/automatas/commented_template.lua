------------------------------ Window Config ------------------------------
title = "Blank Automata Template"
windowConfig = {
	w = 1150,							--Window width, in pixels.
	h = 1150,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	guiH = 600,							--Height of the GUI section of the window, in pixels.
}

------------------------------ Commons ------------------------------
commons = {
	gridW = 100,							--[=100]Width of the grid, in cells.
	gridH = 100,							--[=100]Height of the grid, in cells.
	seed = 10^9,							--[=12345678] Seed for the RNG. Defaults to.
	generations = 15,						--[=0] The number of generations to immediately compute after generation.
	outOfBoundsState = "Alive",				--For cells near the edge of the grid; What state should anything outside the grid considered to be? Can either be a string with the name of a cell, or a function**.
	adjQuery = premade.aHex,				--[Semi-Optional] A function to use when fetching the adjacent-cells of a cell.***
	gridIterator = premade.iLeftRightDown,	--[=TL_TO_BR]]A function defining the order in which to iterate over the grid.
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

------------------------------ States - Alive ------------------------------
--Starting off with out first state, "alive", we create class that holds all data and logic for that state.
rules.states.Alive = class("Alive")
	
--Called once when the cell is first created (called after the cell has already been decided to be this state).
--	To define the logic for what states what cells are initialized into, use [rules.generate].
function rules.states.Alive:initialize(rules)
	
end

--Called everytime a generation is iterated.
function rules.states.Alive:update(adj, countedAdj, generation)
	--Below is some example logic.
	--These are basically just "shorthands" to make the code a little neater.
	local n = countedAdj.Dead
	local min = rules.survive.min
	local max = rules.survive.max
	
	
	if n < min or n > max then
		--By returning a string equal to the name of ANOTHER state, this cell will switch to that state.
		return "Dead"
	end
	--[nil] basically means nothing.
	--By returning nothing, this cell will NOT change.
	return nil
end

------------------------------ States - Dead ------------------------------
--Same stuff here.
rules.states.Dead = class("Dead")

--Called once when the cell is first created (called after the cell has already been decided to be this state).
--	To define the logic for what states what cells are initialized into, use [rules.generate].
function rules.states.Dead:initialize(rules)
	
end

--Called everytime a generation is iterated.
function rules.states.Dead:update(adj, countedAdj, generation)
	--No shorthands here as the code is short enough as is.
	if countedAdj.Alive == rules.born then
		return "Alive"
	end
	return nil
end

------------------------------ GUI ------------------------------
premade.gcAll(gui)

------------------------------ Colors ------------------------------	
--The colors of the states.
colors = {
	Alive = {0, 0, 0},	
	Dead = {1, 1, 1},
}
	