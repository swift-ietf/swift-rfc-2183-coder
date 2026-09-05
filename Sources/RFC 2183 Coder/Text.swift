import RFC_2183
import RFC_5322

enum Text {

    static func trimmed(_ text: some StringProtocol) -> String {
        var slice = Substring(text)
        while let first = slice.first, first == " " || first == "\t" {
            slice = slice.dropFirst()
        }
        while let last = slice.last, last == " " || last == "\t" {
            slice = slice.dropLast()
        }
        return String(slice)
    }

    static func quoted(_ value: String) -> String {
        var result = "\""
        for character in value {
            if character == "\"" { result.append("\\") }
            result.append(character)
        }
        result.append("\"")
        return result
    }

    static func unquoted(_ value: String) -> String {
        guard value.count >= 2, value.hasPrefix("\""), value.hasSuffix("\"") else {
            return value
        }
        var result = ""
        var escaped = false
        for character in value.dropFirst().dropLast() {
            if escaped {
                result.append(character)
                escaped = false
                continue
            }
            if character == "\\" {
                escaped = true
                continue
            }
            result.append(character)
        }
        return result
    }

    static func segments(_ text: String) -> [String] {
        var segments: [String] = []
        var current = ""
        var quoting = false
        var escaped = false

        for character in text {
            if escaped {
                current.append(character)
                escaped = false
                continue
            }
            if quoting, character == "\\" {
                current.append(character)
                escaped = true
                continue
            }
            if character == "\"" {
                quoting.toggle()
                current.append(character)
                continue
            }
            if character == ";", !quoting {
                segments.append(current)
                current = ""
                continue
            }
            current.append(character)
        }
        segments.append(current)
        return segments
    }

    static func render(_ disposition: RFC_2183.ContentDisposition) -> String {
        disposition.type.rawValue + render(disposition.parameters)
    }

    static func render(_ parameters: RFC_2183.Parameters) -> String {
        var result = ""

        if let filename = parameters.filename {
            result += "; filename=" + quoted(filename.value)
        }
        if let creationDate = parameters.creationDate {
            result += "; creation-date=" + quoted(creationDate.description)
        }
        if let modificationDate = parameters.modificationDate {
            result += "; modification-date=" + quoted(modificationDate.description)
        }
        if let readDate = parameters.readDate {
            result += "; read-date=" + quoted(readDate.description)
        }
        if let size = parameters.size {
            result += "; size=" + size.rawValue
        }
        if let name = parameters.name {
            result += "; name=" + quoted(name)
        }
        for (key, value) in parameters.extensionParameters.sorted(by: {
            $0.key.rawValue < $1.key.rawValue
        }) {
            result += "; " + key.rawValue + "=" + quoted(value)
        }

        return result
    }

    static let known: Set<String> = [
        "filename",
        "creation-date",
        "modification-date",
        "read-date",
        "size",
        "name",
    ]

    static func parameters(_ raw: [String: String]) -> RFC_2183.Parameters {
        var parameters = RFC_2183.Parameters()

        if let filename = raw["filename"] {
            parameters.filename = try? RFC_2183.Filename(filename)
        }
        if let creationDate = raw["creation-date"] {
            parameters.creationDate = try? RFC_5322.DateTime(creationDate)
        }
        if let modificationDate = raw["modification-date"] {
            parameters.modificationDate = try? RFC_5322.DateTime(modificationDate)
        }
        if let readDate = raw["read-date"] {
            parameters.readDate = try? RFC_5322.DateTime(readDate)
        }
        if let size = raw["size"] {
            parameters.size = try? RFC_2183.Size(size)
        }
        parameters.name = raw["name"]

        for (key, value) in raw where !known.contains(key) {
            parameters.extensionParameters[RFC_2183.ParameterName(rawValue: key)] = value
        }

        return parameters
    }

    static func contentDisposition(
        _ text: String
    ) throws(RFC_2183.ContentDisposition.Error) -> RFC_2183.ContentDisposition {
        let parts = segments(text)

        let type = trimmed(parts[0])
        guard !type.isEmpty else {
            throw .emptyDispositionType
        }

        var raw: [String: String] = [:]
        for segment in parts.dropFirst() {
            guard let equals = segment.firstIndex(of: "=") else { continue }
            let key = trimmed(segment[..<equals]).lowercased()
            guard !key.isEmpty else { continue }
            let value = trimmed(segment[segment.index(after: equals)...])
            guard !value.isEmpty else { continue }
            raw[key] = unquoted(value)
        }

        return RFC_2183.ContentDisposition(
            type: RFC_2183.DispositionType(rawValue: type),
            parameters: parameters(raw)
        )
    }
}
