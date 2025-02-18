extends CharacterBody2D

@export var move_speed := 400.0
var near_endpoint: WireEndpoint = null

func _ready():
	# Start at center of screen for testing
	global_position = Vector2(500, 250)  # Adjust these values
	print("Paw initialized at: ", global_position)

func _physics_process(delta):
	# Add debug print to check if this is being called
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		print("Moving with direction: ", direction)
	
	velocity = direction * move_speed
	move_and_slide()

func _on_detection_area_entered(area: Area2D):
	if area is WireEndpoint and not area.is_connected:
		near_endpoint = area
		# Optional: Add visual feedback that we can connect here
		print("Can connect to: ", area.wire_color)

func _on_detection_area_exited(area: Area2D):
	if area == near_endpoint:
		near_endpoint = null
