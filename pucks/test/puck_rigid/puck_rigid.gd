extends RigidBody

export var camera_node_path:NodePath
export var isInteractable:bool
export var push_force:float

var rayOrigin = Vector3.ZERO
var rayEnd = Vector3.ZERO
var targetDest = Vector3.ZERO

var isSelected:bool = false

onready var camera = get_node(camera_node_path)
onready var pointer = $Pointer


func _ready() -> void:
	$Pointer.visible = false
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:

	targetDest = Vector3.ZERO
	rayOrigin = Vector3.ZERO
	rayEnd = Vector3.ZERO
	
	if isSelected:
		
		# get current physics state
		var space_state = get_world().direct_space_state
		# get current mouse position in the viewport
		var mouse_position = get_viewport().get_mouse_position()
		# set the ray origin
		rayOrigin = camera.project_ray_origin(mouse_position) 
		# set the ray end point
		rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000 
		# get the ray hit
		var intersection = space_state.intersect_ray(rayOrigin, rayEnd) 
		# if there is a proper ray hit get its position and rotate towards it
		if not intersection.empty(): 
			var pos = intersection.position
			var look_here = Vector3(pos.x, translation.y, pos.z)
			
			# need an "offset" for when the puck rotates whilst moving
			# lock the Angular Y axis for now for prototype
			targetDest = translation - look_here
			pointer.look_at(Vector3(targetDest.x, translation.y, targetDest.z), Vector3(0, 1, 0))
			
		pass

# this will need refactoring to work for instanced pucks
# right now all pucks are firing "released button"
# warning-ignore:unused_argument
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released ("puck") && isInteractable:
		var position = self.translation
		apply_impulse(position, Vector3.FORWARD * push_force)
	
	if Input.is_action_just_released("select"):
		print("released button")
		var position = self.translation
		apply_impulse(position, targetDest.normalized() * push_force)
		pointer.visible = false
		isSelected = false



# warning-ignore:unused_argument

func _on_Puck_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:

	if Input.is_action_pressed("select"):
		pointer.visible = true
		isSelected = true
		if event is InputEventMouseMotion:
			pass
	
#	if Input.is_mouse_button_pressed( 1 ): # Left click
#		# Perform some stuff.
#		print("_on_Puck")
#		prints(camera,event,position,normal,shape_idx)


#func _check_direction() -> Vector2:
#	# get current mouse position in the viewport
#	var mouse_position = get_viewport().get_mouse_position()
##	print(mouse_position)
#	return Vector2(mouse_position.x, mouse_position.y)
