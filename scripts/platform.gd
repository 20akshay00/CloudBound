extends CharacterBody2D
class_name Platform

@export var coefficient_of_restitution: float = 1.2
@export var coefficient_of_friction: float = 0.
@export var collision_shape: CollisionShape2D

@export var _is_active: bool = false:
	get:
		return _is_active
	set(val):
		_is_active = val
		_set_state()

@onready var sprite := $Sprite2D
var bounce_time: float = 0.2
var shrink_time: float = 0.4
var sprite_tween: Tween = null
var _is_shrinking: bool = false

@export var _is_stormy: bool = false

var cloud_sprites := [
	preload("res://assets/cloud1.png"),
	preload("res://assets/cloud2.png")	
]

func _ready() -> void:
	sprite.texture = cloud_sprites.pick_random()
	if _is_stormy: 
		sprite.modulate = "aeaeaeff"

func _set_state():
	collision_shape.set_deferred("disabled", not _is_active)
	if _is_active: 
		self.modulate.a = 1.
		if _is_stormy:
			$DetectionArea.set_deferred("monitoring", true)
			$DetectionArea.set_deferred("monitorable", true)
	else:
		self.modulate.a = 0.2

func bounce():
	if not _is_shrinking:
		#if sprite_tween: sprite_tween.kill()
		sprite_tween = get_tree().create_tween()
		sprite_tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), bounce_time)
		sprite_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), bounce_time)
		sprite_tween.tween_property(sprite, "scale", Vector2(1., 1.), bounce_time/2)
		
		if not _is_stormy: sprite_tween.tween_callback(shrink)

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

func _on_detection_area_area_entered(area: Area2D) -> void:
	EventManager.cloud_paired.emit(self, area.get_parent())

func _on_detection_area_area_exited(area: Area2D) -> void:
	EventManager.cloud_unpaired.emit(self, area.get_parent())
