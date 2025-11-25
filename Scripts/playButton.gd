extends ClickAnimationButton
class_name PlayButton

var isPlaying: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pressed.connect(_onPressed)
	SignalBus.reset_simulation.connect(_on_reset_signal)
	_update_ui()

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