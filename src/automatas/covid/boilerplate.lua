--Editor title.
--print("Boilerplate | getfenv(0)", getfenv(0))
--print("Boilerplate | getfenv(1)", getfenv(1))
--print("Boilerplate | getfenv(2)", getfenv(2))
--print("Boilerplate | getfenv(3)", getfenv(3))
--print("Boilerplate | _G", _G)

title = "Hello, world!"
--A table holding window config paramaters, things like size, etc...
windowConfig = {
	w = 1080,							--Window width, in pixels.
	h = 720,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	guiH = 720,							--Height of the GUI section of the window, in pixels.
}

commons = {
	gridW = 300,						
	gridH = 580,						
	outOfBoundsState = "wall",			
	adjQuery = premade.aHex,				--`premade` is a table holding some functions that provide commonly-used behavior.
}
