using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

// public struct AtlasTextureDescriptor {
//     // public Texture texture;
//     public RID textureRID;
//     public int width;
//     public int height;
//     public Rect2 atlasRect;
// }

public class Graphics_mono : Node
{
    public override void _Ready() {
        GD.Print("*** MONO: Graphics_mono loaded: " + this);
    }
    
    // private Dictionary<int, AtlasTextureDescriptor> atlas_map = new Dictionary<int, AtlasTextureDescriptor>();
    private Dictionary<int, AtlasTexture> atlas_map = new Dictionary<int, AtlasTexture>();
    public void RecordAtlasSprite(int img_id, ImageTexture texture, Rect2 atlasRect) {
        AtlasTexture atlas_texture = new AtlasTexture();
        atlas_texture.Atlas = texture;
        atlas_texture.Region = atlasRect;
        atlas_map[img_id] = atlas_texture;
        // atlas_map[img_id] = new AtlasTextureDescriptor() {
        //     // texture = texture,
        //     textureRID = texture.GetRid(),
        //     width = (int)atlasRect.Size.x,
        //     height = (int)atlasRect.Size.y,
        //     atlasRect = atlasRect
        // };
    }
    public bool HasSprite(int img_id) {
        return atlas_map.ContainsKey(img_id);
    }
    // public AtlasTextureDescriptor? GetSprite(int img_id) {
    public AtlasTexture GetSprite(int img_id) {
        if (atlas_map.ContainsKey(img_id))
            return atlas_map[img_id];
        else
            return null;
    }
}