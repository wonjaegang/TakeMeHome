extends Control

## 책임:
##   시그널을 정의하고 중계하며, 시그널 체이닝 진행
##   시그널 버스 내에서는 로직 적용X

## 시그널 정의
# 차량 이동
@warning_ignore("unused_signal")
signal start_driving
@warning_ignore("unused_signal")
signal make_enteredCar_turn(car: Car, angle:float, radius:float)
@warning_ignore("unused_signal")
signal car_arrived_home(car: Car)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
    
    
