extends Area2D

@onready var rect = $CollisionShape2D.shape
@onready var particles = $GPUParticles2D

@export var enable_particles: bool = true

func _ready() -> void:
	if enable_particles:
		var material = ParticleProcessMaterial.new()	
		
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		var extents = rect.get_size()
		material.emission_box_extents = Vector3(extents.x/2, extents.y/2, 0.)
		
		var acc = gravity * gravity_direction
		material.gravity = Vector3(acc.x, acc.y, 0.)
		
		material.alpha_curve = preload("res://Assets/alpha_curve_texture.tres")
		particles.process_material = material

	particles.emitting = enable_particles

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if (body is Ball) or (body is Platform):
		body.external_acceleration += gravity * gravity_direction

func _on_body_exited(body: Node2D) -> void:
	if (body is Ball) or (body is Platform):
		body.external_acceleration -= gravity * gravity_direction
