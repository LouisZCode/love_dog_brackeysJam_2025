extends CharacterBody2D

@export var speed := 300.0
@export var jump_velocity := -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_at_table := false

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _on_table_area_entered(area):
	if area.name == "TableArea":
		is_at_table = true

func _on_table_area_exited(area):
	if area.name == "TableArea":
		is_at_table = false

# Called when the Problem Area is entered
func _on_problem_area_entered(area):
	if "Problem" in area.name:
		# Here we'll add the logic to fix problems
		pass
