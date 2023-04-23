extends Object
class_name PinYinCore

var all_pin_yin = []
var no_tone = {}
var storage = {}

func _init(dict):
	all_pin_yin = dict.keys()
	no_tone = parse_dict(dict)

func parse_dict(dict):
	var parse_dict = {}
	for i in dict:
		var temp = dict[i]
		for j in temp.length():
			if (parse_dict.get(temp[j])):
				parse_dict[temp[j]] = parse_dict[temp[j]] + ' ' + i
			else:
				parse_dict[temp[j]] = i

	return parse_dict

func get_pinyin(cn):
	var result = []
	for i in cn.length():
		var temp = cn[i]
		if no_tone.get(temp):
			result.append(no_tone.get(temp))
		else:
			result.append(temp)
	return result

func match_texts(words: String, pinyin: String) -> bool:
	var result = []
	var currentPinyin = pinyin
	for i in words.length():

		# 是否为中文匹配
		if (words[i] == currentPinyin[0]):
			currentPinyin = currentPinyin.substr(1)
			result.append(i)
			continue

		# 当前字的多音字拼音
		var pa:Array = get_pinyin(words[i])
		var ps:Array
		if pa.size()>0:
			ps = pa[0].split(" ")

		var currentLength = 0
		for p in ps:
			var length = get_match_length(p, currentPinyin)
			if (length > currentLength):
				currentLength = length

		if (currentLength):
			currentPinyin = currentPinyin.substr(currentLength)
			result.append(i)

		if (currentPinyin.is_empty()):
			break

	return true if result.size() && currentPinyin.is_empty() else false

# 检测两个拼音最大的匹配长度
func get_match_length(pinyin1: String, pinyin2: String) -> int:
	var length = 0
	for i in pinyin1.length():
		if length >= pinyin2.length(): continue
		if (pinyin1[i] == pinyin2[length]):
			length +=1

	return length
