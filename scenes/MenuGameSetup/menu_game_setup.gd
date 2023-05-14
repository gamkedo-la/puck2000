extends Spatial

export(Array, PackedScene) var table_scenes = [
	preload("res://tables/classic/TableClassic.tscn"),
	preload("res://tables/beyond_classic/TableBeyondClassic.tscn"), null, null
]
onready var btn_startgame = $Interface/CanvasLayer/Button

var selections = {}


func _ready() -> void:
	btn_startgame.connect("pressed", self, "goto_gameplay")
	
	for child in $Interface/Slides/SelectTables.get_children():
		child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")


func _on_viewport_container_clicked(container, index) -> void:
	prints("got clicked", index)
	selections["table"] = table_scenes[index]
	print(selections["table"].instance().name)


func select_table() -> void:
	pass


func select_puck(selected_puck:String) -> void:
	selections["puck"] = selected_puck
	print(selections)
	pass


func goto_gameplay() -> void:
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
