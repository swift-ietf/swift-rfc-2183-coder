public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import RFC_2183

extension RFC_2183.DispositionType: @retroactive ASCII.Serializable,
    @retroactive Binary.Serializable
{}
