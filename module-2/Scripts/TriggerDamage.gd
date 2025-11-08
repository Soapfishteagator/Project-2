extends Area3D

@export var damage : float = 7.0
@export var explosion := false
@export var explosion_force := 13.0
@export var explosion_radius := 2.0
@export var explosion_effect_scene: PackedScene   # ✅ Added (to link Explosion.tscn in editor)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Characters"):
		for item in body.get_children():
			if item is Health:
				item.call("TakeDamage", damage)
		if explosion:
			explode()

func explode():
	if explosion_effect_scene:   # ✅ Added (spawns your Explosion.tscn)
		var explosion_instance = explosion_effect_scene.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.global_position = global_position
		explosion_instance.explode()

	for o in get_overlapping_bodies():
		if o is RigidBody3D:
			var force = (o.global_position - global_position).normalized()
			force *= explosion_force
			o.apply_central_impulse(force)
			
		elif o is CharacterBody3D:
			if o is PlayerMovement:
				o.disabled = true
				o.disableTimer = 0.5
			var force = (o.global_position - global_position).normalized()
			force *= explosion_force
			o.velocity = Vector3.ZERO
			o.velocity = force
			
	queue_free()
