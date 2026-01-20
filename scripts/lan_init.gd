extends Node2D

@export var player_info_list: PackedScene
@export var std_avatar: Avatar
@export var game_scene: PackedScene

@onready var playername = $MainContainer/FormContainer/PlayerNameContainer/PlayerNameInput
@onready var serverbutton = $MainContainer/FormContainer/ButtonsContainer/ServerButton
@onready var clientbutton = $MainContainer/FormContainer/ButtonsContainer/ClientButton
@onready var statuslabel = $MainContainer/FormContainer/StatusLabel
@onready var startgamebutton = $MainContainer/FormContainer/StartGameButton
@onready var player_list = $MainContainer/PlayerList
@onready var portinput = $MainContainer/FormContainer/HBoxContainer3/PortInput
@onready var ipinput = $MainContainer/FormContainer/HBoxContainer2/IpInput

func _ready() -> void:
	LANLobby.init()
	Global.current_lobby = LANLobby
	LANLobby.player_connected.connect(_on_player_connected)
	LANLobby.server_disconnected.connect(_on_server_disconnected)
	LANLobby.connection_failed.connect(_on_connection_failed)
	
	portinput.text = str(LANLobby.DEFAULT_PORT)
	ipinput.text = LANLobby.DEFAULT_SERVER_IP
	
	### debug only
	playername.text = "debug player"
	get_node("MainContainer/FormContainer/AvatarContainer/Avatar1")._on_pressed()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_player_connected(id, player_info):
	var info_list = player_info_list.instantiate()
	info_list.id = id
	info_list.player_info = player_info
	player_list.add_child(info_list)

func _on_connection_failed():
	statuslabel.text = "Status: Connection failed"
	disable_buttons(false)

func _on_server_pressed() -> void:
	if not _required_data():
		return
	LANLobby.create_game()
	disable_buttons(true)
	startgamebutton.visible = true

func _on_start_pressed():
	LANLobby.start_game(game_scene.resource_path)

func _on_client_pressed() -> void:
	if not _required_data():
		return
	LANLobby.join_game(ipinput.text, portinput.text.to_int())
	disable_buttons(true)

func disable_buttons(status=false):
	serverbutton.disabled = status
	clientbutton.disabled = status

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _required_data() -> bool:
	statuslabel.text = "Status: "
	var result = true
	if not playername.text: 
		statuslabel.text += "Name required "
		result = false
	if not SelectionManager.selected_avatar:
		statuslabel.text += "Avatar required "
		result = false
	if result:
		statuslabel.text += "Waiting "
		LANLobby.player_info["name"] = playername.text
		LANLobby.player_info["avatar_id"] = SelectionManager.avatar.id
	return result

func _on_exit_pressed() -> void:
	get_tree().quit()
