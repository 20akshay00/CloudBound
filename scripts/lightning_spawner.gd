extends Node2D

@export var lightning_scene: PackedScene

var pairs = []

func _ready() -> void:
	EventManager.cloud_paired.connect(_on_cloud_paired)
	EventManager.cloud_removed.connect(_on_cloud_unpaired)

func _on_cloud_paired(cloud1: Platform, cloud2: Platform):
	for pair in pairs:
		if (cloud1 in pair) and (cloud2 in pair):
			return
	
	pairs.append([cloud1, cloud2])
	
	var lightning := lightning_scene.instantiate()
	lightning.cloud1 = cloud1 
	lightning.cloud2 = cloud2
	call_deferred("add_child", lightning)

func _on_cloud_unpaired(cloud1: Platform, cloud2: Platform):
	for idx in pairs.length():
		if (cloud1 in pairs[idx]) and (cloud2 in pairs[idx]):
			pairs.pop_at(idx)
			return
