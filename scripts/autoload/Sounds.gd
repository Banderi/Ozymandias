extends Node
# ANTIMONY 'Sounds' by Banderi --- v0.9

#onready var SOUND3D_SCN = load("res://scenes/FX/Sound3D.tscn")
#onready var SOUND_SCN = load("res://scenes/FX/Sound.tscn")

# Audio buses are:
# - "Master"
# - "SFX"
# - "Music"
# - "Voice"

func get_volume(bus):
	var bus_index = AudioServer.get_bus_index(bus)
	var db = AudioServer.get_bus_volume_db(bus_index)
	var linear = db2linear(db)
	return linear
func set_volume(bus, value):
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))

#func play_sound(sound: String, position, volume : float, bus : String, pitch_rnd = 0.0):
#	var node = null
#	if position == null:
#		node = SOUND_SCN.instance()
#		node.volume_db = linear2db(volume)
##	else:
##		node = SOUND3D_SCN.instance()
##		node.translation = position
##		node.unit_db = linear2db(volume)
#	if pitch_rnd != 0.0:
#		node.pitch_scale = rand_range(1.0 - pitch_rnd, 1.0 + pitch_rnd)
#	node.bus = bus
#	node.stream = load(str("res://audio/sfx/",sound))
#	Game.ROOT_NODE.add_child(node)
#	node.set_pause_mode(2) # Set pause mode to Process
#	node.set_process(true)
#	return node

var MUSIC_PLAYER1 = null
var MUSIC_PLAYER2 = null
var AMBIENT = null
func play_music(music: String, volume : float = 1.0):
	MUSIC_PLAYER1.volume_db = linear2db(volume * 0.4)
	var newstream = load(str("res://audio/music/",music))
	if MUSIC_PLAYER1.stream != newstream:
		MUSIC_PLAYER1.stream = newstream
		MUSIC_PLAYER1.playing = true
func play_music2(music: String, volume : float = 1.0):
	MUSIC_PLAYER2.volume_db = linear2db(volume * 0.4)
	var newstream = load(str("res://audio/music/",music))
	if MUSIC_PLAYER2.stream != newstream:
		MUSIC_PLAYER2.stream = newstream
		MUSIC_PLAYER2.playing = true

func change_filter(bus : String, filter : int, param : String, value):
	var bus_index = AudioServer.get_bus_index(bus)
	var effect = AudioServer.get_bus_effect(bus_index, filter)
	if effect == null:
		return
	if param in effect:
		effect.set(param, value)
func activate_filter(bus : String, filter : int, enabled : bool):
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_effect_enabled(bus_index, filter, enabled)

func play_ambient(ambient: String, volume : float = 1.0):
	if ambient == "":
		AMBIENT.playing = false
		return
	AMBIENT.volume_db = linear2db(volume * 0.5)
	var newstream = load(str("res://audio/sfx/",ambient))
	if AMBIENT.stream != newstream:
		AMBIENT.stream = newstream
		AMBIENT.playing = true

func _ready():
	self.set_pause_mode(2) # Set pause mode to Process
	set_process(true)

###

const MAX_CITY_SOUNDS = 70

var city_sounds = []
