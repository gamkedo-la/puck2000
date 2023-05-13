extends Spatial
# Simple script to rotate object for inspection

export var rotation_speed = 0.025 # in radians

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	rotate_y(rotation_speed)
	pass
