extends Area2D

@export var date_manager_path: NodePath
@onready var prompt_label = $RichTextLabel
@onready var date_manager = get_node(date_manager_path)
var direction_arrow: Node2D

var can_interact := false
var is_active := false

func _ready():
	if not prompt_label:
		push_error("RichTextLabel node not found in Problem scene")
		return
		
	prompt_label.text = "[center]Press E[/center]"
	prompt_label.hide()
	
	# Create direction arrow
	var arrow_scene = preload("res://scenes/direction_arrow.tscn")  # Adjust path
	direction_arrow = arrow_scene.instantiate()
	get_node("/root/Game/CanvasLayer").add_child(direction_arrow)
	
	# Start pointing
	direction_arrow.point_to(global_position)
	
	# Register this distraction
	activate_distraction()

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

func solve_problem():
	if is_active and date_manager:
		date_manager.remove_distraction()
	queue_free()
