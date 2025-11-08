extends Node

enum Song{ THEME }

@onready var song_map: Dictionary[Song, AudioStreamPlayer] = {
	Song.THEME: $Theme
}

# ENGINE


# PUBLIC
func play(song: Song):
	for player: AudioStreamPlayer in get_children():
		player.stop()
	song_map[song].play()

# PRIVATE


# SIGNALS
