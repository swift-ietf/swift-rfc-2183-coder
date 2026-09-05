public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Byte
public import Parseable_ASCII
public import RFC_2183
import Byte_Standard_Library_Integration

extension RFC_2183.ContentDisposition: @retroactive ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        for byte in bytes {
            do throws(ASCII.Code.Error) {
                _ = try ASCII.Code(byte)
            } catch {
                throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
            }
        }
        self = try Text.contentDisposition(String(decoding: bytes, as: UTF8.self))
    }

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: string.utf8.map(Byte.init(bitPattern:)))
    }
}

extension RFC_2183.ContentDisposition: @retroactive ASCII.Serializable,
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

extension RFC_2183.ContentDisposition: @retroactive CustomStringConvertible {

    public var description: String { Text.render(self) }
}
