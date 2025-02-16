extends Area2D

@export var target_room: NodePath = "../Kitchen"  # Relative path from DoorToKitchen to Kitchen
@export var spawn_position: Vector2
@export_enum("Left", "Right") var door_side: String

@onready var prompt_label = $RichTextLabel

func _ready():
	prompt_label.text = "[center]Press E[/center]"
	prompt_label.hide()

func _process(_delta):
	if overlaps_body(get_node("/root/Game/Player")) and Input.is_action_just_pressed("interact"):
		transition_to_room()

func _on_body_entered(body):
	if body.is_in_group("player"):
		prompt_label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		prompt_label.hide()

func transition_to_room():
	var target = get_node(target_room)
	if target:
		# Hide current room, show target room
		get_parent().hide()  # DiningRoom
		target.show()
		
		# Move player to spawn position
		var player = get_node("/root/Game/Player")
		if player:
			player.global_position = spawn_position
		print("Transitioning to Kitchen at position: ", spawn_position)
