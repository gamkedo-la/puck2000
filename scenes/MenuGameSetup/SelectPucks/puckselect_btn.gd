extends TextureButton

export(String) var text = "Button text"

func _ready() -> void:
	setup_text()
	show_arrows()
	set_focus_mode(true)


func setup_text() -> void:
	$Label.text = text


func show_arrows() -> void:
	pass

