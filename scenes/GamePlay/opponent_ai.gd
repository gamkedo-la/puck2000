extends Node

# May require raycasts to check path to OpponentMarkers is clear
# Consider Areas as a way of checking puck priority order
# For now just select randomly

export var opponent_tick_rate:float = 4.0 # in seconds

onready var pucks = $"../Pucks"

var table:Node
var opponent_tick = null # dictates speed of opponent's actions
var selectable_pucks = []
var opponent_markers = []

func _ready() -> void:
	_setup_field()
	pass


func opp_tick_timeout() -> void:
#	print("opponent AI tick!")
	var random_num1 = randi() % selectable_pucks.size()
	# select puck currently on opponent side
	var current_puck = selectable_pucks[random_num1]
	current_puck.isSelected = true
	# set target destination based on OpponentMarkers
	
	var random_num2 = randi() % opponent_markers.size()
	var aim_target = opponent_markers[random_num2].transform.origin
	
	prints(current_puck.transform.origin, aim_target)
	
#	current_puck.targetDest = aim_target
#	print(current_puck.targetDest)
	current_puck.opponent_aiming_at = aim_target

	yield(get_tree().create_timer(0.5), "timeout")

	# set push force
	current_puck.puck_push(current_puck.cur_dir, 9.0)
	
	current_puck.isSelected = false
	pass


func table_setup() -> void:
	table = $"../Table".get_child(0)
	# get position nodes from current table
	var opp_markers = table.get_node("OpponentMarkers").get_children()
	for marker in opp_markers:
		opponent_markers.append(marker)
	pass


func _setup_field() -> void:
	# add a timer
	opponent_tick = Timer.new()
	add_child(opponent_tick)
	opponent_tick.connect("timeout", self, "opp_tick_timeout")
	pass


func update_opponent_pucklist(puck:Node) -> void:
	if puck.isOpponent:
#		prints("puck has entered opponent's side")
		selectable_pucks.append(puck)
	else:
#		prints("puck has exited opponent's side")
		remove_item(selectable_pucks, puck)


func remove_item(array:Array, item):
	for i in range(array.size()):
		if array[i] == item:
			array.remove(i)
			break


func start_opponent_logic() -> void:
	print("Opponent AI logic has started!")
	
	# start the opponent_tick
	opponent_tick.start()
	pass


func stop_opponent_logic() -> void:
	print("Opponent AI logic has started!")
	# stop all opponent functionality
	opponent_tick.stop()
	pass


func reset_opponent() -> void:
	print("Opponent AI variables reset!")
	opponent_tick.wait_time = opponent_tick_rate


# function to check which pucks on opponent's side


# function to decide which puck to select


# function to aim a puck


# function to decide how much push force

