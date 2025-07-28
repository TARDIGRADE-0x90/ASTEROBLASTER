extends Resource
class_name ProjectileData

@export var Icon: Texture
@export var ShotColor: Color
@export var CollisionData: RectangleShape2D
@export var Friendly: bool
@export var Damage: int
@export var Penetration: int
@export var X_Speed: int
@export var Y_Speed: int

func copy_data(new_projectile: ProjectileData) -> void:
	Icon = new_projectile.Icon
	ShotColor = new_projectile.ShotColor
	CollisionData = new_projectile.CollisionData
	Friendly = new_projectile.Friendly
	Damage = new_projectile.Damage
	Penetration = new_projectile.Penetration
	X_Speed = new_projectile.X_Speed
	Y_Speed = new_projectile.Y_Speed
