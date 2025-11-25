extends Button
class_name PlayButton

const PRESSED_SCALE: Vector2 = Vector2(0.9, 0.9)
const ANIMATION_DURATION: float = 0.1

var isPlaying: bool = false
var _tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pivot_offset = size / 2	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	pressed.connect(_onPressed)
	SignalBus.reset_simulation.connect(_on_reset_signal)
	_update_ui()

func _on_button_down() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", PRESSED_SCALE, ANIMATION_DURATION)

func _on_button_up() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(1.0, 1.0), ANIMATION_DURATION)

func _on_reset_signal() -> void:
	isPlaying = false
	_update_ui()

func _onPressed() -> void:
	isPlaying = !isPlaying
	_update_ui()
	
	if isPlaying:
		SignalBus.start_simulation.emit()
	else:
		SignalBus.reset_simulation.emit()

func _update_ui() -> void:
	if isPlaying:
		$PlayIcon.visible = false
		$StopIcon.visible = true
	else:
		$PlayIcon.visible = true
		$StopIcon.visible = false