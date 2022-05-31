------------------------------ Window Config ------------------------------
title = "Blank Automata Template"
windowConfig = {
	w = 1080,
	h = 720,
	guiW = 300,
}

------------------------------ Commons ------------------------------
commons = {
	gridW = 100,
	gridH = 100,
	seed = 10^9,
	generations = 15,
	outOfBoundsState = "BaseFluid",
	adjQuery = premade.aCardinal,
	gridIterator = premade.iLeftRightDown,
}

------------------------------ Rules ------------------------------
rules.initialLivingPercentage = 0.4
rules.survive = {min = 3, max = 5}
rules.born = {3}

function rules:generate(x, y)
	if math.random() > self.initialLivingPercentage then
		return "dead"
	else
		return "alive"
	end
end

------------------------------ States - Alive ------------------------------
rules.states.Alive = class("Alive")
	
function rules.states.Alive:initialize(rules)
	
end

function rules.states.Alive:update(adj, countedAdj, generation)
	local n = countedAdj.dead
	local min = rules.survive.min
	local max = rules.survive.max
	
	if n < min or n > max then
		return "Dead"
	end
	return nil
end

------------------------------ States - Dead ------------------------------
rules.states.Dead = class("Dead")

function rules.states.Dead:initialize(rules)
	
end

function rules.states.Dead:update(adj, countedAdj, generation)
	if countedAdj.Alive == rules.born then
		return "Alive"
	end
	return nil
end

------------------------------ GUI ------------------------------
premade.gcAll(gui)

------------------------------ Colors ------------------------------	
colors = {
	Alive = {0, 0, 0},	
	Dead = {1, 1, 1},
}
	