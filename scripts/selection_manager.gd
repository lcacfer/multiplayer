extends Node

var selected_avatar: bool = false
var avatar: Avatar

signal deselect_all

func select_avatar(_avatar: Avatar):
	deselect_all.emit()
	selected_avatar = true
	avatar = _avatar
