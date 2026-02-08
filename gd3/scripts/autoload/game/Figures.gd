extends Node

const MAX_FIGURES = 2000
const MAX_ROUTES = 1000
const MAX_FORMATIONS = 50
const MAX_TRADERS = 100
const MAX_FERRIES = 50
const MAX_FIGURES_PER_FERRY = 11
const MAX_FIGURES_WAITING_PER_FERRY = 56

var figures = []
var figure_names_1 = []
var figure_names_2 = []
var figure_names_3 = []
var figure_sequence = 0
var figure_traders = []
var next_free_trader_index = 0

# formations
var formations = []
var last_used_formation
var last_formation_id
var total_formations

# ferries
var ferry_queues = []
var ferry_transiting = []
