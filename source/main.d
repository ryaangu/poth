import core.stdc.stdlib;
import std.stdio;

import compiler;
import config;

/// Writes --help message to console.
void writeHelpMessage()
{
	writeln
	(
		"Poth Compiler v0.1\n",
		"Copyright (C) 2022, Ryan\n",
		"\n",
		"Usage:\n",
		"  poth [<option>...] <file>...\n",
		"\n",
		"Where:\n",
		"<file>:\n",
		"  Poth source file\n",
		"\n",
		"<option>:\n",
		"  --help = Shows this message.\n",
		"  --output = Sets the output path.\n",
	);
}

/// Parse command line arguments.
bool parseCommandLineArguments(string[] arguments)
{
	// The error message.
	string message;

	// Loop through each argument and try parsing it
	// NOTE: index = 1 because we skip the compiler path.
	for (uint index = 1; index < arguments.length; ++index)
	{
		// Get the current argument.
		string argument = arguments[index];

		// Is it an option?
		// Output option?
		if (argument == "--output")
		{
			// Set output path.
			if ((index + 1) < arguments.length)
				gOutputPath = arguments[++index];
			else
			{
				message = "expected output path.";
				goto error;
			}
		}

		// Help option?
		else if (argument == "--help")
			writeHelpMessage();

		// Not an option?
		else
		{
			// Let's act like we know it's an input and add it to 
			// source files.
			gSourceFiles ~= SourceFile(argument);
		}
	}

	// Check for inputs
	if (gSourceFiles.length == 0)
	{
		message = "no input files.";
		goto error;
	}

	// Check for output path
	if (gOutputPath == "")
	{
		gOutputPath = "poth_output";
		message     = "no output path specified, using 'poth_output' path.";
		goto warning;
	}

	return true;

	// A warning happened.
	warning:
		writeln("warning: ", message);
		return true;

	// An error happened.
	error:
		writeln("error: ", message);
		return false;
}

/// Entry point function.
void main(string[] arguments)
{
	// Parse all the command line arguments.
	if (!parseCommandLineArguments(arguments))
		exit(ExitCode.CommandLine);

	Compiler compiler;
	compiler.start();

	foreach (ref SourceFile file; gSourceFiles)
	foreach (d; file.definitions)
	{
		d.dump();
		writeln();
	}

	exit(ExitCode.Success);
}