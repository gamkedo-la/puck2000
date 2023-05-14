extends Spatial

export var interval_value:float = 2.0

var isInputEnabled:bool = true
var start_height:float
var max_depth:float
var current_height:float


func _ready() -> void:
	var factor = $"../Pucks".get_children().size() - 1
	var height = interval_value * factor * -1.0
	current_height = get_global_transform().origin.y
	start_height = current_height
	max_depth = current_height + height
#	prints(factor, max_depth)


func _input(_event: InputEvent) -> void:
	
	if Input.is_action_pressed("ui_down") && isInputEnabled && current_height > max_depth:
#		print(transform.origin.y)
		isInputEnabled = false
		var tween = get_tree().create_tween()
		var value = get_global_transform().origin - Vector3(0, interval_value, 0)
		tween.tween_property(self, "translation", value, 0.25).set_trans(Tween.TRANS_SINE)
		tween.connect("finished", self, "_enable_input")

	if Input.is_action_pressed("ui_up") && isInputEnabled && current_height < start_height:
#		print(transform.origin.y)
		isInputEnabled = false
		var tween = get_tree().create_tween()
		var value = get_global_transform().origin + Vector3(0, interval_value, 0)
		tween.tween_property(self, "translation", value, 0.25).set_trans(Tween.TRANS_SINE)
		tween.connect("finished", self, "_enable_input")


func _enable_input() -> void:
	isInputEnabled = true
	current_height = get_global_transform().origin.y





