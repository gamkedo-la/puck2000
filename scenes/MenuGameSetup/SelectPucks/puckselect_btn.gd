extends TextureButton

#export(String) var text = "Button text"
# set focus neighbours relative to button
onready var self_index = get_index()
onready var parent = get_parent()
#var isAnimationInProgress = false


func _ready() -> void:
	set_focus_mode(true)
	# check if button is first in layout, and grab focus
	# get node path of the prev and next buttons


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && has_focus():
		prints("you selected a puck", self.name)
	if event.is_action_released("ui_accept") && has_focus():
		prints("selection confirmed")


func _process(delta:float) -> void:
	if has_focus():
		var rect = get_rect()
		var viewport_rect = get_viewport_rect()
		
		if rect.intersects(viewport_rect):
			var intersection = rect.clip(viewport_rect)
			var intersection_area = intersection.size.x * intersection.size.y
			var button_area = rect.size.x * rect.size.y
			
			var percent_visible = intersection_area / button_area
			
			if percent_visible < 1.0:
				print("button is partially off-screen")
				var button_global_pos = get_global_position()
				var button_y = button_global_pos.y
				
				if button_y < viewport_rect.position.y:
					print("button is near the top")
					scroll_buttons(1)
				elif button_y + rect.size.y > viewport_rect.position.y + viewport_rect.size.y:
					print("button is near the bottom")
					scroll_buttons(-1)
			else:
				print("button is full on-screen")
		else:
			print("button is off-screen")


func scroll_buttons(direction:int) -> void:
#	if isAnimationInProgress:
#		return
	
	var button_count = parent.get_child_count()
#	var scroll_distance = get_rect().size.y * direction
	var scroll_distance = 10 * direction # tied to update rate - need to find a way to decouple animation and input...
	
#	isAnimationInProgress = true
	
	for i in range(button_count):
		var button = parent.get_child(i)
		var target_position = button.rect_position.y + scroll_distance
		
		button.rect_position.y = target_position
		
#		var tween = Tween.new()
#		tween.interpolate_property(button, "rect_position:y", button.rect_position.y, target_position, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		tween.start()
		
		# Attach a completion callback to the last button to indicate the end of the animation
#		if i == button_count - 1:
#			tween.connect("tween_completed", self, "_on_tween_complete")


#func _on_tween_complete() -> void:
#	isAnimationInProgress = false


func set_text(text) -> void:
	$Label.text = text


func set_puck() -> void:
	# set puck to send to gameplay scene
	pass


func set_focus() -> void:
	if parent:
		var isFirst = get_index() == 0
		if isFirst:
			grab_focus()


func set_button_neighbours() -> void:
	if parent.get_child(self_index - 1):
		var prev_btn = parent.get_child(self_index - 1).get_path()
		set_focus_neighbour(MARGIN_TOP, prev_btn)
	if parent.get_child(self_index + 1):
		var next_btn = parent.get_child(self_index + 1).get_path()
		set_focus_neighbour(MARGIN_BOTTOM, next_btn)
