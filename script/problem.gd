extends Area2D

@onready var prompt_label: RichTextLabel = $RichTextLabel


var can_interact := false

func _ready():
	# Make sure label exists
	if not prompt_label:
		push_error("Label node not found in Problem scene")
		return
	prompt_label.text = "Press E"
	prompt_label.hide()
	# Debug print to confirm script is running
	print("Problem initialized")

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		solve_problem()

func _on_body_entered(body):
	print("Body entered:", body.name)  # Debug print
	if body.is_in_group("player"):
		can_interact = true
		prompt_label.show()
		print("Player detected, showing prompt")  # Debug print

func _on_body_exited(body):
	print("Body exited:", body.name)  # Debug print
	if body.is_in_group("player"):
		can_interact = false
		prompt_label.hide()

func solve_problem():
	print("Problem solved!")  # Debug print
	queue_free()
