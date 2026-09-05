import Byte
import Byte_Standard_Library_Integration
import Coder
import Coder_Standard_Library_Integration
import Cursor_Standard_Library_Integration
import RFC_2183
import RFC_2183_Coder
import Testing

@Suite
struct `RFC_2183.ContentDisposition Coder Tests` {

    @Test
    func `parses an attachment with a quoted filename`() throws {
        var input: ArraySlice<Byte> = "attachment; filename=\"document.pdf\""

        let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "document.pdf")
    }

    @Test
    func `stops at the line break`() throws {
        var input: ArraySlice<Byte> = "inline\r\nContent-Type: text/plain"

        let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

        #expect(disposition.type == .inline)
        #expect(input == "\r\nContent-Type: text/plain")
    }

    @Test
    func `a semicolon inside a quoted value does not split the parameter`() throws {
        var input: ArraySlice<Byte> = "attachment; filename=\"a;b.txt\""

        let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)

        #expect(disposition.filename?.value == "a;b.txt")
    }

    @Test
    func `an escaped quote survives the round trip`() throws {
        let disposition = RFC_2183.ContentDisposition(
            type: .attachment,
            parameters: .init(filename: try RFC_2183.Filename(#"file"with"quotes.txt"#))
        )

        #expect(
            try disposition.encoded()
                == #"attachment; filename="file\"with\"quotes.txt""#
        )
        #expect(try RFC_2183.ContentDisposition(ascii: disposition.encoded()) == disposition)
    }

    @Test
    func `form data renders its field name and filename`() throws {
        let disposition = RFC_2183.ContentDisposition.formData(
            name: "avatar",
            filename: try RFC_2183.Filename("photo.jpg")
        )

        #expect(
            disposition.description
                == #"form-data; filename="photo.jpg"; name="avatar""#
        )
    }

    @Test
    func `a size renders as decimal octets`() throws {
        let size = try RFC_2183.Size(bytes: 1_048_576)

        var input: ArraySlice<Byte> = "1048576"
        #expect(try RFC_2183.Size.coder.parse(&input) == size)
        #expect(try size.encoded() == "1048576")
    }

    @Test
    func `an empty disposition type is refused`() {
        var input: ArraySlice<Byte> = "; filename=\"x.txt\""

        #expect(throws: RFC_2183.ContentDisposition.Error.emptyDispositionType) {
            try RFC_2183.ContentDisposition.coder.parse(&input)
        }
    }
}
