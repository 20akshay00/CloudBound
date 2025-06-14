extends Area2D
class_name Wall

@export var wall: Wall
@export var dir: int = -1

func _ready() -> void:
	$CollisionShape2D.shape.normal.x = dir

func _on_body_entered(body: Node2D) -> void:
	if body is Ball and sign(body.velocity.x) == -dir:
		body.position.x = wall.position.x + dir * body.sprites.get_child(0).texture.get_size().y/2
