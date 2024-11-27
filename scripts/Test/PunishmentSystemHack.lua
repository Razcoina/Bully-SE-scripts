function MissionSetup()
end

function MissionCleanup()
end

function main()
	if shared.gHackPunishment == 0 then
		shared.gHackPunishment = 1
		TextPrintString("PRESS R2 TO GET BUSTED!", 10, 1)
	elseif shared.gHackPunishment == 1 then
		shared.gHackPunishment = 2
		TextPrintString("PRESS R2 TO GET BUSTED! PRINCIPAL WILL SAY EVERY LINE OF DIALOGUE", 10, 1)
	elseif shared.gHackPunishment == 2 then
		shared.gHackPunishment = 0
		TextPrintString("USING R2 TO GET BUSTED IS NO LONGER AVAILABLE. RUN MISSION AGAIN TO MAKE IT AVAILABLE!", 10, 1)
	end
	MissionSucceed()
end
