extends Node
# ANTIMONY 'Viewports' by Banderi --- v1.0

### Code by aaronfranke & fbcosentino from https://github.com/godotengine/godot-proposals/issues/1302

var spatial_editor_viewport_container = null
func find_SpatialEditorViewportContainer(node: Node, recursive_level):
	if !Engine.editor_hint:
		return null
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_SpatialEditorViewportContainer(child, recursive_level)
			if result != null:
				return result
func get_3D_editor(tree: SceneTree, recursive_level = 0):
	if !Engine.editor_hint:
		return null
	var result = []
	if spatial_editor_viewport_container == null:
		spatial_editor_viewport_container = find_SpatialEditorViewportContainer(tree.get_root().get_node("EditorNode"), recursive_level)
	for spatial_editor_viewport in spatial_editor_viewport_container.get_children():
		var viewport_container = spatial_editor_viewport.get_child(0)
		var control = spatial_editor_viewport.get_child(1)
		var viewport = viewport_container.get_child(0)
		var camera = viewport.get_child(0)
		result.append( {
			"viewport_container": viewport_container,
			"viewport": viewport,
			"camera": camera,
			"control": control,
		} )
	return result
func get_3D_viewport(tree: SceneTree):
	if !Engine.editor_hint:
		return null
	var r = get_3D_editor(tree, 0)
	if r.size() > 0:
		r = r[0]
		return r.viewport
func get_3D_camera(tree: SceneTree):
	if !Engine.editor_hint:
		return tree.get_root().get_viewport().get_camera()
	var r = get_3D_editor(tree, 0)
	if r.size() > 0:
		r = r[0]
		return r.camera
func get_2D_editor(tree: SceneTree, recursive_level = 0):
	var node = tree.get_root().get_node("EditorNode")
	if node.get_class() == "CanvasItemEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = get_2D_editor(child, recursive_level)
			if result != null:
				return result

### 3D helpers

var space3D = null
var space2D = null # unused for now
func raycast(from, to, exclude = [], mask = 0x7FFFFFFF):
	if from is Vector3:
		if space3D == null:
			return
		return space3D.intersect_ray(from, to, exclude, mask)
	if from is Vector2:
		if space2D == null:
			return
		return space2D.intersect_ray(from, to, exclude, mask)
func raycast_continuous(from, normal, max_hits = 100, exclude = [], mask = 0x7FFFFFFF, max_distance = 9999):
	var hits = []
	var to = from + normal * max_distance
	while hits.size() < max_hits:
		var r = raycast(from, to, exclude, mask)
		if r != null && r.size() > 0:
#			var distance_from_last_point = from.distance_squared_to(r.position)
#			if distance_from_last_point > 0.01:
			hits.push_back(r)
			from = r.position + normal * 0.0001 # epsilon
		else:
			break
	return hits
func mouse_position():
	return get_viewport().get_mouse_position()
func mousepick_vector(camera : Camera):
	var mouse_position = mouse_position()
	return {
		"position": camera.project_ray_origin(mouse_position),
		"normal": camera.project_ray_normal(mouse_position)
	}
func mousepick(camera : Camera, max_hits, exclude = [], mask = 0x7FFFFFFF, max_distance = 9999):
	var mouse_vector = mousepick_vector(camera)
	return raycast_continuous(mouse_vector.position, mouse_vector.normal, max_hits, exclude, mask, max_distance)

func clampdamp(from, to, rate, delta): # modified lerp that takes into account framerate
	# yes I know, the formula is not the "correct" one.
	# but the "correct" one looks/acts like garbage so I'll just use
	# a simple scaling + clamping, so there >:(
	var coeff = rate * delta
	if coeff > 1:
		coeff = 1
	return from + (to - from) * coeff
func smoothslide(from, to, speed, delta): # move from A to B in a smooth linear motion
	var coeff = delta * speed
	var distance = to - from
	var step = distance.normalized() * coeff
	if step.length() > distance.length():
		step = distance
	return from + step
func correct_look_at(node, from, to):
	node.set_global_translation(from)
	var vector = to - from
	var angle = vector.angle_to(Vector3(0, 1, 0))
	if angle < 0.2 || angle > PI:
		node.look_at(from + vector, Vector3(0, 0, 1))
	else:
		node.look_at(from + vector, Vector3(0, 1, 0))
func angle_around_axis(vector, axis):
	var base = Vector3(1, 0, 0)
	var angle = vector.normalized().angle_to(base)

	var normal = base.cross(vector)
	var direction = sign(normal.dot(axis))
	if direction == 0:
		direction = 1

	return angle * direction
func match_camera_phi(vector : Vector3, camera : Camera):
	return vector.rotated(Vector3.UP, camera.global_transform.basis.get_euler().y)

func world2D_to_screen(canvas_transform : Transform2D, world : Vector2):
	return canvas_transform * world
func screen_to_world2D(canvas_transform : Transform2D, screen : Vector2):
	return canvas_transform.affine_inverse() * screen
#func world3D_to_screen(camera : Camera, position : Vector3):
#	if camera.is_position_behind(position):
#		return Vector2(-9999,-9999)
#	return camera.unproject_position(position)
#func screen_to_world3D(camera : Camera, position : Vector2, max_distance = 9999):
#	pass # TODO: this isn't immediately trivial.

#func to2D(v : Vector3):
#	return Vector2(v.x, v.y)
#func to3D(v : Vector2, z):
#	return Vector3(v.x, v.y, z)
#func stitch3D(v_2D : Vector2, v_3D : Vector3):
#	return Vector3(v_2D.x, v_2D.y, v_3D.z)

func rect_from_two_points(p1 : Vector2, p2 : Vector2):
	return Rect2(min(p1.x, p2.x), min(p1.y, p2.y), abs(p2.x - p1.x), abs(p2.y - p1.y))
