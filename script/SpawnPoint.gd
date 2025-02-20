extends Marker2D
enum ProblemType { BARK, MINIGAME }

@export var problem_type: ProblemType = ProblemType.BARK
@export var minigame_name: String = ""
@export var description: String = ""

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.visible = false
		animated_sprite.stop()

# This function will be called when a problem starts using this point
func activate_problem_visuals():
	if animated_sprite:
		animated_sprite.visible = true
		animated_sprite.play("growing")

# This function will be called when a problem is solved
func deactivate_problem_visuals():
	if animated_sprite:
		animated_sprite.visible = false
		animated_sprite.stop()

func _on_problem_state_changed(new_state):
	print("SpawnPoint received state change:", new_state)  # Debug print
	if animated_sprite:
		animated_sprite.visible = true
		match new_state:
			"growing":
				print("Playing growing animation")  # Debug print
				animated_sprite.play("growing")
			"danger":
				print("Playing danger animation")  # Debug print
				animated_sprite.play("danger")
			"critical":
				print("Playing critical animation")  # Debug print
				animated_sprite.play("critical")
