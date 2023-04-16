extends Control

class Vector:
	var object  # The node to follow
	var property  # The property to draw
	var scale  # Scale factor
	var width  # Line width
	var color  # Draw color

	func _init(_object, _property, _scale, _width, _color):
		object = _object
		property = _property
		scale = _scale
		width = _width
		color = _color

	func draw(node, camera: Camera):		
		var start = camera.unproject_position(object.global_transform.origin)
		var end = camera.unproject_position(object.global_transform.origin + object.get(property) * scale)
		node.draw_line(start, end, color, width)
#		node.draw_triangle(end, start.direction_to(end), width*2, color)

			

class Point:
	var object
	var point_vec
	var radius
	var color
	
	func _init(_object, _point_vec, _radius, _color):
		object = _object
		point_vec = _point_vec
		radius = _radius
		color = _color
	
	func draw(node, camera: Camera):
		var pointv = object.get(point_vec)
		var unproj_point = camera.unproject_position(pointv)
		node.draw_circle(unproj_point, radius, color)

class SteerRay:
	var object
	var actor
	var ray_array
	var interest
	var danger
	var scale
	var width
	var color
	
	func _init(_object, _actor, _ray_array, _interest, _danger, _scale, _width, _color):
		object = _object
		actor = _actor
		ray_array = _ray_array
		interest = _interest
		danger = _danger
		scale = _scale
		width = _width
		color = _color
	
	func draw(node, camera: Camera):
		var start
		var end
		var danger_arr = object.get(danger)
		var interest_arr = object.get(interest)
		for i in ray_array.size():
			if ray_array[i]:				
				var rot_ray = ray_array[i].rotated(Vector3.UP, deg2rad(actor.rotation_degrees.y))
				ray_array[i].rotated(Vector3.UP, deg2rad(actor.rotation_degrees.y))
				start = camera.unproject_position(actor.global_transform.origin)
				end = camera.unproject_position(actor.global_transform.origin + (rot_ray * scale))
				node.draw_line(start, end, color, width)
				if interest_arr[i] > 0.0:
					end = camera.unproject_position(object.global_transform.origin + ((rot_ray * scale) * interest_arr[i]))
					node.draw_line(start, end, Color.green, width)
				if danger_arr[i] > 0.0:
					start = camera.unproject_position(object.global_transform.origin + ((rot_ray * scale) * interest_arr[i]))
					end = camera.unproject_position(object.global_transform.origin + ((rot_ray * scale) * danger_arr[i]))
					node.draw_line(start, end, Color.red, width)

class RayHits:
	var object
	var hits_array_name
	var radius
	var color
	var draws
	
	func _init(_object, _hits_array, _radius, _color):
		object = _object
		hits_array_name = _hits_array
		radius = _radius
		color = _color
		draws = 1
	
	func draw(node, camera: Camera):
		var unproj_hit
		var hits_array = object.get(hits_array_name)
		for hit in hits_array:
			unproj_hit = camera.unproject_position(hit)
#			node.draw_circle((hit - object.global_transform.origin), radius, color)
			node.draw_circle(unproj_hit, radius, color)



var vectors = []  # Array to hold all registered values.
var points = []
var steer_rays = []
var ray_hits = []
var ray_hits_tracked = []

func _process(_delta):
	if not visible:
		return
	update()

func _draw():
	var camera = get_viewport().get_camera()
	var _trash_can = []
	for vector in vectors:
		if is_instance_valid(vector.object) && vector.object.is_inside_tree():
			vector.draw(self, camera)
	for point in points:
		if is_instance_valid(point.object) && point.object.is_inside_tree():
			point.draw(self, camera)
	for steer_ray in steer_rays:
		if is_instance_valid(steer_ray.object) && steer_ray.object.is_inside_tree():
			steer_ray.draw(self, camera)
	for ray_hit in ray_hits:
		if is_instance_valid(ray_hit.object) && ray_hit.object.is_inside_tree():
			ray_hit.draw(self, camera)
		
func add_vector(object, property, scale, width, color):
	vectors.append(Vector.new(object, property, scale, width, color))

func add_point(object, point_vec, radius, color):
	points.append(Point.new(object, point_vec, radius, color))

func add_rayarray(object, actor, ray_array, interest, danger, scale, width, color):
	steer_rays.append(SteerRay.new(object, actor, ray_array, interest, danger, scale, width, color))

func add_hitarray(object, hits_array, radius, color):
	if ray_hits.size() > 0:
		for hits in ray_hits:
			if hits.object == object:
				hits.hits_array = hits_array
				hits.radius = radius
				hits.color = color				
				return	
	ray_hits.append(RayHits.new(object, hits_array, radius, color))
