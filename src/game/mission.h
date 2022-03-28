#ifndef GAME_MISSION_H
#define GAME_MISSION_H

enum {
    SCENARIO_NULL = -1,

    // PREDYNASTIC -- PHARAOH
    SCENARIO_NUBT = 0,
    SCENARIO_THINIS_1 = 1,
    SCENARIO_PERWADJYT = 2,
    // ARCHAIC
    SCENARIO_NEKHEN = 3,
    SCENARIO_MEN_NEFER = 4,
    SCENARIO_TIMNA = 5,
    SCENARIO_BEHDET = 6,
    SCENARIO_ABEDJU = 7,
    // OLD KINGDOM
    SCENARIO_SELIMA_OASIS = 8,
    SCENARIO_ABU = 9,
    SCENARIO_SAQQARA = 10,
    SCENARIO_SERABIT_KHADIM = 11,
    SCENARIO_MEIDUM = 12,
    SCENARIO_BUHEN = 13,
    SCENARIO_SOUTH_DASHUR = 14,
    SCENARIO_NORTH_DASHUR = 15,
    SCENARIO_IUNET = 16,
    SCENARIO_ON = 17,
    SCENARIO_ROSTJA = 18,
    SCENARIO_BAHARIYA_OASIS = 19,
    SCENARIO_DJEDU = 20,
    SCENARIO_DAKHLA_OASIS = 21,
    SCENARIO_DUNQUL_OASIS = 22,
    // MIDDLE KINGDOM
    SCENARIO_THINIS_2 = 23,
    SCENARIO_WASET = 24,
    SCENARIO_KEBET = 25,
    SCENARIO_MENAT_KHUFU = 26,
    SCENARIO_ITJTAWY = 27,
    SCENARIO_IKEN = 28,
    SCENARIO_SAWU = 29,
    SCENARIO_HEH = 30,
    SCENARIO_BUBASTIS = 31,
    // NEW KINGDOM
    SCENARIO_KHMUN = 32,
    SCENARIO_SAUTY = 33,
    SCENARIO_BYBLOS = 34,
    SCENARIO_BAKI = 35,
    SCENARIO_ROWARTY = 36,
    SCENARIO_HETEPSENUSRET = 37,

    // VALLEY OF THE KINGS -- CLEOPATRA
    SCENARIO_VALLEY_THUTMOSE = 38,
    SCENARIO_VALLEY_TUT = 39,
    SCENARIO_VALLEY_SETI = 40,
    // RAMSES II
    SCENARIO_SUMUR = 41,
    SCENARIO_QADESH = 42,
    SCENARIO_ABU_SIMBEL = 43,
    SCENARIO_RAMSES_IN_THE_VALLEY = 44,
    // ANCIENT CONQUERORS
    SCENARIO_PI_YER = 45,
    SCENARIO_MIGDOL = 46,
    SCENARIO_TANIS = 47,
    // CLEOPATRA'S CAPITAL
    SCENARIO_ALEXANDRIA_1 = 48,
    SCENARIO_ALEXANDRIA_2 = 49,
    SCENARIO_MARITIS = 50,
    SCENARIO_ALEXANDRIA_3 = 51,
    SCENARIO_ACTIUM = 52,

    SCENARIO_MAX = 100
};

enum {
    CAMPAIGN_PHARAOH_PREDYNASTIC = 0,
    CAMPAIGN_PHARAOH_ARCHAIC = 1,
    CAMPAIGN_PHARAOH_OLD_KINGDOM = 2,
    CAMPAIGN_PHARAOH_MIDDLE_KINGDOM = 3,
    CAMPAIGN_PHARAOH_NEW_KINGDOM = 4,
    //
    CAMPAIGN_CLEOPATRA_VALLEY_OF_THE_KINGS = 5,
    CAMPAIGN_CLEOPATRA_RAMSES_II = 6,
    CAMPAIGN_CLEOPATRA_ANCIENT_CONQUERORS = 7,
    CAMPAIGN_CLEOPATRA_CLEOPATRAS_CAPITAL = 8,
    //
    CAMPAIGN_MAX
};

static const int SCENARIO_LAST_IN_CAMPAIGN[] = {
        SCENARIO_PERWADJYT,
        SCENARIO_ABEDJU,
        SCENARIO_DUNQUL_OASIS,
        SCENARIO_BUBASTIS,
        SCENARIO_HETEPSENUSRET,
        ///
        SCENARIO_VALLEY_SETI,
        SCENARIO_RAMSES_IN_THE_VALLEY,
        SCENARIO_TANIS,
        SCENARIO_ACTIUM
};

static const struct {
    int req_beaten[3] = {SCENARIO_NULL, SCENARIO_NULL, SCENARIO_NULL};
} SCENARIO_REQUIREMENTS_PH[] = {
        {}, // nubt
        {}, // thinis
        {}, // perwadjyt
        //
        {}, // nekhen
        {}, // men-nefer
        {}, // timna
        {SCENARIO_TIMNA}, // behdet
        {SCENARIO_TIMNA}, // abedju
        //
        {SCENARIO_BEHDET, SCENARIO_ABEDJU}, // selima oasis
        {SCENARIO_BEHDET, SCENARIO_ABEDJU}, // abu
        {SCENARIO_SELIMA_OASIS, SCENARIO_ABU}, // saqqara
        {SCENARIO_SAQQARA}, // serabit khadim
        {SCENARIO_SAQQARA}, // meidum
        {SCENARIO_SERABIT_KHADIM, SCENARIO_MEIDUM}, // buhen
        {SCENARIO_SERABIT_KHADIM, SCENARIO_MEIDUM}, // south dashur
        {SCENARIO_BUHEN, SCENARIO_SOUTH_DASHUR}, // north dashur
        {SCENARIO_NORTH_DASHUR}, // iunet
        {SCENARIO_NORTH_DASHUR}, // on
        {SCENARIO_IUNET, SCENARIO_ON}, // rostja
        {SCENARIO_ROSTJA}, // bahariya oasis
        {SCENARIO_ROSTJA}, // djedu
        {SCENARIO_BAHARIYA_OASIS, SCENARIO_DJEDU}, // dakhla oasis
        {SCENARIO_BAHARIYA_OASIS, SCENARIO_DJEDU}, // dunqul oasis
        //
        {SCENARIO_DAKHLA_OASIS, SCENARIO_DUNQUL_OASIS}, // thinis
        {SCENARIO_DAKHLA_OASIS, SCENARIO_DUNQUL_OASIS}, // waset
        {SCENARIO_THINIS_2, SCENARIO_WASET}, // kebet
        {SCENARIO_THINIS_2, SCENARIO_WASET}, // menat khufu
        {SCENARIO_KEBET, SCENARIO_MENAT_KHUFU}, // itjtawy
        {SCENARIO_ITJTAWY}, // iken
        {SCENARIO_ITJTAWY}, // sawu
        {SCENARIO_IKEN, SCENARIO_SAWU}, // heh
        {SCENARIO_IKEN, SCENARIO_SAWU}, // bubastis
        //
        {SCENARIO_HEH, SCENARIO_BUBASTIS}, // khmun
        {SCENARIO_HEH, SCENARIO_BUBASTIS}, // sauty
        {SCENARIO_KHMUN, SCENARIO_SAUTY}, // byblos
        {SCENARIO_KHMUN, SCENARIO_SAUTY}, // baki
        {SCENARIO_BYBLOS}, // rowarty
        {SCENARIO_BAKI}, // hetepsenusret

        // cleopatra
        {},
        {},
        {},
        //
        {},
        {},
        {},
        {},
        //
        {},
        {},
        {},
        //
        {},
        {},
        {},
        {},
        {}
};

//static const int RANK_CHOICE_C3[] = {
//        0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
//};
//// at the end of a mission, do we have a choice in selecting the next map?
//// 0 = no, 1 = yes
//static const int CAN_CHOOSE_NEXT_SCENARIO_PH[22] = {
//        0, 0, 0,
//        0, 0, 1,
//        1, 0, 1, 1, 0, 1, 1,
//        1, 1, 0, 1, 1,
//        1, 1, 0, 0
//};

// lookup table converting MISSION RANK to SCENARIO ID.
static const struct {
    int scenario[3] = {SCENARIO_NULL, SCENARIO_NULL, SCENARIO_NULL};
} MISSION_RANK_TO_SCENARIO[] = {
        {SCENARIO_NUBT}, // <-- no scenario will invoke this rank     0
        {SCENARIO_NEKHEN}, //                                         1
        {SCENARIO_PERWADJYT}, //                                      2
        //
        {SCENARIO_NEKHEN}, //                                         3
        {SCENARIO_MEN_NEFER}, //                                      4
        {SCENARIO_TIMNA}, //                                          5
        {SCENARIO_BEHDET, SCENARIO_ABEDJU}, //               6
        //
        {SCENARIO_SELIMA_OASIS, SCENARIO_ABU}, //            7
        {SCENARIO_SAQQARA}, //                                        8
        {SCENARIO_SERABIT_KHADIM, SCENARIO_MEIDUM}, //       9
        {SCENARIO_BUHEN, SCENARIO_SOUTH_DASHUR}, //         10
        {SCENARIO_NORTH_DASHUR}, //                                  11
        {SCENARIO_IUNET, SCENARIO_ON}, //                   12
        {SCENARIO_ROSTJA}, //                                        13
        {SCENARIO_BAHARIYA_OASIS, SCENARIO_DJEDU}, //       14
        {SCENARIO_DAKHLA_OASIS, SCENARIO_DUNQUL_OASIS}, //  15
        //
        {SCENARIO_THINIS_2, SCENARIO_WASET}, //             16
        {SCENARIO_KEBET, SCENARIO_MENAT_KHUFU}, //          17
        {SCENARIO_ITJTAWY}, //                                       18
        {SCENARIO_IKEN, SCENARIO_SAWU}, //                  19
        {SCENARIO_HEH, SCENARIO_BUBASTIS}, //               20
        //
        {SCENARIO_KHMUN, SCENARIO_SAUTY}, //                21
        {SCENARIO_BYBLOS, SCENARIO_BAKI}, //                22
        {SCENARIO_ROWARTY}, //                                       23 <--- GOD.
        {SCENARIO_HETEPSENUSRET}, //                                 24 <--- GOD.
};
// lookup table converting SCENARIO ID to MISSION RANK.
static const int SCENARIO_TO_MISSION_RANK[] = {
        0, 1, 2,
        3, 4, 5, 6, 6,
        7, 7, 8, 9, 9, 10, 10, 11, 12, 12, 13, 14, 14, 15, 15,
        16, 16, 17, 17, 18, 19, 19, 20, 20,
        21, 21, 22, 22, 23, 24, // <-- the last two are the same "rank" but are unlocked separately!
};

//int game_current_mission_rank();
//int game_mission_peaceful(void);
//int game_mission_military(void);
bool game_mission_has_choice(void);

bool game_campaign_unlocked(int campaign_id);
bool game_scenario_unlocked(int scenario_id);
bool game_scenario_beaten(int scenario_id);

#endif // GAME_MISSION_H
