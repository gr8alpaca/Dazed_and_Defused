@icon("res://assets/textures/ClassIcons16x16/main_menu.png")
@tool
class_name MainMenu extends Node3D


func _ready() -> void:
	if Engine.is_editor_hint(): return
	Audio.play_music(Audio.MUSIC_LIBRARY.main_theme)
	create_player()
	var explosion: GPUParticles3D = $Player/Explosion
	explosion.finished.connect(explosion.set_lifetime.bind(explosion.lifetime), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	explosion.lifetime = 0.02
	explosion.emitting = true
	

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed(&"ui_cancel"):
		if %SettingsMenu.visible:
			%SettingsMenu.request_close.emit()
		elif not %Quit.has_focus(): 
			%Quit.grab_focus()

func create_player() -> void:
	const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
	const PLAYER_START_POSITION: Vector3 = Vector3(3.0, 2.5, 1.0)
	var player: Player = PLAYER_SCENE.instantiate()
	var mouse_controller:= MouseController.new()
	player.set_collision_sensor_enabled(false)
	player.add_child(mouse_controller)
	player.dead.connect(_on_player_dead)
	player.input_active = false
	player.visible = false
	add_child(player, true)
	player.position = PLAYER_START_POSITION
	player.visible = true
	player.body_entered.connect(_on_player_body_entered.bind(player, mouse_controller), CONNECT_ONE_SHOT)

func _on_player_body_entered(collider: Node, player: Player, mouse_controller: MouseController) -> void:
	player.set_collision_sensor_enabled(true)
	mouse_controller.disabled = false

func _on_player_dead(collider: Node) -> void:
	create_player()

func _on_quit_pressed() -> void:
	if not Engine.is_editor_hint(): get_tree().quit()

func _settings_pressed() -> void:
	%Menu.hide()
	%SettingsMenu.show()

func _request_close() -> void:
	%SettingsMenu.hide()
	%Menu.show()

func _start() -> void:
	Master.change_level(1)

func _draw() -> void:
	if not %Start.has_focus() and not Engine.is_editor_hint(): 
		%Start.grab_focus()

func _hidden() -> void:
	if Engine.is_editor_hint(): return
	%Menu.propagate_call(&"release_focus")
