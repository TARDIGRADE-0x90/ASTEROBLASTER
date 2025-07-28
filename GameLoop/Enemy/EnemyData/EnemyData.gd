extends Resource
class_name EnemyData

enum KEYS {MOLLUSK, CHARIOT, HORNET, WING, SUPPLY}

const PATHS: Dictionary = {
	KEYS.MOLLUSK: "res://GameLoop/Enemy/Enemies/Mollusk/Mollusk.tscn",
	KEYS.CHARIOT: "res://GameLoop/Enemy/Enemies/Chariot/Chariot.tscn",
	KEYS.HORNET: "res://GameLoop/Enemy/Enemies/Hornet/Hornet.tscn",
	KEYS.WING: "res://GameLoop/Enemy/Enemies/Wing/Wing.tscn",
	KEYS.SUPPLY: "res://GameLoop/Enemy/Enemies/Supply/Supply.tscn"
}

@export_enum("Mollusk", "Chariot", "Hornet", "Wing", "Supply") var EnemyKey: int
@export var ShipColor: Color
@export var FloatSpeed: Vector2
@export var Health: int = 0
@export var Armor: int = 0
@export var HealthFactor: float = 0
@export var SpawnFactor: float = 0
@export var SpawnRate: float = 1.0
@export var MinimumSpawnRate: float = 0.05
@export var TriggerTime: int = 0
@export var DebrisMin: int = 0
@export var DebrisMax: int = 0
@export var Collidable: bool
@export var Damagable: bool
@export var Active: bool

func copy_data(new_data: EnemyData) -> void:
	EnemyKey = new_data.EnemyKey
	ShipColor = new_data.ShipColor
	FloatSpeed = new_data.FloatSpeed
	Health = new_data.Health
	Armor = new_data.Armor
	HealthFactor = new_data.HealthFactor
	SpawnFactor = new_data.SpawnFactor
	SpawnRate = new_data.SpawnRate
	MinimumSpawnRate = new_data.MinimumSpawnRate
	TriggerTime = new_data.TriggerTime
	DebrisMin = new_data.DebrisMin
	DebrisMax = new_data.DebrisMax
	Collidable = new_data.Collidable
	Damagable = new_data.Damagable
	Active = new_data.Active
