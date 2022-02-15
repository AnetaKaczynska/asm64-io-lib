# asm64_io_lib

### About
Simple ABI64-compliant library that provides the following input/output operations:
- read_char / print_char
- read_int / print_int
- read_string / print_string

### Usage
Compile and run example.cpp.
```shell script
g++ -o example.o -c example.cpp && \
nasm -f elf64 -o lib.o lib.asm && \
g++ -o example lib.o example.o && \
./example
```
