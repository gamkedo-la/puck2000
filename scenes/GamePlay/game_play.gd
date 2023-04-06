extends Spatial
# Load the selected pucks and table
# Randomly select and position background decor

export (PackedScene) var Table
export (PackedScene) var Puck

onready var pucks = $Pucks


func _ready() -> void:
	_place_table()
	pass


func _place_table() -> void:
	var table = Table.instance()
	add_child(table)
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
