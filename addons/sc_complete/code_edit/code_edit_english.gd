@tool
extends CodeEdit

var reg:RegEx
var current_type_text:String = ""
var is_chinese_completion:bool = false
var pinyin_engine:PinYinCore
var dirt:=true
var options:Array[Dictionary]

var pinyins := {}

func make_ready() -> void:

	var start_char:="`"
	var prefixes = get_code_completion_prefixes()
	if not prefixes.has(start_char):
		var t = [start_char]
		t.append_array(prefixes)
#		prefixes.append(start_char)
		set_code_completion_prefixes(t)

func _request_code_completion(force: bool) -> void:

	if dirt:
		code_completion_requested.emit()
	else:
		for option in options:
			var text = option["display_text"].replace("'","")
			var match_res := reg.search(text)
			var py :=''
			if match_res != null:
				var chinese = match_res.get_string()
				if pinyins.get(chinese,[]).is_empty():
					pinyins[chinese] = pinyin_engine.get_pinyin(chinese)
#
				py = "|".join(pinyins[chinese])
				text += " " + py
#
			self.add_code_completion_option(option['kind'],text,option['insert_text'],option['font_color'],option['icon'],option['default_value'])
		self.update_code_completion_options(force)
