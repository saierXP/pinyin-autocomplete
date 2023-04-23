@tool
class_name SimeAPI
extends Sime

enum KeyMask {
	Shift = 1<<0,
	Lock = 1<<1,
	Control = 1<<2,
	Alt = 1<<3,

}

const Key = {
	"Backspace" = 65288
}

signal Commited(text:String)
signal CandidatesChanged(candidates:PackedStringArray)
signal CompositionChanged(composition:String)

var input_key:=0
var input_mask:=0
var menu:SimeMenu
var composition:SimeComposition

var code_edit:CodeEdit

func _handle_key(event:InputEventKey):
	if not is_instance_valid(code_edit):
		return

	input_key = event.keycode
	input_mask =0

	if event.keycode <=KEY_Z and event.keycode >= KEY_A: # A+32=>a
		input_key += 32

	elif event.keycode <=KEY_9 and event.keycode >=KEY_0: #alt + num1 => select first option
		if event.alt_pressed:
			code_edit.accept_event()
		else:
			input_key = 0

	match event.keycode:
		KEY_SPACE:#默认的space=>ctrl+G->取消已经输入的拼音
			input_key = KEY_G+32
			input_mask = 4

		KEY_SEMICOLON:#shift+; => 不处理:的输入
			if event.shift_pressed:
				input_key = 0
				input_mask = 0

		KEY_EQUAL, KEY_MINUS:# [=,-] alt + '+' 切换选项页
			if event.alt_pressed:
				code_edit.accept_event()
			else:
				input_key = 0
		#\ ` ' , . 忽略输入
		KEY_BACKSLASH, KEY_QUOTELEFT, KEY_APOSTROPHE, KEY_COMMA,KEY_PERIOD:
			input_key = 0

		KEY_BACKSPACE: #重映射退格键为65288,且ctrl+退格时清空提交的拼音输入
			input_key = 65288
			if event.ctrl_pressed:
				input_key = KEY_G+32
				input_mask = 4

	prints("Key",input_key,input_mask,event.as_text_keycode())

func _handle_ime():
	if self.process_key(input_key,input_mask):
		var commit_text := self.get_commit() #获取提交的中文文本
		menu = self.get_menu() #获取选择菜单
		composition = self.get_composition() #获取拼音组合

		if not commit_text.is_empty():
			var length = composition.preedit.replace(" ","").length()
			CandidatesChanged.emit([])
			_remove_pinyin(code_edit, length)
			code_edit.insert_text_at_caret(commit_text)

		prints("menu",menu.candidates_text)
		CandidatesChanged.emit(menu.candidates_text)
		CompositionChanged.emit(composition.preedit.replace(" ","'"))

func _remove_pinyin(code_edit:TextEdit,length,ci=0):
	var caret_pos := Vector2i(code_edit.get_caret_column(ci), code_edit.get_caret_line(ci))
	var line := code_edit.get_line(caret_pos.y)
	var from_c:= clamp(caret_pos.x - length, 0, caret_pos.x)
	var start_index :=  line.find('`')
#
	if start_index != -1 and line[start_index-1] == ";" :
		from_c = clamp(from_c-1,0,caret_pos.x)

	code_edit.remove_text(caret_pos.y, from_c , caret_pos.y, caret_pos.x)
	code_edit.adjust_carets_after_edit(ci,caret_pos.y,from_c , caret_pos.y, caret_pos.x)
	code_edit.set_caret_column(from_c,false,ci)

func get_key_mask(n:String) ->int:
	return KeyMask.get(n,0)

func get_key(n:String) -> int:
	return Key.get(n,0)

