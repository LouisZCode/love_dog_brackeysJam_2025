extends Area2D

signal problem_solved

enum ProblemType { BARK, MINIGAME }
enum ProblemState { GROWING, DANGEROUS }

@export var problem_type: ProblemType = ProblemType.BARK
@export var bark_time_required := 2.0
@export var growing_time := 10.0
@export var dangerous_time := 10.0

@onready var prompt_label = $RichTextLabel
@onready var date_manager = get_node("/root/Game/DateManager")
@onready var sprite = $ColorRect
@onready var growing_bar = $GrowingBar
@onready var danger_bar = $DangerBar

var can_interact := false
var is_active := false
var bark_timer := 0.0
var is_barking := false

var current_state := ProblemState.GROWING
var growing_timer := 0.0
var danger_timer := 0.0

var minigame_name: String = ""  # Will be set by spawn point

func _ready():
	if not prompt_label:
		push_error("RichTextLabel node not found")
		return
		
	if not date_manager:
		push_error("DateManager not found!")
		return
	
	setup_progress_bars()
	update_prompt_text()
	prompt_label.hide()
	activate_distraction()
	print("Problem created and registered with DateManager")

func setup_progress_bars():
	# Growing bar (yellow)
	growing_bar.max_value = growing_time
	growing_bar.value = 0
	growing_bar.modulate = Color("FFD700")  # Yellow
	
	# Danger bar (red)
	danger_bar.max_value = dangerous_time
	danger_bar.value = 0
	danger_bar.modulate = Color("FF0000")  # Red
	danger_bar.hide()  # Hidden initially

func _process(delta):
	update_timers(delta)
	handle_interaction(delta)
	update_visibility()

func update_timers(delta):
	match current_state:
		ProblemState.GROWING:
			growing_timer += delta
			growing_bar.value = growing_timer
			
			if growing_timer >= growing_time:
				transition_to_dangerous()
				
		ProblemState.DANGEROUS:
			danger_timer += delta
			danger_bar.value = danger_timer
			
			if danger_timer >= dangerous_time:
				on_problem_timeout()

func transition_to_dangerous():
	current_state = ProblemState.DANGEROUS
	growing_bar.hide()
	danger_bar.show()
	update_prompt_text()
	# Add it as a dangerous distraction that affects love
	if date_manager:
		date_manager.add_dangerous_distraction()
		print("Problem became dangerous and now affects love!")

func on_problem_timeout():
	# This will be implemented later for game over
	print("Problem reached critical state!")
	# For now, just make it more urgent
	sprite.modulate = Color.RED

func handle_interaction(delta):
	if can_interact:
		match problem_type:
			ProblemType.BARK:
				if Input.is_action_pressed("interact"):
					is_barking = true
					bark_timer += delta
					var progress = (bark_timer / bark_time_required) * 100
					prompt_label.text = "[center]Barking... %d%%[/center]" % progress
					
					if bark_timer >= bark_time_required:
						solve_problem()
				else:
					if is_barking:
						bark_timer = 0.0
						is_barking = false
						update_prompt_text()
						
			ProblemType.MINIGAME:
				if Input.is_action_just_pressed("interact"):
					start_minigame()
					# Add a debug print
					print("Starting minigame attempt")

func update_visibility():
	var my_room = get_parent().get_parent().get_parent()
	if my_room:
		sprite.visible = my_room.visible
		prompt_label.visible = my_room.visible and can_interact
		growing_bar.visible = my_room.visible and current_state == ProblemState.GROWING
		danger_bar.visible = my_room.visible and current_state == ProblemState.DANGEROUS

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		if get_parent().get_parent().get_parent().visible:
			prompt_label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		prompt_label.hide()

func update_prompt_text():
	match problem_type:
		ProblemType.BARK:
			prompt_label.text = "[center]Hold E to bark![/center]"
		ProblemType.MINIGAME:
			prompt_label.text = "[center]Press E to start minigame[/center]"

func activate_distraction():
	if date_manager:
		is_active = true
		date_manager.add_distraction()  # This only affects the display count
		print("Problem created and counted in display")
	else:
		push_error("Cannot activate distraction - DateManager not found")

func start_minigame():
	var minigame_manager = get_node("/root/Game/MinigameManager")
	if minigame_manager:
		minigame_manager.start_minigame(minigame_name, self)

func solve_problem():
	if is_active and date_manager:
		date_manager.remove_distraction()  # Remove from display count
		if current_state == ProblemState.DANGEROUS:
			date_manager.remove_dangerous_distraction()  # Remove dangerous effect if it was dangerous
		emit_signal("problem_solved")
		print("Problem solved, remaining distractions:", date_manager.active_distractions)
	queue_free()
