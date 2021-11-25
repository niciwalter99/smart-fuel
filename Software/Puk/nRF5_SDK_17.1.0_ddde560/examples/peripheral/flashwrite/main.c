
#include <stdbool.h>
#include <stdio.h>
#include "nrf.h"
#include "bsp.h"
#include "app_error.h"
#include "nrf_nvmc.h"
#include "nordic_common.h"

#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"

#include "app_timer.h"
#include "nrf_drv_clock.h"

#include "nrf_cli.h"
#include "nrf_cli_uart.h"

void log_init(void) {
    APP_ERROR_CHECK(NRF_LOG_INIT(NULL));
    NRF_LOG_DEFAULT_BACKENDS_INIT();

}

int main(void)
{
    log_init();
    NRF_LOG_INFO("App started");


    //Last Page Adress: 127 *( 4 * 1024)=520192=0x0007F000
    uint32_t f_addr = 0x0007F000;
    uint32_t *p_addr = (uint32_t *)f_addr; //pointer to address

    uint32_t k[120];

    for(int i = 0; i < 120; i++) {
      k[i] = i;
    }
    uint8_t val_1 = 223;
    uint8_t val_2 = 12;

    uint32_t val = 223 + (12 << 8);

    NRF_LOG_INFO("Erasing page 127");
    nrf_nvmc_page_erase(f_addr);
    NRF_LOG_INFO("Erased Succesfully"); 

    nrf_nvmc_write_words(f_addr, k, 120);
    NRF_LOG_INFO("Written to flash");

    uint32_t t = p_addr;

    //NRF_LOG_INFO("First Value %d",t[0]);
    //for(int i = 0; i <120; i++) {
    //   NRF_LOG_INFO("Flash %d",*(p_addr +i));
    //}

     //nrf_nvmc_write_word(f_addr, val);
     //NRF_LOG_INFO("Flash first %d",*p_addr);
     //uint32_t stored = *p_addr;
     //int first = stored&0xFF;
     //int sec = (stored>>8)&0xFF;
     //NRF_LOG_INFO("Flash multiple Values %d",first); // First 8 Bits
     //NRF_LOG_INFO("Flash multiple Values %d",sec); //Bit 9 to 16

     //val = 23123;
     //nrf_nvmc_write_word(f_addr, val);
     //NRF_LOG_INFO("Flash second %d",*p_addr);


    while (true)
    {
    }
}

