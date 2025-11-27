extends Node2D
class_name Road

## 책임:
## - 도로의 방향 저장
##  - 차량이 들어오면 회전하도록 경로변경

const SIGN_ANIMATION_DURATION: float = 1.0
const SIGN_ANIMATION_INTERVAL: float = 0.2
const SIGN_Y_GAP: float = 20.0
const SIGN_MAX_DISTANCE: float = 800.0

enum Direction {
    UP,
    DOWN,
}
var _direction: Direction
var _sign_template_texture: Texture2D
var _sign_template_scale: Vector2
var _sign_start_pos: Vector2
var _spawn_loop_tween: Tween

@onready var _direction_signs_parent: Node2D = $DirectionSigns

func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)
    
    # 템플릿 데이터 초기화
    if _direction_signs_parent.get_child_count() > 0:
        var signTemplate = _direction_signs_parent.get_child(0)
        if signTemplate is Sprite2D:
            _sign_template_texture = signTemplate.texture
            _sign_template_scale = signTemplate.scale
            _sign_start_pos = signTemplate.position
            signTemplate.queue_free()            
            
    _startSignAnimation()

func setDirection(direction: String) -> void:
    _direction = Direction.UP if direction == "up" else Direction.DOWN    
    
func getDirection() -> Direction:
    return _direction

func _startSignAnimation() -> void:
    _spawn_sign(_sign_start_pos)

func _spawn_sign(pos: Vector2) -> void:
    if not _direction_signs_parent: return

    # 노드 생성
    var sign_node = Sprite2D.new()
    sign_node.texture = _sign_template_texture
    sign_node.scale = _sign_template_scale
    sign_node.position = pos
    sign_node.modulate.a = 0.0 # 투명하게 시작
    _direction_signs_parent.add_child(sign_node)
    
    # 1. 애니메이션 (깜빡임 후 삭제)
    var anim_tween = create_tween()
    anim_tween.tween_property(sign_node, "modulate:a", 1.0, SIGN_ANIMATION_DURATION * 0.3)
    anim_tween.tween_property(sign_node, "modulate:a", 0.0, SIGN_ANIMATION_DURATION * 0.7)
    anim_tween.tween_callback(sign_node.queue_free)
    
    # 2. 다음 노드 생성 스케줄링
    _spawn_loop_tween = create_tween()
    _spawn_loop_tween.tween_interval(SIGN_ANIMATION_INTERVAL)
    _spawn_loop_tween.tween_callback(func():
        var next_y = pos.y + SIGN_Y_GAP
            
        # 최대 거리 체크
        if next_y - _sign_start_pos.y > SIGN_MAX_DISTANCE:
            next_y = _sign_start_pos.y
            
        _spawn_sign(Vector2(pos.x, next_y))
    )

func _on_body_entered(body: Node2D) -> void:
    if body is not Car:
        return      
        
    var car: Car = body 
    if not car.getHasEnteredRoad():
        car.setHasEnteredRoad(true)
        return
       
    var angle: float
    var radius: float
    
    var dPos: Vector2 = car.position - position
    radius = abs(dPos.x)
    if dPos.x >= 0 and _direction == Direction.UP:
        angle = PI / 2
    elif dPos.x >= 0 and _direction == Direction.DOWN:
        angle = -PI / 2
    elif dPos.x < 0 and _direction == Direction.UP:
        angle = -PI / 2
    elif dPos.x < 0 and _direction == Direction.DOWN:   
        angle = PI / 2
    else:
        return
        
    SignalBus.make_enteredCar_turn.emit(car, angle, radius)
    
