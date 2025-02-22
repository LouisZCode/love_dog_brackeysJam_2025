extends Area2D

@export var target_room: NodePath  # Relative path from DoorToKitchen to Kitchen
@export var spawn_position: Vector2
@export_enum("Left", "Right") var door_side: String

@onready var prompt_label = $RichTextLabel
@onready var rooms_node = get_node("/root/Game/Rooms")

static var is_transitioning := false

func _ready():
	prompt_label.text = "[center]Press E[/center]"
	prompt_label.hide()


func _process(delta):
	if not get_parent().visible:
		return
	
	# Add check for paused state (which is active during results popup)
	if get_tree().paused:
		return
		
	if not is_transitioning and overlaps_body(get_node("/root/Game/Player")) and Input.is_action_just_pressed("interact"):
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
		# Hide all rooms first
		for room in rooms_node.get_children():
			room.hide()
		
		# Show only the target room
		target.show()
		
		# Move player to spawn position
		var player = get_node("/root/Game/Player")
		if player:
			player.global_position = spawn_position
			print("Transitioning to ", target.name, " at position: ", spawn_position)
