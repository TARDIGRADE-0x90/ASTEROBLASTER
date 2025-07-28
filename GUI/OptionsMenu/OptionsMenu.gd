extends Menu
class_name OptionsMenu

#Return to update this after proper options have been implemented
enum TABS {TAB_MUSIC, TAB_SFX, TAB_VFX, TAB_RETURN}

const MUSIC_PREFIX: String = "Music"
const SFX_PREFIX: String = "SFX"
const VFX_PREFIX: String = "VFX"

const ON_SUFFIX: String = ": ON"
const OFF_SUFFIX: String = ": OFF"

var VFX_SUFFIXES = {
	Global.VFX_LEVELS.MINIMUM: ": MINIMUM",
	Global.VFX_LEVELS.MEDIUM: ": MEDIUM",
	Global.VFX_LEVELS.MAXIMUM: ": MAXIMUM"
}

const MIN_SUFFIX: String = ": MINIMUM"
const MED_SUFFIX: String = ": MEDIUM"
const MAX_SUFFIX: String = ": MAXIMUM"

@onready var options_menu_items = $MarginContainer/OptionsSpace/MarginContainer/OptionsMenuItems

func _init() -> void:
	menu_type = UI_Controller.MENUS.OPTIONS
	menu_item_direction = DIRECTION.VERTICAL

func _ready() -> void:
	assign_menu_items(options_menu_items.get_children())
	
	if Global.music_active: options_menu_items.get_children()[TABS.TAB_MUSIC].title.text = str(MUSIC_PREFIX, ON_SUFFIX)
	else: options_menu_items.get_children()[TABS.TAB_MUSIC].title.text = str(MUSIC_PREFIX, OFF_SUFFIX)
	
	if Global.sfx_active: options_menu_items.get_children()[TABS.TAB_SFX].title.text = str(SFX_PREFIX, ON_SUFFIX)
	else: options_menu_items.get_children()[TABS.TAB_SFX].title.text = str(SFX_PREFIX, OFF_SUFFIX)
	
	options_menu_items.get_children()[TABS.TAB_VFX].title.text = str(VFX_PREFIX, VFX_SUFFIXES.get(Global.vfx_level))

func handle_mouseover(hovered_index: int) -> void:
	selection_hovered = true
	menu_index = hovered_index
	update_cursor()

func handle_mouse_exit() -> void:
	selection_hovered = false

func confirm_selection() -> void:
	match menu_index:
		TABS.TAB_MUSIC:
			Global.music_active = !Global.music_active
			if Global.music_active: 
				options_menu_items.get_children()[TABS.TAB_MUSIC].title.text = str(MUSIC_PREFIX, ON_SUFFIX)
				Global.start_music.emit()
			else: 
				options_menu_items.get_children()[TABS.TAB_MUSIC].title.text = str(MUSIC_PREFIX, OFF_SUFFIX)
				Global.stop_music.emit()
		
		TABS.TAB_SFX:
			Global.sfx_active = !Global.sfx_active
			if Global.sfx_active: 
				options_menu_items.get_children()[TABS.TAB_SFX].title.text = str(SFX_PREFIX, ON_SUFFIX)
			else: 
				options_menu_items.get_children()[TABS.TAB_SFX].title.text = str(SFX_PREFIX, OFF_SUFFIX)
		
		TABS.TAB_VFX:
			Global.vfx_level -= 1
			if Global.vfx_level < 0: #wrap back
				Global.vfx_level = Global.VFX_LEVELS.MAXIMUM
			
			options_menu_items.get_children()[TABS.TAB_VFX].title.text = str(VFX_PREFIX, VFX_SUFFIXES.get(Global.vfx_level))
		
		TABS.TAB_RETURN:
			request_clear.emit()
