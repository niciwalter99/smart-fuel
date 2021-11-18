/**
 * Copyright (c) 2014 - 2021, Nordic Semiconductor ASA
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form, except as embedded into a Nordic
 *    Semiconductor ASA integrated circuit in a product or a software update for
 *    such product, must reproduce the above copyright notice, this list of
 *    conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *
 * 3. Neither the name of Nordic Semiconductor ASA nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * 4. This software, with or without modification, must only be used with a
 *    Nordic Semiconductor ASA integrated circuit.
 *
 * 5. Any software provided in binary form under this license must not be reverse
 *    engineered, decompiled, modified and/or disassembled.
 *
 * THIS SOFTWARE IS PROVIDED BY NORDIC SEMICONDUCTOR ASA "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL NORDIC SEMICONDUCTOR ASA OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
/** @file
 * @defgroup pin_change_int_example_main main.c
 * @{
 * @ingroup pin_change_int_example
 * @brief Pin Change Interrupt Example Application main file.
 *
 * This file contains the source code for a sample application using interrupts triggered by GPIO pins.
 *
 */

#include <stdbool.h>
#include "nrf.h"
#include "nrf_drv_gpiote.h"
#include "app_error.h"
#include "boards.h"
#include "hx711.h"
#include "nrf_delay.h"
//#include "nrf_log.h"
//#include "nrf_log_ctrl.h"
//#include "nrf_log_default_backends.h"

void hx711_callback(hx711_evt_t evt, int value)
{
    uint16_t length = sizeof(int);
    
    if(evt == DATA_READY)
    {
        /* Transmit received sensor data over BLE - ignoring return value. Packets will be dropped
         if:
         -  Not connected
         -  Client has not enabled Notification on the TX characteristic
         -  TX buffer is full*/
        //NRF_LOG_INFO("ADC measuremement %d", value);
        printf('FOUND VALUE');
    }
    else
    {
        /*Invalid ADC readout. A non-zero value would indicate that the readout was interrupted 
         by a higher priority interrupt during readout (i.e., Softdevice radio event).
         */
         printf('ADC ERROR');
        //NRF_LOG_INFO("ADC readout error. %d 0x%x", value, value);
    }
}


/**
 * @brief Function for application main entry.
 */
int main(void)
{
  
    //uint32_t err_code = NRF_LOG_INIT(NULL);
    //APP_ERROR_CHECK(err_code);
    //NRF_LOG_DEFAULT_BACKENDS_INIT();

    hx711_mode_t mikes_mode;
    hx711_init(mikes_mode, hx711_callback);
    hx711_start(false);
    //NRF_LOG_FLUSH(); // push out message

  while(true) {
        NRF_LOG_INFO("print me");
        printf('PRINT');
        nrf_drv_gpiote_in_event_disable(7); // maybe needed
        //hx711_sample(); // Getting caught here
        nrf_delay_ms(1000);
        //NRF_LOG_FLUSH();
    }
}


/** @} */
