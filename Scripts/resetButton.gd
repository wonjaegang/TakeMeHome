extends Control
class_name ResetButton

signal turn_car

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    connect('pressed', Callable(_turnEveryCar))
    
func _turnEveryCar():
    emit_signal('turn_car')
