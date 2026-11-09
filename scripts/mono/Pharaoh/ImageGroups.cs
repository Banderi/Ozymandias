// using System.Collections;
// using System.Collections.Generic;
using E = ImageGroup;
using static ImagePak;
public enum ImagePak : int {
    UNLOADED,
    //
    SPR_MAIN,
    ENEMY,
    //
    GENERAL,
    TERRAIN,
    //
    EMPIRE,
    SPR_AMBIENT,
    //
    FONTS,
    //
    TEMPLE,
    MONUMENT,
    //
    EXPANSION_SPR,
    EXPANSION,
    //
};


// public enum ImageGroup2 { Name, pak, tag_idx };
// public static readonly ImageGroup2[] ImageGroups2 = new ImageGroup2[] {
//     new ImageGroup2(1, 2, 3);
// };

public readonly struct ImageGroup {
    public readonly ImagePak pak;
    public readonly int tag_idx;
	public ImageGroup(ImagePak a, int b) {
		pak = a;
		tag_idx = b;
	}
}

// public class EntryTable : IEnumerable<KeyValuePair<string, E>>
// {
//     private readonly Dictionary<string, E> _map = new Dictionary<string, E>();

//     // The initializer calls this for each { ... } row
//     public void Add(string key, int a, int b, string name) =>
//         _map.Add(key, _(a, b, name));

//     public E this[string key] => _map[key];

//     public IEnumerator<KeyValuePair<string, E>> GetEnumerator() => _map.GetEnumerator();
//     IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
// }


public class ImageGroups {
    static E _(ImagePak a, int b) {
        return new E(a, b);
    }
    
	public static readonly E NONE = _(0, 0);
    
    ////////////////// FONT

    public static readonly E FONT = _(FONTS,  1);


    ////////////////// EMPIRE MAP

    public static readonly E EMPIRE_MAP = _(EMPIRE,  1);

    ////////////////// TERRAIN

    public static readonly E TERRAIN_BLACK = _(TERRAIN,  1);
    public static readonly E TERRAIN_SHRUB = _(TERRAIN,  2);
    public static readonly E TERRAIN_UGLY_GRASS = _(TERRAIN,  3);
    public static readonly E TERRAIN_TREE = _(TERRAIN,  4);
    public static readonly E TERRAIN_WATER = _(TERRAIN,  5);
    public static readonly E TERRAIN_EARTHQUAKE = _(TERRAIN,  6);
    public static readonly E TERRAIN_EMPTY_LAND_ALT = _(TERRAIN,  7);
    public static readonly E TERRAIN_ROCK = _(TERRAIN,  8); //239
    public static readonly E TERRAIN_ELEVATION_ROCK = _(TERRAIN,  8); // this isn't in Pharaoh
    public static readonly E BUILDING_AQUEDUCT = _(TERRAIN,  9); //19
    public static readonly E TERRAIN_ELEVATION = _(TERRAIN,  9); // this isn't in Pharaoh
    public static readonly E TERRAIN_EMPTY_LAND = _(TERRAIN,  10);
    public static readonly E TERRAIN_REEDS = _(TERRAIN,  11);
    public static readonly E BUILDING_TRANSPORT_WHARF = _(TERRAIN,  17);
    public static readonly E BUILDING_FISHING_WHARF = _(TERRAIN,  18); //79
    public static readonly E SUNKEN_TILE = _(TERRAIN,  20);
    public static readonly E TERRAIN_OVERLAY_FLAT = _(TERRAIN,  20);
    public static readonly E TERRAIN_OVERLAY_COLORED = _(TERRAIN,  21);
    public static readonly E DEBUG_ARROWPOST = _(TERRAIN,  24);
    public static readonly E BUILDING_WALL = _(TERRAIN,  24); // TODO
    public static readonly E BUILDING_FERRY = _(TERRAIN,  23);
    public static readonly E BUILDING_SHIPYARD = _(TERRAIN,  26); //77
    public static readonly E BUILDING_DOCK_UNUSED = _(TERRAIN,  27);
    public static readonly E BUILDING_WARSHIP_WHARF = _(TERRAIN,  28);
    public static readonly E TERRAIN_TREE_STUMPS = _(TERRAIN,  30);
    public static readonly E TERRAIN_FLOODPLAIN = _(TERRAIN,  31);
    public static readonly E TERRAIN_FLOODSYSTEM = _(TERRAIN,  33);
    public static readonly E TERRAIN_REEDS_GROWN = _(TERRAIN,  32);
    public static readonly E TERRAIN_ROAD = _(TERRAIN,  33); //112
    public static readonly E TERRAIN_RUBBLE = _(TERRAIN,  34); //114
    public static readonly E TERRAIN_RUBBLE_TENT = _(TERRAIN,  35); //119
    public static readonly E TERRAIN_RUBBLE_GENERAL = _(TERRAIN,  36); //120
    public static readonly E TERRAIN_MEADOW_WITH_GRASS = _(TERRAIN,  37); //138
    public static readonly E DEBUG_WIREFRAME_TILE = _(TERRAIN,  41);
    public static readonly E TERRAIN_ORE_ROCK = _(TERRAIN,  42);
    public static readonly E TERRAIN_DIRT_ROAD = _(TERRAIN,  43);
    public static readonly E TERRAIN_DESIRABILITY = _(TERRAIN,  45); //135
    public static readonly E TERRAIN_GRASS_PH = _(TERRAIN,  46); // terrain
    public static readonly E BUILDING_DOCK = _(TERRAIN,  49); //78
    public static readonly E BUILDING_WATER_LIFT = _(TERRAIN,  50); //25
    public static readonly E TERRAIN_MEADOW_STATIC_TALLGRASS = _(TERRAIN,  54);
    public static readonly E TERRAIN_MEADOW_STATIC_INNER = _(TERRAIN,  55);
    public static readonly E TERRAIN_OVERLAY_WATER = _(TERRAIN,  59);
    public static readonly E TERRAIN_OVERLAY_WATER_HOUSE = _(TERRAIN,  60);
    public static readonly E TERRAIN_DEEPWATER = _(TERRAIN,  61);
    public static readonly E BUILDING_BRIDGE = _(TERRAIN,  63);
    public static readonly E TERRAIN_GRASS_PH_EDGES = _(TERRAIN,  64);
    public static readonly E TERRAIN_GREEN_WATER_EDGES = _(TERRAIN,  65); // ?????
    public static readonly E TERRAIN_MEADOW_STATIC_OUTER = _(TERRAIN,  66);
    public static readonly E TERRAIN_WATER_SHORE = _(TERRAIN,  207); // TODO?
    public static readonly E TERRAIN_ACCESS_RAMP = _(TERRAIN,  216); // this isn't in Pharaoh

    // ////////////////// GENERAL

    public static readonly E BUILDING_STATUE_LARGE_1 = _(GENERAL,  7);
    public static readonly E BUILDING_STATUE_MEDIUM_1 = _(GENERAL,  8);
    public static readonly E GOD_ANGEL = _(GENERAL,  9);
    public static readonly E TOP_MENU_SIDEBAR = _(GENERAL,  11);
    public static readonly E PANEL_BUTTON = _(GENERAL,  15);
    public static readonly E BUILDING_TOWER = _(GENERAL,  17);
    public static readonly E BUILDING_SENET_HOUSE = _(GENERAL,  17); //213 //GROUP_BUILDING_HIPPODROME_1
    // public static readonly E BUILDING_TRANSPORT_WHARF = _(GENERAL,  17); // TODO
    // public static readonly E BUILDING_WARSHIP_WHARF = _(GENERAL,  28); // TODO
    public static readonly E BUILDING_CITY_PALACE = _(GENERAL,  18);
    public static readonly E BUILDING_MARKET = _(GENERAL,  22);
    public static readonly E BUILDING_WELL = _(GENERAL,  23);
    public static readonly E BUILDING_REEDS_COLLECTOR = _(GENERAL,  24);
    public static readonly E BUILDING_HOUSE_TENT = _(GENERAL,  26);
    public static readonly E BUILDING_HOUSE_SHACK = _(GENERAL,  27);
    public static readonly E BUILDING_HOUSE_HOVEL = _(GENERAL,  28);
    public static readonly E BUILDING_HOUSE_CASA = _(GENERAL,  29);
    public static readonly E BUILDING_HOUSE_INSULA_1 = _(GENERAL,  30);
    public static readonly E BUILDING_HOUSE_INSULA_2 = _(GENERAL,  31);
    public static readonly E BUILDING_HOUSE_VILLA_1 = _(GENERAL,  32);
    public static readonly E BUILDING_HOUSE_VILLA_2 = _(GENERAL,  33);
    public static readonly E BUILDING_HOUSE_PALACE_1 = _(GENERAL,  34);
    public static readonly E BUILDING_HOUSE_PALACE_2 = _(GENERAL,  35);
    public static readonly E BUILDING_HOUSE_VACANT_LOT = _(GENERAL,  36);
    public static readonly E BUILDING_FARMLAND = _(GENERAL,  37); //100
    public static readonly E BUILDING_GRANITE_QUARY = _(GENERAL,  38);
    public static readonly E BUILDING_TOWN_PALACE = _(GENERAL,  39);
    public static readonly E BUILDING_CLAY_PIT = _(GENERAL,  40);
    public static readonly E BUILDING_SCHOOL = _(GENERAL,  42); //41
    public static readonly E BUILDING_LIBRARY = _(GENERAL,  43); //42
    // public static readonly E BUILDING_ACADEMY = _(GENERAL,  43); // this isn't in Pharaoh
    public static readonly E BUILDING_PAPYRUS_WORKSHOP = _(GENERAL,  44);
    public static readonly E BUILDING_MARKET_FANCY = _(GENERAL,  45); //210
    public static readonly E BUILDING_JUGGLER_SCHOOL = _(GENERAL,  46); //51
    public static readonly E BUILDING_VILLAGE_PALACE = _(GENERAL,  47); // general
    public static readonly E BUILDING_PAVILLION = _(GENERAL,  48);
    public static readonly E FESTIVAL_SQUARE = _(GENERAL,  49);
    public static readonly E PAVILLION_SQUARE = _(GENERAL,  50);
    public static readonly E BUILDING_CONSERVATORY = _(GENERAL,  51); //49
    public static readonly E BUILDING_DANCE_SCHOOL = _(GENERAL,  52); //50
    public static readonly E BUILDING_FOUNTAIN_4 = _(GENERAL,  53); // this isn't in Pharaoh
    public static readonly E BUILDING_FOUNTAIN_1 = _(GENERAL,  54); // this isn't in Pharaoh
    public static readonly E BUILDING_FOUNTAIN_2 = _(GENERAL,  55); // this isn't in Pharaoh
    public static readonly E BUILDING_FOUNTAIN_3 = _(GENERAL,  56); // this isn't in Pharaoh
    public static readonly E BUILDING_GUILD_BRICKLAYERS = _(GENERAL,  57);
    public static readonly E BANDSTAND_SQUARE = _(GENERAL,  58);
    public static readonly E TERRAIN_GARDEN = _(GENERAL,  59);
    public static readonly E BUILDING_WORKSHOP_RAW_MATERIAL = _(GENERAL,  60);
    public static readonly E RESOURCE_STOCK_PAPYRUS_3  = _(GENERAL,  60);
    public static readonly E BUILDING_STATUE_SMALL_1 = _(GENERAL,  61);
    // public static readonly E BUILDING_SENATE = _(GENERAL,  62); // this isn't in Pharaoh
    public static readonly E BUILDING_COURTHOUSE = _(GENERAL,  62);
    public static readonly E BUILDING_TAX_COLLECTOR = _(GENERAL,  63);
    public static readonly E BUILDING_POLICE_STATION = _(GENERAL,  64);
    public static readonly E BUILDING_TIMBER_YARD = _(GENERAL,  65);
    // public static readonly E BUILDING_FORT_JAVELIN = _(GENERAL,  66); //202
    // public static readonly E BUILDING_FORT_LEGIONARY = _(GENERAL,  66); //204
    // public static readonly E FIGURE_FORT_MOUNTED = _(GENERAL,  66); //232
    public static readonly E BUILDING_FORT = _(GENERAL,  66);
    public static readonly E BUILDING_DENTIST = _(GENERAL,  67);
    public static readonly E BUILDING_APOTHECARY = _(GENERAL,  68);
    public static readonly E BUILDING_WATER_SUPPLY = _(GENERAL,  69);
    public static readonly E BUILDING_PHYSICIAN = _(GENERAL,  70);
    public static readonly E BUILDING_TEMPLE_RA = _(GENERAL,  21); //72
    public static readonly E BUILDING_TEMPLE_PTAH = _(GENERAL,  20); //73
    public static readonly E BUILDING_TEMPLE_OSIRIS = _(GENERAL,  25); //71
    public static readonly E BUILDING_TEMPLE_SETH = _(GENERAL,  19); //74
    public static readonly E BUILDING_TEMPLE_BAST = _(GENERAL,  76); //75
    public static readonly E BUILDING_SHRINE_OSIRIS = _(GENERAL,  75);
    public static readonly E BUILDING_SHRINE_RA = _(GENERAL,  74);
    public static readonly E BUILDING_SHRINE_PTAH = _(GENERAL,  73);
    public static readonly E BUILDING_SHRINE_SETH = _(GENERAL,  72);
    public static readonly E BUILDING_SHRINE_BAST = _(GENERAL,  71);
    // public static readonly E BUILDING_ORACLE = _(GENERAL,  76); // this isn't in Pharaoh
    public static readonly E BUILDING_WORKCAMP = _(GENERAL,  77);
    public static readonly E BUILDING_FIREHOUSE = _(GENERAL,  78);
    public static readonly E BUILDING_ENGINEERS_POST = _(GENERAL,  81);
    public static readonly E BUILDING_WAREHOUSE = _(GENERAL,  82);
    public static readonly E BUILDING_WAREHOUSE_STORAGE_EMPTY = _(GENERAL,  83);
    public static readonly E BUILDING_WAREHOUSE_STORAGE_FILLED = _(GENERAL,  84);
    public static readonly E BUILDING_GOVERNORS_HOUSE = _(GENERAL,  85);
    public static readonly E BUILDING_GOVERNORS_VILLA = _(GENERAL,  86);
    public static readonly E BUILDING_GOVERNORS_PALACE = _(GENERAL,  87);
    public static readonly E BUILDING_GUILD_STONEMASONS = _(GENERAL,  88);
    public static readonly E SIDEBAR_BRIEFING_ROTATE_BUTTONS = _(GENERAL,  89);
    public static readonly E SIDEBAR_ADVISORS_EMPIRE = _(GENERAL,  89); //13
    public static readonly E MESSAGE_ICON = _(GENERAL,  90);
    public static readonly E BUILDING_GUILD_CARPENTERS = _(GENERAL,  91);
    public static readonly E BUILDING_BANDSTAND = _(GENERAL,  92); //45
    public static readonly E LABOR_PRIORITY_LOCK = _(GENERAL,  94);
    public static readonly E OK_CANCEL_SCROLL_BUTTONS = _(GENERAL,  96);
    public static readonly E PLAGUE_SKULL = _(GENERAL,  97); //227
    public static readonly E BUILDING_ROADBLOCK = _(GENERAL,  98);
    public static readonly E BUILDING_GRANARY = _(GENERAL,  99);
    public static readonly E BUILDING_FARM_CROPS_PH = _(GENERAL,  100);
    public static readonly E FIGURE_EXPLOSION = _(GENERAL,  102); // exception sprites in General/Sprites.bmp
    public static readonly E OVERLAY_COLUMN = _(GENERAL,  103);
    public static readonly E BUILDING_CATTLE_RANCH = _(GENERAL,  105);
    public static readonly E MESSAGE_ADVISOR_BUTTONS = _(GENERAL,  106); //199
    public static readonly E SINGLE_SQUARE = _(GENERAL,  107);
    public static readonly E SIDEBAR_UPPER_BUTTONS = _(GENERAL,  110);
    public static readonly E GOD_BOLT = _(GENERAL,  111); //225
    public static readonly E BOOTH_SQUARE = _(GENERAL,  112);
    public static readonly E BUILDING_BOOTH = _(GENERAL,  114); //46
    public static readonly E BUILDING_BEER_WORKSHOP = _(GENERAL,  116); //44
    public static readonly E BUILD_MENU_CATEGORIES = _(GENERAL,  117);
    public static readonly E BUILDING_CHARIOT_MAKER = _(GENERAL,  120); //52
    public static readonly E SIDE_PANEL = _(GENERAL,  121); //12
    public static readonly E BUILDING_LINEN_WORKSHOP = _(GENERAL,  122);
    public static readonly E BUILDING_WEAPONS_WORKSHOP = _(GENERAL,  123);
    public static readonly E BUILDING_JEWELS_WORKSHOP = _(GENERAL,  119); //124
    public static readonly E BUILDING_BRICKS_WORKSHOP = _(GENERAL,  124);
    public static readonly E BUILDING_POTTERY_WORKSHOP = _(GENERAL,  125);
    public static readonly E FIGURE_FORT_FLAGS = _(GENERAL,  126);
    public static readonly E FIGURE_FORT_STANDARD_ICONS = _(GENERAL,  127);
    public static readonly E ADVISOR_ICONS = _(GENERAL,  128);
    public static readonly E RESOURCE_ICONS = _(GENERAL,  129);
    public static readonly E DIALOG_BACKGROUND = _(GENERAL,  132);
    public static readonly E SUNKEN_TEXTBOX_BACKGROUND = _(GENERAL,  133);
    public static readonly E CONTEXT_ICONS = _(GENERAL,  134);
    public static readonly E BUILDING_TOWER_2 = _(GENERAL,  135);
    public static readonly E SIDEBAR_BUTTONS = _(GENERAL,  136); //92
    public static readonly E EDITOR_SIDEBAR_BUTTONS = _(GENERAL,  137);
    public static readonly E BUILDING_WALLS = _(GENERAL,  138);
    public static readonly E FIGURE_FLOTSAM_1 = _(GENERAL,  139); //154
    public static readonly E FIGURE_MAP_FLAG_FLAGS = _(GENERAL,  139);
    public static readonly E FIGURE_MAP_FLAG_ICONS = _(GENERAL,  140);
    public static readonly E MINIMAP_EMPTY_LAND = _(GENERAL,  141);
    public static readonly E MINIMAP_WATER = _(GENERAL,  142);
    public static readonly E MINIMAP_TREE = _(GENERAL,  143);
    public static readonly E MINIMAP_REEDS = _(GENERAL,  144);
    public static readonly E MINIMAP_ROCK = _(GENERAL,  145);
    public static readonly E MINIMAP_MEADOW = _(GENERAL,  146);
    public static readonly E MINIMAP_FLOODPLAIN = _(GENERAL,  146);
    public static readonly E MINIMAP_ROAD = _(GENERAL,  147);
    public static readonly E MINIMAP_HOUSE = _(GENERAL,  148);
    public static readonly E MINIMAP_BUILDING = _(GENERAL,  149);
    public static readonly E MINIMAP_WALL = _(GENERAL,  150);
    public static readonly E MINIMAP_AQUEDUCT = _(GENERAL,  151);
    public static readonly E MINIMAP_BLACK = _(GENERAL,  152);
    public static readonly E FIGURE_FLOTSAM_0 = _(GENERAL,  153); // TODO?
    public static readonly E FIGURE_FLOTSAM_2 = _(GENERAL,  155); // TODO?
    public static readonly E FIGURE_FLOTSAM_3 = _(GENERAL,  156); // TODO?
    public static readonly E POPULATION_GRAPH_BAR = _(GENERAL,  157);
    public static readonly E BULLET = _(GENERAL,  158);
    public static readonly E MENU_ADVISOR_BUTTONS = _(GENERAL,  159);
    public static readonly E MENU_ADVISOR_LAYOUT = _(GENERAL,  160);
    public static readonly E BUILDING_GATEHOUSE = _(GENERAL,  161);
    public static readonly E BUILDING_MARBLE_QUARRY = _(GENERAL,  162);
    public static readonly E BUILDING_BARRACKS = _(GENERAL,  166);
    public static readonly E TERRAIN_PLAZA = _(GENERAL,  168); //58
    public static readonly E BUILDING_LIMESTONE_QUARRY = _(GENERAL,  170); //39
    public static readonly E TRADE_AMOUNT = _(GENERAL,  171); //243
    public static readonly E EMPIRE_PANELS = _(GENERAL,  172);
    public static readonly E BUILDING_MILITARY_ACADEMY = _(GENERAL,  173); //201
    public static readonly E BORDERED_BUTTON = _(GENERAL,  174); //208
    public static readonly E BUILDING_MORTUARY = _(GENERAL,  175); //70
    public static readonly E EMPIRE_CITY_PH_PHARAOH = _(GENERAL,  175);
    public static readonly E BUILDING_HUNTING_LODGE = _(GENERAL,  176);
    public static readonly E EMPIRE_CITY_PH_OURS = _(GENERAL,  176);
    public static readonly E EMPIRE_CITY = _(GENERAL,  177); //174
    public static readonly E EMPIRE_TRADE_ROUTE_TYPE = _(GENERAL,  179);
    public static readonly E BUILDING_NATIVE = _(GENERAL,  183);
    public static readonly E BUILDING_MISSION_POST = _(GENERAL,  184);
    public static readonly E BUILDING_BATHHOUSE_NO_WATER = _(GENERAL,  185);
    public static readonly E BUILDING_GOLD_MINE = _(GENERAL,  185);
    public static readonly E BUILDING_UNUSED_BEIGE_MINE = _(GENERAL,  186);
    public static readonly E BUILDING_GEMSTONE_MINE = _(GENERAL,  188);
    public static readonly E BUILDING_STONE_QUARRY = _(GENERAL,  187); //38
    public static readonly E RATINGS_COLUMN = _(GENERAL,  189);
    public static readonly E BUTTON_EXCLAMATION = _(GENERAL,  193);
    public static readonly E BUILDING_COPPER_MINE = _(GENERAL,  196);
    public static readonly E BUILDING_SANDSTONE_MINE = _(GENERAL,  197);
    public static readonly E RESOURCE_STOCK_BEER_3 = _(GENERAL,  198);
    public static readonly E RESOURCE_STOCK_LINEN_5  = _(GENERAL,  199);
    public static readonly E RESOURCE_STOCK_GEMS_2  = _(GENERAL,  200);
    public static readonly E RESOURCE_STOCK_WEAPONS_2 = _(GENERAL,  201);
    public static readonly E RESOURCE_STOCK_WOOD_5  = _(GENERAL,  202);
    public static readonly E RESOURCE_STOCK_COPPER_2  = _(GENERAL,  203);
    public static readonly E RESOURCE_STOCK_STRAW_2 = _(GENERAL,  204);
    public static readonly E RESOURCE_STOCK_GAMEMEAT_5 = _(GENERAL,  205); //173
    // public static readonly E BUILDING_TRIUMPHAL_ARCH = _(GENERAL,  205); // this isn't in Pharaoh
    public static readonly E RESOURCE_STOCK_REEDS_5  = _(GENERAL,  206);
    public static readonly E RESOURCE_STOCK_CLAY_2 = _(GENERAL,  207);
    public static readonly E RESOURCE_STOCK_BARLEY_2 = _(GENERAL,  208);
    public static readonly E RESOURCE_STOCK_CHARIOTS_2  = _(GENERAL,  209);
    public static readonly E RESOURCE_STOCK_FLAX_2  = _(GENERAL,  210);
    // public static readonly E BUILDING_BATHHOUSE_FANCY_WATER = _(GENERAL,  211); // this isn't in Pharaoh
    // public static readonly E BUILDING_BATHHOUSE_FANCY_NO_WATER = _(GENERAL,  212); // this isn't in Pharaoh
    public static readonly E MINIMAP_DUNES = _(GENERAL,  211);
    public static readonly E TINY_ARROWS = _(GENERAL,  212);
    // public static readonly E BUILDING_HIPPODROME_2 = _(GENERAL,  214); // this isn't in Pharaoh
    public static readonly E BUILDING_GATEHOUSE_2 = _(GENERAL,  220);
    // public static readonly E BUILDING_SENATE_FANCY = _(GENERAL,  221); // this isn't in Pharaoh
    public static readonly E FORT_ICONS = _(GENERAL,  222); // TODO?
    // public static readonly E EMPIRE_FOREIGN_CITY = _(GENERAL,  223); // this isn't in Pharaoh
    public static readonly E BUILDING_FARM_HOUSE = _(GENERAL,  225); //37
    // public static readonly E BUILDING_TRADE_CENTER_FLAG = _(GENERAL,  238); // this isn't in Pharaoh
    public static readonly E TERRAIN_ENTRY_EXIT_FLAGS = _(GENERAL,  240);
    public static readonly E FIGURE_FORT_STANDARD_POLE = _(GENERAL,  241);
    // public static readonly E FIGURE_FLOTSAM_SHEEP = _(GENERAL,  242); // this isn't in Pharaoh
    // public static readonly E BULIDING_GATEHOUSE = _(GENERAL,  248); // this isn't in Pharaoh
    public static readonly E SELECT_MISSION_BUTTON = _(GENERAL,  254); // TODO

    // ////////////////// UNLOADED

    public static readonly E SYSTEM_GRAPHICS = _(UNLOADED,  0);
    public static readonly E FORT_FORMATIONS = _(UNLOADED,  1); //197
    public static readonly E ADVISOR_RATINGS_BACKGROUND = _(UNLOADED,  2); //195
    public static readonly E BIGPEOPLE = _(UNLOADED,  3);
    public static readonly E PROMO_3 = _(UNLOADED,  4); //188
    public static readonly E PROMO_2 = _(UNLOADED,  5); //187
    public static readonly E PROMO_1 = _(UNLOADED,  6); //186
    public static readonly E LOGO = _(UNLOADED,  7); //162
    public static readonly E CONFIG_BACKGROUND = _(UNLOADED,  8); //161
    public static readonly E SCORES_BACKGROUND = _(UNLOADED,  9);
    public static readonly E WIN_GAME_BACKGROUND = _(UNLOADED,  9); //160
    public static readonly E MESSAGE_IMAGES = _(UNLOADED,  10); //159
    public static readonly E ADVISOR_BACKGROUND = _(UNLOADED,  11); //136
    public static readonly E SELECT_MISSION_BACKGROUND = _(UNLOADED,  12); //244
    public static readonly E MAIN_MENU_BACKGROUND = _(UNLOADED,  14);
    public static readonly E MAP_SELECTION_CCK = _(UNLOADED,  15); //246
    public static readonly E NEXT_MISSION_SELECT = _(UNLOADED,  16); //245 <----- ?????????????????
    public static readonly E LOADING_SCREEN = _(UNLOADED,  17); //251
    public static readonly E INTERMEZZO_BACKGROUND = _(UNLOADED,  18); //252
    public static readonly E PANEL_WINDOWS_DESERT = _(UNLOADED,  19); //253
    public static readonly E PANEL_WINDOWS = _(UNLOADED,  21); //95
    // //#define ?????  IMAGE_COLLECTION_UNLOADED,  22 //80
    public static readonly E PORTRAITS = _(UNLOADED,  25); //190
    public static readonly E SCENARIO_IMAGE = _(UNLOADED,  28); //247
    public static readonly E PLAYER_SELECTION = _(UNLOADED,  29);
    public static readonly E MAP_SELECTION_CAMPAIGN = _(UNLOADED,  30);
    public static readonly E GAME_MENU = _(UNLOADED,  31);
    public static readonly E MAP_SELECTION_CUSTOM = _(UNLOADED,  32);
    public static readonly E MAP_SELECTION_HISTORY = _(UNLOADED,  33);

    // ////////////////// SPRMAIN

    public static readonly E FIGURE_HUNTER_ARROW = _(SPR_MAIN,  0);
    public static readonly E FIGURE_ENGINEER = _(SPR_MAIN,  4); //110
    public static readonly E FIGURE_PREFECT = _(SPR_MAIN,  6); //117
    public static readonly E FIGURE_PREFECT_WITH_BUCKET = _(SPR_MAIN,  8); //121
    public static readonly E FIGURE_DELIVERY_BOY = _(SPR_MAIN,  9); //209
    public static readonly E FIGURE_HOMELESS = _(SPR_MAIN,  12); //118
    public static readonly E FIGURE_IMMIGRANT = _(SPR_MAIN,  14); //108
    public static readonly E FIGURE_MARKET_LADY = _(SPR_MAIN,  16); //106
    public static readonly E FIGURE_MARKET_LADY_2 = _(SPR_MAIN,  18);
    public static readonly E FIGURE_POLICEMAN = _(SPR_MAIN,  20);
    public static readonly E FIGURE_CRIMINAL = _(SPR_MAIN,  32); //115
    public static readonly E FIGURE_SHIP = _(SPR_MAIN,  34); //165
    public static readonly E FIGURE_REED_GATHERER = _(SPR_MAIN,  37);
    public static readonly E FIGURE_TAX_COLLECTOR = _(SPR_MAIN,  41); //104
    public static readonly E FIGURE_CARTPUSHER = _(SPR_MAIN,  43); //107
    public static readonly E FIGURE_HUNTER = _(SPR_MAIN,  45);
    public static readonly E FIGURE_TRADE_CARAVAN_DONKEY = _(SPR_MAIN,  52);
    // public static readonly E FIGURE_MIGRANT_CART = _(SPR_MAIN,  52); //131
    public static readonly E FIGURE_SCHOOL_CHILD = _(SPR_MAIN,  57); //105
    public static readonly E FIGURE_WATER_CARRIER = _(SPR_MAIN,  59);
    public static readonly E FIGURE_ARCHER_PH = _(SPR_MAIN,  62);
    public static readonly E FIGURE_INFANTRY_PH = _(SPR_MAIN,  65);
    public static readonly E FIGURE_CHARIOTEER_PH = _(SPR_MAIN,  68);
    public static readonly E FIGURE_BATHHOUSE_WORKER = _(SPR_MAIN,  71); //88
    public static readonly E FIGURE_LUMBERJACK = _(SPR_MAIN,  73);
    public static readonly E FIGURE_CARTPUSHER_CART = _(SPR_MAIN,  77); //97
    public static readonly E FIGURE_DANCER_WHIP = _(SPR_MAIN,  109); // this isn't in Pharaoh
    public static readonly E FIGURE_SEAGULLS = _(SPR_MAIN,  114); //206
    public static readonly E FIGURE_WORKER_PH = _(SPR_MAIN,  116);
    public static readonly E FIGURE_DANCER = _(SPR_MAIN,  128); //101
    public static readonly E FIGURE_JUGGLER = _(SPR_MAIN,  130); //98
    public static readonly E FIGURE_LION = _(SPR_MAIN,  161); //163
    public static readonly E FIGURE_DOCTOR_SURGEON = _(SPR_MAIN,  180); //228
    public static readonly E FIGURE_BARBER = _(SPR_MAIN,  182); //116
    public static readonly E PRIEST_PTAH = _(SPR_MAIN,  187);
    public static readonly E FIGURE_MUSICIAN = _(SPR_MAIN,  191); //111
    public static readonly E PRIEST_SETH = _(SPR_MAIN,  193);
    public static readonly E FIGURE_TOWER_SENTRY = _(SPR_MAIN,  194); // TODO
    public static readonly E FIGURE_MORTUARY = _(SPR_MAIN,  195);
    public static readonly E PRIEST_OSIRIS = _(SPR_MAIN,  197);
    public static readonly E FIGURE_PRIEST = _(SPR_MAIN,  197); //91
    public static readonly E FIGURE_LABOR_SEEKER = _(SPR_MAIN,  206); //57
    public static readonly E FIGURE_MISSILE = _(SPR_MAIN,  198); // TODO
    public static readonly E FIGURE_BALLISTA = _(SPR_MAIN,  200); // TODO
    public static readonly E PRIEST_BAST = _(SPR_MAIN,  208);
    public static readonly E PRIEST_RA = _(SPR_MAIN,  210);
    public static readonly E FIGURE_CHARIOTEER = _(SPR_MAIN,  215); // this isn't in Pharaoh
    public static readonly E FIGURE_HIPPODROME_HORSE_1 = _(SPR_MAIN,  217); // // this isn't in Pharaoh this isn't in Pharaoh
    public static readonly E FIGURE_HIPPODROME_HORSE_2 = _(SPR_MAIN,  218); // this isn't in Pharaoh
    public static readonly E FIGURE_HIPPODROME_CART_1 = _(SPR_MAIN,  219); // this isn't in Pharaoh
    public static readonly E FIGURE_HIPPODROME_CART_2 = _(SPR_MAIN,  220); // this isn't in Pharaoh
    public static readonly E FIGURE_MAGISTRATE = _(SPR_MAIN,  212);
    public static readonly E FIGURE_SHIPWRECK = _(SPR_MAIN,  226); // this isn't in Pharaoh
    public static readonly E FIGURE_PATRICIAN = _(SPR_MAIN,  229); // this isn't in Pharaoh
    public static readonly E FIGURE_MISSIONARY = _(SPR_MAIN,  230); // this isn't in Pharaoh
    public static readonly E FIGURE_TEACHER_LIBRARIAN = _(SPR_MAIN,  201); //231
    public static readonly E FIGURE_SHEEP = _(SPR_MAIN,  233); // TODO
    public static readonly E FIGURE_OSTRICH = _(SPR_MAIN,  156); //234
    public static readonly E FIGURE_CROCODILE = _(SPR_MAIN,  23); //235
    public static readonly E FIGURE_CAESAR_LEGIONARY = _(SPR_MAIN,  236); // this isn't in Pharaoh
    public static readonly E FIGURE_CARTPUSHER_CART_MULTIPLE_FOOD = _(SPR_MAIN,  237); // this isn't in Pharaoh
    public static readonly E FIGURE_CARTPUSHER_CART_MULTIPLE_RESOURCE = _(SPR_MAIN,  250); // this isn't in Pharaoh

    // ////////////////// SPRAMBIENT

    public static readonly E WATER_LIFT_ANIM = _(SPR_AMBIENT,  1); // sprambient
    public static readonly E DANCERS_SHOW = _(SPR_AMBIENT,  6); //192
    public static readonly E JUGGLERS_SHOW = _(SPR_AMBIENT,  7); //191
    public static readonly E FIGURE_FISH = _(SPR_AMBIENT,  8);
    public static readonly E MUSICIANS_SHOW = _(SPR_AMBIENT,  9); //193
    public static readonly E FIGURE_TRADE_CARAVAN = _(SPR_AMBIENT,  20); //130
    public static readonly E FIGURE_HIPPO = _(SPR_AMBIENT,  22);
    public static readonly E FIGURE_ANTILOPE = _(SPR_AMBIENT,  30);
    public static readonly E FIGURE_HUNTER2 = _(SPR_AMBIENT,  36);
    public static readonly E SHIP_BUILDING_1 = _(SPR_AMBIENT,  45);
    public static readonly E GRANARY_ANIM_PH = _(SPR_AMBIENT,  47);
    public static readonly E MINES = _(SPR_AMBIENT,  48);
    public static readonly E WAREHOUSE_ANIM_PH = _(SPR_AMBIENT,  51);
    public static readonly E SHIP_BUILDING_2 = _(SPR_AMBIENT,  52);
    public static readonly E SHIP_BUILDING_3 = _(SPR_AMBIENT,  53);
    public static readonly E SHIP_BUILDING_4 = _(SPR_AMBIENT,  54);
    public static readonly E BUILDING_DOCK_DOCKERS = _(SPR_AMBIENT,  55); //171
    // //   #define GROUP_DOCK_WAITING  IMAGE_COLLECTION_SPR_AMBIENT,  55
    // //   #define GROUP_DOCK_UNLOADING  IMAGE_COLLECTION_SPR_AMBIENT,  56

    // ////////////////// MONUMENT

    public static readonly E MONUMENT_BLOCKS = _(MONUMENT,  1);
    public static readonly E MONUMENT_TERRAIN = _(MONUMENT,  2);
    public static readonly E MONUMENT_DITCHES_PHASE_1 = _(MONUMENT,  3);
    public static readonly E MONUMENT_DITCHES_PHASE_2 = _(MONUMENT,  4);
    public static readonly E MONUMENT_DITCHES_PHASE_3 = _(MONUMENT,  5);
    public static readonly E MONUMENT_DITCHES_PHASE_4 = _(MONUMENT,  6);
    public static readonly E MONUMENT_TOMB_FLOOR = _(MONUMENT,  7);
    public static readonly E MONUMENT_CORNER_POLES = _(MONUMENT,  8);
    public static readonly E MONUMENT_EXTERIORS_END_DRY = _(MONUMENT,  9);
    public static readonly E MONUMENT_EXTERIORS_RUNS = _(MONUMENT,  10);
    public static readonly E MONUMENT_EXTERIORS_END_WET = _(MONUMENT,  11);
    public static readonly E MONUMENT_EXTRA_BLOCKS = _(MONUMENT,  12);

    // ////////////////// TEMPLE

    public static readonly E BUILDING_TEMPLE_COMPLEX_MAIN = _(TEMPLE,  1);
    public static readonly E BUILDING_TEMPLE_COMPLEX_ORACLE = _(TEMPLE,  2);
    public static readonly E BUILDING_TEMPLE_COMPLEX_ALTAR = _(TEMPLE,  3);
    public static readonly E BUILDING_TEMPLE_COMPLEX_FLOORING = _(TEMPLE,  4);
    public static readonly E BUILDING_TEMPLE_COMPLEX_STATUE_1 = _(TEMPLE,  5);
    public static readonly E BUILDING_TEMPLE_COMPLEX_STATUE_2 = _(TEMPLE,  6);
    public static readonly E BUILDING_TEMPLE_COMPLEX_UPGRADES = _(TEMPLE,  7);

    // ////////////////// EXPANSION

    public static readonly E BIG_PEOPLE_2 = _(EXPANSION,  1);
    public static readonly E SCORPION_ICON = _(EXPANSION,  2);
    public static readonly E RESOURCE_ICONS_2 = _(EXPANSION,  3);
    public static readonly E BUILDING_WAREHOUSE_STORAGE_FILLED_2 = _(EXPANSION,  4);
    public static readonly E BUILDING_FARM_CROPS_HENNA = _(EXPANSION,  5);
    public static readonly E BUILDING_ZOO = _(EXPANSION,  6);
    public static readonly E BLOOD_TILES = _(EXPANSION,  7);
    public static readonly E BLOOD_FLOODPLAIN = _(EXPANSION,  8);
    public static readonly E BLOOD_FLOODSYSTEM = _(EXPANSION,  9);
    public static readonly E BLOOD_MARSHLANDS = _(EXPANSION,  11);
    public static readonly E BLOOD_TRANSPORT = _(EXPANSION,  13);
    public static readonly E BLOOD_WELL = _(EXPANSION,  24);
    public static readonly E BLOOD_WATER_SUPPLY = _(EXPANSION,  25);
    public static readonly E BUILDING_LAMP_WORKSHOP = _(EXPANSION,  26);
    public static readonly E BUILDING_PAINT_WORKSHOP = _(EXPANSION,  27);
    public static readonly E BUILDING_GUILD_ARTISANS = _(EXPANSION,  31);
    public static readonly E FROG_ICON = _(EXPANSION,  32);
    public static readonly E TERRAIN_CLIFF = _(EXPANSION,  33);
    public static readonly E BUILDING_STATUE_LARGE_2 = _(EXPANSION,  35);
    public static readonly E BUILDING_STATUE_MEDIUM_2 = _(EXPANSION,  36);
    public static readonly E BUILDING_STATUE_SMALL_2 = _(EXPANSION,  37);
    public static readonly E MISSION_SELECT_2 = _(EXPANSION,  38); // ????
    public static readonly E HISTORY_INFO_2 = _(EXPANSION,  39); // ????
    public static readonly E BLOOD_EDGES = _(EXPANSION,  40); // ????
    public static readonly E BREAKAWAY_SPLASH_LOGO = _(EXPANSION,  41); // ????

    // ////////////////// TODO? (editor image groups)

    // public static readonly E EDITOR_SCENARIO_IMAGE = _(0, 22);
    // public static readonly E EDITOR_BUILDING_CROPS = _(0, 23);
    // public static readonly E EDITOR_EMPIRE_MAP = _(0, 47);
    // public static readonly E EDITOR_SIDE_PANEL = _(0, 80);
    // public static readonly E EDITOR_RESOURCE_ICONS = _(0, 129);
    // public static readonly E EDITOR_EMPIRE_PANELS = _(0, 172);
    // public static readonly E EDITOR_EMPIRE_RESOURCES = _(0, 173);
    // public static readonly E EDITOR_BUILDING_NATIVE = _(0, 183);
    // public static readonly E EDITOR_EMPIRE_FOREIGN_CITY = _(0, 223);
    // public static readonly E EDITOR_TRADE_AMOUNT = _(0, 243);

}