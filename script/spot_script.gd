extends Area2D
signal cleaned

@onready var sprite = $AnimatedSprite2D

var can_be_cleaned := true  # Protection against multiple clicks

func _ready():
	add_to_group("cleanable")
	sprite.play("default")

func clean():
	emit_signal("cleaned")
	# Optional: Add cleaning animation
	queue_free()

func _on_input_event(_viewport, event, _shape_idx):
	if not can_be_cleaned:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		can_be_cleaned = false  # Prevent multiple triggers
		emit_signal("cleaned")
		# Optional: Add a small delay before freeing to show feedback
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
		tween.tween_callback(queue_free)
