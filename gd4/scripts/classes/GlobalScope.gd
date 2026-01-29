extends Node
class_name GlobalScope

enum Margin {
	MARGIN_LEFT = 0,		# Left margin, usually used for Control or StyleBox-derived classes.
	MARGIN_TOP = 1,		# Top margin, usually used for Control or StyleBox-derived classes.
	MARGIN_RIGHT = 2,		# Right margin, usually used for Control or StyleBox-derived classes.
	MARGIN_BOTTOM = 3,		# Bottom margin, usually used for Control or StyleBox-derived classes.
}

enum Corner {
	CORNER_TOP_LEFT = 0,		# Top-left corner.
	CORNER_TOP_RIGHT = 1,		# Top-right corner.
	CORNER_BOTTOM_RIGHT = 2,		# Bottom-right corner.
	CORNER_BOTTOM_LEFT = 3,		# Bottom-left corner.
}

enum Orientation {
	VERTICAL = 1,		# General vertical alignment, usually used for Separator, ScrollBar, Slider, etc.
	HORIZONTAL = 0,		# General horizontal alignment, usually used for Separator, ScrollBar, Slider, etc.
}

enum HAlign {
	HALIGN_LEFT = 0,		# Horizontal left alignment, usually for text-derived classes.
	HALIGN_CENTER = 1,		# Horizontal center alignment, usually for text-derived classes.
	HALIGN_RIGHT = 2,		# Horizontal right alignment, usually for text-derived classes.
}

enum VAlign {
	VALIGN_TOP = 0,		# Vertical top alignment, usually for text-derived classes.
	VALIGN_CENTER = 1,		# Vertical center alignment, usually for text-derived classes.
	VALIGN_BOTTOM = 2,		# Vertical bottom alignment, usually for text-derived classes.
}

enum KeyList {
	KEY_ESCAPE = 16777217,		# Escape key.
	KEY_TAB = 16777218,		# Tab key.
	KEY_BACKTAB = 16777219,		# Shift+Tab key.
	KEY_BACKSPACE = 16777220,		# Backspace key.
	KEY_ENTER = 16777221,		# Return key (on the main keyboard).
	KEY_KP_ENTER = 16777222,		# Enter key on the numeric keypad.
	KEY_INSERT = 16777223,		# Insert key.
	KEY_DELETE = 16777224,		# Delete key.
	KEY_PAUSE = 16777225,		# Pause key.
	KEY_PRINT = 16777226,		# Print Screen key.
	KEY_SYSREQ = 16777227,		# System Request key.
	KEY_CLEAR = 16777228,		# Clear key.
	KEY_HOME = 16777229,		# Home key.
	KEY_END = 16777230,		# End key.
	KEY_LEFT = 16777231,		# Left arrow key.
	KEY_UP = 16777232,		# Up arrow key.
	KEY_RIGHT = 16777233,		# Right arrow key.
	KEY_DOWN = 16777234,		# Down arrow key.
	KEY_PAGEUP = 16777235,		# Page Up key.
	KEY_PAGEDOWN = 16777236,		# Page Down key.
	KEY_SHIFT = 16777237,		# Shift key.
	KEY_CONTROL = 16777238,		# Control key.
	KEY_META = 16777239,		# Meta key.
	KEY_ALT = 16777240,		# Alt key.
	KEY_CAPSLOCK = 16777241,		# Caps Lock key.
	KEY_NUMLOCK = 16777242,		# Num Lock key.
	KEY_SCROLLLOCK = 16777243,		# Scroll Lock key.
	KEY_F1 = 16777244,		# F1 key.
	KEY_F2 = 16777245,		# F2 key.
	KEY_F3 = 16777246,		# F3 key.
	KEY_F4 = 16777247,		# F4 key.
	KEY_F5 = 16777248,		# F5 key.
	KEY_F6 = 16777249,		# F6 key.
	KEY_F7 = 16777250,		# F7 key.
	KEY_F8 = 16777251,		# F8 key.
	KEY_F9 = 16777252,		# F9 key.
	KEY_F10 = 16777253,		# F10 key.
	KEY_F11 = 16777254,		# F11 key.
	KEY_F12 = 16777255,		# F12 key.
	KEY_F13 = 16777256,		# F13 key.
	KEY_F14 = 16777257,		# F14 key.
	KEY_F15 = 16777258,		# F15 key.
	KEY_F16 = 16777259,		# F16 key.
	KEY_KP_MULTIPLY = 16777345,		# Multiply (*) key on the numeric keypad.
	KEY_KP_DIVIDE = 16777346,		# Divide (/) key on the numeric keypad.
	KEY_KP_SUBTRACT = 16777347,		# Subtract (-) key on the numeric keypad.
	KEY_KP_PERIOD = 16777348,		# Period (.) key on the numeric keypad.
	KEY_KP_ADD = 16777349,		# Add (+) key on the numeric keypad.
	KEY_KP_0 = 16777350,		# Number 0 on the numeric keypad.
	KEY_KP_1 = 16777351,		# Number 1 on the numeric keypad.
	KEY_KP_2 = 16777352,		# Number 2 on the numeric keypad.
	KEY_KP_3 = 16777353,		# Number 3 on the numeric keypad.
	KEY_KP_4 = 16777354,		# Number 4 on the numeric keypad.
	KEY_KP_5 = 16777355,		# Number 5 on the numeric keypad.
	KEY_KP_6 = 16777356,		# Number 6 on the numeric keypad.
	KEY_KP_7 = 16777357,		# Number 7 on the numeric keypad.
	KEY_KP_8 = 16777358,		# Number 8 on the numeric keypad.
	KEY_KP_9 = 16777359,		# Number 9 on the numeric keypad.
	KEY_SUPER_L = 16777260,		# Left Super key (Windows key).
	KEY_SUPER_R = 16777261,		# Right Super key (Windows key).
	KEY_MENU = 16777262,		# Context menu key.
	KEY_HYPER_L = 16777263,		# Left Hyper key.
	KEY_HYPER_R = 16777264,		# Right Hyper key.
	KEY_HELP = 16777265,		# Help key.
	KEY_DIRECTION_L = 16777266,		# Left Direction key.
	KEY_DIRECTION_R = 16777267,		# Right Direction key.
	KEY_BACK = 16777280,		# Media back key. Not to be confused with the Back button on an Android device.
	KEY_FORWARD = 16777281,		# Media forward key.
	KEY_STOP = 16777282,		# Media stop key.
	KEY_REFRESH = 16777283,		# Media refresh key.
	KEY_VOLUMEDOWN = 16777284,		# Volume down key.
	KEY_VOLUMEMUTE = 16777285,		# Mute volume key.
	KEY_VOLUMEUP = 16777286,		# Volume up key.
	KEY_BASSBOOST = 16777287,		# Bass Boost key.
	KEY_BASSUP = 16777288,		# Bass up key.
	KEY_BASSDOWN = 16777289,		# Bass down key.
	KEY_TREBLEUP = 16777290,		# Treble up key.
	KEY_TREBLEDOWN = 16777291,		# Treble down key.
	KEY_MEDIAPLAY = 16777292,		# Media play key.
	KEY_MEDIASTOP = 16777293,		# Media stop key.
	KEY_MEDIAPREVIOUS = 16777294,		# Previous song key.
	KEY_MEDIANEXT = 16777295,		# Next song key.
	KEY_MEDIARECORD = 16777296,		# Media record key.
	KEY_HOMEPAGE = 16777297,		# Home page key.
	KEY_FAVORITES = 16777298,		# Favorites key.
	KEY_SEARCH = 16777299,		# Search key.
	KEY_STANDBY = 16777300,		# Standby key.
	KEY_OPENURL = 16777301,		# Open URL / Launch Browser key.
	KEY_LAUNCHMAIL = 16777302,		# Launch Mail key.
	KEY_LAUNCHMEDIA = 16777303,		# Launch Media key.
	KEY_LAUNCH0 = 16777304,		# Launch Shortcut 0 key.
	KEY_LAUNCH1 = 16777305,		# Launch Shortcut 1 key.
	KEY_LAUNCH2 = 16777306,		# Launch Shortcut 2 key.
	KEY_LAUNCH3 = 16777307,		# Launch Shortcut 3 key.
	KEY_LAUNCH4 = 16777308,		# Launch Shortcut 4 key.
	KEY_LAUNCH5 = 16777309,		# Launch Shortcut 5 key.
	KEY_LAUNCH6 = 16777310,		# Launch Shortcut 6 key.
	KEY_LAUNCH7 = 16777311,		# Launch Shortcut 7 key.
	KEY_LAUNCH8 = 16777312,		# Launch Shortcut 8 key.
	KEY_LAUNCH9 = 16777313,		# Launch Shortcut 9 key.
	KEY_LAUNCHA = 16777314,		# Launch Shortcut A key.
	KEY_LAUNCHB = 16777315,		# Launch Shortcut B key.
	KEY_LAUNCHC = 16777316,		# Launch Shortcut C key.
	KEY_LAUNCHD = 16777317,		# Launch Shortcut D key.
	KEY_LAUNCHE = 16777318,		# Launch Shortcut E key.
	KEY_LAUNCHF = 16777319,		# Launch Shortcut F key.
	KEY_UNKNOWN = 33554431,		# Unknown key.
	KEY_SPACE = 32,		# Space key.
	KEY_EXCLAM = 33,		# ! key.
	KEY_QUOTEDBL = 34,		# " key.
	KEY_NUMBERSIGN = 35,		# # key.
	KEY_DOLLAR = 36,		# $ key.
	KEY_PERCENT = 37,		# % key.
	KEY_AMPERSAND = 38,		# & key.
	KEY_APOSTROPHE = 39,		# ' key.
	KEY_PARENLEFT = 40,		# ( key.
	KEY_PARENRIGHT = 41,		# ) key.
	KEY_ASTERISK = 42,		# * key.
	KEY_PLUS = 43,		# + key.
	KEY_COMMA = 44,		# , key.
	KEY_MINUS = 45,		# - key.
	KEY_PERIOD = 46,		# . key.
	KEY_SLASH = 47,		# / key.
	KEY_0 = 48,		# Number 0.
	KEY_1 = 49,		# Number 1.
	KEY_2 = 50,		# Number 2.
	KEY_3 = 51,		# Number 3.
	KEY_4 = 52,		# Number 4.
	KEY_5 = 53,		# Number 5.
	KEY_6 = 54,		# Number 6.
	KEY_7 = 55,		# Number 7.
	KEY_8 = 56,		# Number 8.
	KEY_9 = 57,		# Number 9.
	KEY_COLON = 58,		#  { key.
	KEY_SEMICOLON = 59,		# ; key.
	KEY_LESS = 60,		# < key.
	KEY_EQUAL = 61,		# = key.
	KEY_GREATER = 62,		# > key.
	KEY_QUESTION = 63,		# ? key.
	KEY_AT = 64,		# @ key.
	KEY_A = 65,		# A key.
	KEY_B = 66,		# B key.
	KEY_C = 67,		# C key.
	KEY_D = 68,		# D key.
	KEY_E = 69,		# E key.
	KEY_F = 70,		# F key.
	KEY_G = 71,		# G key.
	KEY_H = 72,		# H key.
	KEY_I = 73,		# I key.
	KEY_J = 74,		# J key.
	KEY_K = 75,		# K key.
	KEY_L = 76,		# L key.
	KEY_M = 77,		# M key.
	KEY_N = 78,		# N key.
	KEY_O = 79,		# O key.
	KEY_P = 80,		# P key.
	KEY_Q = 81,		# Q key.
	KEY_R = 82,		# R key.
	KEY_S = 83,		# S key.
	KEY_T = 84,		# T key.
	KEY_U = 85,		# U key.
	KEY_V = 86,		# V key.
	KEY_W = 87,		# W key.
	KEY_X = 88,		# X key.
	KEY_Y = 89,		# Y key.
	KEY_Z = 90,		# Z key.
	KEY_BRACKETLEFT = 91,		# [ key.
	KEY_BACKSLASH = 92,		# \ key.
	KEY_BRACKETRIGHT = 93,		# ] key.
	KEY_ASCIICIRCUM = 94,		# ^ key.
	KEY_UNDERSCORE = 95,		# _ key.
	KEY_QUOTELEFT = 96,		# ` key.
	KEY_BRACELEFT = 123,		# { key.
	KEY_BAR = 124,		# | key.
	KEY_BRACERIGHT = 125,		# } key.
	KEY_ASCIITILDE = 126,		# ~ key.
	KEY_NOBREAKSPACE = 160,		# Non-breakable space key.
	KEY_EXCLAMDOWN = 161,		# ¡ key.
	KEY_CENT = 162,		# ¢ key.
	KEY_STERLING = 163,		# £ key.
	KEY_CURRENCY = 164,		# ¤ key.
	KEY_YEN = 165,		# ¥ key.
	KEY_BROKENBAR = 166,		# ¦ key.
	KEY_SECTION = 167,		# § key.
	KEY_DIAERESIS = 168,		# ¨ key.
	KEY_COPYRIGHT = 169,		# © key.
	KEY_ORDFEMININE = 170,		# ª key.
	KEY_GUILLEMOTLEFT = 171,		# « key.
	KEY_NOTSIGN = 172,		# ¬ key.
	KEY_HYPHEN = 173,		# Soft hyphen key.
	KEY_REGISTERED = 174,		# ® key.
	KEY_MACRON = 175,		# ¯ key.
	KEY_DEGREE = 176,		# ° key.
	KEY_PLUSMINUS = 177,		# ± key.
	KEY_TWOSUPERIOR = 178,		# ² key.
	KEY_THREESUPERIOR = 179,		# ³ key.
	KEY_ACUTE = 180,		# ´ key.
	KEY_MU = 181,		# µ key.
	KEY_PARAGRAPH = 182,		# ¶ key.
	KEY_PERIODCENTERED = 183,		# · key.
	KEY_CEDILLA = 184,		# ¸ key.
	KEY_ONESUPERIOR = 185,		# ¹ key.
	KEY_MASCULINE = 186,		# º key.
	KEY_GUILLEMOTRIGHT = 187,		# » key.
	KEY_ONEQUARTER = 188,		# ¼ key.
	KEY_ONEHALF = 189,		# ½ key.
	KEY_THREEQUARTERS = 190,		# ¾ key.
	KEY_QUESTIONDOWN = 191,		# ¿ key.
	KEY_AGRAVE = 192,		# À key.
	KEY_AACUTE = 193,		# Á key.
	KEY_ACIRCUMFLEX = 194,		# Â key.
	KEY_ATILDE = 195,		# Ã key.
	KEY_ADIAERESIS = 196,		# Ä key.
	KEY_ARING = 197,		# Å key.
	KEY_AE = 198,		# Æ key.
	KEY_CCEDILLA = 199,		# Ç key.
	KEY_EGRAVE = 200,		# È key.
	KEY_EACUTE = 201,		# É key.
	KEY_ECIRCUMFLEX = 202,		# Ê key.
	KEY_EDIAERESIS = 203,		# Ë key.
	KEY_IGRAVE = 204,		# Ì key.
	KEY_IACUTE = 205,		# Í key.
	KEY_ICIRCUMFLEX = 206,		# Î key.
	KEY_IDIAERESIS = 207,		# Ï key.
	KEY_ETH = 208,		# Ð key.
	KEY_NTILDE = 209,		# Ñ key.
	KEY_OGRAVE = 210,		# Ò key.
	KEY_OACUTE = 211,		# Ó key.
	KEY_OCIRCUMFLEX = 212,		# Ô key.
	KEY_OTILDE = 213,		# Õ key.
	KEY_ODIAERESIS = 214,		# Ö key.
	KEY_MULTIPLY = 215,		# × key.
	KEY_OOBLIQUE = 216,		# Ø key.
	KEY_UGRAVE = 217,		# Ù key.
	KEY_UACUTE = 218,		# Ú key.
	KEY_UCIRCUMFLEX = 219,		# Û key.
	KEY_UDIAERESIS = 220,		# Ü key.
	KEY_YACUTE = 221,		# Ý key.
	KEY_THORN = 222,		# Þ key.
	KEY_SSHARP = 223,		# ß key.
	KEY_DIVISION = 247,		# ÷ key.
	KEY_YDIAERESIS = 255,		# ÿ key.
}

enum KeyModifierMask {
	KEY_CODE_MASK = 33554431,		# Key Code mask.
	KEY_MODIFIER_MASK = -16777216,		# Modifier key mask.
	KEY_MASK_SHIFT = 33554432,		# Shift key mask.
	KEY_MASK_ALT = 67108864,		# Alt key mask.
	KEY_MASK_META = 134217728,		# Meta key mask.
	KEY_MASK_CTRL = 268435456,		# Ctrl key mask.
#	KEY_MASK_CMD = platform-dependent,		# Command key mask. On macOS, this is equivalent to KEY_MASK_META. On other platforms, this is equivalent to KEY_MASK_CTRL. This mask should be preferred to KEY_MASK_META or KEY_MASK_CTRL for system shortcuts as it handles all platforms correctly.
	KEY_MASK_KPAD = 536870912,		# Keypad key mask.
	KEY_MASK_GROUP_SWITCH = 1073741824,		# Group Switch key mask.
}

enum ButtonList {
	BUTTON_LEFT = 1,		# Left mouse button.
	BUTTON_RIGHT = 2,		# Right mouse button.
	BUTTON_MIDDLE = 3,		# Middle mouse button.
	BUTTON_XBUTTON1 = 8,		# Extra mouse button 1 (only present on some mice).
	BUTTON_XBUTTON2 = 9,		# Extra mouse button 2 (only present on some mice).
	BUTTON_WHEEL_UP = 4,		# Mouse wheel up.
	BUTTON_WHEEL_DOWN = 5,		# Mouse wheel down.
	BUTTON_WHEEL_LEFT = 6,		# Mouse wheel left button (only present on some mice).
	BUTTON_WHEEL_RIGHT = 7,		# Mouse wheel right button (only present on some mice).
	BUTTON_MASK_LEFT = 1,		# Left mouse button mask.
	BUTTON_MASK_RIGHT = 2,		# Right mouse button mask.
	BUTTON_MASK_MIDDLE = 4,		# Middle mouse button mask.
	BUTTON_MASK_XBUTTON1 = 128,		# Extra mouse button 1 mask.
	BUTTON_MASK_XBUTTON2 = 256,		# Extra mouse button 2 mask.
}

enum JoystickList {
	JOY_INVALID_OPTION = -1,		# Invalid button or axis.
	JOY_BUTTON_0 = 0,		# Gamepad button 0.
	JOY_BUTTON_1 = 1,		# Gamepad button 1.
	JOY_BUTTON_2 = 2,		# Gamepad button 2.
	JOY_BUTTON_3 = 3,		# Gamepad button 3.
	JOY_BUTTON_4 = 4,		# Gamepad button 4.
	JOY_BUTTON_5 = 5,		# Gamepad button 5.
	JOY_BUTTON_6 = 6,		# Gamepad button 6.
	JOY_BUTTON_7 = 7,		# Gamepad button 7.
	JOY_BUTTON_8 = 8,		# Gamepad button 8.
	JOY_BUTTON_9 = 9,		# Gamepad button 9.
	JOY_BUTTON_10 = 10,		# Gamepad button 10.
	JOY_BUTTON_11 = 11,		# Gamepad button 11.
	JOY_BUTTON_12 = 12,		# Gamepad button 12.
	JOY_BUTTON_13 = 13,		# Gamepad button 13.
	JOY_BUTTON_14 = 14,		# Gamepad button 14.
	JOY_BUTTON_15 = 15,		# Gamepad button 15.
	JOY_BUTTON_16 = 16,		# Gamepad button 16.
	JOY_BUTTON_17 = 17,		# Gamepad button 17.
	JOY_BUTTON_18 = 18,		# Gamepad button 18.
	JOY_BUTTON_19 = 19,		# Gamepad button 19.
	JOY_BUTTON_20 = 20,		# Gamepad button 20.
	JOY_BUTTON_21 = 21,		# Gamepad button 21.
	JOY_BUTTON_22 = 22,		# Gamepad button 22.
	JOY_BUTTON_MAX = 128,		# The maximum number of game controller buttons supported by the engine. The actual limit may be lower on specific platforms.
	JOY_SONY_CIRCLE = 1,		# DualShock circle button.
	JOY_SONY_X = 0,		# DualShock X button.
	JOY_SONY_SQUARE = 2,		# DualShock square button.
	JOY_SONY_TRIANGLE = 3,		# DualShock triangle button.
	JOY_XBOX_B = 1,		# Xbox controller B button.
	JOY_XBOX_A = 0,		# Xbox controller A button.
	JOY_XBOX_X = 2,		# Xbox controller X button.
	JOY_XBOX_Y = 3,		# Xbox controller Y button.
	JOY_DS_A = 1,		# Nintendo controller A button.
	JOY_DS_B = 0,		# Nintendo controller B button.
	JOY_DS_X = 3,		# Nintendo controller X button.
	JOY_DS_Y = 2,		# Nintendo controller Y button.
	JOY_VR_GRIP = 2,		# Grip (side) buttons on a VR controller.
	JOY_VR_PAD = 14,		# Push down on the touchpad or main joystick on a VR controller.
	JOY_VR_TRIGGER = 15,		# Trigger on a VR controller.
	JOY_OCULUS_AX = 7,		# A button on the right Oculus Touch controller, X button on the left controller (also when used in OpenVR).
	JOY_OCULUS_BY = 1,		# B button on the right Oculus Touch controller, Y button on the left controller (also when used in OpenVR).
	JOY_OCULUS_MENU = 3,		# Menu button on either Oculus Touch controller.
	JOY_OPENVR_MENU = 1,		# Menu button in OpenVR (Except when Oculus Touch controllers are used).
	JOY_SELECT = 10,		# Gamepad button Select.
	JOY_START = 11,		# Gamepad button Start.
	JOY_DPAD_UP = 12,		# Gamepad DPad up.
	JOY_DPAD_DOWN = 13,		# Gamepad DPad down.
	JOY_DPAD_LEFT = 14,		# Gamepad DPad left.
	JOY_DPAD_RIGHT = 15,		# Gamepad DPad right.
	JOY_GUIDE = 16,		# Gamepad SDL guide button.
	JOY_MISC1 = 17,		# Gamepad SDL miscellaneous button.
	JOY_PADDLE1 = 18,		# Gamepad SDL paddle 1 button.
	JOY_PADDLE2 = 19,		# Gamepad SDL paddle 2 button.
	JOY_PADDLE3 = 20,		# Gamepad SDL paddle 3 button.
	JOY_PADDLE4 = 21,		# Gamepad SDL paddle 4 button.
	JOY_TOUCHPAD = 22,		# Gamepad SDL touchpad button.
	JOY_L = 4,		# Gamepad left Shoulder button.
	JOY_L2 = 6,		# Gamepad left trigger.
	JOY_L3 = 8,		# Gamepad left stick click.
	JOY_R = 5,		# Gamepad right Shoulder button.
	JOY_R2 = 7,		# Gamepad right trigger.
	JOY_R3 = 9,		# Gamepad right stick click.
	JOY_AXIS_0 = 0,		# Gamepad left stick horizontal axis.
	JOY_AXIS_1 = 1,		# Gamepad left stick vertical axis.
	JOY_AXIS_2 = 2,		# Gamepad right stick horizontal axis.
	JOY_AXIS_3 = 3,		# Gamepad right stick vertical axis.
	JOY_AXIS_4 = 4,		# Generic gamepad axis 4.
	JOY_AXIS_5 = 5,		# Generic gamepad axis 5.
	JOY_AXIS_6 = 6,		# Gamepad left trigger analog axis.
	JOY_AXIS_7 = 7,		# Gamepad right trigger analog axis.
	JOY_AXIS_8 = 8,		# Generic gamepad axis 8.
	JOY_AXIS_9 = 9,		# Generic gamepad axis 9.
	JOY_AXIS_MAX = 10,		# Represents the maximum number of joystick axes supported.
	JOY_ANALOG_LX = 0,		# Gamepad left stick horizontal axis.
	JOY_ANALOG_LY = 1,		# Gamepad left stick vertical axis.
	JOY_ANALOG_RX = 2,		# Gamepad right stick horizontal axis.
	JOY_ANALOG_RY = 3,		# Gamepad right stick vertical axis.
	JOY_ANALOG_L2 = 6,		# Gamepad left analog trigger.
	JOY_ANALOG_R2 = 7,		# Gamepad right analog trigger.
	JOY_VR_ANALOG_TRIGGER = 2,		# VR Controller analog trigger.
	JOY_VR_ANALOG_GRIP = 4,		# VR Controller analog grip (side buttons).
	JOY_OPENVR_TOUCHPADX = 0,		# OpenVR touchpad X axis (Joystick axis on Oculus Touch and Windows MR controllers).
	JOY_OPENVR_TOUCHPADY = 1,		# OpenVR touchpad Y axis (Joystick axis on Oculus Touch and Windows MR controllers).
}

enum MidiMessageList {
	MIDI_MESSAGE_NOTE_OFF = 8,		# MIDI note OFF message. See the documentation of InputEventMIDI for information of how to use MIDI inputs.
	MIDI_MESSAGE_NOTE_ON = 9,		# MIDI note ON message. See the documentation of InputEventMIDI for information of how to use MIDI inputs.
	MIDI_MESSAGE_AFTERTOUCH = 10,		# MIDI aftertouch message. This message is most often sent by pressing down on the key after it "bottoms out".
	MIDI_MESSAGE_CONTROL_CHANGE = 11,		# MIDI control change message. This message is sent when a controller value changes. Controllers include devices such as pedals and levers.
	MIDI_MESSAGE_PROGRAM_CHANGE = 12,		# MIDI program change message. This message sent when the program patch number changes.
	MIDI_MESSAGE_CHANNEL_PRESSURE = 13,		# MIDI channel pressure message. This message is most often sent by pressing down on the key after it "bottoms out". This message is different from polyphonic after-touch as it indicates the highest pressure across all keys.
	MIDI_MESSAGE_PITCH_BEND = 14,		# MIDI pitch bend message. This message is sent to indicate a change in the pitch bender (wheel or lever, typically).
	MIDI_MESSAGE_SYSTEM_EXCLUSIVE = 240,		# MIDI system exclusive message. This has behavior exclusive to the device you're receiving input from. Getting this data is not implemented in Godot.
	MIDI_MESSAGE_QUARTER_FRAME = 241,		# MIDI quarter frame message. Contains timing information that is used to synchronize MIDI devices. Getting this data is not implemented in Godot.
	MIDI_MESSAGE_SONG_POSITION_POINTER = 242,		# MIDI song position pointer message. Gives the number of 16th notes since the start of the song. Getting this data is not implemented in Godot.
	MIDI_MESSAGE_SONG_SELECT = 243,		# MIDI song select message. Specifies which sequence or song is to be played. Getting this data is not implemented in Godot.
	MIDI_MESSAGE_TUNE_REQUEST = 246,		# MIDI tune request message. Upon receiving a tune request, all analog synthesizers should tune their oscillators.
	MIDI_MESSAGE_TIMING_CLOCK = 248,		# MIDI timing clock message. Sent 24 times per quarter note when synchronization is required.
	MIDI_MESSAGE_START = 250,		# MIDI start message. Start the current sequence playing. This message will be followed with Timing Clocks.
	MIDI_MESSAGE_CONTINUE = 251,		# MIDI continue message. Continue at the point the sequence was stopped.
	MIDI_MESSAGE_STOP = 252,		# MIDI stop message. Stop the current sequence.
	MIDI_MESSAGE_ACTIVE_SENSING = 254,		# MIDI active sensing message. This message is intended to be sent repeatedly to tell the receiver that a connection is alive.
	MIDI_MESSAGE_SYSTEM_RESET = 255,		# MIDI system reset message. Reset all receivers in the system to power-up status. It should not be sent on power-up itself.
}

enum Error {
	OK = 0,		# Methods that return Error return OK when no error occurred. Note that many functions don't return an error code but will print error messages to standard output.
	FAILED = 1,		# Generic error.
	ERR_UNAVAILABLE = 2,		# Unavailable error.
	ERR_UNCONFIGURED = 3,		# Unconfigured error.
	ERR_UNAUTHORIZED = 4,		# Unauthorized error.
	ERR_PARAMETER_RANGE_ERROR = 5,		# Parameter range error.
	ERR_OUT_OF_MEMORY = 6,		# Out of memory (OOM) error.
	ERR_FILE_NOT_FOUND = 7,		# File { Not found error.
	ERR_FILE_BAD_DRIVE = 8,		# File { Bad drive error.
	ERR_FILE_BAD_PATH = 9,		# File { Bad path error.
	ERR_FILE_NO_PERMISSION = 10,		# File { No permission error.
	ERR_FILE_ALREADY_IN_USE = 11,		# File { Already in use error.
	ERR_FILE_CANT_OPEN = 12,		# File { Can't open error.
	ERR_FILE_CANT_WRITE = 13,		# File { Can't write error.
	ERR_FILE_CANT_READ = 14,		# File { Can't read error.
	ERR_FILE_UNRECOGNIZED = 15,		# File { Unrecognized error.
	ERR_FILE_CORRUPT = 16,		# File { Corrupt error.
	ERR_FILE_MISSING_DEPENDENCIES = 17,		# File { Missing dependencies error.
	ERR_FILE_EOF = 18,		# File { End of file (EOF) error.
	ERR_CANT_OPEN = 19,		# Can't open error.
	ERR_CANT_CREATE = 20,		# Can't create error.
	ERR_QUERY_FAILED = 21,		# Query failed error.
	ERR_ALREADY_IN_USE = 22,		# Already in use error.
	ERR_LOCKED = 23,		# Locked error.
	ERR_TIMEOUT = 24,		# Timeout error.
	ERR_CANT_CONNECT = 25,		# Can't connect error.
	ERR_CANT_RESOLVE = 26,		# Can't resolve error.
	ERR_CONNECTION_ERROR = 27,		# Connection error.
	ERR_CANT_ACQUIRE_RESOURCE = 28,		# Can't acquire resource error.
	ERR_CANT_FORK = 29,		# Can't fork process error.
	ERR_INVALID_DATA = 30,		# Invalid data error.
	ERR_INVALID_PARAMETER = 31,		# Invalid parameter error.
	ERR_ALREADY_EXISTS = 32,		# Already exists error.
	ERR_DOES_NOT_EXIST = 33,		# Does not exist error.
	ERR_DATABASE_CANT_READ = 34,		# Database { Read error.
	ERR_DATABASE_CANT_WRITE = 35,		# Database { Write error.
	ERR_COMPILATION_FAILED = 36,		# Compilation failed error.
	ERR_METHOD_NOT_FOUND = 37,		# Method not found error.
	ERR_LINK_FAILED = 38,		# Linking failed error.
	ERR_SCRIPT_FAILED = 39,		# Script failed error.
	ERR_CYCLIC_LINK = 40,		# Cycling link (import cycle) error.
	ERR_INVALID_DECLARATION = 41,		# Invalid declaration error.
	ERR_DUPLICATE_SYMBOL = 42,		# Duplicate symbol error.
	ERR_PARSE_ERROR = 43,		# Parse error.
	ERR_BUSY = 44,		# Busy error.
	ERR_SKIP = 45,		# Skip error.
	ERR_HELP = 46,		# Help error.
	ERR_BUG = 47,		# Bug error.
	ERR_PRINTER_ON_FIRE = 48,		# Printer on fire error. (This is an easter egg, no engine methods return this error code.)
}

enum PropertyHint {
	PROPERTY_HINT_NONE = 0,		# No hint for the edited property.
	PROPERTY_HINT_RANGE = 1,		# Hints that an integer or float property should be within a range specified via the hint string "min,max" or "min,max,step". The hint string can optionally include "or_greater" and/or "or_lesser" to allow manual input going respectively above the max or below the min values. Example { "-360,360,1,or_greater,or_lesser".
	PROPERTY_HINT_EXP_RANGE = 2,		# Hints that a float property should be within an exponential range specified via the hint string "min,max" or "min,max,step". The hint string can optionally include "or_greater" and/or "or_lesser" to allow manual input going respectively above the max or below the min values. Example { "0.01,100,0.01,or_greater".
	PROPERTY_HINT_ENUM = 3,		# Hints that an integer, float or string property is an enumerated value to pick in a list specified via a hint string.
	PROPERTY_HINT_EXP_EASING = 4,		# Hints that a float property should be edited via an exponential easing function. The hint string can include "attenuation" to flip the curve horizontally and/or "inout" to also include in/out easing.
	PROPERTY_HINT_LENGTH = 5,		# Deprecated hint, unused.
	PROPERTY_HINT_KEY_ACCEL = 7,		# Deprecated hint, unused.
	PROPERTY_HINT_FLAGS = 8,		# Hints that an integer property is a bitmask with named bit flags. For example, to allow toggling bits 0, 1, 2 and 4, the hint could be something like "Bit0,Bit1,Bit2,,Bit4".
	PROPERTY_HINT_LAYERS_2D_RENDER = 9,		# Hints that an integer property is a bitmask using the optionally named 2D render layers.
	PROPERTY_HINT_LAYERS_2D_PHYSICS = 10,		# Hints that an integer property is a bitmask using the optionally named 2D physics layers.
	PROPERTY_HINT_LAYERS_2D_NAVIGATION = 11,		# Hints that an integer property is a bitmask using the optionally named 2D navigation layers.
	PROPERTY_HINT_LAYERS_3D_RENDER = 12,		# Hints that an integer property is a bitmask using the optionally named 3D render layers.
	PROPERTY_HINT_LAYERS_3D_PHYSICS = 13,		# Hints that an integer property is a bitmask using the optionally named 3D physics layers.
	PROPERTY_HINT_LAYERS_3D_NAVIGATION = 14,		# Hints that an integer property is a bitmask using the optionally named 3D navigation layers.
	PROPERTY_HINT_FILE = 15,		# Hints that a string property is a path to a file. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards like "*.png,*.jpg".
	PROPERTY_HINT_DIR = 16,		# Hints that a string property is a path to a directory. Editing it will show a file dialog for picking the path.
	PROPERTY_HINT_GLOBAL_FILE = 17,		# Hints that a string property is an absolute path to a file outside the project folder. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards like "*.png,*.jpg".
	PROPERTY_HINT_GLOBAL_DIR = 18,		# Hints that a string property is an absolute path to a directory outside the project folder. Editing it will show a file dialog for picking the path.
	PROPERTY_HINT_RESOURCE_TYPE = 19,		# Hints that a property is an instance of a Resource-derived type, optionally specified via the hint string (e.g. "Texture"). Editing it will show a popup menu of valid resource types to instantiate.
	PROPERTY_HINT_MULTILINE_TEXT = 20,		# Hints that a string property is text with line breaks. Editing it will show a text input field where line breaks can be typed.
	PROPERTY_HINT_PLACEHOLDER_TEXT = 21,		# Hints that a string property should have a placeholder text visible on its input field, whenever the property is empty. The hint string is the placeholder text to use.
	PROPERTY_HINT_COLOR_NO_ALPHA = 22,		# Hints that a color property should be edited without changing its alpha component, i.e. only R, G and B channels are edited.
	PROPERTY_HINT_IMAGE_COMPRESS_LOSSY = 23,		# Hints that an image is compressed using lossy compression.
	PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS = 24,		# Hints that an image is compressed using lossless compression.
}

enum PropertyUsageFlags {
	PROPERTY_USAGE_STORAGE = 1,		# The property is serialized and saved in the scene file (default).
	PROPERTY_USAGE_EDITOR = 2,		# The property is shown in the editor inspector (default).
	PROPERTY_USAGE_NETWORK = 4,		# Deprecated usage flag, unused.
	PROPERTY_USAGE_EDITOR_HELPER = 8,		# Deprecated usage flag, unused.
	PROPERTY_USAGE_CHECKABLE = 16,		# The property can be checked in the editor inspector.
	PROPERTY_USAGE_CHECKED = 32,		# The property is checked in the editor inspector.
	PROPERTY_USAGE_INTERNATIONALIZED = 64,		# The property is a translatable string.
	PROPERTY_USAGE_GROUP = 128,		# Used to group properties together in the editor. See EditorInspector.
	PROPERTY_USAGE_CATEGORY = 256,		# Used to categorize properties together in the editor.
	PROPERTY_USAGE_NO_INSTANCE_STATE = 2048,		# The property does not save its state in PackedScene.
	PROPERTY_USAGE_RESTART_IF_CHANGED = 4096,		# Editing the property prompts the user for restarting the editor.
	PROPERTY_USAGE_SCRIPT_VARIABLE = 8192,		# The property is a script variable which should be serialized and saved in the scene file.
	PROPERTY_USAGE_DEFAULT = 7,		# Default usage (storage, editor and network).
	PROPERTY_USAGE_DEFAULT_INTL = 71,		# Default usage for translatable strings (storage, editor, network and internationalized).
	PROPERTY_USAGE_NOEDITOR = 5,		# Default usage but without showing the property in the editor (storage, network).
}

enum MethodFlags {
	METHOD_FLAG_NORMAL = 1,		# Flag for a normal method.
	METHOD_FLAG_EDITOR = 2,		# Flag for an editor method.
	METHOD_FLAG_NOSCRIPT = 4,		# Deprecated method flag, unused.
	METHOD_FLAG_CONST = 8,		# Flag for a constant method.
	METHOD_FLAG_REVERSE = 16,		# Deprecated method flag, unused.
	METHOD_FLAG_VIRTUAL = 32,		# Flag for a virtual method.
	METHOD_FLAG_FROM_SCRIPT = 64,		# Deprecated method flag, unused.
	METHOD_FLAG_VARARG = 128,
	METHOD_FLAGS_DEFAULT = 1,		# Default method flags.
}

enum Variant_Type {
	TYPE_NIL = 0,		# Variable is null.
	TYPE_BOOL = 1,		# Variable is of type bool.
	TYPE_INT = 2,		# Variable is of type int.
	TYPE_REAL = 3,		# Variable is of type float (real).
	TYPE_STRING = 4,		# Variable is of type String.
	TYPE_VECTOR2 = 5,		# Variable is of type Vector2.
	TYPE_RECT2 = 6,		# Variable is of type Rect2.
	TYPE_VECTOR3 = 7,		# Variable is of type Vector3.
	TYPE_TRANSFORM2D = 8,		# Variable is of type Transform2D.
	TYPE_PLANE = 9,		# Variable is of type Plane.
	TYPE_QUAT = 10,		# Variable is of type Quat.
	TYPE_AABB = 11,		# Variable is of type AABB.
	TYPE_BASIS = 12,		# Variable is of type Basis.
	TYPE_TRANSFORM = 13,		# Variable is of type Transform.
	TYPE_COLOR = 14,		# Variable is of type Color.
	TYPE_NODE_PATH = 15,		# Variable is of type NodePath.
	TYPE_RID = 16,		# Variable is of type RID.
	TYPE_OBJECT = 17,		# Variable is of type Object.
	TYPE_DICTIONARY = 18,		# Variable is of type Dictionary.
	TYPE_ARRAY = 19,		# Variable is of type Array.
	TYPE_RAW_ARRAY = 20,		# Variable is of type PoolByteArray.
	TYPE_INT_ARRAY = 21,		# Variable is of type PoolIntArray.
	TYPE_REAL_ARRAY = 22,		# Variable is of type PoolRealArray.
	TYPE_STRING_ARRAY = 23,		# Variable is of type PoolStringArray.
	TYPE_VECTOR2_ARRAY = 24,		# Variable is of type PoolVector2Array.
	TYPE_VECTOR3_ARRAY = 25,		# Variable is of type PoolVector3Array.
	TYPE_COLOR_ARRAY = 26,		# Variable is of type PoolColorArray.
	TYPE_MAX = 27,		# Represents the size of the Variant.Type enum.
}

enum Variant_Operator {
	OP_EQUAL = 0,		# Equality operator (==).
	OP_NOT_EQUAL = 1,		# Inequality operator (!=).
	OP_LESS = 2,		# Less than operator (<).
	OP_LESS_EQUAL = 3,		# Less than or equal operator (<=).
	OP_GREATER = 4,		# Greater than operator (>).
	OP_GREATER_EQUAL = 5,		# Greater than or equal operator (>=).
	OP_ADD = 6,		# Addition operator (+).
	OP_SUBTRACT = 7,		# Subtraction operator (-).
	OP_MULTIPLY = 8,		# Multiplication operator (*).
	OP_DIVIDE = 9,		# Division operator (/).
	OP_NEGATE = 10,		# Unary negation operator (-).
	OP_POSITIVE = 11,		# Unary plus operator (+).
	OP_MODULE = 12,		# Remainder/modulo operator (%).
	OP_STRING_CONCAT = 13,		# String concatenation operator (+).
	OP_SHIFT_LEFT = 14,		# Left shift operator (<<).
	OP_SHIFT_RIGHT = 15,		# Right shift operator (>>).
	OP_BIT_AND = 16,		# Bitwise AND operator (&).
	OP_BIT_OR = 17,		# Bitwise OR operator (|).
	OP_BIT_XOR = 18,		# Bitwise XOR operator (^).
	OP_BIT_NEGATE = 19,		# Bitwise NOT operator (~).
	OP_AND = 20,		# Logical AND operator (and or &&).
	OP_OR = 21,		# Logical OR operator (or or ||).
	OP_XOR = 22,		# Logical XOR operator (not implemented in GDScript).
	OP_NOT = 23,		# Logical NOT operator (not or !).
	OP_IN = 24,		# Logical IN operator (in).
	OP_MAX = 25,		# Represents the size of the Variant.Operator enum.
}

enum Constants {
	SPKEY = 16777216,		# Scancodes with this bit applied are non-printable.
}

enum ConnectionStatus {
	CONNECTION_DISCONNECTED = 0, # The ongoing connection disconnected.
	CONNECTION_CONNECTING = 1, # A connection attempt is ongoing.
	CONNECTION_CONNECTED = 2 # The connection attempt succeeded.
}

enum TransferMode {
	TRANSFER_MODE_UNRELIABLE = 0, # Packets are not acknowledged, no resend attempts are made for lost packets. Packets may arrive in any order. Potentially faster than TRANSFER_MODE_UNRELIABLE_ORDERED. Use for non-critical data, and always consider whether the order matters.
	TRANSFER_MODE_UNRELIABLE_ORDERED = 1, # Packets are not acknowledged, no resend attempts are made for lost packets. Packets are received in the order they were sent in. Potentially faster than TRANSFER_MODE_RELIABLE. Use for non-critical data or data that would be outdated if received late due to resend attempt(s) anyway, for example movement and positional data.
	TRANSFER_MODE_RELIABLE = 2 # Packets must be received and resend attempts should be made until the packets are acknowledged. Packets must be received in the order they were sent in. Most reliable transfer mode, but potentially the slowest due to the overhead. Use for critical data that must be transmitted and arrive in order, for example an ability being triggered or a chat message. Consider carefully if the information really is critical, and use sparingly.
}
