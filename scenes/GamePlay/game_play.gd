extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

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
	
	setup_field()
#	opening_cinematic()
	start_game()
	pass


func _process(_delta: float) -> void:
	$TimerRoundLabel.text = "Time left: "+ str(timer_round.time_left)
	pass


func setup_field() -> void:
	
#	_reset_round_vars() # things like timers and scores etc.
	timer_round.set_wait_time(round_time)
	timer_round.connect("timeout", self, "end_round")
	_place_table()
	pass


func _place_table() -> void:
	var table = Table.instance()
	table_holder.add_child(table)
	
	if not table.get_node("P1Area").is_connected("body_entered", self, "_count_puck"):
		var table_check = table.get_node("P1Area").connect("body_entered", self, "_count_puck", [true, "P1Area"])
		assert(table_check == OK)
	if not table.get_node("P1Area").is_connected("body_exited", self, "_count_puck"):
		var table_check = table.get_node("P1Area").connect("body_exited", self, "_count_puck", [false, "P1Area"])
		assert(table_check == OK)
	if not table.get_node("P2Area").is_connected("body_entered", self, "_count_puck"):
		var table_check = table.get_node("P2Area").connect("body_entered", self, "_count_puck", [true, "P2Area"])
		assert(table_check == OK)
	if not table.get_node("P2Area").is_connected("body_exited", self, "_count_puck"):
		var table_check = table.get_node("P2Area").connect("body_exited", self, "_count_puck", [false, "P2Area"])
		assert(table_check == OK)
	
	_place_pucks(table)
	pass


func _place_pucks(table:StaticBody) -> void:
	var p1_spawn = table.get_node("P1PuckSpawn").get_children()
	var p2_spawn = table.get_node("P2PuckSpawn").get_children()
	for positionNode in p1_spawn:
#		print(pos.transform.origin)
		var puck = _get_puck_instance(positionNode)
		pucks.add_child(puck)
	for positionNode in p2_spawn:
		var puck = _get_puck_instance(positionNode)
		pucks.add_child(puck)
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
		print(p1_area)
		print(p1_puck_count)


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
	pass


func end_round() -> void:
	print("game round ended!")
	# Check how many rounds left
	# If max rounds go to results
	# If not max rounds, start new round
	pass
