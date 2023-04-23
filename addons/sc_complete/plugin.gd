@tool
extends EditorPlugin

const CodeEditEnglish = preload("./code_edit/code_edit_english.gd")
const CandidateOptionScn = preload('res://addons/sc_complete/ime/candidates_option.tscn')

const dict_path = 'res://addons/sc_complete/dict/pinyin_dict_str.json'
var pinyin_engine:PinYinCore
#var sime:SimeAPI
#var ime_enable := false

var start_char = "`"

var script_editor:ScriptEditor
var code_edit:CodeEdit

var candidate_options:CandidateOption
var reg:RegEx = RegEx.new()
var string_to_complete:String = ''


func _enter_tree() -> void:

#	if ime_enable:
#		sime = SimeAPI.new()
#		sime.CandidatesChanged.connect(_on_candidates_changed)

	reg.compile("[\\x{4e00}-\\x{9fa5}]+")

	var f = FileAccess.open(dict_path,FileAccess.READ)
	var dict:Dictionary = JSON.parse_string(f.get_as_text())
	if dict:
		pinyin_engine = PinYinCore.new(dict)
	else:
		push_error("dict null")

func _ready() -> void:
	candidate_options = CandidateOptionScn.instantiate()
	add_child(candidate_options)
	candidate_options.position = Vector2(1200,600)

	script_editor = get_editor_interface().get_script_editor()
	script_editor.editor_script_changed.connect(_editor_script_changed)

func code_edit_signal_connect(c:CodeEdit):

	if not c.gui_input.is_connected(_code_gui_input):
		c.gui_input.connect(_code_gui_input)

	if not c.code_completion_requested.is_connected(_code_completion_requested):
		c.code_completion_requested.connect(_code_completion_requested, CONNECT_DEFERRED)


func _code_completion_requested():
	if code_edit.dirt:
		prints("requested", code_edit.get_code_completion_option(0))
		code_edit.dirt = false
		code_edit.options =  code_edit.get_code_completion_options()


func _editor_script_changed(script:Script):
	code_edit = script_editor.get_current_editor().get_base_editor()
	code_edit_signal_connect(code_edit)
	code_edit.set_meta("is_chinese_mode", false)
	code_edit.set_script(CodeEditEnglish)
	code_edit.make_ready()
	code_edit.reg = reg
	code_edit.dirt = true
	code_edit.pinyins = {}
	code_edit.pinyin_engine = pinyin_engine


func _code_gui_input(event:InputEvent):
	if event.is_pressed() and event is InputEventKey:
		match event.keycode:
			KEY_PERIOD, KEY_APOSTROPHE: # . '
				code_edit.dirt = true

			KEY_SEMICOLON, KEY_2, KEY_4, KEY_5: # shift-> : @ $ %
				if event.shift_pressed:
					code_edit.dirt = true

#		if ime_enable:
#			sime.code_edit = code_edit
#			sime._handle_key(event)
#			sime._handle_ime()


func _on_candidates_changed(c:PackedStringArray):
	candidate_options.visible = not c.is_empty()
	for i in c.size():
		candidate_options.set_option_text(i,c[i])

func _get_complete_string(p_code_edit:CodeEdit) -> String:
	var caret_line := p_code_edit.get_caret_line()
	var caret_column:= p_code_edit.get_caret_column()

	var line = p_code_edit.get_line(caret_line);
	var cofs:int = caret_column
	var start_cofs = cofs;
	while 	(cofs > 0 && line[cofs - 1] > " " && \
			(line[cofs - 1] == '/' || !_is_symbol(line[cofs - 1]))) :
		cofs -= 1

	return  line.substr(cofs, start_cofs - cofs);

func _is_symbol(c:String) -> bool:
	return c != start_char && c != '_' && ((c >= '!' && c <= '/') || (c >= ':' && c <= '@') || (c >= '[' && c <= '`') \
	|| (c >= '{' && c <= '~') || c == '\t' || c == ' ');


func _exit_tree() -> void:
	do_free()
	queue_free()
	print("plugin exit")

func do_free():
	if is_instance_valid(code_edit):
		for c in code_edit.code_completion_requested.get_connections():
			if not c["callable"].is_custom():
				code_edit.code_completion_requested.disconnect(c["callable"])

		for c in code_edit.gui_input.get_connections():
			if not c["callable"].is_custom():
				code_edit.gui_input.disconnect(c["callable"])
		code_edit.set_script(null)
