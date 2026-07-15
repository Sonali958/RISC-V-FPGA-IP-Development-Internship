# Register Map

## PWM IP Register Map

**Version:** 1.0

**Target Platform:** VSDSquadron FPGA SoC

---

# Overview

The PWM IP is controlled through four 32-bit memory-mapped registers. These registers allow software running on the RISC-V processor to configure the PWM output, control its operation, and monitor its runtime status.

All registers are word-aligned and support 32-bit read and write transactions.

**Base Address:** Assigned during SoC integration.

---

# Register Summary

| Offset | Register | Access | Description |
|:------:|:--------:|:------:|-------------|
| **0x00** | **CTRL** | R/W | PWM enable and polarity control |
| **0x04** | **PERIOD** | R/W | PWM period in clock cycles |
| **0x08** | **DUTY** | R/W | PWM high-time in clock cycles |
| **0x0C** | **STATUS** | R | Running status and current counter value |

---

# CTRL Register (Offset: 0x00)

Controls the overall operation of the PWM peripheral.

## Bit Fields

| Bits | Field | Access | Reset | Description |
|------|-------|:------:|:-----:|-------------|
|0|EN|R/W|0|PWM Enable (1 = Enabled, 0 = Disabled)|
|1|POL|R/W|0|Output Polarity (0 = Active High, 1 = Active Low)|
|31:2|Reserved|-|0|Reserved. Writes are ignored and reads return zero.|

## Reset Value

```
0x00000000
```

## Notes

- EN = 0 disables PWM output.
- EN = 1 enables PWM generation.
- POL changes the output polarity without affecting the internal PWM timing.

---

# PERIOD Register (Offset: 0x04)

Stores the PWM period measured in system clock cycles.

## Bit Fields

| Bits | Field | Access | Reset | Description |
|------|-------|:------:|:-----:|-------------|
|31:0|PERIOD|R/W|0|PWM period value|

## Reset Value

```
0x00000000
```

## Notes

- Minimum valid value is **1**.
- Counter counts from **0** to **PERIOD − 1**.
- Increasing PERIOD reduces the PWM frequency.

---

# DUTY Register (Offset: 0x08)

Defines the HIGH duration of the PWM output.

## Bit Fields

| Bits | Field | Access | Reset | Description |
|------|-------|:------:|:-----:|-------------|
|31:0|DUTY|R/W|0|PWM HIGH time|

## Reset Value

```
0x00000000
```

## Output Behaviour

| Condition | PWM Output |
|------------|------------|
|DUTY = 0|Always LOW|
|0 < DUTY < PERIOD|Normal PWM|
|DUTY ≥ PERIOD|Always HIGH|

When the POL bit is set, the output waveform is inverted.

---

# STATUS Register (Offset: 0x0C)

Provides runtime information for software monitoring.

## Bit Fields

| Bits | Field | Access | Reset | Description |
|------|-------|:------:|:-----:|-------------|
|0|RUNNING|R|0|Reflects the PWM Enable state|
|15:1|Reserved|-|0|Reserved|
|31:16|COUNTER|R|0|Current PWM counter value|

## Reset Value

```
0x00000000
```

## Notes

- RUNNING becomes **1** whenever PWM is enabled.
- COUNTER continuously increments while PWM is running.
- Software may periodically read STATUS for debugging or monitoring purposes.

---

# Register Programming Sequence

Typical software initialization sequence:

1. Disable PWM.

```c
IO_OUT(REG_PWM_CONTROL,0);
```

2. Configure the PWM period.

```c
IO_OUT(REG_PWM_PERIOD_VAL,100);
```

3. Configure the PWM duty cycle.

```c
IO_OUT(REG_PWM_DUTY_VAL,50);
```

4. Enable PWM.

```c
IO_OUT(REG_PWM_CONTROL,1);
```

5. Read the STATUS register if runtime monitoring is required.

```c
status = IO_IN(REG_PWM_STATUS);
```

---

# Read/Write Behaviour

| Register | Read Behaviour | Write Behaviour |
|----------|----------------|-----------------|
|CTRL|Returns enable and polarity configuration|Updates enable and polarity bits|
|PERIOD|Returns programmed period|Updates PWM period|
|DUTY|Returns programmed duty cycle|Updates HIGH time|
|STATUS|Returns RUNNING flag and counter value|Read Only|

---

# Reset Behaviour

After a system reset:

| Register | Reset Value |
|----------|-------------|
|CTRL|0x00000000|
|PERIOD|0x00000000|
|DUTY|0x00000000|
|STATUS|0x00000000|

Following reset:

- PWM output is disabled.
- Counter is cleared.
- Output polarity defaults to Active High.
- Software must configure the peripheral before PWM generation begins.

---

# Functional Notes

- Registers are accessed using standard 32-bit memory-mapped transactions.
- Reads from undefined register offsets return **0x00000000**.
- Writes to undefined register offsets are ignored.
- STATUS is intended for runtime monitoring and debugging.
- DUTY may be modified while PWM is running, allowing smooth real-time brightness control without disabling the peripheral.
- The PWM output is generated only when the EN bit is asserted.

---

# Register Access Summary

```
CTRL
 │
 ├── Enable PWM
 └── Select Output Polarity

PERIOD
 │
 └── Set PWM Frequency

DUTY
 │
 └── Set Duty Cycle

STATUS
 │
 ├── Read RUNNING Flag
 └── Read Current Counter Value
```
