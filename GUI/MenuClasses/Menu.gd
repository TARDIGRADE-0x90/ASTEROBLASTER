extends Control
class_name Menu

signal request_menu(menu_key: int)
signal request_menu_directly(menu: Menu)
signal request_menu_override(menu_key: int)
signal request_clear()

const ERR_NULL_LIST: String = "Error (Menu.gd) - menu_items is null or zero length"

const BACK: int = -1
const FORWARD: int = 1
var cols: int = 1

enum DIRECTION {VERTICAL, HORIZONTAL, GRID}

var menu_type: int = -1
var menu_item_direction: int
var menu_items: Array[MenuItem]
var menu_index: int = 0

var selection: MenuItem
var selection_hovered: bool = false
var leave_visible: bool = false

func toggle_visible() -> void:
	visible = !visible

func assign_menu_items(menus: Array[Variant]) -> void:
	var i: int = 0
	while i < menus.size():
		menu_items.append(menus[i])
		menus[i].tab_index = i
		menus[i].hovering.connect(handle_mouseover)
		menus[i].not_hovering.connect(handle_mouse_exit)
		i += 1

func traverse_tab(input_value: int) -> void:
	match menu_item_direction:
		DIRECTION.VERTICAL:
			match input_value:
				UI_Controller.INPUT.UP:
					cycle_index(BACK)
				UI_Controller.INPUT.DOWN:
					cycle_index(FORWARD)
		DIRECTION.HORIZONTAL:
			match input_value:
				UI_Controller.INPUT.LEFT:
					cycle_index(BACK)
				UI_Controller.INPUT.RIGHT:
					cycle_index(FORWARD)
		DIRECTION.GRID:
			match input_value:
				UI_Controller.INPUT.UP:
					cycle_index(-cols)
				UI_Controller.INPUT.DOWN:
					cycle_index(cols)
				UI_Controller.INPUT.LEFT:
					cycle_index(BACK)
				UI_Controller.INPUT.RIGHT:
					cycle_index(FORWARD)

func cycle_index(step: int) -> void:
	assert(menu_items, ERR_NULL_LIST)
	
	#If weird shit ever happens look back at this line of code
	if menu_index + step > menu_items.size():
		menu_index = 0 #Wrap back to front if exceeding (specifically made for column traversals with step > 1)
	else: #Cycle by step amount, applicable for both linear and column step
		menu_index = (menu_index + step) % menu_items.size()
	
	if menu_index < 0: #Wrap back to end of the array if decreasing
		menu_index = menu_items.size() - 1
	
	update_cursor()

func update_cursor() -> void:
	assert(menu_items, ERR_NULL_LIST)
	#Clear previous selection
	if selection: selection.clear_highlight()
	
	selection = menu_items[menu_index]
	selection.highlight()
	
	handle_cursor_update()

func refresh_data() -> void:
	assert(menu_items, ERR_NULL_LIST)
	if selection:
		selection.clear_highlight()
	
	menu_index = 0
	selection = menu_items[menu_index]

#Abstract methods
func confirm_selection() -> void:
	pass

func handle_selection() -> void:
	pass

func handle_mouseover(_hovered_index: int) -> void:
	pass

func handle_mouse_exit() -> void:
	pass

func handle_cursor_update() -> void:
	pass

func handle_exit() -> void:
	pass
