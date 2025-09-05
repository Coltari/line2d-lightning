@tool
class_name AttributeSlider
extends Container

var _value : float:
	get():
		await until_ready()
		return h_slider.value

@export var attribute : String = "An Attribute":
	set(value):
		attribute = value
		await until_ready()
		attribute_label.text = attribute
@export var minimum : float = 0.0:
	set(value):
		minimum = value
		await until_ready()
		h_slider.min_value = minimum
@export var maximum : float = 100.0:
	set(value):
		maximum = value
		await until_ready()
		h_slider.max_value = maximum
@export var step : float = 1.0:
	set(value):
		step = value
		await until_ready()
		h_slider.step = step
@export var value : float:
	get():
		return _value
	set(new_value):
		await until_ready()
		h_slider.value = new_value

@onready var attribute_label: Label = %AttributeLabel
@onready var value_label: Label = %ValueLabel
@onready var h_slider: HSlider = %HSlider

signal value_changed(new_value : float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attribute_label.text = attribute
	h_slider.min_value = minimum
	h_slider.max_value = maximum
	h_slider.step = step
	h_slider.value_changed.connect(on_value_changed)

func on_value_changed(_new_value : float) -> void:
	var text_value := str(snapped(value, 0.01))
	value_label.text = text_value
	value_changed.emit(value)

func until_ready() -> void:
	if not is_node_ready():
		await ready
