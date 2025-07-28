extends Menu
class_name BufferMenu

const POST_BUFFER_DELAY : float = 0.25

@onready var null_tab = $NullTab
@onready var anim = $Anim

var passed: bool = false

func _init() -> void:
	menu_type = UI_Controller.MENUS.BUFFER

func _ready() -> void:
	menu_items.append(null_tab)

func _input(_event: InputEvent):
	if Input.is_anything_pressed() and not passed:
		passed = true
		anim.play("triggered")
		await(anim.animation_finished)
		request_menu_override.emit(UI_Controller.MENUS.MAIN)
		visible = false
