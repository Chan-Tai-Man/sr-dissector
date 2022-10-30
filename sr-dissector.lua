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
	pinfo.cols.protocol = "Silkroad"

	local pklen = buffer:len()
	local current_offset = 0
	while current_offset < pklen do
		local bytes_consumed = dissect_single_packet(buffer, pinfo, tree, current_offset)
		if bytes_consumed < 0 then
			pinfo.desegment_offset = current_offset
			pinfo.desegment_len = -bytes_consumed
			return current_offset + (-bytes_consumed)
		elseif bytes_consumed == 0 then
			return 0
		else
			current_offset = current_offset + bytes_consumed
		end
	end

	return current_offset
end

function dissect_single_packet(buffer, pinfo, tree, offset)
	local remaining = buffer:len() - offset
	if remaining < 6 then
		-- If we have less than 6 bytes remaining, we know the packet isn't complete.
		-- Thus we _always_ need one more segment. We could be more accurate here if
		-- we wanted to, but this is good enough.
		return -DESEGMENT_ONE_MORE_SEGMENT
	end

	local size = buffer(offset,2)
	local total_size = size:le_uint() + 6
	local opcode = buffer(offset + 2,2)
	local security = buffer(offset + 4,2)
	
	local is_encrypted = buffer(offset + 1,1):bitfield(0,1) == 1
	if is_encrypted then
		local size_encrypted = size:le_uint()
		size = size_encrypted - 0x8000
		total_size = get_encrypted_aligned_data_size(size) + 6
	end

	if remaining < total_size then
		return -(total_size - remaining)
	end
	
	local TREE_MAIN = tree:add(silkroad_protocol, buffer(offset, total_size), "Silkroad Protocol")
	
	local SUBTREE_HEADER = TREE_MAIN:add(silkroad_protocol, buffer(offset,6), "Packet Header")
	SUBTREE_HEADER:add_le(header.datasize, size);
	SUBTREE_HEADER:add_le(header.opcode, opcode);
	SUBTREE_HEADER:add_le(header.security, security);
	
	-- Put the opcode inside "Info" column.
	local info = "0x" .. string.upper(tostring(opcode)(3,4)) .. string.upper(tostring(opcode)(0,2));
	if string.find(tostring(pinfo.cols.info), "^0x") == nil then
		pinfo.cols.info:set(info)
	else 
		pinfo.cols.info:append(" - " .. info)
	end
	
	local SUBTREE_DATA = TREE_MAIN:add(silkroad_protocol, buffer(offset + 6, total_size - 6), "Packet Data")
	
	if is_encrypted then
		pinfo.cols.info:append(" ENCRYPTED")
	else
		local opcode = buffer(offset + 2,2):le_uint()

		if opcode == 0x2001 then
			SERVER_GLOBAL_IDENTIFICATION.parse(buffer, offset)
			SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceName, "ServiceName: " .. SERVER_GLOBAL_IDENTIFICATION.ServiceName);
			if SERVER_GLOBAL_IDENTIFICATION.ServiceType:le_uint() == True then
				SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceType, "ServiceType: module - module");
			else
				SUBTREE_DATA:add(SERVER_GLOBAL_IDENTIFICATION.ServiceType, "ServiceType: machine - machine");
			end
			opcodeDesc = "** SERVICE_IDENTIFICATION **"
		elseif opcode == 0x5000 then
			SERVER_GLOBAL_HANDSHAKE.parse(buffer, offset)
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

	return total_size
end

function get_encrypted_aligned_data_size(size)
	local bytes_to_encrypt = size + 4 -- Part of the header is also encrypted
	local missing_for_alignment = bytes_to_encrypt % 8
	if missing_for_alignment > 0 then
		return (bytes_to_encrypt + (8 - missing_for_alignment)) - 4
	end
	return size
end

tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(15779, silkroad_protocol)
tcp_table:add(22233, silkroad_protocol)
tcp_table:add(22232, silkroad_protocol)
tcp_table:add(22231, silkroad_protocol)
tcp_table:add(22230, silkroad_protocol)
