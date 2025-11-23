extends Node2D
class_name Home

## 책임:

const DOOR_MOVE_DISTANCE: float = 16.0
const DOOR_ANIMATION_DURATION: float = 0.5

var _homeIndex : int = -1
var _isDoorOpen : bool = true

@onready var _wallSprite: Sprite2D = $Sprite/Wall
@onready var _openDoorLeft: TileMapLayer = $Sprite/OpenDoorLeft
@onready var _openDoorRight: TileMapLayer = $Sprite/OpenDoorRight
@onready var _closedDoorLeft: TileMapLayer = $Sprite/ClosedDoorLeft
@onready var _closedDoorRight: TileMapLayer = $Sprite/ClosedDoorRight
@onready var _carEnterArea: Area2D = $CarEnterArea

func _ready() -> void:
    _carEnterArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
    
    var car: Car = body
    SignalBus.car_arrived_home.emit(body)
    if car.getCarIndex() == _homeIndex:
        setDoorStateOpen(false)

func setDoorStateOpen(isOpen: bool) -> void:
    if _isDoorOpen == isOpen:
        return
    _isDoorOpen = isOpen
    _playDoorAnimation(isOpen)

func _playDoorAnimation(isOpen: bool) -> void:
    var tween = create_tween()
    tween.set_parallel(true)
    
    _openDoorLeft.visible = true
    _openDoorRight.visible = true
    _closedDoorLeft.visible = true
    _closedDoorRight.visible = true

    if isOpen:        
        # Opening: Spread left/right (Center -> Sides)
        tween.tween_property(_closedDoorLeft, "position:x", -DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tween.tween_property(_closedDoorRight, "position:x", DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        
        tween.chain().tween_callback(func(): 
            _closedDoorLeft.visible = false
            _closedDoorRight.visible = false
        )
    else:
        # Closing: Gather from left/right (Sides -> Center)
        _closedDoorLeft.position.x = -DOOR_MOVE_DISTANCE
        _closedDoorRight.position.x = DOOR_MOVE_DISTANCE
        
        tween.tween_property(_closedDoorLeft, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
        tween.tween_property(_closedDoorRight, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func setHomeIndex(index: int) -> void:
    _homeIndex = index

func setWallTexture(texture: Texture2D) -> void:
    if _wallSprite:
        _wallSprite.texture = texture
    else:
        push_error('before setting texture, node should be added to scene tree')
