extends Area2D

signal problem_solved
signal state_changed(new_state: String)

enum ProblemType { BARK, MINIGAME }
enum ProblemState { GROWING, DANGEROUS, CRITICAL }

@export var problem_type: ProblemType = ProblemType.BARK
@export var bark_time_required := 2.0
@export var growing_time := 10.0
@export var dangerous_time := 10.0

@onready var prompt_label = $RichTextLabel
@onready var date_manager = get_node("/root/Game/DateManager")
@onready var animated_sprite = $AnimatedSprite2D
@onready var bark_sound: AudioStreamPlayer2D = $BarkSound

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
var direction_arrow: Node2D

func _ready():
	add_to_group("problem")

	var arrow_scene = preload("res://scenes/direction_arrow.tscn")
	direction_arrow = arrow_scene.instantiate()
	get_node("/root/Game/CanvasLayer").add_child(direction_arrow)
	direction_arrow.setup(self, global_position)
	
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
	
	emit_signal("state_changed", "growing") 
	
	if bark_sound:
		bark_sound.stream.loop = true

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
	emit_signal("state_changed", "danger")
	if date_manager:
		date_manager.add_dangerous_distraction()

func on_problem_timeout():
	print("Problem reached critical state!")
	if date_manager:
		date_manager.remove_dangerous_distraction()  # No longer dangerous
		date_manager.add_critical_distraction()      # Now critical
	emit_signal("state_changed", "critical")

# In Problem script, handle_interaction function
func handle_interaction(delta):
	if can_interact:
		match problem_type:
			ProblemType.BARK:
				if Input.is_action_pressed("bark"):
					is_barking = true
					bark_timer += delta
					var progress = (bark_timer / bark_time_required) * 100
					prompt_label.text = "[center]Barking... %d%%[/center]" % progress
					
					# Play bark sound while key is held
					if bark_sound and not bark_sound.playing:
						bark_sound.play()
					
					var player = get_node("/root/Game/Player")
					if player:
						player.enter_fixing_state()
					
					if bark_timer >= bark_time_required:
						solve_problem()
				else:
					# Stop bark sound when key is released
					if bark_sound and bark_sound.playing:
						bark_sound.stop()
					
					var player = get_node("/root/Game/Player")
					if player:
						player.exit_fixing_state()
					
					if is_barking:
						bark_timer = 0.0
						is_barking = false
						update_prompt_text()
							
			ProblemType.MINIGAME:  # This stays the same
				if Input.is_action_just_pressed("interact"):
					var player = get_node("/root/Game/Player")
					if player:
						player.enter_fixing_state()
					start_minigame()

func update_visibility():
	var my_room = get_parent().get_parent().get_parent()
	if my_room:
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
			prompt_label.text = "[center]Hold W to bark![/center]"  # Changed from E to W
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
		var player = get_node("/root/Game/Player")
		if player:
			player.exit_fixing_state()
		
		# Stop sounds on the spawn point
		var spawn_point = get_parent()
		if spawn_point.has_method("stop_all_sounds"):
			spawn_point.stop_all_sounds()
			
		date_manager.remove_distraction()
		if current_state == ProblemState.DANGEROUS:
			date_manager.remove_dangerous_distraction()
		emit_signal("problem_solved")
		print("Problem solved, remaining distractions:", date_manager.active_distractions)
		queue_free()

func _exit_tree():
	if direction_arrow:
		direction_arrow.queue_free()
