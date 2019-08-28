getmetatable('').__call = string.sub

silkroad_protocol = Proto("silkroad","Silkroad Protocol");

silkroad_protocol.fields = {}
local header = silkroad_protocol.fields
header.datasize = ProtoField.new("Data size", "silkroad.header.data_length", ftypes.UINT16)
header.opcode = ProtoField.uint16("silkroad.header.opcode", "Opcode", base.HEX)
header.security = ProtoField.new("Security", "silkroad.header.security", ftypes.UINT16)

local data = silkroad_protocol.fields

data.service_name_len = ProtoField.new("Length of service name", "silkroad.data.service_name_len", ftypes.UINT16)
data.service_name = ProtoField.new("Service name", "silkroad.data.service_name", ftypes.STRING)
data.service_type = ProtoField.new("Service type", "silkroad.data.service_type", ftypes.STRING)

data.flag = ProtoField.uint8("silkroad.data.flag", "Flag", base.HEX)
data.blowfish = ProtoField.new("Blowfish", "silkroad.data.blowfish", ftypes.UINT64)
data.count_seed = ProtoField.new("Count seed", "silkroad.data.count_seed", ftypes.UINT32)
data.crc_seed = ProtoField.new("CRC seed", "silkroad.data.crc_seed", ftypes.UINT32)
data.seed_1 = ProtoField.new("Seed 1", "silkroad.data.seed_1", ftypes.UINT32)
data.seed_2 = ProtoField.new("Seed 2", "silkroad.data.seed_2", ftypes.UINT32)
data.seed_3 = ProtoField.new("Seed 3", "silkroad.data.seed_3", ftypes.UINT32)
data.seed_4 = ProtoField.new("Seed 4", "silkroad.data.seed_4", ftypes.UINT32)
data.seed_5 = ProtoField.new("Seed 5", "silkroad.data.seed_5", ftypes.UINT32)

data.ps_count = ProtoField.new("Ping servers count", "silkroad.data.ps_count", ftypes.UINT8)
data.ps_id = ProtoField.new("Ping server ID", "silkroad.data.ps_id", ftypes.UINT8)
data.ps_name_len = ProtoField.new("Ping server name length", "silkroad.data.ps_name_len", ftypes.UINT16)
data.ps_name = ProtoField.new("Ping server name", "silkroad.data.ps_name", ftypes.STRING)
data.ps_port = ProtoField.new("Ping server port", "silkroad.data.ps_port", ftypes.UINT16)

function silkroad_protocol.dissector(buffer, pinfo, tree)
	local size = buffer(0,2)
	local opcode = buffer(2,2)
	local security = buffer(4,2)
	
	local is_encrypted = tostring(buffer(1,1)) == "80"
	
	pinfo.cols.protocol = "Silkroad Protocol"
	
	local baba = tree:add(silkroad_protocol, buffer(0,-1), "Silkroad Protocol")
	
	local tree_header = baba:add(silkroad_protocol, buffer(0,6), "Silkroad Protocol Header")
	tree_header:add_le(header.datasize, size);
	tree_header:add_le(header.opcode, opcode);
	tree_header:add_le(header.security, security);
	
	pinfo.cols.info = "0x" .. string.upper(tostring(opcode)(3,4)) .. string.upper(tostring(opcode)(0,2));
	
	if is_encrypted then
		pinfo.cols.info:append(" /E/")
	end
	
	local tree_data = baba:add(silkroad_protocol, buffer(6, -1), "Silkroad Protocol Data")
	
	if tostring(buffer(2,2)) == "0120" then -- 0x2001
		local service_name_len = buffer(6,2)
		local service_name_len_val = buffer(6,2):le_uint()
		
		local service_name = buffer(8, service_name_len_val)
		
		local service_type = buffer(8 + service_name_len_val, 1)
		
		tree_data:add_le(data.service_name_len, service_name_len);
		tree_data:add(data.service_name, service_name);
		if service_type:le_uint() == True then
			tree_data:add(data.service_type, service_type, "module - module");
		else
			tree_data:add(data.service_type, service_type, "machine - machine");
		end
		
		pinfo.cols.info:append(" SERVER_GLOBAL_IDENTIFICATION")
	elseif tostring(buffer(2, 2)) == "0090" then -- 0x9000
		pinfo.cols.info:append(" CLIENT_GLOBAL_HANDSHAKE_ACCEPT")
	elseif tostring(buffer(2, 2)) == "0050" then -- 0x5000
		local flag = buffer(6, 1) -- 8
		tree_data:add_le(data.flag, flag)
		if flag:le_uint() == 0x0E then
			local blowfish = buffer(7, 8) -- 64
			local count_seed = buffer(15, 4) -- 32
			local crc_seed = buffer(19, 4) -- 32
			local seed_1 = buffer(23, 4) -- 32
			local seed_2 = buffer(27, 4) -- 32
			local seed_3 = buffer(31, 4) -- 32
			local seed_4 = buffer(35, 4) -- 32
			local seed_5 = buffer(39, 4) -- 32
			tree_data:add_le(data.blowfish, blowfish)
			tree_data:add_le(data.count_seed, count_seed)
			tree_data:add_le(data.crc_seed, crc_seed)
			tree_data:add_le(data.seed_1, seed_1)
			tree_data:add_le(data.seed_2, seed_2)
			tree_data:add_le(data.seed_3, seed_3)
			tree_data:add_le(data.seed_4, seed_4)
			tree_data:add_le(data.seed_5, seed_5)
			pinfo.cols.info:append(" SERVER_GLOBAL_HANDSHAKE")
		elseif flag:le_uint() == 0x10 then
			local blowfish = buffer(7, 8)
			tree_data:add_le(data.blowfish, blowfish)
			pinfo.cols.info:append(" SERVER_GLOBAL_HANDSHAKE")
		end
	elseif tostring(buffer(2,2)) == "0461" then -- 0x6104
		pinfo.cols.info:append(" CLIENT_GATEWAY_NOTICE_REQUEST")
	elseif tostring(buffer(2,2)) == "0d60" then -- 0x600D
		pinfo.cols.info:append(" TODO Massive")
	elseif tostring(buffer(2,2)) == "07a1" then -- 0xA107
		pinfo.cols.info:append(" TODO NN")

		local ps = {}
		local ps_count = buffer(6, 1)
		tree_data:add_le(data.ps_count, ps_count) 
		
		local start = 7
		
		
		local ps_item_len
		
		for i =1, ps_count:le_uint() do
		
			local start_backup = start
			ps[i] = {}
			ps[i]["id"] = buffer(start, 1)
			start = start + 1
			ps[i]["name_length"] = buffer(start, 2)
			start = start + 2
			ps[i]["name"] = buffer(start, tonumber(ps[i]["name_length"]))
			start = start + ps[i]["name_length"]:le_uint()
			ps[i]["port"] = buffer(start, 2)
			--start = start + 1
			local a = tree_data:add(buffer(start_backup, start - start_backup + 1), i)
			a:add_le(data.ps_id, ps[i]["id"])
			a:add_le(data.ps_name_len, ps[i]["name_length"])
			a:add_le(data.ps_name, ps[i]["name"])
			a:add_le(data.ps_port, ps[i]["port"])
			i = i + 1

		end
	
	elseif tostring(buffer(2,2)) == "01a1" then -- 0xA101
		pinfo.cols.info:append(" TODO XOXO")
	elseif tostring(buffer(2,2)) == "1621" then -- 0x2116
		pinfo.cols.info:append(" TODO I_WANNA_INPUT_A_CODE_RESPONSE")
	elseif tostring(buffer(2,2)) == "17a1" then -- 0xA117
		pinfo.cols.info:append(" TODO I_SENT_A_CODE_RESPONSE 1")
	elseif tostring(buffer(2,2)) == "0e21" then -- 0x210E -- Queue info?
	 -- flaga byte, max short, time float, current short
		pinfo.cols.info:append(" TODO SERVER_QUEUE_INFO")
	elseif tostring(buffer(2,2)) == "0770" then -- 0x7007
		pinfo.cols.info:append(" TODO CLIENT_CHAR_RELATED")
	elseif tostring(buffer(2,2)) == "07b0" then -- 0xB007
		pinfo.cols.info:append(" TODO SERVER_CHAR_RELATED")
	elseif tostring(buffer(2,2)) == "0220" then -- 0x2002
		pinfo.cols.info:append(" CLIENT_GLOBAL_KEEP_ALIVE")
	elseif tostring(buffer(2,2)) == "2170" then -- 0x7021	
		pinfo.cols.info:append(" CLIENT_MOVE_REQUEST")
	elseif tostring(buffer(2,2)) == "21b0" then -- 0xB021
		pinfo.cols.info:append(" SERVER_MOVE_RESPONSE")
	elseif tostring(buffer(2,2)) == "2470" then -- 0x7024
		pinfo.cols.info:append(" CLIENT_ANGLE_MOVE")
	elseif tostring(buffer(2,2)) == "24b0" then -- 0xB024
		pinfo.cols.info:append(" SERVER_ANGLE")
	elseif tostring(buffer(2,2)) == "0c30" then -- 0x300C
		pinfo.cols.info:append(" UNIQUE_ANNOUNCE")
	elseif tostring(buffer(2,2)) == "be34" then -- 0x34be
		pinfo.cols.info:append(" AGENT_GAME_SERVERTIME")
	elseif tostring(buffer(2,2)) == "b134" then -- 0x34b1
		pinfo.cols.info:append(" SERVER_SEND_EVENT_MSG")
	elseif tostring(buffer(2,2)) == "f538" then -- 0x38f5
		pinfo.cols.info:append(" SERVER_GUILD_UPDATE")-- not sure
	elseif tostring(buffer(2,2)) == "a270" then -- 0x70A2
		pinfo.cols.info:append(" MASTERY_SKILL_ADD_REQUEST")
	elseif tostring(buffer(2,2)) == "4e30" then -- 0x304e
		pinfo.cols.info:append(" AFTER_MASTERY_ADD_ITS_RESPONSE 1")
	elseif tostring(buffer(2,2)) == "a2b0" then -- 0xA2B0
		pinfo.cols.info:append(" AFTER_MASTERY_ADD_ITS_RESPONSE 2")
		
	elseif tostring(buffer(2,2)) == "a170" then -- 0x70a1
		pinfo.cols.info:append(" SKILL_ADD_REQUEST")
		
	elseif tostring(buffer(2,2)) == "a1b0" then -- 0xb0a1
		pinfo.cols.info:append(" SKILL_ADD_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "5871" then -- 0x7158
		pinfo.cols.info:append(" SKILL_ADD_RELATED_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "7335" then -- 0x3573
		pinfo.cols.info:append(" BALOONS_ANNOUNCE")
		
	elseif tostring(buffer(2,2)) == "3470" then -- 0x7034
		pinfo.cols.info:append(" ITEM_MOVED_TO_OTHER_SLOT")
		
	elseif tostring(buffer(2,2)) == "2730" then -- 0x3027
		pinfo.cols.info:append(" SERVER_ITEM_UN_EFFECT")
		
	elseif tostring(buffer(2,2)) == "3930" then -- 0x3039
		pinfo.cols.info:append(" SERVER_ITEM_UN_EFFECT")
		
	elseif tostring(buffer(2,2)) == "3830" then -- 0x3038
		pinfo.cols.info:append(" SERVER_ITEM_EFFECT")
		
	elseif tostring(buffer(2,2)) == "d030" then -- 0x30D0
		pinfo.cols.info:append(" SERVER_SETSPEED")
		
	elseif tostring(buffer(2,2)) == "3d30" then -- 0x303d
		pinfo.cols.info:append(" SERVER_PLAYERSTAT")
		
	elseif tostring(buffer(2,2)) == "1330" then -- 0x3013
		pinfo.cols.info:append(" SERVER_PLAYERDATA")
		
	elseif tostring(buffer(2,2)) == "71b0" then -- 0xb071
		pinfo.cols.info:append(" SERVER_SKILL_DATA")
		
	elseif tostring(buffer(2,2)) == "4570" then -- 0x7045
		pinfo.cols.info:append(" CLIENT_SELECT_OBJECT")
		
	elseif tostring(buffer(2,2)) == "45b0" then -- 0xb045
		pinfo.cols.info:append(" SERVER_SELECT_OBJECT")
		
	elseif tostring(buffer(2,2)) == "bdb0" then -- 0xb0bd
		pinfo.cols.info:append(" SERVER_SKILL_ICON")
		
	elseif tostring(buffer(2,2)) == "703e" then -- 0x3e70
		pinfo.cols.info:append(" LOGG OFF OR DISC 1")
		
	elseif tostring(buffer(2,2)) == "713e" then -- 0x3e71
		pinfo.cols.info:append(" LOGG OFF OR DISC 2")
		
	elseif tostring(buffer(2,2)) == "073b" then -- 0x3b07
		pinfo.cols.info:append(" SERVER_FRIEND_DATA")
		
	elseif tostring(buffer(2,2)) == "f970" then -- 0x70f9
		pinfo.cols.info:append(" CLIENT_GUILD_MESSAGE")
		
	elseif tostring(buffer(2,2)) == "23b0" then -- 0xb023
		pinfo.cols.info:append(" SERVER_MOVE_INTERRUPT")
		
	elseif tostring(buffer(2,2)) == "1530" then -- 0x3015
		pinfo.cols.info:append(" SERVER_SOLO_SPAWN")
		
	elseif tostring(buffer(2,2)) == "1630" then -- 0x3016
		pinfo.cols.info:append(" SERVER_SOLO_DESPAWN")
		
	elseif tostring(buffer(2,2)) == "bf30" then -- 0x30bf ??
		pinfo.cols.info:append(" SERVER_CHANGE_STATUS")
		
	elseif tostring(buffer(2,2)) == "70b0" then -- 0xb070
		pinfo.cols.info:append(" SERVER_ACTION_DATA")
		
	elseif tostring(buffer(2,2)) == "0273" then -- 0x7302
		pinfo.cols.info:append(" CLIENT_FRIEND_INVITE")
		
	elseif tostring(buffer(2,2)) == "02b3" then -- 0xB302
		pinfo.cols.info:append(" SERVER_FRIEND_INVITE")
		
	elseif tostring(buffer(2,2)) == "5330" then -- 0x3053
		pinfo.cols.info:append(" CLIENT_GETUP")
		
	elseif tostring(buffer(2,2)) == "b634" then -- 0x34B6
		pinfo.cols.info:append(" CLIENT_TELEPORTDATA")
		
	elseif tostring(buffer(2,2)) == "a534" then -- 0x34A5
		pinfo.cols.info:append(" SERVER_STARTPLAYERDATA")
		
	elseif tostring(buffer(2,2)) == "4670" then -- 0x7046
		pinfo.cols.info:append(" CLIENT_OPEN_NPC")
		
	elseif tostring(buffer(2,2)) == "46b0" then -- 0xb046
		pinfo.cols.info:append(" SERVER_OPEN_NPC")
		
	elseif tostring(buffer(2,2)) == "4b70" then -- 0x704b
		pinfo.cols.info:append(" CLIENT_CLOSE_NPC")
		
	elseif tostring(buffer(2,2)) == "4bb0" then -- 0xb04b
		pinfo.cols.info:append(" SERVER_CLOSE_NPC")
		
	elseif tostring(buffer(2,2)) == "34b0" then -- 0xb034
		pinfo.cols.info:append(" SERVER_ITEM_MOVE")
		
	elseif tostring(buffer(2,2)) == "2630" then -- 0x3026
		pinfo.cols.info:append(" SERVER_CHAT")
		
	elseif tostring(buffer(2,2)) == "1830" then -- 0x3018
		pinfo.cols.info:append(" SERVER_GROUPSPAWN_END")
		
	elseif tostring(buffer(2,2)) == "7d74" then -- 0x747d
		pinfo.cols.info:append(" CLIENT_ACADEMY_MATCHING_REQUEST")
		
	elseif tostring(buffer(2,2)) == "7474" then -- 0x7474
		pinfo.cols.info:append(" CLIENT_ACADEMY_LEAVE")
		
	elseif tostring(buffer(2,2)) == "7db4" then -- 0xB47d
		pinfo.cols.info:append(" SERVER_ACADEMY_MATCHING_RESPONSE")

	elseif tostring(buffer(2,2)) == "d234" then -- 0x34d2
		pinfo.cols.info:append(" The request for the party denied.") -- mb?
	
	elseif tostring(buffer(2,2)) == "9130" then -- 0x3091
		pinfo.cols.info:append(" CLIENT_SERVER_EMOTE")
				
	elseif tostring(buffer(2,2)) == "0571" then -- 0x7105
		pinfo.cols.info:append(" VOTE_FOR_NEW_LEADER_REQUEST")
				
	elseif tostring(buffer(2,2)) == "05b1" then -- 0xb105
		pinfo.cols.info:append(" VOTE_FOR_NEW_LEADER_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "5172" then -- 0x7251
		pinfo.cols.info:append(" CLIENT_CLOSE_GUILD_STORAGE")
		
	elseif tostring(buffer(2,2)) == "51b2" then -- 0xB251
		pinfo.cols.info:append(" SERVER_CLOSE_GUILD_STORAGE")
		
	elseif tostring(buffer(2,2)) == "0175" then -- 0x7501
		pinfo.cols.info:append(" CLIENT_OPEN_GUILD_USAGE")
		
	elseif tostring(buffer(2,2)) == "01b5" then -- 0xB501
		pinfo.cols.info:append(" SERVER_OPEN_GUILD_USAGE")
		
	elseif tostring(buffer(2,2)) == "5072" then -- 0x7250
		pinfo.cols.info:append(" CLIENT_OPEN_GUILD_STORAGE")
		
	elseif tostring(buffer(2,2)) == "50b2" then -- 0xB250
		pinfo.cols.info:append(" SERVER_OPEN_GUILD_STORAGE")
		
	elseif tostring(buffer(2,2)) == "5272" then -- 0x7252
		pinfo.cols.info:append(" CLIENT_OPEN_GUILD_STORAGE2")
		
	elseif tostring(buffer(2,2)) == "5332" then -- 0x3253
		pinfo.cols.info:append(" SERVER_GUILD_STORAGE_GOLD")
		
	elseif tostring(buffer(2,2)) == "5532" then -- 3255
		pinfo.cols.info:append(" SERVER_GUILD_STORAGE3")

	elseif tostring(buffer(2,2)) == "04b5" then -- 0xb504
		pinfo.cols.info:append(" ?? Styria clash registration?") -- probably not

	elseif tostring(buffer(2,2)) == "3c70" then -- 0x303c
		pinfo.cols.info:append(" CLIENT_OPEN_WAREHOUSE")
		
	elseif tostring(buffer(2,2)) == "4730" then -- 0x3047
		pinfo.cols.info:append(" SERVER_OPEN_WAREHOUSE")
		
	elseif tostring(buffer(2,2)) == "5230" then -- 3052
		pinfo.cols.info:append(" SERVER_REPAIR_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "4130" then -- 3041
		pinfo.cols.info:append(" SERVER_PVP_WAIT")
		
	elseif tostring(buffer(2,2)) == "72b0" then -- b072
		pinfo.cols.info:append(" SERVER_SKILL_ENDBUFF")
		
	elseif tostring(buffer(2,2)) == "2370" then -- 7023
		pinfo.cols.info:append(" START_PLAYER_CONTROL (arrows)")
		
	elseif tostring(buffer(2,2)) == "1675" then -- 7516
		pinfo.cols.info:append(" CLIENT_PVP")
		
	elseif tostring(buffer(2,2)) == "4230" then -- 3042
		pinfo.cols.info:append(" SERVER_PVP_INTERUPT")
		
	elseif tostring(buffer(2,2)) == "16b5" then -- b516
		pinfo.cols.info:append(" SERVER_PVP_DATA")
		
	elseif tostring(buffer(2,2)) == "0274" then -- 7402
		pinfo.cols.info:append(" CLIENT_QUESTMARK")
		
	elseif tostring(buffer(2,2)) == "02b4" then -- B402
		pinfo.cols.info:append(" SERVER_QUESTMARK")
		
	elseif tostring(buffer(2,2)) == "b170" then -- 70b1
		pinfo.cols.info:append(" CLIENT_STALL_OPEN")
		
	elseif tostring(buffer(2,2)) == "ba70" then -- 70ba
		pinfo.cols.info:append(" CLIENT_STALL_ACTION")
		
	elseif tostring(buffer(2,2)) == "b830" then -- 30b8
		pinfo.cols.info:append(" SERVER_STALL_OPEN")
		
	elseif tostring(buffer(2,2)) == "b1b0" then -- b0b1
		pinfo.cols.info:append(" SERVER_STALL_OPENED")
		
	elseif tostring(buffer(2,2)) == "bab0" then -- b0ba
		pinfo.cols.info:append(" SERVER_STALL_ACTION")
		
	elseif tostring(buffer(2,2)) == "b270" then -- 70B2
		pinfo.cols.info:append(" CLIENT_STALL_CLOSE")
		
	elseif tostring(buffer(2,2)) == "b930" then -- 30b9
		pinfo.cols.info:append(" SERVER_STALL_CLOSE")
		
	elseif tostring(buffer(2,2)) == "b2b0" then -- b0b2
		pinfo.cols.info:append(" SERVER_STALL_CLOSED")
		
	elseif tostring(buffer(2,2)) == "a770" then -- 70a7
		pinfo.cols.info:append(" CLIENT_PLAYER_BERSERK")
		
	elseif tostring(buffer(2,2)) == "5970" then -- 7059
		pinfo.cols.info:append(" CLIENT_SAVE_PLACE")
		
	elseif tostring(buffer(2,2)) == "59b0" then -- B059
		pinfo.cols.info:append(" SERVER_SAVE_PLACE")
		
	elseif tostring(buffer(2,2)) == "7874" then -- 7478
		pinfo.cols.info:append(" CLIENT_OPEN_HONOR_RANKLIST")
		
	elseif tostring(buffer(2,2)) == "78b4" then -- B478
		pinfo.cols.info:append(" SERVER_OPEN_HONOR_RANKLIST")
		
	elseif tostring(buffer(2,2)) == "d330" then -- 30d3
		pinfo.cols.info:append(" CLIENT_NPC_QUEST -- ?")
		
	elseif tostring(buffer(2,2)) == "d430" then -- 30d4
		pinfo.cols.info:append(" SERVER_NPC_QUEST")
		
	elseif tostring(buffer(2,2)) == "d530" then -- 30d5
		pinfo.cols.info:append(" SERVER_NPC_QUEST_ACCEPT")
		
	elseif tostring(buffer(2,2)) == "d630" then -- 30d6
		pinfo.cols.info:append(" SERVER_NPC_QUEST_DRAW_ICON")
		
	elseif tostring(buffer(2,2)) == "d730" then -- 30d7
		pinfo.cols.info:append(" SERVER_NPC_QUEST_CLEAR_ICON") -- not sure
		
	elseif tostring(buffer(2,2)) == "8030" then -- 0x3080
		pinfo.cols.info:append(" CLIENT_PARTY_REQUEST")
		
	elseif tostring(buffer(2,2)) == "8030" then -- 0x3080
		pinfo.cols.info:append(" SERVER_PARTY_MEMBER")
		
	elseif tostring(buffer(2,2)) == "74b0" then -- 0xb074
		pinfo.cols.info:append(" SERVER_ACTIONSTATE")
		
	elseif tostring(buffer(2,2)) == "7470" then -- 0x7074
		pinfo.cols.info:append(" CLIENT_SKILL_USE_REQUEST")
	elseif tostring(buffer(2,2)) == "67b0" then -- 0xB067
		pinfo.cols.info:append(" SERVER_PARTY_MEMBER")
		
	elseif tostring(buffer(2,2)) == "2570" then -- 0x7025
		pinfo.cols.info:append(" CLIENT_CHAT")
		
	elseif tostring(buffer(2,2)) == "5730" then -- 0x3057
		pinfo.cols.info:append(" SERVER_SKILL_EFFECTS")

	elseif tostring(buffer(2,2)) == "7830" then -- 0x3078
		pinfo.cols.info:append(" SERVER_GUILD_STORAGE4") -- not sure

	elseif tostring(buffer(2,2)) == "803c" then -- 0x3C80
		pinfo.cols.info:append(" AGENT_ACADEMY_UPDATE")
		
	elseif tostring(buffer(2,2)) == "0938" then -- 0x3809
		pinfo.cols.info:append(" SERVER_AGENT_ENVIRONMENT_WEATHER_UPDATE")
	
	elseif tostring(buffer(2,2)) == "1730" then -- 0x3017
		pinfo.cols.info:append(" SERVER_GROUPSPAWN_START")
		
	elseif tostring(buffer(2,2)) == "d230" then -- 0x30d2
		pinfo.cols.info:append(" SERVER_TELEPORTOTHERSTART")
		
	elseif tostring(buffer(2,2)) == "1930" then -- 0x3019
		pinfo.cols.info:append(" SERVER_GROUPSPAWN_DATA")
		
	elseif tostring(buffer(2,2)) == "5c30" then -- 0x305c
		pinfo.cols.info:append(" SERVER_PLAYER_HANDLE_EFFECT")
		
	elseif tostring(buffer(2,2)) == "3475" then -- 0x7534
		pinfo.cols.info:append(" CLIENT_LEARN_RECEIPE")
		
	elseif tostring(buffer(2,2)) == "34b5" then -- 0xB534
		pinfo.cols.info:append(" SERVER_LEARN_RECEIPE")
		
	elseif tostring(buffer(2,2)) == "6871" then -- 0x7168
		pinfo.cols.info:append(" CLIENT_NPC_BUYPACK") -- not sure
		
	elseif tostring(buffer(2,2)) == "4cb0" then -- 0xB04C
		pinfo.cols.info:append(" SERVER_PLAYER_HANDLE_UPDATE_SLOT 2")

	elseif tostring(buffer(2,2)) == "68b1" then -- 0xb168
		pinfo.cols.info:append(" SERVER_SELL_SUCCESS? I DO NOT KNOW")
		
	elseif tostring(buffer(2,2)) == "1435" then -- 0x3514
		pinfo.cols.info:append(" SERVER_OPEN_NPC_ITEM_WINDOW guess only...")
		
	elseif tostring(buffer(2,2)) == "ec30" then -- 0x30ec
		pinfo.cols.info:append(" SERVER_CLOSE_NPC_ITEM_WINDOW_ACTION guess1")
		
	elseif tostring(buffer(2,2)) == "1435" then -- 0x3514
		pinfo.cols.info:append(" SERVER_CLOSE_NPC_ITEM_WINDOW_ACTION guess1")
		
	elseif tostring(buffer(2,2)) == "1575" then -- 0x7515
		pinfo.cols.info:append(" SERVER_CLOSE_NPC ITEM ???")

	elseif tostring(buffer(2,2)) == "6438" then -- 0x3864
		pinfo.cols.info:append(" SERVER_PARTY_DATA")
		
	elseif tostring(buffer(2,2)) == "6c70" then -- 0x706c
		pinfo.cols.info:append(" CLIENT_PARTYMATCHING_LIST_REQUEST")
		
	elseif tostring(buffer(2,2)) == "6cb0" then -- 0xb06c
		pinfo.cols.info:append(" SERVER_SEND_PARTYLIST")
		
	elseif tostring(buffer(2,2)) == "6170" then -- 0x7061
		pinfo.cols.info:append(" CLIENT_PARTY_LEAVE")
		
	elseif tostring(buffer(2,2)) == "6970" then -- 0x7069
		pinfo.cols.info:append(" CLIENT_CREATE_FORMED_PARTY")
		
	elseif tostring(buffer(2,2)) == "69b0" then -- 0xb069
		pinfo.cols.info:append(" SERVER_FORMED_PARTY_CREATED")
		
	elseif tostring(buffer(2,2)) == "6a70" then -- 0x706a
		pinfo.cols.info:append(" CLIENT_CHANGE_PARTY_NAME")
		
	elseif tostring(buffer(2,2)) == "6ab0" then -- 0xb06a
		pinfo.cols.info:append(" SERVER_PARTY_CHANGENAME")
		
	elseif tostring(buffer(2,2)) == "6b70" then -- 0x706b
		pinfo.cols.info:append(" CLIENT_DELETE_FORMED_PARTY")
		
	elseif tostring(buffer(2,2)) == "6bb0" then -- 0xb06b
		pinfo.cols.info:append(" SERVER_DELETE_FORMED_PARTY")
		
	elseif tostring(buffer(2,2)) == "6d70" then -- 0x706d
		pinfo.cols.info:append(" CLIENT_JOIN_FORMED_PARTY_REQUEST")
		
	elseif tostring(buffer(2,2)) == "6db0" then -- 0xb06d
		pinfo.cols.info:append(" SERVER_JOIN_FORMED_PARTY_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "5a65" then -- 0x655a
		pinfo.cols.info:append(" CLIENT_SHOW_PARTY_FORMATION")
		
	elseif tostring(buffer(2,2)) == "6f70" then -- 0x706f
		pinfo.cols.info:append(" CLIENT_SHOW_PARTY_FORMATION")
		
	elseif tostring(buffer(2,2)) == "6fb0" then -- 0xb06f
		pinfo.cols.info:append(" SERVER_SHOW_PARTY_FORMATION")
		
	elseif tostring(buffer(2,2)) == "5475" then -- 0x7554
		pinfo.cols.info:append(" CLIENT_SET_MACROS")
		
	elseif tostring(buffer(2,2)) == "54b5" then -- 0xB554
		pinfo.cols.info:append(" SERVER_SET_MACROS")
		
	elseif tostring(buffer(2,2)) == "0132" then -- 0x3201
		pinfo.cols.info:append(" SERVER_ARROW_UPDATE")
		
	elseif tostring(buffer(2,2)) == "3735" then -- 0x3537
		pinfo.cols.info:append(" SETTINGS_CHANGED")
		
	elseif tostring(buffer(2,2)) == "4d30" then -- 0x304d
		pinfo.cols.info:append(" SERVER_ITEM_DELETE")
		
	elseif tostring(buffer(2,2)) == "5d75" then -- 0x755d
		pinfo.cols.info:append(" CLIENT_ITEM_MALL")
		
	elseif tostring(buffer(2,2)) == "5db5" then -- 0xb55d
		pinfo.cols.info:append(" SERVER_ITEM_MALL")
		
	elseif tostring(buffer(2,2)) == "5830" then -- 0x3058
		pinfo.cols.info:append(" SERVER_EFFECT_DAMAGE") -- crit?
		
	elseif tostring(buffer(2,2)) == "5a70" then -- 0x705a
		pinfo.cols.info:append(" CLIENT_TELEPORTSTART")
		
	elseif tostring(buffer(2,2)) == "5ab0" then -- b05a
		pinfo.cols.info:append(" SERVER_TELEPORTSTART")
		
	elseif tostring(buffer(2,2)) == "a634" then -- 34a6
		pinfo.cols.info:append(" SERVER_ENDPLAYERDATA")
	
	elseif tostring(buffer(2,2)) == "0e75" then -- 750e
		pinfo.cols.info:append(" CLIENT_REQUEST_WEATHER")
		
	elseif tostring(buffer(2,2)) == "0533" then -- 3305
		pinfo.cols.info:append(" SERVER_SEND_FRIEND_LIST")
		
	elseif tostring(buffer(2,2)) == "0eb5" then -- B50e
		pinfo.cols.info:append(" UNKNOWN? STATE AFTER TELEPORT ???")
		
	elseif tostring(buffer(2,2)) == "0b73" then -- 730b
		pinfo.cols.info:append(" CLIENT_MAILBOX_REQUEST")
		
	elseif tostring(buffer(2,2)) == "0bb3" then -- b30b
		pinfo.cols.info:append(" CLIENT_MAILBOX_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "1136" then -- 3611
		pinfo.cols.info:append(" SERVER_SUCCESSFULL_ENCHANT")
		
	elseif tostring(buffer(2,2)) == "b534" then -- 34b5
		pinfo.cols.info:append(" SERVER_TELEPORTIMAGE")
		
	elseif tostring(buffer(2,2)) == "7d35" then -- 357d
		pinfo.cols.info:append(" BALOON_IS_MOVING_DOWN ???")
		
	elseif tostring(buffer(2,2)) == "7e35" then -- 357e
		pinfo.cols.info:append(" BALOON_IS_MOVING_UP ???")
		
	elseif tostring(buffer(2,2)) == "4030" then -- 3040
		pinfo.cols.info:append(" BALOON_EXCHANGE")
		
	elseif tostring(buffer(2,2)) == "7c35" then -- 357c
		pinfo.cols.info:append(" SERVER_BALOON_USE_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "7475" then -- 7574
		pinfo.cols.info:append(" CLIENT_BALOON_UP_REQUEST")
		
	elseif tostring(buffer(2,2)) == "74b5" then -- B574
		pinfo.cols.info:append(" SERVER_BALOON_UP_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "4930" then -- 3049
		pinfo.cols.info:append(" SERVER_OPEN_WAREPROB")
		
	elseif tostring(buffer(2,2)) == "bb30" then -- 30bb
		pinfo.cols.info:append(" SERVER_STALL_RENAME")
		
	elseif tostring(buffer(2,2)) == "b370" then -- 70b3
		pinfo.cols.info:append(" CLIENT_STALL_OTHER_OPEN")
		
	elseif tostring(buffer(2,2)) == "b570" then -- 70b5
		pinfo.cols.info:append(" CLIENT_STALL_OTHER_CLOSE")
		
	elseif tostring(buffer(2,2)) == "b3b0" then -- b0b3
		pinfo.cols.info:append(" SERVER_VIEW_STALL")
		
	elseif tostring(buffer(2,2)) == "b5b0" then -- b0b5
		pinfo.cols.info:append(" SERVER_STALL_OTHER_CLOSE")
		
	elseif tostring(buffer(2,2)) == "b470" then -- 70b4
		pinfo.cols.info:append(" CLIENT_STALL_BUY")
		
	elseif tostring(buffer(2,2)) == "b4b0" then -- b0b4
		pinfo.cols.info:append(" SERVER_STALL_BUY")
		
	elseif tostring(buffer(2,2)) == "25b0" then -- b025
		pinfo.cols.info:append(" SERVER_CHAT_INDEX")
		
	elseif tostring(buffer(2,2)) == "b730" then -- 30b7
		pinfo.cols.info:append(" SERVER_STALL_PLAYERUPDATE")
		
	elseif tostring(buffer(2,2)) == "4635" then -- 3546
		pinfo.cols.info:append(" SERVER_STALL_?????????? BALOON?")
		
	elseif tostring(buffer(2,2)) == "5775" then -- 7557
		pinfo.cols.info:append(" CLIENT_ITEM_STORAGE_BOX")
		
	elseif tostring(buffer(2,2)) == "5975" then -- 7559
		pinfo.cols.info:append(" CLIENT_ITEM_BOX_LOG")
		
	elseif tostring(buffer(2,2)) == "57b5" then -- B557
		pinfo.cols.info:append(" SERVER_ITEM_STORAGE_BOX")
		
	elseif tostring(buffer(2,2)) == "59b5" then -- B559
		pinfo.cols.info:append(" SERVER_ITEM_BOX_LOG")
		
	elseif tostring(buffer(2,2)) == "3e70" then -- 703e
		pinfo.cols.info:append(" CLIENT_REPAIR_REQUEST")
		
	elseif tostring(buffer(2,2)) == "1236" then -- 3612
		pinfo.cols.info:append(" BUYED_SUCCESSFULY_GOLD")
		
	elseif tostring(buffer(2,2)) == "8470" then -- 7084
		pinfo.cols.info:append(" CLEINT_OPEN_SPECIAL_WINDOW") -- not sure
		
	elseif tostring(buffer(2,2)) == "84b0" then -- B084
		pinfo.cols.info:append(" SERVER_OPEN_SPECIAL_WINDOW")
		
	elseif tostring(buffer(2,2)) == "0c75" then -- 750c
		pinfo.cols.info:append(" CLIENT_STALL_NETWORK_SEARCH_REQUEST")
		
	elseif tostring(buffer(2,2)) == "0cb5" then -- b50c
		pinfo.cols.info:append(" SERVER_STALL_NETWORK_SEARCH_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "0a75" then -- 750a
		pinfo.cols.info:append(" CLIENT_STALL_NETWORK_BUY_REQUEST")
		
	elseif tostring(buffer(2,2)) == "0ab5" then -- b50a
		pinfo.cols.info:append(" SERVER_STALL_NETWORK_BUY_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "0775" then -- 7507
		pinfo.cols.info:append(" CLIENT_STALL_NETWORK_CLOSE_REQUEST")
		
	elseif tostring(buffer(2,2)) == "07b5" then -- B507
		pinfo.cols.info:append(" SERVER_STALL_NETWORK_CLOSE_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "3375" then -- 7533
		pinfo.cols.info:append(" CLIENT_SETTLE_CONSIGMENT_REQUEST")
		
	elseif tostring(buffer(2,2)) == "33b5" then -- B533
		pinfo.cols.info:append(" SERVER_SETTLE_CONSIGMENT_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "6070" then -- 7060
		pinfo.cols.info:append(" CLIENT_PARTY_REQUEST")
		
	elseif tostring(buffer(2,2)) == "60b0" then -- B060
		pinfo.cols.info:append(" SERVER_PARTY_RESPONSE")
		
	elseif tostring(buffer(2,2)) == "8170" then -- 7081
		pinfo.cols.info:append(" CLIENT_EXCHANGE_REQUEST")
		
	elseif tostring(buffer(2,2)) == "8830" then -- 3088
		pinfo.cols.info:append(" SERVER_EXCHANGE_CANCEL")
		
	elseif tostring(buffer(2,2)) == "4f70" then -- 70f4
		pinfo.cols.info:append(" CLIENT_WALK_RUN")
		
	elseif tostring(buffer(2,2)) == "0570" then -- 7005
		pinfo.cols.info:append(" CLIENT_LEAVE_REQUEST")
		
	elseif tostring(buffer(2,2)) == "05b0" then -- b005
		pinfo.cols.info:append(" SERVER_LEAVE_ACCEPT")
		
	elseif tostring(buffer(2,2)) == "0670" then -- 7006
		pinfo.cols.info:append(" CLIENT_LEAVE_CANCEL")
		
	elseif tostring(buffer(2,2)) == "06b0" then -- B006
		pinfo.cols.info:append(" SERVER_LEAVE_CALCEL")
		
	elseif tostring(buffer(2,2)) == "0a30" then -- 0x300A
		pinfo.cols.info:append(" SERVER_LEAVE_SUCCESS")
		
	elseif tostring(buffer(2,2)) == "0170" then -- 0x7001
		pinfo.cols.info:append(" CLIENT_INGAME_REQUEST")
		
	elseif tostring(buffer(2,2)) == "01b0" then -- 0xB001
		pinfo.cols.info:append(" SERVER_LOGINSCREEN_ACCEPT")
		
	elseif tostring(buffer(2,2)) == "ea70" then -- 0x70ea
		pinfo.cols.info:append(" CLIENT_GUIDE")
		
	elseif tostring(buffer(2,2)) == "eab0" then -- 0xb0ea
		pinfo.cols.info:append(" SERVER_SEND_GUIDE")
		
	elseif tostring(buffer(2,2)) == "5070" then -- 0x7050
		pinfo.cols.info:append(" CLIENT_PLAYER_UPDATE_STR")
		
	elseif tostring(buffer(2,2)) == "50b0" then -- 0xb050
		pinfo.cols.info:append(" SERVER_PLAYER_UPDATE_STR")
		
	elseif tostring(buffer(2,2)) == "5170" then -- 0x7051
		pinfo.cols.info:append(" CLIENT_PLAYER_UPDATE_INT")
		
	elseif tostring(buffer(2,2)) == "51b0" then -- 0xb051
		pinfo.cols.info:append(" SERVER_PLAYER_UPDATE_INT")
		
	elseif tostring(buffer(2,2)) == "f370" then -- 0x70f3
		pinfo.cols.info:append(" CLIENT_GUILD_INVITE")
		
	elseif tostring(buffer(2,2)) == "f3b0" then -- 0xb0f3
		pinfo.cols.info:append(" SERVER_GUILD_INVITE")
	
	-- elseif tostring(buffer(2,2)) == "5635" then -- 3556
		-- pinfo.cols.info:append(" FRIEND_LIST??")
	-- elseif tostring(buffer(2,2)) == "3537" then -- 3735
		-- pinfo.cols.info:append(" CLIENT_????")
	-- elseif tostring(buffer(2,2)) == "f337" then -- 37f3
		-- pinfo.cols.info:append(" Just after end player data?")
	-- elseif tostring(buffer(2,2)) == "f538" then -- 0x38F5 Region update?
		-- pinfo.cols.info:append(" Region update")
	end
end

tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(15779, silkroad_protocol)
tcp_table:add(22233, silkroad_protocol)
tcp_table:add(22232, silkroad_protocol)
tcp_table:add(22231, silkroad_protocol)
