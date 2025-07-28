extends MenuItem
class_name UpgradeButton

enum TYPE {LOWER, RAISE}

signal active
signal inactive

@export var button_texture: Texture
@export var button_type: int = -1

@onready var icon = $Icon
@onready var anim = $Anim

func _ready() -> void:
	mouse_entered.connect(hover_over)
	mouse_exited.connect(hover_exit)
	
	if button_texture:
		icon.texture = button_texture

func animate_press() -> void:
	anim.play("pressed")

func hover_over() -> void:
	active.emit()
	highlight()
	
func hover_exit() -> void:
	inactive.emit()
	clear_highlight()
