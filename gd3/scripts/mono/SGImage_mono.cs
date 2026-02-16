using Godot;
using System;

public class SGImage_mono : Node
{
	public override void _Ready()
	{
		GD.Print("*** MONO: SGImageMono loaded: " + this);
	}
	
	public Byte[] readPlain(Byte[] input)
	{
		Byte[] output = new Byte[1];
		return output;
	}
	public Byte[] readIsometric(Byte[] input)
	{
		Byte[] output = new Byte[1];
		return output;
	}
	public Byte[] readSprite(Byte[] input)
	{
		Byte[] output = new Byte[1];
		return output;
	}
}
