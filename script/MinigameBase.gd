extends CanvasLayer

signal minigame_won
signal minigame_lost

@export var time_limit := 10.0  # Time to complete minigame
@export var debug_mode := false

var time_remaining: float
var is_active := false

# Called when minigame starts
func _ready():
	time_remaining = time_limit
	setup_minigame()
	is_active = true

func _process(delta):
	if is_active:
		update_timer(delta)
		update_game_state()

func setup_minigame():
	# Override this in specific minigames to set up their unique elements
	pass

func update_game_state():
	# Override this to implement specific minigame logic
	pass

func update_timer(delta):
	time_remaining -= delta
	if time_remaining <= 0:
		on_time_up()

func on_time_up():
	# Default behavior is to lose when time runs out
	# Override if needed for specific minigames
	lose_game()

func win_game():
	is_active = false
	emit_signal("minigame_won")

func lose_game():
	is_active = false
	emit_signal("minigame_lost")

# Optional: Add debug information
func _input(event):
	if debug_mode and event.is_action_pressed("ui_cancel"):
		lose_game()  # Emergency exit for testing
