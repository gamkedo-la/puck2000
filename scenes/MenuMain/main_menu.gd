extends Spatial

onready var btn_startgame = $CanvasLayer/HBoxContainer/StartGame


func _ready() -> void:
	btn_startgame.connect("pressed", self, "goto_gameplay")


func goto_gameplay() -> void:
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
