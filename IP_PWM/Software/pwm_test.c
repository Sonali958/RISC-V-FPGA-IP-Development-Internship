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
        /* Configure PWM */

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

        /* Fade In */
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

        /* Fade Out */
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

        /* Fade In */
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

        /* Fade Out */
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

        /* Disable */

        IO_OUT(REG_PWM_CONTROL,0);

        status = IO_IN(REG_PWM_STATUS);

        uart_printf("\nPWM DISABLED\n");
        uart_printf("Status : 0x%x\n",status);

        delay(300000);

        /* Toggle Polarity */

        polarity ^= 1;

        uart_printf("\nSwitching PWM Polarity...\n");
    }

    return 0;
}
