extends Button

var is_visible = false

var current_text = ""
var keys_pressed = ""

var variant_keys = {
	KEY_KP_MULTIPLY:"*",
	KEY_KP_DIVIDE:"/",
	KEY_KP_SUBTRACT:"-",
	KEY_KP_PERIOD:".",
	KEY_KP_ADD:"+",
	KEY_KP_0:"0",
	KEY_KP_1:"1",
	KEY_KP_2:"2",
	KEY_KP_3:"3",
	KEY_KP_4:"4",
	KEY_KP_5:"5",
	KEY_KP_6:"6",
	KEY_KP_7:"7",
	KEY_KP_8:"8",
	KEY_KP_9:"9",
	KEY_SPACE:" ",
	KEY_EXCLAMDOWN:KEY_EXCLAM,
	KEY_CENT:KEY_C,
	KEY_BROKENBAR:KEY_BAR,
	KEY_SECTION:KEY_S,
	KEY_DIAERESIS:KEY_QUOTEDBL,
	KEY_QUOTELEFT:KEY_APOSTROPHE,
	KEY_COPYRIGHT:KEY_C,
	KEY_ORDFEMININE:KEY_A,
	KEY_GUILLEMOTLEFT:KEY_LESS,
	KEY_REGISTERED:KEY_R,
	KEY_TWOSUPERIOR:KEY_2,
	KEY_THREESUPERIOR:KEY_3,
	KEY_ACUTE:KEY_APOSTROPHE,
	KEY_MU:KEY_U,
	KEY_PERIODCENTERED:KEY_PERIOD,
	KEY_CEDILLA:KEY_COMMA,
	KEY_ONESUPERIOR:KEY_1,
	KEY_QUESTIONDOWN:KEY_QUESTION,
	KEY_AGRAVE:KEY_A,
	KEY_AACUTE:KEY_A,
	KEY_ACIRCUMFLEX:KEY_A,
	KEY_ATILDE:KEY_A,
	KEY_ADIAERESIS:KEY_A,
	KEY_ARING:KEY_A,
	KEY_AE:KEY_A,
	KEY_CCEDILLA:KEY_C,
	KEY_EGRAVE:KEY_E,
	KEY_EACUTE:KEY_E,
	KEY_ECIRCUMFLEX:KEY_E,
	KEY_EDIAERESIS:KEY_E,
	KEY_IGRAVE:KEY_I,
	KEY_IACUTE:KEY_I,
	KEY_ICIRCUMFLEX:KEY_I,
	KEY_IDIAERESIS:KEY_I,
	KEY_ETH:KEY_D,
	KEY_NTILDE:KEY_N,
	KEY_OGRAVE:KEY_O,
	KEY_OACUTE:KEY_O,
	KEY_OCIRCUMFLEX:KEY_O,
	KEY_OTILDE:KEY_O,
	KEY_ODIAERESIS:KEY_O,
	KEY_OOBLIQUE:KEY_O,
	KEY_MULTIPLY:KEY_X,
	KEY_UGRAVE:KEY_U,
	KEY_UACUTE:KEY_U,
	KEY_UCIRCUMFLEX:KEY_U,
	KEY_UDIAERESIS:KEY_U,
	KEY_YACUTE:KEY_Y,
	KEY_YDIAERESIS:KEY_Y,
	KEY_THORN:KEY_P,
	KEY_SSHARP:KEY_B,
	KEY_DIVISION:KEY_SLASH
}

var clear_keys = [
	KEY_CLEAR,
	KEY_DELETE,
	KEY_BACKSPACE,
	KEY_ESCAPE
]

var acceptable_keys = [
	KEY_SPACE,
	KEY_EXCLAM,
	KEY_QUOTEDBL,
	KEY_NUMBERSIGN,
	KEY_DOLLAR,
	KEY_PERCENT,
	KEY_AMPERSAND,
	KEY_APOSTROPHE,
	KEY_PARENLEFT,
	KEY_PARENRIGHT,
	KEY_ASTERISK,
	KEY_PLUS,
	KEY_COMMA,
	KEY_MINUS,
	KEY_PERIOD,
	KEY_SLASH,
	KEY_0,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
	KEY_COLON,
	KEY_SEMICOLON,
	KEY_LESS,
	KEY_EQUAL,
	KEY_GREATER,
	KEY_QUESTION,
	KEY_AT,
	KEY_A,
	KEY_B,
	KEY_C,
	KEY_D,
	KEY_E,
	KEY_F,
	KEY_G,
	KEY_H,
	KEY_I,
	KEY_J,
	KEY_K,
	KEY_L,
	KEY_M,
	KEY_N,
	KEY_O,
	KEY_P,
	KEY_Q,
	KEY_R,
	KEY_S,
	KEY_T,
	KEY_U,
	KEY_V,
	KEY_W,
	KEY_X,
	KEY_Y,
	KEY_Z,
	KEY_BRACKETLEFT,
	KEY_BACKSLASH,
	KEY_BRACKETRIGHT,
	KEY_ASCIICIRCUM,
	KEY_UNDERSCORE,
	KEY_QUOTELEFT,
	KEY_BRACELEFT,
	KEY_BAR,
	KEY_BRACERIGHT,
	KEY_ASCIITILDE,
	KEY_EXCLAMDOWN,
	KEY_CENT,
	KEY_STERLING,
	KEY_CURRENCY,
	KEY_YEN,
	KEY_BROKENBAR,
	KEY_SECTION,
	KEY_DIAERESIS,
	KEY_COPYRIGHT,
	KEY_ORDFEMININE,
	KEY_GUILLEMOTLEFT,
	KEY_NOTSIGN,
	KEY_REGISTERED,
	KEY_MACRON,
	KEY_DEGREE,
	KEY_PLUSMINUS,
	KEY_TWOSUPERIOR,
	KEY_THREESUPERIOR,
	KEY_ACUTE,
	KEY_MU,
	KEY_PARAGRAPH,
	KEY_PERIODCENTERED,
	KEY_CEDILLA,
	KEY_ONESUPERIOR,
	KEY_MASCULINE,
	KEY_GUILLEMOTRIGHT,
	KEY_ONEQUARTER,
	KEY_ONEHALF,
	KEY_THREEQUARTERS,
	KEY_QUESTIONDOWN,
	KEY_AGRAVE,
	KEY_AACUTE,
	KEY_ACIRCUMFLEX,
	KEY_ATILDE,
	KEY_ADIAERESIS,
	KEY_ARING,
	KEY_AE,
	KEY_CCEDILLA,
	KEY_EGRAVE,
	KEY_EACUTE,
	KEY_ECIRCUMFLEX,
	KEY_EDIAERESIS,
	KEY_IGRAVE,
	KEY_IACUTE,
	KEY_ICIRCUMFLEX,
	KEY_IDIAERESIS,
	KEY_ETH,
	KEY_NTILDE,
	KEY_OGRAVE,
	KEY_OACUTE,
	KEY_OCIRCUMFLEX,
	KEY_OTILDE,
	KEY_ODIAERESIS,
	KEY_MULTIPLY,
	KEY_OOBLIQUE,
	KEY_UGRAVE,
	KEY_UACUTE,
	KEY_UCIRCUMFLEX,
	KEY_UDIAERESIS,
	KEY_YACUTE,
	KEY_THORN,
	KEY_SSHARP,
	KEY_DIVISION,
	KEY_YDIAERESIS
]

export var text_label_path = NodePath("")
onready var text_label = get_node(text_label_path)

func _unhandled_key_input(event):
	if text_label and is_visible and event.pressed:
		var scan = event.scancode
		if current_text == "" and OS.get_scancode_string(scan) == "Space":
			return
		if scan in variant_keys:
			var key = ""
			var vari = variant_keys[scan]
			var vk = ""
			match typeof(vari):
				TYPE_STRING:
					vk = vari
					key = vari
				TYPE_INT:
					vk = OS.get_scancode_string(vari)
					key = OS.get_scancode_string(scan)
			keys_pressed = keys_pressed + vk
			current_text = current_text + key
		elif scan in acceptable_keys:
			var key = OS.get_scancode_string(scan)
			current_text = current_text + key
			var vk = OS.get_scancode_string(scan)
			keys_pressed = keys_pressed + vk
		if scan in clear_keys:
			keys_pressed = ""
			current_text = ""
		
func _visibility_changed():
	current_text = ""
	keys_pressed = ""

var cursor = true
var cursor_time = 0.0

func _process(delta):
	if text_label and is_visible_in_tree():
		cursor_time += delta
		if cursor_time >= 0.5:
			cursor = !cursor
			cursor_time = 0
			is_visible = true
		var display_text = current_text
		if cursor:
			display_text = current_text + "_"
		text_label.text = display_text
	else:
		is_visible = false
