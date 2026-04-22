extends Node

var music_player = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)

func play(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

func stop():
	music_player.stop()
