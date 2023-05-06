class_name GameScene
extends Node

signal scene_changed(scene_name, request)

onready var scene_name = get_name()


func _change_scene_triggered(request) -> void:
	emit_signal("scene_changed", scene_name, request)

