extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -420.0
const JUMP_MAX_DURATION = 0.5
const JUMP_RELEASE_FORCE = 2.0
const AIR_SPEED_MULTIPLIER = 0.7
const COYOTE_TIME_DURATION = 0.1 # Duration for coyote time
const POGO_JUMP_VELOCITY = -500.0


var health = 6
var invincible = false
var facing_direction = 1 # 1 for right, -1 for left

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_time = 0
var pogo_jump = false
var coyote_timer = 0.0
var can_coyote_jump = false

@onready var animation_player = $AnimationPlayer
@onready var invincibility_timer = $InvincibilityTimer
@onready var player_visual = $Polygon2D
@onready var forward_attack = $ForwardAttack

# Store the base x-position of the forward attack hitbox
var forward_attack_base_x_position: float

func _ready():
	forward_attack_base_x_position = forward_attack.position.x

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer += delta
		if coyote_timer > COYOTE_TIME_DURATION:
			can_coyote_jump = false
	else:
		coyote_timer = 0.0
		can_coyote_jump = true


	# Handle Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or can_coyote_jump):
		velocity.y = JUMP_VELOCITY
		jump_time = 0
		can_coyote_jump = false # Consume coyote jump

	if Input.is_action_pressed("jump") and not is_on_floor() and jump_time < JUMP_MAX_DURATION:
		velocity.y += JUMP_VELOCITY * delta
		jump_time += delta
		
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y /= JUMP_RELEASE_FORCE


	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir:
		velocity.x = input_dir * SPEED
		if not is_on_floor():
			velocity.x *= AIR_SPEED_MULTIPLIER
			
		# Flip the player and forward attack hitbox
		if input_dir > 0:
			facing_direction = 1
		elif input_dir < 0:
			facing_direction = -1
			
		player_visual.scale.x = facing_direction
		forward_attack.scale.x = facing_direction # Flip internal contents
		forward_attack.position.x = forward_attack_base_x_position * facing_direction # Position to correct side

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	print("Input Dir: " + str(input_dir) + " | Jump: " + str(Input.is_action_pressed("jump")))


	handle_attacks()

	move_and_slide()

func handle_attacks():
	if Input.is_action_just_pressed("attack"):
		if Input.is_key_pressed(KEY_W):
			animation_player.play("attack_up")
		elif Input.is_key_pressed(KEY_S):
			pogo_jump = true
			animation_player.play("attack_down")
		else:
			animation_player.play("attack_forward")

func _on_attack_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage()
		if pogo_jump:
			velocity.y = POGO_JUMP_VELOCITY
			
func _on_animation_finished(anim_name):
	if anim_name == "attack_down":
		pogo_jump = false

func take_damage():
	if invincible:
		return
		
	health -= 1
	print("Player health: ", health)
	if health <= 0:
		get_tree().reload_current_scene()
	else:
		invincible = true
		invincibility_timer.start()

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage()

func _on_invincibility_timer_timeout():
	invincible = false
