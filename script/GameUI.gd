extends CanvasLayer

@onready var love_bar = $LoveBar
@onready var love_label = $LoveBar/LoveLabel
@onready var distraction_label = $DistractionLabel

# Pink color for max love
var love_color_max = Color("#FF69B4")  # Hot pink
var love_color_min = Color("#000000")  # Black

func _ready():
	var date_manager = get_node("/root/Game/DateManager")
	if date_manager:
		date_manager.love_level_changed.connect(_on_love_changed)
		date_manager.distraction_level_changed.connect(_on_distraction_changed)

func _on_love_changed(new_value: float):
	love_bar.value = new_value
	
	# Update progress bar color
	var gradient_color = love_color_min.lerp(love_color_max, new_value / 100.0)
	love_bar.modulate = gradient_color
	
	# Update label with matching color
	var label_color = love_color_min.lerp(love_color_max, new_value / 100.0)
	var color_code = label_color.to_html(false)
	love_label.text = "[center][color=#" + color_code + "]Love: " + str(ceil(new_value)) + "%[/color][/center]"

func _on_distraction_changed(count: int):
	distraction_label.text = "Distractions: " + str(count)
