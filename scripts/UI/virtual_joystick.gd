@tool
class_name VirtualJoystick extends Control

const JOY_RESET_SEC: float = 0.17
const BACK_COLOR: Color = Color(0.1, 0.1, 0.1, 0.3)
const JOY_COLOR: Color = Color(0.15, 0.15, 0.15, 0.4)

var idx: PackedInt64Array 

var input: Vector2 = Vector2.ZERO:
	set(val):
		input = val.limit_length(1.0)
		Input.set_meta(&"virtual_joystick", input)
		queue_redraw()
		

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
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
	
	draw_circle(size/2.0, minf(size.x, size.y)/2.0, BACK_COLOR, true, -1.0, true)
	
	var stick_center:= size/2.0 + input * minf(size.x, size.y)/2.0
	draw_circle(stick_center, minf(size.x, size.y)/4.0, JOY_COLOR, true, -1.0, true)
	draw_circle(stick_center, minf(size.x, size.y)/5.0, Color(1,1,1, 0.15), false, 2.0, true)
	
	if OS.is_debug_build():
		draw_rect(Rect2(0,0, size.x, size.y), Color.MAGENTA, false, 1.0)
		draw_string_outline(get_theme_default_font(), Vector2(0, -96), "%0.02v" % input, 0, -1, 32, 2, Color.BLACK)
		draw_string(get_theme_default_font(), Vector2(0, -96), "%0.02v" % input, 0, -1, 32)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			queue_redraw()
		
		NOTIFICATION_DRAW:
			draw_circle(size/2.0, minf(size.x, size.y)/2.0, BACK_COLOR, true, -1.0, true)


func _get_minimum_size() -> Vector2:
	return Vector2(132, 132)
