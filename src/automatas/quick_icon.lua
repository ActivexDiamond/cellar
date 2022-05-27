------------------------------ Window Config ------------------------------
title = "Blank Automata Template"
windowConfig = {
	w = 1080,
	h = 720,
	guiW = 350,
	--guiH = 600,
}

------------------------------ Commons ------------------------------
commons = {
	gridW = 256,
	gridH = 256,
	seed = 10^9,
	generations = 0,
	outOfBoundsState = "Human",
	adjQuery = premade.aHex,
	gridIterator = premade.iLeftRightDown,
}

------------------------------ Rules ------------------------------
rules.initialLivingPercentage = 0.99
rules.humanHealth = 5
rules.zombieHunger = 5

function rules:generate(x, y)
	if math.random() > self.initialLivingPercentage then
		return "Zombie"
	else
		return "Human"
	end
end

------------------------------ States - Empty ------------------------------
rules.states.Empty = class("Empty")

function rules.states.Empty:initialize(rules)
end

function rules.states.Empty:update(adj, countedAdj, generation)
	if countedAdj.Human == 3 and countedAdj.Zombie == 0 then
		return "Human"
	end
	return nil
end

------------------------------ States - Human ------------------------------
rules.states.Human = class("Human")
function rules.states.Human:initialize(rules)
	self.health = rules.humanHealth
end

function rules.states.Human:update(adj, countedAdj, generation)
	self.health = self.health - countedAdj.Zombie
	
	if self.health <= 0 then
		return "Zombie"
	end
	return nil
end

------------------------------ States - Zombie ------------------------------
rules.states.Zombie = class("Zombie")

function rules.states.Zombie:initialize(rules)
	self.hunger = rules.zombieHunger
end

function rules.states.Zombie:update(adj, countedAdj, generation)
	if countedAdj.Human == 0 then
		self.hunger = self.hunger - 1
		if self.hunger == 0 then
			return "Empty"
		end
	end
	return nil
end

------------------------------ GUI ------------------------------
premade.gcAll(gui)

gui:addControl("To-Image", c.ACTION_BUTTON, {f = function(target)
	local imageData = love.image.newImageData(target.gridW, target.gridH)
	for x, y, cell in target.gridIterator(target.grid) do
		local color = colors[cell.name]
		imageData:setPixel(x - 1, y - 1, unpack(color))
	end
	local filename = "direct-image-" .. os.date("%Y-%m-%d @%HH-%MM-%Ss") .. ".png"
	imageData:encode("png", filename)
end})

gui:addControl("initialLivingPercentage", c.BUTTON_STEPPER, {steps = {0.01, 0.001, 0.0001}, min = 0, max = 1})
gui:addControl("humanHealth", c.BUTTON_STEPPER)
gui:addControl("zombieHunger", c.BUTTON_STEPPER)
------------------------------ Colors ------------------------------	
colors = {
	Human = {0, 0, 1},	
	Zombie = {0, 1, 0},
	Empty = {1, 1, 1}
}
	