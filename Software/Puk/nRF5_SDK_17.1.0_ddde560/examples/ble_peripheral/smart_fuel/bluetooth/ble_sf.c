
#include "sdk_common.h"
#include "ble_sf.h"
#include "ble_srv_common.h"

#define NRF_LOG_MODULE_NAME SF
#define NRF_LOG_LEVEL           3

#include "nrf_log.h"
NRF_LOG_MODULE_REGISTER();

bool wait_for_delete_end = false;


/**@brief Function for handling the Write event.
 *
 * @param[in] p_lbs      LED Button Service structure.
 * @param[in] p_ble_evt  Event received from the BLE stack.
 */
static void on_write_sf(ble_sf_t * p_sf, ble_evt_t const * p_ble_evt)
{
    ble_gatts_evt_write_t const * p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;

    if ((p_evt_write->handle == p_sf->button_char_handles.value_handle)
        && (p_evt_write->len == 1))
        if(p_evt_write->data[0] == 2) {  //Write 1
           p_sf->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_sf, 0);
        }
        
        if(p_evt_write->data[0] == 3) {
          wait_for_delete_end = true; 
          records_written = 1;
          NRF_LOG_INFO("Delete all");
          delete_all_begin();
        }

        // Set to Tara
        if(p_evt_write->data[0] == 4) {
          p_sf->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_sf, 2);
        }


    if (   (p_evt_write->handle == p_sf->led_char_handles.value_handle)
        && (p_evt_write->len == 1)
        && (p_sf->led_write_handler != NULL))
    {
        NRF_LOG_INFO("Data ready");
        p_sf->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_sf, p_evt_write->data[0]);
    }
}


void ble_sf_on_ble_evt(ble_evt_t const * p_ble_evt, void * p_context)
{
    ble_sf_t * p_sf = (ble_sf_t *)p_context;

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GATTS_EVT_WRITE:
            NRF_LOG_INFO("Write");
            on_write_sf(p_sf, p_ble_evt);
            break;
        default:
            // No implementation needed.
            break;
    }
}


uint32_t ble_sf_init(ble_sf_t * p_sf, const ble_sf_init_t * p_sf_init)
{
    uint32_t              err_code;
    ble_uuid_t            ble_uuid;
    ble_add_char_params_t add_char_params;

    // Initialize service structure.
    p_sf->led_write_handler = p_sf_init->led_write_handler;

    // Add service.
    ble_uuid128_t base_uuid = {LBS_UUID_BASE};
    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_sf->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_sf->uuid_type;
    ble_uuid.uuid = LBS_UUID_SERVICE;

    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &ble_uuid, &p_sf->service_handle);
    VERIFY_SUCCESS(err_code);

    // Add Button characteristic.
    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid              = LBS_UUID_BUTTON_CHAR;
    add_char_params.uuid_type         = p_sf->uuid_type;
    add_char_params.init_len          = 244;//sizeof(uint64_t) + sizeof(uint64_t);
    add_char_params.max_len           = 244;//sizeof(uint64_t) + sizeof(uint64_t);
    add_char_params.char_props.read   = 1;
    add_char_params.char_props.notify = 1;
    add_char_params.char_props.write  = 1;

    add_char_params.read_access       = SEC_OPEN;
    add_char_params.cccd_write_access = SEC_OPEN;
    add_char_params.write_access = SEC_OPEN;

    err_code = characteristic_add(p_sf->service_handle,
                                  &add_char_params,
                                  &p_sf->button_char_handles);
    if (err_code != NRF_SUCCESS)
    {
        return err_code;
    }

    // Add LED characteristic.
    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid             = LBS_UUID_LED_CHAR;
    add_char_params.uuid_type        = p_sf->uuid_type;
    add_char_params.init_len         = sizeof(uint16_t);
    add_char_params.max_len          = sizeof(uint16_t);
    add_char_params.char_props.read  = 1;
    add_char_params.char_props.write = 1;

    add_char_params.read_access  = SEC_OPEN;
    add_char_params.write_access = SEC_OPEN;

    return characteristic_add(p_sf->service_handle, &add_char_params, &p_sf->led_char_handles);
}


uint32_t send_packet(uint16_t conn_handle, ble_sf_t * p_sf, uint8_t* button_state)
{
    
    uint8_t t[200];// = {20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1};
    for(int i = 0; i< 200; i++) {
      t[i] = i;
     // NRF_LOG_INFO("Item is %d", button_state[i]);
    }

    ble_gatts_hvx_params_t params;
    uint16_t len = 200; //sizeof(t);//(button_state);


    memset(&params, 0, sizeof(params));
    params.type   = BLE_GATT_HVX_NOTIFICATION;
    params.handle = p_sf->button_char_handles.value_handle;
    params.p_data = button_state;
    params.p_len  = &len;

    //NRF_LOG_INFO("Send Value %d",button_state[0]);

    uint32_t ret = sd_ble_gatts_hvx(conn_handle, &params);
    if(ret != NRF_SUCCESS && ret !=NRF_ERROR_RESOURCES) 
    {
    NRF_LOG_ERROR("ERROR SEND %d", ret);
    }
    return ret;
}

