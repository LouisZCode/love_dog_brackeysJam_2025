extends Marker2D
enum ProblemType { BARK, MINIGAME }

@export var problem_type: ProblemType = ProblemType.BARK
@export var minigame_name: String = ""
@export var description: String = ""

@onready var growing_sound: AudioStreamPlayer2D = $"../SpawnPoint5/GrowingStateSound"

@onready var animated_sprite = $AnimatedSprite2D
@onready var danger_sound = $DangerStateSound
@onready var critical_sound = $CriticalStateSound

func _ready():
	if animated_sprite:
		animated_sprite.visible = false
		animated_sprite.stop()
	
	growing_sound.stream.loop = true
	danger_sound.stream.loop = true
	critical_sound.stream.loop = true
	
	# Stop any sounds that might be playing
	growing_sound.stop()
	danger_sound.stop()
	critical_sound.stop()

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

func stop_all_sounds():
	growing_sound.stop()
	danger_sound.stop()
	critical_sound.stop()

func _on_problem_state_changed(new_state):
	print("SpawnPoint received state change:", new_state)
	if animated_sprite:
		animated_sprite.visible = true
		match new_state:
			"growing":
				animated_sprite.play("growing")
				# Stop other sounds and play growing sound
				danger_sound.stop()
				critical_sound.stop()
				growing_sound.play()
				
			"danger":
				animated_sprite.play("danger")
				# Stop other sounds and play danger sound
				growing_sound.stop()
				critical_sound.stop()
				danger_sound.play()
				
			"critical":
				animated_sprite.play("critical")
				# Stop other sounds and play critical sound
				growing_sound.stop()
				danger_sound.stop()
				critical_sound.play()
