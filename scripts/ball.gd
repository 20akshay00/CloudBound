extends CharacterBody2D
class_name Ball

@export var gravity: float = 200. 
@export var max_speed: float = 700.

@onready var sprites: Node2D = $Sprites
@onready var sprite_timer: Timer = $Timer
var sprite_timeout: float = 1.
var sprite_id: int = 0:
	get:
		return sprite_id
	set(val):
		if val == 1: sprite_timer.start()
		sprites.get_child(1 - val).hide()
		sprites.get_child(val).show()
		sprite_id = val

func _ready() -> void:
	sprite_timer.timeout.connect(func(): sprite_id = 0)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision: _bounce(collision)
	velocity = velocity.limit_length(max_speed)
	rotation = velocity.angle() - PI/2

func _bounce(collision: KinematicCollision2D) -> Vector2:
	sprite_id = 1
	var normal = collision.get_normal()
	var collider = collision.get_collider()
	collider.bounce(self)
	
	var normal_velocity = velocity.dot(normal) * normal
	var tangential_velocity = velocity - normal_velocity
	
	velocity = -collider.coefficient_of_restitution * normal_velocity + (1. - collider.coefficient_of_friction) * tangential_velocity
	return velocity
