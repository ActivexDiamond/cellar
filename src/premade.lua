--Holds a bunch of useful, commonly-repeated functionality for automata-templates,
--	to reduce boilerplate.

local premade = {}

------------------------------ Conventions ------------------------------
--	a	;	adjQuery
--	i	;	iterator
--	m	;	map
--	ma	;	map all
--	g	;	controller
--	ga	;	controll commons
--	h	;	helper

------------------------------ Helpers ------------------------------
function premade.hDecodePixel(px, legend)
	for k, v in pairs(legend) do
		if (px[1] == v[1] and px[2] == v[2] and
				px[3] == v[3] and px[4] == v[4]) then
			return k
		end
	end
	return nil
end

local memoWeightTables = {}
function premade.hWeightedRandom(t, forceUpdate)
	local cached = memoWeightTables[t]
	local tw = {} 
	if forceUpdate or not cached then 
		for k, v in pairs(t) do
			for i = 1, v do
				table.insert(tw, k)
			end
		end
		memoWeightTables[t] = tw
	else
		tw = cached
	end
	
	local rng = math.random(1, #tw)
	return tw[rng]
end

------------------------------ Adjacent Queries ------------------------------
function premade.aHex(states, grid, x, y)
	local adj, adjCount = {}, {}

	--Fetch neighbors.	
	for ix = x - 1, x + 1 do
		for iy = y - 1, y + 1 do
			if not (ix == x and iy == y) then
				 table.insert(adj, grid[ix][iy])
			end
		end
	end
	
	--Init all to 0.
	for k, _ in pairs(states) do
		adjCount[k] = 0
	end
	
	--Count neighbors.
	for _, v in ipairs(adj) do
		adjCount[v.name] = adjCount[v.name] + 1	
	end
	
	return adj, adjCount
end

------------------------------ Grid Iterators ------------------------------
function premade.iLeftRightDown(grid)
	return coroutine.wrap(function()
		for x = 1, #grid do
			for y = 1, #grid[x] do
				coroutine.yield(x, y, grid[x][y])
			end
		end
	end)
end

------------------------------ Grouped ------------------------------
function premade.gcAll(controller)
	--premade.gGridSize(controller)
	premade.gScreenshot(controller)
	premade.gSeed(controller)
	premade.gCurrentGeneration(controller)
	premade.gIterate(controller)
	premade.gIterateBack(controller)
	premade.gReset(controller)
end

------------------------------ Map ----------------------------
function premade.maFromImageIterator(rules, set, new)
	return coroutine.wrap(function()
		local imgData = love.image.newImageData(rules.path)
		
		local w, h = imgData:getDimensions()
		assert(w == rules.gridW and h == rules.gridH, "Image dimensions do not match grid dimensions!")
		for x = 0, w - 1 do
			for y = 0, h - 1 do
				local px = {imgData:getPixel(x, y)}
--				local str = "(%d, %d) color: {%f, %f, %f, %f}"
--				print(str:format(x, y, px[1], px[2], px[3], px[4]))

				local state = premade.hDecodePixel(px, rules.legend)
				coroutine.yield(x + 1, y + 1, state)
			end
		end
	end)
end
 
function premade.maFromImage(rules, set, new)
	local imgData = love.image.newImageData(rules.path)
	
	local w, h = imgData:getDimensions()
	assert(w == rules.gridW and h == rules.gridH, "Image dimensions do not match grid dimensions!")
	for x = 0, w - 1 do
		for y = 0, h - 1 do
			local px = {imgData:getPixel(x, y)}
			local state = premade.hDecodePixel(px, rules.legend)
			if state then
				set(x + 1, y + 1, new(state))
			else
				set(x + 1, y + 1, new(rules.outOfBoundsState))
			end
		end
	end
end

------------------------------ Controls ------------------------------
function premade.gGridSize(controller)
	local c = controller.Controls 
	controller:addControl("size", c.BUTTON_STEPPER, {steps = {256, 64, 8}, min = 2})
end

function premade.gScreenshot(controller)
	local c = controller.Controls
	controller:addControl("Screenshot", c.ACTION_BUTTON, {f = function() 
		love.graphics.captureScreenshot(os.date("%Y-%m-%d @%HH-%MM-%Ss") .. ".png")
	end})
end

function premade.gSeed(controller)
	local c = controller.Controls
	controller:addControl("seed", c.RANDOMIZE, {max = 1e9})
end

function premade.gCurrentGeneration(controller)
	local c = controller.Controls
	controller:addControl("generationCount", c.LABEL)
end

function premade.gIterate(controller)
	local c = controller.Controls
	controller:addControl("Step", c.ACTION_BUTTON, {f = function(target)
		target:iterate()
	end})
end

function premade.gIterateBack(controller)
	local c = controller.Controls
	controller:addControl("Back Step", c.ACTION_BUTTON, {f = function(target)
		target:change({
			generations = target.generationCount - 1
		}, true)
	end})
end

function premade.gReset(controller)
	local c = controller.Controls
	controller:addControl("Reset", c.ACTION_BUTTON, {f = function(target)
		target:change({
			generations = 0
		}, true)
	end})
	
end

function premade.gAutoIterate(controller)
	local c = controller.Controls
	controller:addControl("autoIterate", c.CHECKBOX)
end

function premade.gAutoIterateFrequency(controller)
	local c = controller.Controls
	controller:addControl("autoIterateFrequency", c.SLIDER, {step = 0.2, min = 0.02, max = 10})
end

return premade