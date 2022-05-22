rules.spawn = {
	baseSpot = {
		Empty = 2000,
		HumanBase = 160,
		HumanInfected = 1,
		Virus = 1,  
	},
	coldSpot = {
		Empty = 8000,
		HumanBase = 160,
		HumanInfected = 1,
		Virus = 1,  
	},
	hotSpot = {
		Empty = 650,
		HumanBase = 160,
		HumanInfected = 2,
		Virus = 2,  
	},
}

rules.spawn = {
	baseSpot = {
		Empty = 100,
		HumanBase = 160,
		HumanInfected = 1,
		Virus = 1,  
	},
	coldSpot = {
		Empty = 800,
		HumanBase = 160,
		HumanInfected = 1,
		Virus = 1,  
	},
	hotSpot = {
		Empty = 50,
		HumanBase = 160,
		HumanInfected = 1,
		Virus = 1,  
	},
}


rules.baseChances = {
	infection = 0.2,
	hospital = 1,
	death = 1,
}

rules.minInfectionDuration = 7
rules.maxInfectionDuration = 14
--[[
Legend
	Color
		green		;	virus
		
		blue		;	human_base
		deep_blue	;	human_infected
		magenta		;	human_dead
	
	Shape
		circle		;	female
		rectangle	;	male
		
	Other
		center-circ	;	mask-strictness (size-relative)
		???			;	vaccine-doses
--]]
