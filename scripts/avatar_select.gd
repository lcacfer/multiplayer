extends TextureButton

@export var avatar: Avatar
@export var selected_color: Color
@export var highlighted_color: Color
@export var selected: bool = false

func _ready() -> void:
	texture_normal = avatar.image 
	SelectionManager.deselect_all.connect(deselect)

func _on_mouse_entered() -> void:
	if not selected: highlight()

func _on_mouse_exited() -> void:
	if not selected: highlight(false)

func _on_pressed() -> void:
	if selected:
		SelectionManager.selected_avatar = false
		selected = false
		highlight(false)
	else:
		SelectionManager.select_avatar(avatar)
		selected = true
		highlight()
	
func highlight(shader_enabled: bool = true):
	if material:
		material.set_shader_parameter("outline_color", selected_color if selected else highlighted_color)	
		material.set_shader_parameter("enabled", shader_enabled)

func deselect() -> void:
	selected = false
	highlight(false)
