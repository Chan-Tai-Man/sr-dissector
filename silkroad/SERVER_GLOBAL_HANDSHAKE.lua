local SERVER_GLOBAL_HANDSHAKE = {}

function SERVER_GLOBAL_HANDSHAKE.parse(buffer, offset)
	SERVER_GLOBAL_HANDSHAKE.Flag = buffer(offset + 6, 1)
	if SERVER_GLOBAL_HANDSHAKE.Flag:le_uint() == 0x0E then
		SERVER_GLOBAL_HANDSHAKE.Blowfish = buffer(offset + 7, 8)
		SERVER_GLOBAL_HANDSHAKE.CountSeed = buffer(offset + 15, 4)
		SERVER_GLOBAL_HANDSHAKE.CRCSeed = buffer(offset + 19, 4)
		SERVER_GLOBAL_HANDSHAKE.Seed_1 = buffer(offset + 23, 4)
		SERVER_GLOBAL_HANDSHAKE.Seed_2 = buffer(offset + 27, 4)
		SERVER_GLOBAL_HANDSHAKE.Seed_3 = buffer(offset + 31, 4)
		SERVER_GLOBAL_HANDSHAKE.Seed_4 = buffer(offset + 35, 4)
		SERVER_GLOBAL_HANDSHAKE.Seed_5 = buffer(offset + 39, 4)
	elseif SERVER_GLOBAL_HANDSHAKE.Flag:le_uint() == 0x10 then
		SERVER_GLOBAL_HANDSHAKE.Blowfish = buffer(offset + 7, 8)
	end
end

return SERVER_GLOBAL_HANDSHAKE