local Slab = require "libs.Slab"
local class = require "libs.middleclass"
local utils = require "libs.utils"

------------------------------ Constructor ------------------------------
local SmartController = class("SmartController")
function SmartController:initialize(headerText, config)
	headerText = headerText or "Editor"
	config = config or {}
	
	self.header = {id = "                 +  " .. headerText .. "  +"}
	
	--Window Drawing Config
	self.window = {
		id = 'window',
		AutoSizeWindow = false,
		AllowResize = false,
		AllowMove = false,
	}
	
	self.window.X = config.x or 0
	self.window.Y = config.y or 0
	self.window.W = config.w or love.graphics.getWidth() / 8
	self.window.H = config.h or love.graphics.getHeight()
	
	self.activeControls = {}
	self.group = self.GLOBAL_GROUP
end

------------------------------ Smart Controls - Controls ------------------------------
---Base
local SccBase = class("SccBase")
function SccBase:initialize(parent, target, updateFunc, varName, config)
	self.parent = parent
	self.target = target
	self._updateFunc = updateFunc
	self.varName = varName
	self.config = config or {}
	
	self.includeValInTextualDisplay = true
	self.id = tostring({})
end 
function SccBase:update(dt)
	Slab.Text(self:_getTextualVal())
	Slab.SameLine()
end
---Base - Shortcuts
function SccBase:_updateVal(newVal)
	self._updateFunc(self.varName, newVal, self:_getVal(), self.target) 
end
function SccBase:_getVal() return self.target[self.varName] end
function SccBase:_getTextualVal()
	local str
	if self.includeValInTextualDisplay then
		str = self.varName .. ": " .. tostring(self:_getVal())
	else
		str = self.varName .. ": "
	end
	return str
end

---Label
local SccLabel = class("SccLabel", SccBase)
function SccLabel:initialize(...)
	SccBase.initialize(self, ...)
end
function SccLabel:update(dt)
	SccBase.update(self, dt)
	Slab.NewLine()
end

---StaticLabel
local SccStaticLabel = class("SccStaticLabel", SccBase)
function SccStaticLabel:initialize(...)
	SccBase.initialize(self, ...)
end
function SccStaticLabel:update(dt)
	Slab.Textf(self.varName)
end

---Randomize
local SccRandomize = class("SccRandomize", SccBase)
function SccRandomize:initialize(...)
	SccBase.initialize(self, ...)
	self.min = self.config.min or 0
	self.max = self.config.max or 1
end
function SccRandomize:update(dt)
	SccBase.update(self, dt)
	if Slab.Button("Randomize") then
		self:_updateVal(math.random(self.min, self.max))
	end
end

---Checkbox
local SccCheckbox = class("SccCheckbox", SccBase)
function SccCheckbox:initialize(...)
	SccBase.initialize(self, ...)
	self.includeValInTextualDisplay = false
end
function SccCheckbox:update(dt)
	SccBase.update(self, dt)
	if Slab.CheckBox(self:_getVal()) then
		self:_updateVal(not self:_getVal())
	end
end

---Slider
local SccSlider = class("SccSlider", SccBase)
function SccSlider:initialize(...)
	SccBase.initialize(self, ...)
	self.includeValInTextualDisplay = false
	self.min = self.config.min or 0
	self.max = self.config.max or 1
	self.opt = {
		Precision = self.config.step, 
	}
end
function SccSlider:update(dt)
	SccBase.update(self, dt)
	if Slab.InputNumberSlider(self.id, self:_getVal(), self.min, self.max, self.opt) then
		self:_updateVal(Slab.GetInputNumber())
	end
end

---ButtonStepper
local SccButtonStepper = class("SccButtonStepper", SccBase)
function SccButtonStepper:initialize(...)
	SccBase.initialize(self, ...)
	self.includeValInTextualDisplay = false

	self.steps = self.config.steps or {1}
	self.max = self.config.max or math.huge
	self.min = self.config.min or -math.huge
	self.buttonW = 20
	self.buttonH = 20
end
function SccButtonStepper:update(dt)
	SccBase.update(self, dt)	
	for i = 1, #self.steps do
		local v = self.steps[i]
		local opt = {W = self.buttonW, Tooltip = "+" .. v}
		if Slab.Button("+", opt) then
			local newVal = self:_getVal() + v
			newVal = math.min(newVal, self.max)
			self:_updateVal(newVal)
		end
		Slab.SameLine()
	end
	Slab.Text(self:_getVal())
	Slab.SameLine()
	for i = #self.steps, 1, -1 do
		local v = self.steps[i]
		local opt = {W = self.buttonW, H = self.buttonH, Tooltip = "-" .. v}
		if Slab.Button("-", opt) then	
			local newVal = self:_getVal() - self.steps[i]
			newVal = math.max(newVal, self.min)
			self:_updateVal(newVal)
		end
		Slab.SameLine()
	end
	Slab.NewLine()
end


---CheckboxList
local SccCheckboxList = class("SccCheckboxList", SccBase)
function SccCheckboxList:initialize(...)
	SccBase.initialize(self, ...)
	self.includeValInTextualDisplay = false

	self.count = self.config.count or #self:_getVal()
end
function SccCheckboxList:update(dt)
	SccBase.update(self, dt)
	
	local t = utils.t.copy(self:_getVal())
	for i = 1, self.count do
		local val = t[i]
		if Slab.CheckBox(t[i]) then
			t[i] = not t[i]
			self:_updateVal(t)
		end
		Slab.SameLine()
	end
	Slab.NewLine()
end

---ActionButton
local SccActionButton = class("SccActionButton", SccBase)
function SccActionButton:initialize(...)
	SccBase.initialize(self, ...)

	self.f = self.config.f
	self.title = self.config.title or self.varName
end
function SccActionButton:update(dt)
	if Slab.Button(self.title) then
		self.f(self.target)
	end
	if self:_getVal() then
		Slab.SameLine()
		Slab.Text(self:_getVal())
	end
end

------------------------------ Smart Controls - API ------------------------------
---Pre-Defined Controls
SmartController.Controls = {
	BASE = SccBase,
	LABEL = SccLabel,
	STATIC_LABEL = SccStaticLabel,
	RANDOMIZE = SccRandomize,
	CHECKBOX = SccCheckbox,
	SLIDER = SccSlider,
	BUTTON_STEPPER = SccButtonStepper,
	CHECKBOX_LIST = SccCheckboxList,
	ACTION_BUTTON = SccActionButton,
}
SmartController.GLOBAL_GROUP = {}			-- unique key

---Control Accessors
function SmartController:addControl(varName, control, config, target, updateFunc)
	config = config or {}
	target = target or self.target
	updateFunc = updateFunc or self.updateFunc

	local i = #self:_getActiveGroup() + 1

	assert(target, "[target] must be set before adding controls (or passed in)!")
	assert(updateFunc, "[updateFunc] must be set before adding controls (or passed in)!")
	local c = control(self, target, updateFunc, varName, config)
	table.insert(self:_getActiveGroup(), i, c)
end

---State Accessors
function SmartController:setTarget(target) self.target = target end
function SmartController:setUpdateFunc(func) self.updateFunc = func end
function SmartController:setGroup(group) self.group = group or self.GLOBAL_GROUP end
function SmartController:clearState() 
	self.target = nil
	self.updateFunc = nil
	self.group = self.GLOBAL_GROUP
end
--TODO: push/pop

------------------------------ Core API ------------------------------
function SmartController:update(dt)
	Slab.BeginWindow(self.window.id, self.window)
	Slab.Text(self.header.id, self.header)
	for k, c in ipairs(self:_getActiveGroup()) do
		c:update(dt)
	end
	Slab.EndWindow()
end
	
------------------------------ Internals ------------------------------
function SmartController:_getActiveGroup()
	if not self.activeControls[self.group] then
		self.activeControls[self.group] = {}
	end
	return self.activeControls[self.group]
end

------------------------------ Getters / Setters ------------------------------
function SmartController:setHeaderText(str)
	self.header = {id = "                 +  " .. str .. "  +"}
end

function SmartController:setConfig(config)
	self.window.X = config.x or self.window.X
	self.window.Y = config.y or self.window.Y
	self.window.W = config.w or self.window.W
	self.window.H = config.h or self.window.H
end

function SmartController:setPosition(x, y)
	self.window.X = x
	self.window.Y = y
end

function SmartController:setSize(w, h)
	self.window.W = w
	self.window.H = h
end

return SmartController