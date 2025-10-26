extends Node
class_name Home

## 책임:
##  - 목적지의 위치를 관리
##  - 목적지 도달 여부 판정

var _road: Road
var _point: int

func _init(road:Road) -> void:
    _road = road
    _point = 0 if road.getDirection() == Road.Direction.UP else Road.TOTAL_POINT

func _ready() -> void:
    pass # Replace with function body.
