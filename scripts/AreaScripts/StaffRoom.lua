local gExitPoint = -1
local gCameraPath = -1
local tblSafeMissions = { "2_S05" }

function main()
	DATLoad("eventsStaffRoom.DAT", 1)
	DATLoad("SP_Staff_Room.DAT", 0)
	LoadAnimationGroup("NPC_Adult")
	F_PreDATInit()
	DATInit()
	--print("[JASON] =========================> Area Script Working: StaffRoom")
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[23] = true
	while not (AreaGetVisible() ~= 23 or SystemShouldEndScript()) do
		Wait(0)
	end
	UnLoadAnimationGroup("NPC_Adult")
	DATUnload(0)
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[23] = false
end

function F_KickPlayerOut()
	local bKickOut = true
	local nCurrentTimeH, _ = ClockGet()
	for _, entry in tblSafeMissions do
		if MissionActiveSpecific(entry) then
			bKickOut = false
		end
	end
	if nCurrentTimeH < 7 or 19 < nCurrentTimeH then
		bKickOut = false
	end
	if bKickOut then
		F_Aggression()
	end
end

function F_Aggression()
	AreaClearAllPeds()
	local gTeacher = PedCreatePoint(63, POINTLIST._STAFFROOM_ANGRYSTAFF)
	PlayerSetControl(0)
	PedSetPosPoint(gPlayer, gExitPoint)
	PedSetPosPoint(gTeacher, gExitPoint, 2)
	PedFaceObject(gTeacher, gPlayer, 3, 0)
	CameraLookAtObject(gPlayer, 3, true, 0.5)
	CameraSetPath(gCameraPath, true)
	TextPrintString("Hey you ! What the hell you think you are doing ! Get out of my here !", 4, 2)
	PedFaceObject(gTeacher, gPlayer, 3, 1)
	Wait(2000)
	PedSetActionNode(gTeacher, "/Global/Welcome/ShakeFist", "Act/Conv/Store.act")
	Wait(1000)
	PedSetActionNode(gTeacher, "/Global/Welcome/Disgusted", "Act/Conv/Store.act")
	Wait(1500)
	local punishment = PlayerGetPunishmentPoints() + 150
	if 500 < punishment then
		punishment = 500
	end
	PlayerSetPunishmentPoints(punishment)
	PedSetActionNode(gPlayer, "/Global/WProps/PropInteract", "Act/WProps.act")
	PlayerSetControl(1)
end
