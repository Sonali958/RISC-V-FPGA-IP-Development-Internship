#ifndef IO_H
#define IO_H

#include <stdint.h>

/*--------------------------------------------------
 * Base Address
 *-------------------------------------------------*/

#define IO_BASE         0x400000UL

/*--------------------------------------------------
 * UART Register Offsets
 *-------------------------------------------------*/

#define SERIAL_DATA     0x10
#define SERIAL_STATUS   0x14

/*--------------------------------------------------
 * PWM Register Offsets
 *-------------------------------------------------*/

#define REG_PWM_CONTROL    0x20
#define REG_PWM_PERIOD_VAL  0x24
#define REG_PWM_DUTY_VAL    0x28
#define REG_PWM_STATUS  0x2C

/*--------------------------------------------------
 * Register Access Macros
 *-------------------------------------------------*/

#define IO_IN(addr) \
    (*(volatile uint32_t *)(IO_BASE + (addr)))

#define IO_OUT(addr,val) \
    (*(volatile uint32_t *)(IO_BASE + (addr)) = (val))

#endif /* IO_H */
