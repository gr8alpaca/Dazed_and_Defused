@tool
extends EditorScript

func _run() -> void:
	var scene:= get_scene()
	var pts: PackedVector2Array
	#var collision_shape: CollisionShape2D =  scene.get_node(^"CollisionShape2D")
	const CURVE : Curve = preload("res://resources/new_curve.tres")
	#CURVE.bake()
	var points: PackedVector2Array = [Vector2(1.0, 0.0), Vector2.ZERO]
	for i in CURVE.bake_resolution + 1:
		var x:float = inverse_lerp(0, CURVE.bake_resolution, i)
		points.push_back(Vector2(x, CURVE.sample_baked(x)))
	
	print(points)
	var csg_polygon: CSGPolygon3D = scene.get_node(^"%CSGPolygon3D")
	csg_polygon.polygon = points
