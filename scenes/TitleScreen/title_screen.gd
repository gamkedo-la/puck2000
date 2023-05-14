extends Spatial

onready var start_button = $CanvasLayer/Control/HBoxContainer/StartGame

const MENU_BGM = preload("res://audio/bgm/BGM-microwaves.mp3")

func _ready() -> void:
	start_button.connect("pressed", self, "goto_main_menu")
	BGMManager.play_bgm(MENU_BGM)


func goto_main_menu() -> void:
	SceneTransition.change_scene("res://scenes/MenuMain/MenuMain.tscn")
