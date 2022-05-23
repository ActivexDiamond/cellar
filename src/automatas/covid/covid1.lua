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

local MAPS = {
	"automatas/covid/uni_floor_g.png",
	"automatas/covid/uni_floor_g_nocaf.png",
}
local activeMap = 1 
rules.path = MAPS[activeMap]

rules.legend = {
	Wall = {0, 0, 0, 1},

	baseSpot = {0, 0, 0, 0},
	hotSpot = {1, 0, 0, 1},
	coldSpot = {0, 1, 1, 1},
	}

------------------------------ Process .csv ------------------------------
rules.surveyData = {}
do
	local path = "automatas/covid/survey_data.csv"
	local data = csv.open(path, {header = true})
	
	assert(data, "File-path issue related to operating system.")
	
	for fields in data:lines() do
		local t = {}
		local str = ""
		for k, v in pairs(fields) do
			t[k] = v
			local padded = premade.hRightPad(k .. " " .. v, 25)
			str = str .. padded
		end
		print(str)
		table.insert(rules.surveyData, t)
	end
	--print(inspect(rules.survey_data))
end

------------------------------ Helpers ------------------------------
local fetchHumanData
do
	local i = 0
	function fetchHumanData()
		i = i + 1
		if i > #rules.surveyData then
			i = 1
		end
		return rules.surveyData[i]
	end
end

------------------------------ Generate ------------------------------
function rules:generateAll(set, new)
	local MODIFIED_STATS_STRING = "Infection: %.5f\t\t Hospital: %.5f\t\t Death: %.5f\n"
	local SPAWN_STRING = "Spawning at a [%s]: %s.\n"

	print("=> Echoing map loading process.")
	for x, y, pxState in premade.maFromImageIterator(self, set, new) do
		if pxState  == "Wall" then
			set(x, y, new("Wall"))
			goto continue
		end

		local state = premade.hWeightedRandom(self.spawn[pxState])
		io.write(SPAWN_STRING:format(pxState, state))
		if state == "HumanBase" then
			set(x, y, new(state, fetchHumanData()))
		elseif state == "HumanInfected" then
			local humanBase = new("HumanBase", fetchHumanData())
			set(x, y, new(state, humanBase))
		else
			assert(state == "Empty" or state == "Virus", "Invalid state found in map: " .. state)
			set(x, y, new(state))
		end
		::continue::
	end

	print("=> Echoing the modified (final) stats of all human cells")
	for _, _, state in premade.iLeftRightDown(self.grid) do
		if state.name == "HumanBase" or state == "HumanInfected" then
			io.write(MODIFIED_STATS_STRING:format(state.infection, state.hospital, state.death))
		end
	end
end

------------------------------ Blank States ------------------------------
rules.states.Wall = class("Wall")

rules.states.Empty = class("Empty")
--function rules.states.Empty:initialize(rules, stats)
--end
--function rules.states.Empty:update(adj, countedAdj, generation)
--end

------------------------------ Common State Methods ------------------------------
--TODO: Refactor into a Human class and do better.
local function copyHumanStats(self, stats)
	for k, stat in pairs(stats) do
		if not self[k] then
			self[k] = stat
		end
	end
end

local function computeModifiedValue(self, var)
	local base = self.rules.baseChances[var]
	local mod = 1
	for category, stats in pairs(self.rules.modifiers) do
		local val
		if category == "vaccineType" then
			local monthStr = self.daysAlive > 120 and ">4 months" or "<=4 months"
			local doseStr  = self.doses .. " doses"
			val = stats[self.vaccineType][monthStr][doseStr][var]
		elseif category == "maskStrictness" then
		--Ignore, as this is accounted for in maskType.
		elseif category == "maskType" then
			local maskVal = stats[self.maskType][var]
			if maskVal == 100 then
				val = 100	--Is unffected by strictness!
			else
				local strictness = self.maskStrictness / 10		--Map from [1, 10] to [0, 1]
				val = 100 - (maskVal * strictness)
			end
		else	--Age, gender, activity
			local objStat = self[category]
			val = stats[objStat][var]
		end
		--print('c / s / v', category, self[category], stats[self[category]])
		mod = mod * (val / 100)

	end
	return math.min(base * mod, 1)
end

local function computeChances(self)
	self.infection = computeModifiedValue(self, "infection")
	self.hospital = computeModifiedValue(self, "hospital")
	self.death = computeModifiedValue(self, "death")
end

------------------------------ States - HumanBase ------------------------------
rules.states.HumanBase = class("HumanBase")
function rules.states.HumanBase:initialize(rules, stats)
	self.rules = rules
	self.daysAlive = 0

	copyHumanStats(self, stats)
	computeChances(self)
end

function rules.states.HumanBase:update(adj, countedAdj, generation)
	self.daysAlive = self.daysAlive + 1

	local infectors = countedAdj.HumanInfected + countedAdj.HumanHospitalized +
		countedAdj.HumanDead + countedAdj.Virus
	for i = 1, infectors do
		local rng = math.random()
		if rng <= self.infection then
			return "HumanInfected", self
		end
	end
end

------------------------------ States - HumanVaccinated ------------------------------
rules.states.HumanVaccinated = class("HumanVaccinated")
function rules.states.HumanVaccinated:initialize(rules, stats)
	self.rules = rules

	copyHumanStats(self, stats)
end

function rules.states.HumanVaccinated:update(adj, countedAdj, generation)
	self.daysAlive = self.daysAlive + 1
end

------------------------------ States - HumanInfected ------------------------------
rules.states.HumanInfected = class("HumanInfected")
function rules.states.HumanInfected:initialize(rules, stats)
	self.rules = rules

	copyHumanStats(self, stats)

	self.daysInfected = 0
	self.infectionDuration = math.random(self.rules.minInfectionDuration,
		self.rules.maxInfectionDuration)
end

function rules.states.HumanInfected:update(adj, countedAdj, generation)
	self.daysAlive = self.daysAlive + 1
	self.daysInfected = self.daysInfected + 1

	if self.daysInfected > self.infectionDuration then
		self.daysInfected = nil
		return "HumanBase", self
	end

	local rng = math.random()
	if rng <= self.hospital then
		return "HumanHospitalized", self
	end
end

------------------------------ States - HumanHospitalized ------------------------------
rules.states.HumanHospitalized = class("HumanHospitalized")
function rules.states.HumanHospitalized:initialize(rules, stats)
	self.rules = rules

	copyHumanStats(self, stats)
end

function rules.states.HumanHospitalized:update(adj, countedAdj, generation)
	self.daysAlive = self.daysAlive + 1
	self.daysInfected = self.daysInfected + 1

	local rng = math.random()
	if rng <= self.death then
		return "HumanDead", self
	end
end

------------------------------ States - HumanHospitalized ------------------------------
rules.states.HumanDead = class("HumanDead")
function rules.states.HumanDead:initialize(rules, stats)
	self.rules = rules

	copyHumanStats(self, stats)
end

function rules.states.HumanDead:update(adj, countedAdj, generation)
	self.daysAlive = self.daysAlive + 1

	return "Virus"
end

--rules.states.humanRecovered = {
--	update = function(self, rules, world, neighbors, countedNeighbors, generation)
--	end,
--}

------------------------------ States - Virus ------------------------------
rules.states.Virus = class("Virus")
function rules.states.Virus:initialize(rules)
	self.rules = rules
	self.lifespan = 10
end

function rules.states.Virus:update(adj, countedAdj, generation)
	self.lifespan = self.lifespan - 1
	if self.lifespan < 1 then
		return "Empty"
	end
end

------------------------------ GUI - Basic ------------------------------
premade.gcAll(gui)

------------------------------ GUI - Map Controls ------------------------------
gui:addControl("path", c.ACTION_BUTTON, {title = "Switch Map", f = function(target)
	activeMap = math.max((activeMap + 1) % (#MAPS + 1), 1)
	target.path = MAPS[activeMap]
	print("Switching map to:", activeMap)
	target:reset()
end})

------------------------------ GUI - Data Visualization ------------------------------
gui:addControl("Echo Stats", c.ACTION_BUTTON, {f = function(target)
	local count = setmetatable({}, {
		__index = function(t, k) return 0 end
		})

	for _, _, stat in premade.iLeftRightDown(target.grid) do
		if stat.name ~= "Empty" and stat.name ~= "Wall" and stat.name ~= "Virus" then
			count[stat.name] = count[stat.name] + 1
		end
	end

	print("=> Echoing human counts.")
	local str = "%s: %d"
	local total = 0
	for k, v in pairs(count) do
		total = total + v
		print(str:format(k, v))
	end
	print(str:format("Total", total))

end})

------------------------------ Colors ------------------------------
colors = {
	Empty = 				{1, 1, 1, 1},			--white
	Wall = 					{0, 0, 0, 1},			--black

	HumanBase = 			{0, 0, 1, 1},			--blue
	HumanVaccinated = 		{0.8, 0.4, 0.8, 1},		--pale-pink (is it good?)
	HumanInfected = 		{1, 1, 0, 1},			--yellow
	HumanHospitalized = 	{1, 0, 0, 1},			--red
	HumanDead = 			{1, 0, 1, 1},			--magenta

	Virus = 				{0, 1, 0, 1},
}

