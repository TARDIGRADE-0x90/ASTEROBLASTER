extends Node

const RIPPLE: PackedScene = preload(FilePaths.RIPPLE)
const DEBRIS: PackedScene = preload(FilePaths.DEBRIS_MANAGER)
const BURST: PackedScene = preload(FilePaths.BURST)
const SPARKS: PackedScene = preload(FilePaths.SPARKS)
const HIT_RING: PackedScene = preload(FilePaths.HIT_RING)

var ripple_pool: Array[Ripple]
var debris_pool: Array[DebrisManager]
var burst_pool: Array[Burst]
var sparks_pool: Array[Sparks]
var hit_ring_pool: Array[HitRing]

"""
IF YOU GET RANDOM, SEEMINGLY INEXPLICABLE CRASHES - LOOK BACK HERE
so far so good actually

Note: There is significant room for improvement with performance, especially now that
pooling has been applied to VFX; investigate these effects, especially ones that require 
array traversals

(update - much has been tweaked, only debris needs optimization now)
"""

func _ready() -> void:
	Global.game_state_changed.connect(flush_pools) #probably make another signal? without the int? idk

func generate_ripple(target: Vector2, color: Color) -> void: #minimum
	var ripple: Ripple 
	
	if not ripple_pool.is_empty():
		ripple = ripple_pool.pop_front()
		ripple.initialize(target, color)
		show_vfx(ripple)
	else:
		ripple = RIPPLE.instantiate()
		ripple.initialize(target, color)
		Global.zone.add_child(ripple)
		ripple.VFXPoolable.released.connect(hide_vfx.bind(ripple_pool))

func generate_debris(target: Vector2, min: int, max: int) -> void: #maximum
	if Global.vfx_level == Global.VFX_LEVELS.MAXIMUM:
		var debris: DebrisManager
		
		if not debris_pool.is_empty():
			debris = debris_pool.pop_front()
			debris.global_position = target
			debris.spawn_debris(randi_range(min, max))
			show_vfx(debris)
		else:
			debris = DEBRIS.instantiate()
			Global.zone.add_child(debris)
			#debris.color = debris_color
			debris.global_position = target
			debris.spawn_debris(randi_range(min, max))
			#debris.set_owner(Global.zone)
			debris.VFXPoolable.released.connect(hide_vfx.bind(debris_pool))

func generate_burst(target: Vector2, color: Color) -> void: #medium
	if Global.vfx_level >= Global.VFX_LEVELS.MEDIUM:
		var burst: Burst
		
		if not burst_pool.is_empty():
			burst = burst_pool.pop_front()
			burst.initialize(target, color)
			show_vfx(burst)
		else:
			burst = BURST.instantiate()
			burst.initialize(target, color)
			Global.zone.add_child(burst)
			burst.VFXPoolable.released.connect(hide_vfx.bind(burst_pool))

func generate_sparks(target: Vector2, hit_color: Color, facing: int = Sparks.DOWN) -> void: #medium
	if Global.vfx_level >= Global.VFX_LEVELS.MEDIUM:
		var sparks: Sparks
		
		if not sparks_pool.is_empty():
			sparks = sparks_pool.pop_front()
			sparks.initialize(target, hit_color, facing)
			show_vfx(sparks)
		else:
			sparks = SPARKS.instantiate()
			sparks.initialize(target, hit_color, facing)
			Global.zone.add_child(sparks)
			sparks.VFXPoolable.released.connect(hide_vfx.bind(sparks_pool))

func generate_hit_ring(target: Vector2, hit_color: Color) -> void: #minimum
	var hit_ring: HitRing
	
	if not hit_ring_pool.is_empty():
		hit_ring = hit_ring_pool.pop_front()
		hit_ring.initialize(target, hit_color)
		show_vfx(hit_ring)
	else:
		hit_ring = HIT_RING.instantiate()
		hit_ring.initialize(target, hit_color)
		Global.zone.add_child(hit_ring)
		hit_ring.VFXPoolable.released.connect(hide_vfx.bind(hit_ring_pool))

func show_vfx(vfx: Variant) -> void: #UNSAFE DUE TO LACK OF ESTABLISHED CLASSES/TYPES, BEWARE
	vfx.VFXPoolable.show_poolable(false, true)

func hide_vfx(vfx: Variant, vfx_pool: Array[Variant]) -> void:
	vfx.VFXPoolable.hide_poolable(false, true)
	vfx_pool.append(vfx)

func flush_pools(FUCK_YOU: int = -1) -> void:
	ripple_pool.clear() #SHITTY CODE YOU SHOULD IMPLEMENT A CUSTOM OBJECT POOL THAT FLUSHES ON TREE EXIT
	debris_pool.clear()
	burst_pool.clear()
	sparks_pool.clear()
	hit_ring_pool.clear()
