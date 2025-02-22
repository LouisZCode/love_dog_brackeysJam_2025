# EndingScreen.gd
extends CanvasLayer

@onready var background_image = $BackgroundSprite
@onready var story_text = $StoryText
@onready var continue_text = $ContinueText
@onready var game_ui = get_node("/root/Game/CanvasLayer")

var typing_speed := 0.05
var is_typing := false
var text_completed := false

var congratulations_text = "[wave amp=50 freq=5][rainbow freq=0.2 sat=10 val=20]Congratulations![/rainbow][/wave]"
var regular_text = """You've been such a good boy! Thanks to your help, 
   all three dates were a complete success!

   Your owner found true love, and it's all thanks to 
   one very special guardian of romance..."""

func _ready():
   # Set up story text in center
	if story_text:
		story_text.anchors_preset = Control.PRESET_CENTER
		story_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 20)
		# Move up slightly from center
		story_text.position.y -= 150
		story_text.position.x -= 150
   
   # Set up continue text at bottom
	if continue_text:
		continue_text.anchors_preset = Control.PRESET_CENTER_BOTTOM
		continue_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_KEEP_SIZE, 20)
		continue_text.position.y -= 230
   
   # Background sprite should cover full screen
	if background_image:
		background_image.anchors_preset = Control.PRESET_FULL_RECT
		background_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	hide()

func show_ending():
	show()
	if game_ui:
		game_ui.hide()
	
	story_text.text = ""
	continue_text.modulate.a = 0
	continue_text.text = "[center]Press E to end[/center]"
	start_typing()

func start_typing():
	is_typing = true
	
	# First show congratulations with animation
	story_text.text = congratulations_text
	await get_tree().create_timer(typing_speed * 3).timeout
	
	# Add a newline before starting regular text
	story_text.text += "\n\n"
	
	# Type regular text character by character
	var current_text = story_text.text
	for iter_character in regular_text:
		if not is_typing:
			break
			
		# Skip BBCode tags
		if iter_character != "[":
			current_text += iter_character
			story_text.text = current_text
		
		if iter_character != "\n":
			await get_tree().create_timer(typing_speed).timeout
	
	text_completed = true
	show_continue_prompt()

func show_continue_prompt():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(continue_text, "modulate:a", 0.5, 1.0)
	tween.tween_property(continue_text, "modulate:a", 1.0, 1.0)

func _input(event):
	if event.is_action_pressed("interact"):  # E key
		if is_typing:
			# Skip typing animation
			is_typing = false
			story_text.text = congratulations_text + "\n\n" + regular_text
			text_completed = true
			show_continue_prompt()
		elif text_completed and visible:  # Added visible check
			# Show the UI again before freeing only when E is pressed
			if game_ui:
				game_ui.show()
			queue_free()
