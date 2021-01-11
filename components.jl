abstract type Component end

mutable struct Bus
    contents::UInt8
end
value(c::Bus) = c.contents
set_value(c::Bus, v::UInt8) = c.contents = v

mutable struct Register <: Component
    value::UInt8
    bus::Bus
end
value(c::Register) = c.value
set_value(c::Register, v::UInt8) = c.value = v

mutable struct ProgramCounter <: Component
    value::UInt8
    bus::Bus
end
value(c::ProgramCounter) = c.value
set_value(c::ProgramCounter, v::UInt8) = c.value = v
enable(c::ProgramCounter) = c.value += 1

mutable struct ALU <: Component
    in1::Register
    in2::Register
    bus::Bus
end
value(c::ALU) = value(c.in1) + value(c.in2)

mutable struct RAM <: Component
    contents::Vector{UInt8}
    mar::Register
    bus::Bus

    RAM(mar::Register, bus::Bus) = new(zeros(UInt8, 16), mar, bus)
end
value(c::RAM) = c.contents[value(c.mar) << 4 >> 4 + 1]
set_value(c::RAM, v::UInt8) = c.contents[value(c.mar) << 4 >> 4 + 1] = v

output(c::Component) = c.bus.contents = value(c)
input(c::Component) = set_value(c, c.bus.contents)
