include("components.jl")

bus = Bus(0x0)

register_a = Register(0x0, bus)
register_b = Register(0x0, bus)
register_mar = Register(0x0, bus)
register_ir = Register(0x0, bus)
register_out = Register(0x0, bus)

alu = ALU(register_a, register_b, bus)
pc = ProgramCounter(0x00, bus)
ram = RAM(register_mar, bus)


AO = () -> output(register_a)
AI = () -> input(register_a)
BO = () -> output(register_b)
BI = () -> input(register_b)
ΣO = () -> output(alu)
MI = () -> input(register_mar)
RO = () -> output(ram)
RI = () -> input(ram)
IO = () -> output(register_ir)
II = () -> input(register_ir)
CO = () -> output(pc)
CI = () -> input(pc)
CE = () -> enable(pc)
OI = () -> input(register_out)



# Standard operations
so = [
    [CO, MI],
    [RO, II, CE]    
]

instruction_map = Dict(
    "LDA"  => 0x0,
    "LDB"  => 0x1,
    "STA"  => 0x2,
    "STB"  => 0x3,
    "ADD"  => 0x4,
    "ADDR" => 0x5,
    "JMP"  => 0x6,
    "OUT"  => 0x7,
    "OUTR" => 0x8,
    "HLT"  => 0xf
)
instructions = [
    # 0x0 - LDA
    [
        [IO, MI],
        [RO, AI]
    ],
    # 0x1 - LDB
    [
        [IO, MI],
        [RO, BI]
    ],
    # 0x2 - STA
    [
        [IO, MI],
        [AO, RI]
    ],
    # 0x3 - STB
    [
        [IO, MI],
        [BO, RI]
    ],
    # 0x4 - ADD
    [
        [ΣO, AI]
    ],
    # 0x5 - ADDR
    [
        [IO, MI],
        [ΣO, RI]
    ],
    # 0x6 - JMP
    [
        [IO, CI]
    ],
    # 0x7 - OUT
    [
        [AO, OI]
    ],
    # 0x8 - OUTR
    [
        [IO, MI],
        [RO, OI]
    ],
    [],
    [],
    [],
    [],
    [],
    [],
    # 0xf - HLT
    [
    ]
]


function step()
    for s ∈ so
        for f ∈ s
            f()
        end
    end
    op = value(register_ir) >> 4
    for s ∈ instructions[op+1]
        for f ∈ s
            f()
        end
    end
end

function reset()
    set_value(pc, 0x0)
    set_value(register_out, 0x0)
end

function load(program::Vector{UInt8})
    if length(program) > 16
        @error "Cannot load program more than 16 bytes in length"
        return
    end
    reset()

    ram.contents = UInt8[program..., zeros(UInt8, 16 - length(program))...]
end

function compile_file(file::AbstractString)
    function map_instruction(str)
        str = uppercase(str)
        if str ∈ keys(instruction_map)
            return instruction_map[str]
        end
        throw(ErrorException("Instruction $(str) does not exist"))
    end

    open(file, "r") do io
        lines = readlines(file)
        prg = UInt8[]
        for line ∈ lines
            els = split(line)
            if length(els) == 2
                op = map_instruction(els[1])
                arg = parse(UInt8, els[2])
                push!(prg, op << 4 + arg)
            elseif length(els) == 1
                if startswith(els[1], "0x")
                    push!(prg, parse(UInt8, els[1]))
                else
                    op = map_instruction(els[1])
                    push!(prg, op << 4)
                end
            elseif length(els) == 0
                push!(prg, 0x0)
            else
                throw(ErrorException("Error parsing asm file: Instructions must have 0, 1 or 2 operands"))
            end
        end

        prg
    end
end

function load_file(file::AbstractString)
    load(compile_file(file))
end

function write_program(file::AbstractString, prg::Vector{UInt8})
    open(file, "w") do io
        for i ∈ prg
            write(io, i)
        end
    end
end

function read_program(file::AbstractString)
    open(file, "r") do io
        prg = UInt8[]
        while !eof(io)
            push!(prg, read(io, UInt8))
        end

        prg
    end
end

function hex(n)
    return "0x" * string(n; base=16)
end

function state()
    return """
        Register A: $(hex(value(register_a)))
        Register B: $(hex(value(register_b)))
        Register MAR: $(hex(value(register_mar)))
        Register IR: $(hex(value(register_ir)))
        Register OUT: $(hex(value(register_out)))

        Program Counter: $(hex(value(pc)))
    """
end