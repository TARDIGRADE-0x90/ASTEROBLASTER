extends Control
class_name MenuItem

const COLOR_DEFAULT = Color(1, 1, 1, 1)
const COLOR_HIGHLIGHT = Color(0.9, 0.7, 0.3, 0.85)

var tab_index: int = -1

func clear_highlight() -> void:
	modulate = COLOR_DEFAULT

func highlight() -> void:
	modulate = COLOR_HIGHLIGHT

