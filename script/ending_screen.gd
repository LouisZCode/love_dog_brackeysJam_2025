# EndingScreen.gd
extends CanvasLayer

@onready var background_image = $BackgroundSprite
@onready var story_text = $StoryText
@onready var continue_text = $ContinueText

var full_text = """[center]
[rainbow freq=0.2 sat=10 val=20]Congratulations![/rainbow]

You've been such a good boy! Thanks to your help, 
all three dates were a complete success!

Your owner found true love, and it's all thanks to 
one very special guardian of romance...
[/center]"""

var typing_speed := 0.05
var is_typing := false
var text_completed := false

func _ready():
	# Hide at start - we'll show it only when called
	hide()

func show_ending():
	show()
	story_text.text = ""
	continue_text.modulate.a = 0
	continue_text.text = "[center]Press E to end[/center]"
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
			# Here you can either quit the game or return to title
			queue_free()
