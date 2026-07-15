# PWM IP for VSDSquadron RISC-V SoC

![Platform](https://img.shields.io/badge/Platform-VSDSquadron%20FPGA-blue)
![Language](https://img.shields.io/badge/Language-Verilog-orange)
![Interface](https://img.shields.io/badge/Interface-Memory--Mapped-success)
![Validation](https://img.shields.io/badge/Validation-Simulation%20%7C%20FPGA-brightgreen)

---

# PWM IP Overview

The PWM (Pulse Width Modulation) IP is a single-channel, memory-mapped peripheral developed for the VSDSquadron RISC-V SoC.

It generates a programmable PWM signal that can be configured entirely through software using a 32-bit register interface.

The IP supports:

- Programmable Period
- Programmable Duty Cycle
- Enable/Disable Control
- Active-High / Active-Low Output
- Runtime Status Monitoring

Typical applications include LED dimming, motor control, waveform generation, and embedded FPGA projects.

---

# Repository Structure

```
ip/
└── pwm/
    ├── rtl/
    │   └── pwm.v
    │
    ├── software/
    │   ├── pwm_test.c
    │   ├── io.h
    │   └── Software_Guide.md
    │
    ├── docs/
    │   ├── IP_User_Guide.md
    │   ├── Register_Map.md
    │   ├── Integration_Guide.md
    │   └── Example_Usage.md
    │
    └── README.md
```

---

# Quick Integration

1. Copy `rtl/pwm.v` into the SoC RTL project.
2. Instantiate the PWM module inside `riscv.v`.
3. Connect the memory-mapped interface.
4. Connect the `pwm` output to the desired FPGA pin.
5. Add the PWM register address space.
6. Rebuild the SoC.

Detailed integration instructions are available in:

```
docs/Integration_Guide.md
```

---

# Documentation

| Document | Description |
|----------|-------------|
|IP_User_Guide.md|Complete IP description and programming model|
|Register_Map.md|Register definitions and bit fields|
|Integration_Guide.md|RTL and SoC integration procedure|
|Example_Usage.md|Simulation, software example and FPGA validation|
|Software_Guide.md|Firmware build and execution guide|

---

# How to Test

## RTL Simulation

```bash
iverilog -o pwm_sim tb_pwm.v pwm.v
vvp pwm_sim
gtkwave pwm.vcd
```

Verify:

- Register transactions
- PWM waveform
- Counter operation
- STATUS register

---

## FPGA Validation

1. Build the complete SoC.
2. Program the VSDSquadron FPGA.
3. Load the reference firmware (`pwm_test.c`).
4. Open the UART terminal.
5. Observe LED brightness changes.
6. Verify UART status messages.

Expected behaviour:

- PWM output is generated.
- LED fades smoothly as the duty cycle changes.
- STATUS register reflects peripheral activity.
- Active-High and Active-Low modes operate correctly.

---

# Validation Status

- ✅ RTL Simulation Verified
- ✅ GTKWave Waveform Verified
- ✅ Software Demonstration Verified
- ✅ FPGA Hardware Validated

---

# License

Developed as part of the VSDSquadron RISC-V SoC IP Development program for educational and FPGA prototyping purposes.
