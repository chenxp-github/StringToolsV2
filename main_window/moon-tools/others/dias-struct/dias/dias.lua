require("dias_consts")
require("c_dias_v2x_send_info")
require("c_its_lane_type_attributes")
require("c_its_positional_accuracy")
require("c_dias_v2x_service_param")
require("c_its_link")
require("c_its_position_confidence_set")
require("c_its_acceleration_set4_way")
require("c_its_map")
require("c_its_psm")
require("c_its_basic_safety_message")
require("c_its_map_position3_d")
require("c_its_reference_link")
require("c_its_brake_system_status")
require("c_its_map_speed_limit")
require("c_its_reference_path")
require("c_its_computed_lane")
require("c_its_motion_confidence_set")
require("c_its_road_point")
require("c_its_connecting_lane")
require("c_its_movement")
require("c_its_rsa")
require("c_its_connection")
require("c_its_participant")
require("c_its_rte")
require("c_its_ddate_time")
require("c_its_path_history")
require("c_its_rts")
require("c_its_full_position_vector")
require("c_its_path_history_point_set")
require("c_its_spat")
require("c_its_intersection")
require("c_its_path_point")
require("c_its_time_counting_down")
require("c_its_intersection_reference_id")
require("c_its_path_prediction")
require("c_its_utctiming")
require("c_its_intersection_state_id")
require("c_its_phase")
require("c_its_vehicle_classification")
require("c_its_intersection_state")
require("c_its_phase_state")
require("c_its_vehicle_emergency_extensions")
require("c_its_lane_attributes")
require("c_its_point_list")
require("c_its_vehicle_safety_extensions")
require("c_its_lane")
require("c_its_position3_d")
require("c_its_vehicle_size")

function dias_init_client(client_name, msg_type)
    local init_param={
        eDataType = msg_type,
        u32RecvMsgFlag = 
              DIAS_V2X_MSG_TYPE_RAW 
            | DIAS_V2X_MSG_TYPE_BSM 
            | DIAS_V2X_MSG_TYPE_SPAT
            | DIAS_V2X_MSG_TYPE_MAP
            | DIAS_V2X_MSG_TYPE_RSM
            | DIAS_V2X_MSG_TYPE_RSI 
            | DIAS_V2X_MSG_TYPE_ALL,
        u32RawAidListNum = 6,
        u32RawAidList = {0, 17, 4, 7, 16, 3},
        pfnRecvCallBack = 0,
    };

    local param_data = new_mem();
    lua_to_DiasV2xServiceParam(init_param,param_data);
    local r = Dias.V2xServiceInit(client_name,param_data);
    param_data:Destroy();
    return r;
end

function dias_default_init_client(client_name)
    return dias_init_client(client_name, DIAS_INIT_MSG_TYPE_STRUCT)
end

function dias_init_stream_client(client_name) 
    return dias_init_client(client_name, DIAS_INIT_MSG_TYPE_ASN1_ENCODED)
end

function dias_find_first_client_name()
    for i=1,LteArray.GetLen(),1 do 
        local name = LteArray.GetClientName(i-1);
        local opt = LteArray.GetClientOptions(i-1);
        if opt&LTE_OPT_USE_DIAS_API ~= 0 then
            return name;
        end
    end
end


function dias_send_encoded_asn1_stream(client_name, tp, mem)
    local sendInfo={
        bIsEvent = 0,
        eMsgType = tp,
        u32Aid = 17,
        u32Priority = 0,
        u32Reserved = 0
    };
    local bin_sendInfo = new_mem();
    lua_to_DiasV2xSendInfo(sendInfo,bin_sendInfo);
    Dias.V2xSendData(client_name,bin_sendInfo,mem);
end

function dias_send_rsi_message(client_name, rsi)
    local sendInfo={
        bIsEvent = 0,
        eMsgType = DIAS_V2X_MSG_TYPE_RSI,
        u32Aid = 17,
        u32Priority = 0,
        u32Reserved = 0
    };
    
    local bin_sendInfo = new_mem();
    lua_to_DiasV2xSendInfo(sendInfo,bin_sendInfo);

    if type(rsi) == "table" then
        local bin_rsi = new_mem(1024*1024);
        lua_to_ItsRsa(rsi,bin_rsi);
        Dias.V2xSendData(client_name,bin_sendInfo,bin_rsi);
        bin_rsi:Destroy();
    else
        Dias.V2xSendData(client_name,bin_sendInfo,rsi);
    end

    bin_sendInfo:Destroy();
end

