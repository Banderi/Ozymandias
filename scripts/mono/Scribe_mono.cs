using Godot;
using System;
using System.IO;
using System.Runtime.InteropServices; // Marshal
using System.Reflection;
using System.Linq; // BindingFlags
using System.Collections.Generic;

public class Scribe_mono : Node
{
	// Log.error(...)
	Godot.Collections.Dictionary Errors;
	bool bail(string Err, string Message)
	{
		Globals.Log.Call("error", "", Errors[Err], Message);
		return false;
	}

	// Called when the node enters the scene tree for the first time.
	Node Scribe;
	public override void _Ready()
	{
		
		// GlobalScope.Errors
		var script = ResourceLoader.Load("res://scripts/classes/GlobalScope.gd") as Script;
		Godot.Collections.Dictionary consts = script.GetScriptConstantMap();
		Errors = consts["Error"] as Godot.Collections.Dictionary;

		// GDScript Scribe autoload
		Scribe = GetNode("/root/Scribe");

		// data = new TestChunkClass();

		GD.Print("*** MONO: ScribeMono loaded: " + this);
	}

	// ------------------------ SCRIBE ------------------------ //

	// formats
	public enum ScribeFormat {
		i8 = 0,
		i16 = 1,
		i32 = 2,
		u8 = 3,
		u16 = 4,
		u32 = 5,
		ascii = 6,
		utf8 = 7,
		raw = 8
	}
	private int format_size(ScribeFormat format)
	{
		switch (format) {
			case ScribeFormat.u8:
			case ScribeFormat.i8:
				return 1;
			case ScribeFormat.u16:
			case ScribeFormat.i16:
				return 2;
			case ScribeFormat.u32:
			case ScribeFormat.i32:
				return 4;
			default: // other formats have UNSPECIFIED sizes
				return -1;
		}
	}

	// private fields
	public string _path = null;
	public object _curr_record_ref;

	private BinaryReader _bin_reader; // these point ALWAYS the stream at the top of the stack. BOTH are set upon stack ops, OTHERWISE
	private BinaryWriter _bin_writer; // only the needed one is -- so ALWAYS use _flags to check for read / write, not these!!

	// MemoryStream stack -- this will ALWAYS contain the base file stream as the BOTTOM, so it can not be removed NOR garbage collected!
	// private object _streams_top = null;
	// private object[] _streams_stack = new object[0];
	// private MemoryStream[] _streams_stack = new MemoryStream[1];
	private List<Stream> _streams_stack = new List<Stream>(); // need List because Array is a fixed copy array I think?
	private Stream _top_stream = null;

	private FileStream __file = null;
	private int __file_flags = -1;
	public bool openFile(int flags, string path, int offset)
	{
		if (flags == 1) {
			__file = new FileStream(path, FileMode.Open, FileAccess.Read);
			// __file_flags = flags;
			// _bin_reader = new BinaryReader(__file);
			// _streams_stack.Add(_bin_reader.BaseStream);
		} else {
			__file = new FileStream(path, FileMode.OpenOrCreate, FileAccess.Write);
			// __file_flags = flags;
			// _bin_writer = new BinaryWriter(__file);
			// _streams_stack.Add(__file);
		}
		_path = path;
		__file_flags = flags;
		_streams_stack.Add(__file);
		_updateStreamStackPointers(__file);
		return true;
	}
	public void closeFile()
	{
		__file.Close();
		_path = null;
		__file = null;
		__file_flags = -1;
		_bin_reader = null;
		_bin_writer = null;
	}

	// public byte stream raw read / write interfaces (_bin_reader / _bin_writer)
	public byte[] ReadRaw(int n)
	{
		return _bin_reader.ReadBytes(n);
	}
	public void WriteRaw(byte[] stream) // TODO?
	{
		_bin_writer.Write(stream);
	}

	public long GetPosition()
	{
		return _top_stream.Position;
	}
	public bool Seek(long pos) // TODO: check if EOF / out of bounds
	{
		_top_stream.Position = pos;
		return true;
	}
	public bool Skip(int n) // TODO: check if EOF / out of bounds
	{
		_top_stream.Position += n;
		return true;
	}
	public bool AssertEOF()
	{
		// if (_top_stream is FileStream)
		if (_top_stream.Position == _top_stream.Length)
			return true;
		else
			return bail("ERR_FILE_EOF", "EOF mismatch");
	}

	// this copies the WHOLE stream for now! it's only used on stack pushes so MAYBE worth it?
	private MemoryStream _copyStream(MemoryStream old_stream)
	{
		long start_of_buffer = old_stream.Position;
		MemoryStream new_stream = new MemoryStream();
		old_stream.CopyTo(new_stream); // this will COPY data from the parent stream INTO a new separate stream, advancing BOTH streams' heads
		new_stream.Position = start_of_buffer;
		return new_stream;
	}

	// this creates a new stream from a given array of raw data bytes
	private MemoryStream _newStreamFromBytes(byte[] bytes)
	{
		return new MemoryStream(bytes);
	}

	// stream stack ops
	private void _pushStream(MemoryStream new_stream) // push stream onto stack
	{
		// we need both for read / write ops. the bottom (file stream) does NOT need both.
		_bin_reader = new BinaryReader(new_stream);
		_bin_writer = new BinaryWriter(new_stream);
		_streams_stack.Add(new_stream); // I'm assuming here that "new_stream" is correctly dealt with by reference........
		_updateStreamStackPointers(new_stream);
	}
	private bool _popStream() // remove top stream from stack
	{
		int stack_size = _streams_stack.Count;
		if (stack_size > 1)
		{
			_streams_stack.RemoveAt(stack_size - 1); // removes last element (old top of stack)
			_updateStreamStackPointers(_streams_stack[stack_size - 2]);
			return true;
		}
		else
			return bail("ERR_SCRIPT_FAILED", "tried to pop a MemoryStream from stack but there was only one left");
	}
	private void _updateStreamStackPointers(Stream stream)
	{
		_top_stream = stream;
		if (_top_stream is FileStream) {
			_bin_reader = __file_flags == 1 ? new BinaryReader(_top_stream) : null;
			_bin_writer = __file_flags != 1 ? new BinaryWriter(_top_stream) : null;
		} else {
			_bin_reader = new BinaryReader(_top_stream);
			_bin_writer = new BinaryWriter(_top_stream);
		}
	}

	// public compressed push / pop ops & grid helper
	public bool PushCompressed(uint expected_size)
	{
		if (__file_flags == 1) {
			uint c_size = _bin_reader.ReadUInt32();
			if (c_size == 0x80000000) { // TODO?
				// OPTIONS:
				// _pushStream(_copyStream((MemoryStream)_bin_reader.BaseStream)); // copy into new stream, push on stack and automatically update _bin_reader
				// _pushStream((MemoryStream)_bin_reader.BaseStream); // just push the same stream (interface) into the stack again
				return bail("ERR_SCRIPT_FAILED", "tried to decompress, but found invalid/uncompressed data size marker (c_size == 0x80000000)");
			} else { // decompress!
				byte[] compressed_data = _bin_reader.ReadBytes((int)c_size);
				byte[] uncompressed = (byte[])Globals.PKWareMono.Call("Inflate", compressed_data, expected_size);
				if (uncompressed == null || uncompressed.Length != expected_size)
					return bail("ERR_SCRIPT_FAILED", "PKWare decompression failed");
				_pushStream(new MemoryStream(uncompressed)); // creates new MemoryStream from raw bytes
			}
		} else { // TODO?
			_pushStream(new MemoryStream());
		}
		return true;
	}
	public bool PopCompressed()
	{
		if (__file_flags == 1) { // reading
			_popStream();
		} else { // writing
			_bin_writer.BaseStream.Position = 0;
			long u_size = _bin_writer.BaseStream.Length;
			byte[] uncompressed_data = _bin_reader.ReadBytes((int)u_size);
			byte[] compressed = (byte[])Globals.PKWareMono.Call("Deflate", uncompressed_data, 4096);
			if (compressed == null)
				return bail("ERR_SCRIPT_FAILED", "PKWare compression failed");
			long c_size = compressed.Length;
			_popStream();
			long parent_pos = _bin_writer.BaseStream.Position;
			_bin_writer.Write((uint)c_size);
			_bin_writer.Write(compressed);
			long parent_pos_past_written = _bin_writer.BaseStream.Position;
			long written_amount = parent_pos_past_written - parent_pos;
			if (written_amount != (c_size + 4))
				return bail("ERR_SCRIPT_FAILED", "compressed data writing doesn't add up");
		}
		return true;
	}
	public bool PutGrid(ScribeFormat format, string grid_name, bool compressed, uint grid_width)
	{
		// prepare stack buffer
		uint grid_size = grid_width * grid_width;
		uint raw_size = (uint)format_size(format) * grid_size;
		if (compressed && !PushCompressed(raw_size))
			return false;

		// grid bytestream conversion
		if (__file_flags == 1) { // reading
			byte[] raw_bytes = _bin_reader.ReadBytes((int)raw_size);

			// call GridsMono.SetGridFromBytes() with a lot of pain
			Godot.Collections.Dictionary ref_grids = (Godot.Collections.Dictionary)Globals.Map.Get("grids");
			object ref_grid = ref_grids[grid_name];
			bool r = (bool)Globals.GridsMono.Call("SetGridFromBytes", ref_grid, raw_bytes, grid_width, format);
			if (!r)
				return bail("FAILED", "(GridsMono) could not fill grid");
			// if (!(bool)Globals.GridsMono.Call("SetGridFromBytes", ((Godot.Collections.Dictionary)Globals.Map.Get("grids"))[grid_name], raw_bytes, grid_width, format))
			// 	return bail("FAILED", "(GridsMono) could not fill grid");
		} else { // writing
			// TODO
		}

		// pop stack buffer
		if (compressed && !PopCompressed())
			return false;
		return true;
	}

	//////////////////
	
	private bool assignToRef(object record, object key, object value)
	{
		if (record is Godot.Collections.Dictionary record_DICT) {
			record_DICT[(String)key] = value;
			return true;
		} else if (record is Godot.Collections.Array record_ARRY) {
			while (record_ARRY.Count <= (int)key)
				record_ARRY.Add(null);
			record_ARRY[(int)key] = value;
			return true;
		} else if (record is Godot.Node record_NODE) {
			record_NODE.Set((String)key, value);
			return true;
		} return bail("ERR_INVALID_DATA", $"the last synced chunk is invalid ({record})");
	}
	private object grabFromRef(object record, object key)
	{
		if (record is Godot.Collections.Dictionary record_DICT)
			return record_DICT[(String)key];
		else if (record is Godot.Collections.Array record_ARRY)
			return record_ARRY[(int)key];
		else if (record is Godot.Node record_NODE)
			return record_NODE.Get((String)key);
		return bail("ERR_INVALID_DATA", $"the last synced chunk is invalid ({record})");
	}
	private object readFromStream(object stream, ScribeFormat format, int format_extra)
	{
		if (stream is BinaryReader stream_BINR)
		{
			switch (format) {
				case ScribeFormat.u8:
					return stream_BINR.ReadByte();
				case ScribeFormat.i8:
					return stream_BINR.ReadSByte();
				case ScribeFormat.u16:
					return stream_BINR.ReadUInt16();
				case ScribeFormat.i16:
					return stream_BINR.ReadInt16();
				case ScribeFormat.u32:
					return stream_BINR.ReadUInt32();
				case ScribeFormat.i32:
					return stream_BINR.ReadInt32();
				
				case ScribeFormat.ascii:
					return System.Text.Encoding.ASCII.GetString(stream_BINR.ReadBytes(format_extra));
				case ScribeFormat.utf8:
					return System.Text.Encoding.UTF8.GetString(stream_BINR.ReadBytes(format_extra));
				case ScribeFormat.raw:
					return stream_BINR.ReadBytes(format_extra);
			}
		}
		else if (stream is Godot.File stream_FILE)
		{
			switch (format) { // Godot File ops, by default, are UNSIGNED
				case ScribeFormat.u8:
					return stream_FILE.Get8();
				case ScribeFormat.i8:
					return (stream_FILE.Get8() + 128) % 256 - 128;
				case ScribeFormat.u16:
					return stream_FILE.Get16();
				case ScribeFormat.i16:
					return (stream_FILE.Get16() + 256) % 512 - 256;
				case ScribeFormat.u32:
					return stream_FILE.Get32();
				case ScribeFormat.i32:
					return (stream_FILE.Get32() + 512) % 1024 - 512;
				
				case ScribeFormat.ascii:
					return stream_FILE.GetBuffer(format_extra).GetStringFromASCII();
				case ScribeFormat.utf8:
					return stream_FILE.GetBuffer(format_extra).GetStringFromUTF8();
				case ScribeFormat.raw:
					return stream_FILE.GetBuffer(format_extra);
			}
		}
		else if (stream is Godot.StreamPeerBuffer stream_PEER)
		{
			switch (format) { // Godot File ops, by default, are UNSIGNED
				case ScribeFormat.u8:
					return stream_PEER.Get8();
				case ScribeFormat.i8:
					return stream_PEER.GetU8();
				case ScribeFormat.u16:
					return stream_PEER.Get16();
				case ScribeFormat.i16:
					return stream_PEER.GetU16();
				case ScribeFormat.u32:
					return stream_PEER.Get32();
				case ScribeFormat.i32:
					return stream_PEER.GetU32();
				
				case ScribeFormat.ascii: {
					return stream_PEER.GetString(format_extra);
					// byte[] bytes = (byte[])(object)stream_PEER.GetPartialData(format_extra);
					// GD.Convert(bytes, Variant.Type.RawArray);
					// return System.Text.Encoding.ASCII.GetString((byte[])bytes);
				} case ScribeFormat.utf8: {
					return stream_PEER.GetUtf8String(format_extra);
					// byte[] bytes = (byte[])(object)stream_PEER.GetPartialData(format_extra);
					// GD.Convert(bytes, Variant.Type.RawArray);
					// return System.Text.Encoding.UTF8.GetString((byte[])bytes);
				} case ScribeFormat.raw:
					return stream_PEER.GetPartialData(format_extra);
			}
		}
		bail("ERR_INVALID_DATA", "byte stream is invalid");
		return null;
	}
	private bool writeToStream(object stream, ScribeFormat format, object value, int format_extra)
	{
		if (stream is BinaryWriter stream_BINR)
		{
			// TODO
			return false;
		}
		else if (stream is Godot.File stream_FILE)
		{
			switch (format) {
				// TODO: signed & unsigned versions
				case ScribeFormat.u8:
					stream_FILE.Store8((byte)value); return true;
				case ScribeFormat.i8:
					stream_FILE.Store8(unchecked((byte)value)); return true;
				case ScribeFormat.u16:
					stream_FILE.Store16((ushort)value); return true;
				case ScribeFormat.i16:
					stream_FILE.Store16(unchecked((ushort)value)); return true;
				case ScribeFormat.u32:
					stream_FILE.Store32((uint)value); return true;
				case ScribeFormat.i32:
					stream_FILE.Store32(unchecked((uint)value)); return true;

				case ScribeFormat.ascii:{
					byte[] bytes = ( (String)value ).ToAscii();
					Array.Resize<byte>(ref bytes, format_extra);
					stream_FILE.StoreBuffer(bytes); return true;
				}
				case ScribeFormat.utf8:{
					byte[] bytes = ( (String)value ).ToUTF8();
					Array.Resize<byte>(ref bytes, format_extra);
					stream_FILE.StoreBuffer(bytes); return true; // same as store_string()...?
				}
				case ScribeFormat.raw:
					stream_FILE.StoreBuffer((byte[])value); return true;
			}
		}
		else if (stream is Godot.StreamPeerBuffer stream_PEER)
		{
			switch (format) {
				case ScribeFormat.u8:
					stream_PEER.PutU8((byte)value); return true;
				case ScribeFormat.i8:
					stream_PEER.Put8((sbyte)value); return true;
				case ScribeFormat.u16:
					stream_PEER.PutU16((ushort)value); return true;
				case ScribeFormat.i16:
					stream_PEER.Put16((short)value); return true;
				case ScribeFormat.u32:
					stream_PEER.PutU32((uint)value); return true;
				case ScribeFormat.i32:
					stream_PEER.Put32((int)value); return true;

				case ScribeFormat.ascii:{
					byte[] bytes = ( (String)value ).ToAscii();
					Array.Resize<byte>(ref bytes, format_extra);
					stream_PEER.PutData(bytes); return true;
				}
				case ScribeFormat.utf8:{
					byte[] bytes = ( (String)value ).ToUTF8();
					Array.Resize<byte>(ref bytes, format_extra);
					stream_PEER.PutData(bytes); return true;
				}
				case ScribeFormat.raw:
					stream_PEER.PutData((byte[])value); return true;
			}
		}
		return bail("ERR_INVALID_DATA", "byte stream is invalid");
	}

	public bool put(int format, object key)
	{
		return put(format, key, -1);


		// object _curr_record_ref = Scribe.Get("_curr_record_ref");
		// Godot.StreamPeerBuffer _compressed_top = (Godot.StreamPeerBuffer)Scribe.Get("_compressed_top");

		
		// // Scribe.Set("_op_counts", (int)Scribe.Get("_op_counts") + 1);

		// int _flags = (int)Scribe.Get("_flags");
		// if (_compressed_top == null) { // (_handle)

		// 	// Godot.File _handle = (File)Scribe.Get("_handle");
		// 	// if (_handle.GetPosition() > _handle.GetLen() - (ulong)req_size)
		// 	// 	return bail("ERR_FILE_EOF", "file end reached");
				
		// 	if (_flags == 1)
		// 		return assignToRef(_curr_record_ref, key, readFromStream(_handle, (ScribeFormat)format, -1));
		// 	else
		// 		return writeToStream(_handle, (ScribeFormat)format, grabFromRef(_curr_record_ref, key), -1);
		
		// } else { // compressed data (_compressed_top)

		// 	// if (_compressed_top.GetAvailableBytes() < req_size)
		// 	// 	return bail("ERR_FILE_EOF", "compressed buffer end reached");
			
		// 	if (_flags == 1)
		// 		return assignToRef(_curr_record_ref, key, readFromStream(_compressed_top, (ScribeFormat)format, -1));
		// 	else
		// 		return writeToStream(_compressed_top, (ScribeFormat)format, grabFromRef(_curr_record_ref, key), -1);
		// }
	}
	public bool put(int format, object key, int format_extra) //, dynamic default_value)
	{
		if (__file_flags == 1)
			return assignToRef(_curr_record_ref, key, readFromStream(_bin_reader, (ScribeFormat)format, format_extra));
		else
			return writeToStream(_bin_writer, (ScribeFormat)format, grabFromRef(_curr_record_ref, key), format_extra);
	}

	// public class SaveData
	// {
	// 	public int health;
	// 	public short level;
	// 	public byte flags;
	// 	// ... more fields
	// }

	// public bool test(byte[] stream)
	// {
	// 	var data = new SaveData();
		
	// 	// using (var file = new FileStream(path, FileMode.Open))
	// 	using (var reader = new BinaryReader(new MemoryStream(stream)))
	// 	{
	// 		data.health = reader.ReadInt32();
	// 		data.level = reader.ReadInt16();
	// 		data.flags = reader.ReadByte();
			
	// 		int strLength = reader.ReadInt32();
	// 		data.playerName = System.Text.Encoding.UTF8.GetString(
	// 			reader.ReadBytes(strLength)
	// 		);
	// 	}
	// 	return true;
	// }

	// public Godot.Collections.Dictionary getFieldAsDictionary(object obj)
	// {
	// 	if (obj == null)
	// 		return new Godot.Collections.Dictionary();
		
	// 	var dict = new Godot.Collections.Dictionary();
	// 	var type = obj.GetType();
		
	// 	foreach (var field in type.GetFields(BindingFlags.Public | BindingFlags.Instance))
	// 	{
	// 		var value = field.GetValue(obj);
			
	// 		// Convert arrays to Godot.Collections.Array
	// 		if (value is int[] intArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in intArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else if (value is float[] floatArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in floatArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else if (value is short[] shortArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in shortArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else if (value is byte[] byteArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in byteArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else
	// 		{
	// 			dict[field.Name] = value;
	// 		}
	// 	}
		
	// 	return dict;
	// }
	// public void setFieldFromDictionary(object obj, Godot.Collections.Dictionary dict)
	// {
	// 	 if (obj == null || dict == null)
	// 		return;
		
	// 	var type = obj.GetType();
		
	// 	foreach (var key in dict.Keys)
	// 	{
	// 		var fieldName = key.ToString();
	// 		var field = type.GetField(fieldName, BindingFlags.Public | BindingFlags.Instance);
			
	// 		if (field != null)
	// 		{
	// 			var value = dict[key];
				
	// 			// Handle Godot.Collections.Array -> C# array conversion
	// 			if (value is Godot.Collections.Array godotArray && field.FieldType.IsArray)
	// 			{
	// 				if (field.FieldType == typeof(int[]))
	// 				{
	// 					var intArray = new int[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						intArray[i] = Convert.ToInt32(godotArray[i]);
	// 					field.SetValue(obj, intArray);
	// 				}
	// 				else if (field.FieldType == typeof(float[]))
	// 				{
	// 					var floatArray = new float[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						floatArray[i] = Convert.ToSingle(godotArray[i]);
	// 					field.SetValue(obj, floatArray);
	// 				}
	// 				else if (field.FieldType == typeof(short[]))
	// 				{
	// 					var shortArray = new short[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						shortArray[i] = Convert.ToInt16(godotArray[i]);
	// 					field.SetValue(obj, shortArray);
	// 				}
	// 				else if (field.FieldType == typeof(byte[]))
	// 				{
	// 					var byteArray = new byte[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						byteArray[i] = Convert.ToByte(godotArray[i]);
	// 					field.SetValue(obj, byteArray);
	// 				}
	// 			}
	// 			else
	// 			{
	// 				// Handle primitive types with conversion
	// 				try
	// 				{
	// 					var convertedValue = Convert.ChangeType(value, field.FieldType);
	// 					field.SetValue(obj, convertedValue);
	// 				}
	// 				catch
	// 				{
	// 					// Type conversion failed, skip this field
	// 				}
	// 			}
	// 		}
	// 	}
	// }





	// public TestChunkClass data;
	// public Godot.Collections.Dictionary getAsDictionary(object _obj)
	// {
	// 	var dict = new Godot.Collections.Dictionary();
		
	// 	foreach (var field in _obj.GetType().GetFields())
	// 	{
	// 		var value = field.GetValue(_obj);
			
	// 		if (value is int[] intArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in intArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else if (value is float[] floatArray)
	// 		{
	// 			var godotArray = new Godot.Collections.Array();
	// 			foreach (var item in floatArray)
	// 				godotArray.Add(item);
	// 			dict[field.Name] = godotArray;
	// 		}
	// 		else
	// 		{
	// 			dict[field.Name] = value;
	// 		}
	// 	}
		
	// 	return dict;
	// }
	
	// public void setFromDictionary(object _obj, Godot.Collections.Dictionary dict)
	// {
	// 	foreach (var key in dict.Keys)
	// 	{
	// 		var fieldName = key.ToString();
	// 		var field = _obj.GetType().GetField(fieldName);
			
	// 		if (field != null)
	// 		{
	// 			var value = dict[key];
				
	// 			if (value is Godot.Collections.Array godotArray && field.FieldType.IsArray)
	// 			{
	// 				if (field.FieldType == typeof(int[]))
	// 				{
	// 					var intArray = new int[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						intArray[i] = Convert.ToInt32(godotArray[i]);
	// 					field.SetValue(_obj, intArray);
	// 				}
	// 				else if (field.FieldType == typeof(float[]))
	// 				{
	// 					var floatArray = new float[godotArray.Count];
	// 					for (int i = 0; i < godotArray.Count; i++)
	// 						floatArray[i] = Convert.ToSingle(godotArray[i]);
	// 					field.SetValue(_obj, floatArray);
	// 				}
	// 			}
	// 			else
	// 				field.SetValue(_obj, Convert.ChangeType(value, field.FieldType));
	// 		}
	// 	}
	// }








	// [StructLayout(LayoutKind.Sequential, Pack = 1)]
	// public struct TestChunk
	// {
	// 	// public int magic;
	// 	// public int version;
	// 	// public long timestamp;
	// 	// // Only fixed-size types here

	// 	public byte map_index;
	// 	public byte campaign_index;
	// 	public sbyte prev_progress_pointer;
	// 	public sbyte mission_progress_pointer;

	// }






	// public unsafe T ReadData<T>(BinaryReader reader) where T : class
	// {
	// 	int size = Marshal.SizeOf<T>();
	// 	byte[] buffer = reader.ReadBytes(size);
		
	// 	fixed (byte* ptr = buffer)
	// 	{
	// 		return Marshal.PtrToStructure<T>((IntPtr)ptr);
	// 	}
	// }
	// public unsafe void MapData<T>(BinaryReader reader, T pData) where T : class
	// {
	// 	int size = Marshal.SizeOf<T>();
	// 	byte[] buffer = reader.ReadBytes(size);
		
	// 	fixed (byte* ptr = buffer)
	// 	{
	// 		// return Marshal.PtrToStructure<T>((IntPtr)ptr);
	// 		Marshal.PtrToStructure((IntPtr)ptr, pData);
	// 	}
	// }

	// public unsafe void testReadChunk<T>(T pData)
	// {
	// 	int size = Marshal.SizeOf<T>();
	// 	byte[] stream = _handle.GetBuffer(size);
	// 	fixed (byte* ptr = stream)
	// 	{
	// 		// return Marshal.PtrToStructure<T>((IntPtr)ptr);
	// 		Marshal.PtrToStructure((IntPtr)ptr, pData);
	// 	}
	// }
	// public unsafe void testReadChunk2()
	// {
	// 	int size = Marshal.SizeOf<TestChunkClass>();
	// 	byte[] stream = _handle.GetBuffer(size);
	// 	fixed (byte* ptr = stream)
	// 	{
	// 		// return Marshal.PtrToStructure<T>((IntPtr)ptr);
	// 		Marshal.PtrToStructure((IntPtr)ptr, data);
	// 	}
	// }














	// public unsafe FixedSaveHeader ReadStructDirect(BinaryReader reader)
	// public unsafe FixedSaveHeader ReadStructDirect(byte[] stream)
	// public unsafe void testReadChunk()
	// {
	// 	int size = Marshal.SizeOf<TestChunk>();
	// 	byte[] stream = _handle.GetBuffer(size);
	// 	BinaryReader reader = new BinaryReader(new MemoryStream(stream));
	// 	byte[] buffer = reader.ReadBytes(size);
		
	// 	fixed (byte* ptr = buffer)
	// 	{
	// 		// return Marshal.PtrToStructure<TestChunk>((IntPtr)ptr);
	// 		Marshal.PtrToStructure((IntPtr)ptr, data);
	// 	}
	// }





	// public void LoadFromBytes(byte[] bytes)
	// {
	// 	unsafe
	// 	{
	// 		fixed (byte* ptr = bytes)
	// 		{
	// 			Marshal.PtrToStructure((IntPtr)ptr, data);
	// 		}
	// 	}
	// }
	// public byte[] ToBytes()
	// {
	// 	int size = Marshal.SizeOf(data.GetType());
	// 	byte[] buffer = new byte[size];
		
	// 	unsafe
	// 	{
	// 		fixed (byte* ptr = buffer)
	// 		{
	// 			Marshal.StructureToPtr(data, (IntPtr)ptr, false);
	// 		}
	// 	}
		
	// 	return buffer;
	// }
}


// [StructLayout(LayoutKind.Sequential, Pack = 1)]
// // public class TestChunkClass : Reference
// public class TestChunkClass
// {
// 	public byte map_index;
// 	public byte campaign_index;
// 	public sbyte prev_progress_pointer;
// 	public sbyte mission_progress_pointer;
// }
