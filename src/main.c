#include "NUC1311.h"

#define PLL_CLOCK           50000000

void TMR0_IRQHandler(void)
{
    if(TIMER_GetIntFlag(TIMER0) == 1)
    {
        /* Clear Timer0 time-out interrupt flag */
        TIMER_ClearIntFlag(TIMER0);
		GPIO_TOGGLE(PB12);
    }
}

void SYS_Init(void)
{
    /*---------------------------------------------------------------------------------------------------------*/
    /* Init System Clock                                                                                       */
    /*---------------------------------------------------------------------------------------------------------*/
	SYS_UnlockReg();
    /* Enable HIRC clock */
    CLK_EnableXtalRC(CLK_PWRCON_IRC22M_EN_Msk);

    /* Waiting for HIRC clock ready */
    CLK_WaitClockReady(CLK_CLKSTATUS_IRC22M_STB_Msk);

    /* Switch HCLK clock source to HIRC */
    CLK_SetHCLK(CLK_CLKSEL0_HCLK_S_HIRC, CLK_CLKDIV_HCLK(1));

    /* Enable HXT */
 	SystemCoreClockUpdate();
 	CLK_EnableXtalRC(CLK_PWRCON_XTL12M_EN_Msk);

    /* Waiting for clock ready */
    CLK_WaitClockReady(CLK_CLKSTATUS_XTL12M_STB_Msk);

    /* Set core clock as PLL_CLOCK from PLL and SysTick source to HCLK/2*/
    CLK_SetCoreClock(PLL_CLOCK);
    CLK_SetSysTickClockSrc(CLK_CLKSEL0_STCLK_S_HCLK_DIV2);

    /* Enable peripheral clock */
    CLK_EnableModuleClock(TMR0_MODULE);

    /* Peripheral clock source */
    CLK_SetModuleClock(TMR0_MODULE, CLK_CLKSEL1_TMR0_S_HXT, 0);
}


int main()
{

    /* Init System, peripheral clock and multi-function I/O */
    SYS_Init();

    GPIO_SetMode(PB, BIT12, GPIO_PMD_OUTPUT);

    /* Open Timer0 in periodic mode, enable interrupt and 1 interrupt tick per second */
    TIMER_Open(TIMER0, TIMER_PERIODIC_MODE, 2);
    TIMER_EnableInt(TIMER0);


    NVIC_EnableIRQ(TMR0_IRQn);

    TIMER_Start(TIMER0);
    while(1)
	{
	}

	return 0;
}
