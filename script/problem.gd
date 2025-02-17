extends Area2D

@onready var prompt_label = $RichTextLabel
@onready var date_manager = get_node("/root/Game/DateManager")  # Direct path to DateManager
var direction_arrow: Node2D

var can_interact := false
var is_active := false

func _ready():
	if not prompt_label:
		push_error("RichTextLabel node not found in Problem scene")
		return
		
	if not date_manager:
		push_error("DateManager not found! Check the path!")
		return
		
	prompt_label.text = "[center]Press E[/center]"
	prompt_label.hide()

	
	# Register this distraction
	activate_distraction()
	print("Problem created and registered with DateManager")

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		solve_problem()

func _exit_tree():
	if direction_arrow:
		direction_arrow.queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		prompt_label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		prompt_label.hide()

func activate_distraction():
	if date_manager:
		is_active = true
		date_manager.add_distraction()
		print("Distraction activated, total distractions:", date_manager.active_distractions)
	else:
		push_error("Cannot activate distraction - DateManager not found")

func solve_problem():
	if is_active and date_manager:
		date_manager.remove_distraction()
		print("Problem solved, remaining distractions:", date_manager.active_distractions)
	queue_free()
