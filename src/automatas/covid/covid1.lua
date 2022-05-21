------------------------------ Configs ------------------------------
love.filesystem.load("automatas/covid/boilerplate.lua")()
love.filesystem.load("automatas/covid/base.lua")()
love.filesystem.load("automatas/covid/modifiers.lua")()

--print("Covid | getfenv(0)", getfenv(0))
--print("Covid | getfenv(1)", getfenv(1))
--print("Covid | getfenv(2)", getfenv(2))
--print("Covid | getfenv(3)", getfenv(3))
--print("Covid | _G", _G)

------------------------------ Ruleset ------------------------------
---Ruleset data/params.
rules.humanOdds = 0.2
rules.zombieOdds = 0.4

print(commons.gridW, commons.gridH)

rules.path = "automatas/covid/uni_floor_g.png"
rules.legend = {
	empty = {0, 0, 0, 0},
	wall = {0, 0, 0, 1},
}

function rules:generateAll(set, new) 
	for x, y, pxState in premade.maFromImageIterator(self, set, new) do
		--print(x, y, pxState)
		if pxState == "wall" then
			set(x, y, new(pxState))
		elseif pxState == "empty" then
			local state = premade.hWeightedRandom(self.spawn)
			set(x, y, new(state, {}))
			
		else
			error "Invalid state gotten from map... How did that happene?"
		end
	end
end

--function rules:generateAll(set, new)
--	local imgData = love.image.newImageData(rules.path)
--	
--	local w, h = imgData:getDimensions()
--	print(w, h)
--	assert(w == self.gridW and h == self.gridH, "Image dimensions do not match grid dimensions!")
--	for x = 0, w - 1 do
--		for y = 0, h - 1 do
--			local px = {imgData:getPixel(x, y)}
--			local pxState = premade.hDecodePixel(px, rules.legend) 
--			if pxState == "wall" then
--				set(x, y, new(pxState))
--			elseif pxState == "empty" then
--				local state = premade.hWeightedRandom(self.spawn)
--				set(x, y, new(state, {}))
--			else
--				error "Invalid state gotten from map... How did that happene?"
--			end
--		end
--	end
--end


rules.states.wall = {
	init = function(self, x, y, generation)
	end,
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.empty = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_base = {
	init = function(self, stats)
		for k, v in pairs(stats) do
			self[k] = v
		end
		
	end,
	update = function(self, rules, adj, countedAdj, generation)
	end,
}

rules.states.human_vaccinated = {
	update = function(self, rules, adj, countedAdj, generation)
	end,
}

rules.states.human_infected = {
	update = function(self, rules, adj, countedAdj, generation)
	end,
}

rules.states.human_hospitalized = {
	update = function(self, rules, adj, countedAdj, generation)
	end,
}

rules.states.human_dead = {
	update = function(self, rules, adj, countedAdj, generation)
	end,
}

--rules.states.human_recovered = {
--	update = function(self, rules, world, neighbors, countedNeighbors, generation)
--	end,
--}

rules.states.virus = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

------------------------------ GUI ------------------------------
premade.gcAll(gui)

------------------------------ Colors ------------------------------
colors = {
	empty = 				{1, 1, 1, 1},
	wall = 					{0, 0, 0, 1},
	
	human_base = 			{0, 0, 1, 1},
	human_vaccinated = 		{0, 0, 1, 1},
	human_infected = 		{0, 0, 1, 1},
	hospitalized = 			{0, 0, 1, 1},
	human_dead = 			{0, 0, 1, 1},
	
	virus = 				{0, 1, 0, 1},
}