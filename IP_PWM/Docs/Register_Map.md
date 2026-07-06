# Register Map

## Overview

The PWM IP is controlled through a set of 32-bit memory-mapped registers. These registers allow software running on the RISC-V processor to configure the PWM output, monitor its status, and control its operation.

All registers are word-aligned and support 32-bit accesses.

**Base Address:** `PWM_BASE` (Assigned during SoC integration)

---

# Register Summary

| Offset | Register | Access | Description |
|---------|----------|:------:|-------------|
| `0x00` | CTRL | R/W | PWM control register (Enable and Polarity) |
| `0x04` | PERIOD | R/W | PWM period value (clock cycles) |
| `0x08` | DUTY | R/W | PWM high-time value (clock cycles) |
| `0x0C` | STATUS | R | PWM running status and counter value |

---

# CTRL Register (Offset: 0x00)

Controls the overall operation of the PWM peripheral.

### Bit Fields

| Bits | Name | Access | Reset | Description |
|------|------|:------:|:-----:|-------------|
| 0 | EN | R/W | 0 | Enables PWM output (1 = Enabled, 0 = Disabled) |
| 1 | POL | R/W | 0 | PWM Polarity (0 = Active High, 1 = Active Low) |
| 31:2 | Reserved | - | 0 | Reserved. Writes are ignored. Reads return 0. |

### Reset Value

```
0x00000000
```

---

# PERIOD Register (Offset: 0x04)

Stores the PWM period in clock cycles.

### Bit Fields

| Bits | Name | Access | Reset | Description |
|------|------|:------:|:-----:|-------------|
|31:0|PERIOD|R/W|0|Total PWM period in clock ticks|

### Notes

- Minimum valid value is **1**.
- PWM counter increments from **0** to **PERIOD − 1**.
- Larger values produce lower PWM frequency.

---

# DUTY Register (Offset: 0x08)

Defines the HIGH duration of the PWM output.

### Bit Fields

| Bits | Name | Access | Reset | Description |
|------|------|:------:|:-----:|-------------|
|31:0|DUTY|R/W|0|PWM high-time in clock ticks|

### Notes

| Condition | PWM Output |
|------------|------------|
| DUTY = 0 | Always LOW |
| 0 < DUTY < PERIOD | Normal PWM |
| DUTY ≥ PERIOD | Always HIGH |

If polarity inversion is enabled (POL = 1), the output logic is inverted.

---

# STATUS Register (Offset: 0x0C)

Provides status information for software debugging and runtime monitoring.

### Bit Fields

| Bits | Name | Access | Reset | Description |
|------|------|:------:|:-----:|-------------|
|0|RUNNING|R|0|Indicates whether PWM is enabled|
|15:1|Reserved|-|0|Reserved|
|31:16|COUNTER|R|0|Current PWM counter value|

---

# Register Access Sequence

Typical software initialization sequence:

1. Write the desired PWM period to the **PERIOD** register.
2. Write the desired duty cycle to the **DUTY** register.
3. Configure polarity if required using the **CTRL** register.
4. Set the **EN** bit in the **CTRL** register.
5. Optionally monitor the **STATUS** register to verify operation.

---

# Read/Write Behavior

| Register | Read | Write |
|----------|------|-------|
| CTRL | Returns current control settings | Updates enable and polarity |
| PERIOD | Returns programmed period | Updates PWM period |
| DUTY | Returns programmed duty cycle | Updates PWM duty cycle |
| STATUS | Returns running status and counter value | Read Only |

---

# Reset Behavior

After system reset:

| Register | Reset Value |
|----------|-------------|
| CTRL | 0x00000000 |
| PERIOD | 0x00000000 |
| DUTY | 0x00000000 |
| STATUS | 0x00000000 |

The PWM output remains disabled until software explicitly configures and enables the peripheral.

---

# Functional Notes

- Registers are memory-mapped and accessed using standard 32-bit read/write operations.
- Undefined register offsets return **0x00000000**.
- Writes to undefined register offsets are ignored.
- The STATUS register is intended for software monitoring and debugging.
- The PWM output is generated only when the **EN** bit is set.
