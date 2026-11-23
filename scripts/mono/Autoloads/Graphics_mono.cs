using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Graphics_mono : Node
{
    public override void _Ready() {
        GD.Print("*** MONO: Graphics_mono loaded: " + this);
    }
    
    private Dictionary<int, AtlasTexture> atlas_map = new Dictionary<int, AtlasTexture>();
    public void RecordAtlasSprite(int img_id, ImageTexture texture, Rect2 atlasRect) {
        AtlasTexture atlas_texture = new AtlasTexture();
        atlas_texture.Atlas = texture;
        atlas_texture.Region = atlasRect;
        atlas_map[img_id] = atlas_texture;
    }
    public bool HasSprite(int img_id) {
        return atlas_map.ContainsKey(img_id);
    }
    public AtlasTexture GetSprite(int img_id) {
        if (atlas_map.ContainsKey(img_id))
            return atlas_map[img_id];
        else
            return null;
    }
}