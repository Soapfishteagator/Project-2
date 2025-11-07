extends Area3D

@export var damage : float = 7.0

@export var explosion := false
@export var explosion_force := 100.0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Characters"):
		for health in body.get_children():
			if health.name == "Head":
				health.call("TakeDamage", damage)
		if explosion:
			explode()

func explode():
	queue_free()
