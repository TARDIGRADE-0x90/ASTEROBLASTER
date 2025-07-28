extends Resource
class_name Attribute

enum TYPES {DAMAGE, PENETRATION, FIRERATE, PROJECTILES}

@export_enum("Damage", "Penetration", "Firerate", "Projectiles") var Type: int #Attribute type
@export var Level: int #Level
@export_range(1, 99) var Rank: int
@export var LevelPerRank: int #Amount of levels before rank raises
@export var MaxRank: int #Maximum rank of the attribute
@export var Value: float #The current value of the attribute
@export var UpdateRate: float #How much it updates per each scrap allocation

#method specifically for copying values without pointing directly to the player's own attributes
func copy_stat(new_stat: Attribute) -> void:
	Level = new_stat.Level
	Rank = new_stat.Rank
	LevelPerRank = new_stat.LevelPerRank
	MaxRank = new_stat.MaxRank
	Value = new_stat.Value
	UpdateRate = new_stat.UpdateRate
