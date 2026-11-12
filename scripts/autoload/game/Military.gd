extends Node

var working_towers = 0
var invasions_creation_sequence = 0
var campaign_company_rejoin = []

func enscribe_formations():
	Scribe.push_compressed(Figures.MAX_FORMATIONS * 144)
	Scribe.pop_compressed()
