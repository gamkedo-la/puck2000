extends Spatial
# Currently redundent script. 
# All functionality is handled in individual puck.gd script

var current_selected_puck:Node = null


func _ready() -> void:
	current_selected_puck = null
	pass # Replace with function body.


func connect_puck_signal(puck:Node) -> void:
# warning-ignore:return_value_discarded
	puck.connect("puck_selected", self, "handle_puck_selection")


func handle_puck_selection(puck:Node) -> void:
	current_selected_puck = puck
