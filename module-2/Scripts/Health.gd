extends Node
class_name Health

@export var max_health : float= 10.0
var health : float = max_health
@export var health_bar : bool = true
@onready var bar : ProgressBar = $HealthBar

func _ready() -> void:
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
