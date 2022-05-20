

commons = {
	gridW = 100,						
	gridH = 100,						
	outOfBOundsState = "wall",			
	adjQuery = premade.HEX,				--`premade` is a table holding some functions that provide commonly-used behavior.
}

rules = {}

rules.states = {}

---Ruleset data/params.
rules.virus_stats = {

}

rules.human_stats = {
	
}

rules.vaccine_stats = {

}

rules.collected_data = {
	age = {
		["18-24"]	= 81.4,
		["25-30"]	= 11.6,
		["31-40"]	= 4.7,
		["41-70+"]	= 2.3,
	},  
	gender = {
		male	= 48.8,
		female	= 51.2,
	},
	
	vaccinated = {
		no	= 2.3,
		yes	= 97.7, 
	},
	
	vaccine_type = {
		pfizer	= 62.8,
		astra	= 11.6,
		chineese= 25.5,
	},
	
	vaccine_doses = {
		[1] = 11.6,
		[2] = 83.7,
		[3] = 4.7,
	},
	
	social_activity = {
		["1-3"] = 32.6,
		["3-5"] = 30.2,
		["5-7"] = 37.2,
	},
	
	ever_infected = {
		no	= 48.8,
		yes	= 51.2,
	},
	
	infections_pre_vaccine = {
		[0]		= 39.9,
		[1]		= 42.9,
		[2]		= 14.3,
		[3]		= 2.9,
		["4+"]	= 0,
	},
	
	infections_post_vaccine = {
		[0]		= 63.4,
		[1]		= 33.3,
		[2]		= 3.3,
		[3]		= 0,
		["4+"]	= 0,
	},
	
	mask_strictness = {
		[1]		= 17.1,
		[2]		= 9.8,
		[3]		= 9.8,
		[4]		= 19.5,
		[5]		= 31.7,
		[6]		= 2.4,
		[7]		= 2.4,
		[8]		= 4.9,
		[9]		= 2.4,
		[10]	= 0,
		
	},
	mask_type = {
		surgical = 80.5,
		n95 = 19.4,
	},
	
	mask_vaccine_correlation = {
		no		= 33.3,
		yes		= 31,
		maybe	= 35.7,	
	},
}

rules.misc = {
	maybe_split = {
		no	= 50,
		yes	= 50,
	},
}

function rules:generate(x, y)
end

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
	init = function(self, x, y, generation, stats)
		self.age = stats.age
		self.gender = stats.gender
		
		self.vaccine_status = stats.vaccine_status
		self.vaccine_doses = stats.vaccine_doses
		self.social_activity = stats.social

		self.mask_strictness = stats.mask_strictness
		self.mask_type = stats.mask_type
		self.mask_vaccine_change = stats.mask_vaccine_change
				
		self.infections_pre_vaccine = stats.infections_pre_vaccine
		self.infections_post_vaccine = stats.infections_post_vaccine
		
		self.base_infection_chance = stats.base_infection_chance		--0.25
		
		
	end,
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_immune = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_vaccinated = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_infected = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_dead = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.human_recovered = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

rules.states.virus = {
	update = function(self, rules, world, neighbors, countedNeighbors, generation)
	end,
}

------------------------------ GUI ------------------------------
--gui:addControl("outOfBoundsState", c.RADIO, {rules.states})

------------------------------ Colors ------------------------------
colors = {
	empty = {1, 1, 1},
	human = {0, 0, 1},
	zombie = {0, 1, 0},
}