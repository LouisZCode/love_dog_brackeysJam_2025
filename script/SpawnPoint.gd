extends Marker2D

enum ProblemType { BARK, MINIGAME }
@export var problem_type: ProblemType = ProblemType.BARK
@export var minigame_name: String = ""
@export var description: String = ""

# Animation references
@export var growing_animation: String = "growing"
@export var danger_animation: String = "danger"
@export var critical_animation: String = "critical"

# Sound references
@export var growing_sound: AudioStream
@export var danger_sound: AudioStream
@export var critical_sound: AudioStream

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D
