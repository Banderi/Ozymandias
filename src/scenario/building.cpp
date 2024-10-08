#include "building.h"

#include "building/type.h"
#include "scenario/data.h"

bool scenario_building_allowed(int building_type) {
    if (GAME_ENV == ENGINE_ENV_C3)
        switch (building_type) {
            case BUILDING_ROAD:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_ROAD];
            case BUILDING_WATER_LIFT:
            case BUILDING_IRRIGATION_DITCH:
            case BUILDING_MENU_BEAUTIFICATION:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_AQUEDUCT];
            case BUILDING_WELL:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_WELL];
            case BUILDING_DENTIST:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_BARBER];
            case BUILDING_MENU_MONUMENTS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_BATHHOUSE];
            case BUILDING_APOTHECARY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_DOCTOR];
            case BUILDING_MORTUARY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_HOSPITAL];
            case BUILDING_MENU_TEMPLES:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_SMALL_TEMPLES];
            case BUILDING_MENU_TEMPLE_COMPLEX:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_LARGE_TEMPLES];
            case BUILDING_ORACLE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_ORACLE];
            case BUILDING_SCHOOL:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_SCHOOL];
            case BUILDING_MENU_WATER_CROSSINGS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_ACADEMY];
            case BUILDING_LIBRARY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_LIBRARY];
            case BUILDING_BOOTH:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_THEATER];
            case BUILDING_BANDSTAND:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_AMPHITHEATER];
            case BUILDING_PAVILLION:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_COLOSSEUM];
            case BUILDING_SENET_HOUSE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_HIPPODROME];
            case BUILDING_CONSERVATORY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_GLADIATOR_SCHOOL];
            case BUILDING_DANCE_SCHOOL:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_LION_HOUSE];
            case BUILDING_JUGGLER_SCHOOL:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_ACTOR_COLONY];
            case BUILDING_CHARIOT_MAKER:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_CHARIOT_MAKER];
            case BUILDING_TAX_COLLECTOR:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_FORUM];
            case BUILDING_SENATE_UPGRADED:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_SENATE];
            case BUILDING_PERSONAL_MANSION:
            case BUILDING_FAMILY_MANSION:
            case BUILDING_DYNASTY_MANSION:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_GOVERNOR_HOME];
            case BUILDING_SMALL_STATUE:
            case BUILDING_MEDIUM_STATUE:
            case BUILDING_LARGE_STATUE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_STATUES];
            case BUILDING_GARDENS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_GARDENS];
            case BUILDING_PLAZA:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_PLAZA];
            case BUILDING_ENGINEERS_POST:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_ENGINEERS_POST];
            case BUILDING_MISSION_POST:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_MISSION_POST];
            case BUILDING_SHIPYARD:
            case BUILDING_FISHING_WHARF:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_WHARF];
            case BUILDING_DOCK:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_DOCK];
            case BUILDING_WALL:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_WALL];
            case BUILDING_TOWER:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_TOWER];
            case BUILDING_GATEHOUSE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_GATEHOUSE];
            case BUILDING_POLICE_STATION:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_PREFECTURE];
            case BUILDING_MENU_FORTS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_FORT];
            case BUILDING_MILITARY_ACADEMY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_MILITARY_ACADEMY];
            case BUILDING_RECRUITER:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_BARRACKS];
            case BUILDING_DISTRIBUTION_CENTER_UNUSED:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_DISTRIBUTION_CENTER];
            case BUILDING_MENU_FARMS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_FARMS];
            case BUILDING_MENU_RAW_MATERIALS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_RAW_MATERIALS];
            case BUILDING_MENU_GUILDS:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_WORKSHOPS];
            case BUILDING_MARKET:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_MARKET];
            case BUILDING_GRANARY:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_GRANARY];
            case BUILDING_WAREHOUSE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_WAREHOUSE];
            case BUILDING_LOW_BRIDGE:
            case BUILDING_SHIP_BRIDGE:
                return scenario_data.allowed_buildings[ALLOWED_BUILDING_BRIDGE];
        }
    else if (GAME_ENV == ENGINE_ENV_PHARAOH)
        switch (building_type) {
            case BUILDING_GOLD_MINE:
                return scenario_data.allowed_buildings[2];
            case BUILDING_WATER_LIFT:
                return scenario_data.allowed_buildings[3];
            case BUILDING_IRRIGATION_DITCH:
                return scenario_data.allowed_buildings[4];
            case BUILDING_SHIPYARD:
                return scenario_data.allowed_buildings[5];
            case BUILDING_WORK_CAMP:
                return scenario_data.allowed_buildings[6];
            case BUILDING_GRANARY:
                return scenario_data.allowed_buildings[7];
            case BUILDING_MARKET:
                return scenario_data.allowed_buildings[8];
            case BUILDING_WAREHOUSE:
                return scenario_data.allowed_buildings[9];
            case BUILDING_DOCK:
                return scenario_data.allowed_buildings[10];
            case BUILDING_BOOTH:
            case BUILDING_JUGGLER_SCHOOL:
                return scenario_data.allowed_buildings[11];
            case BUILDING_BANDSTAND:
            case BUILDING_CONSERVATORY:
                return scenario_data.allowed_buildings[12];
            case BUILDING_PAVILLION:
            case BUILDING_DANCE_SCHOOL:
                return scenario_data.allowed_buildings[13];
            case BUILDING_SENET_HOUSE:
                return scenario_data.allowed_buildings[14];
            case BUILDING_FESTIVAL_SQUARE:
                return scenario_data.allowed_buildings[15];
            case BUILDING_SCHOOL:
                return scenario_data.allowed_buildings[16];
            case BUILDING_LIBRARY:
                return scenario_data.allowed_buildings[17];
            case BUILDING_WATER_SUPPLY:
                return scenario_data.allowed_buildings[18];
            case BUILDING_DENTIST:
                return scenario_data.allowed_buildings[19];
            case BUILDING_APOTHECARY:
                return scenario_data.allowed_buildings[20];
            case BUILDING_PHYSICIAN:
                return scenario_data.allowed_buildings[21];
            case BUILDING_MORTUARY:
                return scenario_data.allowed_buildings[22];
            case BUILDING_TAX_COLLECTOR:
                return scenario_data.allowed_buildings[23];
            case BUILDING_COURTHOUSE:
                return scenario_data.allowed_buildings[24];
            case BUILDING_VILLAGE_PALACE:
            case BUILDING_TOWN_PALACE:
            case BUILDING_CITY_PALACE:
                return scenario_data.allowed_buildings[25];
            case BUILDING_PERSONAL_MANSION:
            case BUILDING_FAMILY_MANSION:
            case BUILDING_DYNASTY_MANSION:
                return scenario_data.allowed_buildings[26];
            case BUILDING_ROADBLOCK:
                return scenario_data.allowed_buildings[27];
            case BUILDING_LOW_BRIDGE:
                return scenario_data.allowed_buildings[28];
            case BUILDING_FERRY:
                return scenario_data.allowed_buildings[29];
            case BUILDING_GARDENS:
                return scenario_data.allowed_buildings[30];
            case BUILDING_PLAZA:
                return scenario_data.allowed_buildings[31];
            case BUILDING_SMALL_STATUE:
            case BUILDING_MEDIUM_STATUE:
            case BUILDING_LARGE_STATUE:
                return scenario_data.allowed_buildings[32];
            case BUILDING_WALL_PH:
                return scenario_data.allowed_buildings[33];
            case BUILDING_TOWER_PH:
                return scenario_data.allowed_buildings[34];
            case BUILDING_GATEHOUSE_PH:
                return scenario_data.allowed_buildings[35];
            case BUILDING_RECRUITER:
                return scenario_data.allowed_buildings[36];
            case BUILDING_FORT_INFANTRY:
                return scenario_data.allowed_buildings[37];
            case BUILDING_FORT_ARCHERS:
                return scenario_data.allowed_buildings[38];
            case BUILDING_FORT_CHARIOTEERS:
                return scenario_data.allowed_buildings[39];
            case BUILDING_MILITARY_ACADEMY:
                return scenario_data.allowed_buildings[40];
            case BUILDING_WEAPONS_WORKSHOP:
                return scenario_data.allowed_buildings[41];
            case BUILDING_CHARIOTS_WORKSHOP:
                return scenario_data.allowed_buildings[42];
            case BUILDING_WARSHIP_WHARF:
                return scenario_data.allowed_buildings[43];
            case BUILDING_TRANSPORT_WHARF:
                return scenario_data.allowed_buildings[44];
            case BUILDING_ZOO:
                return scenario_data.allowed_buildings[45];
                ///
            case BUILDING_TEMPLE_COMPLEX_OSIRIS:
                return scenario_data.allowed_buildings[104];
            case BUILDING_TEMPLE_COMPLEX_RA:
                return scenario_data.allowed_buildings[105];
            case BUILDING_TEMPLE_COMPLEX_PTAH:
                return scenario_data.allowed_buildings[106];
            case BUILDING_TEMPLE_COMPLEX_SETH:
                return scenario_data.allowed_buildings[107];
            case BUILDING_TEMPLE_COMPLEX_BAST:
                return scenario_data.allowed_buildings[108];
        }
    return true;
}

int scenario_building_image_native_hut(void) {
    return scenario_data.native_images.hut;
}

int scenario_building_image_native_meeting(void) {
    return scenario_data.native_images.meeting;
}

int scenario_building_image_native_crops(void) {
    return scenario_data.native_images.crops;
}
