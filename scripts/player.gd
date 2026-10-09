extends CharacterBody2D

@onready var camera: Camera2D = $CameraContainer/Camera2D  
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#this is camera movement, like the bounce thing, (remove if you dont want)
@export var camera_jump: float = 15.0   
@export var camera_landing: float = 25.0   
@export var bounce_recovery_speed: float = 10.0   
@onready var corruption: TextureProgressBar = $corruption
@export var maxc := 1000
var camera_target_y: float = 0.0
var was_on_floor: bool = true

const SPEED = 300.0
#btw i understood how to do pogo, just increase the value (-250 for regular jump, -450 for pogo jump)
#ignore above. -300 for the holding jumping thing and -500 for pogo jump
#but change the values if you want
const JUMP_VELOCITY = -500.0

#acceleration adds the delay when you change directions & friction acts as friction for the ground 🤷‍♂️
@export var acceleration: float = 2500.0  
@export var friction: float = 2000.0       
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

@export var has_pogo: bool = true
@export var pogo_max_charge_time: float = 0.6
var pogo_current_charge: float = 0.0
var is_charging_pogo: bool = false
func _ready() -> void:
	audio_stream_player.play()
	if corruption:
		corruption.max_value = maxc
func _physics_process(delta: float) -> void:
	if corruption.value == 0:
		get_tree().change_scene_to_file("res://scenes/die_menu.tscn")
	#the exact frame the player lands, the player stops but the camera has to decelerate 
	if is_on_floor() and not was_on_floor:
		camera_target_y = camera_landing
		
	was_on_floor = is_on_floor()

	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.play("air")
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		camera_target_y = -camera_jump 

	#so when you release jump, the deceleration happens faster and the variable jumping happens
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = velocity.y / 2.0

	if has_pogo:
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				is_charging_pogo = true
				pogo_current_charge = 0.0
				
			
			if is_charging_pogo and Input.is_action_pressed("jump"):
				velocity.x = 0
				#this changes the curren_charge till the max_charge time (0.8s, change it if you want it to be longer, i think its fine)
				pogo_current_charge = min(pogo_current_charge + delta, pogo_max_charge_time)
				velocity.y = 0.0
				camera_target_y = 0.0
				animated_sprite_2d.play("jump_start")

			if is_charging_pogo and Input.is_action_just_released("jump"):
				#this thing decides how much of the max height you go depending on how long you held the jump button
				var charge_ratio = pogo_current_charge / pogo_max_charge_time
				velocity.y = lerp(-300.0, -750.0, charge_ratio) 
				camera_target_y = -camera_jump * (1.0 + charge_ratio)
				is_charging_pogo = false
				animated_sprite_2d.play("jump_end")
		elif is_charging_pogo:
			is_charging_pogo = false

	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	#i have no clue how this works, please explain, gemini is ass at explaining
	camera_target_y = lerp(camera_target_y, 0.0, delta * bounce_recovery_speed)
	camera.position.y = lerp(camera.position.y, camera_target_y, delta * bounce_recovery_speed)
