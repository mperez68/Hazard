class_name Overlay extends CanvasLayer

const WIN_TEXTURE = preload("res://ui/win.tscn")
const LOSS_TEXTURE = preload("res://ui/loss.tscn")

signal update_main(new_main: int)
signal roll

# UI
@onready var main_label: Label = %MainLabel
@onready var win_loss_label: Label = %WinLossLabel
@onready var chance_label: Label = %ChanceLabel
@onready var result_label: Label = %ResultLabel
@onready var main_sel_container: HBoxContainer = %MainSelContainer
@onready var roll_button: Button = %RollButton
@onready var losses_container: VBoxContainer = %LossesContainer
@onready var wins_container: VBoxContainer = %WinsContainer
# SFX
@onready var click_sfx: AudioStreamPlayer = %Click
@onready var roll_sfx: AudioStreamPlayer = %Roll

# ENGINE
func _ready() -> void:
	update_text("")
	update_result(0)
	# Call me Israel the way I'm gonna kill all these children
	for child in losses_container.get_children() + wins_container.get_children():
		child.queue_free()


# PUBLIC
## Updates the number text for the dice total. color is optional, default is white.
func update_result(result: int, color: Color = Color.WHITE):
	result_label.text = str(result) if result > 0 else "-"
	result_label.self_modulate = color if result > 0 else Color.DIM_GRAY

## Updates the header text. main and chance texts are optional.
## If there is a chance text, we set the main text to red. Otherwise, main text is green.
func update_text(text: String, main: int = 0, chance: int = 0):
	win_loss_label.text = text
	main_label.text = str(main) if main > 0 else "-"
	chance_label.text = str(chance) if chance > 0 else "-"
	main_label.self_modulate = Color.RED if chance > 0 else Color.GREEN

## Locks the UI. set is_locked to false to unlock.
func lock(is_locked: bool = true):
	main_sel_container.visible = !is_locked
	roll_button.visible = !is_locked

## Updates the win/loss ratio icons to the given values.
func update_win_loss(nickings: int, outings: int):
	_set_to_child_count(wins_container, nickings, WIN_TEXTURE)
	_set_to_child_count(losses_container, outings, LOSS_TEXTURE)


# PRIVATE
func _set_to_child_count(container: Control, value: int, texture: PackedScene):
	var children := container.get_children()
	var child_count := children.size()
	if child_count < value:
		for i in value - child_count:
			container.add_child(texture.instantiate())
	elif child_count > value:
		for i in child_count - value:
			children[i].queue_free()

# SIGNALS
func _on_main_button_pressed(new_main: int) -> void:
	update_main.emit(new_main)
	click_sfx.play()

func _on_roll_button_pressed() -> void:
	roll.emit()
	roll_sfx.play()
	lock()

func _on_exit_button_pressed() -> void:
	click_sfx.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()	# TODO scene manager
