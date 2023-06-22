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

var pucks_fwd_m = []
var pucks_bkd_m = []
var pucks_fwd_l = []
var pucks_fwd_r = []
var pucks_bkd_l = []
var pucks_bkd_r = []

## AI random number modifier variables ##
var confidence_base:float = 1.0
var confidence_sector:float = 0.0

#var current_puck:Node = null


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

	## SELECT PUCK ##
	var current_puck = null
#	var random_num = randi() % selectable_pucks.size()
#	current_puck = selectable_pucks[random_num]
	current_puck = select_puck_from_sectors()
	
	# check which sector selected puck is currently in
#	prints("selected puck is situated: ", current_puck.cur_sector)
	
	if current_puck.cur_sector == null:
		printerr("opponent_ai.gd: current_puck.cur_sector is null")
	
	if current_puck.cur_sector != null:
		match current_puck.cur_sector.name:
			"FWD-M":
				print("we're in FWD-M")
				confidence_sector = 9.0
			"BKD-M":
				print("we're in BKD-M")
				confidence_sector = 8.0
			"BKD-L":
				print("we're in BKD-L")
				confidence_sector = 8.0
			"BKD-R":
				print("we're in BKD-R")
				confidence_sector = 8.0
			"FWD-L":
				print("we're in FWD-L")
				confidence_sector = 1.0
			"FWD-R":
				print("we're in FWD-R")
				confidence_sector = 1.0
			_:
				printerr("opponent_ai.gd: current_puck.cur_sector is null, check the match statement in opp_tick_timeout()")
	else:
		confidence_sector = 10.0
	
	if confidence_sector < 5.0:
		current_puck.isADV = false
	else:
		current_puck.isADV = true
#	if pucks_adv.size() > 0:
#		# select puck currently detected in P2Adv
#		var random_num = randi() % pucks_adv.size()
#		current_puck = pucks_adv[random_num]
#		current_puck.isADV = true
#	else:
#		# select puck currently detected in P2Rtt
#		var random_num = randi() % pucks_rtt.size()
#		current_puck = pucks_rtt[random_num]
#		current_puck.isADV = false

	current_puck.isSelected = true
#	prints("current selected puck is in", current_puck.cur_sector)
	
#	## SELECT MARKER ##
#	# set target destination based on OpponentMarkers
	var aim_target = null
	if current_puck.isADV:
		var random_num2 = randi() % opponent_markers_adv.size()
		aim_target = opponent_markers_adv[random_num2].global_transform.origin
	else:
		var random_num2 = randi() % opponent_markers_rtt.size()
		aim_target = opponent_markers_rtt[random_num2].global_transform.origin

	current_puck.opponent_aiming_at = aim_target

	# give the puck time to rotate
	yield(get_tree().create_timer(0.5), "timeout")

	var isClear = check_clearance(current_puck, aim_target)

	if !isClear:
		print("I couldn't line up a clear shot")
		var obstruction = check_ahead(current_puck)
		
		if obstruction != current_puck && obstruction.is_in_group("pucks") :
			print("Taking the shot anyway!")
			current_puck.puck_push(current_puck.cur_dir, 9.0)

	else:
		print("Taking the shot!")
		# set push force
		current_puck.puck_push(current_puck.cur_dir, 9.0)

	current_puck.isADV = false
	current_puck.isSelected = false
	current_puck.last_touch_start()
	pass


func check_clearance(puck:Node, target:Vector3) -> bool:
	
	var collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
	# TODO: Change code to make use of Raycast nodes instead of trying to check via script
	
	var puck_raycast = puck.get_node("Raycasts").get_node("Raycast1")
	
	# use collision mask to check objects in the way
	puck_raycast.set_collision_mask(collision_mask)
	
	var raycast_result = puck_raycast.get_collider()
#	print("puck raycast colliding with ",puck_raycast.get_collider())
	if raycast_result != null:
		return false
	else:
		return true
	# must return true or false


func check_ahead(puck:Node) -> Node:
	var collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	var puck_raycast = puck.get_node("Raycasts").get_node("Raycast1")
	# use collision mask to check objects in the way
	puck_raycast.set_collision_mask(collision_mask)
	var raycast_result = puck_raycast.get_collider()

	if raycast_result != null:
		return raycast_result
	else:
		return puck


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
	
	# connect signals for $OpponentSectors children nodes
	# used to check which sectors have which pucks
	
	var opp_sectors = table.get_node("OpponentSectors")
	
	var sector_fwd_m = opp_sectors.get_node("FWD-M")
	if not sector_fwd_m.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_m.connect("body_entered", self, "_update_puck_sector_lists", ["FWD-M", true])
		assert(sector_check == OK)
	if not sector_fwd_m.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_m.connect("body_exited", self, "_update_puck_sector_lists", ["FWD-M", false])
		assert(sector_check == OK)
	
	var sector_bkd_m = opp_sectors.get_node("BKD-M")
	if not sector_bkd_m.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_m.connect("body_entered", self, "_update_puck_sector_lists", ["BKD-M", true])
		assert(sector_check == OK)
	if not sector_bkd_m.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_m.connect("body_exited", self, "_update_puck_sector_lists", ["BKD-M", false])
		assert(sector_check == OK)

	var sector_bkd_l = opp_sectors.get_node("BKD-L")
	if not sector_bkd_l.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_l.connect("body_entered", self, "_update_puck_sector_lists", ["BKD-L", true])
		assert(sector_check == OK)
	if not sector_bkd_l.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_l.connect("body_exited", self, "_update_puck_sector_lists", ["BKD-L", false])
		assert(sector_check == OK)

	var sector_bkd_r = opp_sectors.get_node("BKD-R")
	if not sector_bkd_r.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_r.connect("body_entered", self, "_update_puck_sector_lists", ["BKD-R", true])
		assert(sector_check == OK)
	if not sector_bkd_r.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_bkd_r.connect("body_exited", self, "_update_puck_sector_lists", ["BKD-R", false])
		assert(sector_check == OK)

	var sector_fwd_l = opp_sectors.get_node("FWD-L")
	if not sector_fwd_l.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_l.connect("body_entered", self, "_update_puck_sector_lists", ["FWD-L", true])
		assert(sector_check == OK)
	if not sector_fwd_l.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_l.connect("body_exited", self, "_update_puck_sector_lists", ["FWD-L", false])
		assert(sector_check == OK)

	var sector_fwd_r = opp_sectors.get_node("FWD-R")
	if not sector_fwd_r.is_connected("body_entered", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_r.connect("body_entered", self, "_update_puck_sector_lists", ["FWD-R", true])
		assert(sector_check == OK)
	if not sector_fwd_r.is_connected("body_exited", self, "_update_puck_sector_lists"):
		var sector_check = sector_fwd_r.connect("body_exited", self, "_update_puck_sector_lists", ["FWD-R", false])
		assert(sector_check == OK)


func _setup_field() -> void:
	# add a timer
	opponent_tick = Timer.new()
	add_child(opponent_tick)
	if not opponent_tick.is_connected("timeout", self, "opp_tick_timeout"):
		var tick_check = opponent_tick.connect("timeout", self, "opp_tick_timeout")
		assert(tick_check == OK)
	pass


func update_opponent_pucklist(puck:Node) -> void:
	if puck.isOpponent:
#		prints("puck has entered opponent's side")
		selectable_pucks.append(puck)
	else:
#		prints("puck has exited opponent's side")
		remove_item(selectable_pucks, puck)


func _update_puck_sector_lists(body:Node, sector:String, isAppend:bool) -> void: 
	
#	prints("_update_puck_sector_lists:",body,sector)
	
	if !body.is_in_group("pucks"):
		return
	
	match sector:
		"FWD-M":
			if isAppend:
				pucks_fwd_m.append(body)
#				prints("add puck!", body, pucks_fwd_m)
			else:
				remove_item(pucks_fwd_m, body)
#				prints("remove puck!", body, pucks_fwd_m)
		"BKD-M":
			if isAppend:
				pucks_bkd_m.append(body)
			else:
				remove_item(pucks_bkd_m, body)
		"BKD-L":
			if isAppend:
				pucks_bkd_l.append(body)
			else:
				remove_item(pucks_bkd_l, body)
		"BKD-R":
			if isAppend:
				pucks_bkd_r.append(body)
			else:
				remove_item(pucks_bkd_r, body)
		"FWD-L":
			if isAppend:
				pucks_fwd_l.append(body)
			else:
				remove_item(pucks_fwd_l, body)
		"FWD-R":
			if isAppend:
				pucks_fwd_r.append(body)
			else:
				remove_item(pucks_fwd_r, body)
		_:
			printerr("uh oh, something went wrong in _update_puck_sector_lists()")
		
#	printt(pucks_fwd_m,pucks_bkd_m,pucks_fwd_l,pucks_fwd_r,pucks_bkd_l,pucks_bkd_r)
	
	pass


func select_puck_from_sectors() -> Node:
#	selects puck in a priority order
	var selected = null
	
	var sectors_by_priority = [
		pucks_fwd_m, pucks_bkd_m, pucks_fwd_l, pucks_fwd_r, pucks_bkd_l, pucks_bkd_r
	]
	
	var isClean = false
	
	for sector in sectors_by_priority:
		if sector.empty():
			continue  # Skip to the next sector if the current sector is empty
		
		for puck in sector:
			
			if !puck.isLastTouched:
				selected = puck
				isClean = true
				break  # Exit the inner loop if isLastTouched is false
		
		if isClean:
			break  # Exit the outer loop if isLastTouched is false
	if isClean:
		return selected
	else:
		# just pick any available puck on opponent side
		var random_num = randi() % selectable_pucks.size()
		return selectable_pucks[random_num]

#	if pucks_fwd_m.size() > 0:
#		var random_num = randi() % pucks_fwd_m.size()
#		selected = pucks_fwd_m[random_num]
#		return selected
#	elif pucks_bkd_m.size() > 0:
#		var random_num = randi() % pucks_bkd_m.size()
#		return pucks_bkd_m[random_num]
#	elif pucks_fwd_l.size() > 0:
#		var random_num = randi() % pucks_fwd_l.size()
#		return pucks_fwd_l[random_num]
#	elif pucks_fwd_r.size() > 0:
#		var random_num = randi() % pucks_fwd_r.size()
#		return pucks_fwd_r[random_num]
#	elif pucks_bkd_l.size() > 0:
#		var random_num = randi() % pucks_bkd_l.size()
#		return pucks_bkd_l[random_num]
#	elif pucks_bkd_r.size() > 0:
#		var random_num = randi() % pucks_bkd_r.size()
#		return pucks_bkd_r[random_num]
#	else:
#		var random_num = randi() % selectable_pucks.size()
#		selected = selectable_pucks[random_num]
#		return selected


func check_if_last_touched(selected:Node) -> Node:
	if selected.isLastTouched:
		return selected
	else:
		return null


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

