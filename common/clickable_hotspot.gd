extends ViewportContainer

signal clicked_on_viewport_container(container, index, type)

# assign as string
export var select_what:String

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		emit_signal("clicked_on_viewport_container", self, self.get_index(), select_what)
