extends Control

# The number of buttons in the menu
export var num_buttons: int = 10 # replace with number of available pucks

# The size of each button
export var button_size: Vector2 = Vector2(200, 50)

# The spacing between each button
export var button_spacing: float = 10.0

# The index of the currently selected button
var selected_index: int = 0

# The position of the first button in the menu
var button_offset: Vector2 = Vector2(0, 0)

# The position of the currently selected button
var selected_button_position: Vector2 = Vector2(0, 0)

func _ready():
	# Calculate the total size of the menu
	var menu_size = Vector2(button_size.x, button_size.y * num_buttons + button_spacing * (num_buttons - 1))
	set_size(menu_size)

	# Create the buttons
	for i in range(num_buttons):
		var button = Button.new()
		button.text = "Button " + str(i + 1)
		button.rect_min_size = button_size
		button.connect("pressed", self, "_on_button_pressed", [i])
		button.name = "puck_btn_" + str(i)
		add_child(button)

		# Position the button
		var button_position = button_offset + Vector2(0, (button_size.y + button_spacing) * i)
		button.rect_position = button_position

		# Set the position of the selected button
		if i == selected_index:
			selected_button_position = button_position

	# Select the first button
	select_button(0)

func _on_button_pressed(index):
	select_button(index)

func select_button(index):
	# Deselect the currently selected button
	if selected_index >= 0:
		var selected_button = get_node("puck_btn_" + str(selected_index))
		selected_button.modulate = Color(1, 1, 1, 1)

	# Select the new button
	selected_index = index
	var selected_button = get_node("puck_btn_" + str(selected_index))
	selected_button.modulate = Color(0, 1, 1, 1)

	# Scroll to the selected button
	var offset = selected_button.rect_position - selected_button_position
	offset.y = -offset.y
#	get_parent().scroll(offset)
