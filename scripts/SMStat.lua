function F_VendettaGreasers()
	local playable = 1
	if g_3RM01_GreaserLevel > 3 then
		playable = 0
	end
	return playable
end

function F_VendettaPreppies()
	local playable = 1
	if g_3RM01_PreppyLevel > 3 then
		playable = 0
	end
	return playable
end
