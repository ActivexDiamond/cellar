--Holds a bunch of useful, commonly-repeated functionality for automata-templates,
--	to reduce boilerplate.

local premade = {}

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

function premade.gIterate(controller)
	local c = controller.Controls
	controller.addControl("Step", c.ACTION_BUTTON, {f = function(target)
		target:iterate()
	end})
end

function premade.gReset(controller)
	local c = controller.Controls
	controller.addControl("Reset", c.ACTION_BUTTON, {f = function(target)
		target:reset()
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