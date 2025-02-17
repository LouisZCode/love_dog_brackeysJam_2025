extends Camera2D

var room_positions = {
	"DiningRoom": Vector2(0, -100),
	"Kitchen": Vector2(-1100, -300),
	"LivingRoom": Vector2(1100, -300),
	"Basement": Vector2(0, 250),
	"Attic": Vector2(0, -650)
}

@onready var rooms_node = get_node("../Rooms")

func _ready():
	# Make sure this camera is active
	make_current()
	enabled = true
	
	# Set initial position for dining room
	global_position = room_positions["DiningRoom"]

func _process(_delta):
	update_camera_for_current_room()

func update_camera_for_current_room():
	for room in rooms_node.get_children():
		if room.visible and room.name in room_positions:
			global_position = room_positions[room.name]
			break
