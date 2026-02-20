using Godot;
using System;
using System.IO; // BinaryReader / BinaryWriter
using System.Reflection; // FieldInfo
using System.Runtime.InteropServices; // Marshal

public class Building : Node
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    partial class BuildingData {
        
    }
	BuildingData data = new BuildingData();

	// constructor
	public short BUILDING_IDX;
	Building(short _IDX)
	{
		BUILDING_IDX = _IDX;
	}
    
	// public I/O
	public bool Fill() // returns true if this building block is in use
	{
		_readFromStream(((Scribe_mono)Globals.ScribeMono).GetReader());
		return in_use();
	}
	public void Dump()
	{
		_writeToStream(((Scribe_mono)Globals.ScribeMono).GetWriter());
	}

	// private I/O
	unsafe void _readFromStream(BinaryReader reader)
	{
		int size = Marshal.SizeOf<BuildingData>();
		byte[] buffer = reader.ReadBytes(size);
		fixed (byte* ptr = buffer)
		{
			Marshal.PtrToStructure((IntPtr)ptr, data);
		}
	}
	unsafe void _writeToStream(BinaryWriter writer)
    {
		int size = Marshal.SizeOf<BuildingData>();
		byte[] buffer = new byte[size];
		
		fixed (byte* ptr = buffer)
		{
			Marshal.StructureToPtr(data, (IntPtr)ptr, false);
		}
		writer.Write(buffer);
    }

	// raw data fields set/get
	public new object get(String fieldName)
	{
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return null;
		return field.GetValue(data);
	}
	public new bool set(String fieldName, object value)
	{
		FieldInfo field = data.GetType().GetField(fieldName);
		if (field == null)
			return false;
		try {
			field.SetValue(data, Convert.ChangeType(value, field.FieldType));
		} catch (Exception e) {
			GD.PrintErr(e.ToString());
			GD.PushError(e.ToString());
			return false;
		}
		return true;
	}

    // =============================== Building =============================== //

	public static Building getBuilding(short building_id)
	{
        if (building_id == 0)
            return null;
		return (Building) ((Godot.Collections.Array)Globals.Buildings.Get("buildings"))[building_id];
	}

    
	public bool in_use()
	{
		return false;
		// return data.state != Enums.FigureStates.NONE;
	}

    // public bool has_figure(byte index, byte figure_id)
    // {
    //     return false;
    // }
    public void remove_figure(short index)
    {
        
    }
}
