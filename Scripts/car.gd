extends CharacterBody2D
class_name Car

## 책임:
##  - 차량의 이동 관리

const SPEED: float = 100.0
var _isDriving : bool = false
var _isTurning : bool = false
var _angularSpeed : float = 0
var _targetAngle : float = 0

func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    if not _isDriving:
        return
    
    if _isTurning:
        _rotate(delta)
        
    _moveForward(delta)

func startCar() -> void:
    _isDriving = true

func _setCurve(angle: float, radius: float) -> void:
    _isTurning = true
    _targetAngle = rotation + angle
    _angularSpeed = SPEED / radius * sign(angle)

func _rotate(delta: float) -> void:
    rotation += _angularSpeed * delta
    if (_targetAngle - rotation) * sign(_angularSpeed) <= 0:
        rotation = _targetAngle
        _isTurning = false

func _moveForward(delta: float) -> void:
    position += Vector2.RIGHT.rotated(rotation) * SPEED * delta
        
    
