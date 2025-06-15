extends Node2D

@export var lightning_scene: PackedScene
@export var cloud_scene: PackedScene
@export var player: Ball

@export var snowcloud_scene: PackedScene

var pairs = []

func _ready() -> void:
	EventManager.cloud_paired.connect(_on_cloud_paired)
	EventManager.cloud_unpaired.connect(_on_cloud_unpaired)

func _on_cloud_paired(cloud1: Platform, cloud2: Platform):
	for pair in pairs:
		if (cloud1 in pair) and (cloud2 in pair):
			return
	
	pairs.append([cloud1, cloud2])
	
	var lightning := lightning_scene.instantiate()
	lightning.cloud1 = cloud1 
	lightning.cloud2 = cloud2
	call_deferred("add_child", lightning)
	call_deferred("move_child", lightning, 0)

func _on_cloud_unpaired(cloud1: Platform, cloud2: Platform):
	for idx in pairs.size():
		if (cloud1 in pairs[idx]) and (cloud2 in pairs[idx]):
			pairs.pop_at(idx)
			return

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("increase_bounce"):
		for pos in [Vector2(300., -400.), Vector2(-300., -500.)]:
			var cloud = cloud_scene.instantiate()
			cloud._is_stormy = true
			cloud.global_position = player.global_position + pos
			add_child(cloud)
			cloud.grow()
	if Input.is_action_just_pressed("decrease_bounce"):
		for pos in [Vector2(300., -400.), Vector2(-300., -500.)]:
			var cloud = snowcloud_scene.instantiate()
			cloud.global_position = player.global_position + pos
			add_child(cloud)
			cloud.grow()
