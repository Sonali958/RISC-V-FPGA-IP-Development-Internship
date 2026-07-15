# PWM Software Guide

## Version

1.0

**Target Platform:** VSDSquadron FPGA SoC

---

# Overview

This directory contains the reference software application for the PWM IP integrated into the VSDSquadron RISC-V SoC.

The application demonstrates how to configure and control the PWM peripheral through its memory-mapped register interface. It also provides a practical example of runtime duty-cycle adjustment, status monitoring, UART reporting, and polarity switching.

The software is intended to run directly on the embedded RISC-V processor without requiring any modification to the PWM hardware.

---

# Directory Structure

```
software/
├── pwm_test.c
├── io.h
└── Software_Guide.md
```

| File | Description |
|------|-------------|
|`pwm_test.c`|Reference PWM demonstration application|
|`io.h`|Memory-mapped register definitions|
|`Software_Guide.md`|Software documentation|

---

# Software Objectives

The reference application demonstrates:

- PWM peripheral initialization
- Memory-mapped register programming
- PWM enable and disable
- Period configuration
- Duty-cycle configuration
- STATUS register monitoring
- UART status reporting
- Runtime duty-cycle updates
- Active-High PWM mode
- Active-Low PWM mode

---

# Hardware Requirements

- VSDSquadron FPGA Board
- Integrated PWM IP
- RISC-V SoC
- USB-UART Adapter
- On-board LED

---

# Software Requirements

Required development tools:

- RISC-V GCC Toolchain
- Make
- UART Terminal (Picocom, Minicom, PuTTY, Tera Term)

---

# Building the Software

Compile the firmware.

```bash
make
```

The generated executable is loaded into the RISC-V processor memory.

---

# Running the Application

1. Program the FPGA.
2. Load the firmware.
3. Connect the UART terminal.
4. Reset the processor.
5. Observe UART messages.
6. Observe the LED brightness.

---

# Software Operation

The firmware performs the following sequence.

```
Reset PWM

      │

      ▼

Configure PERIOD

      │

      ▼

Configure DUTY

      │

      ▼

Enable PWM

      │

      ▼

Read STATUS

      │

      ▼

Increase Duty Cycle

      │

      ▼

Decrease Duty Cycle

      │

      ▼

Disable PWM

      │

      ▼

Toggle Output Polarity

      │

      ▼

Repeat
```

---

# Register Programming

The PWM peripheral is configured using memory-mapped register writes.

Disable PWM

```c
IO_OUT(REG_PWM_CONTROL,0);
```

Configure the period

```c
IO_OUT(REG_PWM_PERIOD_VAL,100);
```

Configure the duty cycle

```c
IO_OUT(REG_PWM_DUTY_VAL,50);
```

Enable PWM

```c
IO_OUT(REG_PWM_CONTROL,1);
```

Read STATUS

```c
status = IO_IN(REG_PWM_STATUS);
```

---

# Runtime Demonstration

After initialization, the firmware automatically

- increases duty cycle from 0% to 100%
- decreases duty cycle from 100% to 0%
- disables PWM
- switches output polarity
- repeats continuously

This produces a smooth LED fade effect.

---

# UART Output

Typical UART output

```text
=====================================
        PWM IP SOFTWARE TEST
=====================================

PWM ENABLED

Mode : ACTIVE HIGH
Period : 100
Status : 0x00000001

Increasing Duty Cycle

Duty = 0
Duty = 10
Duty = 20
...
Duty = 100

Decreasing Duty Cycle

Duty = 100
...
Duty = 0

PWM DISABLED

Switching PWM Polarity...
```

The sequence repeats in Active-Low mode.

---

# Expected Hardware Behaviour

When executed successfully,

- PWM output becomes active.
- LED brightness gradually increases.
- LED brightness gradually decreases.
- STATUS register reflects peripheral activity.
- UART reports duty-cycle updates.
- PWM polarity changes after every complete fade cycle.

---

# LED Behaviour

| Duty Cycle | LED Behaviour |
|------------|---------------|
|0%|OFF|
|10%|Very Dim|
|25%|Dim|
|50%|Medium Brightness|
|75%|Bright|
|100%|Fully ON|

---

# Error Conditions

| Condition | Behaviour |
|-----------|-----------|
|PERIOD = 0|Invalid configuration|
|DUTY = 0|Output remains LOW|
|DUTY ≥ PERIOD|Output remains HIGH|
|PWM Disabled|Output inactive|
|Incorrect UART Configuration|No terminal output|

---

# Verification Summary

The software demonstrates

- Register programming
- Memory-mapped communication
- PWM generation
- Runtime duty-cycle updates
- STATUS monitoring
- UART communication
- LED brightness control
- Active-High and Active-Low operation

---

# Related Documentation

```
docs/
├── README.md
├── IP_User_Guide.md
├── Register_Map.md
├── Integration_Guide.md
└── Example_Usage.md
```

---

# Conclusion

The supplied software provides a complete reference implementation for operating the PWM IP on the VSDSquadron RISC-V SoC. It demonstrates initialization, runtime configuration, duty-cycle modulation, polarity control, UART status reporting, and FPGA validation, making it a practical starting point for integrating the PWM peripheral into embedded applications.
