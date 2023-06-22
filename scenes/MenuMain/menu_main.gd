extends Spatial

onready var btn_startgame = $CanvasLayer/HBoxContainer/StartGame


func _ready() -> void:
	btn_startgame.connect("pressed", self, "goto_gameplay")


func goto_gameplay() -> void:
	SceneTransition.change_scene("res://scenes/MenuGameSetup/MenuGameSetup.tscn")


func _on_HowToPlay_pressed():
	SceneTransition.change_scene("res://scenes/MenuCredits/MenuCredits.tscn")
	pass # Replace with function body.
