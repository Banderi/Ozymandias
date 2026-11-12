extends Node

const RESOURCES_MAX = 36
const RESOURCES_FOODS_MAX = 9
const MAX_GODS = 5

var player_name1 = ""
var player_name2 = ""
var city_graph_order = 0

var bailout_money_received = false
var pop_milestone_25 = false
var pop_milestone_50 = false
var pop_milestone_75 = false

var industry_buildings_total = []
var industry_buildings_active = []

var tax_percentage = 0
var finance_treasury = 0
var sentiment = 0
var health_target = 0
var health = 0
var health_workers = 0

var population = 0
var pop_last_year = 0
var pop_school_age = 0
var pop_academy_age = 0
var pop_total_capacity = 0
var pop_room_in_houses = 0
var pop_monthly = []
var pop_monthly_next_index = 0
var pop_monthly_count = 0
var pop_by_age = []
var pop_by_level = []
var pop_yearly_births = 0
var pop_yearly_deaths = 0
var pop_lost_removal = 0

var _TEMP_UNSORTED_ATA = {}

func enscribe():
	Scribe.push_compressed(37808)
	var _t = Stopwatch.start()
	
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "tax_percentage")
	Scribe.put(ScribeFormat.i32, "finance_treasury")
	Scribe.put(ScribeFormat.i32, "sentiment")
	Scribe.put(ScribeFormat.i32, "health_target")
	Scribe.put(ScribeFormat.i32, "health")
	Scribe.put(ScribeFormat.i32, "health_workers")
	Scribe.skip(4)
	Scribe.put(ScribeFormat.i32, "population")
	Scribe.put(ScribeFormat.i32, "pop_last_year")
	Scribe.put(ScribeFormat.i32, "pop_school_age")
	Scribe.put(ScribeFormat.i32, "pop_academy_age")
	Scribe.put(ScribeFormat.i32, "pop_total_capacity")
	Scribe.put(ScribeFormat.i32, "pop_room_in_houses")
	Scribe.sync_record([City, "pop_monthly"], TYPE_ARRAY)
	for i in 2400:
		Scribe.put(ScribeFormat.i32, i)
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "pop_monthly_next_index")
	Scribe.put(ScribeFormat.i32, "pop_monthly_count")
	Scribe.sync_record([City, "pop_by_age"], TYPE_ARRAY)
	for i in 100:
		Scribe.put(ScribeFormat.i16, i)
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.sync_record([City, "pop_by_level"], TYPE_ARRAY)
	for i in 20:
		Scribe.put(ScribeFormat.i32, i)
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "pop_yearly_births")
	Scribe.put(ScribeFormat.i32, "pop_yearly_deaths")
	Scribe.put(ScribeFormat.i32, "pop_lost_removal")
	Scribe.put(ScribeFormat.i32, "immigration_amount_per_batch")
	Scribe.put(ScribeFormat.i32, "emigration_amount_per_batch")
	Scribe.put(ScribeFormat.i32, "emigration_queue_size")
	Scribe.put(ScribeFormat.i32, "immigration_queue_size")
	Scribe.put(ScribeFormat.i32, "pop_lost_homeless")
	Scribe.put(ScribeFormat.i32, "pop_last_change")
	Scribe.put(ScribeFormat.i32, "pop_average_per_year")
	Scribe.put(ScribeFormat.i32, "pop_total_all_years")
	Scribe.put(ScribeFormat.i32, "pop_in_shacks")
	Scribe.put(ScribeFormat.i32, "pop_in_villas")
	Scribe.put(ScribeFormat.i32, "pop_total_years")
	Scribe.put(ScribeFormat.i32, "pop_yearly_update_requested")
	Scribe.put(ScribeFormat.i32, "pop_last_used_house_add")
	Scribe.put(ScribeFormat.i32, "pop_last_used_house_remove")
	Scribe.put(ScribeFormat.i32, "immigration_total_today")
	Scribe.put(ScribeFormat.i32, "emigration_total_today")
	Scribe.put(ScribeFormat.i32, "immigration_refused_today")
	Scribe.put(ScribeFormat.i32, "migration_percentage")
	Scribe.skip(4)
	
	
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "migration.immigration_duration")
	Scribe.put(ScribeFormat.i32, "migration.emigration_duration")
	Scribe.put(ScribeFormat.i32, "migration.newcomers")
#	Scribe.sync_record([_TEMP_UNSORTED_ATA, "unused.unknown_27e0"], TYPE_ARRAY)
#	for i in 4:
#		Scribe.put(ScribeFormat.i32, i)
#	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.skip(16)
	Scribe.put(ScribeFormat.i16, "unused.unknown_27f0")
	Scribe.put(ScribeFormat.i16, "resource.last_used_warehouse")
#	Scribe.sync_record([_TEMP_UNSORTED_ATA, "unused.unknown_27e0"], TYPE_ARRAY)
#	for i in 18:
#		Scribe.put(ScribeFormat.i16, i)
#	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.skip(16)
	Scribe.put(ScribeFormat.u16, "map.entry_point.private_access(_X)")
	Scribe.put(ScribeFormat.u16, "map.entry_point.private_access(_Y)")
	Scribe.put(ScribeFormat.i32, "map.entry_point.private_access(_GRID_OFFSET)")
	Scribe.put(ScribeFormat.u16, "map.exit_point.private_access(_X)")
	Scribe.put(ScribeFormat.u16, "map.exit_point.private_access(_Y)")
	Scribe.put(ScribeFormat.i32, "map.exit_point.private_access(_GRID_OFFSET)")
	Scribe.put(ScribeFormat.u16, "building.senate.private_access(_X)")
	Scribe.put(ScribeFormat.u16, "building.senate.private_access(_Y)")
	Scribe.put(ScribeFormat.i32, "building.senate.private_access(_GRID_OFFSET)")
	Scribe.put(ScribeFormat.i32, "building.senate_building_id")
	Scribe.put(ScribeFormat.i16, "unused.unknown_2828")
	Scribe.skip(2)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.space_in_warehouses"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.stored_in_warehouses"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.trade_status"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.trading_amount"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.mothballed"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i16, "unused.unused_28ca")

#    Scribe.skip(20)
#    for i in RESOURCES_MAX:
#        Scribe.put(ScribeFormat.i16, "resource.unk_00[i + 1]")
#    for i in RESOURCES_FOODS_MAX:
#        Scribe.put(ScribeFormat.i16, "resource.granary_food_stored[i]")
#    Scribe.skip(28) # temp


	Scribe.skip(20)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.unk_00"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i16, i)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.granary_food_stored"], TYPE_ARRAY)
	for i in RESOURCES_FOODS_MAX:
		Scribe.put(ScribeFormat.i16, i)
	Scribe.skip(28) # temp

	var food_index = 0
#	for i in 4: # reset available foods quick array
#		city_data.resource.food_types_allowed[i] = 0;
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.food_types_available_arr"], TYPE_ARRAY)
	for i in RESOURCES_FOODS_MAX:
		Scribe.put(ScribeFormat.u8, i)
#		if (city_data.resource.food_types_available_arr[i]):
#			city_data.resource.food_types_allowed[food_index] = i
#			food_index += 1
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.food_types_eaten_arr"], TYPE_ARRAY)
	for i in RESOURCES_FOODS_MAX:
		Scribe.put(ScribeFormat.u8, i)

	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.food_types_arr_unk_00"], TYPE_ARRAY)
	for i in RESOURCES_FOODS_MAX:
		Scribe.put(ScribeFormat.u8, i)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.food_types_arr_unk_01"], TYPE_ARRAY)
	for i in RESOURCES_FOODS_MAX:
		Scribe.put(ScribeFormat.u8, i)

	Scribe.skip(216)

	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.stockpiled"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i32, i)

#	# TODO: TEMP!!!!
#	city_data.resource.food_types_available_num = 0;
#	city_data.resource.food_types_eaten_num = 0;

	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "resource.food_supply_months")
	Scribe.put(ScribeFormat.i32, "resource.granaries.operating")
	Scribe.put(ScribeFormat.i32, "population.percentage_plebs")
	Scribe.put(ScribeFormat.i32, "population.working_age")
	Scribe.put(ScribeFormat.i32, "labor.workers_available")
	for i in 10:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "labor.categories", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.i32, "workers_needed")
		Scribe.put(ScribeFormat.i32, "workers_allocated")
		Scribe.put(ScribeFormat.i32, "total_houses_covered")
		Scribe.put(ScribeFormat.i32, "buildings")
		Scribe.put(ScribeFormat.i32, "priority")
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "labor.workers_employed")
	Scribe.put(ScribeFormat.i32, "labor.workers_unemployed")
	Scribe.put(ScribeFormat.i32, "labor.unemployment_percentage")
	Scribe.put(ScribeFormat.i32, "labor.unemployment_percentage_for_senate")
	Scribe.put(ScribeFormat.i32, "labor.workers_needed")
	Scribe.put(ScribeFormat.i32, "labor.wages")
	Scribe.put(ScribeFormat.i32, "labor.wages_rome")
	Scribe.put(ScribeFormat.i32, "unused.unknown_2b6c")
	Scribe.put(ScribeFormat.i32, "finance.wages_so_far")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.wages")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.wages")
	Scribe.put(ScribeFormat.i32, "taxes.taxed_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.taxed_patricians")
	Scribe.put(ScribeFormat.i32, "taxes.untaxed_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.untaxed_patricians")
	Scribe.put(ScribeFormat.i32, "taxes.percentage_taxed_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.percentage_taxed_patricians")
	Scribe.put(ScribeFormat.i32, "taxes.percentage_taxed_people")
	Scribe.put(ScribeFormat.i32, "taxes.yearly.collected_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.yearly.collected_patricians")
	Scribe.put(ScribeFormat.i32, "taxes.yearly.uncollected_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.yearly.uncollected_patricians")
	Scribe.put(ScribeFormat.i32, "finance.this_year.income.taxes")
	Scribe.put(ScribeFormat.i32, "finance.last_year.income.taxes")
	Scribe.put(ScribeFormat.i32, "taxes.monthly.collected_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.monthly.uncollected_plebs")
	Scribe.put(ScribeFormat.i32, "taxes.monthly.collected_patricians")
	Scribe.put(ScribeFormat.i32, "taxes.monthly.uncollected_patricians")
	Scribe.put(ScribeFormat.i32, "finance.this_year.income.exports")
	Scribe.put(ScribeFormat.i32, "finance.last_year.income.exports")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.imports")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.imports")
	Scribe.put(ScribeFormat.i32, "finance.interest_so_far")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.interest")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.interest")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.stolen")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.stolen")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.construction")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.construction")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.salary")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.salary")
	Scribe.put(ScribeFormat.i32, "emperor.salary_amount")
	Scribe.put(ScribeFormat.i32, "emperor.salary_rank")
	Scribe.put(ScribeFormat.i32, "finance.salary_so_far")
	Scribe.put(ScribeFormat.i32, "finance.last_year.income.total")
	Scribe.put(ScribeFormat.i32, "finance.this_year.income.total")
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.total")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.total")
	Scribe.put(ScribeFormat.i32, "finance.last_year.net_in_out")
	Scribe.put(ScribeFormat.i32, "finance.this_year.net_in_out")
	Scribe.put(ScribeFormat.i32, "finance.last_year.balance")
	Scribe.put(ScribeFormat.i32, "finance.this_year.balance")
#	for i in 1400:
#		Scribe.put(ScribeFormat.i32, "unused.unknown_2c20[i]")
	Scribe.skip(1400 * 4)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "unused.houses_requiring_unknown_to_evolve"], TYPE_ARRAY)
	for i in 8:
		Scribe.put(ScribeFormat.i32, i)
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "trade.caravan_import_resource")
	Scribe.put(ScribeFormat.i32, "trade.caravan_backup_import_resource")
	Scribe.put(ScribeFormat.i32, "ratings.culture")
	Scribe.put(ScribeFormat.i32, "ratings.prosperity")
	Scribe.put(ScribeFormat.i32, "ratings.monument")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom")
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "ratings.prosperity_treasury_last_year")
	Scribe.put(ScribeFormat.i32, "ratings.culture_points.theater")
	Scribe.put(ScribeFormat.i32, "ratings.culture_points.religion")
	Scribe.put(ScribeFormat.i32, "ratings.culture_points.school")
	Scribe.put(ScribeFormat.i32, "ratings.culture_points.library")
	Scribe.put(ScribeFormat.i32, "ratings.culture_points.academy")
	Scribe.put(ScribeFormat.i32, "ratings.monument_num_criminals")
	Scribe.put(ScribeFormat.i32, "ratings.monument_num_rioters")
	Scribe.put(ScribeFormat.i32, "houses.missing.fountain")
	Scribe.put(ScribeFormat.i32, "houses.missing.well")
	Scribe.put(ScribeFormat.i32, "houses.missing.more_entertainment")
	Scribe.put(ScribeFormat.i32, "houses.missing.more_education")
	Scribe.put(ScribeFormat.i32, "houses.missing.education")
	Scribe.put(ScribeFormat.i32, "houses.requiring.school")
	Scribe.put(ScribeFormat.i32, "houses.requiring.library")
	Scribe.put(ScribeFormat.i32, "unused.unknown_4284")
	Scribe.put(ScribeFormat.i32, "houses.missing.barber")
	Scribe.put(ScribeFormat.i32, "houses.missing.bathhouse")
	Scribe.put(ScribeFormat.i32, "houses.missing.food")
#	for i in 2:
#		Scribe.put(ScribeFormat.i32, "unused.unknown_4294[i]")
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "building.hippodrome_placed")
	Scribe.put(ScribeFormat.i32, "houses.missing.clinic")
	Scribe.put(ScribeFormat.i32, "houses.missing.hospital")
	Scribe.put(ScribeFormat.i32, "houses.requiring.barber")
	Scribe.put(ScribeFormat.i32, "houses.requiring.bathhouse")
	Scribe.put(ScribeFormat.i32, "houses.requiring.clinic")
	Scribe.put(ScribeFormat.i32, "houses.missing.religion")
	Scribe.put(ScribeFormat.i32, "houses.missing.second_religion")
	Scribe.put(ScribeFormat.i32, "houses.missing.third_religion")
	Scribe.put(ScribeFormat.i32, "houses.requiring.religion")
	Scribe.put(ScribeFormat.i32, "entertainment.theater_shows")
	Scribe.put(ScribeFormat.i32, "entertainment.theater_no_shows_weighted")
	Scribe.put(ScribeFormat.i32, "entertainment.amphitheater_shows")
	Scribe.put(ScribeFormat.i32, "entertainment.amphitheater_no_shows_weighted")
	Scribe.put(ScribeFormat.i32, "entertainment.colosseum_shows")
	Scribe.put(ScribeFormat.i32, "entertainment.colosseum_no_shows_weighted")
	Scribe.put(ScribeFormat.i32, "entertainment.hippodrome_shows")
	Scribe.put(ScribeFormat.i32, "entertainment.hippodrome_no_shows_weighted")
	Scribe.put(ScribeFormat.i32, "entertainment.venue_needing_shows")
	Scribe.put(ScribeFormat.i32, "culture.average_entertainment")
	Scribe.put(ScribeFormat.i32, "houses.missing.entertainment")
	Scribe.put(ScribeFormat.i32, "festival.months_since_festival") # ok
	for i in MAX_GODS:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "religion.gods", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u8, "target_mood")
	Scribe.skip(5)
	for i in MAX_GODS:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "religion.gods", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u8, "mood")
	Scribe.skip(5)
	for i in MAX_GODS:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "religion.gods", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u8, "wrath_bolts")
	Scribe.skip(5)
	Scribe.skip(15)
	Scribe.skip(35)
#    for i in MAX_GODS:
#        city_data.religion.gods[i].unused1 = main->read_i8();
#    for i in MAX_GODS:
#        city_data.religion.gods[i].unused2 = main->read_i8();
#    for i in MAX_GODS:
#        city_data.religion.gods[i].unused3 = main->read_i8();
	for i in MAX_GODS:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "religion.gods", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u32, "months_since_festival")
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "religion.least_happy_god")
	Scribe.put(ScribeFormat.i32, "unused.unknown_4334")
	Scribe.put(ScribeFormat.i32, "migration.no_immigration_cause")
	Scribe.put(ScribeFormat.i32, "sentiment.protesters")
	Scribe.put(ScribeFormat.i32, "sentiment.criminals")
	Scribe.put(ScribeFormat.i32, "houses.health")
	Scribe.put(ScribeFormat.i32, "houses.religion")
	Scribe.put(ScribeFormat.i32, "houses.education")
	Scribe.put(ScribeFormat.i32, "houses.entertainment")
	Scribe.put(ScribeFormat.i32, "figure.rioters")
	Scribe.skip(20)
	Scribe.put(ScribeFormat.i32, "ratings.selected")
	Scribe.put(ScribeFormat.i32, "ratings.culture_explanation")
	Scribe.put(ScribeFormat.i32, "ratings.prosperity_explanation")
	Scribe.put(ScribeFormat.i32, "ratings.monument_explanation")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_explanation")
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "emperor.player_rank")
	Scribe.put(ScribeFormat.i32, "emperor.personal_savings") # ok
#    for i in 2:
#        Scribe.put(ScribeFormat.i32, "unused.unknown_4374[i]")
#    Scribe.put(ScribeFormat.i32, "finance.last_year.income.donated")
#    Scribe.put(ScribeFormat.i32, "finance.this_year.income.donated")
#        for i in 2:
#            Scribe.put(ScribeFormat.i32, "unused.unknown_4374[i]")
	Scribe.put(ScribeFormat.i32, "finance.last_year.income.donated")
	Scribe.put(ScribeFormat.i32, "finance.this_year.income.donated")
#	for i in 2:
#		Scribe.put(ScribeFormat.i32, "unused.unknown_4374[i]")
	Scribe.skip(8)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "building.working_dock_ids"], TYPE_ARRAY)
	for i in 10:
		Scribe.put(ScribeFormat.i16, i)
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i16, "building.temple_complex_placed")
	Scribe.put(ScribeFormat.i16, "figure.animals")
#	for i in 3:
#		Scribe.put(ScribeFormat.i16, "unused.unknown_439c[i]")
	Scribe.skip(6)
	Scribe.skip(2)
	Scribe.skip(2)
	Scribe.put(ScribeFormat.i16, "building.senate_placed")
	Scribe.skip(2)
	Scribe.skip(2)
	Scribe.skip(2)
	Scribe.skip(2)
	Scribe.skip(2)
#        Scribe.put(ScribeFormat.i16, "trade.num_sea_routes")
#        Scribe.put(ScribeFormat.i16, "trade.num_land_routes")
#        Scribe.put(ScribeFormat.i16, "trade.sea_trade_problem_duration")
#        Scribe.put(ScribeFormat.i16, "trade.land_trade_problem_duration")
#        Scribe.put(ScribeFormat.i16, "building.working_docks")
#        Scribe.put(ScribeFormat.i16, "building.senate_placed")
#        Scribe.put(ScribeFormat.i16, "building.working_wharfs")

#	for i in 2:
#		Scribe.put(ScribeFormat.i8, "unused.padding_43b2[i]")
	Scribe.skip(2)
	Scribe.put(ScribeFormat.i16, "finance.stolen_this_year")
	Scribe.put(ScribeFormat.i16, "finance.stolen_last_year")
	Scribe.put(ScribeFormat.i32, "trade.docker_import_resource")
	Scribe.put(ScribeFormat.i32, "trade.docker_export_resource")
	Scribe.put(ScribeFormat.i32, "emperor.debt_state")
	Scribe.put(ScribeFormat.i32, "emperor.months_in_debt")
	Scribe.put(ScribeFormat.i32, "finance.cheated_money")
	Scribe.put(ScribeFormat.i8, "building.barracks.private_access(_X)")
	Scribe.put(ScribeFormat.i8, "building.barracks.private_access(_Y)")
	Scribe.put(ScribeFormat.i16, "building.barracks.private_access(_GRID_OFFSET)")
	Scribe.put(ScribeFormat.i32, "building.barracks_building_id")
	Scribe.put(ScribeFormat.i32, "building.barracks_placed")
#	for i in 5:
#		Scribe.put(ScribeFormat.i32, "unused.unknown_43d8[i]")
	Scribe.skip(10)
	Scribe.put(ScribeFormat.i32, "population.lost_troop_request")
	Scribe.put(ScribeFormat.i32, "unused.unknown_43f0")
	Scribe.put(ScribeFormat.i32, "mission.has_won")
	Scribe.put(ScribeFormat.i32, "mission.continue_months_left")
	Scribe.put(ScribeFormat.i32, "mission.continue_months_chosen") # wrong? hmm... 300 became 120? is it the wages?
	Scribe.put(ScribeFormat.i32, "finance.wage_rate_paid_this_year")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.tribute") # ok
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.tribute")
	Scribe.put(ScribeFormat.i32, "finance.tribute_not_paid_last_year")
	Scribe.put(ScribeFormat.i32, "festival.selected.god")
	Scribe.put(ScribeFormat.i32, "festival.selected.size") # ????
	Scribe.put(ScribeFormat.i32, "festival.planned.size")
	Scribe.put(ScribeFormat.i32, "festival.planned.months_to_go")
	Scribe.put(ScribeFormat.i32, "festival.planned.god")
	Scribe.put(ScribeFormat.i32, "festival.small_cost") # 23 --> 22 ??????
	Scribe.put(ScribeFormat.i32, "festival.large_cost") # 46 --> 45
	Scribe.put(ScribeFormat.i32, "festival.grand_cost") # 93 --> 90
	Scribe.put(ScribeFormat.i32, "festival.grand_alcohol")
	Scribe.put(ScribeFormat.i32, "festival.not_enough_alcohol")
	Scribe.put(ScribeFormat.i32, "culture.average_religion")
	Scribe.put(ScribeFormat.i32, "culture.average_education")
	Scribe.put(ScribeFormat.i32, "culture.average_health")
	Scribe.put(ScribeFormat.i32, "culture.religion_coverage")
	Scribe.put(ScribeFormat.i32, "festival.first_festival_effect_months")
	Scribe.put(ScribeFormat.i32, "festival.second_festival_effect_months")
	Scribe.put(ScribeFormat.i32, "unused.unused_4454")
	Scribe.put(ScribeFormat.i32, "sentiment.unemployment")
	Scribe.put(ScribeFormat.i32, "sentiment.previous_value") # ok
	Scribe.put(ScribeFormat.i32, "sentiment.message_delay")
	Scribe.put(ScribeFormat.i32, "sentiment.low_mood_cause")
	Scribe.put(ScribeFormat.i32, "figure.security_breach_duration")
#	for i in 4:
#		Scribe.put(ScribeFormat.i32, "unused.unknown_446c[i]")
	Scribe.skip(16)
	Scribe.put(ScribeFormat.i32, "emperor.selected_gift_size")
	Scribe.put(ScribeFormat.i32, "emperor.months_since_gift") # ok
	Scribe.put(ScribeFormat.i32, "emperor.gift_overdose_penalty")
	Scribe.put(ScribeFormat.i32, "unused.unused_4488")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_MODEST].id")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_GENEROUS].id")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_LAVISH].id")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_MODEST].cost")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_GENEROUS].cost")
	Scribe.put(ScribeFormat.i32, "emperor.gifts[GIFT_LAVISH].cost")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_salary_penalty")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_milestone_penalty")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_ignored_request_penalty")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_last_year")
	Scribe.put(ScribeFormat.i32, "ratings.kingdom_change")
	Scribe.put(ScribeFormat.i32, "military.native_attack_duration")
	Scribe.put(ScribeFormat.i32, "unused.unused_native_force_attack")
	Scribe.put(ScribeFormat.i32, "building.mission_post_operational")
	Scribe.put(ScribeFormat.i32, "building.main_native_meeting.private_access(_X)")
	Scribe.put(ScribeFormat.i32, "building.main_native_meeting.private_access(_Y)")
	Scribe.put(ScribeFormat.i32, "finance.wage_rate_paid_last_year")
	Scribe.put(ScribeFormat.i32, "resource.food_needed_per_month") # 62
	Scribe.put(ScribeFormat.i32, "resource.granaries.understaffed")
	Scribe.put(ScribeFormat.i32, "resource.granaries.not_operating")
	Scribe.put(ScribeFormat.i32, "resource.granaries.not_operating_with_food")
#	for i in 2:
#		Scribe.put(ScribeFormat.i32, "unused.unused_44e0[i]")
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "religion.venus_curse_active")
	Scribe.put(ScribeFormat.i32, "unused.unused_44ec")
	Scribe.put(ScribeFormat.i32, "religion.ra_150_export_profits_months_left")
	Scribe.put(ScribeFormat.i32, "religion.seth_crush_enemy_troops")
#	city_data.religion.osiris_double_farm_yield = false; # todo
	Scribe.put(ScribeFormat.i32, "unused.unused_44f8")
	Scribe.put(ScribeFormat.i32, "religion.angry_message_delay")
	Scribe.put(ScribeFormat.i32, "resource.food_consumed_last_month")
	Scribe.put(ScribeFormat.i32, "resource.food_produced_last_month")
	Scribe.put(ScribeFormat.i32, "resource.food_produced_this_month")
	Scribe.put(ScribeFormat.i32, "ratings.monument_riot_cause")
	Scribe.put(ScribeFormat.i32, "finance.estimated_tax_income")
	Scribe.put(ScribeFormat.i32, "mission.tutorial_senate_built") # ok
	Scribe.put(ScribeFormat.i8, "building.distribution_center.private_access(_X)")
	Scribe.put(ScribeFormat.i8, "building.distribution_center.private_access(_Y)")
	Scribe.put(ScribeFormat.i16, "building.distribution_center.private_access(_GRID_OFFSET)")
	Scribe.put(ScribeFormat.i32, "building.distribution_center_building_id")
	Scribe.put(ScribeFormat.i32, "building.distribution_center_placed")
#	for i in 11:
#		Scribe.put(ScribeFormat.i32, "unused.unused_4524[i]")
	Scribe.skip(44)
	Scribe.put(ScribeFormat.i32, "building.shipyard_boats_requested")
	Scribe.put(ScribeFormat.i32, "figure.enemies")
	Scribe.put(ScribeFormat.i32, "sentiment.wages")
	Scribe.put(ScribeFormat.i32, "population.people_in_tents")
	Scribe.put(ScribeFormat.i32, "population.people_in_large_insula_and_above")
	Scribe.put(ScribeFormat.i32, "figure.imperial_soldiers")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.duration_day_countdown")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.warnings_given")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.days_until_invasion")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.retreat_message_shown")
	Scribe.put(ScribeFormat.i32, "ratings.monument_destroyed_buildings")
	Scribe.put(ScribeFormat.i32, "ratings.monument_years_of_monument")
	Scribe.put(ScribeFormat.u8, "distant_battle.city")
	Scribe.put(ScribeFormat.u8, "distant_battle.enemy_strength")
	Scribe.put(ScribeFormat.u8, "distant_battle.roman_strength")
	Scribe.put(ScribeFormat.i8, "distant_battle.months_until_battle")
	Scribe.put(ScribeFormat.i8, "distant_battle.roman_months_to_travel_back")
	Scribe.put(ScribeFormat.i8, "distant_battle.roman_months_to_travel_forth")
	Scribe.put(ScribeFormat.i8, "distant_battle.city_foreign_months_left")
	Scribe.put(ScribeFormat.i8, "building.triumphal_arches_available")
	Scribe.put(ScribeFormat.i8, "distant_battle.total_count")
	Scribe.put(ScribeFormat.i8, "distant_battle.won_count")
	Scribe.put(ScribeFormat.i8, "distant_battle.enemy_months_traveled")
	Scribe.put(ScribeFormat.i8, "distant_battle.roman_months_traveled")
	Scribe.put(ScribeFormat.u8, "military.total_legions")
	Scribe.put(ScribeFormat.u8, "military.empire_service_legions")
	Scribe.put(ScribeFormat.u8, "unused.unknown_458e")
	Scribe.put(ScribeFormat.u8, "military.total_soldiers")
	Scribe.put(ScribeFormat.i8, "building.triumphal_arches_placed")
	Scribe.put(ScribeFormat.i8, "sound.die_citizen")
	Scribe.put(ScribeFormat.i8, "sound.die_soldier")
	Scribe.put(ScribeFormat.i8, "sound.shoot_arrow")
	Scribe.put(ScribeFormat.i32, "building.trade_center_building_id")
	Scribe.put(ScribeFormat.i32, "figure.soldiers")
	Scribe.put(ScribeFormat.i8, "sound.hit_soldier")
	Scribe.put(ScribeFormat.i8, "sound.hit_spear")
	Scribe.put(ScribeFormat.i8, "sound.hit_club")
	Scribe.put(ScribeFormat.i8, "sound.march_enemy")
	Scribe.put(ScribeFormat.i8, "sound.march_horse")
	Scribe.put(ScribeFormat.i8, "sound.hit_elephant")
	Scribe.put(ScribeFormat.i8, "sound.hit_axe")
	Scribe.put(ScribeFormat.i8, "sound.hit_wolf")
	Scribe.put(ScribeFormat.i8, "sound.march_wolf")
	Scribe.skip(10)
	Scribe.put(ScribeFormat.i8, "sentiment.include_tents")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.count")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.size")
	Scribe.put(ScribeFormat.i32, "emperor.invasion.soldiers_killed")
	Scribe.put(ScribeFormat.i32, "military.legionary_legions")
	Scribe.put(ScribeFormat.i32, "population.highest_ever")
	Scribe.put(ScribeFormat.i32, "finance.estimated_wages")
	Scribe.put(ScribeFormat.i32, "resource.wine_types_available")
	Scribe.put(ScribeFormat.i32, "ratings.prosperity_max")
#	for i in 10:
#		Scribe.put(ScribeFormat.i32, "map.largest_road_networks[i].id") # ????
#		Scribe.put(ScribeFormat.i32, "map.largest_road_networks[i].size")
	Scribe.skip(80) # TODO
	Scribe.put(ScribeFormat.i32, "houses.missing.second_wine")
	Scribe.put(ScribeFormat.i32, "religion.neptune_sank_ships")
	Scribe.put(ScribeFormat.i32, "entertainment.hippodrome_has_race")
	Scribe.put(ScribeFormat.i32, "entertainment.hippodrome_message_shown")
	Scribe.put(ScribeFormat.i32, "entertainment.colosseum_message_shown")
	Scribe.put(ScribeFormat.i32, "migration.emigration_message_shown")
	Scribe.put(ScribeFormat.i32, "mission.fired_message_shown")
	Scribe.put(ScribeFormat.i32, "mission.victory_message_shown")
	Scribe.put(ScribeFormat.i32, "mission.start_saved_game_written")
	Scribe.put(ScribeFormat.i32, "mission.tutorial_fire_message_shown")
	Scribe.put(ScribeFormat.i32, "mission.tutorial_disease_message_shown")
	Scribe.put(ScribeFormat.i32, "figure.attacking_natives")

	Scribe.put(ScribeFormat.i32, "building.temple_complex_id")
	Scribe.skip(36)
	Scribe.put(ScribeFormat.i32, "finance.last_year.expenses.requests_and_festivals")
	Scribe.put(ScribeFormat.i32, "finance.this_year.expenses.requests_and_festivals")
	Scribe.skip(64)
	Scribe.put(ScribeFormat.i32, "finance.estimated_tax_uncollected")
	Scribe.put(ScribeFormat.i32, "building.festival_square.private_access(_X)")
	Scribe.put(ScribeFormat.i32, "building.festival_square.private_access(_Y)")
	Scribe.skip(8)
	Scribe.put(ScribeFormat.i32, "finance.this_year.income.gold_extracted")
	Scribe.put(ScribeFormat.i32, "religion.ra_no_traders_months_left")
	Scribe.skip(92)
	Scribe.put(ScribeFormat.i16, "building.festival_square_placed")
	for i in MAX_GODS:
		Scribe.sync_record([_TEMP_UNSORTED_ATA, "religion.gods", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u8, "happy_ankhs")
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.skip(33)
	Scribe.skip(2) # 2800 --> 0     granary space?
	Scribe.skip(30)
	Scribe.skip(2) # 400 --> 0      granary used (game meat)?
	Scribe.skip(146)
	Scribe.sync_record([_TEMP_UNSORTED_ATA, "resource.stored_in_warehouses_actual"], TYPE_ARRAY)
	for i in RESOURCES_MAX:
		Scribe.put(ScribeFormat.i32, i) # this is OFF BY ONE!
	Scribe.sync_record([_TEMP_UNSORTED_ATA], TYPE_DICTIONARY)
	Scribe.skip(4) # something related to Bast plague (minor curse)
	Scribe.put(ScribeFormat.i16, "religion.ra_slightly_increased_trading_months_left")
	Scribe.put(ScribeFormat.i16, "religion.ra_harshly_reduced_trading_months_left")
	Scribe.put(ScribeFormat.i16, "religion.ra_slightly_reduced_trading_months_left")
	Scribe.skip(2)
	Scribe.put(ScribeFormat.i32, "religion.seth_protect_player_troops")
	Scribe.skip(4)
	Scribe.put(ScribeFormat.i32, "religion.osiris_double_farm_yield")
	Scribe.put(ScribeFormat.i32, "religion.osiris_flood_will_destroy_active")
	Scribe.skip(51)
	Scribe.put(ScribeFormat.i16, "building.academy_placed")
	Scribe.skip(7)
	
	
	
	print("city data:                ms taken: %3d" % [
		Stopwatch.query(_t)
	])
	Scribe.pop_compressed()
