extends Node2D
class_name Home

## 책임:

const DOOR_MOVE_DISTANCE: float = 16.0
const DOOR_ANIMATION_DURATION: float = 0.5

var _homeIndex : int = -1
var _isDoorOpen : bool = true
var _doorTween: Tween
var _chimneySmokeTween: Tween
var _smokeInitialPos: Vector2
var _smokeInitialScale: Vector2
var _smokeInitialModulate: Color

@onready var _wallSprite: Sprite2D = $Sprite/Wall
@onready var _openDoorLeft: TileMapLayer = $Sprite/OpenDoorLeft
@onready var _openDoorRight: TileMapLayer = $Sprite/OpenDoorRight
@onready var _closedDoorLeft: TileMapLayer = $Sprite/ClosedDoorLeft
@onready var _closedDoorRight: TileMapLayer = $Sprite/ClosedDoorRight
@onready var _smoke: Sprite2D = $Sprite/Smoke
@onready var _carEnterArea: Area2D = $CarEnterArea

func _ready() -> void:
    _carEnterArea.body_entered.connect(_on_body_entered)
    SignalBus.reset_simulation.connect(_on_reset_simulation)    
    _initializeSmoke()

func _initializeSmoke() -> void:
    _smokeInitialPos = _smoke.position
    _smokeInitialScale = _smoke.scale
    _smokeInitialModulate = _smoke.modulate
    _smoke.visible = false

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
    var isSmoke: bool = not isOpen
    _playChimneySmokeAnimation(isSmoke)

func _playDoorAnimation(isOpen: bool) -> void:
    if _doorTween:
        _doorTween.kill()
    _doorTween = create_tween()
    _doorTween.set_parallel(true)
    
    _openDoorLeft.visible = true
    _openDoorRight.visible = true
    _closedDoorLeft.visible = true
    _closedDoorRight.visible = true

    if isOpen:        
        # Opening: Spread left/right (Center -> Sides)
        _doorTween.tween_property(_closedDoorLeft, "position:x", -DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        _doorTween.tween_property(_closedDoorRight, "position:x", DOOR_MOVE_DISTANCE, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        
        _doorTween.chain().tween_callback(func(): 
            _closedDoorLeft.visible = false
            _closedDoorRight.visible = false
        )
    else:
        # Closing: Gather from left/right (Sides -> Center)
        _closedDoorLeft.position.x = -DOOR_MOVE_DISTANCE
        _closedDoorRight.position.x = DOOR_MOVE_DISTANCE
        
        _doorTween.tween_property(_closedDoorLeft, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
        _doorTween.tween_property(_closedDoorRight, "position:x", 0.0, DOOR_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _playChimneySmokeAnimation(isSmoke: bool) -> void:
    if _chimneySmokeTween:
        _chimneySmokeTween.kill()
            
    if isSmoke:
        _smoke.visible = true
        _chimneySmokeTween = create_tween().set_loops()
        _chimneySmokeTween.set_parallel(true)

        var targetPos: Vector2 = _smokeInitialPos + Vector2(20.0, -40.0)
        const SMOKE_ANIMATION_DURATION: float = 0.7
        _chimneySmokeTween.tween_property(_smoke, "position", targetPos, SMOKE_ANIMATION_DURATION).from(_smokeInitialPos)
        
        var targetScale: Vector2 = Vector2(0.3, 0.3)
        _chimneySmokeTween.tween_property(_smoke, "scale", targetScale, SMOKE_ANIMATION_DURATION).from(_smokeInitialScale)
        
        _chimneySmokeTween.tween_property(_smoke, "modulate:a", 0.0, SMOKE_ANIMATION_DURATION).from(_smokeInitialModulate.a).set_ease(Tween.EASE_OUT)
        
        _chimneySmokeTween.set_parallel(false)
        _chimneySmokeTween.tween_interval(0.2)
    else:
        _smoke.visible = false

func setHomeIndex(index: int) -> void:
    _homeIndex = index

func setWallTexture(texture: Texture2D) -> void:
    if _wallSprite:
        _wallSprite.texture = texture
    else:
        push_error('before setting texture, node should be added to scene tree')
