public partial class Figure : ReferenceEx {
    
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

    public static readonly FigureActionProps[] FigureActionProperties = {
        new FigureActionProps (0, 0,                                0,      ImageGroups.NONE),  //FIGURE_NONE = 0,
        new FigureActionProps (1, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_MIGRANT),  //FIGURE_IMMIGRANT = 1,
        new FigureActionProps (1, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_HOMELESS),  //FIGURE_EMIGRANT = 2,
        new FigureActionProps (1, Enums.TerrainUsage.PREFER_ROADS,  0,      ImageGroups.FIGURE_HOMELESS),  //FIGURE_HOMELESS = 3,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.FIGURE_CARTPUSHER),  //FIGURE_CART_PUSHER = 4,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_LABOR_SEEKER),  //FIGURE_LABOR_SEEKER = 5,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_EXPLOSION),  //FIGURE_EXPLOSION = 6,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         512,    ImageGroups.FIGURE_TAX_COLLECTOR),  //FIGURE_TAX_COLLECTOR = 7,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         640,    ImageGroups.FIGURE_ENGINEER),  //FIGURE_ENGINEER = 8,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.FIGURE_CARTPUSHER),  //FIGURE_WAREHOUSEMAN = 9,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         640,    ImageGroups.FIGURE_PREFECT),  //FIGURE_PREFECT = 10,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_ARCHER_PH),  //FIGURE_FORT_JAVELIN = 11,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_CHARIOTEER_PH),  //FIGURE_FORT_MOUNTED = 12,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_INFANTRY_PH),  //FIGURE_FORT_LEGIONARY = 13,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_FORT_STANDARD = 14,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         512,    ImageGroups.FIGURE_JUGGLER),  //FIGURE_ACTOR = 15,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         512,    ImageGroups.FIGURE_MUSICIAN),  //FIGURE_GLADIATOR = 16,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         512,    ImageGroups.FIGURE_DANCER),  //FIGURE_LION_TAMER = 17,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         512,    ImageGroups.FIGURE_CHARIOTEER),  //FIGURE_CHARIOTEER = 18,
        new FigureActionProps (1, Enums.TerrainUsage.PREFER_ROADS,  0,      ImageGroups.FIGURE_TRADE_CARAVAN),  //FIGURE_TRADE_CARAVAN = 19,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_TRADE_SHIP = 20,
        new FigureActionProps (1, Enums.TerrainUsage.PREFER_ROADS,  0,      ImageGroups.FIGURE_TRADE_CARAVAN_DONKEY),  //FIGURE_TRADE_CARAVAN_DONKEY = 21,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.FIGURE_CRIMINAL),  //FIGURE_PROTESTER = 22,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.FIGURE_CRIMINAL),  //FIGURE_CRIMINAL = 23,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         480,    ImageGroups.FIGURE_CRIMINAL),  //FIGURE_RIOTER = 24,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_FISHING_BOAT = 25,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_MARKET_LADY_2),  //FIGURE_MARKET_TRADER = 26,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_PRIEST),  //FIGURE_PRIEST = 27,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         192,    ImageGroups.FIGURE_SCHOOL_CHILD),   //FIGURE_SCHOOL_CHILD = 28,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_TEACHER_LIBRARIAN),  //FIGURE_TEACHER = 29,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_TEACHER_LIBRARIAN),  //FIGURE_LIBRARIAN = 30,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_BARBER),  //FIGURE_BARBER = 31,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_BATHHOUSE_WORKER),  //FIGURE_BATHHOUSE_WORKER = 32,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_DOCTOR_SURGEON),  //FIGURE_DOCTOR = 33,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.FIGURE_MORTUARY),   //FIGURE_SURGEON = 34,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         384,    ImageGroups.NONE),   //FIGURE_WORKER = 35,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),   //FIGURE_MAP_FLAG = 36,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE), //FIGURE_FLOTSAM = 37,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),    //FIGURE_DOCKER = 38,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         800,    ImageGroups.NONE),   //FIGURE_MARKET_BUYER = 39,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         128,    ImageGroups.FIGURE_PATRICIAN),   //FIGURE_PATRICIAN = 40,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           800,    ImageGroups.NONE),   //FIGURE_INDIGENOUS_NATIVE = 41,
        new FigureActionProps (1, Enums.TerrainUsage.WALLS,         800,    ImageGroups.NONE),   //FIGURE_TOWER_SENTRY = 42,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY43_SPEAR = 43,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY44_SWORD = 44,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY45_SWORD = 45,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY46_CAMEL = 46,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY47_ELEPHANT = 47,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY48_CHARIOT = 48,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),  //FIGURE_ENEMY49_FAST_SWORD = 49,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),  //FIGURE_ENEMY50_SWORD = 50,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),  //FIGURE_ENEMY51_SPEAR = 51,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY52_MOUNTED_ARCHER = 52,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY53_AXE = 53,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY54_GLADIATOR = 54,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY_CAESAR_JAVELIN = 55,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY_CAESAR_MOUNTED = 56,
        new FigureActionProps (1, Enums.TerrainUsage.ENEMY,         0,      ImageGroups.NONE),   //FIGURE_ENEMY_CAESAR_LEGIONARY = 57,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),   //FIGURE_NATIVE_TRADER = 58,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),   //FIGURE_ARROW = 59,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),   //FIGURE_JAVELIN = 60,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),   //FIGURE_BOLT = 61,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),   //FIGURE_BALLISTA = 62,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_CREATURE = 63,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         192,    ImageGroups.FIGURE_MISSIONARY),    //FIGURE_MISSIONARY = 64,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_SEAGULLS),   //FIGURE_FISH_GULLS = 65,
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.FIGURE_DELIVERY_BOY),  //FIGURE_DELIVERY_BOY = 66,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_SHIPWRECK = 67,
        new FigureActionProps (2, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_SHEEP),  //FIGURE_SHEEP = 68,
        new FigureActionProps (2, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_OSTRICH),  //FIGURE_WOLF = 69,
        new FigureActionProps (2, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_CROCODILE),  //FIGURE_ZEBRA = 70,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_SPEAR = 71,
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  //FIGURE_HIPPODROME_HORSES = 72,

        // PHARAOH

        new FigureActionProps (1, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_HUNTER),  // 73
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_HUNTER_ARROW),  // 74
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 75
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 76
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 77
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 78
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 79
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 80
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 81
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 82
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 83
        new FigureActionProps (1, Enums.TerrainUsage.ANIMAL,        0,      ImageGroups.FIGURE_HIPPO),  // 84 hippo
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.FIGURE_WORKER_PH),  // 85
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 86
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         640,    ImageGroups.FIGURE_WATER_CARRIER),  // 87 water carrier
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         640,    ImageGroups.FIGURE_POLICEMAN),  // 88 policeman
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         800,    ImageGroups.FIGURE_MAGISTRATE),  // 89 magistrate
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 90
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 91
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 92
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 93
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 94
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 95
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 96
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 97
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 98
        new FigureActionProps (1, Enums.TerrainUsage.ANY,           0,      ImageGroups.NONE),  // 99
        new FigureActionProps (1, Enums.TerrainUsage.ROADS,         0,      ImageGroups.NONE),  // 100
    };
}