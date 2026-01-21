extends Node

var current_lobby: Lobby

func get_avatar(_id: String = "") -> Avatar:
	if not _id: _id = current_lobby.player_info["avatar_id"]
	var _avatar = load("res://resources/"+_id+".tres")
	if _avatar: return _avatar
	return load("res://resources/p1.tres")

func get_avatar_path(_id: String = "") -> String:
	if not _id: _id = current_lobby.player_info["avatar_id"]
	return "res://images/characters/" + _id

func get_player_name() -> String:
	return current_lobby.player_info["name"]
