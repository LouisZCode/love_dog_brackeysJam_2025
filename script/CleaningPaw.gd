# CleaningPaw.gd
extends CharacterBody2D

@export var move_speed := 400.0
var can_clean := false
var current_spot = null

func _physics_process(delta):
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * move_speed
	move_and_slide()
	
	# Check for cleaning action
	if can_clean and current_spot and Input.is_action_just_pressed("interact"):
		current_spot.clean()

func _on_clean_area_entered(area):
	if area.is_in_group("cleanable"):
		can_clean = true
		current_spot = area

func _on_clean_area_exited(area):
	if area == current_spot:
		can_clean = false
		current_spot = null
