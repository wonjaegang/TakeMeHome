extends ClickAnimationButton
class_name ResetButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()
    pressed.connect(_onPressed)
    SignalBus.start_simulation.connect(func() -> void: disabled = true)
    SignalBus.reset_simulation.connect(func() -> void: disabled = false)
    
func _onPressed():
    SignalBus.clear_User_Crossway.emit()