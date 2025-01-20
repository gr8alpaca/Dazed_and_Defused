@tool
extends EditorScript

func _run() -> void:
	var scene:= get_scene()
	var fuse: SoftBody3D = scene.get_node(^"%Fuse")
	var mesh: Mesh = fuse.mesh
	for i in 500:
		print( "%3.0d" % i, " : %1.05v" % fuse.get_point_transform(0))
	#mesh.get_mesh_arrays()
