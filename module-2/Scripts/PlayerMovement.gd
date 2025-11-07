extends CharacterBody3D

#movement constants
const WALK_SPEED = 4.5
const SPRINT_MULTIPLIER = 1.5
const SENSITIVITY = 0.02
const GRAVITY = 19.6
const JUMP_SPEED = 9.5
const JUMP_BUFFER_TIME = 0.1
const COYOTEE_TIME = 0.1

#movement variables
var jump_buffer := 0.0
var speed := 0.0
var inputDirection := Vector2.ZERO
var coyotee_time := 0.0

#bob parameters
const BOB_AMP = 0.08
const BOB_FREQ = 2.0
var t_bob := 0.0

#camera
@onready var head = $Head
@onready var camera = $Head/Camera3D
const BASE_FOV = 70
const FOV_CHANGE = 1.3

#death
var dead := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	#camera movement
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-45), deg_to_rad(80))

func _input(event: InputEvent) -> void:
	if dead:
		if event.is_action_just_pressed("jump"):
			ResetDeath()
		return
	#input
	inputDirection = Input.get_vector("left", "right","front", "back")
	
	if event.is_action_pressed("sprint"):
		speed = WALK_SPEED * SPRINT_MULTIPLIER
	else:
		speed = WALK_SPEED
	
	if event.is_action_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME

func _physics_process(delta):
	if dead:
		return
		
	#timers
	if jump_buffer > 0:
		jump_buffer -= delta
	if coyotee_time > 0:
		coyotee_time -= delta
	
	#GRAVITY
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else :
		coyotee_time = COYOTEE_TIME
	
	#jump
	if jump_buffer > 0 && coyotee_time > 0:
		velocity.y = JUMP_SPEED
		jump_buffer = 0
		coyotee_time = 0
	
	#move
	var direction = (head.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	#camera
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var clamped_velocity = clamp(Vector3(velocity.x, 0, velocity.z).length(), 0.5, WALK_SPEED * SPRINT_MULTIPLIER)
	var target_fov = BASE_FOV + FOV_CHANGE * clamped_velocity
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func Death():
	$Head/Camera3D/Panel.visible = true	
	dead = true
	
func ResetDeath():
	$Head/Camera3D/Panel.visible = false
	for item in get_children():
		if item.name == "Head":
			item.call("RestoreHealth", 10.0)
	dead = false
