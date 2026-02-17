extends Node

const MAX_EVENTS = 150

var city_faction = 0
var unused_faction_flags1 = 0
var unused_faction_flags2 = 0

#var info = {}
var starting_year = 0
var max_year = 0
var unkn_00 = 0
var empire_id = 0
var unkn_01 = 0
var initial_funds = 0
var enemy_id = 0

var scenario_subtitle = ""
var scenario_brief_description = ""
var scenario_icon = 0
var is_open_play = false
var initial_player_rank = 0

var objectives = {
	"ratings": []
}
var time_until_failure_enabled = false
var time_until_failure = 0
var time_until_victory_enabled = false
var time_until_victory = 0
var population_goal_enabled = false
var population_goal = 0

var climate_type = 0
var monuments_era = 0
var player_tribe_faction = 0
var debt_interest_rate = 0
#var available_monument_1 = 0
#var available_monument_2 = 0
#var available_monument_3 = 0
var current_pharaoh = 0
var player_incarnation = 0

var is_campaign_mission_first = 0
var is_campaign_mission_first_four = 0
var scenario_is_custom = false
var scenario_map_name = ""
var mission_play_type = 0
var difficulty = 0


var starting_kingdom = 0
var starting_savings = 0
var starting_rank = 0


var unk_fields = []
var events = []
var events_extra = {}

var tutorial_flags_1 = []
var tutorial_flags_2 = []
