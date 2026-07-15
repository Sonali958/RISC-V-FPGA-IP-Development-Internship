# PWM IP User Guide

# Pulse Width Modulation (PWM) IP

**Version:** 1.0

**Author:** Sonali

**Target Platform:** VSDSquadron FPGA SoC

**Bus Interface:** 32-bit Memory-Mapped Register Interface

---

# Table of Contents

1. Introduction
2. IP Overview
3. Feature Summary
4. Applications
5. System Architecture
6. Functional Description
7. Register Interface
8. Software Programming Model
9. Board-Level Usage
10. Validation
11. Known Limitations
12. Future Improvements
13. Related Documents

---

# 1. Introduction

The PWM (Pulse Width Modulation) IP is a reusable hardware peripheral designed for the VSDSquadron RISC-V SoC. It generates a programmable PWM waveform by varying the duty cycle while maintaining a configurable output period.

The peripheral is fully memory-mapped, allowing software running on the RISC-V processor to configure PWM parameters through simple register accesses without modifying the hardware implementation.

The IP is intended to be modular, reusable, and easy to integrate into FPGA-based System-on-Chip designs.

---

# 2. IP Overview

## Purpose

The PWM IP generates a programmable pulse-width modulated signal suitable for applications requiring adjustable output power or brightness.

The peripheral is configured entirely through software by writing to memory-mapped control registers.

---

## Typical Use Cases

- LED Brightness Control
- Servo Motor Control
- DC Motor Speed Control
- Audio Tone Generation
- Power Electronics
- FPGA Learning Projects
- Embedded Control Systems

---

## Why Use This IP?

The PWM peripheral provides:

- Memory-mapped software interface
- Programmable period and duty cycle
- Runtime duty-cycle updates
- Output polarity control
- Compact RTL implementation
- Easy integration into the VSDSquadron SoC
- Low FPGA resource utilization

---

# 3. Feature Summary

| Feature | Description |
|----------|-------------|
| PWM Channels | 1 |
| Register Width | 32-bit |
| Bus Interface | Memory-Mapped |
| Period Control | Supported |
| Duty Cycle Control | Supported |
| Enable / Disable | Supported |
| Polarity Inversion | Supported |
| Status Register | Supported |
| Counter Monitoring | Supported |
| Clock Source | System Clock |
| FPGA Target | VSDSquadron FPGA |

---

# 4. System Architecture

```
                   CPU
                    │
          Memory-Mapped Bus
                    │
           Address Decoder
                    │
           +----------------+
           |    PWM IP Core |
           +----------------+
             │     │      │
      Registers Counter PWM Logic
                    │
                 pwm_out
                    │
               LED / GPIO
```

---

# 5. Functional Description

The PWM IP generates its output waveform by comparing an internal counter with the programmed duty-cycle value.

The internal counter continuously increments from **0** to **PERIOD − 1**.

When

```
Counter < DUTY
```

the PWM output remains HIGH.

Otherwise,

```
Counter ≥ DUTY
```

the output becomes LOW.

After reaching the programmed period, the counter wraps back to zero and the process repeats continuously while the PWM is enabled.

If the polarity bit is enabled, the generated waveform is inverted before driving the output pin.

---

## PWM Generation

```
Counter

0 --------------------------> PERIOD-1

Counter < DUTY

████████░░░░░░░░
 HIGH      LOW
```

Changing the DUTY register changes the pulse width without modifying the output frequency.

---

# 6. Register Interface

The PWM peripheral exposes four memory-mapped registers.

| Offset | Register | Description |
|---------|----------|-------------|
|0x00|CTRL|Enable and Polarity Control|
|0x04|PERIOD|PWM Period|
|0x08|DUTY|PWM High Time|
|0x0C|STATUS|Running Status and Counter|

Detailed register descriptions, bit fields, reset values, and read/write behavior are available in **Register_Map.md**.

---

# 7. Software Programming Model

The peripheral is configured entirely through software.

A typical initialization sequence is shown below.

### Step 1

Configure the PWM period.

```c
IO_OUT(REG_PWM_PERIOD_VAL,100);
```

---

### Step 2

Configure the duty cycle.

```c
IO_OUT(REG_PWM_DUTY_VAL,50);
```

---

### Step 3

Enable the PWM peripheral.

```c
IO_OUT(REG_PWM_CONTROL,1);
```

---

### Step 4

Read the status register (optional).

```c
status = IO_IN(REG_PWM_STATUS);
```

---

## Software Flow

```
Start

   │

   ▼

Configure PERIOD

   │

   ▼

Configure DUTY

   │

   ▼

Configure POL (Optional)

   │

   ▼

Enable PWM

   │

   ▼

Read STATUS

   │

   ▼

Update DUTY (Runtime)

   │

   ▼

PWM Running
```

The supplied demonstration firmware continuously varies the duty cycle to create a smooth LED fading effect and periodically switches the PWM output polarity.

---

# 8. Board-Level Usage

The PWM output signal

```
pwm_out
```

may be connected to:

- On-board LED
- GPIO Header
- PMOD Connector
- External Oscilloscope
- Logic Analyzer

During hardware validation, the PWM output was connected to an on-board LED.

The firmware continuously updated the DUTY register, producing a smooth fade-in and fade-out effect.

Example LED behaviour:

| Duty Cycle | LED Behaviour |
|-------------|---------------|
|0%|OFF|
|25%|Dim|
|50%|Medium Brightness|
|75%|Bright|
|100%|Fully ON|

---

# 9. Validation

The PWM IP was validated through simulation, software execution, and FPGA implementation.

## RTL Simulation

Simulation verified:

- Register read operations
- Register write operations
- PWM counter functionality
- PWM waveform generation
- Enable/Disable control
- Polarity inversion
- Memory-mapped register interface

Waveforms were analyzed using GTKWave.

---

## Software Validation

The supplied firmware demonstrates:

- PWM initialization
- Register configuration
- STATUS register monitoring
- Continuous duty-cycle updates
- LED fade-in operation
- LED fade-out operation
- Runtime polarity switching
- Continuous PWM generation

UART output reports the current operating mode, programmed duty cycle, and status register values during execution.

---

## FPGA Validation

The complete SoC was synthesized and programmed onto the VSDSquadron FPGA board.

Observed hardware behaviour:

- PWM output generated successfully
- LED brightness varied smoothly with duty cycle
- UART displayed peripheral status information
- Active-High and Active-Low modes operated correctly
- Continuous operation confirmed stable hardware functionality

---

# 10. Known Limitations

Current implementation limitations include:

- Single PWM output channel
- No interrupt support
- No prescaler
- No dead-time insertion
- Frequency depends on the system clock
- No complementary PWM outputs
- Fixed 32-bit register interface

These design choices intentionally keep the peripheral compact and easy to understand.

---

# 11. Future Improvements

Potential future enhancements include:

- Multi-channel PWM
- Prescaler support
- Interrupt generation
- Capture mode
- Complementary PWM outputs
- Dead-time insertion
- DMA support
- Runtime frequency adjustment
- Hardware fault protection

---

# 12. Related Documents

This IP package includes:

- README.md
- Register_Map.md
- Integration_Guide.md
- Example_Usage.md

Together these documents provide complete information for integrating, programming, validating, and using the PWM IP on the VSDSquadron FPGA platform.

---

# Conclusion

The PWM IP provides a compact, configurable, and reusable pulse-width modulation peripheral for FPGA-based RISC-V SoC designs. Through its memory-mapped register interface, software can configure the PWM period, duty cycle, polarity, and enable control while monitoring runtime status. Successful validation through RTL simulation, software execution, and FPGA implementation demonstrates reliable operation, making the IP suitable for educational projects and as a foundation for more advanced PWM-based control systems.
