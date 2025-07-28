extends Control
class_name LevelGUI

enum LABELS {TIME, HEALTH, SCRAP, COOLDOWN}

@onready var level_gui_labels = $LevelGUILabels

var labels: Array[LevelLabel]
var flashing_labels: Array[LevelLabel]

func _ready() -> void:
	labels.assign(level_gui_labels.get_children())

func update_label(label_key: int, new_text: String) -> void:
	labels[label_key].set_text(new_text)

func trigger_flash(label_key: int) -> void:
	labels[label_key].trigger()

