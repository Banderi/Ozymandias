// 8-bit (single byte) Boolean, for cleaner Marshalling purposes
public readonly struct bool8
{
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