extends Spatial

var puck_selected = null



func _ready() -> void:
	puck_selected = null
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released ("puck"):
		puck_selected.puck_push()
	
	if Input.is_action_just_pressed("select"):
		print(puck_selected)
	
	if Input.is_action_just_released("select"):
		print(puck_selected)


func puck_selection(puck:Node) -> void:
	puck_selected = puck


func puck_deselection(puck:Node) -> void:
	if puck_selected:
		puck_selected.puck_push()
	puck_selected = null


func setup_field() -> void: # called from GamePlay node
	var pucks = get_children()
	for puck in pucks:
		print(puck)
		puck.connect("puck_selected", self, "puck_selection")
		puck.connect("puck_deselected", self, "puck_deselection")
	
