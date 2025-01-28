@icon("res://assets/textures/ClassIcons16x16/pause.png")
@tool
class_name PauseMenu extends Control
const MAX_ALPHA: float = 0.3
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/menus/settings/settings_menu.tscn")

var settings_menu: SettingsMenu
var color_rect: ColorRect

func open() -> void:
	pass
func close() -> void:
	pass


func _init() -> void:
	if Engine.is_editor_hint(): return
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect = ColorRect.new()
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.TRANSPARENT
	add_child(color_rect)
	
	var vbox:=HBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var resume_button:= Button.new()
	resume_button.text = "Resume"
	resume_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	#hbox.add_child()
	settings_menu = SETTINGS_MENU_SCENE.instantiate()
	
	add_child(settings_menu)
