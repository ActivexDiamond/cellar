## Simulation Manager
In the following chapters we will discuss the first half of this project; a tool designed for the creation and simulation of Cellular Automata systems. Referred to in this document as **Cellar**.

Cellar is a Cellular Automata simulation and creation framework. It allows researchers to use a light but powerful templating-A.P.I. to define automatons.
It also comes with a graphical parameter-editor  that can be used by utilizing a number of simplified-G.U.I.-widgets that it exposes. You can also write your own widgets by extending the base (i.e. blank) widget.

Our program is fully customizable using its advanced built-in template-A.P.I. driven by Lua and using LuaJIT for performance optimization. It allows the researcher to fully customize the editor to suit the needs of their research, making it an adaptive simulation-manager.

It is also cross-platform, allowing the research to use a single-codebase that is completely O.S.-agnostic. It can run on:
- Windows
- MacOS
- \*nix Systems.
- iOS & Android *(With decreased performance.)*
- HTML5 *(Web)*

It offers an online-console facilitating remote debugging and control.

### Editor G.U.I.
#### Tools Used
The G.U.I. A.P.I. is written in Lua 5.1 and interpreted with LuaJIT-5.2, which offers it, and the user (researchers), access to some Lua 5.2 features; mainly `goto` which is used in some parts of the program.

The following libraries were utilized to create the editor's G.U.I.:
1. **L2D**: A C++ framework for Lua development. It was used for the following reasons:
	- Cross-platform building and exporting.
	- Platform agnostic path-handling.
	- File-path aware Lua extensibility.
	- Timing functionality.
	- Multi-threading support for Lua; which was crucial for the performance of our program.
	- An OpenGL 3.2 graphics and rendering layer.
2. **Slab**: A Lua/L2D Immediate Mode G.U.I. framework; used to satisfy all of the program's U.X. requirements.
3. **MiddleClass**: A memory-aware and performant object orientation library for Lua 5.x.

---

#### Core API
Create a new instance of `SmartController`.
Note instances are completely independent and many can be managed simultaneously with no issues.
```lua
instance = SmartController:initialize(headerText, config)
```

##### Arguments

 ```lua 
 string headerText ("Editor")
```
[*Optional*] The title of the editor window.
 ```lua 
 table config (x = 0, y = 0, w = windowWidth / 8, h = windowHeight)
```
[*Optional*] The transform data of the editor window.

---

Must be called once per-frame; as it is used internally for updating all of the controller's logic.
```lua
SmartController:update(dt)
```

##### Arguments

```lua
number dt
```
The amount of time that has passed since the last update call, in milliseconds.

---

An enum holding all available widgets.
```lua
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
```
An enum holding all available widgets.

---

The main method used to add new controls to the editor.
```lua
SmartController:addControl(varName, control, config, target, updateFunc)
```
##### Arguments

 ```lua 
string varName
```
They `key` of the variable to edit; must reside within `target` and is passed into `updateFunc`. If `config.title` is not provided; this will also be used as the label of the control.
 ```lua 
SccBase control
```
`SccBase` or any class extending it. The GUI widget to add. Any of the values of the `Controls` enum are valid for this, but custom classes may also be provided.
```lua
table config ({})
```
A table passed into `control`. Can contain arbitrary data which is then used by the widget. Widgets may require certain values to be passed; however all the default widgets do not require any values.

All widgets accept a `string title` field which is used as their label. Other possible configs are described in each widget's section.
```lua
table target (instance:getTarget())
```
The target of this control. If none is provided, the global target set by `instance.setTarget` is used. If no global target is set either, an error is thrown.
```lua
function(varName, newVal, oldVal, target) updateFunc (instance:getUpdateFunc())
```
The update-function used by this control to modify `varName` inside `target`. If none is provided, the global update-function set by `instance.setUpdateFunc` is used. If no global update-function is set either, an error is thrown.

---

#### Getters & Setters
Sets the global target of newly added controls, if none is passed during their creation. Note that the target is cached and thus only effects controls added after its called.
```lua
SmartController:setTarget(target)
```

---



##### Arguments

```lua
table target
```
The target passed into update-function calls for controls.

---
Sets the global update-function for newly added controls, if none is passed during their creation. Note that the update-function is cached and thus only effects controls added after its called.
```lua
SmartController:setUpdateFunc(func)
```
##### Arguments
```lua
function(varName, newVal, oldVal, target) func
```
The update-function used for calls.

---

#### Widgets
The base widget inherited by all other widgets. It used for the following reasons:
1. To assert that the control passed into `addControl` is valid.
2. To minimize the amount of boilerplate needed when writing widgets.
3. To prepare all common widget state.
```lua
instance = SccBase:initialize(parent, target, updateFunc, varName, config)
```

##### Arguments
```lua
SmartController parent
```
A reference to the `SmartController` object that created this widget.

```lua
table target
```
The target that this control will modify.

```lua
function(varName, newVal, oldVal, target) updateFunc
```
The update-function called upon the widget issuing any change. This must modify the target and set `target[varName]` to `newVal`; otherwise no change will occur!

The function is free to perform any other needed changes .

```lua
string varName
```
The `key` of the value to modify inside `target`.

```lua
table config ({title=varName})
```
An optional table to pass configuration values into the widget. For all default widgets; `title` is used for their display-labels and, alongside all other values, it is optional, making `config` an optional field for them. Child widgets may override this behavior.

---

Provides a textual-label that displays either `title` or `varName` alongside the value of the variable being targeted by this widget - which is **updated dynamically**.

```lua
instance = SccLabel:initialize(...) <extends SccBase>
```

---

Provides a textual- C-style formatted-label that displays either `title` or `varName`. This is intend for displaying this such as help, legends, etc...

```lua
instance = SccStaticLabel:initialize(...) <extends SccBase>
```

---

Provides a button that generates a pseudo-randomized number in between `config.min` and `config.max` (inclusive) and passes it into update-function. If `min` and `max` are within the range `[0, 1]` then a `float` is produced, otherwise, an `integer` is produced. The produced number, in both cases, is `32-bit` and it uses `C`'s `math.random` for its operation.

```lua
instance = SccRandomize:initialize(...) <extends SccBase>
```

##### Config

```lua
number min (0)
```
The lower bound of used for the R.N.G. Inclusive.

```lua
number max (1)
```
The upper bound of used for the R.N.G. Inclusive.

---

Provides a simple boolean checkbox. Its value is both, passed into and obtained from `target`.
```lua
instance = SccCheckbox:initialize(...) <extends SccBase>
```

##### Config
```lua
number count (#self:_getVal())
```
The number of checkboxes to display.

---

Provides a list of boolean checkboxes. Its value is both, passed into and obtained from `target`. Useful for settings flags, tabulated toggleables, etc...
```lua
instance = SccCheckboxList:initialize(...) <extends SccBase>
```

---

Provides  numerical slider that can either controlled with the mouse, or have a value directly inputted into it via the keyboard, for higher precision. Its value is both, passed into and obtained from `target`.
```lua
instance = SccSlider:initialize(...) <extends SccBase>
```

##### Config

```lua
number min (0)
```
The lower bound allowed by the slider.

```lua
number max (1)
```
The upper bound allowed by the slider.

```lua
number step (max * 0.01)
```
The step size of the slider.

---


Similar to `SccSlider` but provides buttons for incrementing and decrementing the targeted value instead of a slider -- which provides greater precision. The number of buttons and their values can be customized with `config`.
```lua
instance = SccButtonStepper:initialize(...) <extends SccBase>
```

##### Config

```lua
array steps ({1})
```
The number and size of increment / decrement steps. The number of buttons created by this widget is `#steps * 2` and the value of each button corresponds to `steps[i]` and `-steps[i]` where `i` is the index of that button (starting at `1`, as per Lua standards.)

```lua
number min (-math.huge)
```
The lower bound of values allowed by the stepper.

```lua
number max (math.huge)
```
The upper bound of values allowed by the stepper.

---

A blank-button that can be assigned any action the user wishes by initializing it with a custom callback.
```lua
instance = SccActionButton:initialize(...) <extends SccBase>
```

##### Config

```lua
function(target) f
```
The callback to be called when the button is pressed.


## Simulation Creator
A powerful templating-A.P.I. intended for the creation of cellular automata in a performant, multi-threaded environment. Aims to help the user by providing a framework that can cover the needs of most cellular automata simulations.

### Setup
### Environment
Below is the static parts of environment in which user-written scripts are run -- a list of what is exposed to the simulation creator.
```lua
local AUTOMATA_ENV = {
	--Lua metadata.
	_VERSION = _VERSION,
	
	--Basics
	print = print,
	type = type,
	tonumber = tonumber,
	tostring = tostring,
	
	--Environment
	setfenv = setfenv,
	getfenv = getfenv,	
	
	--Lua control and loops.
	pairs = pairs,
	ipairs = ipairs,
	next = next,
	select = select,
	unpack = unpack,
	
	--Lua error handling.
	assert = assert,
	error = error,
	pcall = pcall,
	xpcall = xpcall,
	
	--Lua metatables.
	rawset = rawset,
	rawget = rawget,
	rawequal = rawequal,
	setmetatable = setmetatable,
	getmetatable = getmetatable,
	
	--Lua core libs.
	table = table,
	math = math,
	string = string,
	os = _SANDBOXED_OS,	--Only includes time-related functions!
	bit = bit,
	io = _SANDBOXED_IO,
	
	--L2D
	l2d = l2d
	
	--Libs.
	checker = checker,
	csv = csv,
	inspect = inspect,
	class = middlecclass,
	
	--Automata-related.
	simUtils = simUtils,
}
```
*Native Lua functionality will not be explained.*
However, below, is a quick library of all 3rd-party tools available.

1. **L2D**: See the "G.U.I. / Tools Used" section.
2. **MiddleClass**: See the "G.U.I. / Tools Used" section.
3. **CSV**: A pure-Lua `.csv` parser with support for headers and custom-formats. This was slightly modified to use `l2d.filesystem.open` instead of `io.open` to make it platform-agnostic.
4. **inspect**: A human friendly (debugging-oriented) Lua-table printer.


Of the tools used, the following were custom-written for this project:
1. **Checker**: An assertion library intended for unit-testing and input-validation.
2. **PreMade**: A collection of functionality that is commonly used in cellular automata simulations -- to lighten the load of the user, and accelerate development time of simulations.


### Pre-Made Functionality
Below is the full A.P.I. of the **PreMade** library.

#### Conventions
**Pre-Made** uses the following prefixes for its functions.
Prefix | Usage
:-: | :-:
a | Querying functions.
i | Iterators.
m | Generators.
ma | Full-map generators.
g | G.U.I. control.
ga | Grouped G.U.I. controls.
h | Helpers and utility functions.

#### Querying Functions
Given a cell-coordinate, returns its neighbors ("neighbors" are defined as all cells in a 3x3 grid centered on the target cell).
```lua
adj, adjCounted = premade.aHex(states, grid, x, y)
```
##### Arguments
```lua
table states
```
A table containing all of the states to be accounted by `adjCount`. This is usually the same as `rules.states` but the user my pass in any table they wish -- present entries will be counted above zero, non present ones will still be present but with a count of zero. 
The comparison is as follows: `key == grid[x][y].name`

```lua
array grid
```
The grid to check - must be a 2-dimensional array. If any of `[x - 1, x + 1]` or `[y - 1, y + 1]` are out-of-bounds, an error is thrown unless `grid` handles it gracefully.
It will be accessed as follows: `state = grid[x][y]`

```lua
number x
number y
```
The coordinates of the cell to check around.

##### Returns
```lua
array adj
```
An array of its neighbors. Contains the actual instances of each number. Order is non-deterministic.

```lua
table adjCounted
```
A table of the counts of each state in the simulation (See `states` above.) neighboring the target cell. Contains a `key` for each state, indexed by its `string` name. The `value` is a `number` in the range `[0, 8]`. Note that an entry is present for each state defined by `states`, even those not neighboring the target cell.

--- 

#### Iterators
Returns an iterator that traverses `grid` one row at a time, left-to-right, starting at the top.
```lua
iter = premade.iLeftRightDown(grid)
```
##### Arguments
```lua
array grid
```
The grid to traverse. Must be a 2-dimensionl array.

##### Returns
```lua
(x, y, state = function()) iter
```
A stateless iterator coroutine wrapped behind a `coroutine.wrap(f)` function. Each call returns three values;
- `x` and `y`: The coordinates of the cell.
- `state`: The instance of whichever state is in that cell.

Once iteration has finished, it returns `nil`. 
Can be directly used in Lua's generic-loops.
Example:
```lua
for x, y, state in premade.iLeftRightDown(grid) do
	print(string.format("Cell at (%d, %d): %s", x, y, state))
end
print("Done!")
```

---

#### Generators & Full Map Generators
#### G.U.I. Controls (Grouped & Ungrouped)
#### Helpers & Utility Functions
Returns the current working directory - relative to the premade
```lua
PATH = premade.hGetCwd()
```
##### Returns
```lua
string PATH
```
The C.W.D. of **premade**.

--- 

Decodes the state (based on your simulation's rules) of a grid-cell from a `PixelData` object and a 
```lua
state = premade.hDecodePixel(px, legend)
```
##### Arguments
```lua
table{number, number, number, number(nil)} px
```
The pixel to decode

```lua
table legend
```
A table of `PixelData` indexed by Lua-variable-valid  `string`s, used to decode the pixels.

##### Returns
```lua
(string or nil) state
```
The name of the state, if one is found, nil otherwise.

--- 

Given a table of weights, randomly returns one of the values in that table -- respecting their weights. This function is memoized; it caches the weighted-tables it creates when call. The relationship between weights is linear.
```lua
v = premade.hWeightedRandom(t, forceUpdate)
```
##### Arguments
```lua
table t
```
A table of weights, from which to randomly return a value.

```lua
boolean forceUpdate (false)
```
If true, forces the function to discard its cache for this table and recreate it.

##### Returns
```lua
type(k) v
```
The randomly selected value. Its type is whatever the type of the `key` corresponding to it is.

--- 

Takes in any UTF-8 compliant string, pads it on the left side, and returns it.
```lua
paddedStr = premade.hLeftPad(str, len, pad)
```
##### Arguments
```lua
string str
```
The string to pad.

```lua
number len
```
The string-length to stop padding at.


```lua
string pad (" ")
```
The character to pad with. If `#pad ~= 1` an error is thrown. Defaults to the empty-space character.

##### Returns
```lua
string paddedStr
```
The padded string. If `#str >= len` then `paddedStr == str` is guaranteed.

--- 

Identical to `premade.hLeftPad` but pads on the right-side instead.
```lua
paddedStr = premade.hRightPad(str, len, pad)
```

--- 

Generates a 2-dimensional grid, given a `.png` or `.jpg` image. Intended to be used as a pre-made value for `rules.generateAll`
```lua
grrd = premade.maFromImage(rules, set, new)
```
##### Arguments
```lua
table rules
```
A simulations `rules` table. 
Technically, any table may be passed, so long as it contains the following fields:
- `string path`: A filename pointing to a valid `.png` or `.jpg` image. Is relative to `src/`.
- `table legend`: A table conforming to the rules of `premade.hDecodePixel`'s second argument; `legend`.
- `string outOfBoundsState`: A string pointing to a valid state defined in the current simulation.

```lua
function(x, y, state) set
```
A function that takes in a 2-dimensional coordinate and a state instance; and places it into the grid at that location.
This is usually passed in by Cellar itself, as this function is intended to be used as a pre-made value for `rules.generateAll`.

```lua
function(stateName) new
```
A function that takes a valid state name, and returns an instance of that state.
This is usually passed in by Cellar itself, as this function is intended to be used as a pre-made value for `rules.generateAll`.


## COVID19 Demo

using the database harvested from collage campus regarding our spicified virus we processed and configured it into rules to be the base logic of how each cells interact within the simulation.

### GUI
<cellar-gui.png>
Above is an image showcasing all of the controls used in our COVID19-demo.

Button Name | Usage
:-: | :-:
Screenshot | Takes a screenshot of the entire window and saves it at your home directory[^1]
seed | The seed used by all RNG operation.
Randomize | Randomizes the simulation and steps back up-to the current `generationCount`.
generationCount | How many generations have been simulated up to this point.
Step | Simulate a single generation.
BackStep | Undo a single step of the simulation.
Reset | Resets the generation count back to zero.
AutoIterate | Enable automatic stepping.
AutoIterateFrequency | Time between auto-steps in seconds.
Cycle Map | Cycle between all loaded maps.
Echo Stats | Compute stats for current generation, and echoes to console.[^2]

[^1]: Windows: "%appdata%/CellularAutomataSimulator"
  MacOS:   "AppSupport/CellularAutomataSimulator"
  *nix:    ".local/share//CellularAutomataSimulator"

[^2]: Not computed every step because it is very C.P.U. intensive.


# Deprecated

### Simulation Controls


### Usage

### //State / Saving

### //Import / Export

## //Map Editor

### GUI

### Usage

### Import / Export


## Simulation Creator

### Environment

### Pre-Made Functionality

### Built-In Assertions

### //Unit Testing

### //Writing Optimized Simulation

### Examples

### Limitations

### //Full Documentation

## Software Architecture

### Tools Used

### //Set Up

### Conventions

### Design Goals

### Architecture

### //Unit Tests

### //Untitled

<title = I think there should be something here, but can’t remember.>

### /Benchmarks

