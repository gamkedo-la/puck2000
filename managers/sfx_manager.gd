extends Node

export var audiobus_sfx_name = "SFX"

# holds the linear values
var sfx_vol:float
# holds the db values
var sfx_bus_vol:float

onready var audiobus_sfx := AudioServer.get_bus_index(audiobus_sfx_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	isMute = false
	# setup initial volumes
	sfx_vol = 0.55
	
	AudioServer.set_bus_volume_db(audiobus_sfx, linear2db(sfx_vol))
	
	sfx_bus_vol = AudioServer.get_bus_volume_db(audiobus_sfx)


func play_sfx(
	sound: AudioStream, parent: Node,
	pitch_range: Vector2 = Vector2(1.0,1.0), 
	volume_db: float = sfx_vol,
	pause_behaviour = PAUSE_MODE_INHERIT, audiobus: String = "SFX"
) -> void:
	
	if sound != null and parent != null:
		var stream = AudioStreamPlayer.new()
		
		stream.stream = sound
		stream.connect("finished", stream, "queue_free")
		
		stream.bus = audiobus
		
		stream.pitch_scale = rand_range(pitch_range.x, pitch_range.y)
		stream.volume_db = AudioServer.get_bus_volume_db(audiobus_sfx)
		stream.pause_mode = pause_behaviour
		
		parent.call_deferred("add_child", stream)
		stream.play()
