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

var pucks_fwd_l = []
var pucks_fwd_m = []
var pucks_fwd_r = []
var pucks_bkd_l = []
var pucks_bkd_m = []
var pucks_bkd_r = []

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
	var random_num = randi() % selectable_pucks.size()
	current_puck = selectable_pucks[random_num]
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
	
	current_puck.start_move_to(Vector3(0.0, 1.05, -9.0))
	
	current_puck.isSelected = true
#	prints("current selected puck is in", current_puck.cur_sector)
	
	
#	## SELECT MARKER ##
#	# set target destination based on OpponentMarkers
#	var aim_target = null
#	if current_puck.isADV:
#		var random_num2 = randi() % opponent_markers_adv.size()
#		aim_target = opponent_markers_adv[random_num2].global_transform.origin
#	else:
#		var random_num2 = randi() % opponent_markers_rtt.size()
#		aim_target = opponent_markers_rtt[random_num2].global_transform.origin
#
#	current_puck.opponent_aiming_at = aim_target
#
#	# give the puck time to rotate
#	yield(get_tree().create_timer(0.5), "timeout")
#
#	var isClear = check_clearance(current_puck, aim_target)
#
#	if !isClear:
#		print("I couldn't line up a clear shot")
#	else:
#		print("Taking the shot!")
#		# set push force
#		current_puck.puck_push(current_puck.cur_dir, 9.0)
#
#	current_puck.isSelected = false
	pass


func check_clearance(puck:Node, target:Vector3) -> bool:
	
	# Get all RayOrigins locations
	var puck_ray_origins = puck.get_node("RayOrigins").get_children()
	
	# Rays are ordered as 0 = front, 1 = left, 2 = right
	var ray_origins = []
	for i in puck_ray_origins.size():
		var ray_origin_pos = puck_ray_origins[i].global_transform.origin
		ray_origins.append(ray_origin_pos)
	
	# The ray_ends are so raycasts are parallel - to reflect the width of the puck
	var ray_ends = []
	ray_ends.append(Vector3(target.x, ray_origins[0].y, target.z)) # the 3DPosition node in the table scene as is
	ray_ends.append(Vector3(target.x + puck_ray_origins[1].transform.origin.x, ray_origins[1].y, target.z)) # to the left of that node
	ray_ends.append(Vector3(target.x + puck_ray_origins[2].transform.origin.x, ray_origins[2].y, target.z)) # to the left of that node
	# TODO: There's still an issue with the raycast vector maths here - what happens if the raycasts are fired when the puck hasn't had time to turn to face the target yet?
	
	var all_ray_points = [ray_origins, ray_ends]
	
#	print("ray_origins: ", ray_origins)
#	print("ray_ends: ", ray_ends)

	if puck.isDebug:
		
		for i in all_ray_points[0].size():
			var ray_origin = all_ray_points[0][i]
			var ray_end = all_ray_points[1][i]
			DebugDraw.draw_line_3d(ray_origin, ray_end, Color(0, 1, 0))

	# get current physics state
	var space_state = puck.get_world().direct_space_state
	
	var collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
	var results = []
	# get the ray hits
	for i in all_ray_points[0].size():
		var ray_origin = all_ray_points[0][i]
		var ray_end = all_ray_points[1][i]
		var temp_result = space_state.intersect_ray(ray_origin, ray_end, [], collision_mask)
		results.append(temp_result)

#	print("raycast intersect results: ", results)

	for result in results:
		if not result.empty():
#			print("I hit something")
			print(result.collider, " is blocking the way")
			return false
		else:
#			print("Nothing in the way")
			pass
	
	return true


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

