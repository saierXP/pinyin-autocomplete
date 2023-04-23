@tool
extends Control
class_name CandidateOption


var options:Array[HBoxContainer]
var commit_text:String
@export var res:Array
func _ready() -> void:
	create_options()

func set_option_text(idx:int, t:String) ->void:
	options[idx].set_char(t)

func create_options():
	options.resize(5)
	for i in options.size():
		options[i] = preload('res://addons/sc_complete/ime/option.tscn').instantiate()
		$PanelContainer/VBoxContainer.add_child(options[i])
		options[i].create(i+1, "")

#func _on_text_edit_gui_input(event: InputEvent) -> void:
#	sime.input_key = 0
#	sime.input_mask = 0
#	if event is InputEventKey and event.is_pressed():
#		sime._handle_key(event)
#		sime._handle_ime()
#
#		var candidations := sime.get_candidations()
#		if candidations.is_empty():
#			for i in 5:
#				set_option_text(i,'')
#		else:
#			for i in candidations.size():
#				set_option_text(i,candidations[i])
