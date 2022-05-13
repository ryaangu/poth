module config;

import compiler.common.source_file;
import compiler.common.diagnostic;

/// All the exit codes.
enum ExitCode
{
    /// No errors happened.
    Success,

    /// An unknown error happened.
    Failure,

    /// Failed to parse command line argument.
    CommandLine,
}

/// All the source files are in this array.
__gshared SourceFile[] gSourceFiles;

/// The output path.
__gshared string gOutputPath;

/// Fatal errors happened?
__gshared bool gHasFatalErrors = false;

/// All the diagnostics.
__gshared Diagnostic[] gDiagnostics;