extends Control

# 시그널버스는 이렇게 쓰는게 아니다!!! 시그널을 여기서 정의해여해! 더 공부할것!

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var cars: Array[Node] = get_node('../Cars').get_children()
    var crossways: Array[Node] = get_node('../Crossways').get_children()
    var playButton: PlayButton = get_node('../PlayButton')
    var resetButton: ResetButton = get_node('../ResetButton')
    
    # 디버깅    
    for car:Car in cars:
        resetButton.turn_car.connect(car._setCurve.bind(PI / 2, 30))
        
    # 차량 출발
    for car:Car in cars:
        playButton.start_driving.connect(car.startCar)
        
    # 차량 회전    
    #for crossway: Crossway in crossways:
        #crossway.makeEnteredCarTurn.connect()
    
    # 레벨 종료
    
    
    
