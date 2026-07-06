# PWM Software Guide

## Overview

This directory contains the reference software application for the PWM IP developed for the VSDSquadron FPGA RISC-V SoC.

The software demonstrates how to configure, control, and validate the PWM peripheral through its memory-mapped register interface. It serves both as a functional example and as a hardware verification program for the integrated PWM IP.

The example application is intended to run directly on the VSDSquadron RISC-V processor without requiring any modifications to the RTL implementation.

---

# Directory Structure

```
software/
├── pwm_test.c
└── Software_Guide.md
```

| File | Description |
|------|-------------|
| `pwm_test.c` | Complete reference software demonstrating configuration and validation of the PWM IP |
| `Software_Guide.md` | Documentation for compiling, executing, and understanding the software example |

---

# Software Objectives

The software demonstrates the following capabilities:

- Initialization of the PWM peripheral
- Memory-mapped register programming
- Register read/write verification
- PWM enable and disable operation
- Duty cycle configuration
- Period configuration
- Status register monitoring
- Boundary condition testing
- Live counter monitoring
- UART-based reporting of validation results

---

# Hardware Requirements

- VSDSquadron FPGA Board
- Integrated PWM IP
- RISC-V SoC
- UART Interface
- On-board LED

---

# Software Requirements

The following software tools are required:

- RISC-V GCC Toolchain
- Make Utility
- UART Terminal (PuTTY, Minicom, Tera Term, etc.)

---

# Building the Application

Compile the software using the VSDSquadron software environment.

Example:

```bash
make
```

This generates the executable that is loaded onto the RISC-V processor.

---

# Running the Application

1. Program the FPGA with the integrated SoC design.
2. Load the compiled executable into the RISC-V system.
3. Open the UART terminal.
4. Reset the processor.
5. Execute the application.
6. Observe the UART output.
7. Observe the LED connected to `pwm_out`.

---

# Software Operation

The application configures the PWM peripheral using memory-mapped register accesses.

The initialization sequence is shown below.

```
System Reset
      │
      ▼
Read Default Registers
      │
      ▼
Configure PWM Period
      │
      ▼
Configure PWM Duty Cycle
      │
      ▼
Enable PWM
      │
      ▼
Read Status Register
      │
      ▼
Execute Validation Tests
      │
      ▼
Display Test Results
```

---

# Validation Tests

The application automatically performs the following tests.

| Test | Description |
|------|-------------|
| Test 1 | Verify default register values |
| Test 2 | Verify PERIOD register |
| Test 3 | Verify DUTY register |
| Test 4 | Verify CTRL register |
| Test 5 | Verify STATUS register |
| Test 6 | Boundary Test (DUTY = 0) |
| Test 7 | Boundary Test (DUTY = PERIOD) |
| Test 8 | Boundary Test (DUTY > PERIOD) |
| Test 9 | Counter Monitoring |
| Test 10 | Disable PWM |

Each test reports either **PASS** or **FAIL** through the UART interface.

---

# Register Programming Sequence

The PWM peripheral is programmed using the following register write sequence.

```c
IO_OUT(IO_PWM_PERIOD, PERIOD_VAL);
IO_OUT(IO_PWM_DUTY, DUTY_VAL);
IO_OUT(IO_PWM_CTRL, PWM_EN);
```

The STATUS register can then be read to monitor the running state of the peripheral.

```c
status = IO_IN(IO_PWM_STATUS);
```

---

# Expected UART Output

A successful execution produces output similar to:

```text
PWM TEST START

PWM SOFTWARE TEST

TEST1 Default Registers
[PASS]

TEST2 PERIOD
[PASS]

TEST3 DUTY
[PASS]

TEST4 CTRL
[PASS]

TEST5 STATUS
[PASS]

TEST6 DUTY=0
[PASS]

TEST7 DUTY=PERIOD
[PASS]

TEST8 DUTY>PERIOD
[PASS]

TEST9 MONITOR
[PASS]

TEST10 DISABLE
[PASS]

RESULT

PASS : 10
FAIL : 0

PWM VERIFIED
```

---

# Expected Hardware Behaviour

After the software configures the PWM peripheral:

- The PWM output becomes active.
- The STATUS register indicates that the PWM is running.
- The internal counter continuously increments.
- The LED connected to `pwm_out` changes brightness according to the programmed duty cycle.
- Disabling the PWM forces the output to its inactive state.

---

# Duty Cycle Demonstration

| Duty Cycle | Expected LED Behaviour |
|------------|------------------------|
| 0% | LED OFF |
| 25% | Dim |
| 50% | Medium Brightness |
| 75% | Bright |
| 100% | Fully ON |

---

# Error Conditions

| Condition | Expected Behaviour |
|-----------|-------------------|
| PERIOD = 0 | PWM remains disabled or undefined (avoid configuration) |
| DUTY = 0 | Output remains LOW |
| DUTY = PERIOD | Output remains HIGH |
| DUTY > PERIOD | Output remains HIGH according to implemented logic |
| CTRL.EN = 0 | PWM output disabled |

---

# Verification Summary

The software verifies:

- Correct memory-mapped communication
- Register read/write operations
- PWM configuration
- Counter operation
- STATUS register functionality
- Boundary condition handling
- UART communication
- Hardware operation on the FPGA

---

# Related Documentation

Additional documentation is available in:

```
docs/
├── IP_User_Guide.md
├── Register_Map.md
├── Integration_Guide.md
└── Example_Usage.md
```

---

# Conclusion

The provided software serves as a complete reference application for the PWM IP. It demonstrates peripheral initialization, register configuration, runtime monitoring, and functional validation on both simulation and the VSDSquadron FPGA platform. The application can be used directly for verification or as a foundation for developing custom PWM-based embedded applications.
