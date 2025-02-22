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
var regular_text = """

You've been such a good boy! Thanks to your help, 
all three dates were a complete success!

Your owner found true love, and it's all thanks to 
one very special guardian of romance..."""

func _ready():
	hide()

func show_ending():
	show()
	if game_ui:
		game_ui.hide()
		
	story_text.text = ""
	continue_text.modulate.a = 0
	continue_text.text = "Press E to end"
	start_typing()

func start_typing():
	is_typing = true
	
	story_text.text = congratulations_text
	await get_tree().create_timer(typing_speed * 3).timeout
	
	for character in regular_text:
		if not is_typing:
			break
			
		story_text.text += character
		if character != "\n":
			await get_tree().create_timer(typing_speed).timeout
	
	text_completed = true
	show_continue_prompt()

# ... rest remains the same ...

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
			story_text.text = "" + congratulations_text + "\n" +  regular_text + ""
			text_completed = true
			show_continue_prompt()
		elif text_completed:
			# Show the UI again before freeing
			if game_ui:
				game_ui.show()
			queue_free()
