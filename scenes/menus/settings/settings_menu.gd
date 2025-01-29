@icon("res://assets/textures/ClassIcons16x16/settings_gear.png")
@tool
class_name SettingsMenu extends Control

const SETTINGS: Settings = preload("res://resources/settings.tres")

signal request_close

@export_tool_button("Populate Menu", "HSlider")
var populate_callable: Callable = populate_menu

func _ready() -> void:
	if not Engine.is_editor_hint() and not SETTINGS.is_loaded: 
		SETTINGS.load_settings()
	populate_menu()
	if Engine.is_editor_hint(): return
	%BackButton.pressed.connect(emit_signal.bind(&"request_close"))
	%Reset.pressed.connect(reset_default)
	request_close.connect(SETTINGS.save_settings)
	visibility_changed.connect(_on_visibility_changed)

func reset_default() -> void:
	SETTINGS.reset_to_default()
	populate_menu()

func populate_menu() -> void:
	var grid: GridContainer = %Grid
	for child in grid.get_children():
		grid.remove_child(child)
		child.free()
	
	for prop: Dictionary in SETTINGS.get_property_list():
		if prop.name not in SETTINGS.PROPERTIES: continue
		create_setting_slider(prop, grid)
	
	var label:= Label.new()
	label.name = &"CameraShakeLabel"
	label.text = "Camera Shake"
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var check:= CheckBox.new()
	check.name = &"CameraShakeCheck"
	check.button_pressed = SETTINGS.get_camera_shake()
	check.toggled.connect(_on_value_changed.bind(&"camera_shake"))
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	check.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	grid.add_child(label)
	grid.add_child(Control.new())
	grid.add_child(check)


func create_setting_slider(property: Dictionary, parent: Control) -> void:
	var label:= Label.new()
	
	label.text = property.name.capitalize()
	
	var slider: HSlider = HSlider.new()
	var spinbox: SpinBox = SpinBox.new()
	slider.share(spinbox)
	
	var bound_strings: PackedStringArray = property.hint_string.split(",")
	slider.min_value = float(bound_strings[0])
	slider.max_value = float(bound_strings[1])
	slider.step = float(bound_strings[2])
	slider.value = SETTINGS[property.name]
	slider.exp_edit = bound_strings[-1] == "exp"
	
	#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	spinbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	label.name = property.name.to_pascal_case() + "Label"
	slider.name = property.name.to_pascal_case() + "Slider"
	spinbox.name = property.name.to_pascal_case() + "Spinbox"
	
	parent.add_child(label, true)
	parent.add_child(slider, true)
	parent.add_child(spinbox, true)
	
	if not Engine.is_editor_hint():
		slider.value_changed.connect(_on_value_changed.bind(property.name))

func _on_value_changed(value: float, property: StringName) -> void:
	SETTINGS.set(property, value)

func _on_visibility_changed() -> void:
	if visible and %Grid.get_child_count() > 1:
		var control: Control = %Grid.get_child(1)
		if control.visible and not control.has_focus():
			control.grab_focus()
	else:
		propagate_call(&"release_focus")
	
