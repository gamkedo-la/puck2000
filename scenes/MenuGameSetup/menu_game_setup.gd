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
onready var btn_next = $Interface/CanvasLayer/ButtonNext
onready var btn_prev = $Interface/CanvasLayer/ButtonPrev
onready var btn_play = $Interface/CanvasLayer/ButtonPlay
onready var interface_screen = $Interface

var current_select_screen = 0
var isInputEnabled:bool = true

var selections = {
	"table": table_scenes[0],
	"puck": puck_cosmetics[0]
}


func _ready() -> void:
#	btn_startgame.connect("button_up", self, "goto_gameplay")
	btn_next.connect("button_up", self, "goto_animation", [true])
	btn_prev.connect("button_up", self, "goto_animation", [false])
	btn_play.connect("button_up", self, "goto_gameplay")
	
	connect("send_selections", $"../SceneTransition/DataBus", "test_func")
	
	for child in $Interface/Slides/SelectTables.get_children():
		child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")
	
	for container in $Interface/Slides/SelectPucks/VBoxContainer.get_children():
		for child in container.get_children():
			child.connect("clicked_on_viewport_container", self, "_on_viewport_container_clicked")
	
	# connect signals from "Select" nodes
	# create function to add Node to array to send to Gameplay scene
	
	# reset buttons
	sort_buttons()


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


func goto_next_slide() -> void:
	# advances to next select screen
	pass


func goto_prev_slide() -> void:
	# returns to previous select screen
	pass


func goto_animation(isNext:bool) -> void:
	# handle animation tween for select screen transition
	var slides = interface_screen.get_node("Slides")
	var tween = get_tree().create_tween()
	var value
	
	if isNext == true:
		value = slides.get_position() - Vector2(interface_screen.get_viewport_rect().size.x, 0)
		# track which screen we're on:
		current_select_screen += 1
	else:
		value = slides.get_position() + Vector2(interface_screen.get_viewport_rect().size.x, 0)
		# track which screen we're on:
		current_select_screen -= 1
	
	sort_buttons()
	
	isInputEnabled = false
	tween.tween_property(slides, "rect_position", value, 0.5).set_trans(Tween.TRANS_SINE)
	tween.connect("finished", self, "_enable_input")
	pass


func sort_buttons() -> void:
	# show/hide buttons based on current screen
	# use script global, current_select_screen
	match current_select_screen:
		0:
			btn_next.show() 
			btn_prev.hide()
			btn_play.hide()
			pass
		1:
			btn_next.show() 
			btn_prev.show()
			btn_play.hide()
			pass
		2:
			btn_next.hide() 
			btn_prev.show()
			btn_play.show()
			pass
		_:
			print_debug("Did something go wrong in sort_buttons()?")


func goto_gameplay() -> void:
	emit_signal("send_selections", selections)
	SceneTransition.change_scene("res://scenes/GamePlay/GamePlay.tscn")
	BGMManager.stop_bgm()

