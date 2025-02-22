extends MinigameBase

@export var spots_to_clean := 5
var spot_scene = preload("res://scenes/cleaning_spot.tscn")
var paw_scene = preload("res://scenes/cleaning_paw.tscn")
var spots_cleaned := 0
var cleaning_paw

# Define the spawn area
var spawn_area = Rect2(Vector2(300, 150), Vector2(400, 250))  # Adjust these values
@onready var instruction_label = $InstructionLabel
@onready var win_sound: AudioStreamPlayer2D = $win_sound
@onready var lose_sound: AudioStreamPlayer2D = $lose_sound

func setup_minigame():
	setup_instruction_label()
	spawn_spots()
	spawn_cleaning_paw()

func spawn_cleaning_paw():
	cleaning_paw = paw_scene.instantiate()
	add_child(cleaning_paw)
	# Start paw in center of play area
	cleaning_paw.global_position = spawn_area.get_center()

func setup_instruction_label():
	instruction_label.text = "[center]Put out the [color=red][font_size=32]5[/font_size][/color] burning spots![/center]"
	instruction_label.bbcode_enabled = true

func spawn_spots():
	for i in spots_to_clean:
		var spot = spot_scene.instantiate()
		add_child(spot)
		# Random position within defined spawn area
		var x = randf_range(spawn_area.position.x, spawn_area.end.x)
		var y = randf_range(spawn_area.position.y, spawn_area.end.y)
		spot.position = Vector2(x, y)
		spot.cleaned.connect(_on_spot_cleaned)

func _on_spot_cleaned():
	spots_cleaned += 1
	update_instruction()
	if spots_cleaned >= spots_to_clean:
		win_sound.play()
		var timer = get_tree().create_timer(0.5)  # Half second delay
		timer.timeout.connect(func(): win_game())


func update_instruction():
	var remaining = spots_to_clean - spots_cleaned
	var size = int(lerp(32, 24, (spots_to_clean - remaining) / float(spots_to_clean)))
	var color = Color.RED.lerp(Color.GREEN, spots_cleaned / float(spots_to_clean))
	var color_code = color.to_html(false)
	
	instruction_label.text = "[center]Put out the[color=#%s][font_size=%d]%d[/font_size][/color] burning spots![/center]" % [
		color_code,
		size,
		remaining
	]
