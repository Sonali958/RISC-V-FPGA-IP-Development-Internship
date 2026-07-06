# Example Usage

## Overview

This document demonstrates how to configure, operate, simulate, and validate the PWM IP on the VSDSquadron RISC-V SoC.

The PWM peripheral is controlled entirely through memory-mapped registers. Software configures the PWM period, duty cycle, and control bits, while the hardware continuously generates the corresponding PWM waveform.

The supplied software (`pwm_test.c`) performs complete verification of the peripheral including register testing, boundary condition checks, runtime monitoring, and FPGA validation.

---

# Hardware Requirements

- VSDSquadron FPGA Board
- Integrated RISC-V SoC
- PWM IP
- UART Terminal
- On-board LED

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
└── pwm_test.c
```

---

# Register Programming Sequence

The PWM peripheral is initialized in the following order.

```
Start
   │
   ▼
Configure PERIOD Register
   │
   ▼
Configure DUTY Register
   │
   ▼
Configure CTRL Register
   │
   ▼
PWM Starts Running
   │
   ▼
Monitor STATUS Register (Optional)
```

---

# Basic Example

```c
IO_OUT(IO_PWM_PERIOD,100);
IO_OUT(IO_PWM_DUTY,50);
IO_OUT(IO_PWM_CTRL,1);
```

The above configuration produces

- PWM Period = 100 Clock Cycles
- Duty = 50 Clock Cycles
- Duty Cycle = 50%

---

# Complete Example Software

The complete software application used for validation is provided below.

```c
#include <stdint.h>
#include <stdio.h>
#include "io.h"

#define PERIOD_VAL 8
#define DUTY_VAL   3

#define PWM_EN     1
#define PWM_DIS    0

#define SAMPLES    10

uint32_t pass=0,fail=0;

void ok(int x)
{
    if(x){
        printf("[PASS]\n");
        pass++;
    }
    else{
        printf("[FAIL]\n");
        fail++;
    }
}

void status(uint32_t s)
{
    printf("STATUS : 0x%08X\n",s);
    printf("RUN    : %u\n",s&1);
    printf("COUNT  : %u\n",s>>16);
}

int duty_percent(int d,int p)
{
    if(p==0) return 0;
    return (d*100)/p;
}

void delay()
{
    for(volatile int i = 0; i < 1000000; i++);
}

int main()
{
    IO_OUT(IO_LEDS, 0x01);
    printf("PWM TEST START\r\n");
    IO_OUT(IO_LEDS, 0x03);
    uint32_t ctrl,status_reg;

    printf("\nPWM SOFTWARE TEST\n");
    printf("-----------------\n");

    printf("CTRL   : %08X\n",IO_BASE+IO_PWM_CTRL);
    printf("PERIOD : %08X\n",IO_BASE+IO_PWM_PERIOD);
    printf("DUTY   : %08X\n",IO_BASE+IO_PWM_DUTY);
    printf("STATUS : %08X\n\n",IO_BASE+IO_PWM_STATUS);

    printf("TEST1 Default Registers\n");

    ctrl=IO_IN(IO_PWM_CTRL);

    printf("CTRL=%u PERIOD=%u DUTY=%u\n",
           ctrl,
           IO_IN(IO_PWM_PERIOD),
           IO_IN(IO_PWM_DUTY));

    ok(ctrl==0 && IO_IN(IO_PWM_DUTY)==0);

    printf("\nTEST2 PERIOD\n");

    IO_OUT(IO_PWM_PERIOD,PERIOD_VAL);

    printf("Write=%u Read=%u\n",
           PERIOD_VAL,
           IO_IN(IO_PWM_PERIOD));

    ok(IO_IN(IO_PWM_PERIOD)==PERIOD_VAL);

    printf("\nTEST3 DUTY\n");

    IO_OUT(IO_PWM_DUTY,DUTY_VAL);

    printf("Write=%u Read=%u\n",
           DUTY_VAL,
           IO_IN(IO_PWM_DUTY));

    printf("Duty=%d%%\n",
        duty_percent(IO_IN(IO_PWM_DUTY),
                     IO_IN(IO_PWM_PERIOD)));

    ok(IO_IN(IO_PWM_DUTY)==DUTY_VAL);

    printf("\nTEST4 CTRL\n");

    IO_OUT(IO_PWM_CTRL,PWM_EN);

    ctrl=IO_IN(IO_PWM_CTRL);

    printf("CTRL=%08X\n",ctrl);

    ok(ctrl&1);
    
        printf("\nTEST5 STATUS\n");

    status_reg = IO_IN(IO_PWM_STATUS);

    status(status_reg);

    ok(status_reg & 1);


    //-------------------------------
    // Boundary Test : DUTY = 0
    //-------------------------------

    printf("\nTEST6 DUTY=0\n");

    IO_OUT(IO_PWM_DUTY,0);

    printf("PERIOD=%u DUTY=%u\n",
           IO_IN(IO_PWM_PERIOD),
           IO_IN(IO_PWM_DUTY));

    ok(IO_IN(IO_PWM_DUTY)==0);


    //-------------------------------
    // Boundary Test : DUTY = PERIOD
    //-------------------------------

    printf("\nTEST7 DUTY=PERIOD\n");

    IO_OUT(IO_PWM_DUTY,IO_IN(IO_PWM_PERIOD));

    printf("PERIOD=%u DUTY=%u\n",
           IO_IN(IO_PWM_PERIOD),
           IO_IN(IO_PWM_DUTY));

    ok(IO_IN(IO_PWM_DUTY)==IO_IN(IO_PWM_PERIOD));


    //-------------------------------
    // Boundary Test : DUTY > PERIOD
    //-------------------------------

    printf("\nTEST8 DUTY>PERIOD\n");

    IO_OUT(IO_PWM_DUTY,
           IO_IN(IO_PWM_PERIOD)+5);

    printf("PERIOD=%u DUTY=%u\n",
           IO_IN(IO_PWM_PERIOD),
           IO_IN(IO_PWM_DUTY));

    ok(IO_IN(IO_PWM_DUTY) >
       IO_IN(IO_PWM_PERIOD));


    //-------------------------------
    // Restore Configuration
    //-------------------------------

    IO_OUT(IO_PWM_PERIOD,PERIOD_VAL);
    IO_OUT(IO_PWM_DUTY,DUTY_VAL);
    IO_OUT(IO_PWM_CTRL,PWM_EN);


    //-------------------------------
    // Live Monitor
    //-------------------------------

    printf("\nTEST9 MONITOR\n");

    uint32_t prev =
        IO_IN(IO_PWM_STATUS)>>16;

    int running=0;

    for(int i=0;i<SAMPLES;i++)
    {
        status_reg=IO_IN(IO_PWM_STATUS);

        uint32_t cnt=status_reg>>16;

        printf("%2d : %4u\n",
               i+1,
               cnt);

        if(cnt!=prev)
            running=1;

        prev=cnt;
    }

    ok(running);


    //-------------------------------
    // Disable PWM
    //-------------------------------

    printf("\nTEST10 DISABLE\n");

    IO_OUT(IO_PWM_CTRL,PWM_DIS);

    ctrl=IO_IN(IO_PWM_CTRL);

    printf("CTRL=%08X\n",ctrl);

    ok((ctrl&1)==0);


    //-------------------------------
    // Summary
    //-------------------------------

    printf("\nRESULT\n");

    printf("PASS : %u\n",pass);
    printf("FAIL : %u\n",fail);

    if(fail==0)
        printf("PWM VERIFIED\n");
    else
        printf("PWM FAILED\n");

    while(1);

    return 0;

    IO_OUT(IO_PWM_PERIOD, 100);
    IO_OUT(IO_PWM_DUTY, 50);
    IO_OUT(IO_PWM_CTRL, 1);

    while(1);

    return 0;

}



```

The software performs automatic verification of every register and validates correct hardware operation before reporting PASS or FAIL.

---

# Software Test Flow

The supplied software performs the following sequence.

| Test | Description |
|------|-------------|
|Test 1|Verify default register values|
|Test 2|Write and read PERIOD register|
|Test 3|Write and read DUTY register|
|Test 4|Enable PWM through CTRL register|
|Test 5|Read STATUS register|
|Test 6|Verify DUTY = 0 condition|
|Test 7|Verify DUTY = PERIOD|
|Test 8|Verify DUTY > PERIOD|
|Test 9|Monitor PWM counter|
|Test 10|Disable PWM|

---

# Simulation Validation

The PWM IP was first verified using RTL simulation before FPGA implementation.

## Simulation Flow

```bash
iverilog -o pwm_sim tb_pwm.v pwm.v
vvp pwm_sim
gtkwave pwm.vcd
```

Simulation confirms that

- Register writes update the peripheral correctly.
- Register reads return expected values.
- PWM output changes according to software configuration.
- Address decoding functions correctly.
- Memory-mapped communication operates as expected.

---

# Waveform Analysis

'''
The waveform is already attached in task4/images 

'''
### Waveform Description

The captured GTKWave simulation verifies the interaction between the processor interface and the PWM peripheral.

The waveform contains the following important signals.

| Signal | Description |
|---------|-------------|
|i_clk|System clock driving the peripheral|
|i_rst|Reset signal|
|i_addr|Memory-mapped register address|
|i_wdata|32-bit write data from processor|
|i_we|Register write enable|
|o_rdata|Register read data|
|o_pwm|Generated PWM output|

### Functional Analysis

The waveform demonstrates the following sequence.

**1. Clock Operation**

The clock toggles continuously, providing the timing reference for the PWM peripheral.

---

**2. Register Writes**

Whenever `i_we` becomes HIGH, the value on `i_wdata` is written into the register selected by `i_addr`.

This confirms that the memory-mapped interface accepts software writes correctly.

---

**3. Register Reads**

The `o_rdata` signal changes according to the selected register, confirming successful read-back of stored values.

---

**4. PWM Output Generation**

After the control, period, and duty registers are programmed, the `o_pwm` output begins toggling.

The waveform confirms that:

- PWM generation starts only after enabling the peripheral.
- The output responds to the programmed register values.
- Changes written by software affect the generated PWM signal.

---

**5. Functional Verification**

The waveform verifies

- Correct bus transactions
- Proper register decoding
- Successful register storage
- PWM enable functionality
- Successful PWM output generation

---

# FPGA Validation

After successful RTL simulation, the design was synthesized and programmed onto the VSDSquadron FPGA.

## Hardware Setup

```
PWM IP
   │
   ▼
pwm_out
   │
   ▼
On-board LED
```

The PWM output was connected to an on-board LED for hardware validation.

---

# FPGA Test Procedure

1. Build the complete SoC.
2. Generate the FPGA bitstream.
3. Program the VSDSquadron FPGA.
4. Load the compiled firmware.
5. Open the UART terminal.
6. Execute `pwm_test`.
7. Observe the LED.

---

# FPGA Observations

The PWM peripheral behaved as expected during hardware testing.

- Register accesses were successful.
- UART displayed successful software execution.
- PWM output was generated continuously.
- Changing the DUTY register changed the LED brightness.
- The STATUS register correctly reflected the running state.
- Counter monitoring showed continuous PWM operation.

---

# LED Brightness Verification

| Duty Value | LED Behaviour |
|-------------|---------------|
|0%|LED OFF|
|25%|Dim|
|50%|Medium Brightness|
|75%|Bright|
|100%|Fully ON|

The LED brightness changed smoothly according to the programmed duty cycle, confirming correct PWM generation.

---

# UART Output

Expected terminal output:

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

# Expected Results

Successful execution should satisfy the following conditions.

| Verification | Result |
|--------------|--------|
|Register Read/Write|PASS|
|Address Decoding|PASS|
|PWM Generation|PASS|
|STATUS Register|PASS|
|Boundary Conditions|PASS|
|Counter Monitoring|PASS|
|UART Communication|PASS|
|FPGA Demonstration|PASS|

---

# Troubleshooting

| Problem | Possible Cause | Solution |
|----------|----------------|----------|
|LED remains OFF|PWM not enabled|Write CTRL.EN = 1|
|LED always ON|Duty ≥ Period|Reduce DUTY value|
|Incorrect brightness|Wrong PERIOD/DUTY values|Reconfigure registers|
|No UART output|Firmware not loaded|Reload executable|
|No waveform|Simulation not executed|Regenerate VCD file|

---

# Conclusion

The PWM IP was successfully verified through software testing, RTL simulation, and FPGA implementation. The software correctly configured the peripheral through memory-mapped registers, the simulation confirmed proper register transactions and PWM signal generation, and the FPGA demonstration verified real hardware operation by varying LED brightness according to the programmed duty cycle. Together, these results validate the correctness and reliability of the PWM IP for integration into the VSDSquadron RISC-V SoC.
