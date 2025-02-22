@icon("res://assets/textures/ClassIcons16x16/pause.png")
@tool
class_name PauseMenu extends Control
const MAX_ALPHA: float = 0.3
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/menus/settings/settings_menu.tscn")
const FADE_DURATION_SEC: float = 0.6 

var settings_menu: SettingsMenu
var color_rect: ColorRect
var panel_container: PanelContainer

func open() -> void:
	if visible: return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	tween(true)
	panel_container.show()
	show()

func close() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if visible and settings_menu.visible:
		settings_menu.hide()
		panel_container.show()
		settings_menu.SETTINGS.save_settings()
		return
	
	if not panel_container.visible: 
		return
	
	panel_container.hide()
	get_tree().paused = false
	tween(false).tween_callback(hide)

func toggle() -> void:
	if visible:		close()
	else:			open()

func tween(to_visible: bool) -> Tween:
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(color_rect, ^"color:a",  MAX_ALPHA if to_visible else 0.0, FADE_DURATION_SEC)
	return tw

func open_settings() -> void:
	settings_menu.show()
	panel_container.hide()

func quit_to_main() -> void:
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	Master.reset_to_main()

func _init() -> void:
	if Engine.is_editor_hint(): return
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect = ColorRect.new()
	color_rect.color = Color(0,0,0,0)
	add_child(color_rect)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	panel_container = PanelContainer.new()
	var vbox:=VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 16)
	panel_container.add_child(vbox)
	
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	for arr : Array in [["Resume", close], ["Settings", open_settings], ["Quit", quit_to_main]]:
		var but:= Button.new()
		but.text = arr[0]
		but.pressed.connect(arr[1])
		but.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(but)
	
	color_rect.add_child(panel_container)
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER,Control.PRESET_MODE_MINSIZE)
	
	settings_menu = SETTINGS_MENU_SCENE.instantiate()
	settings_menu.request_close.connect(close)
	add_child(settings_menu)
	
	settings_menu.hide()
	
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		toggle()
		accept_event()
