extends Area2D
class_name Player

#Reminder:
#When focusing, perhaps apply a damage buff that's equal to (1.0 + (ProjectileRank - 1) * 0.1)
signal receive_damage
signal health_changed
signal upgrade_requested
signal scrap_collected #NOTE: ScrapCatcher is set to CollisionLayer2
signal stats_updated

enum STAT_INDEX {DAMAGE, PENETRATION, FIRERATE, PROJECTILES}

const ERR_OWNER_UNSET: String = "Error in Player.gd : fire() - Scene owner not set"

const PLAYER_SHOT: PackedScene = preload(FilePaths.PROJECTILE)
const PLAYER_SHOT_DATA: ProjectileData = preload(FilePaths.PLAYER_PROJECTILE_DATA)
const DEFAULT_SHOT_DATA: ProjectileData = preload(FilePaths.BASE_PLAYER_PROJECTILE_DATA)

const DEFAULT_DAMAGE: Attribute = preload(FilePaths.BASE_DAMAGE_ATTRIBUTE)
const DEFAULT_FIRERATE: Attribute = preload(FilePaths.BASE_FIRERATE_ATTRIBUTE)
const DEFAULT_PENETRATION: Attribute = preload(FilePaths.BASE_PENETRATION_ATTRIBUTE)
const DEFAULT_PROJECTILES: Attribute = preload(FilePaths.BASE_PROJECTILE_ATTRIBUTE)

const MAX_HEALTH: int = 5

const CANNON_STEP_X: int = 16
const CANNON_STEP_Y: int = -4
const MAX_PROJ_SPEED: float = -24

const BASE_ACCELERATION: float = .35
const FOCUS_SPEED_FACTOR: float = .50
const LEFT_MARGIN_LENIENCE: int = 16
const RIGHT_MARGIN_LENIENCE: int = 16

@export var PlayerProjectileManager: ProjectileManager
@export var PlayerSoundHandler: SoundHandler
@export var Attributes: Array[Attribute]
@export var Acceleration: float = BASE_ACCELERATION
@export var BaseSpeed: int = 10

var firerate_cooldown: Timer #initialize in ready method
var proj_data: ProjectileData = PLAYER_SHOT_DATA
var default_attributes: Array[Attribute]

var direction_x: int = 0
var current_speed := BaseSpeed
var current_velocity := Vector2(0, 0)
var current_direction := Vector2(0,0)

var health: int = MAX_HEALTH
var firing: bool = false
var focusing: bool = false

func _ready() -> void:
	set_meta(ObjectMeta.IS_ACTOR, true)
	reset_stats()
	
	receive_damage.connect(handle_damage)
	scrap_collected.connect(handle_scrap_collect)
	stats_updated.connect(handle_stat_update)
	
	firerate_cooldown = PlayerProjectileManager.ShotTimer
	firerate_cooldown.wait_time = Attributes[STAT_INDEX.FIRERATE].Value
	firerate_cooldown.set_one_shot(true)

func _physics_process(_delta: float) -> void:
	update_velocity()
	if firing: fire()

func _unhandled_input(event: InputEvent) -> void:
	parse_movement(event)
	parse_firing_focus(event)
	parse_attack_input(event)
	parse_upgrade_request(event)

func parse_movement(_event: InputEvent) -> void:
	direction_x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	current_direction.x = direction_x

func parse_firing_focus(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		focusing = true
		current_speed = BaseSpeed * FOCUS_SPEED_FACTOR
	if event.is_action_released("shift"):
		focusing = false
		current_speed = BaseSpeed

func parse_attack_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"): firing = true
	if event.is_action_released("fire"): firing = false

func parse_upgrade_request(event: InputEvent) -> void:
	if event.is_action_pressed("request"):
		upgrade_requested.emit()

func update_velocity() -> void:
	Acceleration = BASE_ACCELERATION
	
	if (direction_x < 0 and global_position.x <= Global.zone_left - LEFT_MARGIN_LENIENCE) or (direction_x > 0 and global_position.x >= Global.zone_right + RIGHT_MARGIN_LENIENCE):
		if Acceleration != 1: Acceleration = 1 #Line to prevent extreme slide-out that can occur
		current_velocity = Vector2(0, 0) #zone binding
		translate(current_velocity)
		return
	
	current_velocity = lerp(current_velocity, current_direction * current_speed, Acceleration)
	translate(current_velocity)

func handle_damage() -> void:
	health -= 1
	health_changed.emit()
	PlayerSoundHandler.parse_sound(SFXLibrary.SOUNDS.PLAYER_HURT)

func handle_scrap_collect() -> void:
	PlayerSoundHandler.parse_sound(SFXLibrary.SOUNDS.COLLECT)

func fire() -> void:
	if firerate_cooldown.is_stopped():
		fire_shot_formation_pyramid() #can be replaced with match statement for different shot formations
		firerate_cooldown.start()
		PlayerSoundHandler.parse_sound(SFXLibrary.SOUNDS.PLAYER_FIRE)

func fire_shot_formation_pyramid() -> void: #abhorrent cluster of attribute and shot placement data based on a diagram I drew
	var cannon_anchor_x_unfocused: int = (-((CANNON_STEP_X * 0.5) * (Attributes[Attribute.TYPES.PROJECTILES].Rank - 1)))
	var cannon_anchor_x_focused: int = (-((CANNON_STEP_X * 0.5) * (Attributes[Attribute.TYPES.PROJECTILES].Rank - 1))) * 0.5
	var cannon_anchor_x: int = 0
	var cannon_anchor_y: int = CANNON_STEP_Y if Attributes[Attribute.TYPES.PROJECTILES].Rank > 2 else 0
	var x_step_unfocused: int = CANNON_STEP_X 
	var x_step_focused: int = (CANNON_STEP_X * 0.5)
	var current_x_step: int = 0
	var cannons_even: bool = Attributes[Attribute.TYPES.PROJECTILES].Rank % 2 == 0 
	var flip_point: int = (Attributes[Attribute.TYPES.PROJECTILES].Rank * 0.5)
	var flipped: bool = false #All of this is based on the projectiles diagram
	var x_step: int = 0
	var y_step: int = 0 #applying floorf on thousands of floats per second is slow btw, remember this
	
	if focusing: #slightly neater than cramped ternaries and, possibly, improves performance slightly
		current_x_step = x_step_focused
		cannon_anchor_x = cannon_anchor_x_focused
	else: 
		current_x_step = x_step_unfocused
		cannon_anchor_x = cannon_anchor_x_unfocused
	
	for i in range(Attributes[Attribute.TYPES.PROJECTILES].Rank):
		x_step = cannon_anchor_x + (current_x_step * i)
		if (i == flip_point and cannons_even):	pass #Skip the change of y_step at this specific point
		elif not flipped:						y_step = cannon_anchor_y * i
		else:									y_step -= cannon_anchor_y
	
		PlayerProjectileManager.generate_projectile(global_position, PLAYER_SHOT, proj_data, Vector2(x_step, y_step))
		if i == flip_point: flipped = true
		i += 1

#a duct-taped solution to reset stat data upon resetting
func reset_stats() -> void: #BE COGNIZANT OF WHERE THIS IS PLACED - Planning to create different zones later
	Attributes[Attribute.TYPES.DAMAGE].copy_stat(DEFAULT_DAMAGE)
	Attributes[Attribute.TYPES.FIRERATE].copy_stat(DEFAULT_FIRERATE)
	Attributes[Attribute.TYPES.PENETRATION].copy_stat(DEFAULT_PENETRATION)
	Attributes[Attribute.TYPES.PROJECTILES].copy_stat(DEFAULT_PROJECTILES)
	proj_data.copy_data(DEFAULT_SHOT_DATA)

func handle_stat_update() -> void:
	#perhaps modify colors for projectile based on stat values later?
	proj_data.Damage = Attributes[Attribute.TYPES.DAMAGE].Value
	proj_data.Penetration = Attributes[Attribute.TYPES.PENETRATION].Rank
	firerate_cooldown.set_wait_time(Attributes[Attribute.TYPES.FIRERATE].Value)
	#PlayerProjectileManager.update_pool(proj_data) #override all current projectiles in pool
