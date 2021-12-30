#ifndef STORAGE_H__
#define STORAGE_H__

#include "fds.h"
#include "app_error.h"
#include <stdint.h>
#include "nrf_delay.h"
#include "ble_lbs.h"



//#define NRF_LOG_MODULE_NAME storage
//#include "nrf_log.h"
//#include "nrf_log_ctrl.h"

#define DATA_PER_RECORD 4000


#define WATER_LEVEL_HEAD_FILE (0x8010)
#define WATER_LEVEL_REC_KEY  (0x7010)


/* Header file which can store first 12 Hours */
typedef struct
{
    uint8_t weigth[DATA_PER_RECORD]; // 6 records per minute -> data for 12 hours
    char     datetime[16];
    uint16_t index;
    uint8_t global_index;
} water_level_head_file;

void delete_all_begin(void);
void delete_all_process(void);

fds_stat_t storage_init(void);
uint8_t* get_stored_data(uint8_t * stored_data,uint8_t record_count);

extern uint8_t records_written;

#endif
