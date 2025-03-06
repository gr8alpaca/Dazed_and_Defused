class_name InputDebug extends Label

var data: Dictionary[int, InputEvent]

func _init() -> void:
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	vertical_alignment = VERTICAL_ALIGNMENT_TOP
	horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
	add_theme_font_size_override("font_size", 20)
	get_window().window_input.connect(_on_input, CONNECT_DEFERRED)

func _on_input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag): return
	
	data[event.index] = event
	
	if event.is_canceled() or (event is InputEventScreenTouch and not event.is_pressed()):
		data.erase(event.index)
	
	update_data.call_deferred()

func update_data() -> void:
	var new_text: String = ""
	for idx: int in data.keys():
		new_text += "%01.0d: %3.0v - %s %2.0v\n" % [idx, data[idx].position, data[idx].get_class(), data[idx].screen_relative if data[idx] is InputEventScreenDrag else Vector2.ZERO] 
	text = new_text
