@tool
class_name Dice extends Node2D

signal rolled(value: int)

## The index value corresponds to the dice face. 0 is a "?".
const DIE_VALUE_SPRITES: Array[CompressedTexture2D] = [
	preload("uid://bitbwdojxb6qq"),
	preload("uid://berd6e2xrf6a0"),
	preload("uid://drhxpvpbkcvms"),
	preload("uid://cv2xjflx1u7e4"),
	preload("uid://dxalwlt34qh5n"),
	preload("uid://bfckahylaguk0"),
	preload("uid://bjkfkln3gua21")
	
]

@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var roll_timer: Timer = $RollTimer
@onready var sub_roll_timer: Timer = $SubRollTimer
@onready var shuffle_start_timer: Timer = $ShuffleStartTimer
@onready var rolling_sfx: AudioStreamPlayer = %Rolling

var rolling: bool:
	get():
		return !roll_timer.is_stopped()

@export_range(0, 6, 1) var die_value: int = 0:
	set(value):
		die_value = value
		sprite.texture = DIE_VALUE_SPRITES[die_value]


# ENGINE
func _ready():
	# Break if in editor.
	if Engine.is_editor_hint():
		return
	
	animation_player.play("idle")


# PUBLIC
## Rolls the dice. If no time is given, defaults to 1 second. A `rolled` signal is sent when the final roll value is landed on.
func roll(time: float = 1.0):
	if !roll_timer.is_stopped():
		return
	roll_timer.start(time)
	shuffle_start_timer.start(randf_range(0, shuffle_start_timer.wait_time))
	animation_player.play("rolling")
	animation_player.advance(randf_range(0, animation_player.current_animation_length))


# PRIVATE


# SIGNALS
func _on_roll_timer_timeout() -> void:
	sub_roll_timer.stop()
	animation_player.play("idle")
	rolled.emit(die_value)

func _on_sub_roll_timer_timeout() -> void:
	die_value = randi_range(1, 6)
	rolling_sfx.play()

func _on_shuffle_start_timer_timeout() -> void:
	_on_sub_roll_timer_timeout()
	sub_roll_timer.start()
