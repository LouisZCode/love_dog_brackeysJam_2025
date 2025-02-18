# Wire.gd
extends Node2D

signal wire_clicked(wire)
signal connection_point_clicked(point, color)

@export var wire_color: Color = Color.RED
var is_connected := false
var connection_point: Vector2

func _ready():
	# Set up wire visual
	$ColorRect.color = wire_color
	connection_point = position
