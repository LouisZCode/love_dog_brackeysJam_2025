extends Node

signal minigame_started
signal minigame_ended(was_successful: bool)

var current_minigame: Node = null
var current_problem: Node = null
var is_minigame_active := false

# Dictionary to map minigame names to their scene paths
var minigame_scenes := {
	"wire_fix": "res://scenes/minigames/wire_fix.tscn",
	"quick_clean": "res://scenes/minigames/quick_clean.tscn",
	"pattern_match": "res://scenes/minigames/pattern_match.tscn"
}

func start_minigame(minigame_name: String, problem: Node) -> bool:
	if is_minigame_active:
		return false
	
	if not minigame_name in minigame_scenes:
		push_error("Minigame not found: " + minigame_name)
		return false
	
	# Store reference to problem that started this minigame
	current_problem = problem
	
	# Load and instance the minigame scene
	var minigame_scene = load(minigame_scenes[minigame_name])
	if not minigame_scene:
		push_error("Could not load minigame scene: " + minigame_name)
		return false
	
	current_minigame = minigame_scene.instantiate()
	
	# Connect to minigame signals
	current_minigame.minigame_won.connect(_on_minigame_won)
	current_minigame.minigame_lost.connect(_on_minigame_lost)
	
	# Add minigame to scene
	add_child(current_minigame)
	
	# Pause main game systems
	get_tree().paused = true
	current_minigame.process_mode = Node.PROCESS_MODE_ALWAYS
	
	is_minigame_active = true
	emit_signal("minigame_started")
	return true

func _on_minigame_won():
	end_minigame(true)

func _on_minigame_lost():
	end_minigame(false)

func end_minigame(was_successful: bool):
	if not is_minigame_active:
		return
	
	# Resume main game
	get_tree().paused = false
	
	# Handle the problem based on result
	if was_successful and current_problem:
		current_problem.solve_problem()
	
	# Clean up minigame
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null
	
	current_problem = null
	is_minigame_active = false
	
	emit_signal("minigame_ended", was_successful)

# Optional: Force end current minigame (useful for debugging or emergency exits)
func force_end_minigame():
	if is_minigame_active:
		end_minigame(false)
