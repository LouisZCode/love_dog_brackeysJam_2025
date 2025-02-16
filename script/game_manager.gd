extends Node

enum GameState {MENU, PLAYING, PAUSED, GAME_OVER}
var current_state: GameState = GameState.MENU
var love_meter: float = 50.0  # Start at 50%
var elapsed_time: float = 0.0

func _ready():
	# Initialize game systems
	pass

func start_game():
	current_state = GameState.PLAYING
	love_meter = 50.0
	elapsed_time = 0.0

func _process(delta):
	if current_state == GameState.PLAYING:
		elapsed_time += delta
		# Update game logic here
