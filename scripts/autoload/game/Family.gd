extends Node

var highscores = []
var data = {}
var current_family = null

func get_current_save_path():
	if current_family == null:
		return null
	return Assets.SAVES_PATH + "/" + current_family
func get_most_recent_family_save():
	return IO.find_most_recent_file(get_current_save_path(), ".sav")
func get_family_saves():
	if current_family == null:
		return null
	return IO.dir_contents(get_current_save_path(), ".sav").files

func enumerate_families(): # this will REMOVE CACHED DATA from non-existing families!
	var f = IO.dir_contents(Assets.SAVES_PATH)
	
	data = {}
	for family_name in f.folders:
		data[family_name] = {}
	
	Log.generic(self, "enumerated: %s families found in the Save folder" % [data.size()])

func has_beaten_any_mission(og = true): # in OG Pharaoh, the game simply checks if there's any savegame in the player folder
	if current_family == null:
		return false
	if og:
		var save_path = get_current_save_path()
		if IO.dir_exists(save_path):
			var savefiles = IO.dir_contents(save_path, ".sav").files
			return savefiles.size() != 0
	else:
		pass # TODO
	return false

# family scores chunk
func enscribe_highscore_chunk():
	Scribe.put(ScribeFormat.u32, "score")
	Scribe.put(ScribeFormat.u32, "mission_idx")
	Scribe.put(ScribeFormat.ascii, "player_name", 32, "")
	Scribe.put(ScribeFormat.u32, "rating_culture")
	Scribe.put(ScribeFormat.u32, "rating_prosperity")
	Scribe.put(ScribeFormat.u32, "rating_kingdom")
	Scribe.put(ScribeFormat.u32, "final_population")
	Scribe.put(ScribeFormat.u32, "final_funds")
	Scribe.put(ScribeFormat.u32, "completion_months")
	Scribe.put(ScribeFormat.u32, "difficulty")
	Scribe.put(ScribeFormat.u32, "unk09")
	Scribe.put(ScribeFormat.u32, "unk10_nonempty")
	Scribe.put(ScribeFormat.ascii, "player_name", 32, "")
func enscribe_JAS():
	for i in range(100):
		Scribe.sync_record([highscores, i], TYPE_DICTIONARY)
		enscribe_highscore_chunk()
func enscribe_DAT(family_name):
	for i in range(100):											# unused(?) scenario data chunks
		Scribe.sync_record([data, family_name, "chunks", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.i8, "campaign_idx")
		Scribe.put(ScribeFormat.u8, "campaign_idx_2")
		Scribe.put(ScribeFormat.u16, "unk02")
		Scribe.put(ScribeFormat.u32, "unk03")

		Scribe.put(ScribeFormat.i32, "mission_n_200")
		Scribe.put(ScribeFormat.i32, "mission_n_A")
		Scribe.put(ScribeFormat.i32, "mission_n_B")
		Scribe.put(ScribeFormat.i32, "mission_n_unk")

		Scribe.put(ScribeFormat.i32, "unk08")
		Scribe.put(ScribeFormat.i32, "unk09")
		Scribe.put(ScribeFormat.u32, "unk10")
		Scribe.put(ScribeFormat.u32, "unk11")
		Scribe.put(ScribeFormat.i16, "unk12")
		Scribe.put(ScribeFormat.u16, "unk13")
		Scribe.put(ScribeFormat.u32, "unk14")
		Scribe.put(ScribeFormat.u32, "unk15")
		Scribe.put(ScribeFormat.i16, "unk16")
		Scribe.put(ScribeFormat.u16, "unk17")

		Scribe.put(ScribeFormat.u32, "unk18")
		Scribe.put(ScribeFormat.u8, "mission_completed")
		Scribe.put(ScribeFormat.u16, "unk19")
		Scribe.put(ScribeFormat.u8, "unk20")
	
	Scribe.sync_record([data, family_name], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "unk38")							# number of fields for the Pharaoh main campaign? (38)

	Scribe.sync_record([data, family_name, "scenario_names"], TYPE_ARRAY)
	for i in range(100):
		Scribe.put(ScribeFormat.ascii, i, 50, "")					# map names

	Scribe.sync_record([data, family_name], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "unk35")							# unknown 32-bit field (35)
	Scribe.put(ScribeFormat.ascii, "raw_autosave_path", 64, "")		# path to last autosave_replay.sav file

	Scribe.put(ScribeFormat.i32, "unk00")							# unknown 32-bit field (0)
	
	for i in range(100):
		Scribe.sync_record([data, family_name, "scenario_highscores", i], TYPE_DICTIONARY)
		enscribe_highscore_chunk()
		
	Scribe.sync_record([data, family_name, "unkarr12"], TYPE_ARRAY)
	for i in range(12):
		Scribe.put(ScribeFormat.i16, i)								# unknown twelve 2-byte fields?

# highscore.jas
func JAS_load(path):
	return Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_JAS"))
func JAS_save(path):
	return Scribe.enscribe(path, File.WRITE, false, funcref(self, "enscribe_JAS"))

# player.dat
func DAT_load(path, family_name):
	return Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_DAT"), [family_name])
func DAT_save(path, family_name):
	return Scribe.enscribe(path, File.WRITE, false, funcref(self, "enscribe_DAT"), [family_name])
