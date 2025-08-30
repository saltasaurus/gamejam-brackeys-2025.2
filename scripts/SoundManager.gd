extends Node

var audio_players: Array[AudioStreamPlayer2D]

var music = preload("res://assets/music/song1.wav")

var music_player: AudioStreamPlayer

func _ready() -> void:
	for i in range(64):
		var a = AudioStreamPlayer2D.new()
		add_child(a)
		audio_players.push_back(a)
		a.finished.connect(on_sound_finished(a))

	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = music
	music_player.volume_db = -5
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.play()

	music_player.finished.connect(
		func():
			music_player.play()
	)

func play(sound: AudioStream, pos: Vector2, volume: float = 0) -> void:
	if audio_players.size() == 0:
		return

	var a: AudioStreamPlayer2D = audio_players.pop_back()
	a.stop()
	a.stream = sound
	a.position = pos
	a.volume_db = volume
	a.play()

func on_sound_finished(audio: AudioStreamPlayer2D):
	return func():
		audio_players.push_back(audio)
