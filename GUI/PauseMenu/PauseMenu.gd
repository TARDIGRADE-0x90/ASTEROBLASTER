extends Menu
class_name PauseMenu

enum TABS {RESUME, MAIN_MENU, QUIT}

@onready var pause_menu_items = $MenuSelection/MenuBars/PauseMenuItems

func _init() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	menu_type = UI_Controller.MENUS.PAUSE
	menu_item_direction = DIRECTION.VERTICAL

func _ready() -> void:
	assign_menu_items(pause_menu_items.get_children())

func handle_mouseover(hovered_index: int) -> void:
	selection_hovered = true
	menu_index = hovered_index
	update_cursor()

func handle_mouse_exit() -> void:
	selection_hovered = false

func confirm_selection() -> void:
	match menu_index:
		TABS.RESUME:
			Global.unpause.emit()
	#	TABS.OPTIONS:
	#		pass
		TABS.MAIN_MENU:
			Global.game_state_changed.emit(Global.GAME_STATES.START_SCREEN)
		TABS.QUIT:
			get_tree().quit()
