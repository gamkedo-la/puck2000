extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

signal puck_spawning_finished

export (PackedScene) var Table
export (PackedScene) var Puck

var p1_puck_count:int
var p2_puck_count:int
var p1_area:Area
var p2_area:Area

onready var pucks = $Pucks
onready var table_holder = $Table

func _ready() -> void:
	_connect_signals()
	_place_table()
	pass


func _connect_signals() -> void:
#	if not self.is_connected("puck_spawning_finished", self, "_get_puck_count"):
#		var con_res = self.connect("puck_spawning_finished", self, "_get_puck_count")
#		assert(con_res == OK)
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
	emit_signal("puck_spawning_finished")
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
		prints("p1:",p1_puck_count)
		prints("p2:",p2_puck_count)
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("ui_accept"):
		print(p1_area)
		print(p1_puck_count)
