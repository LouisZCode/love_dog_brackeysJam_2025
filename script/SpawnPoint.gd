extends Marker2D

# Using the same enum as in Problem script
enum ProblemType { BARK, MINIGAME }

@export var problem_type: ProblemType = ProblemType.BARK
@export var minigame_name: String = ""  # Only used if type is MINIGAME

# Optional: add description to help organize in editor
@export var description: String = ""
