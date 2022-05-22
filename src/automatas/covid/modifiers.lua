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
	vaccineType = {
		no = {
			["<=4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},	
				["2 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["3 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 100,
					hospital = 100,
				},
				["2 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["3 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
			},
		},
		pfizer = {
			["<=4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 54,
					hospital = 88,
					death = 100,
				},	
				["2 doses"] = {
					infection = 90,
					hospital = 88,
					death = 100,
				},
				["3 doses"] = {
					infection = 95,
					hospital = 88,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 33,
					hospital = 88,
				},
				["2 doses"] = {
					infection = 67,
					hospital = 88,
					death = 100,
				},
				["3 doses"] = {
					infection = 77,
					hospital = 88,
					death = 100,
				},
			},
		},
		astra = {
			["<=4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 88,
					hospital= 71,
					death = 100,
				},	
				["2 doses"] = {
					infection = 90,
					hospital= 71,
					death = 100,
				},
				["3 doses"] = {
					infection = 93,
					hospital = 71,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 64,
					hospital= 88,
					death = 100,
				},
				["2 doses"] = {
					infection = 70,
					hospital = 88,
					death = 100,
				},
				["3 doses"] = {
					infection = 77,
					hospital = 88,
					death = 100,
				},
			},
		},
		
		chinees = {
			["<=4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital = 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 38,
					hospital= 56,
					death = 100,
				},	
				["2 doses"] = {
					infection = 69,
					hospital= 56,
					death = 100,
				},
				["3 doses"] = {
					infection = 56,
					hospital = 56,
					death = 100,
				},
			},
			[">4 months"] = {
				["0 doses"] = {
					infection = 100,
					hospital= 100,
					death = 100,
				},
				["1 doses"] = {
					infection = 25,
					hospital= 56,
					death = 100,
				},
				["2 doses"] = {
					infection = 40,
					hospital = 56,
					death = 100,
				},
				["3 doses"] = {
					infection = 55,
					hospital = 56,
					death = 100,
				},
			},
		},
	},
	maskType = {
		no = {
			infection = 100,
			hospital = 100,
			death = 100,
		},
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
	activity = {
		["1-3"] = {
			infection = 125,
			hospital = 100,
			death = 100,		
		},
		["3-5"] = {
			infection = 200,
			hospital = 100,
			death = 100,		
		},
		["5-7"] = {
			infection = 400,
			hospital = 100,
			death = 100,		
		},
	}
	
}