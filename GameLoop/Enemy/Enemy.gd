extends Area2D
class_name Enemy

signal receive_damage(damage_received: int)
signal death_finished(type: Enemy)

const ERR_SHOT_MANAGER_UNSET: String = "Error in Enemy.gd - ProjecilteManager not set for firing enemy"
const ERR_SFX_UNSET: String = "Error in Enemy.gd - SoundHandler not set"
const ERR_DMG_COLOR_UNSET: String = "Error in Enemy.gd - DamageColor is not set"

const SHOT_WAIT_MIN: float = 1.2
const SHOT_WAIT_MAX: float = 2.5

const ENEMY_SHOT: PackedScene = preload(FilePaths.PROJECTILE)
const ENEMY_SHOT_DATA: ProjectileData = preload(FilePaths.ENEMY_PROJECTILE_DATA)

@export var EnemyPoolable: Poolable
@export var EnemySoundHandler: SoundHandler
@export var EnemyProjectileManager: ProjectileManager
@export var EnemyDamageColor: DamagePainter
@export var Data: EnemyData

var zone: Zone
var current_health: int = 0
var velocity: Vector2
var shot_timer: Timer
var dead: bool = false #Made specifically to prevent damage signals from processing twice

func _init() -> void:
	set_meta(ObjectMeta.IS_ACTOR, true)

func _ready() -> void:
	assert(EnemySoundHandler, ERR_SFX_UNSET)
	
	if EnemyPoolable:
		EnemyPoolable.Active = true
	
	receive_damage.connect(take_damage)
	area_entered.connect(collide_with_player)
	body_entered.connect(collide_with_player)
	
	on_ready_initialization()
	initialize_data()

func fire(fire_timer: Timer, enemy_shot: PackedScene, shot_data: ProjectileData) -> void:
	assert(EnemyProjectileManager, ERR_SHOT_MANAGER_UNSET)

	fire_timer.set_wait_time(randf_range(SHOT_WAIT_MIN, SHOT_WAIT_MAX))
	EnemySoundHandler.parse_sound(SFXLibrary.SOUNDS.ENEMY_FIRE)
	EnemyProjectileManager.generate_projectile(global_position, enemy_shot, shot_data)

func descend() -> void:
	translate(velocity)
	
	if (global_position.y > Global.zone_bottom): #Handle termination if going beyond zone
		if Data.Collidable: Global.player.receive_damage.emit() #Damage if it also deals damage on player collison (i.e, not Supply)
		terminate()

func collide_with_player(area: Area2D) -> void:
	if Data.Collidable and Global.player == area:
		area.receive_damage.emit()
		handle_death_vfx()
		terminate()

#I cannot think of how to represent this other than fractions (which require division); if this causes a
#performance issue, investigate later
func take_damage(incoming_damage: int) -> void:
	current_health -= incoming_damage
	
	if current_health <= 0 and not dead:
		dead = true
		handle_death_vfx()
		handle_death_sfx()
		on_death() #Method that's called upon destruction
		terminate()
	
	#var difference: float = ((current_health) / float(Data.Health)) * 0.1
	#if EnemyDamageColor:
	#	EnemyDamageColor.redden(difference)

func handle_death_vfx() -> void:
	VFX.generate_debris(global_position, Data.DebrisMin, Data.DebrisMax) #as of now, around 10 frame cost from extreme spawns with debris
	VFX.generate_ripple(global_position, Data.ShipColor)
	VFX.generate_burst(global_position, Data.ShipColor)
	pass

func handle_death_sfx() -> void:
	EnemySoundHandler.parse_sound(SFXLibrary.SOUNDS.EXPLOSION2)

func initialize_data() -> void:
	#self.modulate = Color(1, 1, 1, 1)
	current_health = Data.Health
	velocity = Data.FloatSpeed
	zone = Global.zone
	dead = false
	
	if shot_timer:
		shot_timer.start()

func terminate() -> void:
	dead = true
	death_finished.emit(self)
	
	if EnemyPoolable and EnemyPoolable.Active: 
		if shot_timer:
			shot_timer.stop()
		EnemyPoolable.released.emit(self)
	else:
		call_deferred("queue_free")

#Virtual methods for child classes to use
func on_ready_initialization() -> void:
	pass

func on_death() -> void:
	pass

