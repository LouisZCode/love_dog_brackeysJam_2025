extends CanvasLayer
@onready var love_bar = $LoveBar
@onready var love_label = $LoveBar/LoveLabel
@onready var distraction_label = $DistractionLabel
@onready var timer_label: RichTextLabel = $TimerLabel
@onready var results_popup: Panel = $ResultsPopup

var love_color_max = Color("#FF69B4")  # Hot pink
var love_color_min = Color("#ffffff")  # Black

# Colors for distraction states
var distraction_colors = {
	"safe": Color("#00FF00"),    # Green
	"warning": Color("#FFFF00"), # Yellow
	"danger": Color("#FFA500"),  # Orange
	"critical": Color("#FF0000") # Red
}

var original_label_position: Vector2
var tween: Tween

@onready var minigame_manager = get_node("/root/Game/MinigameManager")

func _ready():
	var date_manager = get_node("/root/Game/DateManager")
	if date_manager:
		date_manager.love_level_changed.connect(_on_love_changed)
		date_manager.distraction_level_changed.connect(_on_distraction_changed)
	
	original_label_position = distraction_label.position
	
	if timer_label:
		timer_label.time_up.connect(_on_time_up)

func _on_love_changed(new_value: float):
	love_bar.value = new_value
	var gradient_color = love_color_min.lerp(love_color_max, new_value / 100.0)
	love_bar.modulate = gradient_color
	var label_color = love_color_min.lerp(love_color_max, new_value / 100.0)
	var color_code = label_color.to_html(false)
	love_label.text = "[center][color=#" + color_code + "]Love: " + str(ceil(new_value)) + "%[/color][/center]"

func _on_distraction_changed(count: int):
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	# Calculate color and animation intensity based on count
	var color: Color
	var scale_factor := 1.0
	var shake_amount := 0.0
	
	match count:
		0:
			color = distraction_colors["safe"]
		1:
			color = distraction_colors["safe"].lerp(distraction_colors["warning"], 0.5)
			scale_factor = 1.1
			shake_amount = 2.0
		2:
			color = distraction_colors["warning"]
			scale_factor = 1.2
			shake_amount = 4.0
		3:
			color = distraction_colors["danger"]
			scale_factor = 1.3
			shake_amount = 6.0
		_:
			color = distraction_colors["critical"]
			scale_factor = 1.4
			shake_amount = 8.0
	
	distraction_label.text = "Distractions: " + str(count)
	distraction_label.modulate = color
	
	if count > 0:
		# Single shake animation that repeats
		tween.set_loops()  # Make it repeat
		# Shake right
		tween.tween_property(distraction_label, "position", 
			original_label_position + Vector2(shake_amount, 0), 0.1)
		# Shake left
		tween.tween_property(distraction_label, "position", 
			original_label_position - Vector2(shake_amount, 0), 0.1)
		# Return to center
		tween.tween_property(distraction_label, "position", 
			original_label_position, 0.1)
		
		# Scale animation
		tween.parallel().tween_property(distraction_label, "scale", 
			Vector2.ONE * scale_factor, 0.3)
	else:
		# Reset to original state
		tween.tween_property(distraction_label, "position", 
			original_label_position, 0.2)
		tween.parallel().tween_property(distraction_label, "scale", 
			Vector2.ONE, 0.2)



func _on_time_up():
	
	# First close any active minigame
	if minigame_manager and minigame_manager.is_minigame_active:
		minigame_manager.force_end_minigame()
	
	# Then trigger results popup
	emit_signal("time_up")
	# Calculate final scores
	var final_love = love_bar.value
	var final_distractions = int(distraction_label.text.split(": ")[1])
	
	# Stop all animations and tweens
	if tween:
		tween.kill()
	
	# Show results popup
	results_popup.display_results(final_love, final_distractions)
