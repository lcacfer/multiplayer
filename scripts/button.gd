extends Sprite2D

var active: bool = false
signal activation(status: bool)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	_highlight()
	#Lobby.debug_log(name)


func _on_area_2d_body_exited(_body: Node2D) -> void:
	_highlight(false)
	#Lobby.debug_log("no " + name)

func _highlight(status: bool = true) -> void:
	active = status
	activation.emit(status)
	modulate = Color.WHITE if not status else Color.FIREBRICK
