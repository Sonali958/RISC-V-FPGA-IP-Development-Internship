<div align="center">

# RISC-V FPGA IP Development Internship

### VLSI System Design (VSD)

Documentation of internship tasks, FPGA implementations, simulations, and learning outcomes.

![Status](https://img.shields.io/badge/Status-In%20Progress-success)
![FPGA](https://img.shields.io/badge/Board-VSDSquadron-blue)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V-orange)

</div>

---

## 📖 Overview

This repository documents all tasks completed during the **RISC-V Based IP Design on VSDSquadron FPGA Internship** organized by **VLSI System Design (VSD)**.

### Topics Covered

- RISC-V Architecture
- Verilog HDL
- RTL Design & Verification
- FPGA Design Flow
- Simulation & Synthesis
- Hardware Validation
- Open Source Semiconductor Design

---


## 🛠️ Tools Used

- Oracle VirtualBox
- Ubuntu Linux
- Git
- GitHub
- VS Code
- GCC Compiler
- Verilog HDL
- VSDSquadron FPGA


---

## 📊 Internship Progress

| Task | Status |
|--------|--------|
| Task 1 | ✔ Completed |
| Task 2 | ✔ Completed |


---

## 📑 Table of Contents

- [Task 1](#task-1)
- [Task 2](#task-2)

---

# Task 1

<details>
<summary><b>RISC-V Toolchain Setup and Assembly Analysis</b></summary>

## Objective

The objective of this task was to:

- Create and execute a C program (`sum1ton.c`) in the Linux environment.
- Compile the program using the RISC-V cross compiler.
- Generate assembly instructions using `objdump`.
- Compare the generated instructions under different optimization levels (`-O1` and `-Ofast`).

---

## Part 1: Creating and Executing sum1ton.c

### Program Description

A C program was created to calculate the sum of numbers from 1 to N.

### Steps Performed

1. Created `sum1ton.c` using Leafpad/gedit.
2. Saved the source file.
3. Compiled the program.
4. Executed the program and verified the output.


### Screenshots

### Source Code

![Creating File](Task1/screenshots/ss2.png)



#### Creating the Source File using gedit in codespace

![Creating File](Task1/screenshots/ss1.png)


#### Creating the Source File using leafpad in virtual box

![Creating File](Task1/screenshots/sum1ton.png)


#### Program Execution

![Program Output](Task1/screenshots/ss3.png)

---

## Part 2: RISC-V Cross Compilation and Instruction Analysis

### Screenshot

![Displaying the Source Code](Task1/screenshots/ss4.png)


### Compilation Using -O1

```bash
riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
```

### listed sum1ton.o
```bash
ls -ltr sum1ton.o
```

### Disassembly

```bash
riscv64-unknown-elf-objdump -d sum1ton.o
```

```bash
riscv64-unknown-elf-objdump -d sum1ton.o | less
```

### Screenshots

### O1 Assembly Output

![O1 Assembly Output](Task1/screenshots/ss5.png)

---

### Using `riscv64-unknown-elf-objdump -d sum1ton.o | less`

![Disassembly Output and searching for main using /main](Task1/screenshots/ss7.png)

---

### Disassembly Output and searching for main using /main

![Disassembly Output and searching for main using /main](Task1/screenshots/ss8.png)

---

### RISC-V Assembly Code Generated from `sum1ton.c`

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss9.png)

---

### Calculation 1

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss10.png)

---

### Calculation 2 - Number of Instructions in the `main()` Function

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss11.png)

---

### Compilation Using -Ofast

```bash
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o sum1ton.o sum1ton.c
```

### Disassembly

```bash
riscv64-unknown-elf-objdump -d sum1ton.o
```
```bash
riscv64-unknown-elf-objdump -d sum1ton.o | less
```


### Screenshots

### Ofast Assembly Output

![Ofast Assembly Output](Task1/screenshots/ss12.png)

---

### Using `riscv64-unknown-elf-objdump -d sum1ton.o | less`

![Disassembly Output and searching for main using /main](Task1/screenshots/ss13.png)

---

### Disassembly Output and searching for main using /main

![Disassembly Output and searching for main using /main](Task1/screenshots/ss14.png)

---

### RISC-V Assembly Code Generated from `sum1ton.c`

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss15.png)

---

### Calculation 1

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss16.png)

---

### Calculation 2 - Number of Instructions in the `main()` Function

![RISC-V Assembly Code Generated from `sum1ton.c`](Task1/screenshots/ss17.png)

---


### Viewing Large Assembly Output

```bash
riscv64-unknown-elf-objdump -d sum1ton.o | less
```

This command was used to navigate through the assembly output page by page.

---

## Instruction Count Comparison

| Optimization Level | Number of Instructions in `<main>` |
|-------------------|-------------------------------------|
| O1 | 15 |
| Ofast | 12 |

### Observation

The assembly generated using the `-Ofast` optimization level was more optimized compared to `-O1`. By comparing the number of instructions present in the `<main>` function, it was observed that compiler optimization can reduce instruction count significantly and improve execution efficiency.

---

## Comparative Analysis of `-O1` and `-Ofast`

| Parameter                          | `-O1`                                                    | `-Ofast`                                        |
| ---------------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| Optimization Level                 | Moderate optimization                                    | Aggressive optimization                         |
| Primary Objective                  | Improve performance while maintaining safe optimizations | Maximize execution speed                        |
| Number of Instructions in `<main>` | **15**                                                   | **12*                                          |
| Assembly Code Size                 | Larger                                                   | Smaller                                         |
| Generated Code Efficiency          | Moderate                                                 | Higher                                          |
| Compiler Optimization              | Basic optimization techniques                            | Advanced optimization techniques |


---

## Learning Outcomes

- Learned Linux file creation and editing using Leafpad/gedit.
- Understood the RISC-V cross-compilation flow.
- Generated assembly code using `objdump`.
- Analyzed compiler optimization effects.
- Compared instruction counts between different optimization levels.

</details>

---

# Task 2

<details>
<summary><b>Task 2: SPIKE Simulation and Debugging using RISC-V GCC</b></summary>

### 📄 Detailed Documentation - It is in the Task 2 folder of the repository

👉 **[Click here to view the Task 2 Documentation](Task2/README.md)**

This task focuses on understanding the complete RISC-V software development flow using the RISC-V GCC toolchain and the SPIKE RISC-V ISA simulator. It includes C program verification, RISC-V cross-compilation, simulation, debugging, and digital design application implementation.

---

### Task 2A: RISC-V Toolchain Setup, Compilation, Simulation and Instruction Analysis

This part focuses on exploring the complete RISC-V software execution flow, starting from a high-level C program and moving towards low-level instruction analysis.

It includes:

* Compilation and verification of a C program using GCC.
* Cross-compilation of the program using `riscv64-unknown-elf-gcc`.
* Execution of the generated RISC-V binary using the SPIKE RISC-V ISA simulator.
* Generation and analysis of RISC-V assembly instructions using Objdump.
* Instruction-level debugging using SPIKE debug mode.
* Understanding the working and format of RISC-V instructions such as LUI and ADDI.

---

### Task 2B: Digital Design Application using C

This part focuses on developing a digital design application in C and validating its functionality across the RISC-V software flow.

It includes:

* Designing and implementing a application using C programming.
* Functional verification of the application using the GCC compiler.
* Cross-compilation of the application for the RISC-V architecture.
* Execution and validation of the generated RISC-V binary using the SPIKE simulator..

</details>

---


## 👩‍💻 Author

**Sonali**

ECE, The LNMIIT Jaipur
