extends Area2D

@onready var prompt_label: RichTextLabel = $RichTextLabel

var can_interact := false

func _ready():
	prompt_label.hide()

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		solve_problem()

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		prompt_label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		prompt_label.hide()

func solve_problem():
	# Play solve animation/sound here later
	queue_free()  # For now, just remove the problem
