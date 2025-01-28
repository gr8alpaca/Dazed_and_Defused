@icon("res://assets/textures/ClassIcons16x16/settings_gear.png")
@tool
class_name SettingsMenu extends Control

const SETTINGS: Settings = preload("res://resources/settings.tres")

signal request_close

@export_tool_button("Populate Menu", "HSlider")
var populate_callable: Callable = populate_menu

func _ready() -> void:
	SETTINGS.load_settings()
	populate_menu()
	%BackButton.pressed.connect(emit_signal.bind(&"request_close"))
	request_close.connect(SETTINGS.save_settings)

func populate_menu() -> void:
	var grid: GridContainer = %Grid
	for child in grid.get_children():
		grid.remove_child(child)
		child.free()
	
	for prop: Dictionary in SETTINGS.get_property_list():
		if prop.name not in SETTINGS.PROPERTIES: continue
		create_setting_slider(prop, grid)


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
	
	slider.value_changed.connect(_on_value_changed.bind(property.name))

func _on_value_changed(value: float, property: StringName) -> void:
	SETTINGS.set(property, value)
