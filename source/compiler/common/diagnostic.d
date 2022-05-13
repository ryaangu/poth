module compiler.common.diagnostic;

import compiler.common.file_location;

/// The kind of a diagnostic.
enum DiagnosticKind
{
    Warning,
    Note,
    Error,
}

/// A structure that represents a diagnostic.
struct Diagnostic
{
    /// The kind of the diagnostic.
    DiagnosticKind kind;

    /// The file path of where the diagnostic happened.
    string path;

    /// The file location of the diagnostic's content.
    FileLocation location;

    /// The message of the diagnostic.
    string message;
}