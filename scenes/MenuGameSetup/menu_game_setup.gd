extends Spatial

signal send_selections(selections)

export(Array, PackedScene) var table_scenes = [
	preload("res://tables/classic/TableClassic.tscn"),
	preload("res://tables/beyond_classic/TableBeyondClassic.tscn"), null, null
]
export(Array, PackedScene) var puck_cosmetics = [
	preload("res://pucks/standard/PStd-Standard.tscn"),
	preload("res://pucks/standard_variations/cdplayer/PuckStd-cd-walkman.tscn"),
	preload("res://pucks/standard_variations/marble/PuckStd-marble.tscn"),
	preload("res://pucks/standard_variations/ocean/PuckStd-ocean.tscn"),
	preload("res://pucks/standard_variations/sakura/PuckStd-sakura.tscn"),
	preload("res://pucks/special/cd_player/PuckSpcl-cd_player.tscn"),
	preload("res://pucks/special/love_candy/PuckSpcl-love_heart.tscn"),
	preload("res://pucks/special/cd_spindle/PuckSpcl-cd_spindle.tscn"),
	preload("res://pucks/special/roomba/PuckSpcl-roomba.tscn"),
	preload("res://pucks/special/burger/PuckSpcl-burger.tscn")
]
onready var btn_startgame = $Interface/CanvasLayer/Button

var selections = {
	"table": table_scenes[0],
	"puck": puck_cosmetics[0]
}


func _ready() -> void:
	btn_startgame.connect("button_up", self, "goto_gameplay")
	
	connect("send_selections", $"../SceneTransition/DataBus", "test_func")
	
	for child in $Interface/Slides/SelectTables.get_children():
		child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")
	
	for container in $Interface/Slides/SelectPucks/VBoxContainer.get_children():
		for child in container.get_children():
			child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")
	
	# connect signals from "Select" nodes
	# create function to add Node to array to send to Gameplay scene


func _on_viewport_container_clicked(container:ViewportContainer, index:int, type:String) -> void:
#	prints("got clicked", index)
	if type == "table":
		select_table(index)
	if type == "puck":
		select_puck(index)
#	print(selections["table"].instance().name)


func select_table(index:int) -> void:
	selections["table"] = table_scenes[index]
	print_debug(selections["table"].instance().name)
	pass


func select_puck(index:int) -> void:
#	selections["puck"] = selected_puck
	selections["puck"] = puck_cosmetics[index]
	print_debug(selections["puck"].instance().name)
	pass


func goto_gameplay() -> void:
	emit_signal("send_selections", selections)
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
	BGMManager.stop_bgm()

