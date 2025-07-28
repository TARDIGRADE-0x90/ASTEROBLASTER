extends Node2D
class_name EnemyManager

"""
To do next -
Smooth out the shift between scattered -> formation -> scattered
"""

signal all_clear

enum ENEMY_KEYS {MOLLUSK, CHARIOT, HORNET, WING, SUPPLY}
enum SPAWN_STATE {SCATTERED, FORMATION, MINIBOSS, BOSS}

const ERR_ENEMY_REPEAT: String = "Error: EnemyManager._ready(), enemy data repeated in EnemySelection"
const META_LOCKED: String = "Locked"
const META_UNLOCK_TRIGGER: String = "UnlockTrigger"

const SPAWNS: int = 10
const Y_OFFSET: int = -16
const X_STEP: int = 48

const HP_GROWTH_FACTOR: float = .65

@export var EnemySelection: Array[EnemyData]
@export var EnemyFormationManager: FormationManager

@onready var current_enemies = $CurrentEnemies

var enemy_datas: Array[EnemyData]
var enemy_spawns: Array[Vector2]
var enemy_timers: Array[Timer]
var enemy_pools: Array[Array] #when this gets generalized, enemy pools can become Array[ObjectPool]
var enemy_count: int = 0
var enemies_present: bool = false
var formation_enemy_active: bool = false
var formation_active: bool = false
var all_timers_active: bool = true

var current_spawn_state: int = SPAWN_STATE.SCATTERED

func _ready() -> void:
	initialize_enemies()
	initialize_formation()

func initialize_formation() -> void: #Copy the existing array, but cut supply
	EnemyFormationManager.EnemyChoice.assign(EnemySelection)
	EnemyFormationManager.EnemyChoice.erase(EnemySelection[EnemyData.KEYS.SUPPLY]) #exclude supplies from formations
	
	EnemyFormationManager.FormationTimer.timeout.connect(spawn_enemy_formation.bind())
	EnemyFormationManager.EnemySelectionTimer.timeout.connect(spawn_enemy_selection) #replace 0 with randomized offset later
	EnemyFormationManager.StartDelay.timeout.connect(switch_spawning_state.bind(SPAWN_STATE.FORMATION))
	EnemyFormationManager.StopDelay.timeout.connect(switch_spawning_state.bind(SPAWN_STATE.SCATTERED))

func initialize_enemies() -> void:
	for i in range(EnemySelection.size()): 
		assert(EnemySelection.has(EnemySelection[i]), ERR_ENEMY_REPEAT) #Assert enemy selection doesn't repeat
		enemy_datas.append(EnemySelection[i]) #Note that in this manner, enemy & timer have corresponding indices
		enemy_timers.append(Timer.new()) #Generate timer corresponding to the specific entity
		enemy_timers[i].timeout.connect(spawn_enemy.bind(EnemySelection[i]))
		enemy_timers[i].wait_time = EnemySelection[i].SpawnRate
		add_child(enemy_timers[i])
		enemy_pools.append(Array()) #Each enemy array also corresponds to the index of enemy type
		
		if EnemySelection[i].TriggerTime <= Global.game_time: #Check if the trigger time is at 0 or not; lock if true
			EnemySelection[i].Active = true
			enemy_timers[i].set_meta(META_LOCKED, false)
			enemy_timers[i].start()
		else:
			enemy_timers[i].set_meta(META_LOCKED, true)
			enemy_timers[i].set_meta(META_UNLOCK_TRIGGER, EnemySelection[i].TriggerTime)
			all_timers_active = false

func _process(delta: float) -> void:
	enemies_present = get_enemy_count() > 0

#Initialization of spawn points
func assign_spawns(anchor: int) -> void:
	var current_x: int = anchor - int(X_STEP * 0.5)
	for i in range(SPAWNS):
		enemy_spawns.append(Vector2(current_x, Y_OFFSET))
		current_x += X_STEP

#Enemy generation
func spawn_enemy(new_enemy: EnemyData, spawn_index: int = randi_range(0, SPAWNS - 1)) -> void:
	generate_enemy(new_enemy, enemy_spawns[spawn_index])

func spawn_enemy_selection() -> void: #this is called in the formatoin timer
	formation_enemy_active = true #somehow this has to be set to false idk how I will do that actually
	
	if EnemyFormationManager.pattern_index >= EnemyFormationManager.current_pattern.size(): #this is necessary
		formation_enemy_active = false #maybe this should work?
		return
	
	if !EnemyFormationManager.current_enemy:
		print("come on nigga") 
		return
	
	EnemyFormationManager.spawn_point = EnemyFormationManager.current_pattern[EnemyFormationManager.pattern_index] + EnemyFormationManager.pattern_offset

	generate_enemy(EnemyFormationManager.current_enemy, enemy_spawns[EnemyFormationManager.spawn_point])
	EnemyFormationManager.pattern_index += 1

#This occurs every time the formation timer goes off
func spawn_enemy_formation() -> void:
	EnemyFormationManager.current_enemy = EnemyFormationManager.EnemyChoice.pick_random()
	EnemyFormationManager.current_pattern = EnemyFormationManager.data.choose_tier_one_formation()
	EnemyFormationManager.pattern_index = 0
	
	var width: int = EnemyFormationManager.current_pattern.max() #Understand that width is entirely predicated on each formation holding at least one 0 spot
	var bound: int = (SPAWNS - 1) - width 
	EnemyFormationManager.pattern_offset = randi_range(0, bound) #add a randomized integer offset to spot
	
	EnemyFormationManager.EnemySelectionTimer.start()

func generate_enemy(new_enemy: EnemyData, spawn_point: Vector2) -> void:
	var loaded_enemy: Enemy
	
	if enemy_pools[new_enemy.EnemyKey].is_empty(): #necessary because of how the indices are corresponded
		loaded_enemy = load(EnemyData.PATHS[new_enemy.EnemyKey]).instantiate() #check warning later: "ext_resource, invalid UID: uid://b7g05kcoidfqq" - using text path instead: [path]
		current_enemies.add_child(loaded_enemy)
		loaded_enemy.global_position = spawn_point
		loaded_enemy.death_finished.connect(count_enemy_death)
		
		if loaded_enemy.EnemyPoolable:
			loaded_enemy.EnemyPoolable.released.connect(hide_enemy)
	
	else:
		loaded_enemy = enemy_pools[new_enemy.EnemyKey].pop_front()
		loaded_enemy.global_position = spawn_point
		show_enemy(loaded_enemy)
	
	loaded_enemy.initialize_data()
	
	enemy_count += 1
	enemies_present = true

func show_enemy(enemy: Enemy) -> void:
	enemy.EnemyPoolable.show_poolable(true, true, true, true)

func hide_enemy(enemy: Enemy) -> void:
	enemy.EnemyPoolable.hide_poolable(true, true, true, true)
	enemy_pools[enemy.Data.EnemyKey].append(enemy)

func count_enemy_death(enemy: Enemy) -> void:
	enemy_count -= 1
	if get_enemy_count() == 0 and not formation_enemy_active: #THIS MAY HAVE TO BE REVISED LATER
		all_clear.emit()

func has_enemies() -> bool:
	return enemies_present

func get_enemy_count() -> int:
	return enemy_count

#Run through timers that are locked, unlock if enough time passed
func check_locked_timers() -> void:
	if not all_timers_active: #only run if locked timers are present
		var none_locked: bool = true
		
		for i in range(enemy_timers.size()): #Done in a specific manner, since locked_timers and enemies share indices
			if enemy_timers[i].get_meta(META_LOCKED) == true:
				none_locked = false
				if Global.game_time >= enemy_timers[i].get_meta(META_UNLOCK_TRIGGER):
					enemy_datas[i].Active = true
					enemy_timers[i].set_meta(META_LOCKED, false)
					enemy_timers[i].start()
			i += 1
		#Cease if all timers active
		if none_locked:
			EnemyFormationManager.StartDelay.start()
			all_timers_active = true

func switch_spawning_state(new_state: int) -> void:
	current_spawn_state = new_state
	match current_spawn_state:
		SPAWN_STATE.SCATTERED: #stop formation timer and begin scattered timers
			formation_active = false
			resume_scatter_timers() 
			stop_formation_timers()
		SPAWN_STATE.FORMATION:#stop scatter timers and begin formation timer
			formation_active = true
			resume_formation_timers()
			stop_scatter_timers()
			EnemyFormationManager.StopDelay.start()

func resume_formation_timers() -> void:
	EnemyFormationManager.FormationTimer.start()

func stop_formation_timers() -> void:
	EnemyFormationManager.FormationTimer.stop()

func stop_scatter_timers() -> void:
	for timer in enemy_timers:
		if timer.get_meta(META_LOCKED) == false:
			timer.stop()

func resume_scatter_timers() -> void:
	for timer in enemy_timers:
		if timer.get_meta(META_LOCKED) == false:
			timer.start()

func stop_timers() -> void:
	EnemyFormationManager.StartDelay.paused = true
	EnemyFormationManager.StopDelay.paused = true
	stop_formation_timers()
	stop_scatter_timers()

func resume_timers() -> void:
	EnemyFormationManager.StartDelay.paused = false
	EnemyFormationManager.StopDelay.paused = false
	
	match current_spawn_state:
		SPAWN_STATE.FORMATION:
			resume_formation_timers()
		SPAWN_STATE.SCATTERED:
			resume_scatter_timers()

func handle_hp_buff() -> void:
	for e_data in enemy_datas:
		if e_data.Active:
			var prior_hp: float = e_data.Health
			e_data.Health += (e_data.HealthFactor * log(prior_hp) * HP_GROWTH_FACTOR)

func handle_spawn_buff() -> void:
	var i: int = 0 #while loop to make use of corresponding indices
	while i < enemy_datas.size():
		if enemy_datas[i].Active and \
				(enemy_datas[i].SpawnRate > enemy_datas[i].MinimumSpawnRate) and \
				(enemy_datas[i].EnemyKey != ENEMY_KEYS.SUPPLY):
			enemy_datas[i].SpawnRate = max(enemy_datas[i].MinimumSpawnRate, enemy_datas[i].SpawnRate - abs(enemy_datas[i].SpawnFactor))
			enemy_timers[i].set_wait_time(enemy_datas[i].SpawnRate)
		i += 1
