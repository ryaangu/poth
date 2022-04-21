// module compiler.backend.emitter;

// import compiler.config;

// import compiler.frontend.node;

// import compiler.ir.ir_constant;
// import compiler.ir.ir_builder;
// import compiler.ir.ir_label;

// import std.algorithm;
// import std.stdio;
// import std.file;
// import std.conv;

// struct Emitter
// {
//     Scanner scanner;

//     IR_Builder builder;
//     IR_Label *current_label;
    
//     uint[] stack;

//     void push(IR_Constant constant)
//     {
//         IR_Constant register = current_label.add_register();
//         current_label.assign(register, constant);
//         stack ~= register.as_register;
//     }

//     IR_Constant pop()
//     {
//         if (stack.length == 0)
//             writeln("tried to pop nothing.");

//         uint register = stack[$ - 1];
//         --stack.length;

//         return IR_Constant(register);
//     }

//     void forward_declare()
//     {
//         advance();

//         switch (scanner.previous.kind)
//         {
//             case TokenKind.Identifier:
//             {
//                 string name = scanner.previous.content;

//                 if (match(TokenKind.Colon))
//                 {
//                     if (name in builder.labels)
//                     {
//                         // error
//                         writeln("HUH!");
//                     }

//                     current_label = builder.add_label(name);
//                 }

//                 break;    
//             }

//             default:
//                 break;
//         }
//     }

//     void emit()
//     {
//         advance();

//         switch (scanner.previous.kind)
//         {
//             case TokenKind.Identifier:
//             {
//                 string name = scanner.previous.content;

//                 if (match(TokenKind.Colon))
//                     current_label = &(builder.labels[name]);
//                 else
//                     writeln("calls not supported yet.");
//                 break;    
//             }

//             case TokenKind.Integer:
//             {
//                 push(IR_Constant(to!(long)(scanner.previous.content)));
//                 break;
//             }

//             case TokenKind.Float:
//             {
//                 push(IR_Constant(to!(double)(scanner.previous.content)));
//                 break;
//             }

//             case TokenKind.Plus:
//             {
//                 IR_Constant a = pop();
//                 IR_Constant b = pop();

//                 IR_Constant register = current_label.add_register();
//                 stack ~= register.as_register;
//                 current_label.add(register, a, b);
//                 break;
//             }

//             case TokenKind.Dot:
//             {
//                 current_label.cout(pop());
//                 break;
//             }

//             default:
//                 break;
//         }
//     }

//     void reset()
//     {
//         scanner = Scanner(readText("tests/test.mn") ~ "\0");
//         advance();
//     }

//     void start()
//     {
//         reset();
//         writeln("-- INPUT --\n", scanner.source, '\n');
//         current_label = builder.add_label("main");
//     }
// }