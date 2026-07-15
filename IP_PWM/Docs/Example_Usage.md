# Example Usage

## Overview

This document demonstrates how to configure, execute, and validate the PWM IP integrated into the VSDSquadron RISC-V SoC.

The PWM peripheral is controlled through memory-mapped registers. Software configures the PWM period, duty cycle, and output polarity while the hardware continuously generates the corresponding PWM waveform.

The supplied software (`pwm_test.c`) demonstrates practical usage of the PWM IP by creating a smooth LED fade effect, monitoring the peripheral status through UART, and switching between Active-High and Active-Low output modes.

---

# Hardware Requirements

- VSDSquadron FPGA Board
- Integrated RISC-V SoC
- PWM IP
- On-board LED
- USB-UART Adapter (CH340)
- UART Terminal (Picocom/Minicom)

---

# Software Requirements

- RISC-V GCC Toolchain
- Make
- Icarus Verilog
- GTKWave

---

# Directory Structure

```
software/
├── io.h
└── pwm_test.c
```

---

# Register Programming Sequence

The PWM peripheral is initialized using the following sequence.

```
Reset PWM
      │
      ▼
Configure PERIOD Register
      │
      ▼
Configure DUTY Register
      │
      ▼
Enable PWM
      │
      ▼
Read STATUS Register
      │
      ▼
Update Duty Cycle
      │
      ▼
Disable PWM
      │
      ▼
Switch PWM Polarity
      │
      ▼
Repeat
```

---

# Basic Example

```c
IO_OUT(REG_PWM_CONTROL,0);

IO_OUT(REG_PWM_PERIOD_VAL,100);
IO_OUT(REG_PWM_DUTY_VAL,50);

IO_OUT(REG_PWM_CONTROL,1);
```

This configuration produces

- PWM Enabled
- Period = 100 clock cycles
- Duty Cycle = 50%
- Active-High Output

---

# Complete Example Software

```c
#include "io.h"
#include "uart.h"

void delay(unsigned int t)
{
    while(t--)
    {
        asm volatile("nop");
    }
}

int main(void)
{
    uint32_t status;
    int polarity = 0;

    uart_printf("\n");
    uart_printf("=====================================\n");
    uart_printf("        PWM IP SOFTWARE TEST\n");
    uart_printf("=====================================\n");

    while(1)
    {
        IO_OUT(REG_PWM_CONTROL,0);

        IO_OUT(REG_PWM_PERIOD_VAL,100);
        IO_OUT(REG_PWM_DUTY_VAL,0);

        IO_OUT(REG_PWM_CONTROL,(polarity<<1)|1);

        status = IO_IN(REG_PWM_STATUS);

        uart_printf("\n---------------------------------\n");
        uart_printf("PWM ENABLED\n");
        uart_printf("Mode   : %s\n",
               polarity ? "ACTIVE LOW" : "ACTIVE HIGH");
        uart_printf("Period : %d\n",100);
        uart_printf("Status : 0x%x\n",status);

        uart_printf("\n---------------------------------\n");
        uart_printf("\nIncreasing Duty Cycle\n");
        uart_printf("\n---------------------------------\n");

        for(int duty=0; duty<=100; duty+=10)
        {
            IO_OUT(REG_PWM_DUTY_VAL,duty);

            status = IO_IN(REG_PWM_STATUS);

            uart_printf("Duty = %d   Status = 0x%x\n",
                    duty,
                    status);

            delay(50000);
        }

        uart_printf("\n---------------------------------\n");
        uart_printf("\nDecreasing Duty Cycle\n");
        uart_printf("\n---------------------------------\n");

        for(int duty=100; duty>=0; duty-=10)
        {
            IO_OUT(REG_PWM_DUTY_VAL,duty);

            status = IO_IN(REG_PWM_STATUS);

            uart_printf("Duty = %d   Status = 0x%x\n",
                    duty,
                    status);

            delay(50000);
        }

        IO_OUT(REG_PWM_CONTROL,0);

        status = IO_IN(REG_PWM_STATUS);

        uart_printf("\nPWM DISABLED\n");
        uart_printf("Status : 0x%x\n",status);

        delay(300000);

        polarity ^= 1;

        uart_printf("\nSwitching PWM Polarity...\n");
    }

    return 0;
}
```

---

# Software Flow

The demonstration software performs the following sequence.

| Step | Description |
|------|-------------|
|1|Disable PWM before configuration|
|2|Program PERIOD register|
|3|Program DUTY register|
|4|Enable PWM|
|5|Read STATUS register|
|6|Increase duty cycle from 0% to 100%|
|7|Decrease duty cycle from 100% to 0%|
|8|Disable PWM|
|9|Switch PWM polarity|
|10|Repeat continuously|

---

# Simulation Validation

The PWM IP was first verified through RTL simulation before FPGA implementation.

## Simulation Flow

```bash
iverilog -o pwm_sim tb_pwm.v pwm.v
vvp pwm_sim
gtkwave pwm.vcd
```

Simulation verifies:

- Correct register write operations
- Correct register read operations
- Proper PWM counter operation
- PWM waveform generation
- Status register updates
- Memory-mapped interface functionality

---

# Waveform Analysis

The GTKWave waveform confirms correct operation of the PWM peripheral.

## Clock Operation

The system clock continuously drives the PWM counter and register interface.

---

## Register Writes

Software writes to the CTRL, PERIOD, and DUTY registers through the memory-mapped bus. The internal registers update correctly after each write transaction.

---

## Register Reads

The STATUS register reflects the current enable state together with the running PWM counter, allowing software to monitor peripheral activity.

---

## PWM Counter

The internal counter increments continuously from 0 to PERIOD−1 before wrapping back to zero.

---

## PWM Output Generation

Once the PWM is enabled, the output waveform is generated according to the programmed duty cycle.

As the DUTY register increases, the HIGH portion of the waveform becomes wider. Reducing the DUTY register shortens the HIGH pulse width.

---

## Polarity Control

Changing the POL bit in the CTRL register inverts the PWM output, allowing both Active-High and Active-Low operation without modifying external hardware.

---

# FPGA Validation

After successful simulation, the complete SoC was synthesized and programmed onto the VSDSquadron FPGA.

## Hardware Setup

```
PWM IP
   │
   ▼
pwm_out
   │
   ▼
On-board LED

UART
   │
   ▼
USB-UART Adapter
   │
   ▼
PC Terminal
```

---

# FPGA Test Procedure

1. Build the complete SoC.
2. Generate the FPGA bitstream.
3. Program the VSDSquadron FPGA.
4. Load the compiled firmware.
5. Connect the UART terminal.
6. Execute the PWM demonstration.
7. Observe the LED brightness and UART output.

---

# UART Output

Example terminal output:

```text
=====================================
        PWM IP SOFTWARE TEST
=====================================

PWM ENABLED

Mode   : ACTIVE HIGH
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
Duty = 90
...
Duty = 0

PWM DISABLED

Switching PWM Polarity...
```

The same sequence repeats after changing the PWM polarity.

---

# LED Behaviour

| Duty Cycle | LED Behaviour |
|------------|---------------|
|0%|LED OFF|
|10%|Very Dim|
|25%|Dim|
|50%|Medium Brightness|
|75%|Bright|
|100%|Fully ON|

The LED smoothly fades in and fades out as the duty cycle changes.

---

# Expected Results

| Verification | Expected Result |
|--------------|-----------------|
|PWM Enable|PASS|
|Register Programming|PASS|
|Status Readback|PASS|
|Duty Cycle Update|PASS|
|LED Brightness Control|PASS|
|UART Output|PASS|
|Polarity Switching|PASS|
|Continuous PWM Generation|PASS|

---

# Troubleshooting

| Problem | Possible Cause | Solution |
|----------|----------------|----------|
|LED remains OFF|PWM not enabled|Enable CTRL register|
|LED always ON|Duty ≥ Period|Reduce DUTY value|
|Brightness not changing|Incorrect DUTY updates|Verify software writes|
|No UART output|Firmware not loaded|Reload firmware|
|No waveform|Simulation not executed|Generate VCD and open in GTKWave|

---

# Conclusion

The supplied firmware demonstrates complete operation of the PWM IP on the VSDSquadron RISC-V SoC. Through memory-mapped register programming, software dynamically adjusts the PWM duty cycle, producing a smooth LED fading effect while continuously reporting peripheral status over UART. RTL simulation confirms correct register transactions and waveform generation, and FPGA validation verifies reliable operation on hardware, making this example a practical reference for integrating and evaluating the PWM IP.
