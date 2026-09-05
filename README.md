# swift-rfc-2183-coder

Wire coders for [swift-rfc-2183](https://github.com/swift-ietf/swift-rfc-2183): `RFC_2183.ContentDisposition.Coder`, `RFC_2183.Filename.Coder` and `RFC_2183.Size.Coder` parse and serialize the Content-Disposition text forms over any byte cursor, `Coder.Codable` gives each of them `encoded()` and `init(decoding:)`, and the `ASCII.Parseable`, `ASCII.Serializable` and `Binary.Serializable` conformances (with `RFC_2183.ContentDisposition.description` and the `RFC_5322.Header` construction) live here so that the domain package stays a pure model.
