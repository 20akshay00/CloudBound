extends Node2D

@export var platform_scene: PackedScene
@export var clouds: Node2D 
@export var ball: Ball

var min_distance: float = 100.
var platform: Platform = null

var coefficient_of_restitution: float = 1.5
var platform_angle: float = 0.
var rotation_sensitivity: float = 5.
var restitution_sensitivity: float = 0.1

var max_clouds: int = 5

func _ready() -> void:
	_create_platform()

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if (get_global_mouse_position() - ball.global_position).length() > min_distance:
		platform.show()
		if Input.is_action_just_pressed("place"):
			_activate_platfom()
	else:
		platform.hide()
		
	var rotation_direction = 2. * (int(Input.is_action_just_released("MWU")) - int(Input.is_action_just_released("MWD")))
	if rotation_direction == 0.: rotation_direction = Input.get_axis("rotate_ccw", "rotate_cw")
	_rotate_platform(delta * rotation_sensitivity * rotation_direction)

	coefficient_of_restitution += Input.get_axis("decrease_bounce", "increase_bounce") * restitution_sensitivity
	coefficient_of_restitution = clamp(coefficient_of_restitution, 0.2, 2.)
	
func _create_platform() -> void:
	platform = platform_scene.instantiate()
	platform.coefficient_of_restitution = coefficient_of_restitution
	platform.rotation = platform_angle
	platform._is_active = false
	add_child(platform)

func _activate_platfom() -> void:
	platform._is_active = true
	platform.reparent(clouds)
	EventManager.cloud_added.emit(platform)
	_create_platform()
	
	if clouds.get_child_count() > max_clouds:
		clouds.get_child(0).shrink()

func _rotate_platform(angle: float) -> void:
	platform_angle += angle
	platform.rotation += angle
