@tool
class_name VirtualJoystick extends Control
const THEME_TYPE: StringName = &"VirtualJoystick"

const BASE_MIN_SIZE: Vector2 = Vector2(132, 132)

const JOY_RESET_SEC: float = 0.07

const BACK_COLOR: Color = Color(0.1, 0.1, 0.1, 0.3)
const JOY_COLOR: Color = Color(0.15, 0.15, 0.15, 0.4)
const JOY_RING_COLOR: Color = Color(1,1,1, 0.15)

const THEME_ITEMS: Dictionary[Theme.DataType, Dictionary] = {
	Theme.DataType.DATA_TYPE_COLOR: {
		back_color = Color(0.1, 0.1, 0.1, 0.3),
		joy_color = Color(0.15, 0.15, 0.15, 0.4),
		joy_ring_color = Color(1.0, 1.0, 1.0, 0.15)
	},
	
	Theme.DataType.DATA_TYPE_CONSTANT: {
		hud_size = 132,
		corner_offset = 48,
	},
	
}


var idx: PackedInt64Array 

var input: Vector2 = Vector2.ZERO:
	set(val):
		input = val.limit_length(1.0)
		parse_input(&"move_left", -input.x)
		parse_input(&"move_right", input.x)
		parse_input(&"move_up", -input.y)
		parse_input(&"move_down", input.y)
		queue_redraw()
		

var hud_scale: float = 1.0


static func _static_init() -> void:
	var t:= ThemeDB.get_project_theme()
	
	if not t:
		printerr("Unable to get project theme!")
		
	if not THEME_TYPE in t.get_type_list():
		t.add_type(THEME_TYPE)
	
	for data_type: Theme.DataType in THEME_ITEMS:
		for item: StringName in THEME_ITEMS[data_type]:
			if not t.has_theme_item(data_type, item, THEME_TYPE):
				t.set_theme_item(data_type, item, THEME_TYPE, THEME_ITEMS[data_type][item])


func parse_input(action: StringName, strength: float) -> void:
	var ev: InputEventAction = InputEventAction.new()
	ev.action = action
	ev.strength = clampf(strength, 0.0, 1.0)
	ev.pressed = strength > 0.0
	Input.parse_input_event(ev)

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE


func _process(delta: float) -> void:
	if idx.is_empty():
		input = input.move_toward(Vector2.ZERO,  delta / JOY_RESET_SEC)
		

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not event.is_canceled():
			idx.push_back(event.index)
		
		elif event.index in idx:
			idx.remove_at(idx.find(event.index))
		
		accept_event()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if event.index in idx:
			input = (( event.position * get_transform()) - size/2.0) / (minf(size.x, size.y)/2.0)
			accept_event()

func _draw() -> void:
	var diameter: float = minf(size.x, size.y)
	draw_circle(size/2.0, diameter/2.0, BACK_COLOR, true, -1.0, true)
	
	var stick_center:= size/2.0 + input * diameter/2.0
	draw_circle(stick_center, diameter/4.0, JOY_COLOR, true, -1.0, true)
	draw_circle(stick_center, diameter/5.0, JOY_RING_COLOR, false, 2.0, true)
	
	if OS.is_debug_build():
		draw_string_outline(get_theme_default_font(), Vector2(0, -96), "%0.02v" % input, 0, -1, 32, 2, Color.BLACK)
		draw_string(get_theme_default_font(), Vector2(0, -96), "%0.02v" % input, 0, -1, 32)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			queue_redraw()
		
		NOTIFICATION_DRAW:
			draw_circle(size/2.0, minf(size.x, size.y)/2.0, BACK_COLOR, true, -1.0, true)
		
		NOTIFICATION_THEME_CHANGED:
			queue_redraw()
			reset_size()
			set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, get_theme_constant(&"corner_offset", THEME_TYPE))
		#NOTIFICATION_READY when Engine.is_editor_hint():
			#const COLORS: Dictionary[StringName, Color] = {
				#back_color = Color(0.1, 0.1, 0.1, 0.3),
				#joy_color = Color(0.15, 0.15, 0.15, 0.4),
				#joy_ring_color = Color(1,1,1, 0.15)
			#}
			#
			#const BACK_COLOR: Color = Color(0.1, 0.1, 0.1, 0.3)
			#const JOY_COLOR: Color = Color(0.15, 0.15, 0.15, 0.4)
			#const JOY_RING_COLOR: Color = Color(1,1,1, 0.15)
			#
			#if not has_theme_color()
			#ThemeDB.get_default_theme()
			#pass


func _get_minimum_size() -> Vector2:
	return Vector2.ONE * get_theme_constant(&"hud_size", THEME_TYPE) 
