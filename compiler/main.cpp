#include <runtime/stack.hpp>
#include <runtime/builtin.hpp>

// The global stack
Stack stack;

// The entry point function
int main(void)
{
    stack.push("hello\n");
    cout(stack.pop());

    // Success
    return 0;
}