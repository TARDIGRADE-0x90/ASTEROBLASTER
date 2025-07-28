extends Menu
class_name UpgradeMenu

signal upgrade_complete

enum TABS {DAMAGE, PENETRATION, FIRERATE, PROJECTILES}

const ERR_BUTTON_INVALID: String = "Error in UpgradeMenu.gd - Invalid child node in attribute selection"
const ERR_PLAYER_INVALID: String = "Error in UpgradeMenu.gd - Player not found in scene"
const ERR_SFX_UNSET: String = "Error in UpgradeMenu.gd - SoundHandler not set"

const LEVEL_PREFIX: String = "Lvl. "
const RANK_PREFIX: String = "Rank "
const SCRAP_PREFIX: String = "Scrap Available: "

const MULTIPLIER: int = 5
const NO_HOVER: int = -1
const UPGRADE_STEP: int = 1

@export var AttributeItems: VBoxContainer
@export var AttributeButtons: VBoxContainer
@export var AttributeLevels: VBoxContainer
@export var AttributeRanks: VBoxContainer
@export var AttributeValues: VBoxContainer
@export var AttributeProjectedValues: VBoxContainer
@export var MenuSoundHandler: SoundHandler

@onready var scrap_header = $HeaderContainer/ScrapHeader
@onready var multiple_active = $HeaderContainer/MultipleActive

var attribute_type_hovered: int = NO_HOVER
var button_type_hovered: int = NO_HOVER
var buttons: Array[UpgradeButton]

var level_labels: Array
var rank_labels: Array
var value_labels: Array
var projected_value_labels: Array
var adjusting: bool = false #This is here as a safeguard to prevent simultaneous lower/raises with lmb+left/right

var previous_attributes: Array[Attribute]
var incoming_attributes: Array[Attribute]
var current_scrap: int = 0
var scrap_max: int = current_scrap

func _init() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	menu_type = UI_Controller.MENUS.UPGRADE
	menu_item_direction = DIRECTION.VERTICAL

func _ready() -> void:
	assert(Global.player, ERR_PLAYER_INVALID)
	MenuSoundHandler.parse_sound(SFXLibrary.SOUNDS.UPGRADE_ENTER)
	
	#Scrap assignment
	current_scrap = Global.zone.get_scrap()
	scrap_max = current_scrap
	scrap_header.text = str(SCRAP_PREFIX, current_scrap)
	
	#Attribute assignment
	incoming_attributes.assign(Global.player.Attributes)
	assign_menu_items(AttributeItems.get_children())
	assign_attributes() 
	assign_buttons()
	assign_attribute_labels()
	multiple_active.visible = false
	
	Global.upgrade_menu_open.emit(self)
	Global.pause.emit()

func assign_attributes() -> void: #Overwrite previous attributes 
	previous_attributes.clear()
	var i: int = 0
	while i < incoming_attributes.size():
		previous_attributes.append(Attribute.new())
		previous_attributes[i].copy_stat(incoming_attributes[i])
		i += 1

func assign_buttons() -> void:
	var type_assignment: int = 0
	for button_group in AttributeButtons.get_children():
		var i: int = 0 #NOTE: This assumes each node is structured in Button -> lower/raise organization
		while i < button_group.get_child_count():
			assert(is_instance_of(button_group.get_children()[i], UpgradeButton), ERR_BUTTON_INVALID)
			buttons.append(button_group.get_children()[i])
			button_group.get_children()[i].active.connect(handle_button_hover.bind(type_assignment, i))
			button_group.get_children()[i].inactive.connect(handle_button_exit.bind())
			i += 1
		type_assignment += 1 #The assumption is made that nodes are ordered in respective attribute type

func assign_attribute_labels() -> void:
	level_labels.assign(AttributeLevels.get_children())
	rank_labels.assign(AttributeRanks.get_children())
	value_labels.assign(AttributeValues.get_children())
	projected_value_labels.assign(AttributeProjectedValues.get_children())
	
	var i: int = 0
	while i < previous_attributes.size():
		level_labels[i].text = str(LEVEL_PREFIX, previous_attributes[i].Level)
		rank_labels[i].text = str(RANK_PREFIX, previous_attributes[i].Rank)
		value_labels[i].text = str(previous_attributes[i].Value)
		projected_value_labels[i].text = str(previous_attributes[i].Value)
		i += 1

func handle_button_hover(attribute_type: int, amount_type: int) -> void: #Assign corresponding index to cursor
	attribute_type_hovered = attribute_type
	
	match amount_type:
		UpgradeButton.TYPE.LOWER: button_type_hovered = -UPGRADE_STEP
		UpgradeButton.TYPE.RAISE: button_type_hovered = UPGRADE_STEP

func handle_button_exit() -> void:
	attribute_type_hovered = NO_HOVER

func adjust_attribute(i: int, amount: int, from_key: bool = true) -> void:
	adjusting = true #Lock attribute out to prevent simultaneous increase/decrease
	
	if from_key: buttons[(menu_index + i + max(0, amount))].animate_press() #Selection; This simply works.
	if multiple_active.visible: amount *= MULTIPLIER
	
	if amount > 0 and (current_scrap - amount < 0):
		adjusting = false  #If increasing, deny after this check (whether enough scrap is left to buy)
		MenuSoundHandler.parse_sound(SFXLibrary.SOUNDS.INSUFFICIENT)
		return
	if amount < 0 and \
			((current_scrap + abs(amount) > scrap_max) or \
			(incoming_attributes[i].Level + (amount) < previous_attributes[i].Level)):
		adjusting = false #If reducing, deny after this check (doesn't overflow scrap nor underflow level)
		MenuSoundHandler.parse_sound(SFXLibrary.SOUNDS.INSUFFICIENT)
		return
	
	incoming_attributes[i].Level += amount #Update values by amount
	incoming_attributes[i].Value += incoming_attributes[i].UpdateRate * amount
	level_labels[i].text = str(LEVEL_PREFIX, incoming_attributes[i].Level)
	projected_value_labels[i].text = str(incoming_attributes[i].Value)
	
	#Rank Handling
	if (amount > 0) and \
	((incoming_attributes[i].LevelPerRank * (incoming_attributes[i].Rank)) - incoming_attributes[i].Level) <= 0:
		incoming_attributes[i].Rank += 1
	if (amount < 0) and (incoming_attributes[i].Rank > 1) and \
	(incoming_attributes[i].Level - (incoming_attributes[i].LevelPerRank * (incoming_attributes[i].Rank - 1))) < 0:
		incoming_attributes[i].Rank -= 1
	rank_labels[i].text = str(RANK_PREFIX, incoming_attributes[i].Rank)
	
	current_scrap -= amount
	scrap_header.text = str(SCRAP_PREFIX, current_scrap)
	
	adjusting = false

func traverse_tab(input_value: int) -> void:
	match input_value:
		UI_Controller.INPUT.UP:
			cycle_index(BACK)
		UI_Controller.INPUT.DOWN:
			cycle_index(FORWARD)
		UI_Controller.INPUT.LEFT:
			if not adjusting: adjust_attribute(menu_index, -UPGRADE_STEP)
		UI_Controller.INPUT.RIGHT:
			if not adjusting: adjust_attribute(menu_index, UPGRADE_STEP)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"): multiple_active.visible = true
	if event.is_action_released("shift"): multiple_active.visible = false
	
	if not adjusting:
		if event.is_action_pressed("lmb"):
			if attribute_type_hovered != NO_HOVER:
				adjust_attribute(attribute_type_hovered, button_type_hovered, false)

#Overrides the menu as this is a special menu derivative
func confirm_selection() -> void: 
	assign_attributes() #assign the new attributes to the player
	Global.player.Attributes.assign(previous_attributes) 
	Global.player.stats_updated.emit()
	Global.zone.set_scrap(current_scrap)
	MenuSoundHandler.parse_sound(SFXLibrary.SOUNDS.CONFIRM) 

func refresh_data() -> void: 
	assert(menu_items, ERR_NULL_LIST)
	
	Global.player.Attributes.assign(previous_attributes) #resets any adjustments made on the menu
	upgrade_complete.emit()
	
	if selection: selection.clear_highlight()
	menu_index = 0
	selection = menu_items[menu_index]
	MenuSoundHandler.parse_sound(SFXLibrary.SOUNDS.UPGRADE_EXIT)
	
	queue_free()
