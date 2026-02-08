extends "res://enemy.gd"

enum State {PATROL, CHARGE}

var state = State.PATROL
const CHARGE_SPEED = 200.0
var player = null

@onready var player_detection = $PlayerDetection
#@onready var edge_detector_left = $EdgeDetectorLeft
#@onready var edge_detector_right = $EdgeDetectorRight


func _ready():
	player_detection.connect("body_entered", Callable(self, "_on_player_detection_body_entered"))
	player_detection.connect("body_exited", Callable(self, "_on_player_detection_body_exited"))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		State.PATROL:
			if is_on_floor():
				if direction > 0 and not edge_detector_right.is_colliding():
					direction = -1
				elif direction < 0 and not edge_detector_left.is_colliding():
					direction = 1
			
			velocity.x = direction * SPEED
		
		State.CHARGE:
			if player:
				var player_direction = (player.global_position - global_position).normalized()
				velocity.x = player_direction.x * CHARGE_SPEED

	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.CHARGE

func _on_player_detection_body_exited(body):
	if body.is_in_group("player"):
		player = null
		state = State.PATROL
