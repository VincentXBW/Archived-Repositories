extends CharacterBody3D

@export var MAX_SPEED = 10.0         
@export var SPRINT_SPEED = 15.0      
@export var CROUCH_SPEED = 4.0
@export var ACCELERATION = 10.0      
@export var FRICTION = 5.0          
@export var JUMP_VELOCITY = 7.5     
@export var GRAVITY = 25.0          

@export var AIR_ACCEL = 100.0       
@export var AIR_MAX_SPEED = 2.0     

@export var BOB_FREQUENCY = 1.5       
@export var BOB_AMPLITUDE = 0.05      
@export var ROLL_AMOUNT = 0.025       
@export var ROLL_SPEED = 5.0

@export var TOGGLE_CROUCH_SPEED = 10.0
var normal_height = 2.0
var crouch_height = 1.0
var normal_pivot_y = 1.2
var crouch_pivot_y = 0.5

const SAVE_PATH = "user://savegame.json"
@export var gear: Array[String] = ["starter_sword", "health_potion"] 

@onready var twist_pivot = $TwistPivot
@onready var pitch_pivot = $TwistPivot/PitchPivot
@onready var fp_camera = $TwistPivot/PitchPivot/FPCamera
@onready var tp_spring_arm = $TPSpringArm
@onready var tp_camera = $TPSpringArm/TPCamera
@onready var collision_shape = $CollisionShape3D

var mouse_sensitivity = 0.0025
var is_crouching = false
var is_sprinting = false            
var bob_time = 0.0
var current_roll = 0.0
var step_timer = 0.0 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fp_camera.current = true
	tp_camera.current = false
	twist_pivot.position.y = normal_pivot_y  
	load_game()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		pitch_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -deg_to_rad(85), deg_to_rad(85))
		
		tp_spring_arm.rotation.y = twist_pivot.rotation.y
		tp_spring_arm.rotation.x = pitch_pivot.rotation.x

	if Input.is_key_pressed(KEY_F5):
		save_game()
	if Input.is_key_pressed(KEY_F6):
		load_game()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching
	
	if collision_shape and collision_shape.shape is CapsuleShape3D:
		var target_height = crouch_height if is_crouching else normal_height
		var target_pivot = crouch_pivot_y if is_crouching else normal_pivot_y
		
		collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, delta * TOGGLE_CROUCH_SPEED)
		collision_shape.position.y = collision_shape.shape.height / 2.0
		twist_pivot.position.y = lerp(twist_pivot.position.y, target_pivot, delta * TOGGLE_CROUCH_SPEED)

	var target_max_speed = MAX_SPEED
	if is_crouching:
		target_max_speed = CROUCH_SPEED
	elif is_sprinting:
		target_max_speed = SPRINT_SPEED

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if is_crouching:
			var forward_dir = -twist_pivot.global_transform.basis.z.normalized()
			velocity += forward_dir * (target_max_speed * 1.2)
			velocity.y = JUMP_VELOCITY * 0.75

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var wish_dir = (twist_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		var speed = velocity.length()
		if speed != 0:
			var drop = speed * FRICTION * delta
			velocity *= max(speed - drop, 0) / speed
		
		if wish_dir != Vector3.ZERO:
			var current_speed = velocity.dot(wish_dir)
			var add_speed = target_max_speed - current_speed
			if add_speed > 0:
				var accel_speed = ACCELERATION * target_max_speed * delta
				accel_speed = min(accel_speed, add_speed)
				velocity += wish_dir * accel_speed
	else:
		if wish_dir != Vector3.ZERO:
			var current_speed = velocity.dot(wish_dir)
			var add_speed = AIR_MAX_SPEED - current_speed
			if add_speed > 0:
				var accel_speed = AIR_ACCEL * target_max_speed * delta
				accel_speed = min(accel_speed, add_speed)
				velocity += wish_dir * accel_speed

	move_and_slide()

	if step_timer > 0.0:
		step_timer -= delta

	if is_on_floor() and input_dir != Vector2.ZERO:
		bob_time += delta * BOB_FREQUENCY * (target_max_speed * 0.7)
		fp_camera.transform.origin.y = sin(bob_time) * BOB_AMPLITUDE
	else:
		bob_time = 0.0
		fp_camera.transform.origin.y = lerp(fp_camera.transform.origin.y, 0.0, delta * 10.0)
		step_timer = 0.0 

	var target_roll = -input_dir.x * ROLL_AMOUNT
	current_roll = lerp(current_roll, target_roll, delta * ROLL_SPEED)
	fp_camera.rotation.z = current_roll
	tp_camera.rotation.z = current_roll

func save_game():
	var save_data = {
		"position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z
		},
		"gear": gear
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.get_data()
			
			if "position" in data:
				var pos = data["position"]
				global_position = Vector3(pos.x, pos.y, pos.z)
			
			if "gear" in data:
				gear.assign(data["gear"])
