public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_2183
import Byte_Standard_Library_Integration
import Parser
import Serializer

extension RFC_2183.Filename {

    public struct Coder<
        Input: Cursor.`Protocol`<Byte, Never>,
        Buffer: RangeReplaceableCollection<Byte>
    >: Coding {

        public typealias Output = RFC_2183.Filename

        public typealias Failure = RFC_2183.Filename.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let bytes = Scan.run(&input) { byte in
                let code = byte.bitPattern
                return code != 0x3B && code != 0x0D && code != 0x0A
            }
            do throws(Failure) {
                return try RFC_2183.Filename(
                    Text.unquoted(Text.trimmed(String(decoding: bytes, as: UTF8.self)))
                )
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.value, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_2183.Filename: Coder.Codable {}
