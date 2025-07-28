extends Node2D
class_name HitRing

const LIFETIME: float = 0.3
const INITIAL_ARC_RATE: float = 0.2
const INITIAL_ARC_RADIUS: float = 1.0
const INITIAL_ARC_RATE_POWER: float = 1.2
const ARC_DX_MIN: float = 1.8
const ARC_DX_MAX: float = 2.0

@export var ArcX: int = 240
@export var ArcY: int = 240
@export var ArcColor := Color(1, 1, 1)
@export var VFXPoolable: Poolable

@onready var Lifetime = $Lifetime

var angle1: float = 0
var angle2: float = 7
var arc_radius: float = INITIAL_ARC_RADIUS
var arc_rate: float = INITIAL_ARC_RATE
var arc_rate_power: float = INITIAL_ARC_RATE_POWER
var arc_points: int = 8
var arc_width: float = 2.5
var arc_dx: float = 1.0
var arc_dx_rate: float = 0.05
var alpha_decay_rate: float = 0.1

func _ready() -> void:
	arc_dx = randf_range(ARC_DX_MIN, ARC_DX_MAX)
	
	Lifetime.wait_time = LIFETIME
	Lifetime.timeout.connect(delete)
	Lifetime.set_one_shot(true)
	Lifetime.start()

func initialize(pos: Vector2, input_color: Color) -> void:
	arc_rate = INITIAL_ARC_RATE
	arc_dx = randf_range(ARC_DX_MIN, ARC_DX_MAX)
	arc_radius = INITIAL_ARC_RADIUS
	arc_rate_power = INITIAL_ARC_RATE_POWER
	
	ArcX = pos.x
	ArcY = pos.y
	ArcColor = input_color
	
	if Lifetime:
		Lifetime.start()

"""
Marked to raise performance later (also examine Ripple.gd)
"""
func _draw() -> void:
	draw_arc(Vector2(ArcX, ArcY), arc_radius, angle1, angle2, arc_points, ArcColor, arc_width)

func modify_radius() -> void:
	arc_rate *= arc_dx
	arc_dx -= arc_dx_rate
	arc_radius = arc_rate * arc_rate_power
	arc_rate_power += 0.1

func modify_color_alpha() -> void:
	ArcColor.a = max(0, ArcColor.a - alpha_decay_rate)

func _physics_process(delta) -> void:
	modify_radius()
	modify_color_alpha()
	queue_redraw()

func delete() -> void:
	#set_physics_process(false)
	
	if VFXPoolable.Active:
		VFXPoolable.released.emit(self)
	else:
		queue_free()
