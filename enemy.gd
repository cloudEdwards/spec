extends CharacterBody2D

const SPEED = 100.0
var direction = -1

@onready var edge_detector_left = $EdgeDetectorLeft
@onready var edge_detector_right = $EdgeDetectorRight

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		if direction > 0 and not edge_detector_right.is_colliding():
			direction = -1
		elif direction < 0 and not edge_detector_left.is_colliding():
			direction = 1
			
	velocity.x = direction * SPEED
	
	move_and_slide()

func take_damage():
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
