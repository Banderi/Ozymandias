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
	public Godot.Image ReadPlain(Byte[] input, int img_width, int img_height)
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
		return image;
	}
	public Godot.Image ReadWithCompressedAlpha(Byte[] input, int img_width, int img_height)
	{
		BinaryReader reader = new BinaryReader(new MemoryStream(input));
		Godot.Image image = new Godot.Image();
		image.Create(img_width, img_height, false, Image.Format.Rgba8);
		image.Lock();
		int y = 0;
		int x = 0;
		int data_length = input.Length;
		while (data_length > 0) {
			int control = reader.ReadByte();
			if (control == 255) { // next byte = transparent pixels to skip
				int skip = reader.ReadByte();
				y += skip / img_width;
				x += skip % img_width;
				if (x >= img_width) {
					y++;
					x -= img_width;
				}
				data_length -= 2;
			} else { // control = number of concrete pixels
				for (int i = 0; i < control; i++) {
					ushort _c = reader.ReadUInt16();
					Godot.Color color = color_from_555_u16(_c);
					image.SetPixel(x, y, color);
					x++;
					if (x >= img_width) {
						y++;
						x -= img_width;
					}
				}
				data_length -= control * 2 + 1;
			}
		}
		image.Unlock();
		return image;
	}

	public Godot.Image ReadIsometric(Byte[] input, int img_uncompressed_len, int img_width, int img_height, int img_isometric_tile_size, int tile_height, int tile_width)
	{
		BinaryReader reader = new BinaryReader(new MemoryStream(input));
		Godot.Image image = new Godot.Image();
		image.Create(img_width, img_height, false, Image.Format.Rgba8);
		image.Lock();

		int tile_half_height = tile_height / 2;
		int footprint_height = (img_width + 2) / 2; // height of isometric footprint, without the top
		int footprint_y_start = img_height - footprint_height; // start of the isometric footprint inside the overall sprite

		// determine tile size (num. of map tiles this isometric sprite spans -- in either direction, since it's always a square!)
		int tile_size = img_isometric_tile_size; // value from the SGx records data
		if (tile_size == 0) { // if zero / invalid, determine tile size from the image's own sprite sizes
			if (footprint_height % tile_height == 0)
				tile_size = footprint_height / tile_height;
			else
				return null; // could not determine tile size!
		}

		// isometric footprint data is split by tile (top-to-bottom, left-to-right) and each tile's pixel data is by rows, skipping alpha pixels
		int rows = 2 * tile_size - 1;
		int row_tiles = 1;

		// row by row (vertically, from top to bottom)
		for (int r = 0; r < rows; r++) {
			int tile_x = tile_height * (tile_size - row_tiles);
			int tile_y = tile_half_height * r + footprint_y_start;

			// tile by tile (horizontally, from left to right)
			for (int i = 0; i < row_tiles; i++) {
				int x_start = 28;

				// row by row (individual tile's pixel data)
				for (int y = 0; y < tile_height; y++) {

					// read row of actual pixel data
					int x_max = tile_width - x_start;
					for (int x = x_start; x < x_max; x++) {
						ushort _c = reader.ReadUInt16();
						Godot.Color color = color_from_555_u16(_c);
						image.SetPixel(tile_x + x, tile_y + y, color);
					}

					// stagger x coord of where each subsequent pixel row starts
					if (y < 14)
						x_start -= 2;
					else if (y > 14)
						x_start += 2;
				}
				tile_x += tile_width + 2; // advance to next tile's x coord
			}

			// stagger num. of tiles in each row of tiles in a diamond shape
			if (r < tile_size - 1)
				row_tiles++;
			else
				row_tiles--;
		}

		// read rest of the sprite (isometric top)
		int compressed_data_len = input.Length - img_uncompressed_len;
		if (compressed_data_len > 0) {
			reader.BaseStream.Position = img_uncompressed_len;
			int top_y = 0;
			int top_x = 0;
			while (compressed_data_len > 0) {
				int control = reader.ReadByte();
				if (control == 255) { // next byte = transparent pixels to skip
					int skip = reader.ReadByte();
					top_y += skip / img_width;
					top_x += skip % img_width;
					if (top_x >= img_width) {
						top_y++;
						top_x -= img_width;
					}
					compressed_data_len -= 2;
				} else { // control = number of concrete pixels
					for (int i = 0; i < control; i++) {
						ushort _c = reader.ReadUInt16();
						Godot.Color color = color_from_555_u16(_c);
						image.SetPixel(top_x, top_y, color);
						top_x++;
						if (top_x >= img_width) {
							top_y++;
							top_x -= img_width;
						}
					}
					compressed_data_len -= control * 2 + 1;
				}
			}
		}

		image.Unlock();
		return image;
	}

	public void SetAlphaMask(Godot.Image image, int img_width, byte[] alpha_input)
	{
		BinaryReader reader = new BinaryReader(new MemoryStream(alpha_input));
		image.Lock();

		// int i = 0;
		int x = 0, y = 0, j;
		// int width = img->workRecord->width;
		// int length = img->workRecord->alpha_length;
		int img_alpha_length = alpha_input.Length;
		// while (i < alpha_input.Length) {
		while (img_alpha_length > 0) {
			// uint8_t c = buffer[i++];
			byte c = reader.ReadByte();
			if (c == 255) {
				/* The next byte is the number of pixels to skip */
				// x += buffer[i++];
				x += reader.ReadByte();
				img_alpha_length++;
				while (x >= img_width) {
					y++;
					x -= img_width;
				}
			} else {
				/* `c' is the number of image data bytes */
				// for (j = 0; j < c; j++, i++) {
				for (j = 0; j < c; j++, img_alpha_length--) {
					// setAlphaPixel(img, pixels, x, y, buffer[i]);

					/* Only the first five bits of the alpha channel are used */
					byte color = reader.ReadByte();
					byte alpha = (byte)(((color & 0x1f) << 3) | ((color & 0x1c) >> 2));

					// int p = y * img_width + x;
					// pixels[p] = (pixels[p] & 0x00ffffff) | (alpha << 24);
					Godot.Color pixel = image.GetPixel(x, y);
					pixel.a8 = alpha;
					image.SetPixel(x, y, pixel);

					x++;
					if (x >= img_width) {
						y++;
						x = 0;
					}
				}
			}
		}
	}
}
