@tool
extends CodeEdit

var reg:RegEx
var start_char:="`"
var current_type_text:String = ""
var is_chinese_completion:bool = false
var pinyin_engine:PinYinCore


func make_ready(r:RegEx, pye, ime=null) -> void:
	reg = r
	pinyin_engine = pye

	var prefixes = get_code_completion_prefixes()
	if not prefixes.has(start_char):
		var t = [start_char]
		t.append_array(prefixes)
#		prefixes.append(start_char)
		set_code_completion_prefixes(t)


func _filter_code_completion_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
#	var start = Time.get_ticks_usec()
	var chinese: Array[Dictionary]
	if is_chinese_completion:
		chinese = candidates.filter(filter_option_with_chinese)
		if current_type_text.split(start_char,false).size() == 0:
			return chinese

#	printraw(Time.get_ticks_usec() - start,"	")
	return chinese.filter(filter_options_with_pinyin)

func filter_option_with_chinese(candidate:Dictionary) -> bool:
	return reg.search(candidate["display_text"]) != null

func filter_options_with_pinyin(candidate:Dictionary) -> bool:
	return match_pinyin(current_type_text.split(start_char,false)[0], candidate["display_text"])

func match_pinyin(input:String, match_text:String) ->bool:
	if is_instance_valid(pinyin_engine):
#		return pinyin_engine.make_match(match_text,input)
		return pinyin_engine.match_texts(match_text,input)
	else:
		push_error("null pinyin engint")
		return false

func get_cursor() ->Vector2i:
	return Vector2i(get_caret_column(), get_caret_line())
