extends Node2D

var target_position: Vector2
var screen_size: Vector2
var margin := 50.0  # Distance from screen edge

func _ready():
	# Get screen size
	screen_size = get_viewport_rect().size
	# Hide initially
	hide()

func _process(_delta):
	if not visible:
		return
		
	# Get center of screen (camera position)
	var screen_center = get_viewport_rect().size / 2
	
	# Calculate direction to target
	var direction = target_position - screen_center
	
	# Determine if target is off screen
	var is_off_screen = false
	var arrow_position = Vector2.ZERO
	
	# Check if target is outside viewport
	if abs(direction.x) > screen_size.x/2 or abs(direction.y) > screen_size.y/2:
		is_off_screen = true
		
		# Calculate angle to target
		var angle = direction.angle()
		# Rotate arrow to point at target
		rotation = angle
		
		# Position arrow at screen edge
		# Calculate intersection with screen bounds
		var slope = direction.y / direction.x if direction.x != 0 else INF
		var half_width = (screen_size.x / 2) - margin
		var half_height = (screen_size.y / 2) - margin
		
		# Find intersection with screen edges
		if abs(slope) * half_width < half_height:
			# Intersects with left/right edge
			arrow_position.x = half_width * sign(direction.x)
			arrow_position.y = slope * arrow_position.x
		else:
			# Intersects with top/bottom edge
			arrow_position.y = half_height * sign(direction.y)
			arrow_position.x = arrow_position.y / slope if slope != 0 else half_width * sign(direction.x)
		
		# Position relative to screen center
		global_position = screen_center + arrow_position
	
	visible = is_off_screen

func point_to(pos: Vector2):
	target_position = pos
	show()
