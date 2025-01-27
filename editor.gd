@tool
extends EditorScript

@export_range(0.1, 15.0, 0.1, "exp") 
var movement_sensitivity: float = 3.0

func _run() -> void:
	var scene:= get_scene()
	var pts: PackedVector2Array
	for prop in get_property_list():
		if prop.name == "movement_sensitivity":
			print(prop)
