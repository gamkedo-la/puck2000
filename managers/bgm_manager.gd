extends Node

export var audiobus_bgm_name = "BGM"

onready var audiobus_bgm := AudioServer.get_bus_index(audiobus_bgm_name)

# holds the linear values
var bgm_vol:float
# holds the db values
var bgm_bus_vol:float

var current_bgm = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	isMute = false
	# setup initial volumes
	bgm_vol = 0.85
	
	AudioServer.set_bus_volume_db(audiobus_bgm, linear2db(bgm_vol))
	
	bgm_bus_vol = AudioServer.get_bus_volume_db(audiobus_bgm)


func play_bgm(
	sound: AudioStream, parent: Node = self,
	pitch_range: Vector2 = Vector2(1.0,1.0), 
	volume_db: float = bgm_vol,
	pause_behaviour = PAUSE_MODE_INHERIT, audiobus: String = "BGM"
) -> void:
	
	if sound != null and parent != null:
		var stream = AudioStreamPlayer.new()
		
		stream.stream = sound
		stream.connect("finished", stream, "queue_free")
		
		stream.bus = audiobus
		
		stream.pitch_scale = rand_range(pitch_range.x, pitch_range.y)
		stream.volume_db = AudioServer.get_bus_volume_db(audiobus_bgm)
		stream.pause_mode = pause_behaviour
		
		parent.call_deferred("add_child", stream)
		stream.play()
		current_bgm = stream


func stop_bgm() -> void:
	current_bgm.stop()


func end_bgm() -> void:
	current_bgm.queue_free()
