extends Node
class_name ProjectileManager

const ERR_OWNER_UNSET: String = "Error in ProjectileManager.gd : fire() - Scene owner not set"

@export var ShotTimer: Timer

var bullet_pool: Array[Projectile]

#Generalized projectile generation (pooling solution is specific to this script (and is finnicky at lower framerates); generalize it later)
func generate_projectile(origin: Vector2, shot: PackedScene, shot_data: ProjectileData, shot_placement := Vector2(0,0)) -> void:
	assert(Global.zone, ERR_OWNER_UNSET)
	var proj: Projectile
	
	if not bullet_pool.is_empty():
		proj = bullet_pool.pop_front()
		proj.assign_data(shot_data)
		proj.global_position = origin + shot_placement
		show_projectile(proj)
	else:
		proj = shot.instantiate()
		proj.assign_data(shot_data)
		Global.add_child_to_owner(proj)
		proj.global_position = origin + shot_placement
		proj.ProjectilePoolable.released.connect(hide_projectile)

func show_projectile(proj: Projectile) -> void:
	proj.ProjectilePoolable.show_poolable(true, true, true)

func hide_projectile(proj: Projectile) -> void:
	bullet_pool.append(proj)
	proj.ProjectilePoolable.hide_poolable(true, true, true)

func flush_pool() -> void:
	for bullet in bullet_pool:
		bullet.call_deferred("queue_free")
	
	bullet_pool.clear()

func update_pool(new_data: ProjectileData) -> void:
	for bullet in bullet_pool:
		bullet.assign_data(new_data)
