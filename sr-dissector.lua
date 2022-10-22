local SERVER_GLOBAL_IDENTIFICATION = require "silkroad/SERVER_GLOBAL_IDENTIFICATION";
local SERVER_GLOBAL_HANDSHAKE = require "silkroad/SERVER_GLOBAL_HANDSHAKE";
local OPCODES = require "silkroad/opcodes";

getmetatable('').__call = string.sub

silkroad_protocol = Proto("silkroad","Silkroad Protocol");

silkroad_protocol.fields = {}
local header = silkroad_protocol.fields
header.datasize = ProtoField.new("Data size", "silkroad.header.data_length", ftypes.UINT16)
header.opcode = ProtoField.uint16("silkroad.header.opcode", "Opcode", base.HEX)
header.security = ProtoField.new("Security", "silkroad.header.security", ftypes.UINT16)

function silkroad_protocol.dissector(buffer, pinfo, tree)
	local size = buffer(0,2)
	local opcode = buffer(2,2)
	local security = buffer(4,2)
	
	local is_encrypted = buffer(1,1):bitfield(0,1) == 1
	if is_encrypted then
		local size_encrypted = size:le_uint()
		size = size_encrypted - 0x8000
	end
	
	pinfo.cols.protocol = "Silkroad"
	
	local TREE_MAIN = tree:add(silkroad_protocol, buffer(0,-1), "Silkroad Protocol")
	
	local SUBTREE_HEADER = TREE_MAIN:add(silkroad_protocol, buffer(0,6), "Packet Header")
	SUBTREE_HEADER:add_le(header.datasize, size);
	SUBTREE_HEADER:add_le(header.opcode, opcode);
	SUBTREE_HEADER:add_le(header.security, security);
	
	-- Put the opcode inside "Info" column.
	pinfo.cols.info = "0x" .. string.upper(tostring(opcode)(3,4)) .. string.upper(tostring(opcode)(0,2));
	
	local SUBTREE_DATA = TREE_MAIN:add(silkroad_protocol, buffer(6, -1), "Packet Data")
	
	if is_encrypted then
		pinfo.cols.info:append(" #################################################")
	else
		local opcode = buffer(2,2):le_uint()

		if opcode == 0x2001 then
			SERVER_GLOBAL_IDENTIFICATION.parse(buffer)
			SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceName, "ServiceName: " .. SERVER_GLOBAL_IDENTIFICATION.ServiceName);
			if SERVER_GLOBAL_IDENTIFICATION.ServiceType:le_uint() == True then
				SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceType, "ServiceType: module - module");
			else
				SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceType, "ServiceType: machine - machine");
			end
			opcodeDesc = "** SERVICE_IDENTIFICATION **"
		elseif opcode == 0x5000 then
			SERVER_GLOBAL_HANDSHAKE.parse(buffer)
			SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Flag, "Flag: " .. SERVER_GLOBAL_HANDSHAKE.Flag)
			if SERVER_GLOBAL_HANDSHAKE.Flag:le_uint() == 0x0E then
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Blowfish, "Blowfish: " .. SERVER_GLOBAL_HANDSHAKE.Blowfish)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.CountSeed, "CountSeed: " .. SERVER_GLOBAL_HANDSHAKE.CountSeed)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.CRCSeed, "CRCSeed: " .. SERVER_GLOBAL_HANDSHAKE.CRCSeed)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Seed_1, "Seed_1: " .. SERVER_GLOBAL_HANDSHAKE.Seed_1)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Seed_2, "Seed_2: " .. SERVER_GLOBAL_HANDSHAKE.Seed_2)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Seed_3, "Seed_3: " .. SERVER_GLOBAL_HANDSHAKE.Seed_3)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Seed_4, "Seed_4: " .. SERVER_GLOBAL_HANDSHAKE.Seed_4)
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Seed_5, "Seed_5: " .. SERVER_GLOBAL_HANDSHAKE.Seed_5)
			elseif SERVER_GLOBAL_HANDSHAKE.Flag:le_uint() == 0x10 then
				SUBTREE_DATA:add_le(SERVER_GLOBAL_HANDSHAKE.Blowfish, "Blowfish: " .. SERVER_GLOBAL_HANDSHAKE.Blowfish)
			end
			opcodeDesc = "** HANDSHAKE **"
		else
			opcodeDesc = OPCODES.get_description(opcode)
		end
		pinfo.cols.info:append(" " .. opcodeDesc)
	end
end

tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(15779, silkroad_protocol)
tcp_table:add(22233, silkroad_protocol)
tcp_table:add(22232, silkroad_protocol)
tcp_table:add(22231, silkroad_protocol)
tcp_table:add(22230, silkroad_protocol)
