#ifndef GRAPHICS_IMAGE_GROUP_H
#define GRAPHICS_IMAGE_GROUP_H

enum {
    IMAGE_COLLECTION_UNLOADED,
    IMAGE_COLLECTION_TERRAIN,
    IMAGE_COLLECTION_GENERAL,
    IMAGE_COLLECTION_SPR_MAIN,
    IMAGE_COLLECTION_SPR_AMBIENT,
    IMAGE_COLLECTION_EMPIRE,
    //
    IMAGE_COLLECTION_FONT,
    //
    IMAGE_COLLECTION_TEMPLE,
    IMAGE_COLLECTION_MONUMENT,
    IMAGE_COLLECTION_ENEMY,
    //
    IMAGE_COLLECTION_EXPANSION,
    IMAGE_COLLECTION_EXPANSION_SPR,
    //
};

////////////////// FONT

#define GROUP_FONT  IMAGE_COLLECTION_FONT,  1

////////////////// EMPIRE MAP

#define GROUP_EMPIRE_MAP  IMAGE_COLLECTION_EMPIRE,  1

////////////////// TERRAIN

#define GROUP_TERRAIN_BLACK  IMAGE_COLLECTION_TERRAIN,  1
#define GROUP_TERRAIN_SHRUB  IMAGE_COLLECTION_TERRAIN,  2
#define GROUP_TERRAIN_UGLY_GRASS  IMAGE_COLLECTION_TERRAIN,  3
#define GROUP_TERRAIN_TREE  IMAGE_COLLECTION_TERRAIN,  4
#define GROUP_TERRAIN_WATER  IMAGE_COLLECTION_TERRAIN,  5
#define GROUP_TERRAIN_EARTHQUAKE  IMAGE_COLLECTION_TERRAIN,  6
#define GROUP_TERRAIN_EMPTY_LAND_ALT  IMAGE_COLLECTION_TERRAIN,  7
#define GROUP_TERRAIN_ROCK  IMAGE_COLLECTION_TERRAIN,  8 //239
#define GROUP_TERRAIN_ELEVATION_ROCK  IMAGE_COLLECTION_TERRAIN,  8 // this isn't in Pharaoh
#define GROUP_BUILDING_AQUEDUCT  IMAGE_COLLECTION_TERRAIN,  9 //19
#define GROUP_TERRAIN_ELEVATION  IMAGE_COLLECTION_TERRAIN,  9 // this isn't in Pharaoh
#define GROUP_TERRAIN_EMPTY_LAND  IMAGE_COLLECTION_TERRAIN,  10
#define GROUP_TERRAIN_REEDS  IMAGE_COLLECTION_TERRAIN,  11
#define GROUP_BUILDING_TRANSPORT_WHARF  IMAGE_COLLECTION_TERRAIN,  17
#define GROUP_BUILDING_FISHING_WHARF  IMAGE_COLLECTION_TERRAIN,  18 //79
#define GROUP_SUNKEN_TILE  IMAGE_COLLECTION_TERRAIN,  20
#define GROUP_TERRAIN_OVERLAY_FLAT  IMAGE_COLLECTION_TERRAIN,  20
#define GROUP_TERRAIN_OVERLAY_COLORED  IMAGE_COLLECTION_TERRAIN,  21
#define GROUP_DEBUG_ARROWPOST  IMAGE_COLLECTION_TERRAIN,  24
#define GROUP_BUILDING_WALL  IMAGE_COLLECTION_TERRAIN,  24 // TODO
#define GROUP_BUILDING_FERRY  IMAGE_COLLECTION_TERRAIN,  23
#define GROUP_BUILDING_SHIPYARD  IMAGE_COLLECTION_TERRAIN,  26 //77
#define GROUP_BUILDING_DOCK_UNUSED  IMAGE_COLLECTION_TERRAIN,  27
#define GROUP_BUILDING_WARSHIP_WHARF  IMAGE_COLLECTION_TERRAIN,  28
#define GROUP_TERRAIN_FLOODPLAIN  IMAGE_COLLECTION_TERRAIN,  31
#define GROUP_TERRAIN_FLOODSYSTEM  IMAGE_COLLECTION_TERRAIN,  33
#define GROUP_TERRAIN_REEDS_GROWN  IMAGE_COLLECTION_TERRAIN,  32
#define GROUP_TERRAIN_ROAD  IMAGE_COLLECTION_TERRAIN,  33 //112
#define GROUP_TERRAIN_RUBBLE  IMAGE_COLLECTION_TERRAIN,  34 //114
#define GROUP_TERRAIN_RUBBLE_TENT  IMAGE_COLLECTION_TERRAIN,  35 //119
#define GROUP_TERRAIN_RUBBLE_GENERAL  IMAGE_COLLECTION_TERRAIN,  36 //120
#define GROUP_TERRAIN_MEADOW_WITH_GRASS  IMAGE_COLLECTION_TERRAIN,  37 //138
#define GROUP_DEBUG_WIREFRAME_TILE  IMAGE_COLLECTION_TERRAIN,  41
#define GROUP_TERRAIN_ORE_ROCK  IMAGE_COLLECTION_TERRAIN,  42
#define GROUP_TERRAIN_DIRT_ROAD  IMAGE_COLLECTION_TERRAIN,  43
#define GROUP_TERRAIN_DESIRABILITY  IMAGE_COLLECTION_TERRAIN,  45 //135
#define GROUP_TERRAIN_GRASS_PH  IMAGE_COLLECTION_TERRAIN,  46 // terrain
#define GROUP_BUILDING_DOCK  IMAGE_COLLECTION_TERRAIN,  49 //78
#define GROUP_BUILDING_WATER_LIFT  IMAGE_COLLECTION_TERRAIN,  50 //25
#define GROUP_TERRAIN_MEADOW_STATIC_TALLGRASS  IMAGE_COLLECTION_TERRAIN,  54
#define GROUP_TERRAIN_MEADOW_STATIC_INNER  IMAGE_COLLECTION_TERRAIN,  55
#define GROUP_TERRAIN_OVERLAY_WATER  IMAGE_COLLECTION_TERRAIN,  59
#define GROUP_TERRAIN_OVERLAY_WATER_HOUSE  IMAGE_COLLECTION_TERRAIN,  60
#define GROUP_TERRAIN_DEEPWATER  IMAGE_COLLECTION_TERRAIN,  61
#define GROUP_BUILDING_BRIDGE  IMAGE_COLLECTION_TERRAIN,  63
#define GROUP_TERRAIN_GRASS_PH_EDGES  IMAGE_COLLECTION_TERRAIN,  64
#define GROUP_TERRAIN_GREEN_WATER_EDGES  IMAGE_COLLECTION_TERRAIN,  65 // ?????
#define GROUP_TERRAIN_MEADOW_STATIC_OUTER  IMAGE_COLLECTION_TERRAIN,  66
#define GROUP_TERRAIN_WATER_SHORE  IMAGE_COLLECTION_TERRAIN,  207 // TODO?
#define GROUP_TERRAIN_ACCESS_RAMP  IMAGE_COLLECTION_TERRAIN,  216 // this isn't in Pharaoh

////////////////// GENERAL

#define GROUP_TOP_MENU_SIDEBAR  IMAGE_COLLECTION_GENERAL,  11
#define GROUP_PANEL_BUTTON  IMAGE_COLLECTION_GENERAL,  15
#define GROUP_BUILDING_TOWER  IMAGE_COLLECTION_GENERAL,  17
#define GROUP_SIDEBAR_ADVISORS_EMPIRE  IMAGE_COLLECTION_GENERAL,  89 //13
#define GROUP_BUILDING_MARKET  IMAGE_COLLECTION_GENERAL,  22
#define GROUP_BUILDING_WELL  IMAGE_COLLECTION_GENERAL,  23
#define GROUP_BUILDING_HOUSE_TENT  IMAGE_COLLECTION_GENERAL,  26
#define GROUP_BUILDING_HOUSE_SHACK  IMAGE_COLLECTION_GENERAL,  27
#define GROUP_BUILDING_HOUSE_HOVEL  IMAGE_COLLECTION_GENERAL,  28
#define GROUP_BUILDING_HOUSE_CASA  IMAGE_COLLECTION_GENERAL,  29
#define GROUP_BUILDING_HOUSE_INSULA_1  IMAGE_COLLECTION_GENERAL,  30
#define GROUP_BUILDING_HOUSE_INSULA_2  IMAGE_COLLECTION_GENERAL,  31
#define GROUP_BUILDING_HOUSE_VILLA_1  IMAGE_COLLECTION_GENERAL,  32
#define GROUP_BUILDING_HOUSE_VILLA_2  IMAGE_COLLECTION_GENERAL,  33
#define GROUP_BUILDING_HOUSE_PALACE_1  IMAGE_COLLECTION_GENERAL,  34
#define GROUP_BUILDING_HOUSE_PALACE_2  IMAGE_COLLECTION_GENERAL,  35
#define GROUP_BUILDING_HOUSE_VACANT_LOT  IMAGE_COLLECTION_GENERAL,  36
#define GROUP_BUILDING_FARM_HOUSE  IMAGE_COLLECTION_GENERAL,  225 //37
#define GROUP_BUILDING_CLAY_PIT  IMAGE_COLLECTION_GENERAL,  40
#define GROUP_BUILDING_SCHOOL  IMAGE_COLLECTION_GENERAL,  42 //41
#define GROUP_BUILDING_LIBRARY  IMAGE_COLLECTION_GENERAL,  43 //42
#define GROUP_BUILDING_ACADEMY  IMAGE_COLLECTION_GENERAL,  43 // this isn't in Pharaoh
#define GROUP_BUILDING_PAPYRUS_WORKSHOP  IMAGE_COLLECTION_GENERAL,  44
#define GROUP_BUILDING_BANDSTAND  IMAGE_COLLECTION_GENERAL,  92 //45
#define GROUP_BUILDING_BOOTH  IMAGE_COLLECTION_GENERAL,  114 //46
#define GROUP_BUILDING_PAVILLION  IMAGE_COLLECTION_GENERAL,  48
#define GROUP_BUILDING_CONSERVATORY  IMAGE_COLLECTION_GENERAL,  51 //49
#define GROUP_BUILDING_DANCE_SCHOOL  IMAGE_COLLECTION_GENERAL,  52 //50
#define GROUP_BUILDING_JUGGLER_SCHOOL  IMAGE_COLLECTION_GENERAL,  46 //51
#define GROUP_BUILDING_FOUNTAIN_4  IMAGE_COLLECTION_GENERAL,  53 // this isn't in Pharaoh
#define GROUP_BUILDING_FOUNTAIN_1  IMAGE_COLLECTION_GENERAL,  54 // this isn't in Pharaoh
#define GROUP_BUILDING_FOUNTAIN_2  IMAGE_COLLECTION_GENERAL,  55 // this isn't in Pharaoh
#define GROUP_BUILDING_FOUNTAIN_3  IMAGE_COLLECTION_GENERAL,  56 // this isn't in Pharaoh
#define GROUP_TERRAIN_PLAZA  IMAGE_COLLECTION_GENERAL,  168 //58
#define GROUP_TERRAIN_GARDEN  IMAGE_COLLECTION_GENERAL,  59
#define GROUP_BUILDING_WORKSHOP_RAW_MATERIAL  IMAGE_COLLECTION_GENERAL,  60
#define GROUP_BUILDING_STATUE_SMALL_1  IMAGE_COLLECTION_GENERAL,  61
#define GROUP_BUILDING_STATUE_MEDIUM_1  IMAGE_COLLECTION_GENERAL,  8
#define GROUP_BUILDING_STATUE_LARGE_1  IMAGE_COLLECTION_GENERAL,  7
#define GROUP_BUILDING_SENATE  IMAGE_COLLECTION_GENERAL,  62 // this isn't in Pharaoh
#define GROUP_BUILDING_TAX_COLLECTOR  IMAGE_COLLECTION_GENERAL,  63
#define GROUP_BUILDING_POLICE_STATION  IMAGE_COLLECTION_GENERAL,  64
#define GROUP_BUILDING_TIMBER_YARD  IMAGE_COLLECTION_GENERAL,  65
#define GROUP_BUILDING_FORT  IMAGE_COLLECTION_GENERAL,  66
#define GROUP_BUILDING_DENTIST  IMAGE_COLLECTION_GENERAL,  67
#define GROUP_BUILDING_APOTHECARY  IMAGE_COLLECTION_GENERAL,  68
#define GROUP_BUILDING_WATER_SUPPLY  IMAGE_COLLECTION_GENERAL,  69
#define GROUP_BUILDING_PHYSICIAN  IMAGE_COLLECTION_GENERAL,  70
#define GROUP_BUILDING_MORTUARY  IMAGE_COLLECTION_GENERAL,  175 //70
#define GROUP_BUILDING_TEMPLE_OSIRIS  IMAGE_COLLECTION_GENERAL,  25 //71
#define GROUP_BUILDING_TEMPLE_RA  IMAGE_COLLECTION_GENERAL,  21 //72
#define GROUP_BUILDING_TEMPLE_PTAH  IMAGE_COLLECTION_GENERAL,  20 //73
#define GROUP_BUILDING_TEMPLE_SETH  IMAGE_COLLECTION_GENERAL,  19 //74
#define GROUP_BUILDING_TEMPLE_BAST  IMAGE_COLLECTION_GENERAL,  76 //75
#define GROUP_BUILDING_SHRINE_OSIRIS  IMAGE_COLLECTION_GENERAL,  75
#define GROUP_BUILDING_SHRINE_RA  IMAGE_COLLECTION_GENERAL,  74
#define GROUP_BUILDING_SHRINE_PTAH  IMAGE_COLLECTION_GENERAL,  73
#define GROUP_BUILDING_SHRINE_SETH  IMAGE_COLLECTION_GENERAL,  72
#define GROUP_BUILDING_SHRINE_BAST  IMAGE_COLLECTION_GENERAL,  71
#define GROUP_BUILDING_ORACLE  IMAGE_COLLECTION_GENERAL,  76 // this isn't in Pharaoh
#define GROUP_BUILDING_ENGINEERS_POST  IMAGE_COLLECTION_GENERAL,  81
#define GROUP_BUILDING_WAREHOUSE  IMAGE_COLLECTION_GENERAL,  82
#define GROUP_BUILDING_WAREHOUSE_STORAGE_EMPTY  IMAGE_COLLECTION_GENERAL,  83
#define GROUP_BUILDING_WAREHOUSE_STORAGE_FILLED  IMAGE_COLLECTION_GENERAL,  84
#define GROUP_BUILDING_GOVERNORS_HOUSE  IMAGE_COLLECTION_GENERAL,  85
#define GROUP_BUILDING_GOVERNORS_VILLA  IMAGE_COLLECTION_GENERAL,  86
#define GROUP_BUILDING_GOVERNORS_PALACE  IMAGE_COLLECTION_GENERAL,  87
#define GROUP_SIDEBAR_BRIEFING_ROTATE_BUTTONS  IMAGE_COLLECTION_GENERAL,  89
#define GROUP_MESSAGE_ICON  IMAGE_COLLECTION_GENERAL,  90
#define GROUP_SIDEBAR_BUTTONS  IMAGE_COLLECTION_GENERAL,  136 //92
#define GROUP_LABOR_PRIORITY_LOCK  IMAGE_COLLECTION_GENERAL,  94
#define GROUP_OK_CANCEL_SCROLL_BUTTONS  IMAGE_COLLECTION_GENERAL,  96
#define GROUP_BUILDING_GRANARY  IMAGE_COLLECTION_GENERAL,  99
#define GROUP_BUILDING_FARMLAND  IMAGE_COLLECTION_GENERAL,  37 //100
#define GROUP_FIGURE_EXPLOSION  IMAGE_COLLECTION_GENERAL,  102 // exception sprites in General/Sprites.bmp
#define GROUP_OVERLAY_COLUMN  IMAGE_COLLECTION_GENERAL,  103
#define GROUP_SIDEBAR_UPPER_BUTTONS  IMAGE_COLLECTION_GENERAL,  110
#define GROUP_BUILDING_BEER_WORKSHOP  IMAGE_COLLECTION_GENERAL,  116 //44
#define GROUP_BUILDING_CHARIOT_MAKER  IMAGE_COLLECTION_GENERAL,  120 //52
#define GROUP_SIDE_PANEL  IMAGE_COLLECTION_GENERAL,  121 //12
#define GROUP_BUILDING_LINEN_WORKSHOP  IMAGE_COLLECTION_GENERAL,  122
#define GROUP_BUILDING_WEAPONS_WORKSHOP  IMAGE_COLLECTION_GENERAL,  123
#define GROUP_BUILDING_JEWELS_WORKSHOP  IMAGE_COLLECTION_GENERAL,  119 //124
#define GROUP_BUILDING_BRICKS_WORKSHOP  IMAGE_COLLECTION_GENERAL,  124
#define GROUP_BUILDING_POTTERY_WORKSHOP  IMAGE_COLLECTION_GENERAL,  125
#define GROUP_FIGURE_FORT_FLAGS  IMAGE_COLLECTION_GENERAL,  126
#define GROUP_FIGURE_FORT_STANDARD_ICONS  IMAGE_COLLECTION_GENERAL,  127
#define GROUP_ADVISOR_ICONS  IMAGE_COLLECTION_GENERAL,  128
#define GROUP_RESOURCE_ICONS  IMAGE_COLLECTION_GENERAL,  129
#define GROUP_DIALOG_BACKGROUND  IMAGE_COLLECTION_GENERAL,  132
#define GROUP_SUNKEN_TEXTBOX_BACKGROUND  IMAGE_COLLECTION_GENERAL,  133
#define GROUP_CONTEXT_ICONS  IMAGE_COLLECTION_GENERAL,  134
#define GROUP_EDITOR_SIDEBAR_BUTTONS  IMAGE_COLLECTION_GENERAL,  137
#define GROUP_FIGURE_MAP_FLAG_FLAGS  IMAGE_COLLECTION_GENERAL,  139
#define GROUP_FIGURE_MAP_FLAG_ICONS  IMAGE_COLLECTION_GENERAL,  140
#define GROUP_MINIMAP_EMPTY_LAND  IMAGE_COLLECTION_GENERAL,  141
#define GROUP_MINIMAP_WATER  IMAGE_COLLECTION_GENERAL,  142
#define GROUP_MINIMAP_TREE  IMAGE_COLLECTION_GENERAL,  143
#define GROUP_MINIMAP_ROCK  IMAGE_COLLECTION_GENERAL,  145
#define GROUP_MINIMAP_MEADOW  IMAGE_COLLECTION_GENERAL,  146
#define GROUP_MINIMAP_ROAD  IMAGE_COLLECTION_GENERAL,  147
#define GROUP_MINIMAP_HOUSE  IMAGE_COLLECTION_GENERAL,  148
#define GROUP_MINIMAP_BUILDING  IMAGE_COLLECTION_GENERAL,  149
#define GROUP_MINIMAP_WALL  IMAGE_COLLECTION_GENERAL,  150
#define GROUP_MINIMAP_AQUEDUCT  IMAGE_COLLECTION_GENERAL,  151
#define GROUP_MINIMAP_BLACK  IMAGE_COLLECTION_GENERAL,  152
#define GROUP_FIGURE_FLOTSAM_0  IMAGE_COLLECTION_GENERAL,  153 // TODO?
#define GROUP_FIGURE_FLOTSAM_1  IMAGE_COLLECTION_GENERAL,  139 //154
#define GROUP_FIGURE_FLOTSAM_2  IMAGE_COLLECTION_GENERAL,  155 // TODO?
#define GROUP_FIGURE_FLOTSAM_3  IMAGE_COLLECTION_GENERAL,  156 // TODO?
#define GROUP_POPULATION_GRAPH_BAR  IMAGE_COLLECTION_GENERAL,  157
#define GROUP_BULLET  IMAGE_COLLECTION_GENERAL,  158
#define GROUP_BUILDING_BARRACKS  IMAGE_COLLECTION_GENERAL,  166
#define GROUP_EMPIRE_PANELS  IMAGE_COLLECTION_GENERAL,  172
#define GROUP_EMPIRE_RESOURCES  IMAGE_COLLECTION_GENERAL,  205 //173
#define GROUP_EMPIRE_CITY  IMAGE_COLLECTION_GENERAL,  177 //174
#define GROUP_EMPIRE_CITY_TRADE  IMAGE_COLLECTION_GENERAL,  175
#define GROUP_EMPIRE_CITY_DISTANT_ROMAN  IMAGE_COLLECTION_GENERAL,  176
#define GROUP_EMPIRE_TRADE_ROUTE_TYPE  IMAGE_COLLECTION_GENERAL,  179
#define GROUP_BUILDING_NATIVE  IMAGE_COLLECTION_GENERAL,  183
#define GROUP_BUILDING_MISSION_POST  IMAGE_COLLECTION_GENERAL,  184
#define GROUP_BUILDING_BATHHOUSE_NO_WATER  IMAGE_COLLECTION_GENERAL,  185
#define GROUP_RATINGS_COLUMN  IMAGE_COLLECTION_GENERAL,  189
#define GROUP_MESSAGE_ADVISOR_BUTTONS  IMAGE_COLLECTION_GENERAL,  106 //199
#define GROUP_BUILDING_MILITARY_ACADEMY  IMAGE_COLLECTION_GENERAL,  173 //201
#define GROUP_BUILDING_FORT_JAVELIN  IMAGE_COLLECTION_GENERAL,  66 //202
#define GROUP_BUILDING_FORT_LEGIONARY  IMAGE_COLLECTION_GENERAL,  66 //204
#define GROUP_BUILDING_TRIUMPHAL_ARCH  IMAGE_COLLECTION_GENERAL,  205 // this isn't in Pharaoh
#define GROUP_BORDERED_BUTTON  IMAGE_COLLECTION_GENERAL,  174 //208
#define GROUP_BUILDING_MARKET_FANCY  IMAGE_COLLECTION_GENERAL,  45 //210
#define GROUP_BUILDING_BATHHOUSE_FANCY_WATER  IMAGE_COLLECTION_GENERAL,  211 // this isn't in Pharaoh
#define GROUP_BUILDING_BATHHOUSE_FANCY_NO_WATER  IMAGE_COLLECTION_GENERAL,  212 // this isn't in Pharaoh
#define GROUP_BUILDING_SENET_HOUSE  IMAGE_COLLECTION_GENERAL,  17 //213 //GROUP_BUILDING_HIPPODROME_1
#define GROUP_BUILDING_HIPPODROME_2  IMAGE_COLLECTION_GENERAL,  214 // this isn't in Pharaoh
#define GROUP_BUILDING_SENATE_FANCY  IMAGE_COLLECTION_GENERAL,  221 // this isn't in Pharaoh
#define GROUP_FORT_ICONS  IMAGE_COLLECTION_GENERAL,  222 // TODO?
#define GROUP_EMPIRE_FOREIGN_CITY  IMAGE_COLLECTION_GENERAL,  223 // this isn't in Pharaoh
#define GROUP_GOD_BOLT  IMAGE_COLLECTION_GENERAL,  111 //225
#define GROUP_PLAGUE_SKULL  IMAGE_COLLECTION_GENERAL,  97 //227
#define GROUP_FIGURE_FORT_MOUNTED  IMAGE_COLLECTION_GENERAL,  66 //232
#define GROUP_BUILDING_TRADE_CENTER_FLAG  IMAGE_COLLECTION_GENERAL,  238 // this isn't in Pharaoh
#define GROUP_TERRAIN_ENTRY_EXIT_FLAGS  IMAGE_COLLECTION_GENERAL,  240
#define GROUP_FIGURE_FORT_STANDARD_POLE  IMAGE_COLLECTION_GENERAL,  241
#define GROUP_FIGURE_FLOTSAM_SHEEP  IMAGE_COLLECTION_GENERAL,  242 // this isn't in Pharaoh
#define GROUP_TRADE_AMOUNT  IMAGE_COLLECTION_GENERAL,  171 //243
#define GROUP_BULIDING_GATEHOUSE  IMAGE_COLLECTION_GENERAL,  248 // this isn't in Pharaoh
#define GROUP_BUILDING_VILLAGE_PALACE  IMAGE_COLLECTION_GENERAL,  47 // general
#define GROUP_BUILDING_TOWN_PALACE  IMAGE_COLLECTION_GENERAL,  39
#define GROUP_BUILDING_CITY_PALACE  IMAGE_COLLECTION_GENERAL,  18
#define GROUP_BUILDING_FARM_CROPS_PH  IMAGE_COLLECTION_GENERAL,  100
#define GROUP_BUILDING_CATTLE_RANCH  IMAGE_COLLECTION_GENERAL,  105
#define GROUP_BUILDING_REEDS_COLLECTOR  IMAGE_COLLECTION_GENERAL,  24
#define GROUP_SINGLE_SQUARE  IMAGE_COLLECTION_GENERAL,  107
#define GROUP_BOOTH_SQUARE  IMAGE_COLLECTION_GENERAL,  112
#define GROUP_BANDSTAND_SQUARE  IMAGE_COLLECTION_GENERAL,  58
#define GROUP_PAVILLION_SQUARE  IMAGE_COLLECTION_GENERAL,  50
#define GROUP_FESTIVAL_SQUARE  IMAGE_COLLECTION_GENERAL,  49
#define GROUP_BUILDING_GRANITE_QUARY  IMAGE_COLLECTION_GENERAL,  38
#define GROUP_BUILDING_GOLD_MINE  IMAGE_COLLECTION_GENERAL,  185
#define GROUP_BUILDING_GEMSTONE_MINE  IMAGE_COLLECTION_GENERAL,  188
#define GROUP_BUILDING_STONE_QUARRY  IMAGE_COLLECTION_GENERAL,  187 //38
#define GROUP_BUILDING_UNUSED_BEIGE_MINE  IMAGE_COLLECTION_GENERAL,  186
#define GROUP_BUILDING_COPPER_MINE  IMAGE_COLLECTION_GENERAL,  196
#define GROUP_BUILDING_SANDSTONE_MINE  IMAGE_COLLECTION_GENERAL,  197
#define GROUP_BUILDING_MARBLE_QUARRY  IMAGE_COLLECTION_GENERAL,  162
#define GROUP_BUILDING_LIMESTONE_QUARRY  IMAGE_COLLECTION_GENERAL,  170 //39
#define GROUP_BUILDING_HUNTING_LODGE  IMAGE_COLLECTION_GENERAL,  176
#define GROUP_BUILDING_ROADBLOCK  IMAGE_COLLECTION_GENERAL,  98
#define GROUP_BUILDING_FIREHOUSE  IMAGE_COLLECTION_GENERAL,  78
#define GROUP_BUILDING_WORKCAMP  IMAGE_COLLECTION_GENERAL,  77
#define GROUP_BUILDING_WATER_SUPPLY  IMAGE_COLLECTION_GENERAL,  69
#define GROUP_BUILDING_COURTHOUSE  IMAGE_COLLECTION_GENERAL,  62
#define GROUP_BUILDING_WALLS  IMAGE_COLLECTION_GENERAL,  138
#define GROUP_BUILDING_GATEHOUSE  IMAGE_COLLECTION_GENERAL,  161
#define GROUP_BUILDING_GATEHOUSE_2  IMAGE_COLLECTION_GENERAL,  220
#define GROUP_BUILDING_TOWER  IMAGE_COLLECTION_GENERAL,  135
#define GROUP_BUILDING_TRANSPORT_WHARF  IMAGE_COLLECTION_GENERAL,  17 // TODO
#define GROUP_BUILDING_WARSHIP_WHARF  IMAGE_COLLECTION_GENERAL,  28 // TODO
#define GROUP_BUILDING_GUILD_CARPENTERS  IMAGE_COLLECTION_GENERAL,  91
#define GROUP_BUILDING_GUILD_STONEMASONS  IMAGE_COLLECTION_GENERAL,  88
#define GROUP_BUILDING_GUILD_BRICKLAYERS  IMAGE_COLLECTION_GENERAL,  57

#define GROUP_SELECT_MISSION_BUTTON  IMAGE_COLLECTION_GENERAL,  254 // TODO
#define GROUP_BUTTON_EXCLAMATION  IMAGE_COLLECTION_GENERAL,  193
#define GROUP_MENU_ADVISOR_BUTTONS  IMAGE_COLLECTION_GENERAL,  159
#define GROUP_MENU_ADVISOR_LAYOUT  IMAGE_COLLECTION_GENERAL,  160
#define GROUP_TINY_ARROWS  IMAGE_COLLECTION_GENERAL,  212
#define GROUP_GOD_ANGEL  IMAGE_COLLECTION_GENERAL,  9
#define GROUP_PANEL_WINDOWS_PH  IMAGE_COLLECTION_GENERAL,  117
#define GROUP_MINIMAP_REEDS  IMAGE_COLLECTION_GENERAL,  144
#define GROUP_MINIMAP_FLOODPLAIN  IMAGE_COLLECTION_GENERAL,  146
#define GROUP_MINIMAP_DUNES  IMAGE_COLLECTION_GENERAL,  211

////////////////// UNLOADED

#define GROUP_SYSTEM_GRAPHICS  IMAGE_COLLECTION_UNLOADED,  0
#define GROUP_FORT_FORMATIONS  IMAGE_COLLECTION_UNLOADED,  1 //197
#define GROUP_RATINGS_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  2 //195
#define GROUP_BIGPEOPLE  IMAGE_COLLECTION_UNLOADED,  3
#define GROUP_PROMO_3  IMAGE_COLLECTION_UNLOADED,  4 //188
#define GROUP_PROMO_2  IMAGE_COLLECTION_UNLOADED,  5 //187
#define GROUP_PROMO_1  IMAGE_COLLECTION_UNLOADED,  6 //186
#define GROUP_LOGO  IMAGE_COLLECTION_UNLOADED,  7 //162
#define GROUP_CONFIG  IMAGE_COLLECTION_UNLOADED,  8 //161
#define GROUP_SCORES  IMAGE_COLLECTION_UNLOADED,  9
#define GROUP_WIN_GAME_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  9 //160
#define GROUP_MESSAGE_IMAGES  IMAGE_COLLECTION_UNLOADED,  10 //159
#define GROUP_ADVISOR_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  11 //136
#define GROUP_SELECT_MISSION_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  12 //244
#define GROUP_MAIN_MENU_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  14
#define GROUP_SELECT_MISSION  IMAGE_COLLECTION_UNLOADED,  16 //245 <----- ?????????????????
#define GROUP_CCK_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  15 //246
#define GROUP_LOADING_SCREEN  IMAGE_COLLECTION_UNLOADED,  17 //251
#define GROUP_INTERMEZZO_BACKGROUND  IMAGE_COLLECTION_UNLOADED,  18 //252
#define GROUP_PANEL_WINDOWS_DESERT  IMAGE_COLLECTION_UNLOADED,  19 //253
#define GROUP_PANEL_WINDOWS  IMAGE_COLLECTION_UNLOADED,  21 //95
//#define ?????  IMAGE_COLLECTION_UNLOADED,  22 //80
#define GROUP_PORTRAITS  IMAGE_COLLECTION_UNLOADED,  25 //190
#define GROUP_SCENARIO_IMAGE  IMAGE_COLLECTION_UNLOADED,  28 //247
#define GROUP_PLAYER_SELECTION  IMAGE_COLLECTION_UNLOADED,  29
#define GROUP_CAMPAIGN_SELECTION  IMAGE_COLLECTION_UNLOADED,  30
#define GROUP_PLAYER_GAME_MENU  IMAGE_COLLECTION_UNLOADED,  31
#define GROUP_CUSTOM_MISSION_SELECTION  IMAGE_COLLECTION_UNLOADED,  32
#define GROUP_MISSION_EDITOR  IMAGE_COLLECTION_UNLOADED,  33

////////////////// SPRMAIN

#define GROUP_FIGURE_LABOR_SEEKER  IMAGE_COLLECTION_SPR_MAIN,  206 //57
#define GROUP_FIGURE_BATHHOUSE_WORKER  IMAGE_COLLECTION_SPR_MAIN,  71 //88
#define GROUP_FIGURE_PRIEST  IMAGE_COLLECTION_SPR_MAIN,  197 //91
#define GROUP_FIGURE_CARTPUSHER_CART  IMAGE_COLLECTION_SPR_MAIN,  77 //97
#define GROUP_FIGURE_JUGGLER  IMAGE_COLLECTION_SPR_MAIN,  130 //98
#define GROUP_FIGURE_DANCER  IMAGE_COLLECTION_SPR_MAIN,  128 //101
#define GROUP_FIGURE_TAX_COLLECTOR  IMAGE_COLLECTION_SPR_MAIN,  41 //104
#define GROUP_FIGURE_SCHOOL_CHILD  IMAGE_COLLECTION_SPR_MAIN,  57 //105
#define GROUP_FIGURE_MARKET_LADY  IMAGE_COLLECTION_SPR_MAIN,  16 //106
#define GROUP_FIGURE_CARTPUSHER  IMAGE_COLLECTION_SPR_MAIN,  43 //107
#define GROUP_FIGURE_MIGRANT  IMAGE_COLLECTION_SPR_MAIN,  14 //108
#define GROUP_FIGURE_DANCER_WHIP  IMAGE_COLLECTION_SPR_MAIN,  109 // this isn't in Pharaoh
#define GROUP_FIGURE_ENGINEER  IMAGE_COLLECTION_SPR_MAIN,  4 //110
#define GROUP_FIGURE_MUSICIAN  IMAGE_COLLECTION_SPR_MAIN,  191 //111
#define GROUP_FIGURE_CRIMINAL  IMAGE_COLLECTION_SPR_MAIN,  32 //115
#define GROUP_FIGURE_BARBER  IMAGE_COLLECTION_SPR_MAIN,  182 //116
#define GROUP_FIGURE_PREFECT  IMAGE_COLLECTION_SPR_MAIN,  6 //117
#define GROUP_FIGURE_HOMELESS  IMAGE_COLLECTION_SPR_MAIN,  12 //118
#define GROUP_FIGURE_PREFECT_WITH_BUCKET  IMAGE_COLLECTION_SPR_MAIN,  8 //121
#define GROUP_FIGURE_MIGRANT_CART  IMAGE_COLLECTION_SPR_MAIN,  52 //131
#define GROUP_FIGURE_LION  IMAGE_COLLECTION_SPR_MAIN,  161 //163
#define GROUP_FIGURE_SHIP  IMAGE_COLLECTION_SPR_MAIN,  34 //165
#define GROUP_FIGURE_TOWER_SENTRY  IMAGE_COLLECTION_SPR_MAIN,  194 // TODO
#define GROUP_FIGURE_MISSILE  IMAGE_COLLECTION_SPR_MAIN,  198 // TODO
#define GROUP_FIGURE_BALLISTA  IMAGE_COLLECTION_SPR_MAIN,  200 // TODO
#define GROUP_FIGURE_SEAGULLS  IMAGE_COLLECTION_SPR_MAIN,  114 //206
#define GROUP_FIGURE_DELIVERY_BOY  IMAGE_COLLECTION_SPR_MAIN,  9 //209
#define GROUP_FIGURE_CHARIOTEER  IMAGE_COLLECTION_SPR_MAIN,  215 // this isn't in Pharaoh
#define GROUP_FIGURE_HIPPODROME_HORSE_1  IMAGE_COLLECTION_SPR_MAIN,  217 // // this isn't in Pharaoh this isn't in Pharaoh
#define GROUP_FIGURE_HIPPODROME_HORSE_2  IMAGE_COLLECTION_SPR_MAIN,  218 // this isn't in Pharaoh
#define GROUP_FIGURE_HIPPODROME_CART_1  IMAGE_COLLECTION_SPR_MAIN,  219 // this isn't in Pharaoh
#define GROUP_FIGURE_HIPPODROME_CART_2  IMAGE_COLLECTION_SPR_MAIN,  220 // this isn't in Pharaoh
#define GROUP_FIGURE_SHIPWRECK  IMAGE_COLLECTION_SPR_MAIN,  226 // this isn't in Pharaoh
#define GROUP_FIGURE_DOCTOR_SURGEON  IMAGE_COLLECTION_SPR_MAIN,  180 //228
#define GROUP_FIGURE_PATRICIAN  IMAGE_COLLECTION_SPR_MAIN,  229 // this isn't in Pharaoh
#define GROUP_FIGURE_MISSIONARY  IMAGE_COLLECTION_SPR_MAIN,  230 // this isn't in Pharaoh
#define GROUP_FIGURE_TEACHER_LIBRARIAN  IMAGE_COLLECTION_SPR_MAIN,  201 //231
#define GROUP_FIGURE_SHEEP  IMAGE_COLLECTION_SPR_MAIN,  233 // TODO
#define GROUP_FIGURE_OSTRICH  IMAGE_COLLECTION_SPR_MAIN,  156 //234
#define GROUP_FIGURE_CROCODILE  IMAGE_COLLECTION_SPR_MAIN,  23 //235
#define GROUP_FIGURE_CAESAR_LEGIONARY  IMAGE_COLLECTION_SPR_MAIN,  236 // this isn't in Pharaoh
#define GROUP_FIGURE_CARTPUSHER_CART_MULTIPLE_FOOD  IMAGE_COLLECTION_SPR_MAIN,  237 // this isn't in Pharaoh
#define GROUP_FIGURE_CARTPUSHER_CART_MULTIPLE_RESOURCE  IMAGE_COLLECTION_SPR_MAIN,  250 // this isn't in Pharaoh
#define GROUP_PRIEST_OSIRIS  IMAGE_COLLECTION_SPR_MAIN,  197
#define GROUP_PRIEST_RA  IMAGE_COLLECTION_SPR_MAIN,  210
#define GROUP_PRIEST_SETH  IMAGE_COLLECTION_SPR_MAIN,  193
#define GROUP_PRIEST_PTAH  IMAGE_COLLECTION_SPR_MAIN,  187
#define GROUP_PRIEST_BAST  IMAGE_COLLECTION_SPR_MAIN,  208
#define GROUP_FIGURE_MARKET_LADY_2  IMAGE_COLLECTION_SPR_MAIN,  18
#define GROUP_FIGURE_POLICEMAN  IMAGE_COLLECTION_SPR_MAIN,  20
#define GROUP_FIGURE_REED_GATHERER  IMAGE_COLLECTION_SPR_MAIN,  37
#define GROUP_FIGURE_HUNTER  IMAGE_COLLECTION_SPR_MAIN,  45
#define GROUP_FIGURE_HUNTER_ARROW  IMAGE_COLLECTION_SPR_MAIN,  0
#define GROUP_FIGURE_TRADE_CARAVAN_DONKEY  IMAGE_COLLECTION_SPR_MAIN,  52
#define GROUP_FIGURE_WATER_CARRIER  IMAGE_COLLECTION_SPR_MAIN,  59
#define GROUP_FIGURE_WORKER_PH  IMAGE_COLLECTION_SPR_MAIN,  116
#define GROUP_FIGURE_MORTUARY  IMAGE_COLLECTION_SPR_MAIN,  195
#define GROUP_FIGURE_MAGISTRATE  IMAGE_COLLECTION_SPR_MAIN,  212
#define GROUP_FIGURE_ARCHER_PH  IMAGE_COLLECTION_SPR_MAIN,  62
#define GROUP_FIGURE_INFANTRY_PH  IMAGE_COLLECTION_SPR_MAIN,  65
#define GROUP_FIGURE_CHARIOTEER_PH  IMAGE_COLLECTION_SPR_MAIN,  68

////////////////// SPRAMBIENT

#define GROUP_FIGURE_TRADE_CARAVAN  IMAGE_COLLECTION_SPR_AMBIENT,  20 //130
#define GROUP_BUILDING_DOCK_DOCKERS  IMAGE_COLLECTION_SPR_AMBIENT,  55 //171
#define GROUP_JUGGLERS_SHOW  IMAGE_COLLECTION_SPR_AMBIENT,  7 //191
#define GROUP_DANCERS_SHOW  IMAGE_COLLECTION_SPR_AMBIENT,  6 //192
#define GROUP_MUSICIANS_SHOW  IMAGE_COLLECTION_SPR_AMBIENT,  9 //193
#define GROUP_WATER_LIFT_ANIM  IMAGE_COLLECTION_SPR_AMBIENT,  1 // sprambient
#define GROUP_GRANARY_ANIM_PH  IMAGE_COLLECTION_SPR_AMBIENT,  47
#define GROUP_WAREHOUSE_ANIM_PH  IMAGE_COLLECTION_SPR_AMBIENT,  51
//   #define GROUP_DOCK_WAITING  IMAGE_COLLECTION_SPR_AMBIENT,  55
//   #define GROUP_DOCK_UNLOADING  IMAGE_COLLECTION_SPR_AMBIENT,  56
#define GROUP_MINES  IMAGE_COLLECTION_SPR_AMBIENT,  48
#define GROUP_DANCERS  IMAGE_COLLECTION_SPR_AMBIENT,  6
#define GROUP_JUGGLERS  IMAGE_COLLECTION_SPR_AMBIENT,  7
#define GROUP_MUSICIANS  IMAGE_COLLECTION_SPR_AMBIENT,  9
#define GROUP_FIGURE_FISH  IMAGE_COLLECTION_SPR_AMBIENT,  8
#define GROUP_FIGURE_HIPPO  IMAGE_COLLECTION_SPR_AMBIENT,  22
#define GROUP_FIGURE_ANTILOPE  IMAGE_COLLECTION_SPR_AMBIENT,  30
#define GROUP_FIGURE_HUNTER2  IMAGE_COLLECTION_SPR_AMBIENT,  36
#define GROUP_SHIP_BUILDING_1  IMAGE_COLLECTION_SPR_AMBIENT,  45
#define GROUP_SHIP_BUILDING_2  IMAGE_COLLECTION_SPR_AMBIENT,  52
#define GROUP_SHIP_BUILDING_3  IMAGE_COLLECTION_SPR_AMBIENT,  53
#define GROUP_SHIP_BUILDING_4  IMAGE_COLLECTION_SPR_AMBIENT,  54

////////////////// MONUMENT

#define GROUP_MONUMENT_BLOCKS  IMAGE_COLLECTION_MONUMENT,  1
#define GROUP_MONUMENT_TERRAIN  IMAGE_COLLECTION_MONUMENT,  2
#define GROUP_MONUMENT_DITCHES_PHASE_1  IMAGE_COLLECTION_MONUMENT,  3
#define GROUP_MONUMENT_DITCHES_PHASE_2  IMAGE_COLLECTION_MONUMENT,  4
#define GROUP_MONUMENT_DITCHES_PHASE_3  IMAGE_COLLECTION_MONUMENT,  5
#define GROUP_MONUMENT_DITCHES_PHASE_4  IMAGE_COLLECTION_MONUMENT,  6
#define GROUP_MONUMENT_TOMB_FLOOR  IMAGE_COLLECTION_MONUMENT,  7
#define GROUP_MONUMENT_CORNER_POLES  IMAGE_COLLECTION_MONUMENT,  8
#define GROUP_MONUMENT_EXTERIORS_END_DRY  IMAGE_COLLECTION_MONUMENT,  9
#define GROUP_MONUMENT_EXTERIORS_RUNS  IMAGE_COLLECTION_MONUMENT,  10
#define GROUP_MONUMENT_EXTERIORS_END_WET  IMAGE_COLLECTION_MONUMENT,  11
#define GROUP_MONUMENT_EXTRA_BLOCKS  IMAGE_COLLECTION_MONUMENT,  12

////////////////// TEMPLE

#define GROUP_BUILDING_TEMPLE_COMPLEX_MAIN  IMAGE_COLLECTION_TEMPLE,  1
#define GROUP_BUILDING_TEMPLE_COMPLEX_ORACLE  IMAGE_COLLECTION_TEMPLE,  2
#define GROUP_BUILDING_TEMPLE_COMPLEX_ALTAR  IMAGE_COLLECTION_TEMPLE,  3
#define GROUP_BUILDING_TEMPLE_COMPLEX_FLOORING  IMAGE_COLLECTION_TEMPLE,  4
#define GROUP_BUILDING_TEMPLE_COMPLEX_STATUE_1  IMAGE_COLLECTION_TEMPLE,  5
#define GROUP_BUILDING_TEMPLE_COMPLEX_STATUE_2  IMAGE_COLLECTION_TEMPLE,  6
#define GROUP_BUILDING_TEMPLE_COMPLEX_UPGRADES  IMAGE_COLLECTION_TEMPLE,  7

////////////////// EXPANSION

#define GROUP_BIG_PEOPLE_2  IMAGE_COLLECTION_EXPANSION,  1
#define GROUP_SCORPION_ICON  IMAGE_COLLECTION_EXPANSION,  2
#define GROUP_RESOURCE_ICONS_2  IMAGE_COLLECTION_EXPANSION,  3
#define GROUP_BUILDING_WAREHOUSE_STORAGE_FILLED_2  IMAGE_COLLECTION_EXPANSION,  4
#define GROUP_BUILDING_FARM_CROPS_HENNA  IMAGE_COLLECTION_EXPANSION,  5
#define GROUP_BUILDING_ZOO  IMAGE_COLLECTION_EXPANSION,  6
#define GROUP_BLOOD_TILES  IMAGE_COLLECTION_EXPANSION,  7
#define GROUP_BLOOD_FLOODPLAIN  IMAGE_COLLECTION_EXPANSION,  8
#define GROUP_BLOOD_FLOODSYSTEM  IMAGE_COLLECTION_EXPANSION,  9
#define GROUP_BLOOD_MARSHLANDS  IMAGE_COLLECTION_EXPANSION,  11
#define GROUP_BLOOD_TRANSPORT  IMAGE_COLLECTION_EXPANSION,  13
#define GROUP_BLOOD_WELL  IMAGE_COLLECTION_EXPANSION,  24
#define GROUP_BLOOD_WATER_SUPPLY  IMAGE_COLLECTION_EXPANSION,  25
#define GROUP_BUILDING_LAMP_WORKSHOP  IMAGE_COLLECTION_EXPANSION,  26
#define GROUP_BUILDING_PAINT_WORKSHOP  IMAGE_COLLECTION_EXPANSION,  27
#define GROUP_BUILDING_GUILD_ARTISANS  IMAGE_COLLECTION_EXPANSION,  31
#define GROUP_FROG_ICON  IMAGE_COLLECTION_EXPANSION,  32
#define GROUP_TERRAIN_CLIFF  IMAGE_COLLECTION_EXPANSION,  33
#define GROUP_BUILDING_STATUE_LARGE_2  IMAGE_COLLECTION_EXPANSION,  35
#define GROUP_BUILDING_STATUE_MEDIUM_2  IMAGE_COLLECTION_EXPANSION,  36
#define GROUP_BUILDING_STATUE_SMALL_2  IMAGE_COLLECTION_EXPANSION,  37
#define GROUP_MISSION_SELECT_2  IMAGE_COLLECTION_EXPANSION,  38 // ????
#define GROUP_HISTORY_INFO_2  IMAGE_COLLECTION_EXPANSION,  39 // ????
#define GROUP_BLOOD_EDGES  IMAGE_COLLECTION_EXPANSION,  40 // ????
#define GROUP_BREAKAWAY_SPLASH_LOGO  IMAGE_COLLECTION_EXPANSION,  41 // ????

#endif // GRAPHICS_IMAGE_GROUP_H
