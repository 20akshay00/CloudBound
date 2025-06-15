extends Area2D
class_name SnowCloud

@export var collision_shape: CollisionShape2D

@onready var sprite := $Sprite2D
var bounce_time: float = 0.2
var shrink_time: float = 0.4
var sprite_tween: Tween = null
var _is_shrinking: bool = false

var external_acceleration := Vector2.ZERO

var cloud_sprites := [
	preload("res://assets/cloud1.png"),
	preload("res://assets/cloud2.png"),
	preload("res://assets/cloud3.png")
]

func _ready() -> void:
	sprite.texture = cloud_sprites.pick_random()

func bounce(body: Ball):
	pass

func shrink():
	_is_shrinking = true
	reparent(get_parent().get_parent())
	collision_shape.set_deferred("disabled", true)

	if sprite_tween: sprite_tween.kill()
	sprite_tween = get_tree().create_tween()
	sprite_tween.set_parallel()
	sprite_tween.tween_property(self, "scale", Vector2(0.2, 0.2), shrink_time)
	sprite_tween.tween_property(self, "modulate:a", 0., shrink_time)
	sprite_tween.chain()
	sprite_tween.tween_callback(
			func(): EventManager.cloud_removed.emit(self); queue_free();
		)

func grow():
	scale = Vector2(0., 0.)
	modulate.a = 0.
	
	if sprite_tween: sprite_tween.kill()
	sprite_tween = get_tree().create_tween()
	sprite_tween.set_parallel()
	sprite_tween.tween_property(self, "scale", Vector2(1., 1.), shrink_time)
	sprite_tween.tween_property(self, "modulate:a", 1., shrink_time)

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		body.velocity = Vector2.ZERO
		body.freeze()
