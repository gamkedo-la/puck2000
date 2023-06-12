extends TextureButton

export(String) var text = "Button text"

func _ready() -> void:
	setup_text()
	show_arrows()
	set_focus_mode(true)
	
	# check if button is first in layout, and grab focus
	var parent = get_parent()
	if parent:
		var isFirst = get_index() == 0
		if isFirst:
			grab_focus()
	
	# set focus neighbours relative to button
	var self_index = get_index()
	
	# get node path of the prev and next buttons
	if parent.get_child(self_index - 1):
		var prev_btn = parent.get_child(self_index - 1).get_path()
		set_focus_neighbour(MARGIN_TOP, prev_btn)
	if parent.get_child(self_index + 1):
		var next_btn = parent.get_child(self_index + 1).get_path()
		set_focus_neighbour(MARGIN_BOTTOM, next_btn)


func setup_text() -> void:
	$Label.text = text


func show_arrows() -> void:
	pass

