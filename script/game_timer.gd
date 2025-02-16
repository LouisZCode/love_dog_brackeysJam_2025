extends RichTextLabel

signal time_warning
signal time_up

@export var total_time := 180.0  # 3 minutes in seconds
@export var min_font_size := 20
@export var max_font_size := 50

var time_remaining: float
var is_running := false
var start_color := Color("#2ECC71")  # Healthy green
var end_color := Color("#FF0000")    # Blood red

func _ready():
	time_remaining = total_time
	update_display()

func _process(delta):
	if is_running:
		time_remaining = max(0, time_remaining - delta)
		update_display()
		
		# Emit warning at 30 seconds
		if time_remaining <= 30 and time_remaining > 29:
			emit_signal("time_warning")
			
		# Time's up
		if time_remaining <= 0:
			emit_signal("time_up")
			is_running = false

func update_display():
	var minutes = floor(time_remaining / 60)
	var seconds = fmod(time_remaining, 60)
	
	# Calculate time percentage
	var time_percentage = time_remaining / total_time
	
	# Interpolate color
	var current_color = start_color.lerp(end_color, 1 - time_percentage)
	
	# Interpolate font size
	var current_size = lerp(min_font_size, max_font_size, 1 - time_percentage)
	
	# Format the time with color and size
	text = "[center][color=#%s][font_size=%d]%02d:%02d[/font_size][/color][/center]" % [
		current_color.to_html(false),
		current_size,
		minutes,
		seconds
	]

func start_timer():
	is_running = true

func pause_timer():
	is_running = false

func get_time_percentage() -> float:
	return (time_remaining / total_time) * 100.0
