#ifndef OZYMANDIAS_FILE_FORMATS_H
#define OZYMANDIAS_FILE_FORMATS_H

typedef enum {
    FILE_FORMAT_NULL,
    //
    FILE_FORMAT_BMP,
    FILE_FORMAT_PNG,
    FILE_FORMAT_JPG,
    //
    FILE_FORMAT_SGX,
    FILE_FORMAT_555,
    //
    FILE_FORMAT_MISSION_PAK,
    FILE_FORMAT_SAVE_FILE,
    FILE_FORMAT_MAP_FILE,
    //
    FILE_FORMAT_JAS_RECORDS,
    FILE_FORMAT_PLAYER_DATA,
} file_format_t;

file_format_t get_format_from_file(const char *filename);

#endif //OZYMANDIAS_FILE_FORMATS_H
