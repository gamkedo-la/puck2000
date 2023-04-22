extends RigidBody

# warning-ignore:unused_signal
signal puck_selected

export var camera_node_path:NodePath
export var isInteractable:bool
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

onready var camera = get_node(camera_node_path)
onready var pointer = $Pointer


func _ready() -> void:
	isSelected = false
#	isReset = false
	$Pointer.visible = false
	pass # Replace with function body.


#func look_follow(state, current_transform, target_position):
#	var up_dir = Vector3(0, 1, 0)
#	var cur_dir = current_transform.basis.xform(Vector3(0, 0, 1)) # get vector that represents local FORWARD
#	var target_dir = (target_position - current_transform.origin).normalized()
#	$"../LabelTargetDir".text = "target_dir: " + str(target_dir)
#	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
#	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))


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

	if isDebug && isSelected:
		DebugDraw.set_text("puck pos", translation)
		DebugDraw.set_text("target pos", targetDest)
	
	if isSelected:
		find_target_pos()
		pass


func find_target_pos() -> void:
	targetDest = Vector3.ZERO
	rayOrigin = Vector3.ZERO
	rayEnd = Vector3.ZERO
	# get current physics state
	var space_state = get_world().direct_space_state
	# get current mouse position in the viewport
	var mouse_position = get_viewport().get_mouse_position()
	# set the ray origin
	rayOrigin = camera.project_ray_origin(mouse_position) 
	# set the ray end point
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000 
	# get the ray hit
	var intersection = space_state.intersect_ray(rayOrigin, rayEnd, [], 1)
#	var intersection = space_state.intersect_ray(rayOrigin, rayEnd)
	# we want to exclude anything marked on Collision layer 3 "wall" because it messes with the mouse raycast
	# if there is a proper ray hit get its position and rotate towards it
	
	if isDebug:
		DebugDraw.set_text("mouse screen pos", mouse_position)
#		DebugDraw.set_text("intersection", intersection)
		
	if not intersection.empty():
		var pos = Vector3(intersection.position.x, 0.0, intersection.position.z)
		var look_here = Vector3(pos.x, translation.y, pos.z)
		
		if isDebug:
			DebugDraw.set_text("mouse raycast pos", look_here)
			if has_node("../MouseMarker"):
				$"../MouseMarker".set_global_translation(look_here)
		
		# need an "offset" for when the puck rotates whilst moving
		# lock the Angular Y axis for now for prototype
#			targetDest = translation - look_here
#		targetDest = Vector3(-look_here.x, look_here.y, -look_here.z) #unary minus operator
		targetDest = look_here
#		DebugDraw.draw_line_3d(pos, rayEnd, Color(0, 1, 0))
		
#			pointer.look_at(Vector3(targetDest.x, translation.y, targetDest.z), Vector3(0, 1, 0))
	pass


func puck_push(direction:Vector3) -> void:
	var position = self.translation
	apply_impulse(position, direction * push_force)


func reset_inertia() -> void:
	# this is ok if fired only once?
	set_linear_velocity(Vector3.ZERO)
#	isReset = true


# warning-ignore:unused_argument
func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("select") && isSelected:
#		print("deselect")
		pointer.visible = false
		isSelected = false
		puck_push(cur_dir)


# warning-ignore:unused_argument
func _on_Puck_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
#	if self == get_parent().current_selected_puck:
#		print("currently selected puck")
	
	if Input.is_action_just_pressed("select"):
#		print("select")
		pointer.visible = true
		isSelected = true
#		emit_signal("puck_selected", self)

