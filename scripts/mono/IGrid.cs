public interface IGrid
{
	int Width { get; }
    int Height { get; }
    bool Fill(byte[] bytes);
    byte[] Dump();
    object GetValue(int x, int y);
    bool SetValue(int x, int y, object value);
}