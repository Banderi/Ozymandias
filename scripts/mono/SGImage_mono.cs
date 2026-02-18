using Godot;
using System;
using System.IO;

public class SGImage_mono : Node
{
	public override void _Ready()
	{
		GD.Print("*** MONO: SGImageMono loaded: " + this);
	}
	
	const uint COLOR_SG_TRANSPARENT_MAGENTA = 0x781f;
	private static Godot.Color color_from_555_u16(ushort c)
	{
		if ((c & 0x7fff) == COLOR_SG_TRANSPARENT_MAGENTA) // <--- the alpha bit is ignored unlike in RGBA1555. alpha is dictated by a preset magenta color.
			return new Godot.Color(0);
		// if ((c & 0x8000) == 0x8000)
		// 	return new Godot.Color(0);
		Godot.Color color = new Godot.Color( (int)(       //      In the original SGReader code, the middle byte is shifted differently;
			((c & 0x7c00) << 17) | ((c & 0x7000) << 12) | //      instead of mapping bits 8-10 to 9-11 (as would be from following the pattern),
			// ((c & 0x3e0) << 14) | ((c & 0x300) << 8) | // <--- the upper 2 bits 9-10 are brought over unchanged, the lower bit is discarded,
			((c & 0x3e0) << 14) | ((c & 0x380) << 9) |    //      and bit 11 ends up being always zero. this has almost no impact on the image
			((c & 0x1f) << 11) | ((c & 0x1c) << 6) |      //      itself, only an imperceptible shift in color shade.
			0xff ));
		return color;
	}
	public Godot.ImageTexture ReadUncompressed(Byte[] input, int img_width, int img_height)
	{
		BinaryReader reader = new BinaryReader(new MemoryStream(input));
		Godot.Image image = new Godot.Image();
		image.Create(img_width, img_height, false, Image.Format.Rgba8);
		image.Lock();
		for (int y = 0; y < img_height; y++) {
			for (int x = 0; x < img_width; x++) {
				ushort _c = reader.ReadUInt16();
				Godot.Color color = color_from_555_u16(_c);
				image.SetPixel(x, y, color);
			}
		}
		image.Unlock();
		Godot.ImageTexture texture = new Godot.ImageTexture();
		texture.CreateFromImage(image, 0);
		return texture;
	}
	public Byte[] ReadIsometric(Byte[] input)
	{
		Byte[] output = new Byte[1];
		return output;
	}
	public Byte[] ReadCompressed(Byte[] input)
	{
		Byte[] output = new Byte[1];
		return output;
	}
}
