# PWM IP User Guide

# Pulse Width Modulation (PWM) IP

**Version:** 1.0

**Author:** Sonali

**Target Platform:** VSDSquadron FPGA SoC

**Bus Interface:** Memory-Mapped 32-bit Register Interface

---

# Table of Contents

1. Introduction
2. IP Overview
3. Features
4. Applications
5. System Architecture
6. Functional Description
7. Register Interface
8. Software Programming Model
9. Board-Level Usage
10. Validation
11. Known Limitations
12. Future Improvements

---

# 1. Introduction

The PWM (Pulse Width Modulation) IP is a reusable hardware peripheral designed for the VSDSquadron RISC-V SoC. It generates a configurable PWM waveform by varying the ratio of HIGH and LOW durations while maintaining a programmable period.

The peripheral is memory mapped, allowing software running on the RISC-V processor to configure and control the PWM output through simple register accesses.

This IP has been designed with modularity, readability, and portability in mind, enabling straightforward integration into FPGA-based SoC designs.

---

# 2. IP Overview

## Purpose

The purpose of this IP is to generate a programmable PWM signal suitable for controlling external devices requiring variable duty cycles.

Software configures the peripheral by writing to memory-mapped registers without modifying the hardware implementation.

---

## Typical Use Cases

- LED Brightness Control
- Servo Motor Positioning
- DC Motor Speed Control
- Audio Signal Generation
- Power Electronics
- Digital Control Systems
- FPGA Learning Projects

---

## Why Use This IP?

This PWM peripheral provides:

- Simple software-controlled operation
- Fully memory-mapped register interface
- Easy integration into VSDSquadron SoC
- Low hardware resource utilization
- Real-time duty cycle updates
- Reusable and modular RTL implementation

---

# 3. Feature Summary

| Feature | Description |
|----------|-------------|
| Channels | Single PWM Output |
| Bus Width | 32-bit |
| Register Interface | Memory-Mapped |
| Period Control | Supported |
| Duty Cycle Control | Supported |
| Enable/Disable | Supported |
| Polarity Inversion | Supported |
| Status Register | Supported |
| Counter Monitoring | Supported |
| Clock | System Clock |
| FPGA Compatible | VSDSquadron FPGA |

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
          |   PWM IP Core  |
          +----------------+
           │      │      │
      Registers Counter PWM Logic
                   │
               pwm_out
                   │
             LED / GPIO Pin
```

---

# 5. Functional Description

The PWM IP generates a pulse-width modulated signal by comparing an internal counter with a programmable duty-cycle value.

The counter continuously increments from zero to the configured PERIOD value.

If

```
Counter < DUTY
```

the PWM output remains HIGH.

Otherwise,

```
Counter ≥ DUTY
```

the PWM output becomes LOW.

The sequence repeats continuously while the PWM is enabled.

If polarity inversion is enabled, the generated waveform is inverted before reaching the output.

---

# PWM Generation

```
Counter

0 -----------------------> PERIOD-1

          Counter < DUTY

HIGH HIGH HIGH HIGH LOW LOW LOW LOW
```

---

# 6. Register Interface

The PWM peripheral exposes four memory-mapped registers.

| Offset | Register | Description |
|---------|----------|-------------|
|0x00|CTRL|Enable and Polarity Control|
|0x04|PERIOD|PWM Period|
|0x08|DUTY|PWM High Time|
|0x0C|STATUS|Running Status and Counter|

A detailed description of every register is available in **Register_Map.md**.

---

# 7. Software Programming Model

The peripheral is entirely software configurable.

A typical initialization sequence is shown below.

### Step 1

Configure the PWM period.

```c
IO_OUT(IO_PWM_PERIOD,100);
```

---

### Step 2

Configure the duty cycle.

```c
IO_OUT(IO_PWM_DUTY,50);
```

---

### Step 3

Enable PWM.

```c
IO_OUT(IO_PWM_CTRL,1);
```

---

### Step 4

Optionally monitor the STATUS register.

```c
status = IO_IN(IO_PWM_STATUS);
```

---

# Software Flow

```
Start

↓

Configure PERIOD

↓

Configure DUTY

↓

Configure POL (Optional)

↓

Enable PWM

↓

Monitor STATUS

↓

PWM Running
```

---

# 8. Board-Level Usage

The PWM output is exposed as

```
pwm_out
```

The signal may be connected to:

- On-board LED
- GPIO Header
- PMOD Connector
- External Oscilloscope
- Logic Analyzer

During hardware validation, the PWM output was connected to an on-board LED.

Changing the DUTY register changed the LED brightness.

Example

| Duty | LED Brightness |
|------|----------------|
|0%|OFF|
|25%|Dim|
|50%|Medium|
|75%|Bright|
|100%|Fully ON|

---

# 9. Validation

The PWM IP was validated through multiple stages.

## Functional Simulation

Verified:

- Register Read/Write
- Counter Operation
- PWM Waveform
- Enable/Disable Logic
- Duty Cycle Operation
- Boundary Conditions

Waveforms were inspected using GTKWave.

---

## Software Validation

The supplied software performs:

- Default Register Verification
- Register Read/Write Tests
- Enable Verification
- Status Verification
- Boundary Tests
- Counter Monitoring
- Disable Verification

All software tests completed successfully.

---

## FPGA Validation

Hardware validation was performed on the VSDSquadron FPGA board.

Observed behavior:

- PWM output generated successfully.
- LED brightness varied according to DUTY value.
- UART displayed successful execution of all software tests.

---

# 10. Known Limitations

Current implementation limitations include:

- Single PWM output channel
- No interrupt generation
- No prescaler support
- No dead-time insertion
- Frequency depends on the system clock
- No complementary PWM outputs
- Fixed 32-bit register interface

These limitations were intentionally kept to maintain a simple and educational implementation.

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
- Runtime frequency measurement
- Hardware fault protection

---

# 12. Related Documents

This IP package includes:

- **README.md**
- **Register_Map.md**
- **Integration_Guide.md**
- **Example_Usage.md**

Together, these documents provide complete information for integrating, programming, and validating the PWM IP on the VSDSquadron FPGA platform.

---

# Conclusion

The PWM IP provides a compact, configurable, and reusable pulse-width modulation peripheral for FPGA-based RISC-V SoC designs. Through its memory-mapped register interface, software can easily configure PWM parameters such as period, duty cycle, polarity, and enable control. Its modular design, comprehensive documentation, and successful validation on both simulation and FPGA hardware make it suitable for educational projects and as a foundation for more advanced PWM-based control systems.
