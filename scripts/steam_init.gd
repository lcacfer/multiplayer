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
@onready var lobbyinput = $MainContainer/FormContainer/HBoxContainer2/LobbyInput
@onready var invitebutton = $MainContainer/FormContainer/ButtonsContainer2/InviteButton
func _ready() -> void:
	SteamLobby.init()
	Global.current_lobby = SteamLobby
	# event callback when invited by friend
	Steam.join_requested.connect(_on_join_requested)
	# events from lobby
	SteamLobby.player_connected.connect(_on_player_connected)
	SteamLobby.server_created.connect(_on_server_created)
	SteamLobby.server_disconnected.connect(_on_server_disconnected)
	SteamLobby.connection_failed.connect(_on_connection_failed)

	### debug only
	playername.text = Steam.getFriendPersonaName(Steam.getSteamID())
	get_node("MainContainer/FormContainer/AvatarContainer/Avatar1")._on_pressed()

func _on_server_pressed() -> void:
	if not _required_data():
		return
	SteamLobby.create_game()
	disable_buttons(true)
	startgamebutton.visible = true

func _on_server_created():
	lobbyinput.text = str(SteamLobby.lobby_id)
	invitebutton.disabled = false

func _on_start_pressed():
	SteamLobby.start_game(game_scene.resource_path)

func _on_client_pressed() -> void:
	if not _required_data():
		return
	SteamLobby.join_game(lobbyinput.text.to_int())
	#Lobby.player_connected.connect(_on_joined_game)
	disable_buttons(true)

func _on_player_connected(id, player_info):
	# TODO: Refactor for steam user data/avatar
	var info_list = player_info_list.instantiate()
	info_list.id = id
	info_list.player_info = player_info
	player_list.add_child(info_list)

func _on_connection_failed():
	statuslabel.text = "Status: Connection failed"
	disable_buttons(false)

func _on_join_requested(_lobby_id: int, _friend_id: int) -> void:
	if not _required_data():
		return
	lobbyinput.text = str(_lobby_id)
	disable_buttons(true)
	SteamLobby.join_game(_lobby_id)

func disable_buttons(status=false):
	serverbutton.disabled = status
	clientbutton.disabled = status

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_overlay_button_pressed() -> void:
	Steam.activateGameOverlay()

func _on_invite_button_pressed() -> void:
	Steam.activateGameOverlayInviteDialog(SteamLobby.lobby_id)

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
		SteamLobby.player_info["name"] = playername.text
		SteamLobby.player_info["avatar"] = SelectionManager.avatar
		SteamLobby.player_info["avatar_id"] = SelectionManager.avatar.id
	return result
