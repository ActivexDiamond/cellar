# Cellar
A Cellular Automata simulation and creation framework. 

Use a light but powerful templating-API to define your automatons. 

It also comes with a graphical param-editor (Similar to Unity's component editor, but **much** smaller) that can be used by utilizing a number of simplified-GUI-widgets that it exposes. You can also write your own widgets by extending the Base (blank) widget.

# TODO
- Proper docs!

# Example: Hello World
```lua
------------------------------ Window Config ------------------------------
--Editor title.
title = "Hello, world!"
--A table holding window config paramaters, things like size, etc...
windowConfig = {
	w = 1080,							--Window width, in pixels.
	h = 720,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	guiH = 720,							--Height of the GUI section of the window, in pixels.
}

commons = {
	gridW = 100,						
	gridH = 100,						
	outOfBoundsState = "empty",			
	adjQuery = premade.aHex,				--`premade` is a table holding some functions that provide commonly-used behavior.
}

---Ruleset data/params.
rules.humanOdds = 0.2
rules.zombieOdds = 0.4

function rules:generate(x, y)
	local rng = math.random()
	if rng <= self.humanOdds then
		return "human"
	elseif rng <= self.zombieOdds then
		return "zombie"
	end

	return "empty"
end

--Starting off with our first state, "human", we declare a table that holds all data and logic for that state.
rules.states.human = {
	--Called once when the cell is first created (called after the cell has already been decided to be this state).
	--	To define the logic for what states what cells are initialized into, use `rules.generate`.
	init = function(self, x, y, generation)
		self.health = 5
	end,
	
	--Called everytime a generation is iterated.
	update = function(self, rules, adj, countedAdj, generation)
		local zombies = countedAdj.zombie
		--Get bitten once by every zombie around!
		self.health = self.health - zombies
		if self.health <= 0 then
			--By returning a string equal to the name of ANOTHER state, this cell will switch to that state.
			--Any following return values will be passed into the new cell's `init`.
			return "zombie"
		end
		--By returning nil, this cell will NOT change.
		return nil
	end,
}

rules.states.zombie = {
	init = function(self, x, y, generation)
		self.hunger = 5
	end,
	
	update = function(self, rules, adj, countedAdj, generation)
		local humans = countedAdj.human
		--Zombies starve if no one is around!
		if humans == 0 then
			self.hunger = self.hunger - 1
		end
		if self.hunger == 0 then
			return "empty"
		end
		return nil
	end,
}

rules.states.empty = {
	update = function(self, rules, adj, countedAdj, generation)
		local humans = countedAdj.human
		local zombies = countedAdj.zombie
		--Repopulation.
		if humans > 3 and humans > zombies then
			return "human"
		end
		return nil
	end,
}

------------------------------ GUI ------------------------------
--Add some common stuff like grid-resizing, screenshot, etc...
premade.gcAll(controller)

gui:addControl("humanOdds", c.SLIDER)
gui:addControl("zombieOdds", c.SLIDER, {max = 0.5})
gui:addControl("generations", c.BUTTON_STEPPER, {min = 0, max = 250})
	
--Just used for drawing. Key should be the same as the keys (`name`s) used above.
colors = {
	empty = {1, 1, 1},
	human = {0, 0, 1},
	zombie = {0, 1, 0},
}
```

# Example: Conway's Game Of Life
```lua
------------------------------ Window Config ------------------------------
--A table holding window config paramaters, things like size, etc...
windowConfig = {
	w = 1150,								--Window width, in pixels.
	h = 1150,								--Window height, in pixels.
	guiW = 350,								--Width of the GUI section of the window, in pixels.
	guiH = 600,								--Height of the GUI section of the window, in pixels.
}
--Note: The width/height of the grid section of the window is simply the remainder.
--	-> w - guiW and h - guiH
--Note: This is just the VIEW size of the grid. i.e. How big it looks on the screen.
--	This does not, in any way, effect the simulation itself. It's just a zoomed-in/out view.

------------------------------ Commons ------------------------------
--A table holding paramters that are common to ALL cellular automata. Things like grid-size, etc...
commons = {
	gridW = 100,							--Width of the grid, in cells.
	gridH = 100,							--Height of the grid, in cells.
	seed = 10^9,							--[Optional] Seed for the RNG. Defaults to [42].
	generations = 15,						--[Optional] The number of generations to immediately compute after generation. Defaults to [0]. *
	outOfBOundsState = "alive",				--For cells near the edge of the grid; What state should anything outside the grid considered to be? Can either be a string with the name of a cell, or a function**.
	adjQuery = premade.aHex,				--[Semi-Optional] A function to use when fetching the adjacent-cells of a cell.***
	gridIterator = premade.iLeftRightDown,	--[Optional] A function defining the order in which to iterate over the grid.
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
--A table holding all of the rules of your automaton.
rules = {}

--A table of valid states in your automaton.
--They keys should be descriptive-strings acting as the `name` of each state, but can be whatever you want.
rules.states = {}

---Ruleset data/params.
rules.initialLivingPercentage = 0.4
rules.survive = {min = 3, max = 5}
rules.born = {min = 3, max = 3}

--Called once for every cell in the grid, when the simulation is first created.
--Aka; this is where the logic to create the initial configuration goes.
function rules:generate(x, y)
	if math.random() > self.initialLivingPercentage then
		return "dead"
	else
		return "alive"
	end
end

------------------------------ States ------------------------------
--Starting off with our first state, "alive", we declare a table that holds all data and logic for that state.
rules.states.alive = {
	--Called everytime a generation is iterated.
	update = function(self, rules, adj, countedAdj, generation)
		--Below is some example logic.
		local aliveCount = countedAdj.alive
		local min = rules.survive.min
		local max = rules.survive.max
		if aliveCount < min or aliveCount > max then
			--By returning a string equal to the name of ANOTHER state, this cell will switch to that state.
			--Any following return values will be passed into the new cell's `init`.
			return "dead"
		end
		--By returning nil, this cell will NOT change.
		return nil
	end,
	
	--Called once when the cell is first created (called after the cell has already been decided to be this state).
	--	To define the logic for what states what cells are initialized into, use `rules.generate`.
	init = function(self)
		print("I have been born.")
	end,
}

--Same stuff here.
rules.states.dead = {
	update = function(self, rules, world, adj, countedAdj, generation)
		if countedAdj.alive == rules.born then
			return "alive"
		end
		return nil
	end,
	
	init = function(self)
	
	end,
}



------------------------------ GUI ------------------------------
gui:addControl("outOfBoundsState", c.CHECKBOX)
gui:addControl("initialLivingPercentage", c.SLIDER, {step = 2})
gui:addControl("generations", c.BUTTON_STEPPER, {steps = {5, 1}, min = 0, max = 250})
gui:addControl("survive", c.CHECKBOX_LIST, {count = 8})
gui:addControl("born", c.CHECKBOX_LIST, {count = 8})
	
--Just used for drawing. Key should be the same as the keys (`name`s) used above.
colors = {
	alive = {0, 0, 0},	
	dead = {255, 255, 255},
}
	
```
