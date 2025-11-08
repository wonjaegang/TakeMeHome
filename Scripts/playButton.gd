extends Control
class_name PlayButton

signal start_driving

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    connect('pressed', Callable(_startEveryCar))
    
func _startEveryCar():
    emit_signal('start_driving')
