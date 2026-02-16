using Godot;
using System;

public class Scribe_mono : Node
{
	// GDScript Scribe autoload
	Node Scribe;
	Node Log;
	Godot.Collections.Dictionary Errors;
	bool bail(string Err, string Message)
	{
		Log.Call("error", "", Errors[Err], Message);
		return false;
	}

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GD.Print("ScribeMono loaded: " + this);
		
		// Log.error(...)
		Log = GetNode("/root/Log");
		var script = ResourceLoader.Load("res://scripts/classes/GlobalScope.gd") as Script;
		Godot.Collections.Dictionary consts = script.GetScriptConstantMap();
		Errors = consts["Error"] as Godot.Collections.Dictionary;

		// GDScript Scribe autoload
		Scribe = GetNode("/root/Scribe");
	}

	// ------------------------ SCRIBE ------------------------ //

	enum ScribeFormat {
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
		if (stream is Godot.File stream_FILE)
		{
			switch (format) { // Godot File ops, by default, are UNSIGNED
				case ScribeFormat.i8:
					return (stream_FILE.Get8() + 128) % 256 - 128;
				case ScribeFormat.u8:
					return stream_FILE.Get8();
				case ScribeFormat.i16:
					return (stream_FILE.Get16() + 256) % 512 - 256;
				case ScribeFormat.u16:
					return stream_FILE.Get16();
				case ScribeFormat.i32:
					return (stream_FILE.Get32() + 512) % 1024 - 512;
				case ScribeFormat.u32:
					return stream_FILE.Get32();
				
				// BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
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
				case ScribeFormat.i8:
					return stream_PEER.GetU8();
				case ScribeFormat.u8:
					return stream_PEER.Get8();
				case ScribeFormat.i16:
					return stream_PEER.GetU16();
				case ScribeFormat.u16:
					return stream_PEER.Get16();
				case ScribeFormat.i32:
					return stream_PEER.GetU32();
				case ScribeFormat.u32:
					return stream_PEER.Get32();
				
				// BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
				case ScribeFormat.ascii: {
					byte[] bytes = (byte[])(object)stream_PEER.GetPartialData(format_extra);
					GD.Convert(bytes, Variant.Type.RawArray);
					return System.Text.Encoding.ASCII.GetString((byte[])bytes);
				} case ScribeFormat.utf8: {
					byte[] bytes = (byte[])(object)stream_PEER.GetPartialData(format_extra);
					GD.Convert(bytes, Variant.Type.RawArray);
					return System.Text.Encoding.UTF8.GetString((byte[])bytes);
				} case ScribeFormat.raw:
					return stream_PEER.GetPartialData(format_extra);
			}
		}
		bail("ERR_INVALID_DATA", "byte stream is invalid");
		return null;
	}
	private bool writeToStream(object stream, ScribeFormat format, object value, int format_extra)
	{
		if (stream is Godot.File stream_FILE)
		{
			switch (format) {
				// TODO: signed & unsigned versions
				case ScribeFormat.i8:
					stream_FILE.Store8(unchecked((byte)value)); return true;
				case ScribeFormat.u8:
					stream_FILE.Store8((byte)value); return true;
				case ScribeFormat.i16:
					stream_FILE.Store16(unchecked((ushort)value)); return true;
				case ScribeFormat.u16:
					stream_FILE.Store16((ushort)value); return true;
				case ScribeFormat.i32:
					stream_FILE.Store32(unchecked((uint)value)); return true;
				case ScribeFormat.u32:
					stream_FILE.Store32((uint)value); return true;

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
				case ScribeFormat.i8:
					stream_PEER.Put8((sbyte)value); return true;
				case ScribeFormat.u8:
					stream_PEER.PutU8((byte)value); return true;
				case ScribeFormat.i16:
					stream_PEER.Put16((short)value); return true;
				case ScribeFormat.u16:
					stream_PEER.PutU16((ushort)value); return true;
				case ScribeFormat.i32:
					stream_PEER.Put32((int)value); return true;
				case ScribeFormat.u32:
					stream_PEER.PutU32((uint)value); return true;

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
	}

	// Called when the node enters the scene tree for the first time.
	public bool put(int format, object key, int format_extra) //, dynamic default_value)
	{
		// object _curr_record_ref = Scribe.Get("_curr_record_ref");
		// if (_curr_record_ref == null ||
		// 	!(_curr_record_ref is Godot.Collections.Dictionary || _curr_record_ref is Godot.Collections.Array || _curr_record_ref is Godot.Object))
		// 	return bail("ERR_INVALID_DATA", $"the last synced chunk is invalid ({_curr_record_ref})");
		// if (_curr_record_ref is Godot.Collections.Dictionary _ref_DICT) {
		// 	if (!(key is String))
		// 		return bail("ERR_INVALID_PARAMETER", "the parent chunk (Dictionary) requires a key of type String");
		// 	if (!_ref_DICT.Contains(key))
		// 		_ref_DICT[key] = default_value;
		// } else if (_curr_record_ref is Node _ref_NODE) {
		// 	// if (!(key is String))
		// 	// 	return bail("ERR_INVALID_PARAMETER", "the parent chunk (Node) requires a key of type String");
		// 	// try
		// 	// {
				
		// 	// } catch (RuntimeBinderException)
		// 	// {
				
		// 	// }
		// 	// if (!_ref_NODE.Proper(key))
		// 	// 	return bail("ERR_INVALID_PARAMETER", "the parent chunk (Node) can not introduce new member elements");
		// } else if (_curr_record_ref is Godot.Collections.Array _ref_ARRY) {
		// 	if (!(key is int))
		// 		return bail("ERR_INVALID_PARAMETER", "the parent chunk (Array) requires a key of type Int");
		// 	if (_ref_ARRY.Count <= key)
		// 		_ref_ARRY.Add(default_value);
		// }
		int req_size = format_size((ScribeFormat)format);
		if (req_size == -1)
			req_size = format_extra;
		if (req_size == -1)
			return bail("ERR_INVALID_PARAMETER", "cannot determine requested format size");
		
		object _curr_record_ref = Scribe.Get("_curr_record_ref");
		Godot.StreamPeerBuffer _compressed_top = (Godot.StreamPeerBuffer)Scribe.Get("_compressed_top");

		
		Scribe.Set("_op_counts", (int)Scribe.Get("_op_counts") + 1);

		int _flags = (int)Scribe.Get("_flags");
		if (_compressed_top == null) { // uncompressed data

			Godot.File _handle = (File)Scribe.Get("_handle");
			if (_handle.GetPosition() > _handle.GetLen() - (ulong)req_size)
				return bail("ERR_FILE_EOF", "file end reached");
				
			if (_flags == 1) {
				return assignToRef(_curr_record_ref, key, readFromStream(_handle, (ScribeFormat)format, format_extra));
				// switch ((ScribeFormat)format) { // Godot File ops, by default, are UNSIGNED
				// 	case ScribeFormat.i8:
				// 		return assignToRef(_curr_record_ref, key, (_handle.Get8() + 128) % 256 - 128);
				// 	case ScribeFormat.u8:
				// 		return assignToRef(_curr_record_ref, key, _handle.Get8());
				// 	case ScribeFormat.i16:
				// 		return assignToRef(_curr_record_ref, key, (_handle.Get16() + 256) % 512 - 256);
				// 	case ScribeFormat.u16:
				// 		return assignToRef(_curr_record_ref, key, _handle.Get16());
				// 	case ScribeFormat.i32:
				// 		return assignToRef(_curr_record_ref, key, (_handle.Get32() + 512) % 1024 - 512);
				// 	case ScribeFormat.u32:
				// 		return assignToRef(_curr_record_ref, key, _handle.Get32());
					
				// 	// BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
				// 	case ScribeFormat.ascii:
				// 		return assignToRef(_curr_record_ref, key, _handle.GetBuffer(format_extra).GetStringFromASCII());
				// 	case ScribeFormat.utf8:
				// 		return assignToRef(_curr_record_ref, key, _handle.GetBuffer(format_extra).GetStringFromUTF8());
				// 	case ScribeFormat.raw:
				// 		return assignToRef(_curr_record_ref, key, _handle.GetBuffer(format_extra));
				// }
			} else {
				// if (!assignToRef(_curr_record_ref, key, readFromStream(_handle, (ScribeFormat)format, format_extra)))
				return writeToStream(_handle, (ScribeFormat)format, grabFromRef(_curr_record_ref, key), format_extra);
				// switch ((ScribeFormat)format) {
				// 	// these do not have an unsigned version (TODO?)
				// 	case ScribeFormat.i8:
				// 	case ScribeFormat.u8:
				// 		_handle.Store8((byte)grabFromRef(_curr_record_ref, key));
				// 		break;
				// 	case ScribeFormat.i16:
				// 	case ScribeFormat.u16:
				// 		_handle.Store16((ushort)grabFromRef(_curr_record_ref, key));
				// 		break;
				// 	case ScribeFormat.i32:
				// 	case ScribeFormat.u32:
				// 		_handle.Store32((uint)grabFromRef(_curr_record_ref, key));
				// 		break;

				// 	case ScribeFormat.ascii:{
				// 		byte[] bytes = ( (String)grabFromRef(_curr_record_ref, key) ).ToAscii();
				// 		Array.Resize<byte>(ref bytes, format_extra);
				// 		_handle.StoreBuffer(bytes);
				// 		break;
				// 	}
				// 	case ScribeFormat.utf8:{
				// 		byte[] bytes = ( (String)grabFromRef(_curr_record_ref, key) ).ToUTF8();
				// 		Array.Resize<byte>(ref bytes, format_extra);
				// 		_handle.StoreBuffer(bytes);
				// 		break; // same as store_string()...?
				// 	}
				// 	case ScribeFormat.raw:
				// 		_handle.StoreBuffer((byte[])grabFromRef(_curr_record_ref, key));
				// 		break;
				// }
			}
		} else { // compressed buffer I/O
	//		print("[Scribe]: tried to '%s' for '%s' bytes (%s)" % [_flags, format_size(format), format])
			if (_compressed_top.GetAvailableBytes() < req_size)
				return bail("ERR_FILE_EOF", "compressed buffer end reached");
			
			if (_flags == 1) {
				return assignToRef(_curr_record_ref, key, readFromStream(_compressed_top, (ScribeFormat)format, format_extra));
				// switch ((ScribeFormat)format) { // Godot File ops, by default, are UNSIGNED
				// 	case ScribeFormat.i8:
				// 		return assignToRef(_curr_record_ref, key, (_compressed_top.Get8() + 128) % 256 - 128);
				// 	case ScribeFormat.u8:
				// 		return assignToRef(_curr_record_ref, key, _compressed_top.Get8());
				// 	case ScribeFormat.i16:
				// 		return assignToRef(_curr_record_ref, key, (_compressed_top.Get16() + 256) % 512 - 256);
				// 	case ScribeFormat.u16:
				// 		return assignToRef(_curr_record_ref, key, _compressed_top.Get16());
				// 	case ScribeFormat.i32:
				// 		return assignToRef(_curr_record_ref, key, (_compressed_top.Get32() + 512) % 1024 - 512);
				// 	case ScribeFormat.u32:
				// 		return assignToRef(_curr_record_ref, key, _compressed_top.Get32());
					
				// 	// BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
				// 	case ScribeFormat.ascii: {
				// 		dynamic bytes = _compressed_top.GetPartialData(format_extra);
				// 		GD.Convert(bytes, Variant.Type.RawArray);
				// 		return assignToRef(_curr_record_ref, key, System.Text.Encoding.ASCII.GetString((byte[])bytes));
				// 	} case ScribeFormat.utf8: {
				// 		dynamic bytes = _compressed_top.GetPartialData(format_extra);
				// 		GD.Convert(bytes, Variant.Type.RawArray);
				// 		return assignToRef(_curr_record_ref, key, System.Text.Encoding.UTF8.GetString((byte[])bytes));
				// 	} case ScribeFormat.raw:
				// 		return assignToRef(_curr_record_ref, key, _compressed_top.GetPartialData(format_extra));
				// }
			} else {
				return writeToStream(_compressed_top, (ScribeFormat)format, grabFromRef(_curr_record_ref, key), format_extra);
				// switch ((ScribeFormat)format) {
				// 	// these do not have an unsigned version (TODO?)
				// 	case ScribeFormat.i8:
				// 		_compressed_top.Put8((sbyte)grabFromRef(_curr_record_ref, key));
				// 		break;
				// 	case ScribeFormat.u8:
				// 		_compressed_top.PutU8((byte)grabFromRef(_curr_record_ref, key));
				// 		break;
				// 	case ScribeFormat.i16:
				// 	case ScribeFormat.u16:
				// 		_compressed_top.Put16((short)grabFromRef(_curr_record_ref, key));
				// 		break;
				// 	case ScribeFormat.i32:
				// 	case ScribeFormat.u32:
				// 		_compressed_top.Put32(grabFromRef(_curr_record_ref, key));
				// 		break;

				// 	case ScribeFormat.ascii:{
				// 		byte[] bytes = ( (String)grabFromRef(_curr_record_ref, key) ).ToAscii();
				// 		Array.Resize<byte>(ref bytes, format_extra);
				// 		_compressed_top.PutData(bytes);
				// 		break;
				// 	}
				// 	case ScribeFormat.utf8:{
				// 		byte[] bytes = ( (String)grabFromRef(_curr_record_ref, key) ).ToUTF8();
				// 		Array.Resize<byte>(ref bytes, format_extra);
				// 		_compressed_top.PutData(bytes);
				// 		break; // same as store_string()...?
				// 	}
				// 	case ScribeFormat.raw:
				// 		_compressed_top.PutData(grabFromRef(_curr_record_ref, key));
				// 		break;
				// }
			}

			// if (_flags == 1) {
			// 	switch (format) { // Godot File ops, by default, are UNSIGNED
			// 		case ScribeFormat.i8:
			// 			return assignToRef(_curr_record_ref, key, (_compressed_top.Get8() + 128) % 256 - 128);
			// 		case ScribeFormat.u8:
			// 			return assignToRef(_curr_record_ref, key, _compressed_top.Get8());
			// 		case ScribeFormat.i16:
			// 			return assignToRef(_curr_record_ref, key, (_compressed_top.Get16() + 256) % 512 - 256);
			// 		case ScribeFormat.u16:
			// 			return assignToRef(_curr_record_ref, key, _compressed_top.Get16());
			// 		case ScribeFormat.i32:
			// 			return assignToRef(_curr_record_ref, key, (_compressed_top.Get32() + 512) % 1024 - 512);
			// 		case ScribeFormat.u32:
			// 			return assignToRef(_curr_record_ref, key, _compressed_top.Get32());
					
			// 		// BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
			// 		case ScribeFormat.ascii: {
			// 			// _curr_record_ref[key] = (byte[])(_compressed_top.GetPartialData(format_extra)).get_string_from_ascii();
			// 			// byte[] bytes = _compressed_top.GetPartialData(format_extra).ToString();
			// 			// _curr_record_ref[key] = System.Text.Encoding.ASCII.GetString(_compressed_top.GetPartialData(format_extra));
			// 			dynamic bytes = _compressed_top.GetPartialData(format_extra);
			// 			GD.Convert(bytes, Variant.Type.RawArray);
			// 			return assignToRef(_curr_record_ref, key, System.Text.Encoding.ASCII.GetString((byte[])bytes));
			// 		} case ScribeFormat.utf8: {
			// 			// return assignToRef(_curr_record_ref, key, PoolByteArray(_compressed_top.GetPartialData(format_extra)).get_string_from_utf8();
			// 			dynamic bytes = _compressed_top.GetPartialData(format_extra);
			// 			GD.Convert(bytes, Variant.Type.RawArray);
			// 			return assignToRef(_curr_record_ref, key, System.Text.Encoding.UTF8.GetString((byte[])bytes));
			// 		} case ScribeFormat.raw:
			// 			return assignToRef(_curr_record_ref, key, _compressed_top.GetPartialData(format_extra));
			// 	}
			// } else {
			// 	switch (format) {
			// 		// these do not have an unsigned version (TODO?)
			// 		case ScribeFormat.i8:
			// 		case ScribeFormat.u8:
			// 			_compressed_top.Put8(_curr_record_ref[key]);
			// 			break;
			// 		case ScribeFormat.i16:
			// 		case ScribeFormat.u16:
			// 			_compressed_top.Put16(_curr_record_ref[key]);
			// 			break;
			// 		case ScribeFormat.i32:
			// 		case ScribeFormat.u32:
			// 			_compressed_top.Put32(_curr_record_ref[key]);
			// 			break;

			// 		// case ScribeFormat.ascii:
			// 		// 	_compressed_top.put_data(buffer_padded(_curr_record_ref[key].to_ascii(), format_extra))
			// 		// case ScribeFormat.utf8:
			// 		// 	_compressed_top.put_data(buffer_padded(_curr_record_ref[key].to_utf8(), format_extra)) // same as store_string()...?
			// 		// case ScribeFormat.raw:
			// 		// 	_compressed_top.put_data(_curr_record_ref[key])
			// 		case ScribeFormat.ascii:{
			// 			byte[] bytes = ( (String)_curr_record_ref[key] ).ToAscii();
			// 			Array.Resize<byte>(ref bytes, format_extra);
			// 			_compressed_top.PutData(bytes);
			// 			break;
			// 		}
			// 		case ScribeFormat.utf8:{
			// 			byte[] bytes = ( (String)_curr_record_ref[key] ).ToUTF8();
			// 			Array.Resize<byte>(ref bytes, format_extra);
			// 			_compressed_top.PutData(bytes);
			// 			break; // same as store_string()...?
			// 		}
			// 		case ScribeFormat.raw:
			// 			_compressed_top.PutData(_curr_record_ref[key]);
			// 			break;
			// 	}
			// }
		}
		// _op_counts += 1;
		// return false;
	}

	public bool test()
	{
		return true;
	}
}
