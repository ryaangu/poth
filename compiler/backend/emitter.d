module compiler.backend.emitter;

import compiler.frontend.scanner;

import compiler.ir.ir_constant;
import compiler.ir.ir_builder;
import compiler.ir.ir_label;

import std.algorithm;
import std.stdio;
import std.file;
import std.conv;

struct Emitter
{
    Scanner scanner;

    IR_Builder builder;
    IR_Label *current_label;
    
    uint[] stack;

    void advance()
    {
        for (;;)
        {
            if (scanner.scan() != TokenKind.Error)
                break;

            // error
        }
    }

    bool match(TokenKind kind)
    {
        if (scanner.current.kind == kind)
        {
            advance();
            return true;
        }

        return false;
    }

    void consume(TokenKind kind, string message)
    {
        if (match(kind))
            return;

        // error
    }

    void push(IR_Constant constant)
    {
        IR_Constant register = current_label.add_register();
        current_label.assign(register, constant);
        stack ~= register.as_register;
    }

    IR_Constant pop()
    {
        if (stack.length == 0)
            writeln("tried to pop nothing.");

        uint register = stack[$ - 1];
        --stack.length;

        return IR_Constant(register);
    }

    void emit()
    {
        advance();

        switch (scanner.previous.kind)
        {
            case TokenKind.Integer:
            {
                push(IR_Constant(to!(long)(scanner.previous.content)));
                break;
            }

            case TokenKind.Float:
            {
                push(IR_Constant(to!(double)(scanner.previous.content)));
                break;
            }

            case TokenKind.Plus:
            {
                IR_Constant a = pop();
                IR_Constant b = pop();

                IR_Constant register = current_label.add_register();
                stack ~= register.as_register;
                current_label.add(register, a, b);
                break;
            }

            case TokenKind.Dot:
            {
                current_label.cout(pop());
                break;
            }

            default:
                break;
        }
    }

    void start()
    {
        scanner = Scanner(readText("tests/test.mn") ~ "\0");
        writeln("-- INPUT --\n", scanner.source, '\n');
        current_label = builder.add_label("main");
        advance();

        while (!match(TokenKind.End))
            emit();
    }
}