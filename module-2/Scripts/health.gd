extends Node

@export var max_health := 10.0
var health = max_health
@export var health_bar := false
var bar : ProgressBar

func _ready() -> void:
	if health_bar:
		bar = $Camera3D/HealthBar
		bar.max_value = max_health
		bar.value = health

func TakeDamage(damage : float):
	health -= damage
	if health <= 0:
		health = 0
		Die()
	bar.value = health

func RestoreHealth(heal : float):
	TakeDamage(-heal)

func Die():
	print("dead")
	if $"..".name == "Player":
		$"..".call("Death")
