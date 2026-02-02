extends Node

var families_highscores = []
var families_data = {}
var current_family = null

func enumerate_families(): # this will REMOVE CACHED DATA from non-existing families!
	var f = IO.dir_contents(Assets.SAVES_PATH)
	
	families_data = {}
	for family_name in f.folders:
		families_data[family_name] = {}
	
	Log.generic(self, "enumerated: %s families found in the Save folder" % [families_data.size()])

# family scores chunk
func enscribe_highscore_chunk():
	Scribe.put("score", ScribeFormat.u32)
	Scribe.put("mission_idx", ScribeFormat.u32)
	Scribe.put("player_name", ScribeFormat.ascii, 32, "")
	Scribe.put("rating_culture", ScribeFormat.u32)
	Scribe.put("rating_prosperity", ScribeFormat.u32)
	Scribe.put("rating_kingdom", ScribeFormat.u32)
	Scribe.put("final_population", ScribeFormat.u32)
	Scribe.put("final_funds", ScribeFormat.u32)
	Scribe.put("completion_months", ScribeFormat.u32)
	Scribe.put("difficulty", ScribeFormat.u32)
	Scribe.put("unk09", ScribeFormat.u32)
	Scribe.put("unk10_nonempty", ScribeFormat.u32)
func enscribe_JAS():
	for i in range(100):
		Scribe.sync_record([families_highscores, i], TYPE_DICTIONARY)
		enscribe_highscore_chunk()
func enscribe_DAT(family_name):
	for i in range(100):											# unused(?) scenario data chunks
		Scribe.sync_record([families_data, family_name, "chunks", i], TYPE_DICTIONARY)
		Scribe.put("campaign_idx", ScribeFormat.i8)
		Scribe.put("campaign_idx_2", ScribeFormat.u8)
		Scribe.put("unk02", ScribeFormat.u16)
		Scribe.put("unk03", ScribeFormat.u32)

		Scribe.put("mission_n_200", ScribeFormat.i32)
		Scribe.put("mission_n_A", ScribeFormat.i32)
		Scribe.put("mission_n_B", ScribeFormat.i32)
		Scribe.put("mission_n_unk", ScribeFormat.i32)

		Scribe.put("unk08", ScribeFormat.i32)
		Scribe.put("unk09", ScribeFormat.i32)
		Scribe.put("unk10", ScribeFormat.u32)
		Scribe.put("unk11", ScribeFormat.u32)
		Scribe.put("unk12", ScribeFormat.i16)
		Scribe.put("unk13", ScribeFormat.u16)
		Scribe.put("unk14", ScribeFormat.u32)
		Scribe.put("unk15", ScribeFormat.u32)
		Scribe.put("unk16", ScribeFormat.i16)
		Scribe.put("unk17", ScribeFormat.u16)

		Scribe.put("unk18", ScribeFormat.u32)
		Scribe.put("mission_completed", ScribeFormat.u8)
		Scribe.put("unk19", ScribeFormat.u16)
		Scribe.put("unk20", ScribeFormat.u8)
	
	Scribe.sync_record([families_data, family_name], TYPE_DICTIONARY)
	Scribe.put("unk38", ScribeFormat.i32)							# number of fields for the Pharaoh main campaign? (38)

	Scribe.sync_record([families_data, family_name, "scenario_names"], TYPE_ARRAY)
	for i in range(100):
		Scribe.put(i, ScribeFormat.ascii, 50, "")					# map names

	Scribe.sync_record([families_data, family_name], TYPE_DICTIONARY)
	Scribe.put("unk35", ScribeFormat.i32)							# unknown 32-bit field (35)
	Scribe.put("raw_autosave_path", ScribeFormat.ascii, 64, "")		# path to last autosave_replay.sav file

	Scribe.put("unk00", ScribeFormat.i32)							# unknown 32-bit field (0)
	
	for i in range(100):
		Scribe.sync_record([families_data, family_name, "scenario_highscores", i], TYPE_DICTIONARY)
		enscribe_highscore_chunk()
		
	Scribe.sync_record([families_data, family_name, "unkarr12"], TYPE_ARRAY)
	for i in range(12):
		Scribe.put(i, ScribeFormat.i16)								# unknown twelve 2-byte fields?

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
