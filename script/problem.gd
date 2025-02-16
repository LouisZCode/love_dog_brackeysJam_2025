extends Area2D

@export var date_manager_path: NodePath
@onready var prompt_label = $RichTextLabel
@onready var date_manager = get_node("/root/Game/DateManager")

var can_interact := false
var is_active := false

func _ready():
	if not prompt_label:
		push_error("RichTextLabel node not found in Problem scene")
		return
		
	if not date_manager:
		push_error("DateManager not found! Make sure to set the path in the inspector")
		return
		
	prompt_label.text = "[center]Press E[/center]"
	prompt_label.hide()
	
	# Register this distraction
	activate_distraction()

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		solve_problem()

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		prompt_label.show()
		print("Player can interact with problem")  # Debug print

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		prompt_label.hide()

func activate_distraction():
	if date_manager:
		is_active = true
		date_manager.add_distraction()
		print("Distraction activated")  # Debug print
	else:
		push_error("Cannot activate distraction - DateManager not found")

func solve_problem():
	if is_active and date_manager:
		date_manager.remove_distraction()
		print("Problem solved!")  # Debug print
	queue_free()
