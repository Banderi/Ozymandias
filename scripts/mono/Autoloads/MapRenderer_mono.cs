using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class MapRenderer_mono : Node
{
    // private class TileTextureDescriptor {
    //     // public int x;
    //     public int y_offset;
    //     public RID texture_RID;
    //     public TextureInfo tex_info;
    //     public Rect2 draw_rect;
    // }

    private class MapRendererBand {
        
        private readonly RID _canvasItemRID;
        // private readonly RID _parentCanvasItemRID;


        // public static RID TEST_TEXTURE_RID = GD.Load<Texture>("res://icon.png").GetRid();
        // public static RID TEST_TEXTURE_RID = GD.Load<Texture>("res://icon.png").GetRid();
        public static RID TEST_TEXTURE_RID = GD.Load<Texture>("res://assets/Pharaoh/TILE_SHAPE.png").GetRid();
        public static TextureInfo TEST_TEX_INFO = new TextureInfo() {
            // texture = null,
            textureRID = TEST_TEXTURE_RID,
            width = 58,
            height = 30,
            isAtlas = false,
            // atlasRect = new Rect2()
        };

        // ----- tile image data -----
        // public int CombinedTexture; // TODO maybe later if performance calls for this
        // public Texture[] TileTextures; // this is the full array of the textures for the tiles, for now. some of them are null/empty
        // public List<Texture> TileTextures = new List<Texture>(); // this is the full array of the textures for the tiles, for now. some of them are null/empty
        // private Dictionary<int, int> tiles = new Dictionary<int, int>(); // this is the full array of the textures for the tiles, for now. some of them are null/empty
        private Dictionary<int, (TextureInfo, Rect2)> tiles = []; // this is the full array of the textures for the tiles, for now. some of them are null/empty
        // private List<TileTextureDescriptor> tiles = new List<TileTextureDescriptor>(); // this is the full array of the textures for the tiles, for now. some of them are null/empty
        public bool SetTileImage(int cell_x, int image_y_offset, int img_id, int span_width, int span_height) { // TODO
            if (img_id == -1)
                return tiles.Remove(cell_x) && false;
            // TextureInfo? _tex_info = Globals.GraphicsMono.GetSprite(img_id.Value);
            // if (_tex_info == null)
            //     return false && tiles.Remove(cell_x);
            // TextureInfo tex_info = _tex_info.Value;
            // TextureInfo tex_info = new TextureInfo() {
            //     // texture = null,
            //     textureRID = TEST_TEXTURE_RID,
            //     width = 16,
            //     height = 16,
            //     isAtlas = false,
            //     // atlasRect = new Rect2()
            // };
            TextureInfo tex_info = TEST_TEX_INFO;
            int x = (cell_x) * span_width - span_width / 2;
            // int iso_size = tex_info.width / span_width;
            // int y = tex_info.height - (iso_size / 2) * span_width;
            tiles[cell_x] = (tex_info, new Rect2(x, 0, tex_info.width, tex_info.height));
            return true;
        }

        // ----- Figures data -----
        // public void EnlistFigure() { // TODO later

        // }
        // public void RemoveFigure() { // TODO later
            
        // }

        public bool Rebuild(int tile_width, int tile_height) { // TODO
        // try {
            VisualServer.CanvasItemClear(_canvasItemRID);
            foreach (int tile_x in tiles.Keys) {
                // (int image_y_offset, RID tex_RID) = tiles[tile_x];
                (TextureInfo tex_info, Rect2 draw_rect) = tiles[tile_x];
                // TextureInfo? _tex_info = Globals.GraphicsMono.GetSprite(img_idx);
                // if (_tex_info != null) {
                    // TextureInfo tex_info = _tex_info.Value;
                    // int x = tile_x * 16; // TODO
                    // int y = 0; // TODO
                    // Rect2 dst = new Rect2(x, y, tex_info.width, tex_info.height); // TODO

                    // var a = _canvasItemRID.GetId().ToString();
                    // var b = _parentCanvasItemRID.GetId().ToString();
                    // var c = tex_info.textureRID.GetId().ToString();
                    // GD.Print("_canvasItemRID: ", _canvasItemRID == null ? "null" : _canvasItemRID.GetId().ToString());
                    // GD.Print("_parentCanvasItemRID:  ", _parentCanvasItemRID == null ? "null" : _parentCanvasItemRID.GetId().ToString());
                    // GD.Print("tex_info.textureRID:  ", tex_info.textureRID == null ? "null" : tex_info.textureRID.GetId().ToString());
                    // GD.Print($"{tex_info.texture.IsValid()}");
                    // return;

                    // isInstanceValid
                    // RID testItem = VisualServer.CanvasItemCreate();
                    // VisualServer.CanvasItemSetParent(testItem, _parentCanvasItemRID);
                    // RID texture_RID = GD.Load<Texture>("res://icon.png").GetRid();
                    // VisualServer.CanvasItemAddTextureRect(_canvasItemRID, new Rect2(0, 0, 64, 64), testTex);

                    // try {
                    // **NOTE: need to EXPLICITLY pass "new RID(null)" to normalMap as null default arguments break RID resolution!**
                    // https://github.com/godotengine/godot/issues/35828#issuecomment-776904332
                    // VisualServer.CanvasItemAddTextureRectRegion(_canvasItemRID, draw_rect, tex_info.textureRID, tex_info.atlasRect, new Color(1,1,1,1), false, new RID(null), true);
                    // VisualServer.CanvasItemAddTextureRect(_canvasItemRID, draw_rect, tex_info.textureRID, false, new Color(1,1,1,1), false, new RID(null));
                    if (tex_info.isAtlas)
                        VisualServer.CanvasItemAddTextureRectRegion(_canvasItemRID, draw_rect, tex_info.textureRID, tex_info.atlasRect, new Color(1,1,1,1), false, new RID(null), true);
                    else
                        // VisualServer.CanvasItemAddTextureRect(_canvasItemRID, dst, tex_info.textureRID);
                        // VisualServer.CanvasItemAddTextureRect(_canvasItemRID, dst, tex_info.texture.GetRid(), false, new Color(1,1,1,1), false, new RID(null));
                        VisualServer.CanvasItemAddTextureRect(_canvasItemRID, draw_rect, tex_info.textureRID, false, new Color(0.5f,0.5f,0.5f,1), false, new RID(null));
                    // } catch (Exception e) {
                    //     GD.Print($"MapRendererBand.Rebuild: {e}");
                    //     return false;
                    // }

                // }

                
                // RID testTex = GD.Load<Texture>("res://icon.png").GetRid();
                // VisualServer.CanvasItemAddTextureRect(_canvasItemRID, new Rect2(tile_x * 16, tile_x * 16, 64, 64), TEST_TEXTURE_RID, false, new Color(1,1,1,1), false, new RID(null));


                // else
                //     Globals.Log.Call("error", this, 1, $"Rebuild: no texture info for img_idx {img_idx}");
            }
            return true;
        // } catch (Exception e) {
        //     GD.Print($"MapRendererBand.Rebuild: {e}");
        //     return false;
        // }
        }

        // constructor and destructor
        public MapRendererBand(RID parent, int index, int tile_width, int tile_height) {
            // _parentCanvasItemRID = parent;
            _canvasItemRID = VisualServer.CanvasItemCreate();
            // VisualServer.CanvasItemSetParent(_canvasItemRID, _parentCanvasItemRID);
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

    // private int _mapWidth;
    // private int _mapHeight;
    // private int _startingBandIndex; // this changes upon map rotation!
    // public void SetMapBounds(int width, int height) {
    //     _mapWidth = width;
    //     _mapHeight = height;
    //     // TODO later
    //     // _startingBandIndex = startingBandIndex;
    // }

    // this is done BEFORE rendering, for any tiles that requires visual updates
    private List<int> dirty_bands = new List<int>(); // private int[] _dirtyBands;
    public void SetTileImage(int cell_x, int cell_y, int image_y_offset, int img_id) {
        int band_index = cell_x + cell_y;
        // if (dirty_bands.Contains(band_index))
        //     return;
        if (band_index >= 0 && band_index < map_bands.Length) {
            map_bands[band_index].SetTileImage(cell_x, image_y_offset, img_id, TILE_WIDTH, TILE_HEIGHT);
            if (!dirty_bands.Contains(band_index))
                dirty_bands.Add(band_index);
        } else
            PrintError($"SetTileImage: band_index {band_index} out of range");
    }


    // this is called REGARDLESS of dirty sectors, by GDScript
    public override void _Process(float delta) {
        // return;
        // for (int i = 0; i < _dirtyBands.Count; i++)
        for (int i = dirty_bands.Count - 1; i >= 0; i--) {
            bool r = map_bands[dirty_bands[i]].Rebuild(TILE_WIDTH, TILE_HEIGHT);
            dirty_bands.RemoveAt(i);
            if (!r)
                return;
        }
    }






    // pivate

    // public void SupplyTexture(RID texture) {
    //     // TODO later
    // }





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