------------------------------ Window Config ------------------------------
title = "Blank Automata Template"
windowConfig = {
	w = 1080,
	h = 720,
	guiW = 300,
}

------------------------------ Commons ------------------------------
commons = {
	gridW = 150,
	gridH = 150,
	seed = 10^9,
	outOfBoundsState = "BaseFluid",
	adjQuery = premade.aCardinal,
	gridIterator = premade.iLeftRightDown,
}

------------------------------ Rules ------------------------------
rules.STEPS =  106

rules.k = 20
rules.densityFactor = 1
--rules.maxVelocity = 10
rules.chaosFactor = 0.01
rules.diffusionFactor = 0.5
rules.dt = 0.1

function rules:generate(x, y)
	x = x * self.chaosFactor
	y = y * self.chaosFactor
	local density = love.math.noise(x, y)
	local vx, vy = 0, 0
	if math.random() > 0.8 then
		vx = math.random()
		vy = math.random()
	end
	return "BaseFluid", density, vx, vy
end

------------------------------ States - Alive ------------------------------
rules.states.BaseFluid = class("BaseFluid")
	
function rules.states.BaseFluid:initialize(rules, density, vx, vy)
	self.rules = rules
	self.density = density or 0.5
	self.vx = vx or 0
	self.vy = vy or 0
	self.div = 0
	self.p = 0
	
	--Shorthand / syntactic sugar functions.
	--Defined here as to not re-define it in every step/call.
	self.getTarget = function(x, y) return self.rules:getCell(x, y) end
	self.getTargetDensity = function(x, y) return self.rules:getCell(x, y).density end
	self.getTargetVx = function(x, y) return self.rules:getCell(x, y).vx end
	self.getTargetVy = function(x, y) return self.rules:getCell(x, y).vy end
	self.getTargetDiv = function(x, y) return self.rules:getCell(x, y).div end
	self.getTargetP = function(x, y) return self.rules:getCell(x, y).p end
	
	self.step = 0
end

function rules.states.BaseFluid:update(adj, countedAdj, generation)
	if self.x == 1 or self.y == 1 or self.x == self.rules.gridW or self.y == self.rules.gridH then
		return
	end

	self.step = self.step + 1
	--Velocity Step
	if self.step > 0 and self.step <= 20  then
		self:diffuse(1, adj)
	elseif self.step > 20 and self.step <= 40  then
		self:diffuse(2, adj)
	elseif self.step == 41 then
		self:projectPre()
	elseif self.step > 41 and self.step <= 61  then
		self:projectSolver()
	elseif self.step == 62 then	
		self:projectPost()
	elseif self.step == 63 then
		self:advect(1)
		self:advect(2)
	elseif self.step == 64 then
		self:projectPre()
	elseif self.step > 64 and self.step <= 84  then
		self:projectSolver()
	elseif self.step == 85 then	
		self:projectPost()
	--Density Step
	elseif self.step > 85 and self.step <= 105  then
		self:diffuse(0, adj)
	elseif self.step == 106 then
		self:advect(0)
	end
		
	if self.step >= self.rules.STEPS then self.step = 0 end
end

--rules.states.BaseFluid.update = coroutine.wrap(function(self, adj, countedAdj, generation)
--	while true do	--Wrap in an infinite loop so that yielding (swapping) can resume indefinitely. 
--		local b = -1
--		local id = math.random()
--		print("Diffuse", id)
--		self:diffuse(b, adj)
--		coroutine.yield(nil)		--Acts as a swap.
--		print("Advect", id)
--		self:advect(b)
--		coroutine.yield(nil)		--Acts as a swap.
--	end
--end)

function rules.states.BaseFluid:draw(g2d)
	--FIXME: Magic number
	local W = 4 
	local brightness = self.density
	if self.vx == 0 and self.vy == 0 then
		g2d.setColor(brightness, brightness, brightness, 1)
	else
		--local r = 0
		--local g = self.vx / self.rules.maxVelocity
		--local b = self.vy / self.rules.maxVelocity
		--g2d.setColor(r, g, b, 1)
		g2d.setColor(brightness, brightness, brightness, 1)
	end
	
	g2d.rectangle('fill', self.x, self.y, W, W)
end

function rules.states.BaseFluid:diffuse(b, adj)
	local a = self.rules.gridW * self.rules.gridH * self.rules.diffusionFactor * self.rules.dt
	
	local totalDensity = 0
	for _, cell in ipairs(adj) do 
		totalDensity = totalDensity + cell.density
	end
	
	--for k 20
	self.density = (self.density + a * totalDensity) / (1 + 4 * a)
	--end for
	self:setBounds(b, "density")
end

function rules.states.BaseFluid:advect(b)
	--Eeuation Vars
	local N = self.rules.gridW
	local DT = self.rules.dt
	local getD = self.getTargetDensity

	
	--dx/dy per step.
	local dt0 = N * DT
	--Initial change value.
	local x = self.x - dt0 * self.vx
	local y = self.y - dt0 * self.vy
	--Upper bound
	x = math.max(x, 0.5)
	y = math.max(y, 0.5)
	--Lower bound
	x = math.min(x, N + 0.5)
	y = math.min(y, N + 0.5)
	--Position intensities
	local x0 = math.floor(x)
	local y0 = math.floor(y)
	local x1 = x0 + 1
	local y1 = y0 + 1
	
	--
	local s1 = x - x0
	local s0 = 1 - s1
	local t1 = y - y0
	local t0 = 1 - t1
	self.density = s0 * (t0 * getD(x0, y0) + t1 * getD(x0, y1)) +
		s1 * (t0 * getD(x1, y0) + t1 * getD(x1, y1))
		
	self:setBounds(b, "density")
end

function rules.states.BaseFluid:setBounds(b, var)
	local N = self.rules.gridW
	local getD = self.getTarget
	
	--X-edge
	if self.x == 1 then
		local val = getD(2, self.y)[var]
		self[var] = b == 1 and -val or val
	end
	if self.x == N then
		local val = getD(N - 1, self.y)[var]
		self[var] = b == 1 and -val or val
	end
	--Y-edge
	if self.y == 1 then
		local val = getD(self.x, 2)[var]
		self[var] = b == 2 and -val or val
	end
	if self.y == N then
		local val = getD(self.x, N - 1)[var]
		self[var] = b == 2 and -val or val
	end
	
	--Corners
	if self.x == 1 and self.y == 1 then
		local val1 = getD(2, 1)[var]
		local val2 = getD(1, 2)[var]
		self[var] = 0.5 * (val1 + val2)
	end
	if self.x == 1 and self.y == N then
		local val1 = getD(2, N)[var]
		local val2 = getD(1, N - 1)[var]
		self[var] = 0.5 * (val1 + val2)
	end
	if self.x == N and self.y == 0 then
		local val1 = getD(N - 1, 1)[var]
		local val2 = getD(N, 2)[var]
		self[var] = 0.5 * (val1 + val2)
	end
	if self.x == N and self.y == N then
		local val1 = getD(N - 1, N)[var]
		local val2 = getD(N, N - 1)[var]
		self[var] = 0.5 * (val1 + val2)
	end
end

function rules.states.BaseFluid:projectPre()
	local N = self.rules.gridW
	local getVx = self.getTargetVx
	local getVy = self.getTargetVy
	local h = 1.0 / N

	self.div = -0.5 * h * (getVx(self.x + 1, self.y) - getVx(self.x - 1, self.y) +
			getVy(self.x, self.y + 1) - getVy(self.x, self.y - 1))
	self.p = 0
	
	self:setBounds(0, "div")
	self:setBounds(0, "p")
end

function rules.states.BaseFluid:projectSolver()
	local N = self.rules.gridW
	local getP = self.getTargetP
	local h = 1.0 / N
	
	--for k 20
	self.p = (self.div + getP(self.x - 1, self.y) + getP(self.x + 1, self.y) +
			getP(self.x, self.y - 1) + getP(self.x, self.y + 1)) / 4
	self:setBounds(0, "p")
	--end for
end

function rules.states.BaseFluid:projectPost()
	local N = self.rules.gridW
	local getP = self.getTargetP
	local h = 1.0 / N
	
	self.vx = self.vx - (0.5 * (getP(self.x + 1, self.y) - getP(self.x - 1, self.y)) / h)
	self.vy = self.vy - (0.5 * (getP(self.x, self.y + 1) - getP(self.x, self.y - 1)) / h)
	
	self:setBounds(1, "vx")
	self:setBounds(2, "vy")
end

------------------------------ GUI ------------------------------
premade.gScreenshot(gui)
premade.gSeed(gui)
premade.gCurrentGeneration(gui)

gui:addControl("Step", c.ACTION_BUTTON, {f = function(target)
	target:iterate(target.STEPS)
end})

gui:addControl("Back Step", c.ACTION_BUTTON, {f = function(target)
	target:change({
		generations = target.generationCount - target.STEPS
	}, true)
end})


premade.gReset(gui)
premade.gAutoIterate(gui)
premade.gAutoIterateFrequency(gui)