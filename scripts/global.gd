extends Node

var current_lobby: Lobby

func get_avatar(id: String) -> Avatar:
	var _avatar = load("res://resources/"+id+".tres")
	if _avatar: return _avatar
	return load("res://resources/p1.tres")
