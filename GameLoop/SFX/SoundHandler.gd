extends Node
class_name SoundHandler

var active_filepath: String #Variable definitions for readability's sake
var active_volume: int
var active_pitch: float

var sound_pool: Array

func _ready() -> void:
	if SFX.SFXPoolable:
		SFX.SFXPoolable.released.connect(hide_sound)

func parse_sound(sound_key: int) -> void:
	active_filepath = SFXLibrary.LIBRARY[sound_key][SFXLibrary.FILEPATH] 
	active_volume = SFXLibrary.LIBRARY[sound_key][SFXLibrary.VOLUME]
	active_pitch = SFXLibrary.LIBRARY[sound_key][SFXLibrary.PITCH]
	
	if not sound_pool.is_empty():
		var new_sound = sound_pool.pop_front()
		show_sound(new_sound)
		SFX.load_sound(new_sound)
		return
	
	if SFXLibrary.LIBRARY[sound_key][SFXLibrary.PITCH] != SFXLibrary.NO_PITCH:
		SFX.play_pitch_shift(active_filepath, active_volume, active_pitch)
	else:
		SFX.play_sound(active_filepath, active_volume)

func show_sound(obj: Variant) -> void:
	obj.set_process(true)

func hide_sound(obj: Variant) -> void:
	obj.set_process(false)
	sound_pool.append(obj)
