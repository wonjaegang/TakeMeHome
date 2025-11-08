extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var cars = get_node('../Cars').get_children()
    var playButton: PlayButton = get_node('../PlayButton')
    var resetButton: ResetButton = get_node('../ResetButton')
    
    for car:Car in cars:
        playButton.start_driving.connect(car.startCar)
        
    for car:Car in cars:
        resetButton.turn_car.connect(car.setCurve.bind(PI / 2, 30))
