using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public struct TextureInfo {
    public Texture texture;
    public RID textureRID;
    public int width;
    public int height;
    public bool isAtlas;
    public Rect2 atlasRect;
}

public class Graphics_mono : Node // TODO: move to separate file
{
    public override void _Ready() {
        GD.Print("*** MONO: Graphics_mono loaded: " + this);
    }


    
    private Dictionary<int, TextureInfo> textureMap = new Dictionary<int, TextureInfo>();
    public void RecordSprite(int img_id, Texture texture, int width, int height, bool isAtlas, Rect2 atlasRect) {
        // texture.
        textureMap[img_id] = new TextureInfo() { texture = texture, textureRID = texture.GetRid(), width = width, height = height, isAtlas = isAtlas, atlasRect = atlasRect };
    }
    public bool HasSprite(int img_id) {
        return textureMap.ContainsKey(img_id);
    }
    public TextureInfo? GetSprite(int img_id) {
        if (textureMap.ContainsKey(img_id))
            return textureMap[img_id];
        else
            return null;
    }
}