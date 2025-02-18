class_name WireEndpoint
extends Area2D

@export var wire_color: Color
@export var is_top: bool
var is_connected := false

@onready var color_rect = $ColorRect

func _ready():
	color_rect.color = wire_color

func is_point_inside(point: Vector2) -> bool:
	return $CollisionShape2D.get_shape().contains(to_local(point))
