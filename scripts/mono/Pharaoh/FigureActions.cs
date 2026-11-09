using static ImageGroups;
using E = FigureActionProps;
public readonly struct FigureActionProps {
    public readonly byte speed_mult;
    public readonly Enums.TerrainUsage terrain_usage;
    public readonly short max_roam_length;
    public readonly ImageGroup image_group;
    public FigureActionProps(byte a, Enums.TerrainUsage b, short c, ImageGroup d) {
        speed_mult = a;
        terrain_usage = b;
        max_roam_length = c;
        image_group = d;
    }
}
public partial class Figure : ReferenceEx {
    public FigureActionProps[] FigureActionProperties = {
        new E (0, 0,                                0,      NONE),  //FIGURE_NONE = 0,
        new E (1, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_IMMIGRANT),  //FIGURE_IMMIGRANT = 1,
        new E (1, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_HOMELESS),  //FIGURE_EMIGRANT = 2,
        new E (1, Enums.TerrainUsage.PREFER_ROADS,  0,      FIGURE_HOMELESS),  //FIGURE_HOMELESS = 3,
        new E (1, Enums.TerrainUsage.ROADS,         0,      FIGURE_CARTPUSHER),  //FIGURE_CART_PUSHER = 4,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_LABOR_SEEKER),  //FIGURE_LABOR_SEEKER = 5,
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_EXPLOSION),  //FIGURE_EXPLOSION = 6,
        new E (1, Enums.TerrainUsage.ROADS,         512,    FIGURE_TAX_COLLECTOR),  //FIGURE_TAX_COLLECTOR = 7,
        new E (1, Enums.TerrainUsage.ROADS,         640,    FIGURE_ENGINEER),  //FIGURE_ENGINEER = 8,
        new E (1, Enums.TerrainUsage.ROADS,         0,      FIGURE_CARTPUSHER),  //FIGURE_WAREHOUSEMAN = 9,
        new E (1, Enums.TerrainUsage.ROADS,         640,    FIGURE_PREFECT),  //FIGURE_PREFECT = 10,
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_ARCHER_PH),  //FIGURE_FORT_JAVELIN = 11,
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_CHARIOTEER_PH),  //FIGURE_FORT_MOUNTED = 12,
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_INFANTRY_PH),  //FIGURE_FORT_LEGIONARY = 13,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_FORT_STANDARD = 14,
        new E (1, Enums.TerrainUsage.ROADS,         512,    FIGURE_JUGGLER),  //FIGURE_ACTOR = 15,
        new E (1, Enums.TerrainUsage.ROADS,         512,    FIGURE_MUSICIAN),  //FIGURE_GLADIATOR = 16,
        new E (1, Enums.TerrainUsage.ROADS,         512,    FIGURE_DANCER),  //FIGURE_LION_TAMER = 17,
        new E (1, Enums.TerrainUsage.ROADS,         512,    FIGURE_CHARIOTEER),  //FIGURE_CHARIOTEER = 18,
        new E (1, Enums.TerrainUsage.PREFER_ROADS,  0,      FIGURE_TRADE_CARAVAN),  //FIGURE_TRADE_CARAVAN = 19,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_TRADE_SHIP = 20,
        new E (1, Enums.TerrainUsage.PREFER_ROADS,  0,      FIGURE_TRADE_CARAVAN_DONKEY),  //FIGURE_TRADE_CARAVAN_DONKEY = 21,
        new E (1, Enums.TerrainUsage.ROADS,         0,      FIGURE_CRIMINAL),  //FIGURE_PROTESTER = 22,
        new E (1, Enums.TerrainUsage.ROADS,         0,      FIGURE_CRIMINAL),  //FIGURE_CRIMINAL = 23,
        new E (1, Enums.TerrainUsage.ENEMY,         480,    FIGURE_CRIMINAL),  //FIGURE_RIOTER = 24,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_FISHING_BOAT = 25,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_MARKET_LADY_2),  //FIGURE_MARKET_TRADER = 26,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_PRIEST),  //FIGURE_PRIEST = 27,
        new E (1, Enums.TerrainUsage.ROADS,         192,    FIGURE_SCHOOL_CHILD),   //FIGURE_SCHOOL_CHILD = 28,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_TEACHER_LIBRARIAN),  //FIGURE_TEACHER = 29,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_TEACHER_LIBRARIAN),  //FIGURE_LIBRARIAN = 30,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_BARBER),  //FIGURE_BARBER = 31,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_BATHHOUSE_WORKER),  //FIGURE_BATHHOUSE_WORKER = 32,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_DOCTOR_SURGEON),  //FIGURE_DOCTOR = 33,
        new E (1, Enums.TerrainUsage.ROADS,         384,    FIGURE_MORTUARY),   //FIGURE_SURGEON = 34,
        new E (1, Enums.TerrainUsage.ROADS,         384,    NONE),   //FIGURE_WORKER = 35,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),   //FIGURE_MAP_FLAG = 36,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE), //FIGURE_FLOTSAM = 37,
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),    //FIGURE_DOCKER = 38,
        new E (1, Enums.TerrainUsage.ROADS,         800,    NONE),   //FIGURE_MARKET_BUYER = 39,
        new E (1, Enums.TerrainUsage.ROADS,         128,    FIGURE_PATRICIAN),   //FIGURE_PATRICIAN = 40,
        new E (1, Enums.TerrainUsage.ANY,           800,    NONE),   //FIGURE_INDIGENOUS_NATIVE = 41,
        new E (1, Enums.TerrainUsage.WALLS,         800,    NONE),   //FIGURE_TOWER_SENTRY = 42,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY43_SPEAR = 43,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY44_SWORD = 44,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY45_SWORD = 45,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY46_CAMEL = 46,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY47_ELEPHANT = 47,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY48_CHARIOT = 48,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),  //FIGURE_ENEMY49_FAST_SWORD = 49,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),  //FIGURE_ENEMY50_SWORD = 50,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),  //FIGURE_ENEMY51_SPEAR = 51,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY52_MOUNTED_ARCHER = 52,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY53_AXE = 53,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY54_GLADIATOR = 54,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY_CAESAR_JAVELIN = 55,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY_CAESAR_MOUNTED = 56,
        new E (1, Enums.TerrainUsage.ENEMY,         0,      NONE),   //FIGURE_ENEMY_CAESAR_LEGIONARY = 57,
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),   //FIGURE_NATIVE_TRADER = 58,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),   //FIGURE_ARROW = 59,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),   //FIGURE_JAVELIN = 60,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),   //FIGURE_BOLT = 61,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),   //FIGURE_BALLISTA = 62,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_CREATURE = 63,
        new E (1, Enums.TerrainUsage.ROADS,         192,    FIGURE_MISSIONARY),    //FIGURE_MISSIONARY = 64,
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_SEAGULLS),   //FIGURE_FISH_GULLS = 65,
        new E (1, Enums.TerrainUsage.ROADS,         0,      FIGURE_DELIVERY_BOY),  //FIGURE_DELIVERY_BOY = 66,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_SHIPWRECK = 67,
        new E (2, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_SHEEP),  //FIGURE_SHEEP = 68,
        new E (2, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_OSTRICH),  //FIGURE_WOLF = 69,
        new E (2, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_CROCODILE),  //FIGURE_ZEBRA = 70,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_SPEAR = 71,
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  //FIGURE_HIPPODROME_HORSES = 72,

        // PHARAOH

        new E (1, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_HUNTER),  // 73
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_HUNTER_ARROW),  // 74
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 75
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 76
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 77
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 78
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 79
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 80
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 81
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 82
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 83
        new E (1, Enums.TerrainUsage.ANIMAL,        0,      FIGURE_HIPPO),  // 84 hippo
        new E (1, Enums.TerrainUsage.ANY,           0,      FIGURE_WORKER_PH),  // 85
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 86
        new E (1, Enums.TerrainUsage.ROADS,         640,    FIGURE_WATER_CARRIER),  // 87 water carrier
        new E (1, Enums.TerrainUsage.ROADS,         640,    FIGURE_POLICEMAN),  // 88 policeman
        new E (1, Enums.TerrainUsage.ROADS,         800,    FIGURE_MAGISTRATE),  // 89 magistrate
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 90
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 91
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 92
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 93
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 94
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 95
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 96
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 97
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 98
        new E (1, Enums.TerrainUsage.ANY,           0,      NONE),  // 99
        new E (1, Enums.TerrainUsage.ROADS,         0,      NONE),  // 100
    };
}