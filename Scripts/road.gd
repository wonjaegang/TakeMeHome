extends Node2D
class_name Road

## 책임:
## - 도로의 방향 저장
##  - 차량이 들어오면 회전하도록 경로변경

const SIGN_MOVE_DISTANCE: float = 32.0
const SIGN_ANIM_DURATION: float = 1.2
const SIGN_ANIM_INTERVAL: float = 0.4

enum Direction {
    UP,
    DOWN,
}
var _direction: Direction
var _signTweens: Array[Tween] = []
var _signInitialPositions: Dictionary = {}

@onready var _directionSignsParent: Node2D = $DirectionSigns
    
func _ready() -> void:
    $CarEnterArea.body_entered.connect(_on_body_entered)
    
    if _directionSignsParent:
        for child in _directionSignsParent.get_children():
            if child is Node2D:
                _signInitialPositions[child] = child.position
                child.modulate.a = 0.0
                
    _startSignAnimation()

func setDirection(direction: String) -> void:
    _direction = Direction.UP if direction == "up" else Direction.DOWN
    _startSignAnimation()
    
func getDirection() -> Direction:
    return _direction

func _startSignAnimation() -> void:
    for tween in _signTweens:
        if tween: tween.kill()
    _signTweens.clear()
    
    if not _directionSignsParent:
        return

    var signs = _directionSignsParent.get_children()
    # 도로 자체를 회전시키므로 항상 로컬 좌표계 기준 아래(또는 위)로만 이동하면 됨
    # 여기서는 아래쪽(Vector2.DOWN)으로 흐르도록 설정 (필요시 UP으로 변경)
    var move_vector: Vector2 = Vector2.DOWN * SIGN_MOVE_DISTANCE
        
    for i in range(signs.size()):
        var signSprite = signs[i]
        if not signSprite is Node2D: continue
        
        var initial_pos = _signInitialPositions.get(signSprite)
        if initial_pos == null: continue
        
        var tween = create_tween().set_loops()
        _signTweens.append(tween)
        
        # 순차적 실행을 위한 초기 딜레이
        tween.tween_interval(i * SIGN_ANIM_INTERVAL)
        
        # 초기화
        tween.tween_callback(func():
            signSprite.position = initial_pos
            signSprite.modulate.a = 0.0
        )
        
        # 애니메이션 (이동 + 깜빡임)
        tween.set_parallel(true)
        tween.tween_property(signSprite, "position", initial_pos + move_vector, SIGN_ANIM_DURATION)
        tween.tween_property(signSprite, "modulate:a", 1.0, SIGN_ANIM_DURATION * 0.2).set_ease(Tween.EASE_OUT)
        tween.tween_property(signSprite, "modulate:a", 0.0, SIGN_ANIM_DURATION * 0.2).set_delay(SIGN_ANIM_DURATION * 0.8).set_ease(Tween.EASE_IN)
        tween.set_parallel(false)

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
    
