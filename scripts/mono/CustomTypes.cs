// 8-bit (single byte) Boolean, for cleaner Marshalling purposes
public readonly struct bool8 {
	private readonly byte _value;
	private bool8(byte value) {
		_value = value;
	}

	// implicit conversions!
	public static implicit operator bool8(bool value) // bool -> bool8
		=> new bool8(value ? (byte)1 : (byte)0);
	public static implicit operator bool(bool8 value) // bool8 -> bool
		=> value._value != 0;
}

public readonly struct GameTile {
	public readonly int grid_x;
	public readonly int grid_y;
	public readonly int grid_cantor;
	public readonly int map_x;
	public readonly int map_y;
	public readonly int map_cantor;

	public static int _cantor(int x, int y) {
		return x + (Enums.GRID_LENGTH * y);
	}
	public static int _x(int cantor) {
		return cantor % Enums.GRID_LENGTH;
	}
	public static int _y(int cantor) {
		return cantor / Enums.GRID_LENGTH;
	}

	public GameTile(int x, int y, bool map_space) {
		if (map_space) {
			map_x = x;
			map_y = y;
			map_cantor = _cantor(map_x, map_y);

			grid_cantor = map_cantor + GameInterfaces.Map_GetGridStartingOffset();
			grid_x = _x(grid_cantor);
			grid_y = _y(grid_cantor);
		} else {
			grid_x = x;
			grid_y = y;
			grid_cantor = _cantor(grid_x, grid_y);

			map_cantor = grid_cantor - GameInterfaces.Map_GetGridStartingOffset();
			map_x = _x(map_cantor);
			map_y = _y(map_cantor);
		}
	}
	public GameTile(int cantor, bool map_space) {
		if (map_space) {
			map_cantor = cantor;
			map_x = _x(map_cantor);
			map_y = _y(map_cantor);

			grid_cantor = map_cantor + GameInterfaces.Map_GetGridStartingOffset();
			grid_x = _x(grid_cantor);
			grid_y = _y(grid_cantor);
		} else {
			grid_cantor = cantor;
			grid_x = _x(grid_cantor);
			grid_y = _y(grid_cantor);

			map_cantor = grid_cantor - GameInterfaces.Map_GetGridStartingOffset();
			map_x = _x(map_cantor);
			map_y = _y(map_cantor);
		}
	}

	// public static implicit operator ?
}


