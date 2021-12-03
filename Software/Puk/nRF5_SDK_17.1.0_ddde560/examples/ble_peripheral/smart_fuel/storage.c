#include "storage.h"

#define NRF_LOG_MODULE_NAME storage

#if HX711_CONFIG_LOG_ENABLED
    #define NRF_LOG_LEVEL           HX711_CONFIG_LOG_LEVEL
    #define NRF_LOG_INFO_COLOR      HX711_CONFIG_INFO_COLOR
    #define NRF_LOG_DEBUG_COLOR     HX711_CONFIG_DEBUG_COLOR
#else // HX711_CONFIG_LOG_ENABLED
    #define NRF_LOG_LEVEL          4
#endif  // HX711_CONFIG_LOG_ENABLED
#include "nrf_log.h"
NRF_LOG_MODULE_REGISTER();

/**@brief   Sleep until an event is received. */
static void power_manage(void)
{
#ifdef SOFTDEVICE_PRESENT
    (void) sd_app_evt_wait();
#else
    __WFE();
#endif
}

/* Dummy configuration data. */
static configuration_t m_dummy_cfg =
{
    .index  = 0,
    .weigth  = {20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1},
    .datetime = "dummy",
};

/* Array to map FDS events to strings. */
static char const * fds_evt_str[] =
{
    "FDS_EVT_INIT",
    "FDS_EVT_WRITE",
    "FDS_EVT_UPDATE",
    "FDS_EVT_DEL_RECORD",
    "FDS_EVT_DEL_FILE",
    "FDS_EVT_GC",
};

/* A record containing dummy configuration data. */
static fds_record_t const m_dummy_record =
{
    .file_id           = CONFIG_FILE,
    .key               = CONFIG_REC_KEY,
    .data.p_data       = &m_dummy_cfg,
    /* The length of a record is always expressed in 4-byte units (words). */
    .data.length_words = (sizeof(m_dummy_cfg) + 3) / sizeof(uint32_t),
};

/* Keep track of the progress of a delete_all operation. */
static struct
{
    bool delete_next;   //!< Delete next record.
    bool pending;       //!< Waiting for an fds FDS_EVT_DEL_RECORD event, to delete the next record.
} m_delete_all;


/* Flag to check fds initialization. */
static bool volatile m_fds_initialized;


const char *fds_err_str(ret_code_t ret)
{
    /* Array to map FDS return values to strings. */
    static char const * err_str[] =
    {
        "FDS_ERR_OPERATION_TIMEOUT",
        "FDS_ERR_NOT_INITIALIZED",
        "FDS_ERR_UNALIGNED_ADDR",
        "FDS_ERR_INVALID_ARG",
        "FDS_ERR_NULL_ARG",
        "FDS_ERR_NO_OPEN_RECORDS",
        "FDS_ERR_NO_SPACE_IN_FLASH",
        "FDS_ERR_NO_SPACE_IN_QUEUES",
        "FDS_ERR_RECORD_TOO_LARGE",
        "FDS_ERR_NOT_FOUND",
        "FDS_ERR_NO_PAGES",
        "FDS_ERR_USER_LIMIT_REACHED",
        "FDS_ERR_CRC_CHECK_FAILED",
        "FDS_ERR_BUSY",
        "FDS_ERR_INTERNAL",
    };

    return err_str[ret - NRF_ERROR_FDS_ERR_BASE];
}


static void fds_evt_handler(fds_evt_t const * p_evt)
{
    if (p_evt->result == NRF_SUCCESS)
    {
        NRF_LOG_INFO("Event: %s received (NRF_SUCCESS)",
                      fds_evt_str[p_evt->id]);
    }
    else
    {
        NRF_LOG_INFO("Event: %s received (%s)",
                      fds_evt_str[p_evt->id],
                      fds_err_str(p_evt->result));
    }

    switch (p_evt->id)
    {
        case FDS_EVT_INIT:
            if (p_evt->result == NRF_SUCCESS)
            {
                m_fds_initialized = true;
            }
            break;

        case FDS_EVT_WRITE:
        {
            if (p_evt->result == NRF_SUCCESS)
            {
                NRF_LOG_INFO("Record ID:\t0x%04x",  p_evt->write.record_id);
                NRF_LOG_INFO("File ID:\t0x%04x",    p_evt->write.file_id);
                NRF_LOG_INFO("Record key:\t0x%04x", p_evt->write.record_key);
            }
        } break;

        case FDS_EVT_DEL_RECORD:
        {
            if (p_evt->result == NRF_SUCCESS)
            {
                NRF_LOG_INFO("Record ID:\t0x%04x",  p_evt->del.record_id);
                NRF_LOG_INFO("File ID:\t0x%04x",    p_evt->del.file_id);
                NRF_LOG_INFO("Record key:\t0x%04x", p_evt->del.record_key);
            }
            m_delete_all.pending = false;
        } break;

        default:
            break;
    }
}

/**@brief   Wait for fds to initialize. */
static void wait_for_fds_ready(void)
{
    while (!m_fds_initialized)
    {
       power_manage();
    }
}


/**@brief   Begin deleting all records, one by one. */
void delete_all_begin(void)
{
    m_delete_all.delete_next = true;
}


/**@brief   Process a delete all command.
 *
 * Delete records, one by one, until no records are left.
 */
void delete_all_process(void)
{
    if (   m_delete_all.delete_next
        & !m_delete_all.pending)
    {
        NRF_LOG_INFO("Deleting next record.");

        m_delete_all.delete_next = record_delete_next();
        if (!m_delete_all.delete_next)
        {
            NRF_LOG_INFO("No records left to delete.");
        }
    }
}

fds_stat_t storage_init(void) {
  (void) fds_register(fds_evt_handler);
  ret_code_t rc;
  NRF_LOG_INFO("Initializing fds...");
  rc = fds_init();
  APP_ERROR_CHECK(rc);

  wait_for_fds_ready();

  fds_stat_t stat = {0};

  rc = fds_stat(&stat);
  APP_ERROR_CHECK(rc);

  return stat;
}

void write_boot_count(uint8_t boot_count) {
  ret_code_t rc;

  fds_gc(); // Run garbage collection

  fds_record_desc_t desc = {0};
    fds_find_token_t  tok  = {0};
  rc = fds_record_find(CONFIG_FILE, CONFIG_REC_KEY, &desc, &tok);

if (rc == NRF_SUCCESS)
    {
        /* A config file is in flash. Let's update it. */
        fds_flash_record_t config = {0};

        /* Open the record and read its contents. */
        rc = fds_record_open(&desc, &config);
        APP_ERROR_CHECK(rc);

        /* Copy the configuration from flash into m_dummy_cfg. */
        memcpy(&m_dummy_cfg, config.p_data, sizeof(configuration_t));

        fds_stat_t stat = {0};

      rc = fds_stat(&stat);
      APP_ERROR_CHECK(rc);

      NRF_LOG_INFO("Found %d valid records.", stat.valid_records);
      NRF_LOG_INFO("Found %d dirty records (ready to be garbage collected).", stat.dirty_records);

        ///* Update boot count. */
        if(m_dummy_cfg.index < 4000) {

         m_dummy_cfg.index++;
         m_dummy_cfg.weigth[m_dummy_cfg.index] = boot_count;
        }

        NRF_LOG_INFO("Config file found, updating boot count to %d. %d", m_dummy_cfg.index, m_dummy_cfg.weigth[m_dummy_cfg.index]);

        /* Close the record when done reading. */
        rc = fds_record_close(&desc);
        APP_ERROR_CHECK(rc);

        /* Write the updated record to flash. */
        rc = fds_record_update(&desc, &m_dummy_record);
        if ((rc != NRF_SUCCESS) && (rc == FDS_ERR_NO_SPACE_IN_FLASH))
        {
            NRF_LOG_INFO("No space in flash, delete some records to update the config file.");
        }
        else
        {
            APP_ERROR_CHECK(rc);
        }

    }
    else
    {
        /* System config not found; write a new one. */
        NRF_LOG_INFO("Writing config file...");

        rc = fds_record_write(&desc, &m_dummy_record);
        if ((rc != NRF_SUCCESS) && (rc == FDS_ERR_NO_SPACE_IN_FLASH))
        {
            NRF_LOG_INFO("No space in flash, delete some records to update the config file.");
        }
        else if(rc == FDS_ERR_RECORD_TOO_LARGE) {
          NRF_LOG_ERROR("Record is too big");
        }
        else
        {
            APP_ERROR_CHECK(rc);
        }
    }
    nrf_delay_ms(10);
}
  
static uint8_t * stored_weight_data;
uint8_t* get_boot_count(uint8_t * stored_data)  {
    fds_record_desc_t desc = {0};
    fds_find_token_t  tok  = {0};
    uint32_t count;

    NRF_LOG_INFO("Get Record");
    while (fds_record_find(CONFIG_FILE, CONFIG_REC_KEY, &desc, &tok) == NRF_SUCCESS)
    {
        ret_code_t rc;
        fds_flash_record_t frec = {0};

        rc = fds_record_open(&desc, &frec);
        switch (rc)
        {
            case NRF_SUCCESS:
                break;

            case FDS_ERR_CRC_CHECK_FAILED:
                NRF_LOG_ERROR("error: CRC check failed!\n");
                continue;

            case FDS_ERR_NOT_FOUND:
                NRF_LOG_ERROR("error: record not found!\n");
                continue;

            default:
            {
                NRF_LOG_ERROR(
                                "error: unexpecte error %s.\n",
                                fds_err_str(rc));

                continue;
            }
        }

        configuration_t * p_cfg = (configuration_t *)(frec.p_data);
        NRF_LOG_INFO("Return %d", p_cfg->weigth[0]);

        int * p = malloc(sizeof(p_cfg->weigth) * sizeof(uint8_t));
        memcpy(p, p_cfg->weigth, sizeof(p_cfg->weigth) * sizeof(uint8_t));

        rc = fds_record_close(&desc);
        APP_ERROR_CHECK(rc);

        //uint8_t test[4000];
        for(int i = 0; i< 4000; i++) {
          stored_data[i] = p_cfg->weigth[i];
        }

        //stored_weight_data = malloc(sizeof(test) * sizeof(uint8_t));
        //memcpy(stored_weight_data, test, sizeof(test) * sizeof(uint8_t));

        return stored_data;
     }


}


