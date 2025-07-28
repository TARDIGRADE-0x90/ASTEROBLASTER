extends Node
class_name Zone

const ERR_NULL_PLAYER: String = "Error in MainZone.gd - Player not in scene"
const ERR_PLAYER_ALREADY: String = "Error in MainZone.gd - Player already in"
const ERR_ZONE_SFX_UNSET: String = "Error in MainZone.gd - SoundHandler unset"

const HEALTH_PREFIX: String = "HEALTH: "
const SCRAP_SUFFIX: String = " SCRAP"
const UPGRADE_COOLDOWN_PREFIX: String = "UPGRADE:\n"
const UPGRADE_COOLDOWN_READY: String = "READY"
const UPGRADE_COOLDOWN_PENDING: String = "PENDING"
const UPGRADE_COOLDOWN_CONFIRM: String = "RELAYED"

const GAMEZONE_SIZE_X: int = 480
const GAMEZONE_SIZE_Y: int = 720
const X_MARGIN: int = 48
const Y_MARGIN: int = 48

const COOLDOWN_TIME: int = 30
const ENEMY_HP_BUFF_INTERVAL: int = 20
const ENEMY_SPAWN_BUFF_INTERVAL: int = 10

@export var ZoneSoundHandler: SoundHandler

@onready var fps_test = $FPSTest
@onready var enemy_manager = $EnemyManager
@onready var player_spawn = $PlayerSpawn
@onready var upgrade_caravan_spawn = $UpgradeCaravanSpawn
@onready var background_layer = $BackgroundLayer
@onready var level_gui = $BackgroundLayer/GameLoopBackground/LevelGUI
@onready var game_timer = $GameTimer

var player: Player
var current_scrap: int = 0
var upgrade_cooldown: int = COOLDOWN_TIME
var upgrade_on_cooldown: bool = true
var upgrade_pending: bool = false

func _init() -> void:
	Global.zone = self
	Global.game_time = 0
	player = load(FilePaths.PLAYER).instantiate()
	Global.player = player
	Global.add_child_to_owner(player)

func _ready() -> void:
	assign_bounds()
	#speed_time()
	
	#Enemy Manager initialization
	enemy_manager.assign_spawns(Global.zone_left)
	enemy_manager.all_clear.connect(read_all_clear)
	
	#Player initialization with relevant GUI
	assert(Global.player, ERR_NULL_PLAYER)
	player.set_global_position(player_spawn.global_position)
	player.upgrade_requested.connect(parse_upgrade_request)
	player.scrap_collected.connect(update_scrap)
	player.health_changed.connect(update_health_display)

	#Timer initialization
	game_timer.timeout.connect(count)
	game_timer.start()
	
	#Label initialization
	level_gui.update_label(LevelGUI.LABELS.TIME, str(Global.game_time))
	level_gui.update_label(LevelGUI.LABELS.SCRAP, str(current_scrap, SCRAP_SUFFIX))
	level_gui.update_label(LevelGUI.LABELS.HEALTH, str(HEALTH_PREFIX, Global.player.health))
	level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, upgrade_cooldown))
	
	if Global.music_active:
		Music.set_current_track(FilePaths.MUSIC_TRACK_A)

func _physics_process(_delta: float) -> void:
	update_fps_label()

func speed_time() -> void:
	Engine.time_scale = 2

func reset_time() -> void:
	Engine.time_scale = 1

func update_fps_label() -> void:
	fps_test.text = str(Engine.get_frames_per_second())

func update_scrap() -> void: #called on scrap collect
	current_scrap += 1
	level_gui.update_label(LevelGUI.LABELS.SCRAP, str(current_scrap, SCRAP_SUFFIX))

func set_scrap(new_value: int) -> void: #called on upgrade menu confirmation
	current_scrap = new_value
	level_gui.update_label(LevelGUI.LABELS.SCRAP, str(current_scrap, SCRAP_SUFFIX))

func get_scrap() -> int:
	return current_scrap

func update_health_display() -> void:
	level_gui.update_label(LevelGUI.LABELS.HEALTH, str(HEALTH_PREFIX, Global.player.health))
	level_gui.trigger_flash(LevelGUI.LABELS.HEALTH)

func assign_bounds() -> void:
	var current_viewport_rect: Rect2 = get_viewport().get_visible_rect()
	
	if current_viewport_rect.size > Vector2(GAMEZONE_SIZE_X, GAMEZONE_SIZE_Y):
		Global.zone_left = (current_viewport_rect.size.x * 0.5) - (GAMEZONE_SIZE_X * 0.5) + X_MARGIN
		Global.zone_right = (current_viewport_rect.size.x * 0.5) + (GAMEZONE_SIZE_X * 0.5) - X_MARGIN
		Global.zone_top = (current_viewport_rect.size.y * 0.5) - (GAMEZONE_SIZE_Y * 0.5)
		Global.zone_bottom = (current_viewport_rect.size.y * 0.5) + (GAMEZONE_SIZE_Y * 0.5)
	else:
		print("do something else LevelManager.gd, assign_bounds()")
	
	background_layer.offset.x = (Global.zone_right + Global.zone_left) * 0.5
	background_layer.offset.y = (Global.zone_top + Global.zone_bottom) * 0.5

"""
This needs to be rewritten
"""
func parse_upgrade_request() -> void:
	if current_scrap <= 0:
		level_gui.trigger_flash(LevelGUI.LABELS.SCRAP)
		ZoneSoundHandler.parse_sound(SFXLibrary.SOUNDS.UPGRADE_DENY)
	elif upgrade_on_cooldown:
		level_gui.trigger_flash(LevelGUI.LABELS.COOLDOWN)
		ZoneSoundHandler.parse_sound(SFXLibrary.SOUNDS.UPGRADE_DENY)
	else:
		if not upgrade_pending:
			level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, UPGRADE_COOLDOWN_PENDING))
			upgrade_pending = true
			upgrade_on_cooldown = true
			game_timer.paused = true
			enemy_manager.stop_timers()
			ZoneSoundHandler.parse_sound(SFXLibrary.SOUNDS.UPGRADE_REQUEST)
			
			if not enemy_manager.has_enemies(): #Automatically spawn if all enemies down
				read_all_clear() #Note that enemy_manager's _process constantly polls if enemies > 0
				return
			
			await (enemy_manager.all_clear) #Wait for enemies to destroy before proceeding
			read_all_clear()

func read_all_clear() -> void:
	if upgrade_pending:
		upgrade_pending = false
		level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, UPGRADE_COOLDOWN_CONFIRM))
		generate_upgrade_caravan()

func generate_upgrade_caravan() -> void:
	var upgrade_caravan: UpgradeCaravan = load(FilePaths.UPGRADE_CARAVAN).instantiate()
	add_child(upgrade_caravan)
	upgrade_caravan.global_position = upgrade_caravan_spawn.global_position
	upgrade_caravan.passed.connect(generate_upgrade_menu)

func generate_upgrade_menu() -> void:
	var upgrade_menu: UpgradeMenu = load(FilePaths.UPGRADE_MENU).instantiate()
	add_child(upgrade_menu) #save for later
	upgrade_menu.upgrade_complete.connect(finish_upgrades)

func finish_upgrades() -> void:
	upgrade_cooldown = COOLDOWN_TIME
	level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, upgrade_cooldown))
	game_timer.paused = false
	enemy_manager.resume_timers()

func count() -> void:
	Global.game_time += 1
	
	if upgrade_cooldown > 0:
		upgrade_cooldown -= 1
		level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, upgrade_cooldown))
	
	if upgrade_cooldown <= 0 and upgrade_on_cooldown: #boolean to stop a setter being called each second
		upgrade_on_cooldown = false
		level_gui.update_label(LevelGUI.LABELS.COOLDOWN, str(UPGRADE_COOLDOWN_PREFIX, UPGRADE_COOLDOWN_READY))
	
	if (Global.game_time > 0 and Global.game_time % ENEMY_HP_BUFF_INTERVAL == 0):
		if not enemy_manager.formation_active: #only grant buffs when a formation is not ongoing
			enemy_manager.handle_hp_buff()
	
	if (Global.game_time > 0 and Global.game_time % ENEMY_SPAWN_BUFF_INTERVAL == 0): 
		if not enemy_manager.formation_active:
			enemy_manager.handle_spawn_buff()
	
	level_gui.update_label(LevelGUI.LABELS.TIME, str(Global.game_time))
	enemy_manager.check_locked_timers()
