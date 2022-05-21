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
	gridW = 300,						
	gridH = 580,	
	generations = 5,					
	outOfBoundsState = "empty",			
	adjQuery = premade.aHex,				--`premade` is a table holding some functions that provide commonly-used behavior.
}

---Ruleset data/params.
rules.humanOdds = 0.2
rules.zombieOdds = 0.4

rules.path = "automatas/covid/uni_floor_g.png"
rules.legend = {
	empty = {1, 1, 1, 0},
	wall = {0, 0, 0},
	
	human = {0, 0, 1},
	zombie = {0, 1, 0},
}
rules.generateAll = premade.maFromImage

--function rules.generate()
--	return "wall"
--end

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

rules.states.wall = {
}

------------------------------ GUI ------------------------------
--Add some common stuff like grid-resizing, screenshot, etc...
premade.gcAll(gui)

gui:addControl("humanOdds", c.SLIDER)
gui:addControl("zombieOdds", c.SLIDER, {max = 0.5})

--Just used for drawing. Key should be the same as the keys (`name`s) used above.
colors = {
	empty = {1, 1, 1, 1},
	wall = {0, 0, 0, 1},
	
	human = {0, 0, 1, 1},
	zombie = {0, 1, 0, 1},
}