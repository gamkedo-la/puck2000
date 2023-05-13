extends Spatial

onready var btn_startgame = $Interface/CanvasLayer/Button

var selections = {}


func _ready() -> void:
	btn_startgame.connect("pressed", self, "goto_gameplay")


func select_table() -> void:
	pass


func select_puck(selected_puck:String) -> void:
	selections["puck"] = selected_puck
	print(selections)
	pass


func goto_gameplay() -> void:
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
