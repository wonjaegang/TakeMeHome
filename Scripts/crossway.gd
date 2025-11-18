extends Node2D
class_name Crossway

## 책임:
##  - 차량이 들어오면 회전하도록 경로변경

enum originType {NONE, SYSTEM, USER}
var _origin: originType = originType.NONE

func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)
    $TouchButton.pressed.connect(_on_touch_button_pressed)
    $TouchButton.focus_entered.connect(_showPreview)
    $TouchButton.focus_exited.connect(_hidePreview)
    
func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return
    
    var car: Car = body    
    var angle: float
    var radius: float
    
    var dPos: Vector2 = car.position - position
    radius = abs(dPos.y)
    if dPos.x >= 0 and dPos.y <= 0:
        angle = PI / 2
    elif dPos.x < 0 and dPos.y <= 0:
        angle = -PI / 2
    elif dPos.x < 0 and dPos.y > 0:
        angle = PI / 2
    else:
        angle = -PI / 2
        
    SignalBus.make_enteredCar_turn.emit(car, angle, radius)

func _on_touch_button_pressed() -> void:
    activateBy(originType.USER)

func deactivate() -> void:
    $CarEnterArea.monitoring = false
    $CarEnterArea.monitorable = false

func activateBy(origin: originType) -> void:
    if _origin != originType.NONE:
        return
    _origin = origin
    $TileMap/RoadOverlap.visible = true
    $TileMap/LevelCrossway.visible = true
    $CarEnterArea.monitoring = true
    $CarEnterArea.monitorable = true
    
func _showPreview() -> void:
    $TileMap/RoadOverlap.visible = true
    $TileMap/PreviewCrossway.visible = true

func _hidePreview() -> void:
    $TileMap/RoadOverlap.visible = false
    $TileMap/PreviewCrossway.visible = false