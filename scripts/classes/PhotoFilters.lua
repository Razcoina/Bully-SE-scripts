ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPhotography.lua")
local gClassNo = 1
local gTotalPics = 1
local gGoodPicsTaken = 0
local gObjectiveText = ""
local gExitPoint = -1
local gExitArea = 2
local gPhotoTargets = {}
local objBlip = -1

function main()
	AreaTransitionPoint(17, POINTLIST._C5_PLAYERSTART)
	F_InitialCutscene()
	AreaSetDoorLocked("DT_ischool_Art", true)
	AreaTransitionPoint(gExitArea, gExitPoint)
	if not PlayerHasWeapon(328) then
		GiveWeaponToPlayer(328)
		GiveAmmoToPlayer(328, 100)
		PedSetWeapon(0, 328, 30)
	end
	gClassSetupFunction()
	F_InitTargets()
	PlayerSetControl(1)
	CameraFade(500, 1)
	TextPrintString(gObjectiveText, 5, 1)
	Wait(600)
	gMissionRunning = true
	while gMissionRunning do
		if gGoodPicsTaken >= gTotalPics then
			gMissionRunning = false
		end
		Wait(0)
	end
	AreaSetDoorLocked("DT_ischool_Art", false)
	TextPrintString("Excellent job, now return to the classroom", 5, 1)
	objBlip = BlipAddPoint(POINTLIST._C5_EXITPOINT, 0)
	while AreaGetVisible() ~= 17 do
		Wait(0)
	end
	F_EndingCutscene()
	CameraReturnToPlayer()
	L_StopMonitoringTargets()
	SoundPlayMissionEndMusic(true, 9)
	MissionSucceed()
end

function MissionCleanup()
	CounterMakeHUDVisible(false)
	AreaTransitionPoint(2, POINTLIST._C5_EXITPOINT)
	PlayerSetControl(1)
	if objBlip then
		BlipRemove(objBlip)
	end
	DATUnload(2)
end

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("C5.DAT", 2)
	DATInit()
	PlayerSetControl(0)
	LoadWeaponModels({ 328 })
	F_SetupClass(2)
end

function F_ClassOne()
	iPrincipal = PedCreatePoint(65, POINTLIST._C5_PRINCIPALSTART)
	PedFollowPath(iPrincipal, PATH._C5_PRINCIPALPATH01, 1, 0)
	gPhotoTargets = {
		{ id = iPrincipal, type = 2 }
	}
end

function F_ClassTwo()
	local itemsToRemove = 0
	local bannerTable = {
		TRIGGER._ACROSSGYMBACK,
		TRIGGER._ANGELSTATUE,
		TRIGGER._AUTOGARAGE,
		TRIGGER._AUTOSHOP,
		TRIGGER._AUTOSHOPSIDE,
		TRIGGER._BDORMFLAG1,
		TRIGGER._BLEACHERSL,
		TRIGGER._BLEACHERSR,
		TRIGGER._EQUIPMENTROOM,
		TRIGGER._FLAGLEFTSCHOOL,
		TRIGGER._FLAGRIGHTSCHOOL,
		TRIGGER._GDORMBACKDR,
		TRIGGER._GDORMENTRANCE,
		TRIGGER._GLASSDOME,
		TRIGGER._GYMNASIUM,
		TRIGGER._GYMNASIUMBACK,
		TRIGGER._LIBRARYARCH,
		TRIGGER._LIBRARYL,
		TRIGGER._LIBRARYR,
		TRIGGER._PARKINGARCHWAY,
		TRIGGER._PREPPYL,
		TRIGGER._PREPPYR,
		TRIGGER._SCHOOLBACKR,
		TRIGGER._SCHOOLENTRL1,
		TRIGGER._SCHOOLENTRL2,
		TRIGGER._SCHOOLENTRR1,
		TRIGGER._SCHOOLENTRR2,
		TRIGGER._SCHOOLSECONDFLOOR,
		TRIGGER._SCHOOLTOWER,
		TRIGGER._STATUEL,
		TRIGGER._STATUER,
		TRIGGER._TROPHYL,
		TRIGGER._TROPHYR
	}
	local x2, y2, z2
	for i, event in bannerTable do
		PAnimCreate(event)
		x2, y2, z2 = GetAnchorPosition(event)
		--print(" trigger: ", event, x2, y2, z2)
		table.insert(gPhotoTargets, {
			x = x2,
			y = y2,
			z = z2
		})
	end
end

function F_SetupClass(param)
	if param == 1 then
		gClassNo = 1
		gObjectiveText = "Take a picture of the Principal, he must be walking around on the hallways"
		gExitPoint = POINTLIST._C5_EXITPOINT
		gClassSetupFunction = F_ClassOne
	elseif param == 2 then
		gClassNo = 2
		gObjectiveText = "Take a picture of 15 banners around the schoolgrounds"
		gExitPoint = POINTLIST._C5_EXITPOINT02
		gExitArea = 0
		gClassSetupFunction = F_ClassTwo
		gTotalPics = 15
	elseif param == 3 then
		gClassNo = 3
	elseif param == 4 then
		gClassNo = 4
	elseif param == 5 then
		gClassNo = 5
	elseif 6 <= param then
		gClassNo = 6
	end
end

function F_EndingCutscene()
	teacher = PedCreatePoint(63, POINTLIST._C5_ENDINGPOINTS, 1)
	PlayerSetPosPoint(POINTLIST._C5_ENDINGPOINTS, 2)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraLookAtXYZ(-536.29114, 394.74268, 15.509263, true)
	CameraSetXYZ(-534.2692, 394.0767, 15.329271, -536.29114, 394.74268, 15.509263)
	PedFaceObject(gPlayer, teacher, 2, 0, true)
	TextPrintString("Ms. Phillips: Nice work Jimmy, you're quite the photographer.", 3, 2)
	Wait(4000)
	CameraFade(500, 0)
	Wait(500)
	PedDelete(teacher)
end

function F_InitialCutscene()
	teacher = PedCreatePoint(63, POINTLIST._C5_TEACHERSTART)
	CameraSetWidescreen(true)
	CameraLookAtXYZ(-531.1897, 375.2763, 15.069274, true)
	CameraSetXYZ(-538.58215, 376.68225, 16.649103, -531.1897, 375.2763, 15.069274)
	CameraFade(1000, 1)
	PedFollowPath(gPlayer, PATH._C5_PLAYERPATH, 0, 0)
	Wait(500)
	if gClassNo == 1 then
		TextPrintString("Ms. Phillips: Welcome to photography class, I'm Miss Phillips.", 3, 2)
		Wait(3000)
		TextPrintString("Ms. Phillips: I'll be handing out your cameras and first assignment in a moment.", 3, 2)
	else
		TextPrintString("Ms. Phillips: Welcome back everybody. I hope none of you forgot your cameras.", 3, 2)
	end
	Wait(3538)
	CameraFade(500, 0)
	Wait(550)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PedDelete(teacher)
	CameraSetWidescreen(false)
end

function F_PictureTaken(tblTargets)
	if table.getn(tblTargets) < 1 then
		--print("EUREKA, NO TARGETS TO CHECK")
		PhotoGetEntityStart()
		local gEntity, gType = PhotoGetEntityNext()
		--print("Target", gEntity, gType)
		while gEntity ~= -1 do
			gEntity, gType = PhotoGetEntityNext()
			--print("Target", gEntity, gType)
			Wait(0)
		end
	end
	for i, tblEntry in tblTargets do
		if tblEntry.id == iPrincipal then
			L_SetTargetValid(tblEntry, false)
			gGoodPicsTaken = gGoodPicsTaken + 1
			TextPrintString("GOOD PICTURE", 3, 2)
			return true
		elseif tblEntry.x ~= nil then
			for i, event in gPhotoTargets do
				--print(" Coords: ", event.x, event.y, event.z)
				gGoodPicsTaken = gGoodPicsTaken + 1
				if tblEntry.x == event.x and tblEntry.y == event.y and tblEntry.z == event.z then
					TextPrintString("GOOD PICTURE", 3, 2)
					return true
				end
			end
		end
	end
	return false
end

function F_InitTargets()
	for i, target in gPhotoTargets do
		L_AddPhotoTarget("testphotos", { target })
	end
	L_PhotoSetFunction(F_PictureTaken)
	CreateThread("L_MonitorTargets")
	totalTime = 120
	MissionTimerStart(totalTime)
	pictureTakenFunction = F_UpdatePostcardPictures
	classGradeFunction = F_GetPostcardGrade
end
