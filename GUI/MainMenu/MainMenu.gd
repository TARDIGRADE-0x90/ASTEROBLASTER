extends Menu
class_name MainMenu

enum TABS {START, OPTIONS, EXIT}

@onready var main_menu_items = $MainMenuArea/MenuSelection/MenuSelectionPanel/MainMenuItems

func _init() -> void:
	menu_type = UI_Controller.MENUS.MAIN
	menu_item_direction = DIRECTION.VERTICAL

func _ready() -> void:
	assign_menu_items(main_menu_items.get_children())
	
	if Global.music_active:
		Music.set_current_track(FilePaths.MUSIC_SPACE_TITLE)

func handle_mouseover(hovered_index: int) -> void:
	selection_hovered = true
	menu_index = hovered_index
	update_cursor()

func handle_mouse_exit() -> void:
	selection_hovered = false

func confirm_selection() -> void:
	match menu_index:
		TABS.START:
			Global.game_state_changed.emit(Global.GAME_STATES.GAME_LOOP)
		TABS.OPTIONS:
			request_menu.emit(UI_Controller.MENUS.OPTIONS)
		TABS.EXIT:
			get_tree().quit()
	handle_mouse_exit() #Note that this makes the item no longer receptive to mouse clicks, and it must rehover
