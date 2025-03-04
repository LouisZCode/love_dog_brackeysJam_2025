extends MinigameBase

var wires_connected := 0
const TOTAL_WIRES := 3
var active_wire = null
var current_line: Line2D = null
@onready var paw = $WirePaw
@onready var win_sound: AudioStreamPlayer2D = $win_sound
@onready var lose_sound: AudioStreamPlayer2D = $lose_sound

# Define wire colors with their positions
var wire_pairs = {
	"red": {"color": Color(1, 0, 0)},
	"green": {"color": Color(0, 1, 0)},
	"blue": {"color": Color(0, 0, 1)}
}

func _ready():
	setup_endpoints()
	setup_instruction_label()

func setup_instruction_label():
	$InstructionLabel.text = """[center]Connect the wires with [wave amp=50 freq=5][rainbow freq=0.2 sat=10 val=20]matching colors![/rainbow][/wave][/center]"""
	$InstructionLabel.bbcode_enabled = true

func setup_endpoints():
	var y_top = 100
	var y_bottom = 400
	var positions = [Vector2(400, 75), Vector2(600, 75), Vector2(800, 75)]
	
	# Randomize endpoint positions
	positions.shuffle()
	
	# Set up top endpoints
	for i in range(3):
		var color = wire_pairs.keys()[i]
		var top_endpoint = $TopEndpoints.get_child(i)
		top_endpoint.position = positions[i] + Vector2(0, y_top)
		top_endpoint.wire_color = wire_pairs[color]["color"]
		wire_pairs[color]["top"] = top_endpoint
	
	# Randomize again for bottom endpoints
	positions.shuffle()
	
	# Set up bottom endpoints
	for i in range(3):
		var color = wire_pairs.keys()[i]
		var bottom_endpoint = $BottomEndpoints.get_child(i)
		bottom_endpoint.position = positions[i] + Vector2(0, y_bottom)
		bottom_endpoint.wire_color = wire_pairs[color]["color"]
		wire_pairs[color]["bottom"] = bottom_endpoint

func _process(_delta):
	# Update line position if we're dragging a wire
	if current_line and active_wire:
		current_line.points[1] = paw.global_position

	# Check for connection attempts when pressing E
	if Input.is_action_just_pressed("interact"):
		if paw.near_endpoint:  # If we're near an endpoint
			if not active_wire:
				# Start new wire connection
				start_wire(paw.near_endpoint)
			else:
				# Try to complete wire connection
				try_connect_wire(paw.near_endpoint)

func start_wire(endpoint: WireEndpoint):
	print("Starting wire from: ", endpoint.wire_color)
	active_wire = endpoint
	current_line = Line2D.new()
	current_line.default_color = endpoint.wire_color
	current_line.width = 5
	current_line.points = [endpoint.global_position, paw.global_position]
	$WireContainer.add_child(current_line)

func try_connect_wire(endpoint: WireEndpoint):
	print("Trying to connect to: ", endpoint.wire_color)
	if endpoint.wire_color == active_wire.wire_color and endpoint.is_top != active_wire.is_top:
		# Valid connection - keep the line and mark endpoints as connected
		endpoint.is_connected = true
		active_wire.is_connected = true
		current_line.points[1] = endpoint.global_position  # Snap to endpoint
		wires_connected += 1
		
		# Wait a small moment before winning
		if wires_connected == TOTAL_WIRES:
			win_sound.play()
			var timer = get_tree().create_timer(0.5)  # Half second delay
			timer.timeout.connect(func(): win_game())
	else:
		# Invalid connection - remove the line
		lose_sound.play()
		current_line.queue_free()
	
	active_wire = null
	current_line = null

func get_endpoints() -> Array:
	return $TopEndpoints.get_children() + $BottomEndpoints.get_children()
