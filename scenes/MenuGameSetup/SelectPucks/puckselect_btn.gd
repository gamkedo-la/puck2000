extends TextureButton

#export(String) var text = "Button text"
# set focus neighbours relative to button
onready var self_index = get_index()
onready var parent = get_parent()

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
			else:
				print("button is full on-screen")
		else:
			print("button is off-screen")


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
