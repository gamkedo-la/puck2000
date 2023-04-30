extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

# warning-ignore:unused_signal
signal puck_spawn_finished

export (PackedScene) var Table
export (PackedScene) var Puck
export var isDebug:bool = false

export var round_time:float = 90.0

var puck_spawn_pos = []

var p1_puck_count:int
var p2_puck_count:int
var p1_area:Area
var p2_area:Area
var p1_round_wins:int
var p2_round_wins:int
var current_round:int

#var isFirstRound:bool

var table:Spatial

onready var pucks = $Pucks
onready var table_holder = $Table
onready var timer_round = $TimerRoundDuration
onready var opponent = $OpponentAI


func _ready() -> void:
#	isFirstRound = true
	current_round = 0
	# disable controls
	_toggle_input_block(true)
	setup_field()
#	opening_cinematic()
	start_game()
	pass


func _process(_delta: float) -> void:
	$TimerRoundLabel.text = "Time left: "+ str(timer_round.time_left)
	pass


func _toggle_input_block(isVisible:bool) -> void:
	# disable all inputs
	# disable unhandled inputs
	# disable mouse inputs
	# TODO: deselect any pucks if still selected
	$CanvasLayer/InputBlock.visible = isVisible
	pass


func setup_field() -> void:
	
	timer_round.connect("timeout", self, "count_final_round_score")
	# needs to check score and then end round
	# like a count score function
	
	_spawn_table()
	_spawn_pucks()
	reset_round() # things like timers, scores, puck positions
	
	pass


func reset_round() -> void:
	
	$CanvasLayer/BtnPlayAgain.visible = false
	
	set_label_text(3) # reset the countdown label text
	_reset_puck_physics()
	yield(get_tree().create_timer(0.5), "timeout") # give the game enough time to pass the physics calculation frames
	_place_pucks()
	timer_round.set_wait_time(round_time)
	opponent.reset_opponent()


func _spawn_table() -> void:
	table = Table.instance()
	table_holder.add_child(table)
	
	p1_area = table.get_node("P1Area")
	p2_area = table.get_node("P2Area")
	
	if not p1_area.is_connected("body_exited", self, "_check_round_winner"):
		var puck_check = p1_area.connect("body_exited", self, "_check_round_winner", [p1_area, false])
		assert(puck_check == OK)
	if not p2_area.is_connected("body_exited", self, "_check_round_winner"):
		var puck_check = p2_area.connect("body_exited", self, "_check_round_winner", [p2_area, false])
		assert(puck_check == OK)
	
	if not p1_area.is_connected("body_entered", self, "_count_puck"):
		var table_check = p1_area.connect("body_entered", self, "_count_puck", [true, "P1Area"])
		assert(table_check == OK)
	if not p1_area.is_connected("body_exited", self, "_count_puck"):
		var table_check = p1_area.connect("body_exited", self, "_count_puck", [false, "P1Area"])
		assert(table_check == OK)
	if not p2_area.is_connected("body_entered", self, "_count_puck"):
		var table_check = p2_area.connect("body_entered", self, "_count_puck", [true, "P2Area"])
		assert(table_check == OK)
	if not p2_area.is_connected("body_exited", self, "_count_puck"):
		var table_check = p2_area.connect("body_exited", self, "_count_puck", [false, "P2Area"])
		assert(table_check == OK)
	
	# tell $OpponentAI to set up table related things
	opponent.table_setup()
	
	pass


func _place_pucks() -> void:
	var pucks_list = pucks.get_children()
	for i in pucks_list.size():
		# cancel all physics
		# then apply positions
		pucks_list[i].transform.origin = puck_spawn_pos[i].transform.origin
		pucks_list[i].reset_inertia() 
#		print(pucks_list[i])
	pass


func _reset_puck_physics() -> void:
	var pucks_list = pucks.get_children()
	for i in pucks_list.size():
		# cancel all physics
		pucks_list[i].reset_inertia() 	
	pass


func _spawn_pucks() -> void:
	var p1_spawn = table.get_node("P1PuckSpawn").get_children()
	var p2_spawn = table.get_node("P2PuckSpawn").get_children()
	for positionNode in p1_spawn:
#		print(pos.transform.origin)
		puck_spawn_pos.append(positionNode)
		var puck = _get_puck_instance(positionNode)
		pucks.add_child(puck)
	for positionNode in p2_spawn:
		puck_spawn_pos.append(positionNode)
		var puck = _get_puck_instance(positionNode)
		pucks.add_child(puck)
#	$Pucks.setup_field()
	pass


func _get_puck_instance(positionNode:Position3D) -> RigidBody:
		var puck = Puck.instance()
		puck.transform.origin = positionNode.transform.origin
		puck.camera_node_path = "../../Camera"
		if isDebug:
			puck.isDebug = true
		return puck


func _count_puck(body:Node, isEnter:bool, area:String) -> void:
	
	if body.is_in_group("pucks"):
		if isEnter:
			if area == "P1Area":
				p1_puck_count += 1
			else:
				p2_puck_count += 1
				body.isOpponent = true # sets puck to be recognised as being on opponent side
				# send body to opponent_ai.gd
				opponent.update_opponent_pucklist(body)
		else:
			if area == "P1Area":
				p1_puck_count -= 1
			else:
				p2_puck_count -= 1
				body.isOpponent = false
				# send body to opponent_ai.gd
				opponent.update_opponent_pucklist(body)
#		prints("p1:",p1_puck_count)
#		prints("p2:",p2_puck_count)
	pass


func count_final_round_score() -> void:
	var p1_score = p1_area.get_overlapping_bodies()
	var p2_score = p2_area.get_overlapping_bodies()
	# remember, the fewer pucks a player has, the better they're doing
	if p1_score.size() < p2_score.size():
		print("player 1 wins")
		_check_round_winner(null, p1_area, true)
	else:
		print("player 2 wins")
		_check_round_winner(null, p2_area, true)

	pass


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("ui_accept"):
#		print(p1_area)
#		print(p1_puck_count)
		pass
	pass


func start_game() -> void:
#	isFirstRound = false
	_countdown_to_round()
	pass


func set_label_text(value:int) -> void:
	$CountdownText.text = str(value)
	pass


func _countdown_to_round() -> void:
#	yield or another timer, or something
#	timer_countdown.timeout() # use timeout signal
	$CountdownText.visible = true
	var tween = create_tween()
	tween.tween_method(self, "set_label_text", 3, 1, 1.5).set_delay(1)
	tween.tween_callback(self, "set_label_text_go")
	tween.tween_callback(self, "start_round").set_delay(0.75)
	pass


func set_label_text_go() -> void:
	$CountdownText.text = "Go!"


func start_round() -> void:
	$CountdownText.visible = false
	_toggle_input_block(false)
	print("game round start!")
	timer_round.start() # connect to a UI element later
	# start opponent logic
	opponent.start_opponent_logic()
	# enable controls
	
	pass


func end_round(player:String) -> void:
	print("game round ended!")
	
	opponent.stop_opponent_logic()
	timer_round.stop()
	# disable controls
	_toggle_input_block(true)
#	p1_area.set_deferred("monitoring", false)
#	p2_area.set_deferred("monitoring", false)
	
	if player == "P1Area":
		print("P1 is the round winner!")
		p1_round_wins += 1
		$P1RoundWins.text = "P1: " + str(p1_round_wins)
	elif player == "P2Area":
		print("P2 is the round winner!")
		p2_round_wins += 1
		$P2RoundWins.text = "P2: " + str(p2_round_wins)

	# Check how many rounds left
	if p1_round_wins == 3 && p1_round_wins > p2_round_wins:
		print("P1 wins!")
		end_game("Player 1")
		return
	if p2_round_wins == 3 && p2_round_wins > p1_round_wins:
		print("P2 wins!")
		end_game("Player 2")
		return
	# If max rounds go to results
	# If not max rounds, start new round
	
	# restart round
	reset_round()
	yield(get_tree().create_timer(0.5), "timeout")
	start_game()

	pass


func _check_round_winner(_body:Node, area:Area, isTimeout:bool) -> void:
	
	if !isTimeout:
		var bodies = area.get_overlapping_bodies()
	#	print(bodies)
		# remember the collision layers are set to only detect puck rigidbodies
		if bodies.size() > 0:
			return
		elif bodies.size() == 0:
			print("time to end the round")
			end_round(area.name)
		pass
	else:
		end_round(area.name)


func end_game(winner:String) -> void:
	print(winner + " is the winner")
#	end_cinematic()
#	progress to next scene
	# temporary code to replay match
	$CanvasLayer/BtnPlayAgain.visible = true
	pass



func _on_BtnPlayAgain_pressed() -> void:
	p1_round_wins = 0
	p2_round_wins = 0
	reset_round()
	start_game()
	pass # Replace with function body.
