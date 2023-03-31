extends KinematicBody

var last_collision = null
var velocity: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.move_lock_y = true
	
	velocity = Vector3.ZERO
	
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released ("puck"):
		var position = self.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	var current_collision = move_and_collide(Vector3.FORWARD * delta)
	if current_collision != null && current_collision != last_collision:
		print(current_collision)
		last_collision = current_collision
	pass
