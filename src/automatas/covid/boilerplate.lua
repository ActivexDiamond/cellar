--Editor title.
--print("Boilerplate | getfenv(0)", getfenv(0))
--print("Boilerplate | getfenv(1)", getfenv(1))
--print("Boilerplate | getfenv(2)", getfenv(2))
--print("Boilerplate | getfenv(3)", getfenv(3))
--print("Boilerplate | _G", _G)

title = "Covid Simulator 4001!"
--A table holding window config paramaters, things like size, etc...
windowConfig = {
	--fullscreen = true,
	--display = 1,
	w = 1800,							--Window width, in pixels.
	h = 900,							--Window height, in pixels.
	guiW = 400,							--Width of the GUI section of the window, in pixels.
	--guiH = 900,							--Height of the GUI section of the window, in pixels.
	--worldX = 0
	worldY = 100
}

commons = {
	gridW = 580,						
	gridH = 300,						
	outOfBoundsState = "Wall",			
	adjQuery = premade.aHex,				--`premade` is a table holding some functions that provide commonly-used behavior.
}
