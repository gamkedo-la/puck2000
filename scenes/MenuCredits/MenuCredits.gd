extends Spatial

func _ready():
	pass 
	
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			goto_main_menu()
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			goto_main_menu()

func goto_main_menu() -> void:
	SceneTransition.change_scene("res://scenes/MenuMain/MenuMain.tscn")
