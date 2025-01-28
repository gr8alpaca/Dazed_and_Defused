@tool
class_name MainMenu extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	if Engine.is_editor_hint(): return
	create_player()
	#OS.is_userfs_persistent()

func _on_player_dead(collider: Node) -> void:
	create_player()

func create_player() -> void:
	const PLAYER_START_POSITION: Vector3 = Vector3(3.0, 2.5, 1.0)
	var player: Player = player_scene.instantiate()
	var mouse_controller:= MouseController.new()
	player.add_child(mouse_controller)
	player.dead.connect(_on_player_dead)
	player.input_active = false
	player.set_collision_sensor_enabled(false)
	player.visible = false
	add_child(player)
	player.position = PLAYER_START_POSITION
	player.visible = true
	player.body_entered.connect(_on_player_body_entered.bind(player, mouse_controller), CONNECT_ONE_SHOT)

func _on_player_body_entered(collider: Node, player: Player, mouse_controller: MouseController) -> void:
	player.set_collision_sensor_enabled(true)
	mouse_controller.disabled = false

func _on_quit_pressed() -> void:
	get_tree().quit()


func _settings_pressed() -> void:
	%Menu.hide()
	%SettingsMenu.show()


func _request_close() -> void:
	%SettingsMenu.hide()
	%Menu.show()


func _start() -> void:
	Master.change_level(1)
