extends Area2D
class_name Projectile

signal terminated(proj: Projectile)

const BOUND_MARGIN = 32

@export var Data: ProjectileData
@export var Sprite: Sprite2D
@export var Collider: CollisionShape2D
@export var ProjectilePoolable: Poolable

var penetration_left : int = 0

func _ready() -> void:
	#set_process(false)
	modulate = Data.ShotColor
	area_entered.connect(handle_collision)
	
	if Data: #player penetration is saved as a float
		update_data()

func _physics_process(_delta: float) -> void:
	translate(Vector2(Data.X_Speed, Data.Y_Speed))
	
	if (global_position.y < Global.zone_top - BOUND_MARGIN or global_position.y > Global.zone_bottom + BOUND_MARGIN):
		terminate()

func assign_data(new_data: ProjectileData) -> void:
	Data = new_data
	update_data()

func update_data() -> void:
	Sprite.texture = Data.Icon
	Collider.shape = Data.CollisionData
	penetration_left = Data.Penetration

func handle_collision(area: Area2D) -> void:
	if area.has_meta(ObjectMeta.IS_ACTOR):
		#Player projectile hitting enemy
		if Data.Friendly and area != Global.player: 
			area.receive_damage.emit(Data.Damage)
			VFX.generate_hit_ring(global_position, Data.ShotColor)
			VFX.generate_sparks(global_position, Data.ShotColor)
			if area.Data.Armor <= 0: pass
			else:
				penetration_left -= area.Data.Armor
				if penetration_left <= 0:
					terminate()
		
		#Enemy projectile hitting player
		if not Data.Friendly and area == Global.player: 
			area.receive_damage.emit() #Damage amount irrelevant
			VFX.generate_hit_ring(global_position, Data.ShotColor)
			VFX.generate_sparks(global_position, Data.ShotColor, Sparks.UP)
			terminate()

func terminate() -> void:
	terminated.emit(self)
	
	if ProjectilePoolable.Active: 
		ProjectilePoolable.released.emit(self)
	else:
		call_deferred("queue_free")
