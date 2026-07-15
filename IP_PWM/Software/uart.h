#ifndef UART_H
#define UART_H

#include <stdint.h>
#include <stdarg.h>
#include "io.h"

/*--------------------------------------------------
 * UART Low Level
 *-------------------------------------------------*/

static inline void uart_send_byte(char data)
{
    while(IO_IN(SERIAL_STATUS));
    IO_OUT(SERIAL_DATA, data);
}

/*--------------------------------------------------
 * Print Hexadecimal
 *-------------------------------------------------*/

static void uart_write_hex(unsigned int value)
{
    const char hex_table[] = "0123456789ABCDEF";

    for(int shift = 28; shift >= 0; shift -= 4)
    {
        uart_send_byte(hex_table[(value >> shift) & 0xF]);
    }
}

/*--------------------------------------------------
 * Print String
 *-------------------------------------------------*/

static void uart_write_string(const char *text)
{
    while(*text)
    {
        uart_send_byte(*text++);
    }
}

/*--------------------------------------------------
 * Print Decimal
 *-------------------------------------------------*/

static void uart_write_decimal(int value)
{
    char digits[12];
    int index = 0;

    if(value == 0)
    {
        uart_send_byte('0');
        return;
    }

    if(value < 0)
    {
        uart_send_byte('-');
        value = -value;
    }

    while(value)
    {
        digits[index++] = (value % 10) + '0';
        value /= 10;
    }

    while(index)
    {
        uart_send_byte(digits[--index]);
    }
}

/*--------------------------------------------------
 * Print Function
 *-------------------------------------------------*/

static int uart_printf(const char *fmt, ...)
{
    va_list args;

    va_start(args, fmt);

    while(*fmt)
    {
        if(*fmt != '%')
        {
            uart_send_byte(*fmt++);
            continue;
        }

        fmt++;

        switch(*fmt)
        {
            case 'd':
                uart_write_decimal(va_arg(args, int));
                break;

            case 'x':
                uart_write_hex(va_arg(args, unsigned int));
                break;

            case 'c':
                uart_send_byte((char)va_arg(args, int));
                break;

            case 's':
                uart_write_string(va_arg(args, char *));
                break;

            case '%':
                uart_send_byte('%');
                break;

            default:
                uart_send_byte('%');
                uart_send_byte(*fmt);
                break;
        }

        fmt++;
    }

    va_end(args);

    return 0;
}

#endif
