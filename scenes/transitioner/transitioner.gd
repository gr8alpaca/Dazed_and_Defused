@tool
class_name Transitioner extends Control

const BG_FADE_TIME_SEC: float = 0.7
const SCENE_FADE_TIME: float = 0.35

@export var load_bar: ProgressBar
@export var load_label: Label

var scene_path: String
var progress: Array = [0.0]
var message_tw: Tween


func _process(delta: float) -> void:
	if not scene_path:
		set_process(false)
		return
	
	update_loading(ResourceLoader.load_threaded_get_status(scene_path, progress))
	load_bar.value = progress[0] * 100.0
	


func transition(path: String) -> void:
	assert(ResourceLoader.exists(path, "PackedScene"), "Invalid scene path: %s" % path)
	scene_path = path
	show()
	load_label.text = "Loading resources..."
	set_message_tween_active(true)
	tween(true).tween_callback(begin_loading).set_delay(BG_FADE_TIME_SEC)


func begin_loading(attempt_number: int = 0) -> void:
	var err:= ResourceLoader.load_threaded_request(scene_path, "PackedScene")
	if err != OK:
		printerr("Error requesting load threaded for scene '%s'" % scene_path)
	set_process(true)


func enter_new_scene() -> void:
	var scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	scene_path = ""
	
	get_tree().node_added.connect(tween.bind(false).unbind(1), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	get_tree().node_added.connect(load_label.set_text.bind("...").unbind(1), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	
	var err: int = get_tree().change_scene_to_packed(scene)
	assert(err == OK, "ERR: Packed Scene Instantiation (%s)" % error_string(err))
	#load_label.text = "Entering..."


func tween(is_start: bool) -> Tween:
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_parallel(true)
	tw.tween_property($Elements, "modulate:a", float(is_start), SCENE_FADE_TIME).set_delay(BG_FADE_TIME_SEC - SCENE_FADE_TIME)
	tw.tween_property($BG, "modulate:a", float(is_start), BG_FADE_TIME_SEC)
	if not is_start: 
		tw.chain().tween_callback(reset).set_delay(0.1)
	return tw


func reset() -> void:
	hide()
	progress = [0.0]
	$Elements.modulate.a = 0.0
	load_bar.value = 0.0
	load_label.text = ""
	set_message_tween_active(false)
	

func update_loading(load_status: ResourceLoader.ThreadLoadStatus) -> void:
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			load_bar.value = load_bar.max_value
			load_label.text = "Instantiating Scene..."
			enter_new_scene()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			printerr("Could not load resource at path " + scene_path + " (Code %s)" % load_status)
			var default_scene: String = ProjectSettings.get_setting("application/run/main_scene", "")
			if default_scene == scene_path:
				return
			scene_path = default_scene
			begin_loading.call_deferred()
			

func set_message_tween_active(active: bool) -> void:
	const DOT_TWEEN_TIME: float = 1.1
	if not active and message_tw and message_tw.is_valid():
		message_tw.kill()
	if active:
		message_tw = create_tween().set_loops(0)
		message_tw.tween_method(set_label_dot_count, 3, 0, DOT_TWEEN_TIME)
	
func set_label_dot_count(missing_suffix_dots: int =3) -> void:
	load_label.visible_characters = load_label.text.length() - missing_suffix_dots
	
