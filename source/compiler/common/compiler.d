module compiler.common.compiler;

import compiler.common.diagnostic;
import compiler.common.file_location;
import compiler.common.source_file;
import compiler.common.nodes.node;
import compiler.frontend.parser;
import config;

import std.stdio;
import std.conv;
import std.uni;

/// A structure that represents a compiler.
struct Compiler
{
    /// Compile.
    void start()
    {
        // Parse all the source files.
        Parser parser = Parser();
        parser.start();

        // Write diagnostics.
        writeDiagnostics();

        // Check for semantic errors.
        if (!gHasFatalErrors)
        {
            // IR Generation
            foreach (ref SourceFile file; gSourceFiles)
            {
                foreach (ref Node node; file.nodes)
                    node.emit(file);
            }

            // C Generation
            import compiler.backend.c.emitter;
            
            C_Emitter emitter;
            emitter.start();
        }
    }

    /// Write diagnostics to console.
    void writeDiagnostics()
    {
        // Loop through every diagnostic and write it to console.
        foreach (Diagnostic diagnostic; gDiagnostics)
        {
            FileLocation location = diagnostic.location;
            
            // Get diagnostic color.
            string diagnosticColor = "";

            final switch (diagnostic.kind)
            {
                // Warning.
                case DiagnosticKind.Warning:
                {
                    diagnosticColor = "\033[1;33m";
                    break;
                }

                // Note.
                case DiagnosticKind.Note:
                {
                    diagnosticColor = "\033[1;34m";
                    break;
                }

                // Error.
                case DiagnosticKind.Error:
                {
                    diagnosticColor = "\033[1;31m";
                    break;
                }
            }

            // Write location information.
            write("\033[0;37m", diagnostic.path, ':', location.line, ':', location.column, ": ");
            write(diagnosticColor, asLowerCase(to!(string)(diagnostic.kind)));
            writeln("\033[0;37m", ": ", diagnostic.message);

            // Get location content without spacing at start.
            const(char) *line = location.lineStart;

            while (*line == ' ')
                ++line;

            // Get line information
            string lineInformation = to!(string)(location.line) ~ ' ';
            
            // Write "...|"
            for (int i = 0; i < lineInformation.length; ++i)
                write(' ');

            writeln("|");

            // Write "<line> | <content>"
            write(diagnosticColor, lineInformation);
            write("\033[0;37m", "| ");

            const(char) *content = line;

            while (*content != '\n' && *content != '\0')
                write(*content++);

            writeln("\033[0;37m");

            // Write "...| "
            for (int i = 0; i < lineInformation.length; ++i)
                write(' ');

            write("| ");

            // Get start position
            int distance      = (cast(int)(line - location.lineStart));
            int startPosition = (location.column > distance) ? (location.column - distance - location.length - 1) 
                                                             : 0; 
                                
            // Write "^~~..."
            write("\033[1;31m");

            for (int i = 0; i < startPosition; ++i)
                write(' ');

            write('^');

            for (int i = 1; i < location.length; ++i)
                write('~');

            writeln("\033[0;37m");
        }

        // Get pass color
        string passedColor = (gHasFatalErrors) ? "\033[1;31m" 
                                               : "\033[1;32m";

        // Write a little message to the console
        string passed = (gHasFatalErrors) ? "failure"
                                          : "successful";

        string s = (gDiagnostics.length > 1) ? "s" 
                                             : "";

        if (gDiagnostics.length > 0)
            writeln(passedColor, "\nBuild ", passed, " with ", gDiagnostics.length, " diagnostic", s, ".");
        else
            writeln(passedColor, "Build ", passed, " with no diagnostic.");

        write("\033[0;0m");
    }
}