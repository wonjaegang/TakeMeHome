extends Node2D
class_name Crossway

## 책임:
##  - 차량이 들어오면 회전하도록 경로변경

const COLLISION_FEEDBACK_DURATION: float = 0.1
const ACTIVATE_ANIMATION_DURATION: float = 0.3

enum originType {NONE, SYSTEM, USER}
var _origin: originType = originType.NONE

@onready var _carEnterArea: Area2D = $CarEnterArea
@onready var _touchButton: TextureButton = $TouchButton
@onready var _systemCrossway: TileMapLayer = $TileMap/SystemCrossway
@onready var _userCrossway: TileMapLayer = $TileMap/UserCrossway
@onready var _roadOverlap: TileMapLayer = $TileMap/RoadOverlap
@onready var _createPoint: TileMapLayer = $TileMap/CreatePoint
@onready var _collisionShape: CollisionShape2D = $CarEnterArea/CollisionShape2D

func _ready() -> void:
    _carEnterArea.body_entered.connect(_on_body_entered)
    _touchButton.pressed.connect(_on_touch_button_pressed)
    
func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
    
    var car: Car = body    
    var dPos: Vector2 = car.position - position
    
    var angle: float = _calculateTurnAngle(dPos)
    var radius: float = abs(dPos.y)
        
    SignalBus.make_enteredCar_turn.emit(car, angle, radius)

func _calculateTurnAngle(dPos: Vector2) -> float:
    if dPos.x >= 0 and dPos.y <= 0:
        return PI / 2
    elif dPos.x < 0 and dPos.y <= 0:
        return -PI / 2
    elif dPos.x < 0 and dPos.y > 0:
        return PI / 2
    else:
        return -PI / 2

func _on_touch_button_pressed() -> void:
    if _origin == originType.NONE:
        activateBy(originType.USER)
    else:
        deactivate()

func deactivate() -> void:
    if _origin == originType.SYSTEM:
        return
    _origin = originType.NONE
    _systemCrossway.visible = false
    _userCrossway.visible = false
    _roadOverlap.visible = false
    _createPoint.visible = true
    _carEnterArea.monitoring = false
    _carEnterArea.monitorable = false

func activateBy(origin: originType) -> void:
    if _origin != originType.NONE:
        return

    var overlappingCrossway: Crossway = _getOverlappingActiveCrossway()
    if overlappingCrossway:
        overlappingCrossway.playCollisionFeedback()
        return

    _origin = origin
    
    var target_layers: Array[CanvasItem] = []
    target_layers.append(_roadOverlap)

    if origin == originType.USER:
        target_layers.append(_userCrossway)
    elif origin == originType.SYSTEM:        
        target_layers.append(_systemCrossway)
    
    _createPoint.visible = false
    _carEnterArea.monitoring = true
    _carEnterArea.monitorable = true
    
    _playActivateAnimation(target_layers)

func _playActivateAnimation(target_layers: Array[CanvasItem]) -> void:
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    
    for layer in target_layers:
        layer.modulate.a = 0.0
        layer.visible = true
        tween.tween_property(layer, "modulate:a", 1.0, ACTIVATE_ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func playCollisionFeedback() -> void:
    var target_layer: CanvasItem
    if _origin == originType.USER:
        target_layer = _userCrossway
    elif _origin == originType.SYSTEM:
        target_layer = _systemCrossway
    
    if target_layer:
        var original_color: Color = target_layer.modulate
        var tween: Tween = create_tween()
        tween.tween_property(target_layer, "modulate", Color(1, 0.3, 0.3), COLLISION_FEEDBACK_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        tween.tween_property(target_layer, "modulate", original_color, COLLISION_FEEDBACK_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _getOverlappingActiveCrossway() -> Crossway:
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    
    query.shape = _collisionShape.shape
    query.transform = _collisionShape.global_transform
    query.collision_mask = _carEnterArea.collision_mask
    query.collide_with_areas = true
    query.collide_with_bodies = false
    
    var results: Array[Dictionary] = space_state.intersect_shape(query)
    for result in results:
        var collider = result["collider"]
        if collider is Area2D and collider.get_parent() is Crossway:
            var other_crossway: Crossway = collider.get_parent()
            if other_crossway != self and other_crossway._origin != originType.NONE:
                return other_crossway
    return null
    
    
    
    
    
    
    
    
    
    
    
