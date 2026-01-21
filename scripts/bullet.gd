class_name Bullet
extends RigidBody2D

const SPEED: float = 300

@export var velocity: Vector2
@export var color: Color = Color.WHITE
@export var player_id: int

@onready var sprite = $Sprite2D

const DAMAGE: float = 10.0

func _enter_tree() -> void: # server manages bullets
	set_multiplayer_authority(1)

func _ready() -> void:
	if multiplayer.is_server(): # duration timer only on server
		$Duration.start()
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	sprite.modulate = color

func dispose_bullet():
	if is_multiplayer_authority(): call_deferred("queue_free")
