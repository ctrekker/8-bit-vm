# 8-bit-vm
An 8-bit computer virtual machine for designing programs to run on my 8-bit Minecraft computer

## Why?
This project is meant to be a virtual machine for an extremely simple computer. This computer only has a couple different instructions and only 16 bytes of RAM. It follows an identical architecture to the one being built inside Minecraft for the sake of learning. However, computers inside Minecraft are extremely slow due to the speed limits of its in-game circuits. As such this computer is meant to serve as a development machine for building programs which can run inside my Minecraft computer.

I also believe it could be a valuable educational resource for those wishing to learn about how computers work, especially if some kind of user interface is constructed wrapping this repository.

## How?
The computer is written in Julia. As of now you can run code by cloning this repository and including computer.jl
```
git clone https://github.com/ctrekker/8-bit-vm
cd 8-bit-vm
```
Start a Julia REPL and enter the following:
```
include("computer.jl")
```
Then try running the sample `fib.bin` compiled program.
```
load(read_program("fib.bin"))
```
You can compile your own programs by writing them in the format found in `fib.asm` and calling the following functions in the REPL:
```
write_program("fib.bin", compile_file("fib.asm"))
```
This will simply compile the file `fib.asm` and write the compiled output to `fib.bin`

The full (but not very verbose) documentation for this computer can be found in [documentation.pdf](documentation.pdf)

Check out this article I wrote for a far more details explaination of how this VM works: https://cotangent.dev/making-a-computer-inside-a-computer-with-julia/
