class_name InputPrompt extends Object

enum {DEVICE_KEYBOARD, DEVICE_XBOX, DEVICE_PLAYSTATION}


const TEXTURES:= [
	
	#KEYBOARD
	{
		reset = preload("res://assets/textures/buttons/keyboard/R_Key_Dark.png"),
		ui_cancel = preload("res://assets/textures/buttons/keyboard/Esc_Key_Dark.png"),
	},
	
	#XBOX
	{
		reset = preload("res://assets/textures/buttons/xbox/XboxSeriesX_Y.png"),
		ui_cancel = preload("res://assets/textures/buttons/xbox/XboxSeriesX_B.png"),
	},
	
	#PLAYSTATION
	{
		reset = preload("res://assets/textures/buttons/ps/PS5_Triangle.png"),
		ui_cancel = preload("res://assets/textures/buttons/ps/PS5_Circle.png"),
	},
]
