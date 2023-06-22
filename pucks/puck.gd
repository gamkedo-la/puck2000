extends RigidBody

# 1. find_target_pos() to set targetDest Vector3
# 2. _integrate_forces(), if isSelected, look_follow() takes targetDest
# 3. _integrate_forces() also runs check_force(), which takes targetDest - deciding how powerful the puck shot is
# 4. look_follow() rotates puck to face where player is aiming
# 5. puck_push(cur_dir) fires when player Input.is_action_just_released("select")
# 6. KEEP IN MIND, you push the puck based on cur_dir, not targetDest - this means the puck will not go where you intend perfectly, you have to pay attention to the rotation of the puck and let go of the button at the right time when the puck is in alignment with the aim (a timing and observational skill check).

# warning-ignore:unused_signal
signal puck_selected

export var camera_node_path:NodePath
export var max_push_force:float = 24.0
export var push_force_multiplier:float = 2.0
export var push_force:float
export var isDebug:bool = false
export var isOpponent:bool = false
export var last_touch_duration:float = 1.0

const SFX_PUCK_COLLISION_0 = preload("res://audio/sfx/puck_impact_000.ogg")

var rayOrigin = Vector3.ZERO
var rayEnd = Vector3.ZERO
var targetDest = Vector3.ZERO

var opponent_aiming_at = Vector3.ZERO

var cur_dir:Vector3
var cur_sector:Area

# start_move_to() -> _integrate_forces()
var target_position: Vector3
var initial_position: Vector3
var final_position: Vector3

var isSelected:bool = false
var isADV:bool = true # a check for opp ai to decide what kind of target marker to aim at - check oponent_ai.gd
#var isReset:bool = false
var isLastTouched = false
var isPreparing:bool = false
var last_hit:Node = null

var last_touch_timer = null # cooldown on when AI last selected puck

onready var camera = get_node(camera_node_path)
onready var pointer = $Pointer
#onready var table = $"../../Table".get_child(0)
onready var puck_area = $Area
onready var puck_raycasts = $Raycasts


func _ready() -> void:
	isSelected = false
#	isReset = false
	$Pointer.visible = false
	
	if not self.is_connected("body_entered", self, "check_collision"):
		var puck_collide = self.connect("body_entered", self, "check_collision")
		assert(puck_collide == OK)
	
	for ray in puck_raycasts.get_children():
		ray.add_exception(self)
	_setup_last_touch()
#	prints("found table?",table.get_node("OpponentSectors").get_children())
	
#	for area in table.get_node("OpponentSectors").get_children():
#		if not area.is_connected("area_entered", self, "check_area"):
#			var sector_area = area.connect("area_entered", self, "check_area")
#			assert(sector_area == OK)

	# connect signal for area on Puck-main.tscn to detect being inside of OpponentSectors areas
	if not puck_area.is_connected("area_entered", self, "check_area"):
		var puck_area_check = puck_area.connect("area_entered", self, "check_area")
		assert(puck_area_check == OK)	
	
	if isOpponent:
		_opponent_setup()
	
	pass # Replace with function body.


func _opponent_setup() -> void:

	pass


func check_collision(body:Node) -> void:
	if isDebug:
		DebugDraw.set_text("Puck last collided with", body)
	last_hit = body
	if body.is_in_group("pucks"):
		isSelected = false
	SFXManager.play_sfx(SFX_PUCK_COLLISION_0, get_tree().current_scene, Vector2(0.7,0.9))


func check_area(area:Node) -> void:
#	prints("new area:", area, "old area:", cur_sector)
	cur_sector = area
	pass


func look_follow(state, current_transform, target_position):
	var up_dir = Vector3(0, 1, 0)
	cur_dir = current_transform.basis.xform(Vector3(0, 0, 1))
	var target_dir = (target_position - current_transform.origin).normalized()
	
	# unary minus operator
	if !isOpponent:
		target_dir = Vector3(-target_dir.x, 0.0, -target_dir.z)
	else:
		target_dir = Vector3(target_dir.x, 0.0, target_dir.z)
	
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
	if isDebug:
		DebugDraw.set_text("push_force input",new_push_force)
	new_push_force = new_push_force * push_force_multiplier
	if isDebug:
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


func _process(_delta: float) -> void:

	if isDebug:
		DebugDraw.set_text("puck pos", translation)
		DebugDraw.set_text("target pos", targetDest)
		DebugDraw.set_text("Puck last collided with", last_hit)
		
	
	if isSelected && !isOpponent:
		find_target_pos()
		pass
	
	if isSelected && isOpponent:
		# set areas to deem priority of pucks
		find_target_pos_auto(opponent_aiming_at)		
		pass
	
	if isSelected && isOpponent && isDebug:
		$Debug.visible = true
		pass
	else:
		$Debug.visible = false


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


func find_target_pos_auto(target:Vector3) -> void:
	var look_here = Vector3(target.x, translation.y, target.z)
	targetDest = look_here
	pass


#func move_to_bakedpos(target_pos:Vector3) -> void:
#	global_transform.origin = target_pos
#	pass


func puck_push(direction:Vector3, force:float) -> void:
#	print("pushed")
	var position = self.translation
	apply_impulse(position, direction * force)


func reset_inertia() -> void:
	# this is ok if fired only once?
	set_linear_velocity(Vector3.ZERO)
#	isReset = true


# warning-ignore:unused_argument
func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("select") && isSelected && !isOpponent:
#		print("deselect")
		pointer.visible = false
		isSelected = false
		last_touch_timeout() # reset any lingering isLastTouched
		puck_push(cur_dir, push_force)


# warning-ignore:unused_argument
func _on_Puck_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
#	if self == get_parent().current_selected_puck:
#		print("currently selected puck")
	
	if Input.is_action_just_pressed("select"):
#		print("select")
		pointer.visible = true
		isSelected = true
#		emit_signal("puck_selected", self)


func last_touch_timeout() -> void:
	isLastTouched = false
	last_touch_timer.stop()
	last_touch_timer.wait_time = last_touch_duration


func _setup_last_touch() -> void:
	# add a timer
	last_touch_timer = Timer.new()
	add_child(last_touch_timer)
	last_touch_timeout() # set the wait_time for the first time
	last_touch_timer.connect("timeout", self, "last_touch_timeout")
	if not last_touch_timer.is_connected("timeout", self, "last_touch_timeout"):
		var last_touch_check = last_touch_timer.connect("timeout", self, "last_touch_timeout")
		assert(last_touch_check == OK)


func last_touch_start() -> void:
	isLastTouched = true
	last_touch_timer.start()
