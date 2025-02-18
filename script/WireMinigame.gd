extends MinigameBase

var wires_connected := 0
const TOTAL_WIRES := 3
var active_wire = null
var current_start_point = null

# Define wire colors
var wire_colors = {
	"red": Color(1, 0, 0),
	"green": Color(0, 1, 0),
	"blue": Color(0, 0, 1)
}

# Store wire connections
var connections = {}
