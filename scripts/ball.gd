extends CharacterBody2D
class_name Ball

@export var gravity: float = 200. 
@export var max_speed: float = 800.

@onready var sprites: Node2D = $Sprites
@onready var sprite_timer: Timer = $SpriteTimer
@onready var freeze_timer: Timer = $FreezeTimer

var sprite_timeout: float = 1.
var sprite_id: int = 0:
	get:
		return sprite_id
	set(val):
		if not _is_frozen:
			if val == 1: sprite_timer.start()
			sprites.get_child(1 - val).hide()
			sprites.get_child(val).show()
			sprite_id = val

var external_acceleration := Vector2.ZERO

@export var _is_frozen: bool = false:
	get:
		return _is_frozen
	set(val):
		_is_frozen = val
		if sprites:
			if _is_frozen:
				sprites.get_child(0).hide()
				sprites.get_child(1).hide()
				sprites.get_child(2).show()
			else:
				sprites.get_child(0).show()
				sprites.get_child(2).hide()

func _ready() -> void:
	sprite_timer.timeout.connect(func(): sprite_id = 0)
	freeze_timer.timeout.connect(func(): _is_frozen = false)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity += external_acceleration * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision: _bounce(collision)
	velocity = velocity.limit_length(max_speed)
	rotation = velocity.angle() - PI/2

func _bounce(collision: KinematicCollision2D) -> Vector2:
	sprite_id = 1
	var normal = collision.get_normal()
	var collider = collision.get_collider()
	collider.bounce(self)
	
	if collider is Platform:
		if not _is_frozen:
			var normal_velocity = velocity.dot(normal) * normal
			var tangential_velocity = velocity - normal_velocity
			
			velocity = -collider.coefficient_of_restitution * normal_velocity + (1. - collider.coefficient_of_friction) * tangential_velocity
	return velocity

func freeze():
	_is_frozen = true
	freeze_timer.start()
