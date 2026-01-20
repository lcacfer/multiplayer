extends Node2D

@export var player_spawner: MultiplayerSpawner
@export var player_spawn_positions: Array[Node2D]
@export var player_scene: PackedScene
@export var bullet_spawner: MultiplayerSpawner
@export var bullet_scene: PackedScene
@export var mainmenu_scene: PackedScene
@export var door_scene: PackedScene

@onready var players_node = $Players
@onready var bullets_node = $Bullets

# player/bullets layers
var player_layers: Array[int] = [1, 2, 4, 8]
var bullet_layers: Array[int] = [16, 32, 64, 128]
var collision_masks: Array[int] = [238, 221, 187, 119]

var pressed_buttons: int = 0

func _ready():
	# connect network disconnection signals
	Global.current_lobby.server_disconnected.connect(_on_server_disconnected)
	Global.current_lobby.player_disconnected.connect(_on_player_disconnected)
	# set spawn functions
	player_spawner.spawn_function = spawn_player
	bullet_spawner.spawn_function = spawn_bullet
	# start game
	call_deferred("start_game_server")

func _input(event):
	# press esc to exit
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

# spawn players and connect buttons signals
func start_game_server():
	if multiplayer.is_server():
		# spawn players
		var i = 0
		for player in Global.current_lobby.players:
			var player_data = Global.current_lobby.players[player]
			player_data["index"] = i
			player_data["id"] = player
			player_spawner.spawn(player_data)
			i += 1
		# connect button signals only on server
		var button_nodes = $Buttons.get_children()
		for button in button_nodes:
			button.activation.connect(_on_button_pressed)
	else:
		Global.current_lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

# spawn player custom function, needed for properties initialization
func spawn_player(_player_data):
	var _player_instance = player_scene.instantiate()
	_player_instance.global_position = player_spawn_positions[_player_data["index"]].global_position
	_player_instance.name = str(_player_data["id"])
	_player_instance.set_index(_player_data["index"]) 
	return _player_instance

func spawn_bullet(_bullet_data):
	var _bullet_instance = bullet_scene.instantiate()
	_bullet_instance.player_id = _bullet_data["id"]
	_bullet_instance.global_position = _bullet_data["pos"]
	_bullet_instance.velocity = _bullet_data["vel"]
	_bullet_instance.collision_layer = bullet_layers[_bullet_data["index"]]
	_bullet_instance.collision_mask = collision_masks[_bullet_data["index"]]
	_bullet_instance.color = _bullet_data["color"]
	return _bullet_instance

# player enters button
func _on_button_pressed(status: bool):
	if status:
		pressed_buttons += 1
	else:
		pressed_buttons -= 1 
	# if every button pressed, spawn door
	if pressed_buttons >= 4:
		var instance = door_scene.instantiate()
		instance.name = "door"
		get_node("Doors").call_deferred("add_child", instance)

# actions on network disconnection events
func _on_server_disconnected():
	get_tree().change_scene_to_packed(mainmenu_scene)

func _on_player_disconnected(id: int):
	if multiplayer.is_server():
		var player_node = players_node.find_child(str(id), true, false)
		if player_node:
			player_node.queue_free()

# centralized shoot management
func shoot(_player_index, _position, _velocity, _color: Color):
	_on_shoot.rpc_id(1, multiplayer.get_unique_id(), _player_index, _position.x, _position.y, _velocity.x, _velocity.y, _color.to_html())

@rpc("any_peer", "call_local", "reliable")
func _on_shoot(_player_id, _player_index, _position_x, _position_y, _velocity_x, _velocity_y, _color):
	var _position = Vector2(_position_x, _position_y)
	var _velocity = Vector2(_velocity_x, _velocity_y)
	bullet_spawner.spawn({"id": _player_id, "index": _player_index, "pos": _position, "vel": _velocity, "color": Color.from_string(_color, Color.WHITE)})
	#instance.color = Global.current_lobby.players[_player_id]["avatar"].bullet_color
	#instance.player_id = _player_id
	#instance.velocity = _velocity
	#instance.collision_layer = bullet_layers[index]
	#instance.collision_mask = collision_masks[index]
	#bullet_spawners[_player_index].global_position = _position
	#bullet_spawners[_player_index].add_child(instance, true)
