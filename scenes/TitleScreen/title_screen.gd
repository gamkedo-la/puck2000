extends Spatial

onready var start_button = $CanvasLayer/Control/HBoxContainer/StartGame


func _ready() -> void:
	start_button.connect("pressed", self, "goto_main_menu")


func goto_main_menu() -> void:
	SceneTransition.change_scene("res://scenes/MenuMain/MenuMain.tscn")
