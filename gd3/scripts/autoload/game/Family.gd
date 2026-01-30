extends Node

var families_data = []

# highscore.jas
func JAS__scribe(path, to_disk):
	var t = Stopwatch.start()
	for i in range(100):
		if !(Assets.scribe_sync_chunk([families_data, i], TYPE_DICTIONARY)): return false
		if !(Assets.scribe_do("score", Scribe.u32)): return false
		if !(Assets.scribe_do("mission_idx", Scribe.u32)): return false
		if !(Assets.scribe_do("player_name", Scribe.ascii, 32, "")): return false
		if !(Assets.scribe_do("rating_culture", Scribe.u32)): return false
		if !(Assets.scribe_do("rating_prosperity", Scribe.u32)): return false
		if !(Assets.scribe_do("rating_kingdom", Scribe.u32)): return false
		if !(Assets.scribe_do("final_population", Scribe.u32)): return false
		if !(Assets.scribe_do("final_funds", Scribe.u32)): return false
		if !(Assets.scribe_do("completion_months", Scribe.u32)): return false
		if !(Assets.scribe_do("difficulty", Scribe.u32)): return false
		if !(Assets.scribe_do("unk09", Scribe.u32)): return false
		if !(Assets.scribe_do("unk10_nonempty", Scribe.u32)): return false
		print(families_data[i].player_name, ": ", families_data[i].score)
	Stopwatch.stop(t, "time taken:")
	return true
		
func JAS_save(path):
	if IO.file_exists(path):
		if !IO.copy_file(path, path + ".bak", true):
			return false
#	if Assets.scribe_open(File.READ_WRITE, path) == null: # no truncate, requires file to exist
	if Assets.scribe_open(File.WRITE, path) == null: # truncate, creates file if not exists
#	if Assets.scribe_open(File.WRITE_READ, path) == null: # truncate, creates file if not exists
		return false
	var r = JAS__scribe(path, true)
	Assets.scribe_close()
	return r
func JAS_load(path):
	if Assets.scribe_open(File.READ, path) == null:
		return false
	var r = JAS__scribe(path, false)
	Assets.scribe_close()
	return r
