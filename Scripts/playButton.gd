extends Control
class_name PlayButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    connect('pressed', Callable(_startEveryCar))
    
func _startEveryCar():
    SignalBus.start_driving.emit()
