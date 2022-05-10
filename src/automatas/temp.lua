function printTable(t)
	for k, v in ipairs(t) do
		print(k, v)
		end
		for k, v in pairs(t) do
		if type(k) ~= 'number' then
			print(k, v)
		end
	end
	print()
end

x = {"hello", "world", 42, true, false, 100}

x[#x + 1] = 200
x[#x + 1] = 300
x[#x + 1] = 400
printTable(x)


rules = {
	generations = 1000,
	world_name = "College Building A",
	states = {"alive", "dead", "empty"},
}

rules.alive = {
	neighbors = 8,
	color = {255, 255, 0},
}

rules.dead = {
	neighbors = 8,
	color = {0,255,255}
     
}
	
rules.empty = {
	neighbors = 2,
	color = {255, 0, 0},
}6