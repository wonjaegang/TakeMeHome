extends Node
class_name Crossway

## 책임:
## - 연결된 두 도로에 자신을 등록하고 해제
## - 한 도로에서 다른 도로로 차량 이동을 중재

enum Type {
    NORMAL,
    ONEWAY,
}
var _startRoad: Road
var _endRoad: Road
var _point: int
var _type: Type

func _init(startRoad: Road, endRoad: Road, point: int, type: Type) -> void:
    _startRoad = startRoad
    _endRoad = endRoad
    _point = point
    _type = type
    
func _ready() -> void:
    _registerAtRoad()
    
func _registerAtRoad() -> void:
    _startRoad.registerCrossway(_point, self)
    _endRoad.registerCrossway(_point, self)

func _freeFromRoad() -> void:    
    _startRoad.freeCrossway(_point, self)
    _endRoad.freeCrossway(_point, self)
