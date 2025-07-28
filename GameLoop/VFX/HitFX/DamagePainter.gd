extends Node
class_name DamagePainter

const ERR_INVALID_OWNER: String = "Error in DamageColor.gd - Component assigned to invalid object (entity-only)"

const RGB_MIN: float = 0

func _ready() -> void:
	assert(owner.has_meta(ObjectMeta.IS_ACTOR), ERR_INVALID_OWNER)

#do later - make a method that takes a Color input and just have it interpolate to that upon taking damage
func redden(amount: float) -> void:
	var prev_color: Color = owner.get_modulate()
	owner.set_modulate( Color(prev_color.r, max(RGB_MIN, prev_color.g - amount), max(RGB_MIN, prev_color.b - amount)) )
