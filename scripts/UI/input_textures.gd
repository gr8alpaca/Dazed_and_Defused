@tool
@icon("res://assets/textures/ClassIcons16x16/key_t.png")
class_name InputTextures extends Resource

enum {KEYBOARD, XBOX, PLAYSTATION}

var device_type: int = KEYBOARD:
	set(val):
		if device_type == val: return
		device_type = val
		changed.emit()

func _init() -> void:
	if not Engine.is_editor_hint(): 
		Engine.get_main_loop().root.window_input.connect(_input)

func get_texture(action_name: StringName) -> Texture2D:
	return TEXTURES[action_name][device_type]

func _input(event: InputEvent) -> void:
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and (device_type != PLAYSTATION or device_type != XBOX):
		device_type = get_joy_type(event.device)
	if event is InputEventKey and device_type != KEYBOARD:
		device_type = KEYBOARD

func get_joy_type(device: int) -> int:
	var input_name:= Input.get_joy_name(device)
	if input_name.containsn("PS4") or input_name.containsn("PS5") or input_name.containsn("Playstation"):
		return PLAYSTATION
	return XBOX

const TEXTURES:={
	
	reset = [
		preload("res://assets/textures/buttons/keyboard/R_Key_Dark.png"),
		preload("res://assets/textures/buttons/xbox/XboxSeriesX_Y.png"),
		preload("res://assets/textures/buttons/ps/PS5_Triangle.png"),
		],
	
	ui_cancel = [
		preload("res://assets/textures/buttons/keyboard/Esc_Key_Dark.png"),
		preload("res://assets/textures/buttons/xbox/XboxSeriesX_B.png"),
		preload("res://assets/textures/buttons/ps/PS5_Circle.png"),
		],
	
	ui_accept = [
		preload("res://assets/textures/buttons/keyboard/Space_Key_Dark.png"),
		preload("res://assets/textures/buttons/xbox/XboxSeriesX_A.png"), 
		preload("res://assets/textures/buttons/ps/PS5_Circle.png"),
		],
	
	move = [
		preload("res://assets/textures/buttons/keyboard/WASD.png"),
		preload("res://assets/textures/buttons/Left_Stick.png"),
		preload("res://assets/textures/buttons/Left_Stick.png"),
	],
	
	camera = [
		preload("res://assets/textures/buttons/keyboard/ArrowKeys.png"), 
		preload("res://assets/textures/buttons/Right_Stick.png"),
		preload("res://assets/textures/buttons/Right_Stick.png"),
	],
	
	ui_select = [
		preload("res://assets/textures/buttons/keyboard/Space_Key_Dark.png"),
		preload("res://assets/textures/buttons/xbox/XboxSeriesX_A.png"), 
		preload("res://assets/textures/buttons/ps/PS5_Circle.png"),
	],
}
