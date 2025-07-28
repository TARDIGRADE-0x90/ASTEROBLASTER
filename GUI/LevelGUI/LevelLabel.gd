extends Label
class_name LevelLabel

const COLOR_DEFAULT = Color(1, 1, 1, 1)
const COLOR_FLASHING = Color(0.8, 0.3, 0.4, 0.85)

const FLASH_DURATION: float = 0.5
const MULTIPLIER: int = 20
const MOD_FACTOR: int = 5
const DECIMAL: float = 0.1

@export_enum("Time", "Health", "Scrap", "Cooldown") var LabelKey: int
@export var LabelTimer: Timer

func _ready() -> void:
	LabelTimer.set_wait_time(FLASH_DURATION)
	LabelTimer.timeout.connect(clear_flash)

func _process(delta):
	if not LabelTimer.is_stopped():
		flash()

func trigger() -> void:
	LabelTimer.start()

func flash() -> void:
	modulate.r = COLOR_FLASHING.r - ((int(LabelTimer.time_left * MULTIPLIER) % MOD_FACTOR) * DECIMAL)
	modulate.g = COLOR_FLASHING.g - ((int(LabelTimer.time_left * MULTIPLIER) % MOD_FACTOR) * DECIMAL)
	modulate.b = COLOR_FLASHING.b - ((int(LabelTimer.time_left * MULTIPLIER) % MOD_FACTOR) * DECIMAL)

func clear_flash() -> void:
	modulate = COLOR_DEFAULT
