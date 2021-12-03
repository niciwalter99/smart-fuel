#ifndef STORAGE_H__
#define STORAGE_H__

#include "fds.h"
#include "app_error.h"
#include <stdint.h>
#include "nrf_delay.h"



//#define NRF_LOG_MODULE_NAME storage
//#include "nrf_log.h"
//#include "nrf_log_ctrl.h"


#define CONFIG_FILE     (0x8010)
#define CONFIG_REC_KEY  (0x7010)

/* A dummy structure to save in flash. */
typedef struct
{
    uint8_t weigth[4000]; // 6 records per minute -> data for 12 hours
    char     datetime[16];
    uint16_t index;
} configuration_t;

fds_stat_t storage_init(void);
uint8_t* get_boot_count(uint8_t * stored_data);
#endif
