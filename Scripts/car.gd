extends CharacterBody2D
class_name Car

## 책임:
##  - 차량의 이동 관리

const SPEED: float = 200.0
const CAR_DISAPPEAR_DURATION: float = 0.3

var _carIndex : int = -1
var _isDriving : bool = false
var _isTurning : bool = false
var _has_enterd_road : bool = false
var _angularSpeed : float = 0
var _targetAngle : float = 0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    SignalBus.start_driving.connect(_startCar)
    SignalBus.make_enteredCar_turn.connect(_makeCarTurn)
    SignalBus.car_arrived_home.connect(_on_car_arrived_home)

func setCarIndex(index: int) -> void:
    _carIndex = index

func setCarTexture(texture: Texture2D) -> void:
    if _sprite:
        _sprite.texture = texture
    else:
        push_error('before setting texture, node should be added to scene tree')

func _physics_process(delta: float) -> void:
    if not _isDriving:
        return
    
    if _isTurning:
        _rotate(delta)
        
    _moveForward(delta)

func _startCar() -> void:
    _isDriving = true

func _on_car_arrived_home(car: Car, homeIndex: int) -> void:
    if car != self:
        return
    
    if homeIndex != _carIndex:
        print("Car %d arrived at wrong home %d" % [_carIndex, homeIndex])

    _isDriving = false
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, CAR_DISAPPEAR_DURATION)
    tween.tween_callback(queue_free)

func _makeCarTurn(car: Car, angle: float, radius: float) -> void:
    if car != self:
        return
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

func getHasEnteredRoad() -> bool:
    return _has_enterd_road
    
func setHasEnteredRoad(flag: bool) -> void:
    _has_enterd_road = flag


