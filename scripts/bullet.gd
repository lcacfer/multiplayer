extends RigidBody2D

const SPEED: float = 300
const DURATION: float = 1

@export var velocity: Vector2
@export var color: Color = Color.WHITE
@export var player_id: int

const DAMAGE: float = 10.0

func _enter_tree() -> void:
	Global.current_lobby.debug_log("enter bullet: %d %s %s" % [player_id, color, velocity])
	#get_parent().get_multiplayer_authority()
	#Global.current_lobby.debug_log("bullet authority: %s" % get_parent().get_parent().name)
	#set_multiplayer_authority(get_parent().get_parent().name.to_int())

func _ready() -> void:
	if not velocity == Vector2.ZERO:
		linear_velocity = velocity.normalized() * SPEED
	else:
		linear_velocity = Vector2(0, SPEED)
	var timer = Timer.new()
	$Sprite2D.modulate = color
	if not is_multiplayer_authority(): return
	timer.autostart = true
	timer.wait_time = DURATION
	timer.timeout.connect(_on_bullet_timeout)
	add_child(timer)

func _on_bullet_timeout():
	#rpc("dispose_bullet")
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func dispose_bullet():
	if not is_multiplayer_authority(): return
	call_deferred("queue_free")
