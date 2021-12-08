/**
 * Copyright (c) 2013 - 2021, Nordic Semiconductor ASA
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
#include "sdk_common.h"
#if NRF_MODULE_ENABLED(BLE_LBS)
#include "ble_lbs.h"
#include "ble_srv_common.h"

#define NRF_LOG_MODULE_NAME LBS

#if LBS_CONFIG_LOG_ENABLED
    #define NRF_LOG_LEVEL           LBS_CONFIG_LOG_LEVEL
    #define NRF_LOG_INFO_COLOR      LBS_CONFIG_INFO_COLOR
    #define NRF_LOG_DEBUG_COLOR     LBS_CONFIG_DEBUG_COLOR
#else // HX711_CONFIG_LOG_ENABLED
    #define NRF_LOG_LEVEL           3
#endif  // HX711_CONFIG_LOG_ENABLED
#include "nrf_log.h"
NRF_LOG_MODULE_REGISTER();

bool wait_for_delete = false;


/**@brief Function for handling the Write event.
 *
 * @param[in] p_lbs      LED Button Service structure.
 * @param[in] p_ble_evt  Event received from the BLE stack.
 */
static void on_write(ble_lbs_t * p_lbs, ble_evt_t const * p_ble_evt)
{
    ble_gatts_evt_write_t const * p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;
    NRF_LOG_INFO("WRITTE DATA");

    if ((p_evt_write->handle == p_lbs->button_char_handles.value_handle)
        && (p_evt_write->len == 1))
        NRF_LOG_INFO("Data ready");
        if(p_evt_write->data[0] == 2) {  //Write 1
        NRF_LOG_INFO("Data %d",p_evt_write->data[0]);
        NRF_LOG_INFO("Write the DaTATAAAAAAAAAAAAA");
           p_lbs->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_lbs, 0);
        
        }
        
        if(p_evt_write->data[0] == 3) {
          wait_for_delete = true; 
          records_written = 1;
          NRF_LOG_INFO("Delete all");
          delete_all_begin();
        }

        // Set to Tara
        if(p_evt_write->data[0] == 4) {
          p_lbs->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_lbs, 2);
        }


    if (   (p_evt_write->handle == p_lbs->led_char_handles.value_handle)
        && (p_evt_write->len == 1)
        && (p_lbs->led_write_handler != NULL))
    {
        NRF_LOG_INFO("Data ready");
        p_lbs->led_write_handler(p_ble_evt->evt.gap_evt.conn_handle, p_lbs, p_evt_write->data[0]);
    }
}


void ble_lbs_on_ble_evt(ble_evt_t const * p_ble_evt, void * p_context)
{
    ble_lbs_t * p_lbs = (ble_lbs_t *)p_context;

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GATTS_EVT_WRITE:
            NRF_LOG_INFO("Write");
            on_write(p_lbs, p_ble_evt);
            break;
        default:
            // No implementation needed.
            break;
    }
}


uint32_t ble_lbs_init(ble_lbs_t * p_lbs, const ble_lbs_init_t * p_lbs_init)
{
    uint32_t              err_code;
    ble_uuid_t            ble_uuid;
    ble_add_char_params_t add_char_params;

    // Initialize service structure.
    p_lbs->led_write_handler = p_lbs_init->led_write_handler;

    // Add service.
    ble_uuid128_t base_uuid = {LBS_UUID_BASE};
    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_lbs->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_lbs->uuid_type;
    ble_uuid.uuid = LBS_UUID_SERVICE;

    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &ble_uuid, &p_lbs->service_handle);
    VERIFY_SUCCESS(err_code);

    // Add Button characteristic.
    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid              = LBS_UUID_BUTTON_CHAR;
    add_char_params.uuid_type         = p_lbs->uuid_type;
    add_char_params.init_len          = 244;//sizeof(uint64_t) + sizeof(uint64_t);
    add_char_params.max_len           = 244;//sizeof(uint64_t) + sizeof(uint64_t);
    add_char_params.char_props.read   = 1;
    add_char_params.char_props.notify = 1;
    add_char_params.char_props.write  = 1;

    add_char_params.read_access       = SEC_OPEN;
    add_char_params.cccd_write_access = SEC_OPEN;
    add_char_params.write_access = SEC_OPEN;

    err_code = characteristic_add(p_lbs->service_handle,
                                  &add_char_params,
                                  &p_lbs->button_char_handles);
    if (err_code != NRF_SUCCESS)
    {
        return err_code;
    }

    // Add LED characteristic.
    memset(&add_char_params, 0, sizeof(add_char_params));
    add_char_params.uuid             = LBS_UUID_LED_CHAR;
    add_char_params.uuid_type        = p_lbs->uuid_type;
    add_char_params.init_len         = sizeof(uint16_t);
    add_char_params.max_len          = sizeof(uint16_t);
    add_char_params.char_props.read  = 1;
    add_char_params.char_props.write = 1;

    add_char_params.read_access  = SEC_OPEN;
    add_char_params.write_access = SEC_OPEN;

    return characteristic_add(p_lbs->service_handle, &add_char_params, &p_lbs->led_char_handles);
}

uint32_t get_data_information(uint16_t conn_handle, ble_lbs_t * p_lbs) {

    uint16_t button_state = 42;
    ble_gatts_hvx_params_t params;
    uint16_t len = sizeof(button_state);

    memset(&params, 0, sizeof(params));
    params.type   = BLE_GATT_HVX_NOTIFICATION;
    params.handle = p_lbs->led_char_handles.value_handle;
    params.p_data = &button_state;
    params.p_len  = &len;

    NRF_LOG_INFO("Send value %d", *params.p_data);

    return sd_ble_gatts_hvx(conn_handle, &params);
}


uint32_t ble_lbs_on_button_change(uint16_t conn_handle, ble_lbs_t * p_lbs, uint8_t* button_state)
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
    params.handle = p_lbs->button_char_handles.value_handle;
    params.p_data = button_state;
    params.p_len  = &len;

    NRF_LOG_INFO("Send Value %d",button_state[0]);

    uint32_t ret = sd_ble_gatts_hvx(conn_handle, &params);
    if(ret != NRF_SUCCESS && ret !=NRF_ERROR_RESOURCES) 
    {
    NRF_LOG_ERROR("ERROR SEND %d", ret);
    }
    return ret;
}
#endif // NRF_MODULE_ENABLED(BLE_LBS)
