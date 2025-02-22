# IntroScreen.gd
extends CanvasLayer

@onready var background_image = $BackgroundSprite
@onready var story_text = $StoryText
@onready var continue_text = $ContinueText

var full_text = """....today I have a very important mission...\n\nYou are going on a date, You’re feeling a little lonely and this date means a lot\n\n...and I need to make sure everything goes well!\n\nI'll prevent any distractions that could ruin their special moment...\n\nDon’t worry, I’ve got your back.
	"""

var typing_speed := 0.05  # Seconds between each character
var is_typing := false
var text_completed := false


func _ready():
	# Make sure everything is visible at start
	show()
	
	# Start with empty text
	story_text.text = ""
	
	# Hide continue prompt initially
	continue_text.modulate.a = 0
	continue_text.text = "[center]Press E to start[/center]"
	
	# Start typing effect
	start_typing()

func start_typing():
	is_typing = true
	var current_text := ""
	var visible_text := ""
	
	for character in full_text:
		if not is_typing:  # Check if typing was interrupted
			break
			
		current_text += character
		if character != "[":  # Skip BBCode tags
			visible_text += character
		story_text.text = current_text
		
		# Wait for typing speed duration
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
			story_text.text = full_text
			text_completed = true
			show_continue_prompt()
		elif text_completed:
			# Hide everything and stop processing input
			queue_free()  # This will remove the intro screen completely
