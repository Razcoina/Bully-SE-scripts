local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bRanCutscene = false

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	DATLoad("TESTSAFECUT.DAT", 2)
	DATInit()
	F_TableInit()
	AreaTransitionPoint(31, POINTLIST._TESTSAFECUT_SPAWNPLAYER)
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	if blipCutStart ~= nil then
		BlipRemove(blipCutStart)
	end
	DATUnload(2)
	DATInit()
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupWorld()
	F_Intro()
	F_Stage1()
	if bMissionFailed then
		TextPrint("MFAIL", 3, 1)
		Wait(3000)
		MissionFail()
	elseif bMissionPassed then
		TextPrint("MPASS", 3, 1)
		Wait(3000)
		MissionSucceed()
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedBully01 = {
		spawn = POINTLIST._TESTSAFECUT_SPAWNBULLIES,
		element = 1,
		model = 102
	}
	pedBully02 = {
		spawn = POINTLIST._TESTSAFECUT_SPAWNBULLIES,
		element = 2,
		model = 99
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupWorld()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupWorld()")
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupWorld()")
end

function F_Intro()
	--print("()xxxxx[:::::::::::::::> [start] F_Intro()")
	--print("()xxxxx[:::::::::::::::> [finish] F_Intro()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	pedBully01.id = PedCreatePoint(pedBully01.model, pedBully01.spawn, pedBully01.element)
	pedBully02.id = PedCreatePoint(pedBully02.model, pedBully02.spawn, pedBully02.element)
	blipCutStart = BlipAddPoint(POINTLIST._TESTSAFECUT_STARTCUT, 0, 1, 4, 9)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		Stage1_Objectives()
		if bMissionPassed or bMissionFailed then
			break
		end
		Wait(0)
	end
end

function Stage1_Objectives()
	if not bRanCutscene and PlayerIsInTrigger(TRIGGER._TESTSAFECUT_STARTCUT) then
		F_StartCutscene()
		bRanCutscene = true
	end
end

function F_StartCutscene()
	--print("()xxxxx[:::::::::::::::> [start] F_StartCutscene()")
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	Wait(10000)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	bMissionPassed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_StartCutscene()")
end
