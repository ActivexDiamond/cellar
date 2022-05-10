local class = require "libs.cruxclass"
local utils = require "libs.utils"

------------------------------ Upvalues ------------------------------
local checker = Checker(true)

------------------------------ Local Constants ------------------------------
---Commons
local COMMONS_TEMPLATE = {
	gridW = 'number',
	gridH = 'number',
	seed = 'number',
	gridW = 'number',
	gridW = 'number',
	gridW = 'number',
	gridW = 'number',
}

local COMMON_DEFAULTS = {}

---Rules
local RULES_TEMPLATE = {}

local RULES_DEFAULTS = {
	
}

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local CellularWorld = class("CellularWorld")
function CellularWorld:init(commons, rules)
	self:updateCommons(commons)
	self:_assertCommons()
	
	if rules then self:updateRules(rules) end
	self:_assertRules()
	self.generation = 0
end

------------------------------ Constants ------------------------------

------------------------------ Core API ------------------------------
function CellularWorld:update()
end

------------------------------ API ------------------------------
function CellularWorld:updateRules(rules)

end

------------------------------ Util API ------------------------------

------------------------------ Debug API ------------------------------

------------------------------ Internals ------------------------------
function CellularWorld:_assertCommons()

end

function CellularWorld:_assertRules()

end

------------------------------ Getters / Setters ------------------------------
