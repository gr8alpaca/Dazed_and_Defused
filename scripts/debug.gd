class_name Debug extends Label

const FONT_SIZE: int = 10

var data: Dictionary[String, Callable]


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	add_theme_font_override(&"font", ThemeDB.get_default_theme().default_font)
	add_theme_font_size_override(&"font_size", FONT_SIZE)

	

#func _ready() -> void:
	#add_property("Gyro", Input.get_gyroscope)
	#add_property("Accel", Input.get_accelerometer)


func add_property(property_name: String, getter: Callable) -> void:
	data[property_name] = getter

func remove_property(property_name: String) -> void:
	data.erase(property_name)

func _process(delta: float) -> void:
	draw_data()

func draw_data() -> void:
	var data_text: String = ""
	for prop: String in data.keys():
		data_text += prop + ": "
		var value = data[prop].call()
		match typeof(value):
			TYPE_VECTOR3, TYPE_VECTOR2:	data_text += "%1.02v" % value
			_:	data_text += str(value)
		data_text += "\n"
	
	text = data_text
