module moon.main;

import std.stdio;
import moon.scanner;

void main()
{
    Scanner scanner = Scanner("1.4 1.3\0");
    writeln(scanner.scan());
    writeln(scanner.scan());
    writeln(scanner.scan());
}