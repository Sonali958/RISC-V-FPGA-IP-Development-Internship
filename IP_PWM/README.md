# PWM IP for VSDSquadron RISC-V SoC

![Platform](https://img.shields.io/badge/Platform-VSDSquadron%20FPGA-blue)
![Language](https://img.shields.io/badge/Language-Verilog-orange)
![Interface](https://img.shields.io/badge/Interface-Memory--Mapped-success)
![Status](https://img.shields.io/badge/Validation-Simulation%20%26%20FPGA-brightgreen)

---

## Overview

The PWM (Pulse Width Modulation) IP is a memory-mapped peripheral developed for the VSDSquadron RISC-V SoC.

It provides software-controlled generation of PWM signals through a simple 32-bit register interface and is suitable for applications such as LED dimming, motor speed control, and general-purpose waveform generation.

The IP has been validated through RTL simulation, software verification, and FPGA hardware testing.

---

# Features

- 32-bit Memory-Mapped Register Interface
- Programmable PWM Period
- Programmable Duty Cycle
- PWM Enable/Disable Control
- Output Polarity Selection
- STATUS Register for Runtime Monitoring
- Register Read/Write Support
- Software Controlled Operation
- GTKWave Simulation Verified
- FPGA Hardware Validated

---

# Repository Structure

```text
ip/
└── pwm/
    ├── rtl/
    ├── software/
    ├── docs/
    └── README.md
```

---

# Quick Integration

The PWM IP is integrated into the VSDSquadron SoC as a memory-mapped peripheral.

### Integration Steps 

1. Copy `pwm.v` into the RTL project.
2. Instantiate the PWM module inside `riscv.v`.
3. Connect the memory-mapped bus interface.
4. Assign the PWM base address.
5. Connect `pwm_out` to the FPGA top-level.
6. Update FPGA constraints.
7. Compile the software.
8. Program the FPGA.
9. Execute `pwm_test.c`.

Detailed integration instructions are available in:

**docs/Integration_Guide.md**

---

# Register Summary

| Offset | Register | Access | Description |
|---------|----------|:------:|-------------|
| 0x00 | CTRL | R/W | Enable and Polarity Control |
| 0x04 | PERIOD | R/W | PWM Period |
| 0x08 | DUTY | R/W | PWM High Time |
| 0x0C | STATUS | R | Running Status and Counter |

Complete register documentation is available in:

**docs/Register_Map.md**

---

# Software Example

The repository includes a ready-to-run software application:

```
software/
└── pwm_test.c
```

The software demonstrates:

- Peripheral Initialization
- Register Configuration
- Register Verification
- Status Monitoring
- Boundary Testing
- Counter Monitoring
- UART Reporting

Software documentation is available in:

**software/Software_Guide.md**

---

# Validation

The PWM IP has been successfully validated through:

- RTL Simulation (Icarus Verilog, VVP, GTKWave)
- Software Validation on the RISC-V processor
- FPGA Hardware Demonstration on the VSDSquadron FPGA

Simulation waveforms:

➡ **[Waveforms](software/waveforms/)**


FPGA validation images:

➡ **[FPGA Validation](software/FPGA_validation/)**


---

# Documentation

| Document | Description |
|----------|-------------|
| [IP_User_Guide.md](Docs/IP_User_Guide.md) | Complete user manual for the PWM IP |
| [Register_Map.md](Docs/Register_Map.md) | Register descriptions, bit fields, and reset values |
| [Integration_Guide.md](Docs/Integration_Guide.md) | Instructions for integrating the IP into the VSDSquadron SoC |
| [Example_Usage.md](Docs/Example_Usage.md) | Software examples, simulation results, FPGA validation, and expected outputs |
| [Software_Guide.md](Software/Software_Guide.md) | Software compilation, execution, and validation guide |

---

# How to Test

### RTL Simulation

Run the simulation using:

```bash
iverilog -o pwm_sim tb_pwm.v pwm.v
vvp pwm_sim
gtkwave pwm.vcd
```

Observe:

- Register transactions
- Counter operation
- PWM waveform
- Output behaviour

---

### FPGA Demonstration

1. Program the FPGA.
2. Load the compiled software.
3. Open the UART terminal.
4. Execute the software.
5. Observe LED brightness.
6. Verify UART output.

Expected result:

```
PASS : 10
FAIL : 0

PWM VERIFIED
```

---

# Known Limitations

Current implementation limitations include:

- Single PWM channel
- No interrupt support
- No prescaler
- Frequency depends on the system clock

These limitations were intentionally kept to maintain a compact and reusable educational IP.

---

# Applications

Typical applications include:

- LED Brightness Control
- Servo Motor Control
- DC Motor Speed Control
- Digital Power Electronics
- Embedded Systems
- FPGA-Based Learning Projects

---

# Conclusion

The PWM IP provides a reusable, configurable, and memory-mapped PWM peripheral for the VSDSquadron RISC-V SoC. Through its programmable register interface, software can configure PWM period, duty cycle, polarity, and runtime control without modifying the hardware implementation.

The IP has been successfully verified through RTL simulation, software validation, and FPGA hardware testing, making it a reliable plug-and-play peripheral for FPGA-based embedded systems.
