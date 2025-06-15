extends Area2D

@onready var collision_shape: SegmentShape2D = $CollisionShape2D.shape
@onready var sprite: Sprite2D = $Sprite2D

var cloud1: Platform
var cloud2: Platform

func _ready() -> void:
	if cloud1.global_position.x > cloud2.global_position.x: 
		var temp = cloud1
		cloud1 = cloud2
		cloud2 = temp
		
	EventManager.cloud_removed.connect(_on_cloud_removed)
	EventManager.cloud_unpaired.connect(_on_cloud_unpaired)

func _process(delta: float) -> void:
	_set_points()

func _on_cloud_removed(cloud: Platform) -> void:
	if (cloud == cloud1) or (cloud == cloud2):
		_on_death()

func _on_cloud_unpaired(clouda: Platform, cloudb: Platform) -> void:
	if cloud1 == clouda and cloud2 == cloudb:
		_on_death()

func _set_points():
	collision_shape.a = cloud1.global_position
	collision_shape.b = cloud2.global_position
	
	var dist = collision_shape.a - collision_shape.b
	sprite.scale.y = dist.length() / sprite.texture.get_width()
	sprite.rotation = atan2(dist.y, dist.x) + PI/2
	sprite.position = collision_shape.a - dist/2
	
	if dist.length() > 2 * cloud1.get_node("DetectionArea/CollisionShape2D").shape.radius:
		_on_death()

func _on_death():
	if self: queue_free()
