local OPCODES = {}

function OPCODES.get_description(opcode)
    local opcodeDesc = "UNKNOWN"
    if opcode == 0x2002 then
        opcodeDesc = "** KEEP_ALIVE **"

    elseif opcode == 0x210e then
        opcodeDesc = "GATEWAY / QUEUE_INFORMATION"
    elseif opcode == 0x2116 then
        opcodeDesc = "GATEWAY / LOGIN_RESPONSE"

    elseif opcode == 0x300a then
        opcodeDesc = "SERVER_LEAVE_SUCCESS"
    elseif opcode == 0x300c then
        opcodeDesc = "UNIQUE_ANNOUNCE"

    elseif opcode == 0x3013 then
        opcodeDesc = "SERVER_PLAYERDATA"
    elseif opcode == 0x3015 then
        opcodeDesc = "SERVER_SOLO_SPAWN"
    elseif opcode == 0x3016 then
        opcodeDesc = "SERVER_SOLO_DESPAWN"
    elseif opcode == 0x3017 then
        opcodeDesc = "SERVER_GROUPSPAWN_START"
    elseif opcode == 0x3018 then
        opcodeDesc = "SERVER_GROUPSPAWN_END"
    elseif opcode == 0x3019 then
        opcodeDesc = "SERVER_GROUPSPAWN_DATA"

    elseif opcode == 0x3027 then
        opcodeDesc = "SERVER_ITEM_UN_EFFECT 0x3027" -- seems wrong but we have to ensure
    elseif opcode == 0x3026 then
        opcodeDesc = "SERVER_CHAT"

    elseif opcode == 0x3038 then
        opcodeDesc = "SERVER_ITEM_EFFECT"
    elseif opcode == 0x3039 then
        opcodeDesc = "SERVER_ITEM_UN_EFFECT 0x3039"
    elseif opcode == 0x303d then
        opcodeDesc = "SERVER_PLAYERSTAT"

    elseif opcode == 0x3040 then
        opcodeDesc = "BALOON_EXCHANGE"
    elseif opcode == 0x3041 then
        opcodeDesc = "SERVER_PVP_WAIT"
    elseif opcode == 0x3042 then
        opcodeDesc = "SERVER_PVP_INTERUPT"
    elseif opcode == 0x3047 then
        opcodeDesc = "SERVER_OPEN_WAREHOUSE"
    elseif opcode == 0x3049 then
        opcodeDesc = "SERVER_OPEN_WAREPROB"
    elseif opcode == 0x304d then
        opcodeDesc = "SERVER_ITEM_DELETE"
    elseif opcode == 0x304e then
        opcodeDesc = "AFTER_MASTERY_ADD_ITS_RESPONSE 1"

    elseif opcode == 0x3052 then
        opcodeDesc = "SERVER_REPAIR_RESPONSE"
    elseif opcode == 0x3053 then
        opcodeDesc = "CLIENT_GETUP"
    elseif opcode == 0x3057 then
        opcodeDesc = "SERVER_SKILL_EFFECTS"
    elseif opcode == 0x3058 then
        opcodeDesc = "SERVER_EFFECT_DAMAGE"
    elseif opcode == 0x305c then
        opcodeDesc = "SERVER_PLAYER_HANDLE_EFFECT"

    elseif opcode == 0x3078 then
        opcodeDesc = "SERVER_GUILD_STORAGE4"

    elseif opcode == 0x3080 then
        opcodeDesc = "PARTY_REQUEST? WHO SENDS?"
    elseif opcode == 0x3088 then
        opcodeDesc = "SERVER_EXCHANGE_CANCEL"

    elseif opcode == 0x3091 then
        opcodeDesc = "CLIENT_SERVER_EMOTE"

    elseif opcode == 0x30b8 then
        opcodeDesc = "SERVER_STALL_OPEN"
    elseif opcode == 0x30b9 then
        opcodeDesc = "SERVER_STALL_CLOSE"
    elseif opcode == 0x30bf then
        opcodeDesc = "SERVER_CHANGE_STATUS"
    elseif opcode == 0x30bb then
        opcodeDesc = "SERVER_STALL_RENAME"
    elseif opcode == 0x30b7 then
        opcodeDesc = "SERVER_STALL_PLAYERUPDATE"

    elseif opcode == 0x30cf then
        opcodeDesc = "SERVER_QUEST_PROGRESS"

    elseif opcode == 0x30d0 then
        opcodeDesc = "SERVER_SETSPEED"
    -- elseif opcode == 0x30d1 then
    -- 	opcodeDesc = "????????????????????????????????????????????"
    elseif opcode == 0x30d2 then
        opcodeDesc = "SERVER_TELEPORTOTHERSTART"
    elseif opcode == 0x30d3 then
        opcodeDesc = "CLIENT_NPC_QUEST -- ?"
    elseif opcode == 0x30d4 then
        opcodeDesc = "SERVER_NPC_QUEST"
    elseif opcode == 0x30d5 then
        opcodeDesc = "SERVER_NPC_QUEST_ACCEPT"
    elseif opcode == 0x30d6 then
        opcodeDesc = "SERVER_NPC_QUEST_DRAW_ICON"
    elseif opcode == 0x30d7 then
        opcodeDesc = "SERVER_NPC_QUEST_CLEAR_ICON"

    elseif opcode == 0x30ec then
        opcodeDesc = "SERVER_CLOSE_NPC_ITEM_WINDOW_ACTION"

    elseif opcode == 0x3201 then
        opcodeDesc = "SERVER_ARROW_UPDATE"

    elseif opcode == 0x3253 then
        opcodeDesc = "SERVER_GUILD_STORAGE_GOLD"
    elseif opcode == 0x3255 then
        opcodeDesc = "SERVER_GUILD_STORAGE3"

    elseif opcode == 0x3305 then
        opcodeDesc = "SERVER_SEND_FRIEND_LIST"

    elseif opcode == 0x34a5 then
        opcodeDesc = "SERVER_STARTPLAYERDATA"
    elseif opcode == 0x34a6 then
        opcodeDesc = "SERVER_ENDPLAYERDATA"

    elseif opcode == 0x34b1 then
        opcodeDesc = "SERVER_SEND_EVENT_MSG"
    elseif opcode == 0x34b5 then
        opcodeDesc = "SERVER_TELEPORTIMAGE"
    elseif opcode == 0x34b6 then
        opcodeDesc = "CLIENT_TELEPORTDATA"
    elseif opcode == 0x34be then
        opcodeDesc = "AGENT_GAME_SERVERTIME"

    elseif opcode == 0x34c6 then
        opcodeDesc = "CLIENT_FINISH_LOADING"

    elseif opcode == 0x34d2 then
        opcodeDesc = "The request for the party denied."

    elseif opcode == 0x3514 then
        opcodeDesc = "SERVER_OPEN_NPC_ITEM_WINDOW"

    elseif opcode == 0x3537 then
        opcodeDesc = "SETTINGS_CHANGED"

    elseif opcode == 0x3546 then
        opcodeDesc = "SERVER_STALL_OR_BALOON"

    elseif opcode == 0x3573 then
        opcodeDesc = "BALOONS_ANNOUNCE"
    elseif opcode == 0x357c then
        opcodeDesc = "SERVER_BALOON_USE_RESPONSE"
    elseif opcode == 0x357d then
        opcodeDesc = "BALOON_IS_MOVING_DOWN"
    elseif opcode == 0x357e then
        opcodeDesc = "BALOON_IS_MOVING_UP"

    elseif opcode == 0x3611 then
        opcodeDesc = "SERVER_SUCCESSFULL_ENCHANT"
    elseif opcode == 0x3612 then
        opcodeDesc = "BUY_SUCCESS_GOLD"

    elseif opcode == 0x3809 then
        opcodeDesc = "SERVER_AGENT_ENVIRONMENT_WEATHER_UPDATE"
    elseif opcode == 0x3864 then
        opcodeDesc = "SERVER_PARTY_DATA"
    elseif opcode == 0x38f5 then
        opcodeDesc = "SERVER_GUILD_UPDATE"

    elseif opcode == 0x3b07 then
        opcodeDesc = "SERVER_FRIEND_DATA"

    elseif opcode == 0x3c80 then
        opcodeDesc = "AGENT_ACADEMY_UPDATE"

    elseif opcode == 0x3e70 then
        opcodeDesc = "LOGG OFF OR DISC 1"
    elseif opcode == 0x3e71 then
        opcodeDesc = "LOGG OFF OR DISC 2"
    
    elseif opcode == 0x600D then
        opcodeDesc = "** MASSIVE **"
    elseif opcode == 0x6104 then
        opcodeDesc = "CLIENT_GATEWAY_NOTICE_REQUEST"
    elseif opcode == 0x655a then
        opcodeDesc = "CLIENT_SHOW_PARTY_FORMATION"

    elseif opcode == 0x7001 then
        opcodeDesc = "CLIENT_INGAME_REQUEST"
    elseif opcode == 0x7005 then
        opcodeDesc = "CLIENT_LEAVE_REQUEST"
    elseif opcode == 0x7006 then
        opcodeDesc = "CLIENT_LEAVE_CANCEL"
    elseif opcode == 0x7007 then
        opcodeDesc = "CLIENT_CHAR_RELATED"

    elseif opcode == 0x7021 then
        opcodeDesc = "CLIENT_MOVE_REQUEST"
    elseif opcode == 0x7023 then
        opcodeDesc = "START_PLAYER_CONTROL (arrows)"
    elseif opcode == 0x7024 then
        opcodeDesc = "CLIENT_ANGLE_MOVE"
    elseif opcode == 0x7025 then
        opcodeDesc = "CLIENT_CHAT"

    elseif opcode == 0x7034 then
        opcodeDesc = "ITEM_MOVED_TO_OTHER_SLOT"
    elseif opcode == 0x703c then -- 0x303c or 703c CZA SPRAWDZIC
        opcodeDesc = "CLIENT_OPEN_WAREHOUSE"
    elseif opcode == 0x703e then
        opcodeDesc = "CLIENT_REPAIR_REQUEST"

    elseif opcode == 0x7045 then
        opcodeDesc = "CLIENT_SELECT_OBJECT"
    elseif opcode == 0x7046 then
        opcodeDesc = "CLIENT_OPEN_NPC"
    elseif opcode == 0x704b then
        opcodeDesc = "CLIENT_CLOSE_NPC"

    elseif opcode == 0x7050 then
        opcodeDesc = "CLIENT_PLAYER_UPDATE_STR"
    elseif opcode == 0x7051 then
        opcodeDesc = "CLIENT_PLAYER_UPDATE_INT"
    elseif opcode == 0x7059 then
        opcodeDesc = "CLIENT_SAVE_PLACE"
    elseif opcode == 0x705a then
        opcodeDesc = "CLIENT_TELEPORTSTART"

    elseif opcode == 0x7060 then
        opcodeDesc = "CLIENT_PARTY_REQUEST"
    elseif opcode == 0x7061 then
        opcodeDesc = "CLIENT_PARTY_LEAVE"
    elseif opcode == 0x7069 then
        opcodeDesc = "CLIENT_CREATE_FORMED_PARTY"
    elseif opcode == 0x706a then
        opcodeDesc = "CLIENT_CHANGE_PARTY_NAME"
    elseif opcode == 0x706b then
        opcodeDesc = "CLIENT_DELETE_FORMED_PARTY"
    elseif opcode == 0x706c then
        opcodeDesc = "CLIENT_PARTYMATCHING_LIST_REQUEST"
    elseif opcode == 0x706d then
        opcodeDesc = "CLIENT_JOIN_FORMED_PARTY_REQUEST"
    elseif opcode == 0x706f then
        opcodeDesc = "CLIENT_SHOW_PARTY_FORMATION"

    elseif opcode == 0x7074 then
        opcodeDesc = "CLIENT_SKILL_USE_REQUEST"

    elseif opcode == 0x7081 then
        opcodeDesc = "CLIENT_EXCHANGE_REQUEST"
    elseif opcode == 0x7084 then
        opcodeDesc = "CLIENT_OPEN_SPECIAL_WINDOW"
        
    elseif opcode == 0x70a1 then
        opcodeDesc = "SKILL_ADD_REQUEST"
    elseif opcode == 0x70a2 then
        opcodeDesc = "MASTERY_SKILL_ADD_REQUEST"
    elseif opcode == 0x70a7 then
        opcodeDesc = "CLIENT_PLAYER_BERSERK"

    elseif opcode == 0x70b1 then
        opcodeDesc = "CLIENT_STALL_OPEN"
    elseif opcode == 0x70b2 then
        opcodeDesc = "CLIENT_STALL_CLOSE"
    elseif opcode == 0x70b3 then
        opcodeDesc = "CLIENT_STALL_OTHER_OPEN"
    elseif opcode == 0x70b4 then
        opcodeDesc = "CLIENT_STALL_BUY"
    elseif opcode == 0x70b5 then
        opcodeDesc = "CLIENT_STALL_OTHER_CLOSE"
    elseif opcode == 0x70ba then
        opcodeDesc = "CLIENT_STALL_ACTION"

    elseif opcode == 0x70ea then
        opcodeDesc = "CLIENT_GUIDE"

    elseif opcode == 0x70f3 then
        opcodeDesc = "CLIENT_GUILD_INVITE"
    elseif opcode == 0x70f4 then -- 0x70f4 or 0x704f CZA SPRAWDZIC
        opcodeDesc = "CLIENT_WALK_RUN"
    elseif opcode == 0x70f9 then
        opcodeDesc = "CLIENT_GUILD_MESSAGE"


    elseif opcode == 0x7105 then
        opcodeDesc = "VOTE_FOR_NEW_LEADER_REQUEST"
    elseif opcode == 0x7158 then
        opcodeDesc = "SKILL_ADD_RELATED_RESPONSE"
    elseif opcode == 0x7168 then
        opcodeDesc = "CLIENT_NPC_BUYPACK"

    elseif opcode == 0x7250 then
        opcodeDesc = "CLIENT_OPEN_GUILD_STORAGE"
    elseif opcode == 0x7251 then
        opcodeDesc = "CLIENT_CLOSE_GUILD_STORAGE"
    elseif opcode == 0x7252 then
        opcodeDesc = "CLIENT_OPEN_GUILD_STORAGE2"

    elseif opcode == 0x7302 then
        opcodeDesc = "CLIENT_FRIEND_INVITE"
    elseif opcode == 0x730b then
        opcodeDesc = "CLIENT_MAILBOX_REQUEST"

    elseif opcode == 0x7402 then
        opcodeDesc = "CLIENT_QUESTMARK"
    elseif opcode == 0x7474 then
        opcodeDesc = "CLIENT_ACADEMY_LEAVE"
    elseif opcode == 0x7478 then
        opcodeDesc = "CLIENT_OPEN_HONOR_RANKLIST"
    elseif opcode == 0x747d then
        opcodeDesc = "CLIENT_ACADEMY_MATCHING_REQUEST"

    elseif opcode == 0x7501 then
        opcodeDesc = "CLIENT_OPEN_GUILD_USAGE"
    elseif opcode == 0x7507 then
        opcodeDesc = "CLIENT_STALL_NETWORK_CLOSE_REQUEST"
    elseif opcode == 0x750a then
        opcodeDesc = "CLIENT_STALL_NETWORK_BUY_REQUEST"
    elseif opcode == 0x750c then
        opcodeDesc = "CLIENT_STALL_NETWORK_SEARCH_REQUEST"
    elseif opcode == 0x750e then
        opcodeDesc = "CLIENT_REQUEST_WEATHER"

    elseif opcode == 0x7515 then
        opcodeDesc = "SERVER_CLOSE_NPC ITEM"
    elseif opcode == 0x7516 then
        opcodeDesc = "CLIENT_PVP"

    elseif opcode == 0x7533 then
        opcodeDesc = "CLIENT_SETTLE_CONSIGMENT_REQUEST"
    elseif opcode == 0x7534 then
        opcodeDesc = "CLIENT_LEARN_RECEIPE"

    elseif opcode == 0x7554 then
        opcodeDesc = "CLIENT_SET_MACROS"
    elseif opcode == 0x7557 then
        opcodeDesc = "CLIENT_ITEM_STORAGE_BOX"
    elseif opcode == 0x7559 then
        opcodeDesc = "CLIENT_ITEM_BOX_LOG"
    elseif opcode == 0x755d then
        opcodeDesc = "CLIENT_ITEM_MALL"
    elseif opcode == 0x7574 then
        opcodeDesc = "CLIENT_BALOON_UP_REQUEST"

    elseif opcode == 0x9000 then
        opcodeDesc = "** HANDSHAKE_ACCEPT **"

    elseif opcode == 0xa101 then
        opcodeDesc = "GATEWAY / SHARDS"
    elseif opcode == 0xa107 then
        opcodeDesc = "GATEWAY / LOCATIONS"
    elseif opcode == 0xa117 then
        opcodeDesc = "GATEWAY / TOKEN_RESPONSE"

    elseif opcode == 0xa2b0 then
        opcodeDesc = "AFTER_MASTERY_ADD_ITS_RESPONSE 2 -- to raczej złe"

    elseif opcode == 0xb001 then
        opcodeDesc = "SERVER_LOGINSCREEN_ACCEPT"
    elseif opcode == 0xb005 then
        opcodeDesc = "SERVER_LEAVE_ACCEPT"
    elseif opcode == 0xb006 then
        opcodeDesc = "SERVER_LEAVE_CALCEL"
    elseif opcode == 0xb007 then
        opcodeDesc = "SERVER_CHAR_RELATED"

    elseif opcode == 0xb021 then
        opcodeDesc = "SERVER_MOVE_RESPONSE"
    elseif opcode == 0xb023 then
        opcodeDesc = "SERVER_MOVE_INTERRUPT"
    elseif opcode == 0xb024 then
        opcodeDesc = "SERVER_ANGLE"
    elseif opcode == 0xb025 then
        opcodeDesc = "SERVER_CHAT_INDEX"

    elseif opcode == 0xb034 then
        opcodeDesc = "SERVER_ITEM_MOVE"

    elseif opcode == 0xb045 then
        opcodeDesc = "SERVER_SELECT_OBJECT"
    elseif opcode == 0xb046 then
        opcodeDesc = "SERVER_OPEN_NPC"
    elseif opcode == 0xb04b then
        opcodeDesc = "SERVER_CLOSE_NPC"
    elseif opcode == 0xb04c then
        opcodeDesc = "SERVER_PLAYER_HANDLE_UPDATE_SLOT 2"

    elseif opcode == 0xb050 then
        opcodeDesc = "SERVER_PLAYER_UPDATE_STR"
    elseif opcode == 0xb051 then
        opcodeDesc = "SERVER_PLAYER_UPDATE_INT"
    elseif opcode == 0xb059 then
        opcodeDesc = "SERVER_SAVE_PLACE"
    elseif opcode == 0xb05a then
        opcodeDesc = "SERVER_TELEPORTSTART"

    elseif opcode == 0xb060 then
        opcodeDesc = "SERVER_PARTY_RESPONSE"
    elseif opcode == 0xb067 then
        opcodeDesc = "SERVER_PARTY_MEMBER"
    elseif opcode == 0xb069 then
        opcodeDesc = "SERVER_FORMED_PARTY_CREATED"
    elseif opcode == 0xb06a then
        opcodeDesc = "SERVER_PARTY_CHANGENAME"
    elseif opcode == 0xb06b then
        opcodeDesc = "SERVER_DELETE_FORMED_PARTY"
    elseif opcode == 0xb06c then
        opcodeDesc = "SERVER_SEND_PARTYLIST"
    elseif opcode == 0xb06d then
        opcodeDesc = "SERVER_JOIN_FORMED_PARTY_RESPONSE"
    elseif opcode == 0xb06f then
        opcodeDesc = "SERVER_SHOW_PARTY_FORMATION"

    elseif opcode == 0xb070 then
        opcodeDesc = "SERVER_ACTION_DATA"
    elseif opcode == 0xb071 then
        opcodeDesc = "SERVER_SKILL_DATA"
    elseif opcode == 0xb072 then
        opcodeDesc = "SERVER_SKILL_ENDBUFF"
    elseif opcode == 0xb074 then
        opcodeDesc = "SERVER_ACTIONSTATE"

    elseif opcode == 0xb084 then
        opcodeDesc = "SERVER_OPEN_SPECIAL_WINDOW"

    elseif opcode == 0xb0a1 then
        opcodeDesc = "SKILL_ADD_RESPONSE"

    elseif opcode == 0xb0b1 then
        opcodeDesc = "SERVER_STALL_OPENED"
    elseif opcode == 0xb0b2 then
        opcodeDesc = "SERVER_STALL_CLOSED"
    elseif opcode == 0xb0b3 then
        opcodeDesc = "SERVER_STALL_VIEW"
    elseif opcode == 0xb0b4 then
        opcodeDesc = "SERVER_STALL_BUY"
    elseif opcode == 0xb0b5 then
        opcodeDesc = "SERVER_STALL_OTHER_CLOSE"
    elseif opcode == 0xb0ba then
        opcodeDesc = "SERVER_STALL_ACTION"
    elseif opcode == 0xb0bd then
        opcodeDesc = "SERVER_SKILL_ICON"

    elseif opcode == 0xb0ea then
        opcodeDesc = "SERVER_SEND_GUIDE"

    elseif opcode == 0xb0f3 then
        opcodeDesc = "SERVER_GUILD_INVITE"

    elseif opcode == 0xb105 then
        opcodeDesc = "VOTE_FOR_NEW_LEADER_RESPONSE"
    elseif opcode == 0xb168 then
        opcodeDesc = "SERVER_SELL_SUCCESS"

    elseif opcode == 0xb250 then
        opcodeDesc = "SERVER_OPEN_GUILD_STORAGE"
    elseif opcode == 0xb251 then
        opcodeDesc = "SERVER_CLOSE_GUILD_STORAGE"

    elseif opcode == 0xb302 then
        opcodeDesc = "SERVER_FRIEND_INVITE"
    elseif opcode == 0xb30b then
        opcodeDesc = "CLIENT_MAILBOX_RESPONSE"

    elseif opcode == 0xb402 then
        opcodeDesc = "SERVER_QUESTMARK"
    elseif opcode == 0xb478 then
        opcodeDesc = "SERVER_OPEN_HONOR_RANKLIST"
    elseif opcode == 0xb47d then
        opcodeDesc = "SERVER_ACADEMY_MATCHING_RESPONSE"

    elseif opcode == 0xb501 then
        opcodeDesc = "SERVER_OPEN_GUILD_USAGE"
    elseif opcode == 0xb504 then
        opcodeDesc = "Styria clash registration"
    elseif opcode == 0xb507 then
        opcodeDesc = "SERVER_STALL_NETWORK_CLOSE_RESPONSE"
    elseif opcode == 0xb50a then
        opcodeDesc = "SERVER_STALL_NETWORK_BUY_RESPONSE"
    elseif opcode == 0xb50c then
        opcodeDesc = "SERVER_STALL_NETWORK_SEARCH_RESPONSE"
    elseif opcode == 0xb50e then
        opcodeDesc = "STATE AFTER TELEPORT"

    elseif opcode == 0xb516 then
        opcodeDesc = "SERVER_PVP_DATA"

    elseif opcode == 0xb533 then
        opcodeDesc = "SERVER_SETTLE_CONSIGMENT_RESPONSE"
    elseif opcode == 0xb534 then
        opcodeDesc = "SERVER_LEARN_RECEIPE"

    elseif opcode == 0xb554 then
        opcodeDesc = "SERVER_SET_MACROS"
    elseif opcode == 0xb557 then
        opcodeDesc = "SERVER_ITEM_STORAGE_BOX"
    elseif opcode == 0xb559 then
        opcodeDesc = "SERVER_ITEM_BOX_LOG"
    elseif opcode == 0xb55d then
        opcodeDesc = "SERVER_ITEM_MALL"

    elseif opcode == 0xb574 then
        opcodeDesc = "SERVER_BALOON_UP_RESPONSE"
    else
        opcodeDesc = "UNKNOWN"
    end
    return opcodeDesc
end

return OPCODES