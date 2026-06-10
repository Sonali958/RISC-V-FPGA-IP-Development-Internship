# Task 2 - Part A  
## RISC-V Toolchain Setup, Compilation, Simulation and Instruction Analysis

## Objective

The objective of this task is to understand the complete RISC-V software flow by taking a simple C program, compiling it using the native GCC compiler, cross-compiling it for the RISC-V architecture, executing it on the Spike RISC-V simulator, and analyzing the generated RISC-V assembly instructions.

---

## Applications and Tools Used

### 1. GCC Compiler
GNU Compiler Collection (GCC) is used to compile and execute the C program on the host machine to verify its functionality.

### 2. RISC-V GCC Cross Compiler
`riscv64-unknown-elf-gcc` is used to convert the C source code into a RISC-V executable binary. It generates machine instructions that can be executed on a RISC-V processor.

### 3. Spike RISC-V ISA Simulator
Spike is the official RISC-V ISA simulator. It simulates the execution of RISC-V binaries and allows observation of instruction execution and register changes.

### 4. RISC-V Objdump
`riscv64-unknown-elf-objdump` is used to disassemble the RISC-V executable and display the generated assembly instructions.

---

# Step 1: C Program Verification Using GCC

A simple C program was used to calculate the sum of numbers from 1 to 100 using a loop. The program was compiled and executed using GCC to verify that it works correctly before performing RISC-V cross compilation.

C Program:

```c
#include<stdio.h>

int main()
{
    int i, sum = 0, n = 100;

    for(i = 1; i <= n; i++)
    {
        sum += i;
    }

    printf("The sum of numbers 1 to %d is: %d\n", n, sum);

    return 0;
}
```

Compilation command:

```bash
gcc sum1ton.c
```

Execution command:

```bash
./a.out
```

Output:

```
The sum of numbers 1 to 100 is: 5050
```

### Screenshot

![C Program and GCC Execution](screenshots/s1.png)

---

# Step 2: Cross Compiling for RISC-V Architecture

The C program was cross compiled using the RISC-V GCC compiler.

Command used:

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
```

Explanation of flags:

- `-Ofast` : Enables aggressive compiler optimizations.
- `-mabi=lp64` : Specifies the LP64 ABI where long integers and pointers are 64-bit.
- `-march=rv64i` : Generates instructions for the RISC-V 64-bit base integer ISA.
- `-o sum1ton.o` : Specifies the output executable file.

### Screenshot

![RISC-V Cross Compilation](screenshots/s2.png)

---

# Step 3: Executing the RISC-V Binary Using Spike

The generated RISC-V executable was executed using the Spike simulator.

Command:

```bash
spike pk sum1ton.o
```

Where:

- `spike` is the RISC-V ISA simulator.
- `pk` is the Proxy Kernel used to provide basic runtime support.

Output:

```
bbl loader

The sum of numbers 1 to 100 is: 5050
```

The same output confirms that the RISC-V binary executes correctly.

### Screenshot

![Spike Execution](screenshots/s2.png)

---

# Step 4: Generating RISC-V Assembly Code

The generated executable was disassembled using `objdump`.

Command:

```bash
riscv64-unknown-elf-objdump -d sum1ton.o | less
```

This displays the RISC-V assembly instructions corresponding to the C program.

### Screenshot

![Objdump Output](screenshots/s4.png)

---

# Step 5: Debugging Instructions Using Spike

Spike debug mode was enabled using:

```bash
spike -d pk sum1ton.o
```

The debugger was instructed to stop at the beginning of the `main()` function:

```bash
until pc 0 100b0
```

The contents of a register can be checked using:

```bash
reg 0 a2
```

Initially, the value of register `a2` was:

```
0x0000000000000000
```

After executing one instruction:

```bash
reg 0 a2
```

The value changed to:

```
0x0000000000001000
```

This confirms that the instruction modified the register value.

### Screenshot

![Spike Debug Mode](screenshots/s5.png)

---

# Step 6: Analysis of LUI (Load Upper Immediate) Instruction

The first instruction observed was:

```assembly
lui a2, 0x1
```

LUI loads a 20-bit immediate value into the upper 20 bits of the destination register and fills the lower 12 bits with zeros.

Operation:

```
a2 = 0x1 << 12
```

Therefore:

```
a2 = 0x0000000000001000
```

This matches the value observed in Spike.

### Screenshot

![LUI Instruction Analysis](screenshots/s6.png)

---

# Step 7: Analysis of ADDI Instruction and Stack Pointer Update

The next instruction analyzed was:

```assembly
addi sp, sp, -16
```

ADDI adds an immediate value to a source register and stores the result in the destination register.

Before execution:

```
sp = 0x000000007f7e9b50
```

After execution:

```
sp = 0x000000007f7e9b40
```

Since:

```
0x7f7e9b50 - 0x10 = 0x7f7e9b40
```

The result confirms the operation of the instruction.

### Screenshot

Register value verification:

![ADDI Register Verification](screenshots/s7.png)

Hexadecimal calculation verification:

![ADDI Hex Calculation](screenshots/s8.png)

ADDI instruction format analysis:

The ADDI instruction follows the RISC-V I-type instruction format. It consists of a 12-bit immediate field, source register (`rs1`), function code (`funct3`), destination register (`rd`), and opcode. The immediate value is sign-extended and added to the value stored in the source register.

![ADDI Instruction Format](screenshots/s9.png)

---

# Conclusion

This task demonstrated the complete RISC-V software execution flow starting from a high-level C program to low-level instruction analysis.

The following concepts were understood:

- C program compilation using GCC.
- Cross-compilation using RISC-V GCC.
- Execution of RISC-V binaries using the Spike simulator.
- Generation and analysis of RISC-V assembly instructions.
- Instruction-level debugging using Spike.
- Working of RISC-V instructions such as LUI and ADDI.
- Understanding of RISC-V instruction formats and register modifications during execution.

This provides a foundation for understanding how high-level C code is translated into RISC-V machine instructions and executed by a processor.
