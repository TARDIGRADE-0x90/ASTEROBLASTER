extends MenuItem
class_name MenuTab

signal hovering(index)
signal not_hovering()

@onready var title = $Title
@onready var panel = $Panel

func _ready() -> void:
	mouse_entered.connect(relay_hover)
	mouse_exited.connect(dismiss_hover)
	title.text = self.name

func relay_hover() -> void:
	hovering.emit(tab_index)

func dismiss_hover() -> void:
	not_hovering.emit()
