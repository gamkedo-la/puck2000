extends Node
# Manages the scenes and scene transitions, 
# so this will be working at the Main.tscn level

onready var scene_anim = $TransitionPlayer

var current_scene = null


func _ready() -> void:
	current_scene = $TitleScreen
	current_scene.connect("scene_changed", self, "handle_scene_change")
	scene_anim.play("fade_in")
	print("current scene: ", current_scene.name)


func handle_scene_change(current_scene_name:String, requested_scene_name:String) -> void:
	pass


func cleanup() -> void:
	pass

