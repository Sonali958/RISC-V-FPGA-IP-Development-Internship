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


