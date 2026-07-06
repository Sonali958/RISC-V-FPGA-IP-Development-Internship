# Integration Guide

## 1. Introduction

This document explains how to integrate the PWM IP into the VSDSquadron RISC-V SoC. The PWM IP is designed as a memory-mapped peripheral that can be controlled directly by software executing on the RISC-V processor.

The integration process includes:

- Adding the RTL source
- Instantiating the PWM module
- Connecting the memory-mapped bus
- Assigning the register address space
- Routing the PWM output
- Verifying correct operation

---

# 2. Required RTL Files

The following RTL file is required.

```
rtl/
└── pwm.v
```

The remaining SoC files already exist in the VSDSquadron project.

Typical project structure:

```
rtl/
├── riscv.v
├── gpio.v
├── clockworks.v
├── emitter_uart.v
├── memory.v
├── pwm.v
└── ...
```

---

# 3. Integration Architecture

```
                  +-------------------+
                  |    RISC-V CPU     |
                  +---------+---------+
                            |
                     Memory Bus
                            |
                   Address Decoder
                            |
               +------------+-------------+
               |                          |
         Existing Peripherals         PWM Peripheral
                                           |
                    +----------------------+----------------+
                    |                                       |
              Register Interface                    PWM Generator
                    |                                       |
                    +----------------------+----------------+
                                           |
                                       pwm_out
                                           |
                                  FPGA LED / GPIO
```

---

# 4. Instantiating the PWM IP

Instantiate the PWM module inside the SoC top-level module (`riscv.v`).

The PWM module should be connected to:

- System clock
- Reset
- Memory address bus
- Write data bus
- Read data bus
- Read enable
- Write enable
- PWM output

Example:

```verilog
pwm pwm_inst(
    .clk(clk),
    .reset(reset),
    ...
    .pwm_out(pwm_out)
);
```

---

# 5. Memory-Mapped Address Integration

Allocate a dedicated address region for the PWM peripheral.

Example register layout:

| Offset | Register |
|---------|----------|
|0x00|CTRL|
|0x04|PERIOD|
|0x08|DUTY|
|0x0C|STATUS|

The address decoder should generate read and write enable signals whenever an address falls within the PWM register space.

Undefined offsets should:

- Return zero on reads
- Ignore writes

---

# 6. Bus Interface Connections

The PWM peripheral communicates through a standard memory-mapped register interface.

| Signal | Direction | Description |
|---------|-----------|-------------|
|clk|Input|System clock|
|reset|Input|System reset|
|addr|Input|Register address|
|wdata|Input|Write data|
|rdata|Output|Read data|
|write_enable|Input|Write enable|
|read_enable|Input|Read enable|
|pwm_out|Output|PWM signal|

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

---

# 8. FPGA Pin Connections

The PWM output should be connected to one of the available FPGA output pins.

Example:

```
pwm_out
      │
      ▼
LED0
```

The output may also be routed to:

- GPIO Header
- PMOD Connector
- External Oscilloscope
- Logic Analyzer

---

# 9. Constraint File

Connect the PWM output to the desired FPGA pin inside the constraint file.

Example:

```
set_io pwm_out <LED_PIN>
```

Replace `<LED_PIN>` with the appropriate board pin according to the VSDSquadron FPGA documentation.

---

# 10. Software Access

The peripheral is accessed using memory-mapped I/O.

Example:

```c
IO_OUT(IO_PWM_PERIOD,100);
IO_OUT(IO_PWM_DUTY,50);
IO_OUT(IO_PWM_CTRL,1);
```

Software typically performs the following sequence:

1. Configure PERIOD.
2. Configure DUTY.
3. Configure polarity if required.
4. Enable PWM.
5. Read STATUS for monitoring.

---

# 11. Integration Checklist

Before synthesis, verify:

- [ ] pwm.v added to RTL project
- [ ] PWM instantiated in riscv.v
- [ ] Address decoding added
- [ ] Register interface connected
- [ ] Read/write paths verified
- [ ] pwm_out connected to top module
- [ ] FPGA constraints updated
- [ ] Software compiled successfully

---

# 12. Integration Verification

After integration:

- Compile the RTL design.
- Run simulation.
- Verify the PWM waveform using GTKWave.
- Compile the RISC-V software.
- Program the VSDSquadron FPGA.
- Execute the PWM software test.
- Observe LED brightness changes.
- Verify UART output indicates successful execution.

---

# 13. Expected Integration Result

A successful integration will provide:

- Accessible PWM control registers
- Correct register read/write operations
- Functional PWM waveform
- Software-controlled duty cycle adjustment
- LED brightness variation on the FPGA board
- Successful completion of the software validation program
