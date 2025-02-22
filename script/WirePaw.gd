extends CharacterBody2D

@export var move_speed := 400.0

var near_endpoint: WireEndpoint = null

func _ready():
	global_position = Vector2(500, 250)
	print("Paw initialized at: ", global_position)

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Double the Y component
	direction.y *= 2
	
	velocity = direction * move_speed
	move_and_slide()

func _on_detection_area_entered(area: Area2D):
	if area is WireEndpoint and not area.is_connected:
		near_endpoint = area
		print("Can connect to: ", area.wire_color)

func _on_detection_area_exited(area: Area2D):
	if area == near_endpoint:
		near_endpoint = null
