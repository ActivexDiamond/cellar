rules.modifiers = {
	gender = {
		male = {
			infection = 100,
			hospital = 100,
			death = 100,
		},
		female = {
			infection = 113.6,
			hospital = 100,
			death = 100,			
		},
	},
	age = {
		["18-25"] = {
			infection = 100,	
			hospital = 2.5,
			death = 0.626515,
		},
		["25-30"] = {
			infection = 100,
			hospital = 2.5 * 2,
			death = 1.817165,
		},
		["30-40"] = {
			infection = 100,
			hospital = 2.5 * 4,
			death = 4.301700,
		},
		["40-70"] = {
			infection = 100,
			hospital = 2.5 * 17,
			death = 18.75161,
		},
	},
	vaccine = {
		pfizer = {
			["<=4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 54,
					hospital = 88,
					death = 100,
				},	
				["2 dose"] = {
					infection = 90,
					hospital = 88,
					death = 100,
				},
				["3 dose"] = {
					infection = 95,
					hospital = 88,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 33,
					hospital = 88,
				},
				["2 dose"] = {
					infection = 67,
					hospital = 88,
					death = 100,
				},
				["3 dose"] = {
					infection = 77,
					hospital = 88,
					death = 100,
				},
			},
		},
		astra = {
			["<=4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 88,
					hospital= 71,
					death = 100,
				},	
				["2 dose"] = {
					infection = 90,
					hospital= 71,
					death = 100,
				},
				["3 dose"] = {
					infection = 93,
					hospital = 71,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 64,
					hospital= 88,
					death = 100,
				},
				["2 dose"] = {
					infection = 70,
					hospital = 88,
					death = 100,
				},
				["3 dose"] = {
					infection = 77,
					hospital = 88,
					death = 100,
				},
			},
		},
		
		chinese = {
			["<=4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 38,
					hospital= 56,
					death = 100,
				},	
				["2 dose"] = {
					infection = 69,
					hospital= 56,
					death = 100,
				},
				["3 dose"] = {
					infection = 56,
					hospital = 56,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 dose"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 dose"] = {
					infection = 25,
					hospital= 56,
					death = 100,
				},
				["2 dose"] = {
					infection = 40,
					hospital = 56,
					death = 100,
				},
				["3 dose"] = {
					infection = 55,
					hospital = 56,
					death = 100,
				},
			},
		},
	},
	mask = {
		kn95 = {
			infection = 85,
			hospital = 100,
			death = 100,
			},
		surgical = {
			infection = 65,
			hospital = 100,
			death = 100,
		},
	},
}