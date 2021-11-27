#ifndef STORAGE_H__
#define STORAGE_H__

#include "fds.h"
#include "app_error.h"


#define NRF_LOG_MODULE_NAME storage
#include "nrf_log.h"
#include "nrf_log_ctrl.h"


#define CONFIG_FILE     (0x8010)
#define CONFIG_REC_KEY  (0x7010)

/* A dummy structure to save in flash. */
typedef struct
{
    uint32_t boot_count;
    char     device_name[16];
    bool     config1_on;
    bool     config2_on;
} configuration_t;

void init(void);
#endif