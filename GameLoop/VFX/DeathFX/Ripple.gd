extends HitRing
class_name Ripple

@onready var Echo = $Echo

const ERR_LIFETIME_ABSENT: String = "Lifetime timer not present (DeathRing.gd)"

const RIPPLE_BOOST: float = 3
const RIPPLE_DX_MIN: float = 1.6
const RIPPLE_DX_MAX: float = 1.8
const LIFETIME_DEATH_RING: float = 0.5
const ECHO: float = 0.1

var initial_dx: float = 0.0
var ripple_decay_rate: float = 0.03

#Ready method is only method getting overrided, and that's only for the assertion - everything else should be good
func _ready() -> void:
	assert(Lifetime != null, ERR_LIFETIME_ABSENT)
	
	Lifetime.wait_time = LIFETIME_DEATH_RING
	Lifetime.timeout.connect(delete)
	Lifetime.set_one_shot(true)
	Lifetime.start()
	
	arc_dx = randf_range(RIPPLE_DX_MIN, RIPPLE_DX_MAX)
	initial_dx = arc_dx
	
	Echo.wait_time = ECHO
	Echo.timeout.connect(repeat)
	Echo.start()

func modify_color_alpha() -> void:
	ArcColor.a = lerpf(ArcColor.a, 0, ripple_decay_rate)

func repeat() -> void:
	arc_dx = initial_dx
	arc_rate = INITIAL_ARC_RATE * RIPPLE_BOOST
	arc_radius = INITIAL_ARC_RADIUS
