#include <vector>
#include <map>
#include <unordered_map>
#include <string>
#include <iostream>
#include <cstdint>
#include <algorithm>

using float32_t = float;
using float64_t = double;

enum class OperandKind : uint32_t
{
    None,
    Copy,
    Return,
};

enum class ConstantKind : uint32_t
{
    None,
    Register,
    Number,
};

enum class ResultKind : uint32_t
{
    Register,
    Stack,
};

enum class RegisterKind : uint32_t
{
    None,
    RAX,
    RBX,
    RCX,
    RDX,
};

struct Register
{
    RegisterKind kind;
    bool         used;
};

struct Constant
{
    union
    {
        // Register
        uint32_t reg;

        // Number
        float64_t num;
    };

    ConstantKind kind;

    Constant(ConstantKind)  :           kind(ConstantKind::None)     {}
    Constant(uint32_t  reg) : reg(reg), kind(ConstantKind::Register) {}
    Constant(float64_t num) : num(num), kind(ConstantKind::Number)   {}
};

struct Operand
{
    OperandKind kind;
    Constant    dst;
    Constant    src;

    Operand(OperandKind kind, Constant dst, Constant src) : kind(kind), 
                                                            dst(dst),
                                                            src(src) {}
};

struct LiveRange
{
    uint32_t   from;
    uint32_t   to;
    uint32_t   result;
    ResultKind kind;

    bool initialized; // this is just so I know if 'from' was initialized,
                      // maybe I can do this better

    bool operator==(const LiveRange &other)
    {
        return (other.reg == reg);
    }
};

static Operand code[] =
{
    // put value <n> into register <n>
    // return register <n>

    { OperandKind::Copy,   uint32_t(0),        float64_t(2) },
    { OperandKind::Copy,   uint32_t(1),        uint32_t(0)  },
    { OperandKind::Return, ConstantKind::None, uint32_t(1)  },
};

static Register registers[] =
{
    { RegisterKind::None, true  },
    { RegisterKind::RAX,  false },
    { RegisterKind::RBX,  false },
    { RegisterKind::RCX,  false },
    { RegisterKind::RDX,  false },
};

static const char *x64_register_name[] = 
{
    "stack location",
    "rax",
    "rbx",
    "rcx",
    "rdx",
};

static std::unordered_map<uint32_t, LiveRange> ranges;

uint32_t find_available_register(void)
{
    for (Register *reg = registers; reg != registers + (sizeof(registers) / sizeof(Register)); ++reg)
    {
        if (!reg->used)
        {
            reg->used = true;
            return uint32_t(reg->kind);
        }
    }

    return 0;
}

int32_t main(void)
{
    /*
        Liveness analysis
    */

    // Find live ranges
    for (uint32_t index = 0; index < sizeof(code) / sizeof(Operand); ++index)
    {
        const Operand &op = code[index];

        switch (op.kind)
        {
            case OperandKind::Copy:
            {
                if (ranges.find(op.dst.reg) == ranges.end())
                {
                    LiveRange temp_range;
                    temp_range.reg = op.dst.reg;

                    ranges.insert({ op.dst.reg, temp_range });
                }

                LiveRange &range = ranges[op.dst.reg];

                if (!range.initialized)
                {
                    range.initialized = true;
                    range.from        = index;
                }

                range.to = index;

                if (op.src.kind == ConstantKind::Register)
                {
                    LiveRange &src_range = ranges[op.src.reg];

                    if (!src_range.initialized)
                    {
                        src_range.initialized = true;
                        src_range.from        = index;
                    }

                    src_range.to = index;
                }
                break;
            }
            
            case OperandKind::Return:
            {
                LiveRange &range = ranges[op.src.reg];
                range.to         = index;
                break;
            }
        }
    }

    // Remove useless live ranges and codes
    for (const auto &pair : ranges)
    {
        const LiveRange &range = pair.second;

        if (range.from == range.to)
        {
            code[range.from].kind = OperandKind::None;
            ranges.erase(pair.first);
        }
    }

    /*
        Linear register allocation
    */

    // Make a vector of ranges in order of increasing 'from'
    std::vector<LiveRange> sorted_ranges;

    for (auto &pair : ranges)
        sorted_ranges.push_back(pair.second);

    sort
    (
        sorted_ranges.begin(), 
        sorted_ranges.end(),

        [](const LiveRange &a, const LiveRange &b)
        {
            return (a.from < b.from);
        }
    );

    // Linear scan
    std::vector<LiveRange> active;

    for (LiveRange &range : sorted_ranges)
    {
        // Expire old ranges
        for (LiveRange &active_range : active)
        {
            if (active_range.to >= range.from)
                break;

            active.erase(std::remove(active.begin(), active.end(), active_range), active.end());
            registers[ranges[active_range.reg].result].used = false;
        }

        // Allocate regiter or stack
        if (active.size() == sizeof(registers) / sizeof(Register))
        {
            LiveRange &spill = active.back();

            if (spill.to > range.to)
            
        }
        else
        {
            ranges[range.reg].kind   = ResultKind::Register;
            ranges[range.reg].result = find_available_register();

            active.push_back(range);

            // Sort active
            sort
            (
                active.begin(), 
                active.end(),

                [](const LiveRange &a, const LiveRange &b)
                {
                    return (a.to < b.to);
                }
            );
        }
    }

    /*
        x64 generation
    */

    for (Operand *op = code; op != code + (sizeof(code) / sizeof(Operand)); ++op)
    {
        switch (op->kind)
        {
            case OperandKind::Copy:
            {
                std::cout << "mov" << ' ' << x64_register_name[ranges[op->dst.reg].result] << ", ";

                if (op->src.kind == ConstantKind::Register)
                    std::cout << x64_register_name[ranges[op->src.reg].result] << std::endl;
                else
                    std::cout << op->src.num << std::endl;
                break;
            }

            case OperandKind::Return:
            {
                std::cout << "mov rax, " << x64_register_name[ranges[op->src.reg].result] << std::endl;
                std::cout << "ret"                                                        << std::endl;
                break;
            }
        }
    }

    return 0;
}