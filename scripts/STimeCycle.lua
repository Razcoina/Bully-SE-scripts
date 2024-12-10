function main()
	--DebugPrint("STimeCycle.lua main")
	while Alive do
		Wait(1000)
	end
end

function F_AttendedClass()
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		return
	end
	--DebugPrint("F_AttendedClass")
	SetSkippedClass(false)
	PlayerSetPunishmentPoints(0)
	--DebugPrint("F_AttendedClass eof")
end

function F_MissedClass()
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		return
	end
	--DebugPrint("F_MissedClass")
	SetSkippedClass(true)
	StatAddToInt(166)
	--DebugPrint("F_MissedClass eof")
end

function F_AttendedCurfew()
	--DebugPrint("F_AttendedCurfew")
	if not PedInConversation(gPlayer) and not MissionActive() then
		TextPrintString("You got home in time for curfew", 4)
	end
	--DebugPrint("F_AttendedCurfew eof")
end

function F_MissedCurfew()
	--DebugPrint("F_MissedCurfew")
	if not PedInConversation(gPlayer) and not MissionActive() then
		TextPrint("TM_TIRED5", 4, 2)
	end
	--DebugPrint("F_MissedCurfew eof")
end

function F_StartClass()
	--print("IsMissionCompleated( 3_08): ", tostring(IsMissionCompleated("3_08")))
	--print("IsMissionCompleated( 3_08_PostDummy): ", tostring(IsMissionCompleated("3_08_PostDummy")))
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		return
	end
	--DebugPrint("F_StartClass")
	F_RingSchoolBell()
	local current_punishment = PlayerGetPunishmentPoints()
	current_punishment = current_punishment + GetSkippingPunishment()
	--DebugPrint("F_StartClass eof")
end

function F_EndClass()
	--print("IsMissionCompleated( 3_08): ", tostring(IsMissionCompleated("3_08")))
	--print("IsMissionCompleated( 3_08_PostDummy): ", tostring(IsMissionCompleated("3_08_PostDummy")))
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		return
	end
	--DebugPrint("F_EndClass")
	F_RingSchoolBell()
	--print([[
	--
	--  Punishment points after setting: ]] .. PlayerGetPunishmentPoints())
	--DebugPrint("F_EndClass eof")
end

function F_StartMorning()
	--DebugPrint("F_StartMorning + eof")
	F_UpdateTimeCycle()
end

function F_EndMorning()
	--DebugPrint("F_EndMorning + eof")
	F_UpdateTimeCycle()
end

function F_StartLunch()
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		F_UpdateTimeCycle()
		return
	end
	--DebugPrint("F_StartLunch")
	F_UpdateTimeCycle()
	--DebugPrint("F_StartLunch eof")
end

function F_EndLunch()
	F_UpdateTimeCycle()
	--DebugPrint("F_EndLunch + eof")
end

function F_StartAfternoon()
	F_UpdateTimeCycle()
	--DebugPrint("F_StartAfternoon + eof")
end

function F_EndAfternoon()
	F_UpdateTimeCycle()
	--DebugPrint("F_EndAfternoon + eof")
end

function F_StartEvening()
	F_UpdateTimeCycle()
	--DebugPrint("F_StartEvening + eof")
end

function F_EndEvening()
	F_UpdateTimeCycle()
	--DebugPrint("F_EndEvening + eof")
end

function F_StartCurfew_SlightlyTired()
	--DebugPrint("F_StartCurfew_SlightlyTired")
	--DebugPrint("F_StartCurfew_SlightlyTired eof")
	F_UpdateTimeCycle()
end

function F_StartCurfew_Tired()
	--DebugPrint("F_StartCurfew_Tired")
	F_UpdateTimeCycle()
	--DebugPrint("F_StartCurfew_Tired eof")
end

function F_StartCurfew_MoreTired()
	--DebugPrint("F_StartCurfew_MoreTired")
	F_UpdateTimeCycle()
	--DebugPrint("F_StartCurfew_MoreTired eof")
end

function F_StartCurfew_TooTired()
	--DebugPrint("F_StartCurfew_TooTired")
	F_UpdateTimeCycle()
	--DebugPrint("F_StartCurfew_TooTired eof")
end

function F_EndCurfew_TooTired()
	--DebugPrint("F_EndCurfew_TooTired")
	F_UpdateTimeCycle()
	--DebugPrint("F_EndCurfew_TooTired eof")
end

function F_EndTired()
	--DebugPrint("F_EndTired")
	F_UpdateTimeCycle()
	--DebugPrint("F_EndTired eof")
end

function F_Nothing()
	--DebugPrint("F_Nothing")
end

function F_ClassWarning()
	if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
		return
	end
	local warnchoice = math.random(1, 2)
end

function F_UpdateTimeCycle()
	if not IsMissionCompleated("1_B") then
		local CurrentDay = GetCurrentDay(false)
		if CurrentDay < 0 or 2 < CurrentDay then
			SetCurrentDay(0)
		end
	end
	F_UpdateCurfew()
end

function F_UpdateCurfew()
	local rules = shared.gCurfewRules or F_CurfewDefaultRules
	rules()
end

function F_CurfewDefaultRules()
	local timeHour = ClockGet()
	if 23 <= timeHour or timeHour < 7 then
		shared.gCurfew = true
		--print("F_CurfewDefaultRules:", "Curfew ON")
	else
		shared.gCurfew = false
		--print("F_CurfewDefaultRules:", "Curfew OFF")
	end
end
