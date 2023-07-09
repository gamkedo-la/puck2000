extends ViewportContainer

signal clicked_on_viewport_container(container, index, type)

# assign as string
export var select_what:String
var isSelected = false
onready var grandparent = $"../.."

func _process(delta: float) -> void:
	if isSelected:
		update()


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
#			print(index_to_send)

		if which_row.name == "SelectTables":
			if index_to_send >= 2:
				index_to_send = 0
			emit_signal("clicked_on_viewport_container", self, index_to_send, select_what)
		
		clear_drawings(which_row.name)
		startDrawing()


func clear_drawings(check:String) -> void:
	if check == "SelectTables":
		for item in get_parent().get_children():
			item.stopDrawing()

	if check == "HBoxContainer" || check == "HBoxContainer2":
		var rows = grandparent.get_children()
		for row in rows:
			for item in row.get_children():
				item.stopDrawing()
				pass


func startDrawing() -> void:
	isSelected = true


func stopDrawing() -> void:
	isSelected = false
	update()


func _draw():
	if isSelected:
		draw_line(Vector2(0, 0), Vector2(get_size().x, 0), Color(1.0, 0.95, 0.95), 2)
		draw_line(Vector2(get_size().x, 0), Vector2(get_size().x, get_size().y), Color(1.0, 0.95, 0.95), 2)
		draw_line(Vector2(get_size().x, get_size().y), Vector2(0, get_size().y), Color(1.0, 0.95, 0.95), 2)
		draw_line(Vector2(0, get_size().y), Vector2(0, 0), Color(1.0, 0.95, 0.95), 2)

