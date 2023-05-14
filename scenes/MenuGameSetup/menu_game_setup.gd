extends Spatial

signal send_selections(selections)

export(Array, PackedScene) var table_scenes = [
	preload("res://tables/classic/TableClassic.tscn"),
	preload("res://tables/beyond_classic/TableBeyondClassic.tscn"), null, null
]
onready var btn_startgame = $Interface/CanvasLayer/Button

var selections = {
	"table": table_scenes[0],
#	"puck": puck_cosmetics[0]
}


func _ready() -> void:
	btn_startgame.connect("button_up", self, "goto_gameplay")
	
	connect("send_selections", $"../SceneTransition/DataBus", "test_func")
	
	for child in $Interface/Slides/SelectTables.get_children():
		child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")


func _on_viewport_container_clicked(container:ViewportContainer, index:int) -> void:
#	prints("got clicked", index)
	select_table(index)
#	print(selections["table"].instance().name)


func select_table(index:int) -> void:
	selections["table"] = table_scenes[index]
	print_debug(selections)
	pass


func select_puck(selected_puck:String) -> void:
	selections["puck"] = selected_puck
	print_debug(selections)
	pass


func goto_gameplay() -> void:
	emit_signal("send_selections", selections)
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
