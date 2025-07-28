extends Node
class_name UI_Controller

"""
An aside for later -
	When you get to the Upgrade Menu portion, it may be most convenient
	to treat the left and right arrows as a grid for cursor traversal
"""

enum MENUS {BUFFER, MAIN, OPTIONS, PAUSE, UPGRADE}
enum INPUT {UP, DOWN, LEFT, RIGHT}

var menu_dict: Dictionary #Dictionary of menus for strict comparison
var menus_stack: Array[Menu] #Stack to keep track of active menus
var menus_index: int = 0 #Index to keep track of menu layer

var is_active: bool = false
var updating: bool = false

func _init() -> void:
	set_process_mode(PROCESS_MODE_ALWAYS)
	Global.upgrade_menu_open.connect(prepend_menu)
	Global.unpause.connect(hide_menu)

func _ready() -> void:
	#assert_focus()
	initialize_menu()

func initialize_menu() -> void:
	#WITHOUT SAFEGUARDS THIS SIMPLY ASSUMES EACH NODE IS A MENU
	if get_child_count() > 0:
		menus_stack.append(get_children()[0])
		for menu in get_children():
			menu_dict[menu.menu_type] = menu
			menu.request_menu.connect(handle_menu_update)
			menu.request_menu_directly.connect(push_menu)
			menu.request_menu_override.connect(handle_menu_override)
			menu.request_clear.connect(handle_menu_clear)
	
	if menus_stack: #Update cursor if menus have been appended
		menus_stack[0].update_cursor()
		
		if menus_stack[0].menu_type == MENUS.BUFFER:
			is_active = true

"""
func assert_focus() -> void:
	set_focus_mode(Control.FOCUS_ALL)
	grab_focus()
"""

func prepend_menu(new_menu: Menu) -> void:
	is_active = true
	menus_index = 0
	menus_stack.push_front(new_menu)
	new_menu.update_cursor()

func overwrite_menu(new_menu: Menu) -> void:
	is_active = true
	menus_stack[menus_index] = new_menu
	new_menu.visible = true
	new_menu.update_cursor()

func push_menu(new_menu: Menu, show_previous: bool = false) -> void:
	is_active = true
	menus_stack[menus_index].visible = show_previous
	menus_index += 1
	menus_stack.append(new_menu)
	new_menu.visible = true
	new_menu.update_cursor()

#I guarantee this will need to be modified later but leave it here for now
func handle_menu_update(menu_key: int) -> void:
	if not updating: #Replace this boolean with signals or some shit
		updating = true
		push_menu(menu_dict[menu_key])
	updating = false

func handle_menu_override(menu_key: int) -> void:
	if not updating:
		updating = true
		overwrite_menu(menu_dict[menu_key])
	updating = false

func handle_menu_clear() -> void:
	clear_menu()

func query_input(input: int) -> void:
	if menus_stack:
		menus_stack[menus_index].traverse_tab(input)

func query_confirm() -> void:
	if menus_stack:
		menus_stack[menus_index].confirm_selection()

func clear_menu(_show_previous: bool = false) -> void:
	updating = true
	
	if menus_index == 0:
		if menus_stack[0].menu_type == MENUS.UPGRADE:
			menus_stack.pop_front().refresh_data()
		
		if menus_stack[0].menu_type == MENUS.PAUSE:
			hide_menu()
			Global.unpause.emit()
		updating = false
		return
	
	if menus_stack:
		menus_stack[menus_stack.size() - 1].visible = menus_stack[menus_stack.size() - 1].leave_visible
		menus_stack[menus_stack.size() - 1].handle_exit()
		menus_stack.pop_back().refresh_data()
		menus_index -= 1
		menus_stack[menus_index].visible = true
	updating = false

func show_menu() -> void:
	is_active = true
	menus_stack[menus_index].visible = true

func hide_menu() -> void:
	is_active = false
	menus_stack[menus_index].visible = false

func parse_escape() -> void:
	if menus_stack[0].menu_type == MENUS.BUFFER: #ignor typical escape behavior if buffer menu
		return
	
	if is_active:
		clear_menu()
		return
	else:
		if not Global.paused:
			show_menu()
			Global.pause.emit()
			return #Important, so that the line of code after does not run
		if Global.paused:
			hide_menu()
			Global.unpause.emit()

func _input(event: InputEvent):
	if not updating:
		if Input.is_action_just_pressed("ui_cancel"):
			parse_escape()
	if is_active and not updating:
		if Input.is_action_just_pressed("ui_up"):
			query_input(INPUT.UP)
		if Input.is_action_just_pressed("ui_down"):
			query_input(INPUT.DOWN)
		if Input.is_action_just_pressed("ui_left"):
			query_input(INPUT.LEFT)
		if Input.is_action_just_pressed("ui_right"):
			query_input(INPUT.RIGHT)
		if event.is_action_pressed("ui_accept"):
			query_confirm()
		if event.is_action_pressed("lmb"):
			if menus_stack[menus_index].selection_hovered:
				query_confirm()
