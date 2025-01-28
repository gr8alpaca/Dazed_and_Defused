@tool
class_name MainMenu extends Node3D

const PLAYER_START_POSITION: Vector3 = Vector3(3.0, 2.5, 1.0)

@export var player_scene: PackedScene

var starting_player_position: Vector3

func _ready() -> void:
	create_player()
	

func _on_player_dead(collider: Node) -> void:
	create_player()

func create_player() -> void:
	var player: Player = player_scene.instantiate()
	player.dead.connect(_on_player_dead)
	player.input_active = false
	player.set_collision_sensor_enabled(false)
	player.visible = false
	add_child(player)
	player.position = PLAYER_START_POSITION
	player.visible = true
	player.body_entered.connect(enable_player.bind(player), CONNECT_ONE_SHOT)

func enable_player(collider: Node, player: Player) -> void:
	player.input_active = true
	player.set_collision_sensor_enabled(true)



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
