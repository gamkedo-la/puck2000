extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

signal puck_spawn_finished

export (PackedScene) var Table
export (PackedScene) var Puck

export var round_time:float = 90.0

var p1_puck_count:int
var p2_puck_count:int
var p1_area:Area
var p2_area:Area
var p1_round_win:int
var p2_round_win:int
var current_round:int

onready var pucks = $Pucks
onready var table_holder = $Table
onready var timer_round = $TimerRoundDuration


func _ready() -> void:
	current_round = 0
	# disable controls
	_disable_input()
	setup_field()
#	opening_cinematic()
	start_game()
	pass


func _process(_delta: float) -> void:
	$TimerRoundLabel.text = "Time left: "+ str(timer_round.time_left)
	pass


func _disable_input() -> void:
	# disable all inputs
	# disable unhandled inputs
	# disable mouse inputs
	
	pass


func setup_field() -> void:
	
	timer_round.connect("timeout", self, "end_round")
	
	reset_round() # things like timers and scores etc.
	_place_table()
	pass


func reset_round() -> void:
	timer_round.set_wait_time(round_time)
#	reset_pucks() # reset puck positions
	start_game()


func _place_table() -> void:
	var table = Table.instance()
	table_holder.add_child(table)
	
	p1_area = table.get_node("P1Area")
	p2_area = table.get_node("P2Area")
	
	if not p1_area.is_connected("body_exited", self, "_check_winner"):
		var puck_check = p1_area.connect("body_exited", self, "_check_winner", [p1_area])
		assert(puck_check == OK)
	if not p2_area.is_connected("body_exited", self, "_check_winner"):
		var puck_check = p2_area.connect("body_exited", self, "_check_winner", [p1_area])
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
	
	_place_pucks(table)
	pass


func _place_pucks(table:StaticBody) -> void:
	var p1_spawn = table.get_node("P1PuckSpawn").get_children()
	var p2_spawn = table.get_node("P2PuckSpawn").get_children()
	for positionNode in p1_spawn:
#		print(pos.transform.origin)
		var puck = _get_puck_instance(positionNode)
		puck.camera_node_path = "../../Camera"
		pucks.add_child(puck)
	for positionNode in p2_spawn:
		var puck = _get_puck_instance(positionNode)
		puck.camera_node_path = "../../Camera"
		pucks.add_child(puck)
	$Pucks.setup_field()
	pass


func _get_puck_instance(positionNode:Position3D) -> RigidBody:
		var puck = Puck.instance()
		puck.transform.origin = positionNode.transform.origin
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
	_countdown_to_round()
#	_start_round()
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
	print("game round start!")
	$TimerRoundDuration.start() # connect to a UI element later
	
	# enable controls
	
	pass


func end_round() -> void:
	print("game round ended!")
	
	# disable controls
	
	# Check how many rounds left
	if p1_round_win == 3 && p1_round_win > p2_round_win:
		print("P1 wins!")
		return
	if p2_round_win == 3 && p2_round_win > p1_round_win:
		print("P2 wins!")
		return
	
	# restart round
	reset_round()
	
	# If max rounds go to results
	# If not max rounds, start new round
	pass


func _check_winner(body:Node, area:Area) -> void:
#	prints(body, area)
	var pucks_left = area.get_overlapping_bodies()
#	print(pucks_left)
	# check if overlapping bodies has any pucks
	for puck in pucks_left:
		if puck.is_in_group("pucks"):
#			print_debug("no winner yet")
			return
	# ignore if it's a table body
	# if none, then that person wins
#	print("gotta report the winner!")
	end_round()
#	print_debug(pucks_left)
	pass

