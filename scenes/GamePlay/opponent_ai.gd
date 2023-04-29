extends Node

# May require raycasts to check path to OpponentMarkers is clear
# Consider Areas as a way of checking puck priority order
# For now just select randomly

# Key:
# Opponent = anything to do with the AI
# Player = anything to do with the player


export var opponent_tick_rate:float = 4.0 # in seconds

onready var pucks = $"../Pucks"

var table:Node
var opponent_tick = null # dictates speed of opponent's actions
var selectable_pucks = []
var opponent_markers_adv = []
var opponent_markers_rtt = []
var pucks_adv = []
var pucks_rtt = []

func _ready() -> void:
	_setup_field()
	pass


func opp_tick_timeout() -> void:
#	print("opponent AI tick!")

	# Key: 
	# Adv = Advance: Markers that are used to aim puck at player's side
	# Rtt = Retreat: Markers that set up pucks for for the AI to better shoot at player's side

	# check if there are any pucks with clearance to Adv locations
	# keep looping through available pucks until one is free

	# if there are no pucks with clearance to Adv locations
	# check if there are any with clearance to Rtt locations
	
	# if there are no pucks with clearance to Adv locations
	# then select the first puck closest to an Att location

	var random_num1 = randi() % selectable_pucks.size()
	# select puck currently on opponent side
	var current_puck = selectable_pucks[random_num1]
	current_puck.isSelected = true
	# set target destination based on OpponentMarkers
	
	var random_num2 = randi() % opponent_markers_adv.size()
	var aim_target = opponent_markers_adv[random_num2].transform.origin
	
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
	var opp_markers = table.get_node("OpponentMarkers")
	
	var markers_adv = opp_markers.get_node("Adv").get_children()
	var markers_rtt = opp_markers.get_node("Rtt").get_children()
	
	for marker in markers_adv:
		opponent_markers_adv.append(marker)
	for marker in markers_rtt:
		opponent_markers_rtt.append(marker)
	
	# P2Rtt is an Area node in table scenes that help the AI set up puck shots - they're otherwise stuck in the top half of their field and are unable to compete with the player without this.
	# connect P2Rtt signals
	var p2_rtt_area = table.get_node("P2Rtt")
	if not p2_rtt_area.is_connected("body_entered", self, "_update_rtt_adv"):
		var table_check = p2_rtt_area.connect("body_entered", self, "_update_rtt_adv", [true, p2_rtt_area.name])
		assert(table_check == OK)
	if not p2_rtt_area.is_connected("body_exited", self, "_update_rtt_adv"):
		var table_check = p2_rtt_area.connect("body_exited", self, "_update_rtt_adv", [false, p2_rtt_area.name])
		assert(table_check == OK)
		
	var p2_adv_area = table.get_node("P2Adv")
	if not p2_adv_area.is_connected("body_entered", self, "_update_rtt_adv"):
		var table_check = p2_adv_area.connect("body_entered", self, "_update_rtt_adv", [true, p2_adv_area.name])
		assert(table_check == OK)
	if not p2_adv_area.is_connected("body_exited", self, "_update_rtt_adv"):
		var table_check = p2_adv_area.connect("body_exited", self, "_update_rtt_adv", [false, p2_adv_area.name])
		assert(table_check == OK)
	
	pass


func _update_rtt_adv(body:Node, isEnter:bool, area:String) -> void:
	if body.is_in_group("pucks"):
		if isEnter:
			if area == "P2Rtt":
				# append body to pucks_rtt
				pucks_rtt.append(body)
			else:
				# append body to pucks_adv
				pucks_adv.append(body)
		else:
			if area == "P2Rtt":
				# remove body from pucks_rtt
				remove_item(pucks_rtt, body)
			else:
				# remove body from pucks_adv
				remove_item(pucks_adv, body)
#	prints("pucks_rtt:", pucks_rtt)
#	prints("pucks_adv", pucks_adv)


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

