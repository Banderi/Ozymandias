#include "image.h"

#include "SDL.h"

#include "core/buffer.h"
#include "core/file.h"
#include "core/io.h"
#include "core/log.h"
#include "core/mods.h"
#include "core/config.h"
#include "core/game_environment.h"

#include <stdlib.h>
#include <string.h>
#include <graphics/graphics.h>
#include <cassert>
#include <cinttypes>
#include <graphics/renderer.h>
#include "core/string.h"
#include "stopwatch.h"
#include "image_packer.h"

#define ENTRY_SIZE 64
#define NAME_SIZE 32

#define SCRATCH_DATA_SIZE 20000000

enum {
    NO_EXTRA_FONT = 0,
    FULL_CHARSET_IN_FONT = 1,
    MULTIBYTE_IN_FONT = 2
};

static struct {
    int current_climate;
    bool is_editor;
    bool fonts_enabled;
    int font_base_offset;

    std::vector<imagepak**> pak_list;

    imagepak *main;
    imagepak *terrain;
    imagepak *unloaded;
    imagepak *sprmain;
    imagepak *sprambient;

    imagepak *expansion;
    imagepak *sprmain2;

    std::vector<imagepak*> temple_paks;
    std::vector<imagepak*> monument_paks;
    std::vector<imagepak*> enemy_paks;
    std::vector<imagepak*> font_paks;

    imagepak *temple;
    imagepak *monument;
    imagepak *enemy;
    imagepak *empire;
    imagepak *font;

    color_t *tmp_image_data;
} data;

int terrain_ph_offset = 0;

static color_t to_32_bit(uint16_t c) {
    return ALPHA_OPAQUE |
           ((c & 0x7c00) << 9) | ((c & 0x7000) << 4) |
           ((c & 0x3e0) << 6) | ((c & 0x380) << 1) |
           ((c & 0x1f) << 3) | ((c & 0x1c) >> 2);
}

static int convert_uncompressed(buffer *buf, const image *img) {
    int pixels_count = 0;
    auto p_atlas = img->atlas.p_atlas;

    for (int y = 0; y < img->height; y++) {
        color_t *pixel = &p_atlas->raw_buffer[(img->atlas.y_offset + y) * p_atlas->width + img->atlas.x_offset];
        for (int x = 0; x < img->width; x++) {
            color_t color = to_32_bit(buf->read_u16());
            pixel[x] = color == COLOR_SG2_TRANSPARENT ? ALPHA_TRANSPARENT : color;
            pixels_count++;
        }
    }
//    for (int i = 0; i < buf_length; i += 2) {
//        color_t c = to_32_bit(buf->read_u16());
//        *dst = c;
//        dst++;
//    }
    return pixels_count;
}
static int convert_compressed(buffer *buf, int data_length, const image *img) {
    int pixels_count = 0;
    auto p_atlas = img->atlas.p_atlas;
//    int atlas_x = img->atlas.x_offset;
//    int atlas_y = img->atlas.y_offset;
    int atlas_dst = (img->atlas.y_offset * p_atlas->width) + img->atlas.x_offset;
    int y = 0;
    int x = 0;
    while (data_length > 0) {
        int control = buf->read_u8();
        if (control == 255) {
            // next byte = transparent pixels to skip
            int skip = buf->read_u8();
            y += skip / img->width;
            x += skip % img->width;
            if (x >= img->width) {
                y++;
                x -= img->width;
            }
            data_length -= 2;
        } else {
            // control = number of concrete pixels
            for (int i = 0; i < control; i++) {
//                color_t *pixel = &p_atlas->raw_buffer[(img->atlas.y_offset + y) * p_atlas->width + img->atlas.x_offset + x];
//                *pixel = to_32_bit(buf->read_u16());
                int dst = atlas_dst + y * p_atlas->width + x;
                p_atlas->raw_buffer[dst] = to_32_bit(buf->read_u16());
                x++;
                if (x >= img->width) {
                    y++;
                    x -= img->width;
                }
            }
            data_length -= control * 2 + 1;
        }
    }
//    int dst_length = 0;
//    while (buf_length > 0) {
//        int control = buf->read_u8();
//        if (control == 255) {
//            // next byte = transparent pixels to skip
//            *dst++ = 255;
//            *dst++ = buf->read_u8();
//            dst_length += 2;
//            buf_length -= 2;
//        } else {
//            // control = number of concrete pixels
//            *dst++ = control;
//            for (int i = 0; i < control; i++) {
//                *dst++ = to_32_bit(buf->read_u16());
//            }
//            dst_length += control + 1;
//            buf_length -= control * 2 + 1;
//        }
//    }
    return pixels_count;
}

static const int FOOTPRINT_X_START_PER_HEIGHT[] = {
        28, 26, 24, 22, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 0,
        0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28
};

static const int FOOTPRINT_OFFSET_PER_HEIGHT[] = {
        0, 2, 8, 18, 32, 50, 72, 98, 128, 162, 200, 242, 288, 338, 392, 450,
        508, 562, 612, 658, 700, 738, 772, 802, 828, 850, 868, 882, 892, 898
};

static int convert_footprint_tile(buffer *buf, const image *img, int x_offset, int y_offset) {
    int pixels_count = 0;
    auto p_atlas = img->atlas.p_atlas;

    for (int y = 0; y < FOOTPRINT_HEIGHT; y++) {
        int x_start = FOOTPRINT_X_START_PER_HEIGHT[y];
        int x_max = FOOTPRINT_WIDTH - x_start;
        for (int x = x_start; x < x_max; x++) {
            p_atlas->raw_buffer[(y + y_offset + img->atlas.y_offset) * p_atlas->width + img->atlas.x_offset + x + x_offset] =
                    to_32_bit(buf->read_u16());
        }
    }
    return pixels_count;
}
static int convert_isometric_footprint(buffer *buf, const image *img) {
    int pixels_count = 0;
    auto p_atlas = img->atlas.p_atlas;

    int num_tiles = (img->width + 2) / (FOOTPRINT_WIDTH + 2);
    int x_start = (num_tiles - 1) * 30;
    int y_offset;

    if (graphics_renderer()->isometric_images_are_joined()) {
        y_offset = img->height - 30 * num_tiles;
    } else {
        y_offset = img->draw.top_height;
    }

    for (int i = 0; i < num_tiles; i++) {
        int x = -30 * i + x_start;
        int y = FOOTPRINT_HALF_HEIGHT * i + y_offset;
        for (int j = 0; j <= i; j++) {
            convert_footprint_tile(buf, img, x, y);
            x += 60;
        }
    }
    for (int i = num_tiles - 2; i >= 0; i--) {
        int x = -30 * i + x_start;
        int y = FOOTPRINT_HALF_HEIGHT * (num_tiles * 2 - i - 2) + y_offset;
        for (int j = 0; j <= i; j++) {
            convert_footprint_tile(buf, img, x, y);
            x += 60;
        }
    }
    return pixels_count;
}

static buffer *temp_external_image_buf = nullptr;
static const color_t *load_external_data(const image *img) {
    char filename[MAX_FILE_NAME];
    int size = 0;
    safe_realloc_for_size(&temp_external_image_buf, img->draw.data_length);
    switch (GAME_ENV) {
        case ENGINE_ENV_PHARAOH:
            strcpy(&filename[0], "Data/");
            strcpy(&filename[5], img->draw.bitmap_name);
            file_change_extension(filename, "555");
            size = io_read_file_part_into_buffer(
                    &filename[5], MAY_BE_LOCALIZED, temp_external_image_buf,
                    img->draw.data_length, img->draw.sg3_offset - 1
            );
            break;
    }
    if (!size) {
        // try in 555 dir
        size = io_read_file_part_into_buffer(
                filename, MAY_BE_LOCALIZED, temp_external_image_buf,
                img->draw.data_length, img->draw.sg3_offset - 1
        );
        if (!size) {
            log_error("unable to load external image", img->draw.bitmap_name, 0);
            return NULL;
        }
    }
//    color_t *dst = (color_t *) &data.tmp_data[4000000];

    // NB: isometric images are never external
    if (img->draw.is_fully_compressed)
        convert_compressed(temp_external_image_buf, img->draw.data_length, img);
    else {
        convert_uncompressed(temp_external_image_buf, img);
    }
    return data.tmp_image_data;
}

static int convert_image_data(buffer *buf, image *img) {
    if (img->draw.is_fully_compressed)
        convert_compressed(buf, img->draw.data_length, img);
    else if (img->draw.top_height) { // isometric tile
        convert_isometric_footprint(buf, img);
        convert_compressed(buf, img->draw.data_length - img->draw.uncompressed_length, img);
    } else if(img->draw.type == IMAGE_TYPE_ISOMETRIC)
        convert_isometric_footprint(buf, img);
    else
        convert_uncompressed(buf, img);

    img->draw.data = &img->atlas.p_atlas->raw_buffer[(img->atlas.y_offset * img->atlas.p_atlas->width) + img->atlas.x_offset];
//    img->draw.data = dst;
    img->draw.uncompressed_length /= 2;
}

//////////////////////// IMAGEPAK

static stopwatch WATCH;

imagepak::imagepak(const char *filename_partial, int starting_index) {
//    images = nullptr;
//    image_data = nullptr;
    entries_num = 0;
    group_image_ids = new uint16_t[300];

    load_pak(filename_partial, starting_index);
}
imagepak::~imagepak() {
//    delete images;
//    delete image_data;
}

buffer *scratch_data_buf = nullptr;
bool imagepak::load_pak(const char *filename_partial, int starting_index) {

    WATCH.START();

    // construct proper filepaths
    int str_index = 0;
    uint8_t filename_full[100];

    // add "data/" if loading paks in Pharaoh
    if (GAME_ENV == ENGINE_ENV_PHARAOH) {
        string_copy(string_from_ascii("data/"), filename_full, 6);
        str_index += 5;
    }

    // copy file name over
    string_copy((const uint8_t*)filename_partial, &filename_full[str_index], string_length((const uint8_t*)filename_partial) + 1);
    str_index = string_length(filename_full);

    // split in .555 and .sg3 filename strings
    uint8_t filename_555[100];
    uint8_t filename_sgx[100];
    string_copy(filename_full, filename_555, str_index + 1);
    string_copy(filename_full, filename_sgx, str_index + 1);

    // add extension
    string_copy(string_from_ascii(".555"), &filename_555[str_index], 5);
    string_copy(string_from_ascii(".sg3"), &filename_sgx[str_index], 5);

    // prepare sgx data
    safe_realloc_for_size(&scratch_data_buf, SCRATCH_DATA_SIZE);
    if (!io_read_file_into_buffer((const char*)filename_sgx, MAY_BE_LOCALIZED, scratch_data_buf, SCRATCH_DATA_SIZE)) //int MAIN_INDEX_SIZE = 660680;
        return false;
    int HEADER_SIZE = 0;
    if (file_has_extension((const char*)filename_sgx, "sg2"))
        HEADER_SIZE = 20680; // sg2 has 100 bitmap entries
    else
        HEADER_SIZE = 40680; //

    // read header
    scratch_data_buf->read_raw(header_data, sizeof(uint32_t) * 10);

    // allocate arrays
    entries_num = (size_t) header_data[4] + 1;
//    name = (const char*)filename_sgx;
//    images = new image[entries_num];
    images_array.reserve(entries_num);
//    image_data = new color_t[entries_num * 10000];

    scratch_data_buf->skip(40); // skip remaining 40 bytes

    // adjust global index (depends on the pak)
    id_shift_overall = starting_index;

    // parse groups (always a fixed 300 pool)
    groups_num = 0;
    for (int i = 0; i < 300; i++) {
        group_image_ids[i] = scratch_data_buf->read_u16();
        if (group_image_ids[i] != 0 || i == 0) {
            groups_num++;
//            SDL_Log("%s group %i -> id %i", filename_sgx, i, group_image_ids[i]);
        }
    }

    // parse bitmap names;
    // every line is 200 chars - 97 entries in the original c3.sg2
    // header (100 for good measure) and 18 in Pharaoh_General.sg3
    int num_bmp_names = (int)header_data[5];
    char bmp_names[num_bmp_names][200];
    scratch_data_buf->read_raw(bmp_names, 200 * num_bmp_names);

    // move on to the rest of the content
    scratch_data_buf->set_offset(HEADER_SIZE);

    // fill in image data
    int bmp_lastbmp = 0;
    int bmp_lastindex = 1;
    const int entries_num_original = entries_num; // TODO
    for (int i = 0; i < entries_num_original; i++) {
        image img;
        img.draw.sg3_offset = scratch_data_buf->read_i32();
        img.draw.data_length = scratch_data_buf->read_i32();
        img.draw.uncompressed_length = scratch_data_buf->read_i32();
        scratch_data_buf->skip(4);
        img.offset_mirror = scratch_data_buf->read_i32(); // .sg3 only
        // clamp dimensions so that it's not below zero!
        img.width = scratch_data_buf->read_i16(); img.width = img.width < 0 ? 0 : img.width;
        img.height = scratch_data_buf->read_i16(); img.height = img.height < 0 ? 0 : img.height;
        scratch_data_buf->skip(6);
        img.animation.num_sprites = scratch_data_buf->read_u16();
        scratch_data_buf->skip(2);
        img.animation.sprite_x_offset = scratch_data_buf->read_i16();
        img.animation.sprite_y_offset = scratch_data_buf->read_i16();
        scratch_data_buf->skip(10);
        img.animation.can_reverse = scratch_data_buf->read_i8();
        scratch_data_buf->skip(1);
        img.draw.type = scratch_data_buf->read_u8();
        img.draw.is_fully_compressed = scratch_data_buf->read_i8();
        img.draw.is_external = scratch_data_buf->read_i8();
        img.draw.top_height = scratch_data_buf->read_i8();
        scratch_data_buf->skip(2);
        int bitmap_id = scratch_data_buf->read_u8();
        img.draw.bitmap_name = bmp_names[bitmap_id];
//        strncpy(img.draw.bitmap_name, bmn, 200);
        if (bitmap_id != bmp_lastbmp) { // new bitmap name, reset bitmap grouping index
            bmp_lastindex = 1;
            bmp_lastbmp = bitmap_id;
        }
        img.draw.bmp_index = bmp_lastindex;
        bmp_lastindex++;
        scratch_data_buf->skip(1);
        img.animation.speed_id = scratch_data_buf->read_u8();
        if (header_data[1] < 214)
            scratch_data_buf->skip(5);
        else
            scratch_data_buf->skip(5 + 8);
        images_array.push_back(img);
//        images[i] = img;
        int f = 1;
    }

    // prepare image packer & renderer
    int max_texture_width;
    int max_texture_height;
    graphics_renderer()->get_max_image_size(&max_texture_width, &max_texture_height);
    if (image_packer_init(&packer, entries_num, max_texture_width, max_texture_height) != IMAGE_PACKER_OK)
        return false;
    packer.options.fail_policy = IMAGE_PACKER_NEW_IMAGE;
    packer.options.reduce_image_size = 1;
    packer.options.sort_by = IMAGE_PACKER_SORT_BY_AREA;

    // TODO
//    image_data = new color_t[entries_num * 10000];

    // read bitmap data into buffer
    scratch_data_buf->clear();
    int data_size = io_read_file_into_buffer((const char*)filename_555, MAY_BE_LOCALIZED, scratch_data_buf, SCRATCH_DATA_SIZE);
    if (!data_size)
        return false;

    // fill in bmp offset data
    int offset = 4;
    for (int i = 1; i < entries_num; i++) {
        image *img = &images_array.at(i);
        if (img->draw.is_external) {
            if (!img->draw.sg3_offset)
                img->draw.sg3_offset = 1;
        } else {
            img->draw.sg3_offset = offset;
            offset += img->draw.data_length;

            // record packer rect
            image_packer_rect *rect = &packer.rects[i];
            rect->input.width = img->width;
            rect->input.height = img->height;
        }
    }

    // generate atlas pages
//    SDL_Log("%s -> %i images, %i size", filename_sgx, entries_num, data_size);
    image_packer_pack(&packer);
    atlas_pages.reserve(packer.result.images_needed);
    for (int i = 0; i < packer.result.images_needed; ++i) {
        atlas_data_t atlas_data;
        atlas_data.width = i == packer.result.images_needed - 1 ? packer.result.last_image_width : max_texture_width;
        atlas_data.height = i == packer.result.images_needed - 1 ? packer.result.last_image_height : max_texture_height;
        atlas_data.raw_size = atlas_data.width * atlas_data.height;
        atlas_data.raw_buffer = new color_t[atlas_data.raw_size];
        atlas_data.texture = nullptr;
        atlas_pages.push_back(atlas_data);
    }

    // finish filling in image and atlas information
//    color_t *start_dst = image_data;
//    color_t *dst = image_data;
//    dst++; // make sure img->offset > 0
    for (int i = 0; i < entries_num; i++) {
        image *img = &images_array.at(i);
        if (img->draw.is_external)
            continue;
        image_packer_rect *rect = &packer.rects[i];
//        img->atlas.id = (type << IMAGE_ATLAS_BIT_OFFSET) + rect->output.image_index;
        img->atlas.index = rect->output.image_index;
        atlas_data_t *p_data = &atlas_pages.at(img->atlas.index);
        img->atlas.p_atlas = p_data;
        img->atlas.x_offset = rect->output.x;
        img->atlas.y_offset = rect->output.y;
        if (img->atlas.index != 0)
            int a = 5;
        p_data->num_images++;
        p_data->images.push_back(img);


        // convert bitmap data for image pool
        if (img->draw.is_external)
            continue;
        scratch_data_buf->set_offset(img->draw.sg3_offset);
//        int img_offset = (int) (dst - start_dst);

//        color_t *dst = atlas_data->buffers[img->atlas.id & IMAGE_ATLAS_BIT_MASK];
//        atlas_data->buffers[img->atlas.id & IMAGE_ATLAS_BIT_MASK] = dst;
//        int dst_width = atlas_data->image_widths[img->atlas.id & IMAGE_ATLAS_BIT_MASK];
//        atlas_data->image_widths[img->atlas.id & IMAGE_ATLAS_BIT_MASK] = img->draw.data_length;

//        color_t *dst = &p_data->raw_buffer[rect->output.x + p_data->width * rect->output.y];
        int r = convert_image_data(scratch_data_buf, img);

//        if (img->draw.is_fully_compressed)
//            convert_compressed(scratch_data_buf, img->draw.data_length, img);
//        else if (img->draw.top_height) { // isometric tile
//            convert_uncompressed(scratch_data_buf, img);
//            convert_compressed(scratch_data_buf, img->draw.data_length - img->draw.uncompressed_length, img);
//        } else
//            convert_uncompressed(scratch_data_buf, img);

//        if (!img->draw.top_height && img->draw.is_fully_compressed) {
//            img->draw.data = malloc(img->width * img->height * sizeof(color_t));
//            if (draw_data->buffer) {
//                int reduce_width = type != ATLAS_FONT;
//                if (type == ATLAS_MAIN) {
//                    reduce_width = i < image_group(GROUP_FONT) || i >= image_group(GROUP_FONT) + BASE_FONT_ENTRIES;
//                }
//                draw_data->original_width = img->width;
//                memset(draw_data->buffer, 0, img->width * img->height * sizeof(color_t));
//                buffer_set(buf, draw_data->offset);
//                convert_compressed(buf, img, draw_data->data_length, draw_data->buffer, img->width);
//                image_crop(img, draw_data->buffer, reduce_width);
//            }
//        }

//        img->draw.sg3_offset = img_offset;
//        img->draw.uncompressed_length /= 2;
//        img->draw.data = dst;
//        SDL_Log("Loading... %s : %i", filename_555, i);
    }

    int r = graphics_renderer()->prepare_image_atlas(this, &packer);
//    if (!atlas_data) {
//        image_packer_free(&data.packer);
////        free(tmp_data);
////        free(draw_data);
////        free(data.external_draw_data);
////        data.external_draw_data = 0;
//        SDL_Log("Atlas data init failed!");
//        return false;
//    }

//    assets_init(atlas_data->buffers, atlas_data->image_widths);
    graphics_renderer()->create_image_atlas(this, &packer);
    image_packer_free(&packer);

    SDL_Log("Loaded imagepak from '%s' ---- %i images, %i groups, %ix%i atlas pages (%i), %" PRIu64 " milliseconds.",
            filename_sgx,
            entries_num,
            groups_num,
            atlas_pages.at(atlas_pages.size() - 1).width,
            atlas_pages.at(atlas_pages.size() - 1).height,
            atlas_pages.size(),
            WATCH.STOP());

    return true;
}

int imagepak::get_entry_count() {
    return entries_num;
}
int imagepak::get_id(int group) {
    if (group >= groups_num)
        return -1;
//        group = 0;
    int image_id = group_image_ids[group];
    return image_id + id_shift_overall;
}
const image *imagepak::get_image(int id, bool relative) {
    if (!relative)
        id -= id_shift_overall;
    if (id < 0 || id >= entries_num)
        return nullptr;
    return &images_array.at(id);
}

////////////////////////

#include "window/city.h"

static imagepak *pak_from_collection_id(int collection, int pak_cache_idx) {
    switch (GAME_ENV) {
        case ENGINE_ENV_PHARAOH:
            switch (collection) {
                case IMAGE_COLLECTION_UNLOADED:
                    return data.unloaded;
                case IMAGE_COLLECTION_TERRAIN:
                    return data.terrain;
                case IMAGE_COLLECTION_GENERAL:
                    return data.main;
                case IMAGE_COLLECTION_SPR_MAIN:
                    return data.sprmain;
                case IMAGE_COLLECTION_SPR_AMBIENT:
                    return data.sprambient;
                case IMAGE_COLLECTION_EMPIRE:
                    return data.empire;
                    /////
                case IMAGE_COLLECTION_FONT:
                    if (pak_cache_idx < 0 || pak_cache_idx >= data.font_paks.size())
                        return data.font;
                    else
                        return data.font_paks.at(pak_cache_idx);
                    return data.font;
                    /////
                case IMAGE_COLLECTION_TEMPLE:
                    if (pak_cache_idx < 0 || pak_cache_idx >= data.temple_paks.size())
                        return data.temple;
                    else
                        return data.temple_paks.at(pak_cache_idx);
                case IMAGE_COLLECTION_MONUMENT:
                    if (pak_cache_idx < 0 || pak_cache_idx >= data.monument_paks.size())
                        return data.monument;
                    else
                        return data.monument_paks.at(pak_cache_idx);
                case IMAGE_COLLECTION_ENEMY:
                    if (pak_cache_idx < 0 || pak_cache_idx >= data.enemy_paks.size())
                        return data.enemy;
                    else
                        return data.enemy_paks.at(pak_cache_idx);
                    /////
                case IMAGE_COLLECTION_EXPANSION:
                    return data.expansion;
                case IMAGE_COLLECTION_EXPANSION_SPR:
                    return data.sprmain2;
                    /////
            }
            break;
    }
    return nullptr;
}
int image_id_from_group(int collection, int group, int pak_cache_idx) {
    imagepak *pak = pak_from_collection_id(collection, pak_cache_idx);
    if (pak == nullptr)
        return -1;
    return pak->get_id(group);
}
const image *image_get(int id, int mode) {
    const image *img;
    for (int i = 0; i < data.pak_list.size(); ++i) {
        imagepak *pak = *(data.pak_list.at(i));
        if (pak == nullptr)
            continue;
        img = (pak)->get_image(id);
        if (img != nullptr)
            return img;
    }
    // default (failure)
    return image_get(image_id_from_group(GROUP_TERRAIN_BLACK));
    return nullptr;
}
const image *image_letter(int letter_id) {
    if (data.fonts_enabled == FULL_CHARSET_IN_FONT)
        return data.font->get_image(data.font_base_offset + letter_id);
    else if (data.fonts_enabled == MULTIBYTE_IN_FONT && letter_id >= IMAGE_FONT_MULTIBYTE_OFFSET)
        return data.font->get_image(data.font_base_offset + letter_id - IMAGE_FONT_MULTIBYTE_OFFSET);
    else if (letter_id < IMAGE_FONT_MULTIBYTE_OFFSET)
        return image_get(image_id_from_group(GROUP_FONT) + letter_id);
    else {
        return nullptr;
    }
}
const image *image_get_enemy(int id) {
    return data.enemy->get_image(id);
}
const color_t *image_data(int id) {
    const image *lookup = image_get(id);
    const image *img = image_get(id + lookup->offset_mirror);
    if (img->draw.is_external)
        return load_external_data(img);
    else
        return img->draw.data; // todo: mods
}
const color_t *image_data_letter(int letter_id) {
    return image_letter(letter_id)->draw.data;
}
const color_t *image_data_enemy(int id) {
    const image *lookup = image_get(id);
    const image *img = image_get(id + lookup->offset_mirror);
    id += img->offset_mirror;
    if (img->draw.sg3_offset > 0)
        return img->draw.data;
    return NULL;
}

void image_data_init() {
    data.current_climate = -1;
    data.is_editor = false;
    data.fonts_enabled = false;
    data.font_base_offset = 0;

    data.tmp_image_data = new color_t[SCRATCH_DATA_SIZE - 4000000];

    // add paks to parsing list cache
    data.pak_list.push_back(&data.sprmain);
    data.pak_list.push_back(&data.unloaded);
    data.pak_list.push_back(&data.main);
    data.pak_list.push_back(&data.terrain);
    data.pak_list.push_back(&data.temple);
    data.pak_list.push_back(&data.sprambient);
    data.pak_list.push_back(&data.font);
    data.pak_list.push_back(&data.empire);
    data.pak_list.push_back(&data.sprmain2);
    data.pak_list.push_back(&data.expansion);
    data.pak_list.push_back(&data.monument);
}

const char* enemy_file_names_c3[20] = {
        "goths",
        "Etruscan",
        "Etruscan",
        "carthage",
        "Greek",
        "Greek",
        "egyptians",
        "Persians",
        "Phoenician",
        "celts",
        "celts",
        "celts",
        "Gaul",
        "Gaul",
        "goths",
        "goths",
        "goths",
        "Phoenician",
        "North African",
        "Phoenician"
};
const char* enemy_file_names_ph[20] = {
        "Assyrian",
        "Egyptian",
        "Canaanite",
        "Enemy_1",
        "Hittite",
        "Hyksos",
        "Kushite",
        "Libian",
        "Mitani",
        "Nubian",
        "Persian",
        "Phoenician",
        "Roman",
        "SeaPeople",
        "",
        "",
        "",
        "",
        "",
        ""
};

bool image_load_main_paks(int climate_id, int is_editor, int force_reload) {
    if (climate_id == data.current_climate && is_editor == data.is_editor && !force_reload)
        return true;

    const char *filename_555;
    const char *filename_sgx;
    switch (GAME_ENV) {
        case ENGINE_ENV_PHARAOH:

            // Pharaoh loads every image into a global listed cache; however, some
            // display systems use discordant indexes; The sprites cached in the
            // save files, for examples, appear to start at 700 while the terrain
            // system displays them starting at the immediate index after the first
            // pak has ended (683).
            // Moreover, the monuments, temple complexes, and enemies all make use
            // of a single shared index, which is swapped in "real time" for the
            // correct pak in use by the mission, or even depending on buildings
            // present on the map, like the Temple Complexes.
            // What an absolute mess!

            data.unloaded = new imagepak("Pharaoh_Unloaded", 0);    // 0     --> 682
            data.sprmain = new imagepak("SprMain", 700);                              // 700   --> 11007
            // <--- original enemy pak in here                                                               // 11008 --> 11866
            data.main = new imagepak("Pharaoh_General", 11906 - 200);                 // 11906 --> 11866
            data.terrain = new imagepak("Pharaoh_Terrain", 14452 -200);               // 14252 --> 15767 (+64)
            // <--- original temple complex pak here
            data.sprambient = new imagepak("SprAmbient", 15831);                      // 15831 --> 18765
            data.font = new imagepak("Pharaoh_Fonts", 18765);                         // 18765 --> 20305
            data.empire = new imagepak("Empire", 20305);                              // 20305 --> 20506 (+177)
            data.sprmain2 = new imagepak("SprMain2", 20683);                          // 20683 --> 23035
            data.expansion = new imagepak("Expansion", 23035);                        // 23035 --> 23935 (-200)
            // <--- original pyramid pak in here                                                             // 23735 --> 24163

            // the 5 Temple Complex paks.
            data.temple_paks.push_back(new imagepak("Temple_nile", 15591));
            data.temple_paks.push_back(new imagepak("Temple_ra", 15591));
            data.temple_paks.push_back(new imagepak("Temple_ptah", 15591));
            data.temple_paks.push_back(new imagepak("Temple_seth", 15591));
            data.temple_paks.push_back(new imagepak("Temple_bast", 15591));

            // the various Monument paks.
            data.monument_paks.push_back(new imagepak("Mastaba", 23735));
            data.monument_paks.push_back(new imagepak("Pyramid", 23735));
            data.monument_paks.push_back(new imagepak("bent_pyramid", 23735));

            // the various Enemy paks.
            for (int i = 0; i < 20; ++i) {
                if (enemy_file_names_ph[i] != "")
                    data.enemy_paks.push_back(new imagepak(enemy_file_names_ph[i], 11026));
            }

            // (set the first in the bunch as active initially, just for defaults)
            data.temple = data.temple_paks.at(0);
            data.monument = data.monument_paks.at(0);
            data.enemy = data.enemy_paks.at(0);
            break;
    }

    data.is_editor = is_editor;
    return true;
}

bool image_set_enemy_pak(int enemy_id) {
    data.enemy = data.enemy_paks.at(enemy_id);
//    switch (GAME_ENV) {
//        case ENGINE_ENV_PHARAOH:
//            data.enemy = new imagepak(enemy_file_names_ph[enemy_id], 11026);
//            break;
//    }
    return true;
}
bool image_set_font_pak(encoding_type encoding) {
    // TODO?
    if (encoding == ENCODING_CYRILLIC)
        return false;
    else if (encoding == ENCODING_TRADITIONAL_CHINESE)
        return false;
    else if (encoding == ENCODING_SIMPLIFIED_CHINESE)
        return false;
    else if (encoding == ENCODING_KOREAN)
        return false;
    else {
//        free(data.font);
//        free(data.font_data);
//        data.font = 0;
//        data.font_data = 0;
        data.fonts_enabled = NO_EXTRA_FONT;
        return true;
    }
}
