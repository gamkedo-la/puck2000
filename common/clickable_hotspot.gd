extends ViewportContainer

signal clicked_on_viewport_container(container, index, type)

# assign as string
export var select_what:String

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var index_to_send = self.get_index()
		var which_row = get_parent()
		
		if which_row.name == "HBoxContainer":
			emit_signal("clicked_on_viewport_container", self, index_to_send, select_what)
		if which_row.name == "HBoxContainer2":
			index_to_send += 6
			if index_to_send >= 10:
				index_to_send = 0
			emit_signal("clicked_on_viewport_container", self,  index_to_send, select_what)
			print(index_to_send)
		if which_row.name == "SelectTables":
			emit_signal("clicked_on_viewport_container", self, index_to_send, select_what)
