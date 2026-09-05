public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Byte
public import RFC_2183

extension RFC_2183.Parameters: @retroactive ASCII.Serializable,
    @retroactive Binary.Serializable
{

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        Scan.append(Text.render(value), into: &buffer)
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Scan.append(Text.render(value), into: &buffer)
    }
}
