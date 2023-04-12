extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

signal puck_spawn_finished

export (PackedScene) var Table
export (PackedScene) var Puck

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

var table:StaticBody

onready var pucks = $Pucks
onready var table_holder = $Table
onready var timer_round = $TimerRoundDuration


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
	$InputBlock.visible = isVisible
	pass


func setup_field() -> void:
	
	timer_round.connect("timeout", self, "end_round")
	# needs to check score and then end round
	
	_spawn_table()
	_spawn_pucks()
	reset_round() # things like timers, scores, puck positions
	
	pass


func reset_round() -> void:
	_place_pucks()
	timer_round.set_wait_time(round_time)


func _spawn_table() -> void:
	table = Table.instance()
	table_holder.add_child(table)
	
	p1_area = table.get_node("P1Area")
	p2_area = table.get_node("P2Area")
	
	if not p1_area.is_connected("body_exited", self, "_check_round_winner"):
		var puck_check = p1_area.connect("body_exited", self, "_check_round_winner", [p1_area])
		assert(puck_check == OK)
	if not p2_area.is_connected("body_exited", self, "_check_round_winner"):
		var puck_check = p2_area.connect("body_exited", self, "_check_round_winner", [p1_area])
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
	pass


func _place_pucks() -> void:
	var pucks_list = pucks.get_children()
	for i in pucks_list.size():
		# cancel all physics
		# then apply positions
		pucks_list[i].transform.origin = puck_spawn_pos[i].transform.origin
#		print(pucks_list[i])
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
	$Pucks.setup_field()
	pass


func _get_puck_instance(positionNode:Position3D) -> RigidBody:
		var puck = Puck.instance()
		puck.transform.origin = positionNode.transform.origin
		puck.camera_node_path = "../../Camera"
		return puck


func _count_puck(body:Node, isEnter:bool, area:String) -> void:
	
	if body.is_in_group("pucks"):
		if isEnter:
			if area == "P1Area":
				p1_puck_count += 1
			else:
				p2_puck_count += 1
		else:
			if area == "P1Area":
				p1_puck_count -= 1
			else:
				p2_puck_count -= 1
#		prints("p1:",p1_puck_count)
#		prints("p2:",p2_puck_count)
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
	print("do I run twice?")
	$CountdownText.text = "Go!"


func start_round() -> void:
	$CountdownText.visible = false
	_toggle_input_block(false)
	print("game round start!")
	timer_round.start() # connect to a UI element later
	
	# enable controls
	
	pass


func end_round(player:String) -> void:
	print("game round ended!")
	
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
	

	pass


func _check_round_winner(body:Node, area:Area) -> void:
	prints(body, area)
	var bodies = area.get_overlapping_bodies()
#	print(pucks_left)
	# check if overlapping bodies has any pucks
	for n in bodies:
		if n.is_in_group("pucks"):
#			print_debug("no winner yet")
			return
	# ignore if it's a table body
	# if none, then that person wins
#	print("gotta report the winner!")
	end_round(area.name)
#	print_debug(pucks_left)
	pass


func end_game(winner:String) -> void:
	print(winner + " is the winner")
	pass
