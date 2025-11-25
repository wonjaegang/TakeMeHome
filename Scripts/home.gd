extends Node2D
class_name Home

## 책임:

const DOOR_MOVE_DISTANCE: float = 16.0
const DOOR_ANIMATION_DURATION: float = 0.5

var _homeIndex : int = -1
var _isDoorOpen : bool = true
var _tween: Tween

@onready var _wallSprite: Sprite2D = $Sprite/Wall
@onready var _openDoorLeft: TileMapLayer = $Sprite/OpenDoorLeft
@onready var _openDoorRight: TileMapLayer = $Sprite/OpenDoorRight
@onready var _closedDoorLeft: TileMapLayer = $Sprite/ClosedDoorLeft
@onready var _closedDoorRight: TileMapLayer = $Sprite/ClosedDoorRight
@onready var _carEnterArea: Area2D = $CarEnterArea

func _ready() -> void:
    _carEnterArea.body_entered.connect(_on_body_entered)
    SignalBus.reset_simulation.connect(_on_reset_simulation)

func _on_reset_simulation() -> void:
    setDoorStateOpen(true)

func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
    
    var car: Car = body
    var isSucceeded: bool = false
    if car.getCarIndex() == _homeIndex:
        setDoorStateOpen(false)
        isSucceeded = true
    SignalBus.car_arrived_home.emit(body, isSucceeded)

func setDoorStateOpen(isOpen: bool) -> void:
    if _isDoorOpen == isOpen:
        return
    _isDoorOpen = isOpen
    _playDoorAnimation(isOpen)

func _playDoorAnimation(isOpen: bool) -> void:
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.set_parallel(true)
    
    _openDoorLeft.visible = true
    _openDoorRight.visible = true
    _closedDoorLeft.visible = true
    _closedDoorRight.visible = true

    if isOpen:        
        # Opening: Spread left/right (Center -> Sides)
        _tween.tween_property(_closedDoorLeft, "position:x", -DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        _tween.tween_property(_closedDoorRight, "position:x", DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        
        _tween.chain().tween_callback(func(): 
            _closedDoorLeft.visible = false
            _closedDoorRight.visible = false
        )
    else:
        # Closing: Gather from left/right (Sides -> Center)
        _closedDoorLeft.position.x = -DOOR_MOVE_DISTANCE
        _closedDoorRight.position.x = DOOR_MOVE_DISTANCE
        
        _tween.tween_property(_closedDoorLeft, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
        _tween.tween_property(_closedDoorRight, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func setHomeIndex(index: int) -> void:
    _homeIndex = index

func setWallTexture(texture: Texture2D) -> void:
    if _wallSprite:
        _wallSprite.texture = texture
    else:
        push_error('before setting texture, node should be added to scene tree')
