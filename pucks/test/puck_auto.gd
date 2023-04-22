extends RigidBody

# warning-ignore:unused_signal
signal puck_selected

export var camera_node_path:NodePath
export var max_push_force:float = 24.0
export var push_force_multiplier:float = 2.0
export var push_force:float
export var isDebug:bool = false

var rayOrigin = Vector3.ZERO
var rayEnd = Vector3.ZERO
var targetDest = Vector3.ZERO

var cur_dir:Vector3

var isSelected:bool = false
#var isReset:bool = false
var last_hit:Node = null

onready var pointer = $Pointer


func _ready() -> void:
	isSelected = false
#	isReset = false
	$Pointer.visible = false
	if not self.is_connected("body_entered", self, "check_collision"):
		var puck_collide = self.connect("body_entered", self, "check_collision")
		assert(puck_collide == OK)
	pass # Replace with function body.


func check_collision(body:Node) -> void:
	if isDebug:
		DebugDraw.set_text("Puck last collided with", body)
	last_hit = body
	if body.is_in_group("pucks"):
		isSelected = false


func look_follow(state, current_transform, target_position):
	var up_dir = Vector3(0, 1, 0)
	cur_dir = current_transform.basis.xform(Vector3(0, 0, 1))
	var target_dir = (target_position - current_transform.origin).normalized()
	
	# unary minus operator
	target_dir = Vector3(-target_dir.x, 0.0, -target_dir.z)
	
	if isDebug:
		DebugDraw.set_text("target_dir", target_dir)
		
	
	var rotation_axis = cur_dir.cross(target_dir)
	var rotation_angle = cur_dir.dot(target_dir)

	# Calculate the sign of the rotation angle using the cross product
	var angle_sign = check_sign(cur_dir.cross(target_dir).y)

	rotation_angle = clamp(rotation_angle, -1.0, 1.0)

	rotation_angle = acos(rotation_angle) * angle_sign

	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()) * rotation_axis.length())


func check_sign(x) -> float:
	if x > 0.0:
		return 1.0
	elif x < 0.0:
		return -1.0
	else:
		return 0.0


func check_force(current_transform, target_position):
	# code to check how much force to push the puck
	var new_push_force = (target_position - current_transform.origin).length()
	DebugDraw.set_text("push_force input",new_push_force)
	new_push_force = new_push_force * push_force_multiplier
	DebugDraw.set_text("push_force output",new_push_force)
	if new_push_force > max_push_force:
		new_push_force = max_push_force
	push_force = new_push_force
	pass

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	
	if isSelected:
		set_linear_velocity(Vector3.ZERO)
		look_follow(state, get_global_transform(), targetDest)
		check_force(get_global_transform(), targetDest)
	pass


func _process(_delta: float) -> void:

#	if isDebug:
#		DebugDraw.set_text("puck pos", translation)
#		DebugDraw.set_text("target pos", targetDest)
#		DebugDraw.set_text("Puck last collided with", last_hit)
	
	if isSelected:
		find_target_pos()
		pass


func find_target_pos() -> void:
	targetDest = Vector3.ZERO
	rayOrigin = Vector3.ZERO
	rayEnd = Vector3.ZERO

	var look_here = Vector3(0, translation.y, -1)
	
	targetDest = look_here
	
	pass


func puck_push(direction:Vector3) -> void:
	var position = self.translation
	apply_impulse(position, direction * push_force)


# warning-ignore:unused_argument
func _unhandled_input(event: InputEvent) -> void:
	
	
	if Input.is_action_just_pressed("puck"):
		isSelected = true
	
	if Input.is_action_just_released("puck"):
		puck_push(cur_dir)
		isSelected = false

