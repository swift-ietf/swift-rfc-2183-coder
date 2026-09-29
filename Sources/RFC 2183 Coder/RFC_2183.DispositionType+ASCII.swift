public import ASCII
public import Binary
public import RFC_2183

extension RFC_2183.DispositionType: @retroactive ASCII.Parseable {}

extension RFC_2183.DispositionType: @retroactive ASCII.Serializable,
    @retroactive Binary.Serializable
{}
