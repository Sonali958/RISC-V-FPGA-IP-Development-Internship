# Integration Guide

## PWM IP Integration Guide

**Version:** 1.0

**Target Platform:** VSDSquadron FPGA SoC

---

# Table of Contents

1. Introduction
2. Required Files
3. Integration Overview
4. RTL Integration
5. Memory-Mapped Interface
6. Register Address Map
7. Top-Level Signal Connections
8. FPGA Pin Connections
9. Constraint File
10. Software Integration
11. Build Flow
12. Integration Verification
13. Expected Operation
14. Integration Checklist

---

# 1. Introduction

This document describes the complete integration procedure for the PWM IP into the VSDSquadron RISC-V System-on-Chip.

The PWM peripheral is implemented as a memory-mapped hardware block that can be configured directly by software executing on the embedded RISC-V processor.

Integration consists of:

- Adding the PWM RTL
- Connecting the processor bus
- Allocating the register address space
- Connecting the PWM output
- Updating the FPGA constraints
- Programming the software

No modifications to the PWM RTL are required after integration.

---

# 2. Required Files

The following files are required.

```
rtl/
├── pwm.v
├── riscv.v
├── gpio.v
├── clockworks.v
├── emitter_uart.v
└── ...
```

Software files

```
software/
├── io.h
└── pwm_test.c
```

Constraint file

```
VSDSquadronFM.pcf
```

---

# 3. Integration Overview

```
                    +------------------+
                    |   RISC-V CPU     |
                    +--------+---------+
                             |
                      Memory Bus
                             |
                    Address Decoder
                             |
                +------------+-------------+
                |                          |
          Existing Peripherals         PWM Peripheral
                                           |
                     +---------------------+
                     |
               Register Interface
                     |
              PWM Counter Logic
                     |
                 PWM Generator
                     |
                  pwm_out
                     |
               FPGA LED / GPIO
```

The processor accesses the PWM peripheral through the memory-mapped bus. Register writes configure the PWM output, while register reads provide status information.

---

# 4. RTL Integration

Add `pwm.v` to the RTL project.

Instantiate the PWM module inside `riscv.v`.

Connect the following signals.

| PWM Signal | Connected To |
|------------|--------------|
|i_clk|System Clock|
|i_rst|System Reset|
|i_addr|Processor Address Bus|
|i_wdata|Processor Write Data|
|i_we|Processor Write Enable|
|o_rdata|Processor Read Data|
|o_pwm|Top-Level PWM Output|

Example:

```verilog
pwm pwm_unit(
    .i_clk(clk),
    .i_rst(reset),
    .i_addr(io_addr),
    .i_wdata(io_wdata),
    .i_we(io_we),
    .o_rdata(pwm_rdata),
    .o_pwm(pwm_out)
);
```

---

# 5. Memory-Mapped Interface

The PWM IP uses a standard 32-bit memory-mapped register interface.

Software communicates with the peripheral by reading and writing registers.

Undefined register addresses:

- Return zero during reads
- Ignore write operations

---

# 6. Register Address Map

| Offset | Register | Access | Description |
|---------|----------|--------|-------------|
|0x00|CTRL|R/W|Enable and Polarity|
|0x04|PERIOD|R/W|PWM Period|
|0x08|DUTY|R/W|PWM High Time|
|0x0C|STATUS|R|Running Status and Counter|

The detailed register definitions are provided in **Register_Map.md**.

---

# 7. Top-Level Signal Connections

Expose the PWM output from the SoC top-level.

```
PWM IP

   │

   ▼

pwm_out

   │

   ▼

Top Module

   │

   ▼

FPGA Pin
```

The PWM output may be connected to:

- On-board LED
- GPIO Header
- PMOD Connector
- External Oscilloscope
- Logic Analyzer

For hardware validation, the PWM output was connected to an on-board LED.

---

# 8. FPGA Pin Connections

Assign the PWM output signal to the desired FPGA output pin inside the constraint file.

Example

```
set_io PWM <pin_number>
```

For the VSDSquadron board, the PWM signal is mapped through the project constraint file (`VSDSquadronFM.pcf`).

---

# 9. Constraint File

Verify that the following signals are assigned correctly.

- Clock
- Reset
- UART TX
- UART RX
- PWM Output
- LEDs

Any modification to the PWM output pin only requires updating the constraint file.

---

# 10. Software Integration

The PWM peripheral is controlled through memory-mapped register accesses.

Example configuration

```c
IO_OUT(REG_PWM_CONTROL,0);

IO_OUT(REG_PWM_PERIOD_VAL,100);

IO_OUT(REG_PWM_DUTY_VAL,50);

IO_OUT(REG_PWM_CONTROL,1);
```

Typical programming sequence

1. Disable PWM
2. Configure PERIOD
3. Configure DUTY
4. Configure POL (optional)
5. Enable PWM
6. Read STATUS (optional)
7. Update DUTY during runtime

The supplied firmware demonstrates continuous duty-cycle variation together with runtime polarity switching.

---

# 11. Build Flow

Compile the software

```
make
```

Generate the FPGA bitstream

```
make build
```

Program the FPGA

```
make flash
```

Open the UART terminal

```
picocom -b 9600 /dev/ttyUSB0
```

Execute the PWM demonstration firmware.

---

# 12. Integration Verification

Successful integration can be verified using the following checks.

### RTL Simulation

- Register read/write verified
- PWM waveform generated
- Counter operation verified
- STATUS register updated

### FPGA Validation

- Bitstream programmed successfully
- UART output visible
- PWM output generated
- LED brightness changes smoothly
- Active-High mode verified
- Active-Low mode verified

---

# 13. Expected Operation

After programming the FPGA and loading the software:

- PWM starts after enabling CTRL.EN.
- LED brightness gradually increases.
- LED brightness gradually decreases.
- UART displays the programmed duty cycle.
- STATUS register reports the peripheral state.
- PWM polarity automatically switches after every complete fade cycle.
- The demonstration repeats continuously.

---

# 14. Integration Checklist

Before synthesis verify

- [ ] pwm.v added to RTL project
- [ ] PWM instantiated in riscv.v
- [ ] Address decoder connected
- [ ] Register interface connected
- [ ] STATUS connected to processor bus
- [ ] pwm_out connected to top-level
- [ ] Constraint file updated
- [ ] Software compiled
- [ ] FPGA programmed
- [ ] UART output verified
- [ ] LED fading demonstrated

---

# Conclusion

The PWM IP integrates into the VSDSquadron RISC-V SoC as a standard memory-mapped peripheral requiring only RTL instantiation, address decoding, and top-level signal connections. Once integrated, the supplied software configures the PWM registers to generate a continuously varying duty cycle with optional polarity inversion, demonstrating reliable operation through both UART output and LED brightness control on FPGA hardware.
