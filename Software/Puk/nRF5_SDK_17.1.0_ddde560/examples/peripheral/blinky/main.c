
#include <stdbool.h>
#include <stdint.h>

#include "nrf.h"
#include "nordic_common.h"
#include "boards.h"
#include "nrf_delay.h"

// Must include these headers to work with nrf logger
#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"



/**
 * @brief Function for application main entry.
 */
int main(void)
{

// Initialize the Logger module and check if any error occured during initialization
    APP_ERROR_CHECK(NRF_LOG_INIT(NULL));
	
	// Initialize the default backends for nrf logger
    NRF_LOG_DEFAULT_BACKENDS_INIT();

	// print the log msg over uart port
    NRF_LOG_INFO("This is log data from nordic device..");

	// a variable to hold counter value
    uint32_t count = 0;




    while (true)
    {	// Dsiplay the logger info with variable
        NRF_LOG_INFO("Counter Value: %d", count);
        nrf_delay_ms(500); // delay for 500 ms
        count++; // increment the counter by 1
    }
}
/** @} */
