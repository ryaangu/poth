module compiler.common.file_location;

/// A structure that represents a location in the file.
struct FileLocation
{
    /// Points to the start of the line's content.
    const(char) *lineStart;

    /// The line of where the content is.
    ushort line;

    /// The column of where the content starts.
    ushort column;

    /// The length of the content it is pointing to.
    ushort length;
}