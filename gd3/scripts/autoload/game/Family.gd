extends Node

var families_highscores = []
var families_data = {}

# family scores chunk
func enscribe_highscore_chunk():
	if !(Scribe.put("score", ScribeFormat.u32)): return false
	if !(Scribe.put("mission_idx", ScribeFormat.u32)): return false
	if !(Scribe.put("player_name", ScribeFormat.ascii, 32, "")): return false
	if !(Scribe.put("rating_culture", ScribeFormat.u32)): return false
	if !(Scribe.put("rating_prosperity", ScribeFormat.u32)): return false
	if !(Scribe.put("rating_kingdom", ScribeFormat.u32)): return false
	if !(Scribe.put("final_population", ScribeFormat.u32)): return false
	if !(Scribe.put("final_funds", ScribeFormat.u32)): return false
	if !(Scribe.put("completion_months", ScribeFormat.u32)): return false
	if !(Scribe.put("difficulty", ScribeFormat.u32)): return false
	if !(Scribe.put("unk09", ScribeFormat.u32)): return false
	if !(Scribe.put("unk10_nonempty", ScribeFormat.u32)): return false
	return true
func enscribe_JAS():
	for i in range(100):
		if !(Scribe.sync_record([families_highscores, i], TYPE_DICTIONARY)): return false
		if !enscribe_highscore_chunk(): return false
	return true
func enscribe_DAT(family_name):
	for i in range(100):
		if !(Scribe.sync_record([families_data, family_name, "chunks", i], TYPE_DICTIONARY)): return false
		if !(Scribe.put("campaign_idx", ScribeFormat.i8)): return false
		if !(Scribe.put("campaign_idx_2", ScribeFormat.u8)): return false
		if !(Scribe.put("unk02", ScribeFormat.u16)): return false
		if !(Scribe.put("unk03", ScribeFormat.u32)): return false

		if !(Scribe.put("mission_n_200", ScribeFormat.i32)): return false
		if !(Scribe.put("mission_n_A", ScribeFormat.i32)): return false
		if !(Scribe.put("mission_n_B", ScribeFormat.i32)): return false
		if !(Scribe.put("mission_n_unk", ScribeFormat.i32)): return false

		if !(Scribe.put("unk08", ScribeFormat.i32)): return false
		if !(Scribe.put("unk09", ScribeFormat.i32)): return false
		if !(Scribe.put("unk10", ScribeFormat.u32)): return false
		if !(Scribe.put("unk11", ScribeFormat.u32)): return false
		if !(Scribe.put("unk12", ScribeFormat.i16)): return false
		if !(Scribe.put("unk13", ScribeFormat.u16)): return false
		if !(Scribe.put("unk14", ScribeFormat.u32)): return false
		if !(Scribe.put("unk15", ScribeFormat.u32)): return false
		if !(Scribe.put("unk16", ScribeFormat.i16)): return false
		if !(Scribe.put("unk17", ScribeFormat.u16)): return false

		if !(Scribe.put("unk18", ScribeFormat.u32)): return false
		if !(Scribe.put("mission_completed", ScribeFormat.u8)): return false
		if !(Scribe.put("unk19", ScribeFormat.u16)): return false
		if !(Scribe.put("unk20", ScribeFormat.u8)): return false

	
	if !(Scribe.sync_record([families_data, family_name], TYPE_DICTIONARY)): return false
	if !(Scribe.put("unk38", ScribeFormat.i32)): return false # number of fields for the Pharaoh main campaign? (38)

	if !(Scribe.sync_record([families_data, family_name, "scenario_names"], TYPE_ARRAY)): return false
	for i in range(100):
		if !(Scribe.put(i, ScribeFormat.ascii, 50, "")): return false

	if !(Scribe.sync_record([families_data, family_name], TYPE_DICTIONARY)): return false
	if !(Scribe.put("unk35", ScribeFormat.i32)): return false # unknown 32-bit field (35)
	if !(Scribe.put("raw_autosave_path", ScribeFormat.ascii, 36, "")): return false # path to last autosave_replay.sav file

	if !(Scribe.put("unk00", ScribeFormat.i32)): return false # unknown 32-bit field (0)
	
	for i in range(100):
		if !(Scribe.sync_record([families_data, family_name, "scenario_highscores", i], TYPE_DICTIONARY)): return false
		if !enscribe_highscore_chunk(): return false
	return true

# highscore.jas
func JAS_load(path):
	return Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_JAS"))
func JAS_save(path):
	return Scribe.enscribe(path, File.WRITE, false, funcref(self, "enscribe_JAS"))

# player.dat
func DAT_load(path, family_name):
	return Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_DAT"), [family_name])
