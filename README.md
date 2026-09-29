# swift-rfc-2183-coder

Wire coders for [swift-rfc-2183](https://github.com/swift-ietf/swift-rfc-2183): `RFC_2183.ContentDisposition.Coder`, `RFC_2183.DispositionType.Coder`, `RFC_2183.ParameterName.Coder`, `RFC_2183.Filename.Coder` and `RFC_2183.Size.Coder` parse and serialize the Content-Disposition text forms over any byte cursor, `Coder.Codable` gives each of them `encoded()` and `init(decoding:)`, and the `ASCII.Parseable`, `ASCII.Serializable` and `Binary.Serializable` conformances of `ContentDisposition`, `DispositionType`, `ParameterName`, `Filename` and `Size` and the `ASCII.Serializable` / `Binary.Serializable` conformances of `Parameters` live here together with the rendered text forms (`RFC_2183.ContentDisposition.description`, `RFC_2183.Size.rawValue` / `description`) and the `RFC_5322.Header(_:)` construction, so that the domain package stays a pure model.

```swift
import Byte
import Byte_Standard_Library_Integration
import Coder_Standard_Library_Integration
import RFC_2183
import RFC_2183_Coder

var input: ArraySlice<Byte> = "attachment; filename=\"report.pdf\"; size=1024"
let disposition = try RFC_2183.ContentDisposition.coder.parse(&input)
disposition.filename?.value                                  // "report.pdf"
disposition.size?.bytes                                      // 1024

try disposition.encoded()                                    // "attachment; filename=\"report.pdf\"; size=1024"
disposition.description                                      // the same text
```
