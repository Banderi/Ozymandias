extends Node

var routing_debug = 0

func enscribe_routes():
	Scribe.push_compressed(Figures.MAX_ROUTES * 2) # <---------------------------------- TODO
#	for i in Figures.MAX_ROUTES:
#		Scribe.sync_record([Figures.routes, i], TYPE_DICTIONARY)
#		pass
	Scribe.pop_compressed()
func enscribe_cached_stuff():
	Scribe.push_compressed(500000) # route paths cached data <-------------------- TODO
	Scribe.pop_compressed()
