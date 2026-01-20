extends HBoxContainer

@export var id: int
@export var player_info: Dictionary

@onready var id_label = $Label
@onready var avatar_img = $TextureRect 
@onready var name_label = $Label2

func _ready() -> void:
	id_label.text = str(id)
	name_label.text = player_info["name"]
	# standard avatar load image
	avatar_img.texture = Global.get_avatar(player_info["avatar_id"]).image


# steam avatar load
func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	print("Avatar for user: %s" % user_id)
	print("Size: %s" % avatar_size)

	# Create the image for loading
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	# Optionally resize the image if it is too large
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)

	# Set the texture to a Sprite, TextureRect, etc.
	avatar_img.texture = avatar_texture
