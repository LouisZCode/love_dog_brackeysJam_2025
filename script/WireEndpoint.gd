# WireEndpoint.gd
extends Area2D

signal endpoint_clicked(endpoint)

@export var wire_color: Color
@export var is_top: bool = true

var is_connected := false
