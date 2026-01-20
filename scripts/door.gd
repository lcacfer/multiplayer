extends Sprite2D

@rpc("call_local", "authority", "reliable")
func show_door(status: bool = true):
	visible = status
