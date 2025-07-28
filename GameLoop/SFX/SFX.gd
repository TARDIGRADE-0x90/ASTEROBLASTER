extends Node
"""
Apply pooling to this as well
"""

@export var SFX_BOOST: float = 90;
@export var SFX_DECREMENT: float = 125;
@export var SFXPoolable: Poolable 

var sfx_player: AudioStreamPlayer
var stream: AudioStream

func _ready() -> void:
	randomize()
	#SFXPoolable = Poolable.new()
	#SFXPoolable.Active = false
	sfx_player = AudioStreamPlayer.new()
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

"""
var music_player: AudioStreamPlayer
var current_track: AudioStream
var current_track_name: String
var stopping: bool = false

---- method ---- 
var track = load(path)
if current_track != track:
	end_current_track()
	current_track = track
	current_track_name = path
	music_player.set_stream(track)
	music_player.set_volume_db((MUSIC_BOOST) - MUSIC_DECREMENT)
	music_player.play()
"""

func play_sound(sound_path: String, volume: float = 0) -> void:
	if Global.sfx_active:
		sfx_player = AudioStreamPlayer.new()
		stream = ResourceLoader.load(sound_path)
		add_child(sfx_player)
		sfx_player.set_stream(stream)
		sfx_player.set_volume_db((volume + SFX_BOOST) - SFX_DECREMENT)
		sfx_player.finished.connect(clear_object.bind(sfx_player))
		sfx_player.play()

func play_pitch_shift(sound_path: String, volume: float = 0, pitch_range: float = 1) -> void:
	if Global.sfx_active:
		sfx_player = AudioStreamPlayer.new()
		stream = ResourceLoader.load(sound_path)
		add_child(sfx_player)
		sfx_player.set_stream(stream)
		sfx_player.set_pitch_scale((randf() * pitch_range * 0.1) + pitch_range)
		sfx_player.set_volume_db((volume + SFX_BOOST) - SFX_DECREMENT)
		sfx_player.finished.connect(clear_object.bind(sfx_player))
		sfx_player.play()

func load_sound(sound: AudioStreamPlayer) -> void:
	sound.play() #initialization has been handled

func clear_object(obj : Variant) -> void:
	if SFXPoolable and SFXPoolable.Active:
		SFXPoolable.released.emit(obj)
	else:
		obj.call_deferred("queue_free")
