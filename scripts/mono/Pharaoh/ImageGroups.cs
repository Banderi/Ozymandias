public enum ImagePaks : int {
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
    FONT,
    //
    TEMPLE,
    MONUMENT,
    //
    EXPANSION,
    EXPANSION_SPR,
    //
};
// using System;

// using ImagePak = System.String;
// public class ImagePaks {
//     public const ImagePak UNLOADED = "";
//     //
//     public const ImagePak SPR_MAIN = "";
//     public const ImagePak ENEMY = "";
//     //
//     public const ImagePak GENERAL = "";
//     public const ImagePak TERRAIN = "";
//     //
//     public const ImagePak EMPIRE = "";
//     public const ImagePak SPR_AMBIENT = "";
//     //
//     public const ImagePak FONT = "";
//     //
//     public const ImagePak TEMPLE = "";
//     public const ImagePak  MONUMENT = "";
//     //
//     public const ImagePak EXPANSION = "";
//     public const ImagePak EXPANSION_SPR = "";
//     //
// };

public readonly struct ImageGroup {
    public readonly ImagePaks pak;
    public readonly int tag_idx;
	public ImageGroup(ImagePaks a, int b) {
		pak = a;
		tag_idx = b;
	}
}

public class ImageGroups {
    
	public static readonly ImageGroup NONE = new ImageGroup(0, 0);
    
    ////////////////// FONT

    public static readonly ImageGroup FONT = new ImageGroup(ImagePaks.FONT,  1);


    ////////////////// EMPIRE MAP

    public static readonly ImageGroup EMPIRE_MAP = new ImageGroup(ImagePaks.EMPIRE,  1);

    ////////////////// TERRAIN

    public static readonly ImageGroup TERRAIN_BLACK = new ImageGroup(ImagePaks.TERRAIN,  1);
    public static readonly ImageGroup TERRAIN_SHRUB = new ImageGroup(ImagePaks.TERRAIN,  2);
    public static readonly ImageGroup TERRAIN_UGLY_GRASS = new ImageGroup(ImagePaks.TERRAIN,  3);
    public static readonly ImageGroup TERRAIN_TREE = new ImageGroup(ImagePaks.TERRAIN,  4);
    public static readonly ImageGroup TERRAIN_WATER = new ImageGroup(ImagePaks.TERRAIN,  5);
    public static readonly ImageGroup TERRAIN_EARTHQUAKE = new ImageGroup(ImagePaks.TERRAIN,  6);
    public static readonly ImageGroup TERRAIN_EMPTY_LAND_ALT = new ImageGroup(ImagePaks.TERRAIN,  7);
    public static readonly ImageGroup TERRAIN_ROCK = new ImageGroup(ImagePaks.TERRAIN,  8); //239
    public static readonly ImageGroup TERRAIN_ELEVATION_ROCK = new ImageGroup(ImagePaks.TERRAIN,  8); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_AQUEDUCT = new ImageGroup(ImagePaks.TERRAIN,  9); //19
    public static readonly ImageGroup TERRAIN_ELEVATION = new ImageGroup(ImagePaks.TERRAIN,  9); // this isn't in Pharaoh
    public static readonly ImageGroup TERRAIN_EMPTY_LAND = new ImageGroup(ImagePaks.TERRAIN,  10);
    public static readonly ImageGroup TERRAIN_REEDS = new ImageGroup(ImagePaks.TERRAIN,  11);
    public static readonly ImageGroup BUILDING_TRANSPORT_WHARF = new ImageGroup(ImagePaks.TERRAIN,  17);
    public static readonly ImageGroup BUILDING_FISHING_WHARF = new ImageGroup(ImagePaks.TERRAIN,  18); //79
    public static readonly ImageGroup SUNKEN_TILE = new ImageGroup(ImagePaks.TERRAIN,  20);
    public static readonly ImageGroup TERRAIN_OVERLAY_FLAT = new ImageGroup(ImagePaks.TERRAIN,  20);
    public static readonly ImageGroup TERRAIN_OVERLAY_COLORED = new ImageGroup(ImagePaks.TERRAIN,  21);
    public static readonly ImageGroup DEBUG_ARROWPOST = new ImageGroup(ImagePaks.TERRAIN,  24);
    public static readonly ImageGroup BUILDING_WALL = new ImageGroup(ImagePaks.TERRAIN,  24); // TODO
    public static readonly ImageGroup BUILDING_FERRY = new ImageGroup(ImagePaks.TERRAIN,  23);
    public static readonly ImageGroup BUILDING_SHIPYARD = new ImageGroup(ImagePaks.TERRAIN,  26); //77
    public static readonly ImageGroup BUILDING_DOCK_UNUSED = new ImageGroup(ImagePaks.TERRAIN,  27);
    public static readonly ImageGroup BUILDING_WARSHIP_WHARF = new ImageGroup(ImagePaks.TERRAIN,  28);
    public static readonly ImageGroup TERRAIN_TREE_STUMPS = new ImageGroup(ImagePaks.TERRAIN,  30);
    public static readonly ImageGroup TERRAIN_FLOODPLAIN = new ImageGroup(ImagePaks.TERRAIN,  31);
    public static readonly ImageGroup TERRAIN_FLOODSYSTEM = new ImageGroup(ImagePaks.TERRAIN,  33);
    public static readonly ImageGroup TERRAIN_REEDS_GROWN = new ImageGroup(ImagePaks.TERRAIN,  32);
    public static readonly ImageGroup TERRAIN_ROAD = new ImageGroup(ImagePaks.TERRAIN,  33); //112
    public static readonly ImageGroup TERRAIN_RUBBLE = new ImageGroup(ImagePaks.TERRAIN,  34); //114
    public static readonly ImageGroup TERRAIN_RUBBLE_TENT = new ImageGroup(ImagePaks.TERRAIN,  35); //119
    public static readonly ImageGroup TERRAIN_RUBBLE_GENERAL = new ImageGroup(ImagePaks.TERRAIN,  36); //120
    public static readonly ImageGroup TERRAIN_MEADOW_WITH_GRASS = new ImageGroup(ImagePaks.TERRAIN,  37); //138
    public static readonly ImageGroup DEBUG_WIREFRAME_TILE = new ImageGroup(ImagePaks.TERRAIN,  41);
    public static readonly ImageGroup TERRAIN_ORE_ROCK = new ImageGroup(ImagePaks.TERRAIN,  42);
    public static readonly ImageGroup TERRAIN_DIRT_ROAD = new ImageGroup(ImagePaks.TERRAIN,  43);
    public static readonly ImageGroup TERRAIN_DESIRABILITY = new ImageGroup(ImagePaks.TERRAIN,  45); //135
    public static readonly ImageGroup TERRAIN_GRASS_PH = new ImageGroup(ImagePaks.TERRAIN,  46); // terrain
    public static readonly ImageGroup BUILDING_DOCK = new ImageGroup(ImagePaks.TERRAIN,  49); //78
    public static readonly ImageGroup BUILDING_WATER_LIFT = new ImageGroup(ImagePaks.TERRAIN,  50); //25
    public static readonly ImageGroup TERRAIN_MEADOW_STATIC_TALLGRASS = new ImageGroup(ImagePaks.TERRAIN,  54);
    public static readonly ImageGroup TERRAIN_MEADOW_STATIC_INNER = new ImageGroup(ImagePaks.TERRAIN,  55);
    public static readonly ImageGroup TERRAIN_OVERLAY_WATER = new ImageGroup(ImagePaks.TERRAIN,  59);
    public static readonly ImageGroup TERRAIN_OVERLAY_WATER_HOUSE = new ImageGroup(ImagePaks.TERRAIN,  60);
    public static readonly ImageGroup TERRAIN_DEEPWATER = new ImageGroup(ImagePaks.TERRAIN,  61);
    public static readonly ImageGroup BUILDING_BRIDGE = new ImageGroup(ImagePaks.TERRAIN,  63);
    public static readonly ImageGroup TERRAIN_GRASS_PH_EDGES = new ImageGroup(ImagePaks.TERRAIN,  64);
    public static readonly ImageGroup TERRAIN_GREEN_WATER_EDGES = new ImageGroup(ImagePaks.TERRAIN,  65); // ?????
    public static readonly ImageGroup TERRAIN_MEADOW_STATIC_OUTER = new ImageGroup(ImagePaks.TERRAIN,  66);
    public static readonly ImageGroup TERRAIN_WATER_SHORE = new ImageGroup(ImagePaks.TERRAIN,  207); // TODO?
    public static readonly ImageGroup TERRAIN_ACCESS_RAMP = new ImageGroup(ImagePaks.TERRAIN,  216); // this isn't in Pharaoh

    // ////////////////// GENERAL

    public static readonly ImageGroup BUILDING_STATUE_LARGE_1 = new ImageGroup(ImagePaks.GENERAL,  7);
    public static readonly ImageGroup BUILDING_STATUE_MEDIUM_1 = new ImageGroup(ImagePaks.GENERAL,  8);
    public static readonly ImageGroup TOP_MENU_SIDEBAR = new ImageGroup(ImagePaks.GENERAL,  11);
    public static readonly ImageGroup PANEL_BUTTON = new ImageGroup(ImagePaks.GENERAL,  15);
    public static readonly ImageGroup BUILDING_TOWER = new ImageGroup(ImagePaks.GENERAL,  17);
    public static readonly ImageGroup BUILDING_MARKET = new ImageGroup(ImagePaks.GENERAL,  22);
    public static readonly ImageGroup BUILDING_WELL = new ImageGroup(ImagePaks.GENERAL,  23);
    public static readonly ImageGroup BUILDING_HOUSE_TENT = new ImageGroup(ImagePaks.GENERAL,  26);
    public static readonly ImageGroup BUILDING_HOUSE_SHACK = new ImageGroup(ImagePaks.GENERAL,  27);
    public static readonly ImageGroup BUILDING_HOUSE_HOVEL = new ImageGroup(ImagePaks.GENERAL,  28);
    public static readonly ImageGroup BUILDING_HOUSE_CASA = new ImageGroup(ImagePaks.GENERAL,  29);
    public static readonly ImageGroup BUILDING_HOUSE_INSULA_1 = new ImageGroup(ImagePaks.GENERAL,  30);
    public static readonly ImageGroup BUILDING_HOUSE_INSULA_2 = new ImageGroup(ImagePaks.GENERAL,  31);
    public static readonly ImageGroup BUILDING_HOUSE_VILLA_1 = new ImageGroup(ImagePaks.GENERAL,  32);
    public static readonly ImageGroup BUILDING_HOUSE_VILLA_2 = new ImageGroup(ImagePaks.GENERAL,  33);
    public static readonly ImageGroup BUILDING_HOUSE_PALACE_1 = new ImageGroup(ImagePaks.GENERAL,  34);
    public static readonly ImageGroup BUILDING_HOUSE_PALACE_2 = new ImageGroup(ImagePaks.GENERAL,  35);
    public static readonly ImageGroup BUILDING_HOUSE_VACANT_LOT = new ImageGroup(ImagePaks.GENERAL,  36);
    public static readonly ImageGroup BUILDING_FARM_HOUSE = new ImageGroup(ImagePaks.GENERAL,  225); //37
    public static readonly ImageGroup BUILDING_CLAY_PIT = new ImageGroup(ImagePaks.GENERAL,  40);
    public static readonly ImageGroup BUILDING_SCHOOL = new ImageGroup(ImagePaks.GENERAL,  42); //41
    public static readonly ImageGroup BUILDING_LIBRARY = new ImageGroup(ImagePaks.GENERAL,  43); //42
    public static readonly ImageGroup BUILDING_ACADEMY = new ImageGroup(ImagePaks.GENERAL,  43); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_PAPYRUS_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  44);
    public static readonly ImageGroup BUILDING_BANDSTAND = new ImageGroup(ImagePaks.GENERAL,  92); //45
    public static readonly ImageGroup BUILDING_BOOTH = new ImageGroup(ImagePaks.GENERAL,  114); //46
    public static readonly ImageGroup BUILDING_PAVILLION = new ImageGroup(ImagePaks.GENERAL,  48);
    public static readonly ImageGroup BUILDING_CONSERVATORY = new ImageGroup(ImagePaks.GENERAL,  51); //49
    public static readonly ImageGroup BUILDING_DANCE_SCHOOL = new ImageGroup(ImagePaks.GENERAL,  52); //50
    public static readonly ImageGroup BUILDING_JUGGLER_SCHOOL = new ImageGroup(ImagePaks.GENERAL,  46); //51
    public static readonly ImageGroup BUILDING_FOUNTAIN_4 = new ImageGroup(ImagePaks.GENERAL,  53); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_FOUNTAIN_1 = new ImageGroup(ImagePaks.GENERAL,  54); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_FOUNTAIN_2 = new ImageGroup(ImagePaks.GENERAL,  55); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_FOUNTAIN_3 = new ImageGroup(ImagePaks.GENERAL,  56); // this isn't in Pharaoh
    public static readonly ImageGroup TERRAIN_PLAZA = new ImageGroup(ImagePaks.GENERAL,  168); //58
    public static readonly ImageGroup TERRAIN_GARDEN = new ImageGroup(ImagePaks.GENERAL,  59);
    public static readonly ImageGroup BUILDING_WORKSHOP_RAW_MATERIAL = new ImageGroup(ImagePaks.GENERAL,  60);
    public static readonly ImageGroup BUILDING_STATUE_SMALL_1 = new ImageGroup(ImagePaks.GENERAL,  61);
    // public static readonly ImageGroup BUILDING_SENATE = new ImageGroup(ImagePaks.GENERAL,  62); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_COURTHOUSE = new ImageGroup(ImagePaks.GENERAL,  62);
    public static readonly ImageGroup BUILDING_TAX_COLLECTOR = new ImageGroup(ImagePaks.GENERAL,  63);
    public static readonly ImageGroup BUILDING_POLICE_STATION = new ImageGroup(ImagePaks.GENERAL,  64);
    public static readonly ImageGroup BUILDING_TIMBER_YARD = new ImageGroup(ImagePaks.GENERAL,  65);
    public static readonly ImageGroup BUILDING_FORT = new ImageGroup(ImagePaks.GENERAL,  66);
    public static readonly ImageGroup BUILDING_DENTIST = new ImageGroup(ImagePaks.GENERAL,  67);
    public static readonly ImageGroup BUILDING_APOTHECARY = new ImageGroup(ImagePaks.GENERAL,  68);
    public static readonly ImageGroup BUILDING_WATER_SUPPLY = new ImageGroup(ImagePaks.GENERAL,  69);
    public static readonly ImageGroup BUILDING_PHYSICIAN = new ImageGroup(ImagePaks.GENERAL,  70);
    public static readonly ImageGroup BUILDING_MORTUARY = new ImageGroup(ImagePaks.GENERAL,  175); //70
    public static readonly ImageGroup BUILDING_TEMPLE_OSIRIS = new ImageGroup(ImagePaks.GENERAL,  25); //71
    public static readonly ImageGroup BUILDING_TEMPLE_RA = new ImageGroup(ImagePaks.GENERAL,  21); //72
    public static readonly ImageGroup BUILDING_TEMPLE_PTAH = new ImageGroup(ImagePaks.GENERAL,  20); //73
    public static readonly ImageGroup BUILDING_TEMPLE_SETH = new ImageGroup(ImagePaks.GENERAL,  19); //74
    public static readonly ImageGroup BUILDING_TEMPLE_BAST = new ImageGroup(ImagePaks.GENERAL,  76); //75
    public static readonly ImageGroup BUILDING_SHRINE_OSIRIS = new ImageGroup(ImagePaks.GENERAL,  75);
    public static readonly ImageGroup BUILDING_SHRINE_RA = new ImageGroup(ImagePaks.GENERAL,  74);
    public static readonly ImageGroup BUILDING_SHRINE_PTAH = new ImageGroup(ImagePaks.GENERAL,  73);
    public static readonly ImageGroup BUILDING_SHRINE_SETH = new ImageGroup(ImagePaks.GENERAL,  72);
    public static readonly ImageGroup BUILDING_SHRINE_BAST = new ImageGroup(ImagePaks.GENERAL,  71);
    public static readonly ImageGroup BUILDING_ORACLE = new ImageGroup(ImagePaks.GENERAL,  76); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_ENGINEERS_POST = new ImageGroup(ImagePaks.GENERAL,  81);
    public static readonly ImageGroup BUILDING_WAREHOUSE = new ImageGroup(ImagePaks.GENERAL,  82);
    public static readonly ImageGroup BUILDING_WAREHOUSE_STORAGE_EMPTY = new ImageGroup(ImagePaks.GENERAL,  83);
    public static readonly ImageGroup BUILDING_WAREHOUSE_STORAGE_FILLED = new ImageGroup(ImagePaks.GENERAL,  84);
    public static readonly ImageGroup BUILDING_GOVERNORS_HOUSE = new ImageGroup(ImagePaks.GENERAL,  85);
    public static readonly ImageGroup BUILDING_GOVERNORS_VILLA = new ImageGroup(ImagePaks.GENERAL,  86);
    public static readonly ImageGroup BUILDING_GOVERNORS_PALACE = new ImageGroup(ImagePaks.GENERAL,  87);
    public static readonly ImageGroup SIDEBAR_BRIEFING_ROTATE_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  89);
    public static readonly ImageGroup SIDEBAR_ADVISORS_EMPIRE = new ImageGroup(ImagePaks.GENERAL,  89); //13
    public static readonly ImageGroup MESSAGE_ICON = new ImageGroup(ImagePaks.GENERAL,  90);
    public static readonly ImageGroup SIDEBAR_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  136); //92
    public static readonly ImageGroup LABOR_PRIORITY_LOCK = new ImageGroup(ImagePaks.GENERAL,  94);
    public static readonly ImageGroup OK_CANCEL_SCROLL_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  96);
    public static readonly ImageGroup BUILDING_GRANARY = new ImageGroup(ImagePaks.GENERAL,  99);
    public static readonly ImageGroup BUILDING_FARMLAND = new ImageGroup(ImagePaks.GENERAL,  37); //100
    public static readonly ImageGroup FIGURE_EXPLOSION = new ImageGroup(ImagePaks.GENERAL,  102); // exception sprites in General/Sprites.bmp
    public static readonly ImageGroup OVERLAY_COLUMN = new ImageGroup(ImagePaks.GENERAL,  103);
    public static readonly ImageGroup SIDEBAR_UPPER_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  110);
    public static readonly ImageGroup BUILDING_BEER_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  116); //44
    public static readonly ImageGroup BUILDING_CHARIOT_MAKER = new ImageGroup(ImagePaks.GENERAL,  120); //52
    public static readonly ImageGroup SIDE_PANEL = new ImageGroup(ImagePaks.GENERAL,  121); //12
    public static readonly ImageGroup BUILDING_LINEN_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  122);
    public static readonly ImageGroup BUILDING_WEAPONS_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  123);
    public static readonly ImageGroup BUILDING_JEWELS_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  119); //124
    public static readonly ImageGroup BUILDING_BRICKS_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  124);
    public static readonly ImageGroup BUILDING_POTTERY_WORKSHOP = new ImageGroup(ImagePaks.GENERAL,  125);
    public static readonly ImageGroup FIGURE_FORT_FLAGS = new ImageGroup(ImagePaks.GENERAL,  126);
    public static readonly ImageGroup FIGURE_FORT_STANDARD_ICONS = new ImageGroup(ImagePaks.GENERAL,  127);
    public static readonly ImageGroup ADVISOR_ICONS = new ImageGroup(ImagePaks.GENERAL,  128);
    public static readonly ImageGroup RESOURCE_ICONS = new ImageGroup(ImagePaks.GENERAL,  129);
    public static readonly ImageGroup DIALOG_BACKGROUND = new ImageGroup(ImagePaks.GENERAL,  132);
    public static readonly ImageGroup SUNKEN_TEXTBOX_BACKGROUND = new ImageGroup(ImagePaks.GENERAL,  133);
    public static readonly ImageGroup CONTEXT_ICONS = new ImageGroup(ImagePaks.GENERAL,  134);
    public static readonly ImageGroup EDITOR_SIDEBAR_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  137);
    public static readonly ImageGroup FIGURE_MAP_FLAG_FLAGS = new ImageGroup(ImagePaks.GENERAL,  139);
    public static readonly ImageGroup FIGURE_MAP_FLAG_ICONS = new ImageGroup(ImagePaks.GENERAL,  140);
    public static readonly ImageGroup MINIMAP_EMPTY_LAND = new ImageGroup(ImagePaks.GENERAL,  141);
    public static readonly ImageGroup MINIMAP_WATER = new ImageGroup(ImagePaks.GENERAL,  142);
    public static readonly ImageGroup MINIMAP_TREE = new ImageGroup(ImagePaks.GENERAL,  143);
    public static readonly ImageGroup MINIMAP_ROCK = new ImageGroup(ImagePaks.GENERAL,  145);
    public static readonly ImageGroup MINIMAP_MEADOW = new ImageGroup(ImagePaks.GENERAL,  146);
    public static readonly ImageGroup MINIMAP_ROAD = new ImageGroup(ImagePaks.GENERAL,  147);
    public static readonly ImageGroup MINIMAP_HOUSE = new ImageGroup(ImagePaks.GENERAL,  148);
    public static readonly ImageGroup MINIMAP_BUILDING = new ImageGroup(ImagePaks.GENERAL,  149);
    public static readonly ImageGroup MINIMAP_WALL = new ImageGroup(ImagePaks.GENERAL,  150);
    public static readonly ImageGroup MINIMAP_AQUEDUCT = new ImageGroup(ImagePaks.GENERAL,  151);
    public static readonly ImageGroup MINIMAP_BLACK = new ImageGroup(ImagePaks.GENERAL,  152);
    public static readonly ImageGroup FIGURE_FLOTSAM_0 = new ImageGroup(ImagePaks.GENERAL,  153); // TODO?
    public static readonly ImageGroup FIGURE_FLOTSAM_1 = new ImageGroup(ImagePaks.GENERAL,  139); //154
    public static readonly ImageGroup FIGURE_FLOTSAM_2 = new ImageGroup(ImagePaks.GENERAL,  155); // TODO?
    public static readonly ImageGroup FIGURE_FLOTSAM_3 = new ImageGroup(ImagePaks.GENERAL,  156); // TODO?
    public static readonly ImageGroup POPULATION_GRAPH_BAR = new ImageGroup(ImagePaks.GENERAL,  157);
    public static readonly ImageGroup BULLET = new ImageGroup(ImagePaks.GENERAL,  158);
    public static readonly ImageGroup BUILDING_BARRACKS = new ImageGroup(ImagePaks.GENERAL,  166);
    public static readonly ImageGroup EMPIRE_PANELS = new ImageGroup(ImagePaks.GENERAL,  172);
    public static readonly ImageGroup RESOURCE_STOCK_GAMEMEAT_5 = new ImageGroup(ImagePaks.GENERAL,  205); //173
    public static readonly ImageGroup RESOURCE_STOCK_STRAW_2 = new ImageGroup(ImagePaks.GENERAL,  204);
    public static readonly ImageGroup RESOURCE_STOCK_WEAPONS_2 = new ImageGroup(ImagePaks.GENERAL,  201);
    public static readonly ImageGroup RESOURCE_STOCK_CLAY_2 = new ImageGroup(ImagePaks.GENERAL,  207);
    public static readonly ImageGroup RESOURCE_STOCK_BARLEY_2 = new ImageGroup(ImagePaks.GENERAL,  208);
    public static readonly ImageGroup RESOURCE_STOCK_BEER_3 = new ImageGroup(ImagePaks.GENERAL,  198);
    public static readonly ImageGroup RESOURCE_STOCK_FLAX_2  = new ImageGroup(ImagePaks.GENERAL,  210);
    public static readonly ImageGroup RESOURCE_STOCK_LINEN_5  = new ImageGroup(ImagePaks.GENERAL,  199);
    public static readonly ImageGroup RESOURCE_STOCK_GEMS_2  = new ImageGroup(ImagePaks.GENERAL,  200);
    public static readonly ImageGroup RESOURCE_STOCK_WOOD_5  = new ImageGroup(ImagePaks.GENERAL,  202);
    public static readonly ImageGroup RESOURCE_STOCK_REEDS_5  = new ImageGroup(ImagePaks.GENERAL,  206);
    public static readonly ImageGroup RESOURCE_STOCK_PAPYRUS_3  = new ImageGroup(ImagePaks.GENERAL,  60);
    public static readonly ImageGroup RESOURCE_STOCK_CHARIOTS_2  = new ImageGroup(ImagePaks.GENERAL,  209);
    public static readonly ImageGroup RESOURCE_STOCK_COPPER_2  = new ImageGroup(ImagePaks.GENERAL,  203);
    public static readonly ImageGroup EMPIRE_CITY = new ImageGroup(ImagePaks.GENERAL,  177); //174
    public static readonly ImageGroup EMPIRE_CITY_PH_PHARAOH = new ImageGroup(ImagePaks.GENERAL,  175);
    public static readonly ImageGroup EMPIRE_CITY_PH_OURS = new ImageGroup(ImagePaks.GENERAL,  176);
    public static readonly ImageGroup EMPIRE_TRADE_ROUTE_TYPE = new ImageGroup(ImagePaks.GENERAL,  179);
    public static readonly ImageGroup BUILDING_NATIVE = new ImageGroup(ImagePaks.GENERAL,  183);
    public static readonly ImageGroup BUILDING_MISSION_POST = new ImageGroup(ImagePaks.GENERAL,  184);
    public static readonly ImageGroup BUILDING_BATHHOUSE_NO_WATER = new ImageGroup(ImagePaks.GENERAL,  185);
    public static readonly ImageGroup RATINGS_COLUMN = new ImageGroup(ImagePaks.GENERAL,  189);
    public static readonly ImageGroup MESSAGE_ADVISOR_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  106); //199
    public static readonly ImageGroup BUILDING_MILITARY_ACADEMY = new ImageGroup(ImagePaks.GENERAL,  173); //201
    public static readonly ImageGroup BUILDING_FORT_JAVELIN = new ImageGroup(ImagePaks.GENERAL,  66); //202
    public static readonly ImageGroup BUILDING_FORT_LEGIONARY = new ImageGroup(ImagePaks.GENERAL,  66); //204
    public static readonly ImageGroup BUILDING_TRIUMPHAL_ARCH = new ImageGroup(ImagePaks.GENERAL,  205); // this isn't in Pharaoh
    public static readonly ImageGroup BORDERED_BUTTON = new ImageGroup(ImagePaks.GENERAL,  174); //208
    public static readonly ImageGroup BUILDING_MARKET_FANCY = new ImageGroup(ImagePaks.GENERAL,  45); //210
    public static readonly ImageGroup BUILDING_BATHHOUSE_FANCY_WATER = new ImageGroup(ImagePaks.GENERAL,  211); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_BATHHOUSE_FANCY_NO_WATER = new ImageGroup(ImagePaks.GENERAL,  212); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_SENET_HOUSE = new ImageGroup(ImagePaks.GENERAL,  17); //213 //GROUP_BUILDING_HIPPODROME_1
    public static readonly ImageGroup BUILDING_HIPPODROME_2 = new ImageGroup(ImagePaks.GENERAL,  214); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_SENATE_FANCY = new ImageGroup(ImagePaks.GENERAL,  221); // this isn't in Pharaoh
    public static readonly ImageGroup FORT_ICONS = new ImageGroup(ImagePaks.GENERAL,  222); // TODO?
    public static readonly ImageGroup EMPIRE_FOREIGN_CITY = new ImageGroup(ImagePaks.GENERAL,  223); // this isn't in Pharaoh
    public static readonly ImageGroup GOD_BOLT = new ImageGroup(ImagePaks.GENERAL,  111); //225
    public static readonly ImageGroup PLAGUE_SKULL = new ImageGroup(ImagePaks.GENERAL,  97); //227
    public static readonly ImageGroup FIGURE_FORT_MOUNTED = new ImageGroup(ImagePaks.GENERAL,  66); //232
    public static readonly ImageGroup BUILDING_TRADE_CENTER_FLAG = new ImageGroup(ImagePaks.GENERAL,  238); // this isn't in Pharaoh
    public static readonly ImageGroup TERRAIN_ENTRY_EXIT_FLAGS = new ImageGroup(ImagePaks.GENERAL,  240);
    public static readonly ImageGroup FIGURE_FORT_STANDARD_POLE = new ImageGroup(ImagePaks.GENERAL,  241);
    public static readonly ImageGroup FIGURE_FLOTSAM_SHEEP = new ImageGroup(ImagePaks.GENERAL,  242); // this isn't in Pharaoh
    public static readonly ImageGroup TRADE_AMOUNT = new ImageGroup(ImagePaks.GENERAL,  171); //243
    public static readonly ImageGroup BULIDING_GATEHOUSE = new ImageGroup(ImagePaks.GENERAL,  248); // this isn't in Pharaoh
    public static readonly ImageGroup BUILDING_VILLAGE_PALACE = new ImageGroup(ImagePaks.GENERAL,  47); // general
    public static readonly ImageGroup BUILDING_TOWN_PALACE = new ImageGroup(ImagePaks.GENERAL,  39);
    public static readonly ImageGroup BUILDING_CITY_PALACE = new ImageGroup(ImagePaks.GENERAL,  18);
    public static readonly ImageGroup BUILDING_FARM_CROPS_PH = new ImageGroup(ImagePaks.GENERAL,  100);
    public static readonly ImageGroup BUILDING_CATTLE_RANCH = new ImageGroup(ImagePaks.GENERAL,  105);
    public static readonly ImageGroup BUILDING_REEDS_COLLECTOR = new ImageGroup(ImagePaks.GENERAL,  24);
    public static readonly ImageGroup SINGLE_SQUARE = new ImageGroup(ImagePaks.GENERAL,  107);
    public static readonly ImageGroup BOOTH_SQUARE = new ImageGroup(ImagePaks.GENERAL,  112);
    public static readonly ImageGroup BANDSTAND_SQUARE = new ImageGroup(ImagePaks.GENERAL,  58);
    public static readonly ImageGroup PAVILLION_SQUARE = new ImageGroup(ImagePaks.GENERAL,  50);
    public static readonly ImageGroup FESTIVAL_SQUARE = new ImageGroup(ImagePaks.GENERAL,  49);
    public static readonly ImageGroup BUILDING_GRANITE_QUARY = new ImageGroup(ImagePaks.GENERAL,  38);
    public static readonly ImageGroup BUILDING_GOLD_MINE = new ImageGroup(ImagePaks.GENERAL,  185);
    public static readonly ImageGroup BUILDING_GEMSTONE_MINE = new ImageGroup(ImagePaks.GENERAL,  188);
    public static readonly ImageGroup BUILDING_STONE_QUARRY = new ImageGroup(ImagePaks.GENERAL,  187); //38
    public static readonly ImageGroup BUILDING_UNUSED_BEIGE_MINE = new ImageGroup(ImagePaks.GENERAL,  186);
    public static readonly ImageGroup BUILDING_COPPER_MINE = new ImageGroup(ImagePaks.GENERAL,  196);
    public static readonly ImageGroup BUILDING_SANDSTONE_MINE = new ImageGroup(ImagePaks.GENERAL,  197);
    public static readonly ImageGroup BUILDING_MARBLE_QUARRY = new ImageGroup(ImagePaks.GENERAL,  162);
    public static readonly ImageGroup BUILDING_LIMESTONE_QUARRY = new ImageGroup(ImagePaks.GENERAL,  170); //39
    public static readonly ImageGroup BUILDING_HUNTING_LODGE = new ImageGroup(ImagePaks.GENERAL,  176);
    public static readonly ImageGroup BUILDING_ROADBLOCK = new ImageGroup(ImagePaks.GENERAL,  98);
    public static readonly ImageGroup BUILDING_FIREHOUSE = new ImageGroup(ImagePaks.GENERAL,  78);
    public static readonly ImageGroup BUILDING_WORKCAMP = new ImageGroup(ImagePaks.GENERAL,  77);
    public static readonly ImageGroup BUILDING_WALLS = new ImageGroup(ImagePaks.GENERAL,  138);
    public static readonly ImageGroup BUILDING_GATEHOUSE = new ImageGroup(ImagePaks.GENERAL,  161);
    public static readonly ImageGroup BUILDING_GATEHOUSE_2 = new ImageGroup(ImagePaks.GENERAL,  220);
    //  // Warning already redefined. Is it maybe a good idea to get rid of the defines complete and use constexpr ?
    public static readonly ImageGroup BUILDING_TOWER_2 = new ImageGroup(ImagePaks.GENERAL,  135  );
    //  // Warning already redefined. Is it maybe a good idea to get rid of the defines complete and use constexpr ?
    // public static readonly ImageGroup BUILDING_TRANSPORT_WHARF = new ImageGroup(ImagePaks.GENERAL,  17); // TODO
    //  // Warning already redefined. Is it maybe a good idea to get rid of the defines complete and use constexpr ?
    // public static readonly ImageGroup BUILDING_WARSHIP_WHARF = new ImageGroup(ImagePaks.GENERAL,  28); // TODO
    public static readonly ImageGroup BUILDING_GUILD_CARPENTERS = new ImageGroup(ImagePaks.GENERAL,  91);
    public static readonly ImageGroup BUILDING_GUILD_STONEMASONS = new ImageGroup(ImagePaks.GENERAL,  88);
    public static readonly ImageGroup BUILDING_GUILD_BRICKLAYERS = new ImageGroup(ImagePaks.GENERAL,  57);

    public static readonly ImageGroup SELECT_MISSION_BUTTON = new ImageGroup(ImagePaks.GENERAL,  254); // TODO
    public static readonly ImageGroup BUTTON_EXCLAMATION = new ImageGroup(ImagePaks.GENERAL,  193);
    public static readonly ImageGroup MENU_ADVISOR_BUTTONS = new ImageGroup(ImagePaks.GENERAL,  159);
    public static readonly ImageGroup MENU_ADVISOR_LAYOUT = new ImageGroup(ImagePaks.GENERAL,  160);
    public static readonly ImageGroup TINY_ARROWS = new ImageGroup(ImagePaks.GENERAL,  212);
    public static readonly ImageGroup GOD_ANGEL = new ImageGroup(ImagePaks.GENERAL,  9);
    public static readonly ImageGroup BUILD_MENU_CATEGORIES = new ImageGroup(ImagePaks.GENERAL,  117);
    public static readonly ImageGroup MINIMAP_REEDS = new ImageGroup(ImagePaks.GENERAL,  144);
    public static readonly ImageGroup MINIMAP_FLOODPLAIN = new ImageGroup(ImagePaks.GENERAL,  146);
    public static readonly ImageGroup MINIMAP_DUNES = new ImageGroup(ImagePaks.GENERAL,  211);

    // ////////////////// UNLOADED

    public static readonly ImageGroup SYSTEM_GRAPHICS = new ImageGroup(ImagePaks.UNLOADED,  0);
    public static readonly ImageGroup FORT_FORMATIONS = new ImageGroup(ImagePaks.UNLOADED,  1); //197
    public static readonly ImageGroup ADVISOR_RATINGS_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  2); //195
    public static readonly ImageGroup BIGPEOPLE = new ImageGroup(ImagePaks.UNLOADED,  3);
    public static readonly ImageGroup PROMO_3 = new ImageGroup(ImagePaks.UNLOADED,  4); //188
    public static readonly ImageGroup PROMO_2 = new ImageGroup(ImagePaks.UNLOADED,  5); //187
    public static readonly ImageGroup PROMO_1 = new ImageGroup(ImagePaks.UNLOADED,  6); //186
    public static readonly ImageGroup LOGO = new ImageGroup(ImagePaks.UNLOADED,  7); //162
    public static readonly ImageGroup CONFIG_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  8); //161
    public static readonly ImageGroup SCORES_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  9);
    public static readonly ImageGroup WIN_GAME_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  9); //160
    public static readonly ImageGroup MESSAGE_IMAGES = new ImageGroup(ImagePaks.UNLOADED,  10); //159
    public static readonly ImageGroup ADVISOR_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  11); //136
    public static readonly ImageGroup SELECT_MISSION_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  12); //244
    public static readonly ImageGroup MAIN_MENU_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  14);
    public static readonly ImageGroup MAP_SELECTION_CCK = new ImageGroup(ImagePaks.UNLOADED,  15); //246
    public static readonly ImageGroup NEXT_MISSION_SELECT = new ImageGroup(ImagePaks.UNLOADED,  16); //245 <----- ?????????????????
    public static readonly ImageGroup LOADING_SCREEN = new ImageGroup(ImagePaks.UNLOADED,  17); //251
    public static readonly ImageGroup INTERMEZZO_BACKGROUND = new ImageGroup(ImagePaks.UNLOADED,  18); //252
    public static readonly ImageGroup PANEL_WINDOWS_DESERT = new ImageGroup(ImagePaks.UNLOADED,  19); //253
    public static readonly ImageGroup PANEL_WINDOWS = new ImageGroup(ImagePaks.UNLOADED,  21); //95
    // //#define ?????  IMAGE_COLLECTION_UNLOADED,  22 //80
    public static readonly ImageGroup PORTRAITS = new ImageGroup(ImagePaks.UNLOADED,  25); //190
    public static readonly ImageGroup SCENARIO_IMAGE = new ImageGroup(ImagePaks.UNLOADED,  28); //247
    public static readonly ImageGroup PLAYER_SELECTION = new ImageGroup(ImagePaks.UNLOADED,  29);
    public static readonly ImageGroup MAP_SELECTION_CAMPAIGN = new ImageGroup(ImagePaks.UNLOADED,  30);
    public static readonly ImageGroup GAME_MENU = new ImageGroup(ImagePaks.UNLOADED,  31);
    public static readonly ImageGroup MAP_SELECTION_CUSTOM = new ImageGroup(ImagePaks.UNLOADED,  32);
    public static readonly ImageGroup MAP_SELECTION_HISTORY = new ImageGroup(ImagePaks.UNLOADED,  33);

    // ////////////////// SPRMAIN

    public static readonly ImageGroup FIGURE_LABOR_SEEKER = new ImageGroup(ImagePaks.SPR_MAIN,  206); //57
    public static readonly ImageGroup FIGURE_BATHHOUSE_WORKER = new ImageGroup(ImagePaks.SPR_MAIN,  71); //88
    public static readonly ImageGroup FIGURE_PRIEST = new ImageGroup(ImagePaks.SPR_MAIN,  197); //91
    public static readonly ImageGroup FIGURE_CARTPUSHER_CART = new ImageGroup(ImagePaks.SPR_MAIN,  77); //97
    public static readonly ImageGroup FIGURE_JUGGLER = new ImageGroup(ImagePaks.SPR_MAIN,  130); //98
    public static readonly ImageGroup FIGURE_DANCER = new ImageGroup(ImagePaks.SPR_MAIN,  128); //101
    public static readonly ImageGroup FIGURE_TAX_COLLECTOR = new ImageGroup(ImagePaks.SPR_MAIN,  41); //104
    public static readonly ImageGroup FIGURE_SCHOOL_CHILD = new ImageGroup(ImagePaks.SPR_MAIN,  57); //105
    public static readonly ImageGroup FIGURE_MARKET_LADY = new ImageGroup(ImagePaks.SPR_MAIN,  16); //106
    public static readonly ImageGroup FIGURE_CARTPUSHER = new ImageGroup(ImagePaks.SPR_MAIN,  43); //107
    public static readonly ImageGroup FIGURE_MIGRANT = new ImageGroup(ImagePaks.SPR_MAIN,  14); //108
    public static readonly ImageGroup FIGURE_DANCER_WHIP = new ImageGroup(ImagePaks.SPR_MAIN,  109); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_ENGINEER = new ImageGroup(ImagePaks.SPR_MAIN,  4); //110
    public static readonly ImageGroup FIGURE_MUSICIAN = new ImageGroup(ImagePaks.SPR_MAIN,  191); //111
    public static readonly ImageGroup FIGURE_CRIMINAL = new ImageGroup(ImagePaks.SPR_MAIN,  32); //115
    public static readonly ImageGroup FIGURE_BARBER = new ImageGroup(ImagePaks.SPR_MAIN,  182); //116
    public static readonly ImageGroup FIGURE_PREFECT = new ImageGroup(ImagePaks.SPR_MAIN,  6); //117
    public static readonly ImageGroup FIGURE_HOMELESS = new ImageGroup(ImagePaks.SPR_MAIN,  12); //118
    public static readonly ImageGroup FIGURE_PREFECT_WITH_BUCKET = new ImageGroup(ImagePaks.SPR_MAIN,  8); //121
    public static readonly ImageGroup FIGURE_MIGRANT_CART = new ImageGroup(ImagePaks.SPR_MAIN,  52); //131
    public static readonly ImageGroup FIGURE_LION = new ImageGroup(ImagePaks.SPR_MAIN,  161); //163
    public static readonly ImageGroup FIGURE_SHIP = new ImageGroup(ImagePaks.SPR_MAIN,  34); //165
    public static readonly ImageGroup FIGURE_TOWER_SENTRY = new ImageGroup(ImagePaks.SPR_MAIN,  194); // TODO
    public static readonly ImageGroup FIGURE_MISSILE = new ImageGroup(ImagePaks.SPR_MAIN,  198); // TODO
    public static readonly ImageGroup FIGURE_BALLISTA = new ImageGroup(ImagePaks.SPR_MAIN,  200); // TODO
    public static readonly ImageGroup FIGURE_SEAGULLS = new ImageGroup(ImagePaks.SPR_MAIN,  114); //206
    public static readonly ImageGroup FIGURE_DELIVERY_BOY = new ImageGroup(ImagePaks.SPR_MAIN,  9); //209
    public static readonly ImageGroup FIGURE_CHARIOTEER = new ImageGroup(ImagePaks.SPR_MAIN,  215); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_HIPPODROME_HORSE_1 = new ImageGroup(ImagePaks.SPR_MAIN,  217); // // this isn't in Pharaoh this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_HIPPODROME_HORSE_2 = new ImageGroup(ImagePaks.SPR_MAIN,  218); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_HIPPODROME_CART_1 = new ImageGroup(ImagePaks.SPR_MAIN,  219); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_HIPPODROME_CART_2 = new ImageGroup(ImagePaks.SPR_MAIN,  220); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_SHIPWRECK = new ImageGroup(ImagePaks.SPR_MAIN,  226); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_DOCTOR_SURGEON = new ImageGroup(ImagePaks.SPR_MAIN,  180); //228
    public static readonly ImageGroup FIGURE_PATRICIAN = new ImageGroup(ImagePaks.SPR_MAIN,  229); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_MISSIONARY = new ImageGroup(ImagePaks.SPR_MAIN,  230); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_TEACHER_LIBRARIAN = new ImageGroup(ImagePaks.SPR_MAIN,  201); //231
    public static readonly ImageGroup FIGURE_SHEEP = new ImageGroup(ImagePaks.SPR_MAIN,  233); // TODO
    public static readonly ImageGroup FIGURE_OSTRICH = new ImageGroup(ImagePaks.SPR_MAIN,  156); //234
    public static readonly ImageGroup FIGURE_CROCODILE = new ImageGroup(ImagePaks.SPR_MAIN,  23); //235
    public static readonly ImageGroup FIGURE_CAESAR_LEGIONARY = new ImageGroup(ImagePaks.SPR_MAIN,  236); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_CARTPUSHER_CART_MULTIPLE_FOOD = new ImageGroup(ImagePaks.SPR_MAIN,  237); // this isn't in Pharaoh
    public static readonly ImageGroup FIGURE_CARTPUSHER_CART_MULTIPLE_RESOURCE = new ImageGroup(ImagePaks.SPR_MAIN,  250); // this isn't in Pharaoh
    public static readonly ImageGroup PRIEST_OSIRIS = new ImageGroup(ImagePaks.SPR_MAIN,  197);
    public static readonly ImageGroup PRIEST_RA = new ImageGroup(ImagePaks.SPR_MAIN,  210);
    public static readonly ImageGroup PRIEST_SETH = new ImageGroup(ImagePaks.SPR_MAIN,  193);
    public static readonly ImageGroup PRIEST_PTAH = new ImageGroup(ImagePaks.SPR_MAIN,  187);
    public static readonly ImageGroup PRIEST_BAST = new ImageGroup(ImagePaks.SPR_MAIN,  208);
    public static readonly ImageGroup FIGURE_MARKET_LADY_2 = new ImageGroup(ImagePaks.SPR_MAIN,  18);
    public static readonly ImageGroup FIGURE_POLICEMAN = new ImageGroup(ImagePaks.SPR_MAIN,  20);
    public static readonly ImageGroup FIGURE_REED_GATHERER = new ImageGroup(ImagePaks.SPR_MAIN,  37);
    public static readonly ImageGroup FIGURE_HUNTER = new ImageGroup(ImagePaks.SPR_MAIN,  45);
    public static readonly ImageGroup FIGURE_HUNTER_ARROW = new ImageGroup(ImagePaks.SPR_MAIN,  0);
    public static readonly ImageGroup FIGURE_TRADE_CARAVAN_DONKEY = new ImageGroup(ImagePaks.SPR_MAIN,  52);
    public static readonly ImageGroup FIGURE_WATER_CARRIER = new ImageGroup(ImagePaks.SPR_MAIN,  59);
    public static readonly ImageGroup FIGURE_WORKER_PH = new ImageGroup(ImagePaks.SPR_MAIN,  116);
    public static readonly ImageGroup FIGURE_MORTUARY = new ImageGroup(ImagePaks.SPR_MAIN,  195);
    public static readonly ImageGroup FIGURE_MAGISTRATE = new ImageGroup(ImagePaks.SPR_MAIN,  212);
    public static readonly ImageGroup FIGURE_ARCHER_PH = new ImageGroup(ImagePaks.SPR_MAIN,  62);
    public static readonly ImageGroup FIGURE_INFANTRY_PH = new ImageGroup(ImagePaks.SPR_MAIN,  65);
    public static readonly ImageGroup FIGURE_CHARIOTEER_PH = new ImageGroup(ImagePaks.SPR_MAIN,  68);
    public static readonly ImageGroup FIGURE_LUMBERJACK = new ImageGroup(ImagePaks.SPR_MAIN,  73);

    // ////////////////// SPRAMBIENT

    public static readonly ImageGroup FIGURE_TRADE_CARAVAN = new ImageGroup(ImagePaks.SPR_AMBIENT,  20); //130
    public static readonly ImageGroup BUILDING_DOCK_DOCKERS = new ImageGroup(ImagePaks.SPR_AMBIENT,  55); //171
    public static readonly ImageGroup JUGGLERS_SHOW = new ImageGroup(ImagePaks.SPR_AMBIENT,  7); //191
    public static readonly ImageGroup DANCERS_SHOW = new ImageGroup(ImagePaks.SPR_AMBIENT,  6); //192
    public static readonly ImageGroup MUSICIANS_SHOW = new ImageGroup(ImagePaks.SPR_AMBIENT,  9); //193
    public static readonly ImageGroup WATER_LIFT_ANIM = new ImageGroup(ImagePaks.SPR_AMBIENT,  1); // sprambient
    public static readonly ImageGroup GRANARY_ANIM_PH = new ImageGroup(ImagePaks.SPR_AMBIENT,  47);
    public static readonly ImageGroup WAREHOUSE_ANIM_PH = new ImageGroup(ImagePaks.SPR_AMBIENT,  51);
    // //   #define GROUP_DOCK_WAITING  IMAGE_COLLECTION_SPR_AMBIENT,  55
    // //   #define GROUP_DOCK_UNLOADING  IMAGE_COLLECTION_SPR_AMBIENT,  56
    public static readonly ImageGroup MINES = new ImageGroup(ImagePaks.SPR_AMBIENT,  48);
    public static readonly ImageGroup DANCERS = new ImageGroup(ImagePaks.SPR_AMBIENT,  6);
    public static readonly ImageGroup JUGGLERS = new ImageGroup(ImagePaks.SPR_AMBIENT,  7);
    public static readonly ImageGroup MUSICIANS = new ImageGroup(ImagePaks.SPR_AMBIENT,  9);
    public static readonly ImageGroup FIGURE_FISH = new ImageGroup(ImagePaks.SPR_AMBIENT,  8);
    public static readonly ImageGroup FIGURE_HIPPO = new ImageGroup(ImagePaks.SPR_AMBIENT,  22);
    public static readonly ImageGroup FIGURE_ANTILOPE = new ImageGroup(ImagePaks.SPR_AMBIENT,  30);
    public static readonly ImageGroup FIGURE_HUNTER2 = new ImageGroup(ImagePaks.SPR_AMBIENT,  36);
    public static readonly ImageGroup SHIP_BUILDING_1 = new ImageGroup(ImagePaks.SPR_AMBIENT,  45);
    public static readonly ImageGroup SHIP_BUILDING_2 = new ImageGroup(ImagePaks.SPR_AMBIENT,  52);
    public static readonly ImageGroup SHIP_BUILDING_3 = new ImageGroup(ImagePaks.SPR_AMBIENT,  53);
    public static readonly ImageGroup SHIP_BUILDING_4 = new ImageGroup(ImagePaks.SPR_AMBIENT,  54);

    // ////////////////// MONUMENT

    public static readonly ImageGroup MONUMENT_BLOCKS = new ImageGroup(ImagePaks.MONUMENT,  1);
    public static readonly ImageGroup MONUMENT_TERRAIN = new ImageGroup(ImagePaks.MONUMENT,  2);
    public static readonly ImageGroup MONUMENT_DITCHES_PHASE_1 = new ImageGroup(ImagePaks.MONUMENT,  3);
    public static readonly ImageGroup MONUMENT_DITCHES_PHASE_2 = new ImageGroup(ImagePaks.MONUMENT,  4);
    public static readonly ImageGroup MONUMENT_DITCHES_PHASE_3 = new ImageGroup(ImagePaks.MONUMENT,  5);
    public static readonly ImageGroup MONUMENT_DITCHES_PHASE_4 = new ImageGroup(ImagePaks.MONUMENT,  6);
    public static readonly ImageGroup MONUMENT_TOMB_FLOOR = new ImageGroup(ImagePaks.MONUMENT,  7);
    public static readonly ImageGroup MONUMENT_CORNER_POLES = new ImageGroup(ImagePaks.MONUMENT,  8);
    public static readonly ImageGroup MONUMENT_EXTERIORS_END_DRY = new ImageGroup(ImagePaks.MONUMENT,  9);
    public static readonly ImageGroup MONUMENT_EXTERIORS_RUNS = new ImageGroup(ImagePaks.MONUMENT,  10);
    public static readonly ImageGroup MONUMENT_EXTERIORS_END_WET = new ImageGroup(ImagePaks.MONUMENT,  11);
    public static readonly ImageGroup MONUMENT_EXTRA_BLOCKS = new ImageGroup(ImagePaks.MONUMENT,  12);

    // ////////////////// TEMPLE

    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_MAIN = new ImageGroup(ImagePaks.TEMPLE,  1);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_ORACLE = new ImageGroup(ImagePaks.TEMPLE,  2);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_ALTAR = new ImageGroup(ImagePaks.TEMPLE,  3);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_FLOORING = new ImageGroup(ImagePaks.TEMPLE,  4);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_STATUE_1 = new ImageGroup(ImagePaks.TEMPLE,  5);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_STATUE_2 = new ImageGroup(ImagePaks.TEMPLE,  6);
    public static readonly ImageGroup BUILDING_TEMPLE_COMPLEX_UPGRADES = new ImageGroup(ImagePaks.TEMPLE,  7);

    // ////////////////// EXPANSION

    public static readonly ImageGroup BIG_PEOPLE_2 = new ImageGroup(ImagePaks.EXPANSION,  1);
    public static readonly ImageGroup SCORPION_ICON = new ImageGroup(ImagePaks.EXPANSION,  2);
    public static readonly ImageGroup RESOURCE_ICONS_2 = new ImageGroup(ImagePaks.EXPANSION,  3);
    public static readonly ImageGroup BUILDING_WAREHOUSE_STORAGE_FILLED_2 = new ImageGroup(ImagePaks.EXPANSION,  4);
    public static readonly ImageGroup BUILDING_FARM_CROPS_HENNA = new ImageGroup(ImagePaks.EXPANSION,  5);
    public static readonly ImageGroup BUILDING_ZOO = new ImageGroup(ImagePaks.EXPANSION,  6);
    public static readonly ImageGroup BLOOD_TILES = new ImageGroup(ImagePaks.EXPANSION,  7);
    public static readonly ImageGroup BLOOD_FLOODPLAIN = new ImageGroup(ImagePaks.EXPANSION,  8);
    public static readonly ImageGroup BLOOD_FLOODSYSTEM = new ImageGroup(ImagePaks.EXPANSION,  9);
    public static readonly ImageGroup BLOOD_MARSHLANDS = new ImageGroup(ImagePaks.EXPANSION,  11);
    public static readonly ImageGroup BLOOD_TRANSPORT = new ImageGroup(ImagePaks.EXPANSION,  13);
    public static readonly ImageGroup BLOOD_WELL = new ImageGroup(ImagePaks.EXPANSION,  24);
    public static readonly ImageGroup BLOOD_WATER_SUPPLY = new ImageGroup(ImagePaks.EXPANSION,  25);
    public static readonly ImageGroup BUILDING_LAMP_WORKSHOP = new ImageGroup(ImagePaks.EXPANSION,  26);
    public static readonly ImageGroup BUILDING_PAINT_WORKSHOP = new ImageGroup(ImagePaks.EXPANSION,  27);
    public static readonly ImageGroup BUILDING_GUILD_ARTISANS = new ImageGroup(ImagePaks.EXPANSION,  31);
    public static readonly ImageGroup FROG_ICON = new ImageGroup(ImagePaks.EXPANSION,  32);
    public static readonly ImageGroup TERRAIN_CLIFF = new ImageGroup(ImagePaks.EXPANSION,  33);
    public static readonly ImageGroup BUILDING_STATUE_LARGE_2 = new ImageGroup(ImagePaks.EXPANSION,  35);
    public static readonly ImageGroup BUILDING_STATUE_MEDIUM_2 = new ImageGroup(ImagePaks.EXPANSION,  36);
    public static readonly ImageGroup BUILDING_STATUE_SMALL_2 = new ImageGroup(ImagePaks.EXPANSION,  37);
    public static readonly ImageGroup MISSION_SELECT_2 = new ImageGroup(ImagePaks.EXPANSION,  38); // ????
    public static readonly ImageGroup HISTORY_INFO_2 = new ImageGroup(ImagePaks.EXPANSION,  39); // ????
    public static readonly ImageGroup BLOOD_EDGES = new ImageGroup(ImagePaks.EXPANSION,  40); // ????
    public static readonly ImageGroup BREAKAWAY_SPLASH_LOGO = new ImageGroup(ImagePaks.EXPANSION,  41); // ????

    // ////////////////// TODO? (editor image groups)

    // public static readonly ImageGroup EDITOR_SCENARIO_IMAGE = new ImageGroup(ImagePaks.0, 22);
    // public static readonly ImageGroup EDITOR_BUILDING_CROPS = new ImageGroup(ImagePaks.0, 23);
    // public static readonly ImageGroup EDITOR_EMPIRE_MAP = new ImageGroup(ImagePaks.0, 47);
    // public static readonly ImageGroup EDITOR_SIDE_PANEL = new ImageGroup(ImagePaks.0, 80);
    // public static readonly ImageGroup EDITOR_RESOURCE_ICONS = new ImageGroup(ImagePaks.0, 129);
    // public static readonly ImageGroup EDITOR_EMPIRE_PANELS = new ImageGroup(ImagePaks.0, 172);
    // public static readonly ImageGroup EDITOR_EMPIRE_RESOURCES = new ImageGroup(ImagePaks.0, 173);
    // public static readonly ImageGroup EDITOR_BUILDING_NATIVE = new ImageGroup(ImagePaks.0, 183);
    // public static readonly ImageGroup EDITOR_EMPIRE_FOREIGN_CITY = new ImageGroup(ImagePaks.0, 223);
    // public static readonly ImageGroup EDITOR_TRADE_AMOUNT = new ImageGroup(ImagePaks.0, 243);

}