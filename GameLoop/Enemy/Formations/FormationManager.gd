extends Node
class_name FormationManager

const DURATION: int = 30

@export var FormationTimer: Timer
@export var EnemySelectionTimer: Timer
@export var StartDelay: Timer
@export var StopDelay: Timer
@export var EnemyChoice: Array[EnemyData]

var data: FormationData
var current_pattern: Array[int]
var current_enemy: EnemyData
var pattern_index: int = 0
var pattern_offset: int = -1
var spawn_point: int = -1

func _ready() -> void:
	data = FormationData.new()
	StopDelay.wait_time = DURATION

