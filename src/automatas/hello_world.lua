commons = {
	gridW = 100,						
	gridH = 100,						
	outOfBOundsState = "empty",			
	adjQuery = premade.HEX,				--`premade` is a table holding some functions that provide commonly-used behavior.
}

--A table holding all of the rules of your automaton.
rules = {}

--A table of valid states in your automaton.
rules.states = {}

---Ruleset data/params.
rules.humanOdds = 0.2
rules.zombieOdds = 0.4

function rules:generate(x, y)
	local rng = math.random()
	if rng >= self.humanOdds then
		return "human"
	elseif rng >= self.zombieOdds then
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
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
		local zombies = countedNeighbors.zombie
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
	
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
		local humans = countedNeighbors.humans
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
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
		local humans = countedNeighbors.humans
		local zombies = countedNeighbors.zombies
		--Repopulation.
		if humans > 3 and humans > zombies then
			return "human"
		end
		return nil
	end,
}

------------------------------ GUI ------------------------------
gui:addControl("outOfBoundsState", c.RADIO, {rules.states})
gui:addControl("humanOdds", c.SLIDER)
gui:addControl("zombieOdds", c.SLIDER, {max = 0.5})
gui:addControl("generations", c.BUTTON_STEPPER, {min = 0, max = 250})
	
--Just used for drawing. Key should be the same as the keys (`name`s) used above.
colors = {
	empty = {1, 1, 1},
	human = {0, 0, 1},
	zombie = {0, 1, 0},
}