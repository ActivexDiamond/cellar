--Editor title.
--print("Boilerplate | getfenv(0)", getfenv(0))
--print("Boilerplate | getfenv(1)", getfenv(1))
--print("Boilerplate | getfenv(2)", getfenv(2))
--print("Boilerplate | getfenv(3)", getfenv(3))
--print("Boilerplate | _G", _G)

title = "Hello, world!"
--A table holding window config paramaters, things like size, etc...
windowConfig = {
	fullscreen = true,
	display = 1,
	--w = 1920,							--Window width, in pixels.
	--h = 1080,							--Window height, in pixels.
	guiW = 350,							--Width of the GUI section of the window, in pixels.
	--guiH = 720,							--Height of the GUI section of the window, in pixels.
	--worldX = 0
	worldY = 200
}

commons = {
	gridW = 580,						
	gridH = 300,						
	outOfBoundsState = "Wall",			
	adjQuery = premade.aHex,				--`premade` is a table holding some functions that provide commonly-used behavior.
}