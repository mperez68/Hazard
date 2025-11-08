class_name Board extends Node2D

const LOW_OUTING: int = 3
const HIGH_OUTING: int = 11
const DEFAULT_MAIN: int = 7
const NICKING_EXCEPTIONS: Dictionary[int, int] = {
	5: 0, 6: 12, 7: 11, 8: 12, 9: 0
}

@onready var overlay: Overlay = $Overlay
@onready var dice: Array[Dice] = [
	%Dice, %Dice2
]
@onready var turn_delay_timer: Timer = $TurnDelayTimer
# SFX
@onready var nicking_sfx: AudioStreamPlayer = $NickingSfx
@onready var outing_sfx: AudioStreamPlayer = $OutingSfx
@onready var chance_sfx: AudioStreamPlayer = $ChanceSfx
@onready var lose_sfx: AudioStreamPlayer = $LoseSfx

var main: int = DEFAULT_MAIN
var chance: int = 0
var result: int = 0:
	set(value):
		result = value
		var color: Color = Color.WHITE
		if !_is_rolling():
			match _get_outcome():
				-1:
					color = Color.RED
				1: 
					color = Color.GREEN
		overlay.update_result(result, color)

var nickings: int = 0:
	set(value):
		nickings = value
		overlay.update_win_loss(nickings, outings)
var outings: int = 0:
	set(value):
		outings = value
		overlay.update_win_loss(nickings, outings)


# ENGINE
func _ready() -> void:
	MusicManager.play(MusicManager.Song.THEME)

# PUBLIC


# PRIVATE
func _calc_results():
	var outcome: int = _get_outcome()
	# Display results, reroll if chance.
	match outcome:
		-1:		# Outing
			overlay.lock(false)
			outings += 1
			overlay.update_text("Outing!" if outings < 3 else "Outing!\n Pass Caster!", main, chance)
			outing_sfx.play()
			chance = 0
			if outings >= 3:
				lose_sfx.play()
				nickings = 0
				outings = 0
		0:		# Keep rolling
			overlay.update_text("Chance!", main, chance)
			if chance == 0:
				chance = result
			chance_sfx.play()
			turn_delay_timer.start()
		1:		# Nicking
			overlay.lock(false)
			nickings += 1
			overlay.update_text("Nicking!", main, chance)
			nicking_sfx.play()
			chance = 0

func _is_rolling() -> bool:
	for die in dice:
		if die.rolling:
			return true
	return false

## Returns -1 for outing, 0 for roll again (chance), or 1 for nicking based on current result value.
func _get_outcome() -> int:
	# Outing if out of bound
	if result <= LOW_OUTING or result >= HIGH_OUTING:
		return -1
	# If not the first roll, the chance is set and that inverts expectations.
	elif chance > 0:
		if result == chance or result == NICKING_EXCEPTIONS[main]:
			return 1
		elif result == main:
			return -1
	# Otherwise, it's the first roll and we want to hit the main.
	else:
		if result == main or result == NICKING_EXCEPTIONS[main]:
			return 1
	return 0


# SIGNALS
func _on_dice_rolled(value: int) -> void:
	result += value
	# Break if a dice is still rolling.
	if _is_rolling():
		return
	# If no dice are rolling, calculate round results.
	_calc_results()

func _on_overlay_roll(reset_chance: bool = true) -> void:
	# Break if a dice is still rolling.
	if _is_rolling():
		return
	# Reset and start rolling.
	overlay.update_text("Rolling...", main, chance)
	result = 0
	if reset_chance:
		chance = 0
	var length := randf_range(1, 2)
	for i in dice.size():
		dice[i].roll(length + float(i))

func _on_overlay_update_main(new_main: int) -> void:
	main = new_main

func _on_turn_delay_timer_timeout() -> void:
	_on_overlay_roll(false)
