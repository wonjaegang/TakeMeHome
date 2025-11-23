extends Node2D
class_name Crossway

## 책임:
##  - 차량이 들어오면 회전하도록 경로변경

enum originType {NONE, SYSTEM, USER}
var _origin: originType = originType.NONE

func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)
    $TouchButton.pressed.connect(_on_touch_button_pressed)    
    $CarEnterArea.area_entered.connect(_on_area_entered)
    
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
    if _origin == originType.NONE:
        activateBy(originType.USER)
    else:
        deactivate()

func _on_area_entered(area: Area2D) -> void:
    if area.get_parent() is Crossway:
        print('Crossway area entered by another Crossway')
        deactivate()

func deactivate() -> void:
    if _origin == originType.SYSTEM:
        return
    _origin = originType.NONE
    $TileMap/SystemCrossway.visible = false
    $TileMap/UserCrossway.visible = false
    $TileMap/RoadOverlap.visible = false
    $TileMap/CreatePoint.visible = true
    $CarEnterArea.monitoring = false
    $CarEnterArea.monitorable = false

func activateBy(origin: originType) -> void:
    if _origin != originType.NONE:
        return

    if _isOverlappingWithActiveCrossway():
        return

    _origin = origin
    if origin == originType.USER:
        $TileMap/UserCrossway.visible = true
    elif origin == originType.SYSTEM:        
        $TileMap/SystemCrossway.visible = true
    
    $TileMap/RoadOverlap.visible = true
    $TileMap/CreatePoint.visible = false
    $CarEnterArea.monitoring = true
    $CarEnterArea.monitorable = true

func _isOverlappingWithActiveCrossway() -> bool:
    var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
    var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
    var shape_node: CollisionShape2D = $CarEnterArea/CollisionShape2D
    
    query.shape = shape_node.shape
    query.transform = shape_node.global_transform
    query.collision_mask = $CarEnterArea.collision_mask
    query.collide_with_areas = true
    query.collide_with_bodies = false
    
    var results: Array[Dictionary] = space_state.intersect_shape(query)
    for result in results:
        var collider = result["collider"]
        if collider is Area2D and collider.get_parent() is Crossway:
            var other_crossway: Crossway = collider.get_parent()
            if other_crossway != self and other_crossway._origin != originType.NONE:
                return true
    return false
    
    
    
    
    
    
    
    
    
    
    
