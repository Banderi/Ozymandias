using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

// HOW GODOT WORKS:
// - Image is CPU-side, Texture is GPU-side.
// - Texture data is uploaded to the GPU when the Texture is created or updated, and then it can be used in draw commands.
// - CanvasItem is a GPU-side draw command list and acts as a 2D layer.
//          *** NOTE: in Godot, "CanvasItem" actually is the name of the base class for all 2D nodes! but what we're using
//          here is the VisualServer.CanvasItem API. there do not have a scene tree representation, they're just used to
//          batch draw commands for 2D rendering. ***
// - VisualServer is the low-level API for creating/managing the above. it only deals with RIDs which are handles to GPU resources.
// Before the rendering itself, everything is CPU-side:
//   - CanvasItemAddTextureRectRegion adds a draw command to a CanvasItem, which will be drawn in the next frame.
//   - CanvasItemClear removes all draw commands from a CanvasItem.
// At rendering time (frame draw):
//   - the engine collects all CanvasItems, sorts them by Z-index, and sends their draw commands to the GPU for rendering.
//   - batching occurs when multiple draw commands use the same Texture and are in the same CanvasItem.
//     this is why we want to keep all unit frames in a single atlas, and all units in a single CanvasItem per band.
//   - batching is done by the GPU driver, not by Godot. Godot just provides the draw commands in a way that allows batching to happen.
// - pre-combining tiles into a single texture is not necessary for batching, but it can reduce the number of draw commands and
//   improve performance. however, it also increases memory usage and can be more complex to manage. it also breaks batching if the
//   combined texture is not shared with other canvas items, so we'll use atlases for now.
// - C# is not a bottleneck here, because the draw commands are just added to the CanvasItem, and the actual rendering is done by the GPU. 
//   the code only runs once per frame to update the draw commands, which is fast enough for our purposes.
// - C# does have some overhead in calling the VisualServer API, but it is negligible for our use case. the main performance concern is
//   the number of draw commands and the number of textures used, plus the construction of the atlas, sprites positioning and animation.
// - TileMap does not batch its textures, nor offers much flexibility in how it draws tiles, which is why we're doing this.
// For a CanvasItem to be rendered:
//   - it needs to be in the scene tree, have a valid RID, be visible, and be in a visible viewport. therefore, every CanvasItem
//     must be parented to a pre-existing CanvasItem in the scene tree (i.e.: RootCanvasItem, which is set on GDScript side)
//   - CanvasItems are drawn in the order and hierarchy they are added, unless their Z-index is changed.
//   - rendering happens after all scripts have run for the frame. it commences when the engine asks VisualServer to draw, starting
//     from the top-level CanvasItem in each active Viewport, and recursively drawing all the children.
public class MapRenderer_mono : Node
{

    private class MapRendererBand {
        
        private readonly RID _canvasItemRID;
        // public static RID TEST_TEXTURE_RID = GD.Load<Texture>("res://assets/Pharaoh/TILE_SHAPE.png").GetRid();
        public static Texture TEST_TEXTURE = GD.Load<Texture>("res://assets/Pharaoh/TEST_HUT.png");
        // public static TextureDescriptor TEST_TEX_INFO = new TextureDescriptor() {
        //     textureRID = TEST_TEXTURE.GetRid(),
        //     width = 58,
        //     height = 40,
        //     isAtlas = false
        // };

        // ----- tile image data -----
        // private Dictionary<int, (TextureDescriptor, Rect2, Color)> tiles = []; // n-ple dictionary (map) keyed by cell X coord (it's unique)
        private Dictionary<int, (Texture, Rect2, Color)> tiles = []; // n-ple dictionary (map) keyed by cell X coord (it's unique)
        public bool SetTileImage(int cell_x, int draw_y_offset, int img_id, int tile_width, int tile_height) { // TODO
            
            // clear tiles
            if (img_id == -1)
                return tiles.Remove(cell_x);
            
            // TODO: fetch texture info
            // AtlasTextureDescriptor? atlas_sprite = Globals.GraphicsMono.GetSprite(img_id);
            AtlasTexture texture = Globals.GraphicsMono.GetSprite(img_id);
            if (texture == null)
                return false && tiles.Remove(cell_x);
            // TextureInfo tex_info = atlas_sprite.Value;
            // TextureDescriptor tex_info = TEST_TEX_INFO; // <----- temporary
            // Texture texture = (Texture)Globals.Assets.Call("get_gameset_SG_texture", img_id, false); // <--------- this is SLOW AS FUCK.
            // Texture texture = TEST_TEXTURE;
            // if (texture == null)
            //     return tiles.Remove(cell_x);
            // int width = texture.GetWidth();
            // int height = texture.GetHeight();
            int width = (int)texture.Region.Size.x;
            int height = (int)texture.Region.Size.y;
            // AtlasTextureDescriptor texture = atlas_sprite.Value;

            // TODO: calculate y coords
            int x = (cell_x) * tile_width - tile_width / 2;
            int iso_size = (2 + width) / tile_width; // 1x1, 2x2, 3x3 etc. --- NOTE: the image width here **MUST** be exact.
            int iso_height = iso_size * tile_height; // the height of the sprite if it was a flat iso footprint
            int y_runoff = height - iso_height; // the "tall sprite" height bleeding we must account for
            Rect2 draw_rect = new Rect2(x, -y_runoff + draw_y_offset, width, height);
            // Rect2 draw_rect = texture.atlasRect;
            // draw_rect.Position = new Vector2(x, -y_runoff + draw_y_offset);

            // TODO: color mask
            Color color_mask = new Color(1,1,1,1);

            // n-ple dictionary (map)
            if (tiles.ContainsKey(cell_x)) {
                bool same = true;
                if (tiles[cell_x].Item1 != texture)
                    same = false;
                if (tiles[cell_x].Item2 != draw_rect)
                    same = false;
                if (tiles[cell_x].Item3 != color_mask)
                    same = false;
                tiles[cell_x] = (
                    texture,
                    draw_rect,
                    color_mask
                );
                return !same;
            } else {
                tiles[cell_x] = (
                    texture,
                    draw_rect,
                    color_mask
                );
                return true;
            }
        }
        public bool Redraw() {
            VisualServer.CanvasItemClear(_canvasItemRID);
            foreach (int tile_x in tiles.Keys) {
                // (TextureDescriptor tex_info, Rect2 draw_rect, Color mask) = tiles[tile_x];
                (Texture texture, Rect2 draw_rect, Color mask) = tiles[tile_x];
                    // **NOTE: need to EXPLICITLY pass "new RID(null)" to normalMap as null default arguments break RID resolution!**
                    // https://github.com/godotengine/godot/issues/35828#issuecomment-776904332
                    if (texture is AtlasTexture)
                        VisualServer.CanvasItemAddTextureRectRegion(
                            _canvasItemRID, draw_rect, texture.GetRid(), ((AtlasTexture)texture).Region,
                            mask, false, new RID(null), true);
                    else
                        VisualServer.CanvasItemAddTextureRect(
                            _canvasItemRID, draw_rect, texture.GetRid(),
                            false, mask, false, new RID(null));
            }
            return true;
        }

        // constructor and destructor
        public MapRendererBand(RID parent, int index, int tile_width, int tile_height) {
            _canvasItemRID = VisualServer.CanvasItemCreate();
            VisualServer.CanvasItemSetParent(_canvasItemRID, parent);
            VisualServer.CanvasItemSetTransform(_canvasItemRID, new Transform2D(0.0f, new Vector2(-tile_width / 2 * index, tile_height * index / 2)));
            VisualServer.CanvasItemSetZIndex(_canvasItemRID, index);
            VisualServer.CanvasItemSetZAsRelativeToParent(_canvasItemRID, true);
        }
        ~MapRendererBand() {
            Globals.Log.Call("generic", this, "destroying MapRendererBand...");
            if (_canvasItemRID != null)
                VisualServer.FreeRid(_canvasItemRID);
        }
    }

	// Member variables here, example:
	public override void _Ready() {
		GD.Print("*** MONO: MapRenderer_mono loaded: " + this);
	}

	// Log.error(...)
	protected void PrintError(string Message, int Err = 1) {
		Globals.Log.Call("error", this, Err, Message);
	}
	protected void PrintGeneric(string Message) {
		Globals.Log.Call("generic", this, Message);
	}

    // ---------------- Bands ----------------
    private RID root_canvas_RID; // the root canvas item to which all bands/chunks are parented
    private MapRendererBand[] map_bands; // = new MapRendererBand[0];
    private int GRID_SIZE;
    public int TILE_WIDTH;
    public int TILE_HEIGHT;
    public void Init(RID root_RID, int grid_size, Vector2 tile_size) {
        root_canvas_RID = root_RID;
        GRID_SIZE = grid_size;
        TILE_WIDTH = (int)tile_size.x;
        TILE_HEIGHT = (int)tile_size.y;
        int band_count = grid_size * 2 - 1; // the "Diamond" number
        map_bands = new MapRendererBand[band_count];
        for (int i = 0; i < band_count; i++)
            map_bands[i] = new MapRendererBand(root_canvas_RID, i, TILE_WIDTH, TILE_HEIGHT);
        PrintGeneric($"init done -- bands: {band_count}, grid length: {grid_size}");
    }

    // this is done BEFORE rendering, for any tiles that requires visual updates
    private List<int> dirty_bands = new List<int>(); // private int[] _dirtyBands;
    public void SetTileImage(int cell_x, int cell_y, int image_y_offset, int img_id) {
        int band_index = cell_x + cell_y;
        if (band_index >= 0 && band_index < map_bands.Length) {
            map_bands[band_index].SetTileImage(cell_x, image_y_offset, img_id, TILE_WIDTH, TILE_HEIGHT);
            if (!dirty_bands.Contains(band_index))
                dirty_bands.Add(band_index);
        } else
            PrintError($"SetTileImage: band_index {band_index} out of range");
    }

    // this is called REGARDLESS of dirty sectors, by GDScript
    public override void _Process(float delta) {
        for (int i = dirty_bands.Count - 1; i >= 0; i--) {
            bool r = map_bands[dirty_bands[i]].Redraw();
            dirty_bands.RemoveAt(i);
            if (!r)
                return;
        }
    }

    // public int CombinedTexture; // TODO maybe later if performance calls for this
    // public static ImageTexture Combine(Image[] InTextures, int[] YValues) {

    //     int n = InTextures.Length;

    //     // TODO: fill in later
    //     int width = 0, height = 0;

    //     Image combined = new Image();
    //     combined.Create(width, height, false, Image.Format.Rgba8);
    //     combined.Fill(new Color(0, 0, 0, 0));

    //     // for (int k = 0; k < used; k++)
    //     for (int i = 0; i < n; i++)
    //     {
    //         // int idx = (int)(keys[k] & 0xFFFFFFFFL);
    //         Image img = InTextures[i];
    //         if (img == null || img.IsEmpty())
    //             continue;

    //         // BlendRect needs matching formats
    //         // Image converted = null;
    //         // if (img.GetFormat() != Image.Format.Rgba8 || img.IsCompressed())
    //         // {
    //         //     Image _img = (Image)img.Duplicate();
    //         //     if (_img.IsCompressed()) _img.Decompress();
    //         //     _img.Convert(Image.Format.Rgba8);
    //         //     img = _img;
    //         // }

    //         // TODO: fill in later
    //         int x = 0, y = 0;
    //         combined.BlendRect(img, new Rect2(Vector2.Zero, img.GetSize()), new Vector2(x,y));

    //         // if (converted != null) converted.Dispose();
    //     }

    //     // if (reuse != null && reuse.GetWidth() == width && reuse.GetHeight() == height)
    //     // {
    //     //     reuse.SetData(combined);
    //     //     combined.Dispose();
    //     //     return reuse;
    //     // }

    //     ImageTexture tex = new ImageTexture();
    //     // tex.CreateFromImage(combined, filter ? (uint)Texture.FlagsEnum.Filter : 0u);
    //     tex.CreateFromImage(combined);
    //     combined.Dispose();

    //     return tex;
    // }






















}