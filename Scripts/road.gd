extends Node
class_name Road

## 책임:
## - 도로의 방향 저장
## - 각 포인트에 연결된 crossway 조회

enum Direction {
    UP,
    DOWN,
}
const TOTAL_POINT: int = 12  # 상단, 하단 점을 포함한 총 point 수
var _direction: Direction
var _crossways: Dictionary = {}

func _init(direction: String) -> void:
    _direction = Direction.UP if direction == "up" else Direction.DOWN
    
func _ready() -> void:
    pass # Replace with function body.  
    
func getDirection() -> Direction:
    return _direction
    
func registerCrossway(point: int, crossway: Crossway) -> void:
    _crossways[point] = weakref(crossway) ## 언제든 제거될 수 있으므로 약한참조 사용
    
func freeCrossway(point: int, crossway: Crossway) -> void:
    if _crossways.get(point).get_ref() == crossway:
        _crossways.erase(point)
