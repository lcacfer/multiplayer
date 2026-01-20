extends Node2D


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_steam_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/steam_init.tscn")

func _on_lan_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lan_init.tscn")
