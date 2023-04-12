extends Spatial
# Currently redundent script. 
# All functionality is handled in individual puck.gd script


var puck_selected = null


func _ready() -> void:
	puck_selected = null
	pass # Replace with function body.


#func _unhandled_input(event: InputEvent) -> void:
#	if Input.is_action_just_released ("puck"):
#		puck_selected.puck_push()
#
#	if Input.is_action_just_pressed("select"):
##		print(puck_selected)
#		pass
#
#	if Input.is_action_just_released("select"):
#		puck_deselection()


func puck_selection(puck:Node) -> void:
	puck_selected = puck
	puck_selected.pointer.visible = true
	puck_selected.isSelected = true


func puck_deselection() -> void:
	if puck_selected:
		puck_selected.pointer.visible = false
		puck_selected.isSelected = false
		puck_selected.puck_push()
	puck_selected = null


func setup_field() -> void: # called from GamePlay node
	var pucks = get_children()
	for puck in pucks:
#		print(puck)
		puck.connect("puck_selected", self, "puck_selection")

