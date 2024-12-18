--[[ Changes to this file:
	* Modified function MissionSetup, may require testing
	* Modified function F_LoadingScreen, may require testing
	* Modified function F_InstructScreen, may require testing
	* Modified function F_HighScoreScreen, may require testing
	* Modified function F_InitGame, may require testing
	* Modified function cbSquirrleUpdate, may require testing
	* Modified function F_MakeLives, may require testing
	* Modified function cbEchoUpdate, may require testing
]]

local gScreenX, gScreenY = 640, 480
local instTimer = 0
local nextFireTime = 0
local fireTime = 200
local bInstRemoved = false
local bInstPhase = false
local playerWins = false
local bGameOver = false
local gHUD = 0
local gLayer = 0
local gBananaLayer = 0
local gGround = 0
local gClouds = 0
local gSquirrel = 0
local gBat = 0
local gLives = 10
local gSpider = 0
local gHornet = 0
local gStinger = 0
local gBanana = 0
local gNut = 0
local gLife = 0
local gAmmo = 0
local gDeadBats = 0
local tblBananas = {}
local tblSpiders = {}
local tblHornets = {}
local tblEchos = {}
local bat = {}
local tblNut = {}
local tblLives = {}
local tblAmmo = {}
local tblTerrain1 = {}
local tblTerrain2 = {}
local tblTerrain3 = {}
local TerrainSprite1 = {}
local TerrainSprite2 = {}
local TerrainSprite3 = {}
local tblStingers = {}
local bPressX = false
local bPressR1 = false
local bPressTriangle = false
local bLifeChange = false
local bThrow = false
local gHornetsLeft = 0
local bDead = false
local bEndTheGame = false
local bInvulnerabl = false
local bGameOn = false
local bWaitForRemainingDeadHornets = false
local bHornetSuspend = false
local gEagleState = STATE_PARKED
local gEagle = 0
local gEagleWingTime = 0
local gEagleAttactTime = 0
local gEagleHealth = 25
local bWhereEaglesDare = false
local gEagleLaunchTime = 0
local lastRespawnTime = 0
local gHornetsDead = 0
local gBatHealth = 1
local gHornetAttack_texture = 0
local gHornetUp_texture = 0
local gHornetDn_texture = 0
local gBackDrop01 = 0
local gBackDrop02 = 0
local terra_sprite1 = 0
local terra_sprite2 = 0
local terra_sprite3 = 0
local stick1X, stick1Y = 0, 0
local stick2X, stick2Y = 0, 0
local gMoveX, gMoveY = 0, 0
local gMoveSpeedXPos = 140
local gMoveSpeedXNeg = -140
local gMoveSpeedYPos = 140
local gMoveSpeedYNeg = -140
local gShotSpeedXPos = 340
local gShotSpeedXNeg = -340
local gShotSpeedYPos = 340
local gShotSpeedYNeg = -340
local gBatSpriteU = 0
local gBatSpriteM = 0
local gBatSpriteD = 0
local gSquirrelSprite0 = 0
local gSquirrelSprite1 = 0
local EAGLE_PARKED = 0
local EAGLE_ACTIVE = 1
local EAGLE_FALLING = 2
local EAGLE_DEAD = 3
local SALMON_PARKED = 0
local SALMON_ACTIVE = 1
local SALMON_FIRED = 2
local SALMON_DEAD = 3
local BAT_PARKED = 0
local BAT_FLYING = 1
local BAT_DEAD = 2
local HORNET_PARKED = 0
local HORNET_FALLING = 1
local HORNET_DEAD = 2
local STINGER_PARKED = 0
local STINGER_THROWN = 1
local SPIDER_PARKED = 0
local SPIDER_FALLING = 1
local SPIDER_GROUND = 2
local NUT_PARKED = 0
local NUT_THROWN = 1
local ECHO_PARKED = 0
local ECHO_THROWN = 1
local LIFE_PARKED = 0
local LIFE_TAKEN = 1
local AMMO_PARKED = 0
local AMMO_SPENT = 1
local bPressCross = false
local Px, Py, Pz, PLAYER_AREA = 0, 0, 0, 0
local bPressLeft = false
local bPressRight = false
local bPressUp = false
local bPressDown = false
local gScore = 0
local gScoreText = 0
local gScoreParam = 0
local gameOverTimeOut = 0
local highScoreTimer = 0
local bFoundHornet = false
local bFoundStinger = false

function MissionSetup() -- ! Modified
	SoundEnableInteractiveMusic(false)
	SoundStopAmbiences()
	SoundDisableSpeech_ActionTree()
	PlayerSetControl(0)
	PlayerSetInvulnerable(true)
	PedIgnoreStimuli(gPlayer, true)
	PedIgnoreAttacks(gPlayer, true)
	SoundStopAmbiences()
	MinigameCreate("ARCADE", false)
	MinigameStart()
	MinigameEnableHUD(true)
	MGArcade_LoadTextures("MG_Fend")                            -- Adde this
	sSideBarLeft = MGArcade_GetTextureID("Fend_SideScreen_left") -- Adde this
	sSideBarRight = MGArcade_GetTextureID("Fend_SideScreen_right") -- Adde this
	--[[
	MGArcade_InitScreen(0, 0, 0)
	]] -- Changed to:
	MGArcade_InitScreen(128, 128, 128, sSideBarLeft, sSideBarRight)
	Px, Py, Pz = PlayerGetPosXYZ()
	PLAYER_AREA = AreaGetVisible()
end

function MissionCleanup()
	PlayerSetPosXYZArea(Px, Py, Pz, PLAYER_AREA)
	SoundStopStream()
	PlayerSetInvulnerable(false)
	SoundRestartAmbiences()
	MinigameDestroy()
	SoundEnableInteractiveMusic(true)
	SoundEnableSpeech_ActionTree()
	PlayerSetControl(1)
end

function main()
	while MinigameIsReady() == false do
		Wait(0)
	end
	Wait(2)
	SoundStopAmbiences()
	CameraFade(1000, 1)
	Wait(1100)
	SoundPlayStream("Arc_FlyingSquirrelMenu.rsm", 1, 0, 0)
	F_InitGame()
	if MinigameIsActive() then
		Wait(250)
	end
	bInstPhase = true
	while MinigameIsActive() do
		if bInstPhase then
			F_InstructScreen()
			instTimer = GetTimer() + 10000
			SoundStopStream()
			local tblMusicStreams = {
				"Arc_FlyingSquirrelGameMx01.rsm",
				"Arc_FlyingSquirrelGameMx02.rsm",
				"Arc_FlyingSquirrelGameMx03.rsm"
			}
			math.randomseed(GetTimer())
			randomizer = math.random(1, 3)
			SoundPlayStream(tblMusicStreams[randomizer], 1, 0, 0)
			F_StartGame()
			F_HornetRespawnTimes()
			bInstPhase = false
			Wait(500)
			bGameOn = true
		end
		F_MoveTerrain()
		if bLifeChange and not bGameOver then
			for j = 3, 1, -1 do
				if tblLives[j].state == LIFE_PARKED then
					MGArcade_Sprite_SetVisible(gHUD, tblLives[j].id, false)
					tblLives[j].state = LIFE_TAKEN
					break
				end
			end
			local lives = 3
			for k, life in tblLives do
				if tblLives[k].state == LIFE_TAKEN then
					lives = lives - 1
				end
			end
			if lives < 3 and lives ~= 0 then
				bDead = true
				MGArcade_Sprite_SetTexture(gLayer, gSquirrel, gSquirrelSpriteDead)
				MGArcade_Sprite_SetAcc(gLayer, gSquirrel, 0, 0)
				MGArcade_Sprite_SetVel(gLayer, gSquirrel, 0, 185)
				MGArcade_Sprite_SetCollSize(gLayer, gSquirrel, 0, 0)
				local bContinue = false
				while not bContinue and MinigameIsActive() do
					local x, y = MGArcade_Sprite_GetPos(gLayer, gSquirrel)
					if 240 < y then
						bContinue = true
					end
					F_MoveTerrain()
					Wait(0)
				end
				MGArcade_Sprite_SetAcc(gLayer, gSquirrel, 0, 0)
				MGArcade_Sprite_SetVel(gLayer, gSquirrel, 0, 0)
				MGArcade_Sprite_SetTexture(gLayer, gSquirrel, gSquirrelFrame)
				MGArcade_Sprite_SetPos(gLayer, gSquirrel, -150, -100)
				local blink = true
				bDead = false
				bInvulnerabl = true
				while blink and MinigameIsActive() do
					for i = 1, 10 do
						if i == 1 or i == 3 or i == 5 or i == 7 or i == 9 then
							MGArcade_Sprite_SetVisible(gLayer, gSquirrel, true)
							Wait(250)
						else
							MGArcade_Sprite_SetVisible(gLayer, gSquirrel, false)
							Wait(250)
						end
						F_MoveTerrain()
					end
					bInvulnerabl = false
					blink = false
					Wait(0)
				end
				bInvulnerabl = false
				MGArcade_Sprite_SetVisible(gLayer, gSquirrel, true)
				MGArcade_Sprite_SetCollSize(gLayer, gSquirrel, 64, 32)
			elseif lives == 0 and not bGameOver then
				bGameOver = true
				SoundPlay2D("SquirrelDestroy")
				SoundStopStream()
				SoundPlayStreamNoLoop("Arc_FlyingSquirrelLose.rsm", 1)
				MGArcade_Sprite_SetTexture(gLayer, gSquirrel, gSquirrelSpriteDead)
				MGArcade_Sprite_SetAcc(gLayer, gSquirrel, 0, 0)
				MGArcade_Sprite_SetVel(gLayer, gSquirrel, 0, 25)
				F_GameOverScreen()
				gameOverTimeOut = GetTimer() + 5000
			end
			bLifeChange = false
		end
		if bGameOver then
			if not (not IsButtonBeingPressed(7, 0) or bPressCross) or GetTimer() >= gameOverTimeOut then
				bPressCross = true
				MGArcade_Sprite_SetVisible(gGameOverLayer, gOverScreen, false)
				F_HighScoreScreen()
				bEndTheGame = true
			end
			if not IsButtonBeingPressed(7, 0) and bPressCross then
				bPressCross = false
			end
		end
		if bEndTheGame then
			CameraFade(500, 0)
			Wait(500)
			SoundStopStream()
			MinigameEnd()
		end
		Wait(0)
	end
	SoundStopStream()
	if MinigameIsSuccess() then
		Wait(1000)
		playerWins = true
	end
	if playerWins then
		TextPrintString("You win!", 1)
	else
		TextPrintString("GAME OVER.", 1)
	end
	if bGameOver then
	end
	if MinigameIsActive() then
		Wait(1000)
	end
	MinigameEnableHUD(false)
	MinigameEnd()
	if playerWins then
		--print("==== playerWins ====")
		MissionSucceed(false, false, false)
	else
		--print("==== Failing ====")
		MissionFail(false, false)
	end
end

function F_LoadingScreen() -- ! Modified
	local loadingScreen = MGArcade_GetTextureID("Start_screen")
	gStartScreen = MGArcade_CreateLayer(gScreenX, gScreenY, 300, C_LayerUpdate)
	MGArcade_Layer_SetPos(gStartScreen, 0, 0)
	MGArcade_Layer_SetCol(gStartScreen, 255, 255, 255, 255)
	MGArcade_Layer_SetScale(gStartScreen, 1, 1)
	gLoadScreen = MGArcade_Layer_AddSprite(gStartScreen)
	MGArcade_Sprite_SetCol(gStartScreen, gLoadScreen, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gStartScreen, gLoadScreen, 0, 0)
	MGArcade_Sprite_SetSize(gStartScreen, gLoadScreen, gScreenX, gScreenY)
	MGArcade_Sprite_SetTexture(gStartScreen, gLoadScreen, loadingScreen)
	MGArcade_Sprite_SetVisible(gStartScreen, gLoadScreen, true)
	gStartText = MGArcade_Layer_AddSprite(gStartScreen)
	MGArcade_Sprite_SetCol(gStartScreen, gStartText, 50, 50, 50, 255)
	MGArcade_Sprite_SetPos(gStartScreen, gStartText, -100, 140)
	MGArcade_Sprite_SetSize(gStartScreen, gStartText, 1, 1)
	--[[
	MGArcade_Sprite_SetScale(gStartScreen, gStartText, 1.4, 1.4)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gStartScreen, gStartText, 0.8, 0.8)
	else
		MGArcade_Sprite_SetScale(gStartScreen, gStartText, 1.4, 1.4)
	end
	MGArcade_Sprite_SetCollSize(gStartScreen, gStartText, 0, 0)
	MGArcade_Sprite_SetVisible(gStartScreen, gStartText, true)
	MGArcade_Sprite_SetFont(gStartScreen, gStartText, 1)
	MGArcade_Sprite_SetText(gStartScreen, gStartText, "ARCADE_BTNSTRT")
	gExitText = MGArcade_Layer_AddSprite(gStartScreen)
	MGArcade_Sprite_SetCol(gStartScreen, gExitText, 50, 50, 50, 255)
	MGArcade_Sprite_SetPos(gStartScreen, gExitText, -78, 170)
	MGArcade_Sprite_SetSize(gStartScreen, gExitText, 1, 1)
	--[[
	MGArcade_Sprite_SetScale(gStartScreen, gExitText, 1, 1)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gStartScreen, gExitText, 0.7, 0.7)
	else
		MGArcade_Sprite_SetScale(gStartScreen, gExitText, 1, 1)
	end
	MGArcade_Sprite_SetCollSize(gStartScreen, gExitText, 0, 0)
	MGArcade_Sprite_SetVisible(gStartScreen, gExitText, true)
	MGArcade_Sprite_SetFont(gStartScreen, gExitText, 1)
	MGArcade_Sprite_SetText(gStartScreen, gExitText, "ARCADE_BTNEXIT")
	local bRemoveLoad = false
	while not bRemoveLoad and MinigameIsActive() do
		if IsButtonBeingPressed(7, 0) and not bPressCross then
			bRemoveLoad = true
			bPressCross = true
		end
		if not IsButtonBeingPressed(7, 0) and bPressCross then
			bPressCross = false
		end
		Wait(0)
	end
	if MinigameIsActive() then
		SoundPlay2D("Trans03")
	end
	MGArcade_Layer_SetCol(gStartScreen, 255, 255, 255, 0)
	MGArcade_Sprite_SetVisible(gStartScreen, gLoadScreen, false)
end

function F_InstructScreen() -- ! Modified
	gInstructScreen = MGArcade_CreateLayer(gScreenX, gScreenY, 300, C_LayerUpdate)
	MGArcade_Layer_SetPos(gInstructScreen, 0, 0)
	MGArcade_Layer_SetCol(gInstructScreen, 0, 0, 0, 195)
	MGArcade_Layer_SetScale(gInstructScreen, 1, 1)
	local yLoc = -200
	local foodXLoc = -300
	local textXLoc = -124
	local textYLoc = -208
	local textSize = 0.9
	if GetLanguage() == 7 then -- Added this
		textSize = 0.6
	end
	local tCol = {
		235,
		235,
		235,
		255
	}
	local sCol = {
		235,
		235,
		235,
		255
	}
	gTutSprite000 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite000, 550, 400)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite000, 0, 0, 0, 128)
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite000, 0, -16)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite000, true)
	gTutText01 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText01, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText01, foodXLoc + 40, yLoc)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText01, 0.1, 0.1)
	--[[
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, 1, 1)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, textSize, textSize)
	else
		MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, 1, 1)
	end
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText01, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText01, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText01, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText01, "ARCADE_FEND_I01")
	gTutText00 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText00, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText00, textXLoc, textYLoc + 100 - 15)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText00, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText00, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText00, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText00, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText00, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText00, "ARCADE_FENDINST")
	gTutText000 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText000, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText000, textXLoc, textYLoc + 100 + 5)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText000, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText000, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText000, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText000, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText000, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText000, "ARCADE_FENDSHOOT")
	gTutText02 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText02, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText02, textXLoc, textYLoc + 150)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText02, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText02, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText02, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText02, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText02, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText02, "ARCADE_FEND_I02")
	gTutText03 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText03, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText03, textXLoc, textYLoc + 200)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText03, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText03, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText03, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText03, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText03, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText03, "ARCADE_FEND_I03")
	gTutText04 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText04, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText04, textXLoc, textYLoc + 250)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText04, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText04, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText04, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText04, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText04, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText04, "ARCADE_FEND_I04")
	gTutText05 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutText05, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutText05, textXLoc, textYLoc + 305)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutText05, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gInstructScreen, gTutText05, textSize, textSize)
	MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText05, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText05, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gTutText05, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gTutText05, "ARCADE_FEND_I05")
	gTutSprite00 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite00, 64, 32)
	MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite00, gSquirrelSpriteD)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite00, sCol[1], sCol[2], sCol[3], sCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite00, foodXLoc + 100, yLoc + 100)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite00, true)
	gTutSprite01 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite01, 32, 32)
	MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite01, gHornetAttack_texture)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite01, sCol[1], sCol[2], sCol[3], sCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite01, foodXLoc + 100, yLoc + 150)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite01, true)
	gTutSprite02 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite02, 64, 64)
	MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite02, gBatSpriteU)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite02, sCol[1], sCol[2], sCol[3], sCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite02, foodXLoc + 100, yLoc + 200)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite02, true)
	gTutSprite03 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite03, 96, 96)
	MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite03, gEagleMd)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite03, sCol[1], sCol[2], sCol[3], sCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite03, foodXLoc + 100, yLoc + 250)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite03, true)
	gTutSprite04 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite04, 100, 32)
	MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite04, gSalmonSprite)
	MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite04, sCol[1], sCol[2], sCol[3], sCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite04, foodXLoc + 100, yLoc + 305)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite04, true)
	gStartText1 = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gStartText1, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gStartText1, -100, yLoc + 330)
	MGArcade_Sprite_SetSize(gInstructScreen, gStartText1, 1, 1)
	--[[
	MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, 1, 1)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, textSize, textSize)
	else
		MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, 1, 1)
	end
	MGArcade_Sprite_SetCollSize(gInstructScreen, gStartText1, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gStartText1, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gStartText1, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gStartText1, "ARCADE_BTNSTRT")
	gExitText = MGArcade_Layer_AddSprite(gInstructScreen)
	MGArcade_Sprite_SetCol(gInstructScreen, gExitText, tCol[1], tCol[2], tCol[3], tCol[4])
	MGArcade_Sprite_SetPos(gInstructScreen, gExitText, -100, yLoc + 350)
	MGArcade_Sprite_SetSize(gInstructScreen, gExitText, 1, 1)
	--[[
	MGArcade_Sprite_SetScale(gInstructScreen, gExitText, 1, 1)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gInstructScreen, gExitText, textSize, textSize)
	else
		MGArcade_Sprite_SetScale(gInstructScreen, gExitText, 1, 1)
	end
	MGArcade_Sprite_SetCollSize(gInstructScreen, gExitText, 0, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gExitText, true)
	MGArcade_Sprite_SetFont(gInstructScreen, gExitText, 1)
	MGArcade_Sprite_SetText(gInstructScreen, gExitText, "ARCADE_BTNEXIT")
	while not IsButtonBeingPressed(7, 0) and MinigameIsActive() do
		Wait(0)
	end
	SoundStopStream()
	MGArcade_Layer_SetCol(gInstructScreen, 255, 255, 255, 0)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText00, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText000, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText01, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText02, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText03, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText04, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutText05, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite000, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite00, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite01, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite02, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite03, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite04, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gStartText1, false)
	MGArcade_Sprite_SetVisible(gInstructScreen, gExitText, false)
	if MinigameIsActive() then
		MGArcade_Sprite_SetVisible(gLayer, gSquirrel, true)
	end
end

function F_RemoveInst()
	if not bInstRemoved and instTimer <= GetTimer() then
		MGArcade_Layer_SetCol(gInstructScreen, 255, 255, 255, 0)
		MGArcade_Sprite_SetVisible(gInstructScreen, gInstructScreen01, false)
		MGArcade_Sprite_SetVisible(gInstructScreen, gInstructScreen02, false)
		bInstRemoved = true
	end
end

function F_GameOverScreen()
	local overScreen = MGArcade_GetTextureID("GameOver", "GameOver_x")
	gGameOverLayer = MGArcade_CreateLayer(gScreenX, gScreenY, 100, C_LayerUpdate)
	MGArcade_Layer_SetPos(gGameOverLayer, 0, 0)
	MGArcade_Layer_SetCol(gGameOverLayer, 0, 0, 0, 200)
	MGArcade_Layer_SetScale(gGameOverLayer, 1, 1)
	gOverScreen = MGArcade_Layer_AddSprite(gGameOverLayer)
	MGArcade_Sprite_SetCol(gGameOverLayer, gOverScreen, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gGameOverLayer, gOverScreen, 0, 0)
	MGArcade_Sprite_SetSize(gGameOverLayer, gOverScreen, 128, 64)
	MGArcade_Sprite_SetTexture(gGameOverLayer, gOverScreen, overScreen)
	MGArcade_Sprite_SetScale(gGameOverLayer, gOverScreen, 2, 2)
	MGArcade_Sprite_SetVisible(gGameOverLayer, gOverScreen, true)
	Wait(1500)
	SoundPlayStream("Arc_FlyingSquirrelMenu.rsm", 1, 9500, 2500)
end

function F_HighScoreScreen() -- ! Modified
	local hsY = -100
	tblHS = {
		{
			id = 0,
			id2 = 0,
			score = MinigameGetHighScore(2, 0),
			y = hsY + 20,
			flash = false,
			text = "CMG_03"
		},
		{
			id = 0,
			id2 = 0,
			score = MinigameGetHighScore(2, 1),
			y = hsY + 40,
			flash = false,
			text = "CMG_03"
		},
		{
			id = 0,
			id2 = 0,
			score = MinigameGetHighScore(2, 2),
			y = hsY + 60,
			flash = false,
			text = "CMG_03"
		},
		{
			id = 0,
			id2 = 0,
			score = MinigameGetHighScore(2, 3),
			y = hsY + 80,
			flash = false,
			text = "CMG_03"
		},
		{
			id = 0,
			id2 = 0,
			score = MinigameGetHighScore(2, 4),
			y = hsY + 100,
			flash = false,
			text = "CMG_03"
		}
	}
	local scR, scG, scB = 255, 255, 102
	gHighScoreText = MGArcade_Layer_AddSprite(gGameOverLayer)
	MGArcade_Sprite_SetCol(gGameOverLayer, gHighScoreText, scR, scG, scB, 255)
	MGArcade_Sprite_SetPos(gGameOverLayer, gHighScoreText, -75, -100)
	MGArcade_Sprite_SetSize(gGameOverLayer, gHighScoreText, 1, 1)
	--[[
	MGArcade_Sprite_SetScale(gGameOverLayer, gHighScoreText, 1.4, 1.4)
	]] -- Changed to:
	if GetLanguage() == 7 then
		MGArcade_Sprite_SetScale(gGameOverLayer, gHighScoreText, 0.8, 0.8)
	else
		MGArcade_Sprite_SetScale(gGameOverLayer, gHighScoreText, 1.4, 1.4)
	end
	MGArcade_Sprite_SetVisible(gGameOverLayer, gHighScoreText, true)
	MGArcade_Sprite_SetFont(gGameOverLayer, gHighScoreText, 1)
	MGArcade_Sprite_SetText(gGameOverLayer, gHighScoreText, "ARCADE_HIGHSCORE")
	local flashscore = 0
	flashscore = 1 + MinigameSetHighScoreFromID(2, gScore, "ARCADE_JIM")
	for i, score in tblHS do
		score.id = MGArcade_Layer_AddSprite(gGameOverLayer)
		MGArcade_Sprite_SetCol(gGameOverLayer, score.id, scR, scG, scB, 255)
		MGArcade_Sprite_SetPos(gGameOverLayer, score.id, -100, score.y)
		MGArcade_Sprite_SetSize(gGameOverLayer, score.id, 1, 1)
		--[[
		MGArcade_Sprite_SetScale(gGameOverLayer, score.id, 1.4, 1.4)
		]] -- Changed to:
		if GetLanguage() == 7 then
			MGArcade_Sprite_SetScale(gGameOverLayer, score.id, 0.8, 0.8)
		else
			MGArcade_Sprite_SetScale(gGameOverLayer, score.id, 1.4, 1.4)
		end
		MGArcade_Sprite_SetVisible(gGameOverLayer, score.id, true)
		MGArcade_Sprite_SetFont(gGameOverLayer, score.id, 1)
		MGArcade_Sprite_SetTextToScoreName(gGameOverLayer, score.id, 2, i - 1)
	end
	for i, score in tblHS do
		score.id2 = MGArcade_Layer_AddSprite(gGameOverLayer)
		MGArcade_Sprite_SetCol(gGameOverLayer, score.id2, scR, scG, scB, 255)
		MGArcade_Sprite_SetPos(gGameOverLayer, score.id2, 40, score.y)
		MGArcade_Sprite_SetSize(gGameOverLayer, score.id2, 1, 1)
		--[[
		MGArcade_Sprite_SetScale(gGameOverLayer, score.id2, 1.4, 1.4)
		]] -- Changed to:
		if GetLanguage() == 7 then
			MGArcade_Sprite_SetScale(gGameOverLayer, score.id2, 0.8, 0.8)
		else
			MGArcade_Sprite_SetScale(gGameOverLayer, score.id2, 1.4, 1.4)
		end
		MGArcade_Sprite_SetVisible(gGameOverLayer, score.id2, true)
		MGArcade_Sprite_SetFont(gGameOverLayer, score.id2, 1)
		MGArcade_Sprite_SetText(gGameOverLayer, score.id2, score.text)
		local ScoreParam = MGArcade_Sprite_AddTextParam(gGameOverLayer, score.id2, 0)
		MGArcade_Sprite_SetTextParam(gGameOverLayer, score.id2, ScoreParam, MinigameGetHighScore(2, i - 1))
	end
	local flashTime = GetTimer() + 100
	local bOn = false
	local xPress = true
	highScoreTimer = GetTimer() + 5000
	while MinigameIsActive() do
		if flashscore ~= 0 and flashTime <= GetTimer() then
			if bOn then
				MGArcade_Sprite_SetVisible(gGameOverLayer, tblHS[flashscore].id, true)
				MGArcade_Sprite_SetVisible(gGameOverLayer, tblHS[flashscore].id2, true)
				bOn = false
			elseif not bOn then
				MGArcade_Sprite_SetVisible(gGameOverLayer, tblHS[flashscore].id, false)
				MGArcade_Sprite_SetVisible(gGameOverLayer, tblHS[flashscore].id2, false)
				bOn = true
			end
			flashTime = GetTimer() + 100
		end
		F_MoveTerrain()
		if not (not IsButtonBeingPressed(7, 0) or xPress) or GetTimer() >= highScoreTimer then
			xPress = true
			bEndTheGame = true
			break
		end
		if not IsButtonBeingPressed(7, 0) and xPress then
			xPress = false
		end
		Wait(0)
	end
end

function F_InitGame() -- ! Modified
	--[[
	MGArcade_LoadTextures("MG_Fend")
	]]                                                              -- Removed this
	sSideBarLeft = MGArcade_GetTextureID("Fend_SideScreen_left") -- Added this
	sSideBarRight = MGArcade_GetTextureID("Fend_SideScreen_right") -- Added this
	MGArcade_InitScreen(128, 128, 128, sSideBarLeft, sSideBarRight) -- Added this
	F_LoadingScreen()
	if not MinigameIsActive() then
		return
	end
	local tex_sprite0 = MGArcade_GetTextureID("Jungle")
	terra_sprite1 = MGArcade_GetTextureID("Terr01", "Terr01_x")
	terra_sprite2 = MGArcade_GetTextureID("Terr02", "Terr02_x")
	terra_sprite3 = MGArcade_GetTextureID("Terr03", "Terr03_x")
	nut_sprite = MGArcade_GetTextureID("Proj_nut", "Proj_nut_x")
	TerrainSprite1 = terra_sprite1
	TerrainSprite2 = terra_sprite2
	TerrainSprite3 = terra_sprite3
	gBackDrop = MGArcade_CreateLayer(gScreenX, gScreenY, 300, C_LayerUpdate)
	MGArcade_Layer_SetPos(gBackDrop, 0, 0)
	MGArcade_Layer_SetCol(gBackDrop, 255, 255, 255, 255)
	MGArcade_Layer_SetScale(gBackDrop, 1, 1)
	gLayer = MGArcade_CreateLayer(gScreenX, gScreenY, 300, C_LayerUpdate)
	MGArcade_Layer_SetPos(gLayer, 0, 0)
	MGArcade_Layer_SetCol(gLayer, 255, 255, 255, 0)
	MGArcade_Layer_SetScale(gLayer, 1, 1)
	MGArcade_Layer_SetTexture(gLayer, tex_sprite0)
	gBackDrop01 = MGArcade_Layer_AddSprite(gBackDrop)
	MGArcade_Sprite_SetCol(gBackDrop, gBackDrop01, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gBackDrop, gBackDrop01, 0, 0)
	MGArcade_Sprite_SetSize(gBackDrop, gBackDrop01, gScreenX, gScreenY)
	MGArcade_Sprite_SetTexture(gBackDrop, gBackDrop01, tex_sprite0)
	MGArcade_Sprite_SetVisible(gBackDrop, gBackDrop01, true)
	gBackDrop03 = MGArcade_Layer_AddSprite(gBackDrop)
	MGArcade_Sprite_SetCol(gBackDrop, gBackDrop03, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gBackDrop, gBackDrop03, 0, 112)
	MGArcade_Sprite_SetSize(gBackDrop, gBackDrop03, 640, 256)
	MGArcade_Sprite_SetAcc(gBackDrop, gBackDrop03, 0, 0)
	MGArcade_Sprite_SetCollSize(gBackDrop, gBackDrop03, 0, 0)
	MGArcade_Sprite_SetTexture(gBackDrop, gBackDrop03, terra_sprite1)
	MGArcade_Sprite_SetVisible(gBackDrop, gBackDrop03, true)
	gBackDrop04 = MGArcade_Layer_AddSprite(gBackDrop)
	MGArcade_Sprite_SetCol(gBackDrop, gBackDrop04, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gBackDrop, gBackDrop04, 640, 112)
	MGArcade_Sprite_SetSize(gBackDrop, gBackDrop04, 640, 256)
	MGArcade_Sprite_SetVel(gBackDrop, gBackDrop04, 0, 0)
	MGArcade_Sprite_SetAcc(gBackDrop, gBackDrop04, 0, 0)
	MGArcade_Sprite_SetCollSize(gBackDrop, gBackDrop04, 0, 0)
	MGArcade_Sprite_SetTexture(gBackDrop, gBackDrop04, terra_sprite1)
	MGArcade_Sprite_SetVisible(gBackDrop, gBackDrop04, true)
	gSquirrelSpriteU = MGArcade_GetTextureID("FSquir03", "FSquir03_x")
	gSquirrelSprite0 = MGArcade_GetTextureID("FSquir02", "FSquir02_x")
	gSquirrelSpriteD = MGArcade_GetTextureID("FSquir", "FSquir_x")
	gSquirrelSpriteDead = MGArcade_GetTextureID("FSquir_dead", "FSquir_dead_x")
	gSquirrelFrame = gSquirrelSprite0
	gSquirrel = MGArcade_Layer_AddSprite(gLayer, cbSquirrleUpdate, C_SquirrleColl)
	MGArcade_Sprite_SetCol(gLayer, gSquirrel, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gLayer, gSquirrel, -150, -100)
	MGArcade_Sprite_SetSize(gLayer, gSquirrel, 64, 32)
	MGArcade_Sprite_SetVel(gLayer, gSquirrel, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gSquirrel, 0, 0)
	MGArcade_Sprite_SetCollSize(gLayer, gSquirrel, 64, 32)
	MGArcade_Sprite_SetTexture(gLayer, gSquirrel, gSquirrelFrame)
	MGArcade_Sprite_SetVisible(gLayer, gSquirrel, false)
	gBatSpriteU = MGArcade_GetTextureID("BatU", "BatU_x")
	gBatSpriteM = MGArcade_GetTextureID("BatM", "BatM_x")
	gBatSpriteD = MGArcade_GetTextureID("BatD", "BatD_x")
	gBat = MGArcade_Layer_AddSprite(gLayer, cbBatUpdate, C_BatColl)
	MGArcade_Sprite_SetCol(gLayer, gBat, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gLayer, gBat, 350, 400)
	MGArcade_Sprite_SetSize(gLayer, gBat, 64, 64)
	MGArcade_Sprite_SetVel(gLayer, gBat, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gBat, 0, 0)
	MGArcade_Sprite_SetCollSize(gLayer, gBat, 64, 64)
	MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteU)
	MGArcade_Sprite_SetVisible(gLayer, gBat, true)
	gHUD = MGArcade_CreateLayer(640, 32, 48, C_LayerUpdate)
	--[[
	MGArcade_Layer_SetPos(gHUD, 0, -216)
	]] -- Changed to:
	MGArcade_Layer_SetPos(gHUD, 0, -200)
	MGArcade_Layer_SetCol(gHUD, 51, 102, 204, 28)
	MGArcade_Layer_SetScale(gHUD, 1, 1)
	gScoreText = MGArcade_Layer_AddSprite(gHUD)
	MGArcade_Sprite_SetCol(gHUD, gScoreText, 200, 200, 200, 255)
	--[[
	MGArcade_Sprite_SetPos(gHUD, gScoreText, 16, 0)
	]] -- Changed to:
	MGArcade_Sprite_SetPos(gHUD, gScoreText, 16, -15)
	MGArcade_Sprite_SetSize(gHUD, gScoreText, 0.1, 0.1)
	MGArcade_Sprite_SetScale(gHUD, gScoreText, 0.6, 0.6)
	MGArcade_Sprite_SetCollSize(gHUD, gScoreText, 0, 0)
	MGArcade_Sprite_SetVisible(gHUD, gScoreText, true)
	gScoreParam = MGArcade_Sprite_AddTextParam(gHUD, gScoreText, 0)
	MGArcade_Sprite_SetText(gHUD, gScoreText, "ARCADE_SCORE")
	F_MakeEagle()
	F_Tables()
	F_MakeEchos()
	F_MakeLives()
	F_MakeNut()
	F_MakeHornets()
	F_MakeStinger()
	F_MakeTerrain()
end

function F_StartGame()
	MGArcade_Sprite_SetVel(gBackDrop, gBackDrop03, -15, 0)
	MGArcade_Sprite_SetVel(gBackDrop, gBackDrop04, -15, 0)
	for i, land in tblTerrain2 do
		MGArcade_Sprite_SetVel(gBackDrop, land.id, -75, 0)
	end
	for i, land in tblTerrain3 do
		gTerrain = land.id
		MGArcade_Sprite_SetVel(gBackDrop, land.id, -28, 0)
		local randy = math.random(1, 5)
		MGArcade_Sprite_SetScale(gBackDrop, gTerrain, 1, 1)
		if randy == 1 then
			MGArcade_Sprite_SetScale(gBackDrop, gTerrain, 1.25, 1.25)
		elseif randy == 2 then
			MGArcade_Sprite_SetScale(gBackDrop, gTerrain, 1.5, 1.5)
		elseif randy == 3 then
			MGArcade_Sprite_SetScale(gBackDrop, gTerrain, 0.5, 0.5)
		elseif randy == 4 then
			MGArcade_Sprite_SetScale(gBackDrop, gTerrain, 0.75, 0.75)
		end
		local randy = math.random(1, 5)
		MGArcade_Sprite_SetVel(gBackDrop, gTerrain, -28, 0)
		if randy == 1 then
			MGArcade_Sprite_SetVel(gBackDrop, gTerrain, -60, 0)
		elseif randy == 2 then
			MGArcade_Sprite_SetVel(gBackDrop, gTerrain, -38, 0)
		elseif randy == 3 then
			MGArcade_Sprite_SetVel(gBackDrop, gTerrain, -58, 0)
		elseif randy == 4 then
			MGArcade_Sprite_SetVel(gBackDrop, gTerrain, -45, 0)
		end
		local randy = math.random(1, 5)
		MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y)
		if randy == 1 then
			MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y + 5)
		elseif randy == 2 then
			MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y - 5)
		elseif randy == 3 then
			MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y + 2)
		elseif randy == 4 then
			MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y - 2)
		end
	end
end

function F_Tables()
	bat = {
		state = BAT_PARKED,
		id = 0,
		time = 9999999,
		wingtime = 0,
		x = 350,
		y = 400,
		wingup = false,
		attack = false
	}
	bat.id = gBat
	tblEchos = {
		{
			state = ECHO_PARKED,
			id = 0,
			sizeX = 16,
			sizeY = 32,
			x = -192,
			y = -780
		},
		{
			state = ECHO_PARKED,
			id = 0,
			sizeX = 16,
			sizeY = 32,
			x = -128,
			y = -780
		},
		{
			state = ECHO_PARKED,
			id = 0,
			sizeX = 16,
			sizeY = 32,
			x = -64,
			y = -780
		}
	}
	tblTerrain1 = {
		{
			id = 0,
			x = -320,
			y = 150
		},
		{
			id = 0,
			x = -192,
			y = 150
		},
		{
			id = 0,
			x = -64,
			y = 150
		},
		{
			id = 0,
			x = 64,
			y = 150
		},
		{
			id = 0,
			x = 192,
			y = 150
		},
		{
			id = 0,
			x = 320,
			y = 150
		},
		{
			id = 0,
			x = 448,
			y = 150
		}
	}
	tblTerrain2 = {
		{
			id = 0,
			x = -320,
			y = 206
		},
		{
			id = 0,
			x = -192,
			y = 206
		},
		{
			id = 0,
			x = -64,
			y = 206
		},
		{
			id = 0,
			x = 64,
			y = 206
		},
		{
			id = 0,
			x = 192,
			y = 206
		},
		{
			id = 0,
			x = 320,
			y = 206
		},
		{
			id = 0,
			x = 448,
			y = 206
		}
	}
	tblTerrain3 = {
		{
			id = 0,
			x = -320,
			y = -170
		},
		{
			id = 0,
			x = -192,
			y = -170
		},
		{
			id = 0,
			x = -64,
			y = -170
		},
		{
			id = 0,
			x = 64,
			y = -170
		},
		{
			id = 0,
			x = 192,
			y = -170
		},
		{
			id = 0,
			x = 320,
			y = -170
		},
		{
			id = 0,
			x = 448,
			y = -170
		}
	}
	tblBananas = {
		{
			state = BANANA_PARKED,
			id = 0,
			x = -192,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = -128,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = -64,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = 0,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = 64,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = 128,
			y = -180
		},
		{
			state = BANANA_PARKED,
			id = 0,
			x = 192,
			y = -180
		}
	}
	tblSpiders = {
		{
			state = SPIDER_PARKED,
			id = 0,
			time = 0,
			x = -100,
			y = -300
		},
		{
			state = SPIDER_PARKED,
			id = 0,
			time = 0,
			x = -50,
			y = -300
		},
		{
			state = SPIDER_PARKED,
			id = 0,
			time = 0,
			x = 50,
			y = -300
		},
		{
			state = SPIDER_PARKED,
			id = 0,
			time = 0,
			x = 100,
			y = -300
		}
	}
	tblHornets = {
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = -180,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = -128,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = -64,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = 0,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = 64,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = 128,
			attack = false,
			wingup = true
		},
		{
			state = HORNET_PARKED,
			id = 0,
			time = 0,
			wingtime = 0,
			x = 350,
			y = 180,
			attack = false,
			wingup = true
		}
	}
	tblStingers = {
		{
			state = STINGER_PARKED,
			id = 0,
			x = -254,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -248,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -242,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -236,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -230,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -224,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -218,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -212,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -206,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -200,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -194,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -188,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -182,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -176,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -164,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -158,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -152,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -146,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -140,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -134,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -128,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -122,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -116,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -110,
			y = -300
		},
		{
			state = STINGER_PARKED,
			id = 0,
			x = -104,
			y = -300
		}
	}
	tblNut = {
		{
			state = NUT_PARKED,
			id = 0,
			x = -254,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -248,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -242,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -236,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -230,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -224,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -218,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -212,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -206,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -200,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -194,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -188,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -182,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -176,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -164,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -158,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -152,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -146,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -140,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -134,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -128,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -122,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -116,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -110,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -104,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -98,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -92,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -86,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -80,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -74,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -68,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -62,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -56,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -50,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -44,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -38,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -32,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -26,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -20,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -14,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = -8,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 254,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 248,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 242,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 236,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 230,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 224,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 218,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 212,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 206,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 200,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 194,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 188,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 182,
			y = 300
		},
		{
			state = NUT_PARKED,
			id = 0,
			x = 176,
			y = 300
		}
	}
	tblLives = {
		{
			state = LIFE_PARKED,
			id = 0,
			x = -240
		},
		{
			state = LIFE_PARKED,
			id = 0,
			x = -204
		},
		{
			state = LIFE_PARKED,
			id = 0,
			x = -168
		}
	}
end

function F_UpdateBat()
end

function F_BatSeekPlayer()
	if bat.state == BAT_FLYING then
		local px, py = MGArcade_Sprite_GetPos(gLayer, gSquirrel)
		local bx, by = MGArcade_Sprite_GetPos(gLayer, gBat)
		local batVelX = MGArcade_Sprite_GetVel(gLayer, gBat)
		if py > by then
			MGArcade_Sprite_SetVel(gLayer, gBat, batVelX, 30)
		elseif py < by then
			MGArcade_Sprite_SetVel(gLayer, gBat, batVelX, -30)
		else
			MGArcade_Sprite_SetVel(gLayer, gBat, batVelX, 0)
		end
	end
end

function F_HornetFindY()
	local x = 0
	local sect = 0
	local rand = math.random(1, 100)
	if 0 < rand and rand <= 24 then
		sect = 1
	elseif 25 <= rand and rand <= 49 then
		sect = 2
	elseif 50 <= rand and rand <= 74 then
		sect = 3
	elseif 75 <= rand and rand <= 100 then
		sect = 4
	end
	if sect == 1 then
		y = math.random(101, 120)
	elseif sect == 2 then
		y = math.random(0, 100)
	elseif sect == 3 then
		y = math.random(-100, -1)
	elseif sect == 4 then
		y = math.random(-170, -101)
	end
	return y
end

function cbAmmoUpdate(dt, lid, sid)
end

function cbLifeUpdate(dt, lid, sid)
end

function F_MoveTerrain()
	for i, land in tblTerrain2 do
		local x, y = MGArcade_Sprite_GetPos(gBackDrop, land.id)
		local lx, ly = 0, 0
		local nx = 0
		if x <= -448 then
			if i == 6 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[5].id)
			elseif i == 5 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[4].id)
			elseif i == 4 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[3].id)
			elseif i == 3 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[2].id)
			elseif i == 2 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[1].id)
			elseif i == 1 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain2[6].id)
			end
			nx = lx + 128
			MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, 206)
			MGArcade_Sprite_SetTexture(gBackDrop, land.id, terra_sprite2)
			break
		end
	end
	for i, land in tblTerrain3 do
		local x, y = MGArcade_Sprite_GetPos(gBackDrop, land.id)
		local lx, ly = 0, 0
		local nx = 0
		if x <= -448 then
			if i == 6 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[5].id)
			elseif i == 5 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[4].id)
			elseif i == 4 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[3].id)
			elseif i == 3 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[2].id)
			elseif i == 2 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[1].id)
			elseif i == 1 then
				lx, ly = MGArcade_Sprite_GetPos(gBackDrop, tblTerrain3[6].id)
			end
			nx = lx + 128
			MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170)
			local randy = math.random(1, 5)
			MGArcade_Sprite_SetScale(gBackDrop, land.id, 1, 1)
			if randy == 1 then
				MGArcade_Sprite_SetScale(gBackDrop, land.id, 1.25, 1.25)
			elseif randy == 2 then
				MGArcade_Sprite_SetScale(gBackDrop, land.id, 1.5, 1.5)
			elseif randy == 3 then
				MGArcade_Sprite_SetScale(gBackDrop, land.id, 0.5, 0.5)
			elseif randy == 4 then
				MGArcade_Sprite_SetScale(gBackDrop, land.id, 0.75, 0.75)
			end
			local randy = math.random(1, 5)
			MGArcade_Sprite_SetVel(gBackDrop, land.id, -28, 0)
			if randy == 1 then
				MGArcade_Sprite_SetVel(gBackDrop, land.id, -60, 0)
			elseif randy == 2 then
				MGArcade_Sprite_SetVel(gBackDrop, land.id, -38, 0)
			elseif randy == 3 then
				MGArcade_Sprite_SetVel(gBackDrop, land.id, -58, 0)
			elseif randy == 4 then
				MGArcade_Sprite_SetVel(gBackDrop, land.id, -45, 0)
			end
			local randy = math.random(1, 5)
			MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170)
			if randy == 1 then
				MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170 + 5)
			elseif randy == 2 then
				MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170 - 5)
			elseif randy == 3 then
				MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170 + 2)
			elseif randy == 4 then
				MGArcade_Sprite_SetPos(gBackDrop, land.id, 448, -170 - 2)
			end
			MGArcade_Sprite_SetTexture(gBackDrop, land.id, terra_sprite3)
			break
		end
	end
	local x, y = MGArcade_Sprite_GetPos(gBackDrop, gBackDrop03)
	if x <= -640 then
		local bx, by = MGArcade_Sprite_GetPos(gBackDrop, gBackDrop04)
		bx = bx + 639
		MGArcade_Sprite_SetPos(gBackDrop, gBackDrop03, bx, 112)
	end
	local x, y = MGArcade_Sprite_GetPos(gBackDrop, gBackDrop04)
	if x <= -640 then
		local bx, by = MGArcade_Sprite_GetPos(gBackDrop, gBackDrop03)
		bx = bx + 639
		MGArcade_Sprite_SetPos(gBackDrop, gBackDrop04, bx, 112)
	end
end

function C_LayerUpdate(dt, layerID)
	F_UpdateBat()
end

function cbBatUpdate(dt, lid, sid)
	if bat.state == BAT_PARKED then
		if TimerPassed(bat.time) then
			local y = F_HornetFindY()
			MGArcade_Sprite_SetPos(gLayer, gBat, 320, y)
			MGArcade_Sprite_SetVel(gLayer, gBat, -25, 0)
			MGArcade_Sprite_SetAcc(gLayer, gBat, 0, 0)
			MGArcade_Sprite_SetCollSize(gLayer, gBat, 32, 32)
			MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteU)
			bat.state = BAT_FLYING
			bat.time = GetTimer() + 2250
			bat.wingtime = GetTimer() + 200
			bat.attack = false
			bat.wingup = false
			if not bGameOver then
				SoundPlay2D("BatEntrance")
			end
		end
	elseif bat.state == BAT_FLYING then
		local x, y = MGArcade_Sprite_GetPos(gLayer, gBat)
		if x <= -260 then
			MGArcade_Sprite_SetPos(gLayer, gBat, bat.x, bat.y)
			MGArcade_Sprite_SetVel(gLayer, gBat, 0, 0)
			MGArcade_Sprite_SetAcc(gLayer, gBat, 0, 0)
			bat.state = BAT_PARKED
		end
		F_BatSeekPlayer()
		if not bat.attack then
			if TimerPassed(bat.wingtime) then
				if bat.wingup then
					MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteU)
					bat.wingtime = GetTimer() + 200
					bat.wingup = false
				elseif not bat.wingup then
					MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteD)
					bat.wingtime = GetTimer() + 200
					bat.wingup = true
				end
			elseif TimerPassed(bat.time) then
				local x, y = MGArcade_Sprite_GetPos(gLayer, gBat)
				MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteM)
				bat.time = GetTimer() + 500
				bat.attack = true
				F_BatFire(x, y)
			end
		elseif bat.attack and TimerPassed(bat.time) then
			MGArcade_Sprite_SetTexture(gLayer, gBat, gBatSpriteU)
			bat.time = GetTimer() + 2250
			bat.attack = false
			bat.wingtime = GetTimer() + 200
			bat.wingup = true
		end
	elseif bat.state == BAT_DEAD then
		local x, y = MGArcade_Sprite_GetPos(gLayer, gBat)
		if 200 <= y then
			MGArcade_Sprite_SetPos(gLayer, gBat, bat.x, bat.y)
			MGArcade_Sprite_SetVel(gLayer, gBat, 0, 0)
			MGArcade_Sprite_SetAcc(gLayer, gBat, 0, 0)
			MGArcade_Sprite_SetRotSpeed(gLayer, gBat, 0)
			MGArcade_Sprite_SetRot(gLayer, gBat, 0)
			bat.state = BAT_PARKED
			gBatHealth = 1
			bat.time = 100000000
		end
	end
end

function C_BatColl(lid, sid, clid, csid)
	if csid == gSquirrel and not bInvulnerabl and sid == gBat and gLives ~= 0 then
		bLifeChange = true
		gLives = gLives - 1
		if not bGameOver then
			SoundPlay2D("BatWaveFire")
		end
	end
end

function C_StaticCol(lid, sid, clid, csid)
end

function C_SquirrleColl(lid, sid, clid, csid)
	for i, echo in tblEchos do
		if csid == echo.id and sid == gSquirrel and not bInvulnerabl then
			--print("===== The Squirrle it hit the echo! ====")
			if not bGameOver then
				SoundPlay2D("BatWaveHit")
			end
			F_RemoveEcho(echo)
			echo.state = ECHO_PARKED
			if gLives ~= 0 then
				bLifeChange = true
				gLives = gLives - 1
			end
			break
		end
	end
end

function F_CheckStickX(stick1X)
	local vel = 0
	if gMoveX ~= 0 then
		if stick1X <= -0.3 then
			vel = gMoveSpeedXNeg
		elseif 0.3 <= stick1X then
			vel = gMoveSpeedXPos
		else
			vel = 0
		end
	end
	return vel
end

function F_CheckStickY(stick1Y)
	local vel = 0
	if gMoveY ~= 0 then
		if stick1Y <= -0.3 then
			vel = gMoveSpeedYNeg
		elseif 0.3 <= stick1Y then
			vel = gMoveSpeedYPos
		else
			vel = 0
		end
	end
	return vel
end

function cbSquirrleUpdate(dt, lid, sid) -- ! Modified
	if not bGameOver and bGameOn then
		if sid == gSquirrel and not bDead then
			local MaxX = 280
			local MinX = -280
			local MaxY = 204
			--[[
			local MinY = -184
			]] -- Changed to:
			local MinY = -168
			stick1X, stick1Y = 0, 0
			stick2X, stick2Y = 0, 0
			stick1X = -GetStickValue(16, 0)
			stick1Y = -GetStickValue(17, 0)
			stick2X = -GetStickValue(18, 0)
			stick2Y = -GetStickValue(18, 0)
			gMoveX, gMoveY = 0, 30
			MGArcade_Sprite_SetVel(lid, sid, gMoveX, gMoveY)
			local px, py = MGArcade_Sprite_GetPos(gLayer, gSquirrel)
			if 203 <= py and not bInvulnerabl then
				bLifeChange = true
				if not bGameOver then
					SoundPlay2D("HornetStingHit")
				end
			end
			if IsButtonPressed(0, 0) then
				if MinX > px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXNeg
				end
			end
			if IsButtonPressed(1, 0) then
				if MaxX < px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXPos
				end
			end
			if IsButtonPressed(2, 0) then
				if MinY > py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYNeg
				end
			end
			if IsButtonPressed(3, 0) then
				if MaxY < py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYPos
				end
			end
			if stick1X <= -0.3 and stick1Y <= 0.3 and -0.3 <= stick1Y then
				if MinX > px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXNeg
				end
			elseif 0.3 <= stick1X and stick1Y <= 0.3 and -0.3 <= stick1Y then
				if MaxX < px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXPos
				end
			elseif stick1X <= 0.3 and -0.3 <= stick1X and 0.3 <= stick1Y then
				if MaxY < py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYPos
				end
			elseif stick1X <= 0.3 and -0.3 <= stick1X and stick1Y <= -0.3 then
				if MinY > py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYNeg
				end
			elseif stick1X <= -0.3 and stick1Y <= -0.3 then
				if MinX > px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXNeg
				end
				if MinY > py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYNeg
				end
			elseif stick1X <= -0.3 and 0.3 <= stick1Y then
				if MinX > px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXNeg
				end
				if MaxY < py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYPos
				end
			elseif 0.3 <= stick1X and 0.3 <= stick1Y then
				if MaxX < px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXPos
				end
				if MaxY < py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYPos
				end
			elseif 0.3 <= stick1X and stick1Y <= -0.3 then
				if MaxX < px then
					gMoveX = 0
				else
					gMoveX = gMoveSpeedXPos
				end
				if MinY > py then
					gMoveY = 0
				else
					gMoveY = gMoveSpeedYNeg
				end
			end
			if IsButtonPressed(6, 1) then
				--print("====== player ====", gMoveX, gMoveY)
			end
			if gMoveY < 0 then
				gSquirrelFrame = gSquirrelSpriteU
			elseif 0 < gMoveY then
				gSquirrelFrame = gSquirrelSpriteD
			else
				gSquirrelFrame = gSquirrelSprite0
			end
			MGArcade_Sprite_SetTexture(lid, sid, gSquirrelFrame)
			MGArcade_Sprite_SetVel(lid, sid, gMoveX, gMoveY)
		end
		if not bDead and bGameOn then
			if IsButtonPressed(7, 0) and not bPressX and GetTimer() >= nextFireTime then
				local x, y = MGArcade_Sprite_GetPos(lid, sid)
				F_ThrowNut(x, y)
				nextFireTime = GetTimer() + fireTime
				bPressX = true
			end
			if not IsButtonPressed(7, 0) and bPressX then
				bPressX = false
			end
			if IsButtonPressed(12, 0) and not bPressR1 and GetTimer() >= nextFireTime then
				local x, y = MGArcade_Sprite_GetPos(lid, sid)
				F_ThrowNut(x, y)
				nextFireTime = GetTimer() + fireTime
				bPressR1 = true
			end
			if not IsButtonPressed(12, 0) and bPressR1 then
				bPressR1 = false
			end
		end
	end
end

function F_BatFire(x, y)
	for i, echo in tblEchos do
		if echo.state == ECHO_PARKED then
			MGArcade_Sprite_SetScale(gLayer, echo.id, 1, 1)
			MGArcade_Sprite_SetSize(gLayer, echo.id, 16, 32)
			MGArcade_Sprite_SetCollSize(gLayer, echo.id, 16, 32)
			MGArcade_Sprite_SetPos(gLayer, echo.id, x - 16, y)
			MGArcade_Sprite_SetVel(gLayer, echo.id, -150, 0)
			if not bGameOver then
				SoundPlay2D("BatWaveFire")
			end
			echo.state = ECHO_THROWN
			break
		end
	end
end

function F_HornetFire(x, y)
	for i, stinger in tblStingers do
		if stinger.state == STINGER_PARKED then
			MGArcade_Sprite_SetPos(gLayer, stinger.id, x - 16, y)
			MGArcade_Sprite_SetVel(gLayer, stinger.id, -200, 0)
			stinger.state = STINGER_THROWN
			if not bGameOver then
				SoundPlay2D("HornetStingFire")
			end
			break
		end
	end
end

function F_ThrowNut(x, y)
	for i, nut in tblNut do
		if nut.state == NUT_PARKED then
			MGArcade_Sprite_SetPos(gLayer, nut.id, x + 32, y)
			MGArcade_Sprite_SetVel(gLayer, nut.id, 300, 0)
			if not bGameOver then
				SoundPlay2D("NutFire")
			end
			nut.state = NUT_THROWN
			break
		end
	end
end

function F_GetParkedShot()
	local shot = 0
	for i, nut in tblNut do
		if nut.state == NUT_PARKED then
			shot = nut.id
			nut.state = NUT_THROWN
			break
		end
	end
	return shot
end

function cbStaticObjects(dt, lid, sid)
end

function F_ParkNut(sid)
	for i, nut in tblNut do
		if nut.id == sid then
			MGArcade_Sprite_SetPos(gLayer, sid, nut.x, nut.y)
			MGArcade_Sprite_SetVel(gLayer, sid, 0, 0)
			MGArcade_Sprite_SetAcc(gLayer, sid, 0, 0)
			nut.state = NUT_PARKED
			break
		end
	end
end

function C_NutColl(lid, sid, clid, csid)
	if csid == gSquirrel then
	elseif csid == gBat then
		if 1 <= gBatHealth then
			--print("===== bat health =====", gBatHealth)
			gBatHealth = gBatHealth - 1
			F_ParkNut(sid)
		elseif bat.state ~= BAT_DEAD and bat.state ~= BAT_PARKED then
			MGArcade_Sprite_SetVel(gLayer, gBat, -15, 45)
			MGArcade_Sprite_SetAcc(gLayer, gBat, -35, 85)
			MGArcade_Sprite_SetCollSize(gLayer, gBat, 0, 0)
			MGArcade_Sprite_SetRotSpeed(gLayer, gBat, -30)
			bat.state = BAT_DEAD
			gDeadBats = gDeadBats + 1
			if not bGameOver then
				gScore = gScore + 500
				MGArcade_Sprite_SetTextParam(gHUD, gScoreText, gScoreParam, gScore)
				SoundPlay2D("BatDestroyed")
			end
			--print("=== One More Bat Dead =====")
			if gDeadBats == 3 then
				bWhereEaglesDare = true
				gEagleLaunchTime = GetTimer() + 1500
				gDeadBats = 0
				--print("=== Here comes an eagle =====")
			else
				--print("=== Here comes more hornets =====")
				F_ResetHornetTimes()
				bHornetSuspend = false
				F_HornetRespawnTimes()
				gHornetsLeft = 10
			end
		end
	elseif csid == gEagle then
		if 1 <= gEagleHealth then
			gEagleHealth = gEagleHealth - 1
			bEagleHit = true
			gEagleHitTime = GetTimer() + 250
			F_ParkNut(sid)
		elseif gEagleState ~= EAGLE_FALLING and gEagleState ~= EAGLE_DEAD then
			if not bGameOver then
				gScore = gScore + 1050
				SoundPlay2D("EagleDestroyed")
				MGArcade_Sprite_SetTextParam(gHUD, gScoreText, gScoreParam, gScore)
			end
			gEagleState = EAGLE_FALLING
		end
	end
end

function F_ResetHornetTimes()
	local lasttime = 0
	for i, hornet in tblHornets do
		if hornet.status == HORNET_PARKED then
			local nexttime = lasttime + 250
			hornet.time = GetTimer() + nexttime + 1000
			lastime = nexttime
		end
	end
end

function cbNutUpdate(dt, lid, sid)
	if lid == gLayer then
		for i, nut in tblNut do
			if sid == nut.id then
				local x, y = MGArcade_Sprite_GetPos(lid, nut.id)
				if nut.state == NUT_THROWN and 320 <= x then
					F_RemoveNut(nut)
				end
				break
			end
		end
	end
end

function F_RemoveNut(nut)
	MGArcade_Sprite_SetPos(gLayer, nut.id, nut.x, nut.y)
	MGArcade_Sprite_SetVel(gLayer, nut.id, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, nut.id, 0, 0)
	nut.state = NUT_PARKED
end

function F_MakeNut()
	for i, nut in tblNut do
		gNut = MGArcade_Layer_AddSprite(gLayer, cbNutUpdate, C_NutColl)
		MGArcade_Sprite_SetCol(gLayer, gNut, 204, 153, 0, 255)
		MGArcade_Sprite_SetPos(gLayer, gNut, nut.x, nut.y)
		MGArcade_Sprite_SetSize(gLayer, gNut, 32, 32)
		MGArcade_Sprite_SetVel(gLayer, gNut, 0, 0)
		MGArcade_Sprite_SetAcc(gLayer, gNut, 0, 0)
		MGArcade_Sprite_SetCollSize(gLayer, gNut, 32, 32)
		MGArcade_Sprite_SetTexture(gLayer, gNut, nut_sprite)
		MGArcade_Sprite_SetVisible(gLayer, gNut, true)
		MGArcade_Sprite_SetScale(gLayer, gNut, 0.5, 0.5)
		nut.id = gNut
	end
end

function F_MakeHornets()
	gHornetUp_texture = MGArcade_GetTextureID("HornetU", "HornetU_x")
	gHornetDn_texture = MGArcade_GetTextureID("HornetD", "HornetD_x")
	gHornetAttack_texture = MGArcade_GetTextureID("HornetF", "HornetF_x")
	local lastspawntime = 1000
	for i, hornet in tblHornets do
		gHornet = MGArcade_Layer_AddSprite(gLayer, cbHornetUpdate, C_HornetColl)
		MGArcade_Sprite_SetCol(gLayer, gHornet, 255, 255, 255, 255)
		MGArcade_Sprite_SetPos(gLayer, gHornet, hornet.x, hornet.y)
		MGArcade_Sprite_SetSize(gLayer, gHornet, 32, 32)
		MGArcade_Sprite_SetVel(gLayer, gHornet, 0, 0)
		MGArcade_Sprite_SetAcc(gLayer, gHornet, 0, 0)
		MGArcade_Sprite_SetCollSize(gLayer, gHornet, 32, 32)
		MGArcade_Sprite_SetTexture(gLayer, gHornet, gHornetUp_texture)
		MGArcade_Sprite_SetVisible(gLayer, gHornet, true)
		hornet.id = gHornet
		local rand = math.random(1, 5)
		local respawntime = 0
		if rand == 1 then
			respawntime = 1000
		elseif rand == 2 then
			respawntime = 1500
		elseif rand == 3 then
			respawntime = 2000
		elseif rand == 4 then
			respawntime = 2500
		elseif rand == 5 then
			respawntime = 500
		end
		respawntime = lastspawntime + respawntime
		hornet.time = GetTimer() + respawntime
		lastspawntime = respawntime
	end
end

function F_MakeStinger()
	local tex_sprite1 = MGArcade_GetTextureID("Honey", "Honey_x")
	for i, stinger in tblStingers do
		gStinger = MGArcade_Layer_AddSprite(gLayer, cbStingerUpdate, C_StingerColl)
		MGArcade_Sprite_SetCol(gLayer, gStinger, 255, 255, 0, 255)
		MGArcade_Sprite_SetPos(gLayer, gStinger, stinger.x, stinger.y)
		MGArcade_Sprite_SetSize(gLayer, gStinger, 16, 8)
		MGArcade_Sprite_SetVel(gLayer, gStinger, 0, 0)
		MGArcade_Sprite_SetAcc(gLayer, gStinger, 0, 0)
		MGArcade_Sprite_SetCollSize(gLayer, gStinger, 16, 8)
		MGArcade_Sprite_SetTexture(gLayer, gStinger, tex_sprite1)
		MGArcade_Sprite_SetVisible(gLayer, gStinger, true)
		stinger.id = gStinger
	end
end

function F_MakeTerrain()
	for i, land in tblTerrain2 do
		local terra_sprite = TerrainSprite2
		local gTerrain = MGArcade_Layer_AddSprite(gBackDrop)
		MGArcade_Sprite_SetCol(gBackDrop, gTerrain, 255, 255, 255, 255)
		MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y)
		MGArcade_Sprite_SetSize(gBackDrop, gTerrain, 128, 64)
		MGArcade_Sprite_SetVel(gBackDrop, gTerrain, 0, 0)
		MGArcade_Sprite_SetAcc(gBackDrop, gTerrain, 0, 0)
		MGArcade_Sprite_SetCollSize(gBackDrop, gTerrain, 128, 64)
		MGArcade_Sprite_SetTexture(gBackDrop, gTerrain, terra_sprite2)
		MGArcade_Sprite_SetVisible(gBackDrop, gTerrain, true)
		land.id = gTerrain
	end
	for i, land in tblTerrain3 do
		local terra_sprite = TerrainSprite3
		local gTerrain = MGArcade_Layer_AddSprite(gBackDrop)
		MGArcade_Sprite_SetCol(gBackDrop, gTerrain, 255, 255, 255, 255)
		MGArcade_Sprite_SetPos(gBackDrop, gTerrain, land.x, land.y)
		MGArcade_Sprite_SetSize(gBackDrop, gTerrain, 128, 64)
		MGArcade_Sprite_SetVel(gBackDrop, gTerrain, 0, 0)
		MGArcade_Sprite_SetAcc(gBackDrop, gTerrain, 0, 0)
		MGArcade_Sprite_SetCollSize(gBackDrop, gTerrain, 128, 64)
		MGArcade_Sprite_SetTexture(gBackDrop, gTerrain, terra_sprite3)
		MGArcade_Sprite_SetVisible(gBackDrop, gTerrain, true)
		land.id = gTerrain
	end
end

function cbTerrainUpdate(dt, lid, sid)
end

function cbStingerUpdate(dt, lid, sid)
	if bGameOn then
		for i, stingers in tblStingers do
			if sid == stingers.id then
				stinger = stingers
				bFoundStinger = true
				break
			end
		end
		if bFoundStinger then
			if stinger.state == STINGER_THROWN then
				local x, y = MGArcade_Sprite_GetPos(gLayer, stinger.id)
				if x <= -320 then
					MGArcade_Sprite_SetPos(gLayer, stinger.id, stinger.x, stinger.y)
					MGArcade_Sprite_SetVel(gLayer, stinger.id, 0, 0)
					MGArcade_Sprite_SetAcc(gLayer, stinger.id, 0, 0)
					stinger.state = STINGER_PARKED
				end
			end
			bFoundStinger = false
		end
	end
end

function C_StingerColl(lid, sid, clid, csid)
	for i, stinger in tblStingers do
		if sid == stinger.id and csid == gSquirrel and not bInvulnerabl then
			F_RemoveStinger(stinger)
			if gLives ~= 0 then
				bLifeChange = true
				gLives = gLives - 1
				if not bGameOver then
					SoundPlay2D("HornetStingHit")
				end
			end
		end
	end
end

function F_RemoveStinger(stinger)
	MGArcade_Sprite_SetPos(gLayer, stinger.id, stinger.x, stinger.y)
	MGArcade_Sprite_SetVel(gLayer, stinger.id, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, stinger.id, 0, 0)
	MGArcade_Sprite_SetScale(gLayer, stinger.id, 1, 1)
	stinger.state = STINGER_PARKED
end

function cbHornetUpdate(dt, lid, sid)
	if bGameOn then
		for i, hornets in tblHornets do
			if sid == hornets.id then
				hornet = hornets
				bFoundHornet = true
				break
			end
		end
		if bFoundHornet then
			if hornet.state == HORNET_PARKED then
				if TimerPassed(hornet.time) and not bHornetSuspend then
					local y = F_HornetFindY()
					MGArcade_Sprite_SetPos(gLayer, hornet.id, 320, y)
					local rand = math.random(1, 100)
					local velx = -25
					local vely = -25
					if 1 <= rand and rand <= 24 then
						vel = -25
					elseif 25 <= rand and rand <= 49 then
						vel = -30
					elseif 50 <= rand and rand <= 74 then
						vel = -35
					elseif 75 <= rand and rand <= 100 then
						vel = -40
					end
					local rand = math.random(1, 50)
					if 1 <= rand and rand <= 24 then
						vely = 25
					elseif 25 <= rand and rand <= 50 then
						vely = -25
					end
					MGArcade_Sprite_SetVel(gLayer, hornet.id, velx, vely)
					MGArcade_Sprite_SetAcc(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetCollSize(gLayer, hornet.id, 16, 16)
					hornet.state = HORNET_FALLING
					hornet.time = GetTimer() + 1500
					hornet.wingtime = GetTimer() + 100
					if not bGameOver then
						SoundPlay2D("HornetEntrance")
					end
				end
			elseif hornet.state == HORNET_FALLING then
				local x, y = MGArcade_Sprite_GetPos(gLayer, hornet.id)
				local velx, vely = MGArcade_Sprite_GetVel(gLayer, hornet.id)
				if 206 <= y then
					vely = -25
				elseif y <= -206 then
					vely = 25
				end
				MGArcade_Sprite_SetVel(gLayer, hornet.id, velx, vely)
				if x <= -320 then
					MGArcade_Sprite_SetPos(gLayer, hornet.id, hornet.x, hornet.y)
					MGArcade_Sprite_SetVel(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetAcc(gLayer, hornet.id, 0, 0)
					hornet.state = HORNET_PARKED
					gHornetsDead = gHornetsDead + 1
					local rand = math.random(1, 5)
					local respawntime = 0
					if rand == 1 then
						respawntime = 1000
					elseif rand == 2 then
						respawntime = 1500
					elseif rand == 3 then
						respawntime = 2000
					elseif rand == 4 then
						respawntime = 2500
					elseif rand == 5 then
						respawntime = 3000
					end
					hornet.time = GetTimer() + respawntime
				end
				if not hornet.attack then
					if TimerPassed(hornet.wingtime) then
						if hornet.wingup then
							MGArcade_Sprite_SetTexture(gLayer, hornet.id, gHornetUp_texture)
							hornet.wingtime = GetTimer() + 100
							hornet.wingup = false
						elseif not hornet.wingup then
							MGArcade_Sprite_SetTexture(gLayer, hornet.id, gHornetDn_texture)
							hornet.wingtime = GetTimer() + 100
							hornet.wingup = true
						end
					elseif TimerPassed(hornet.time) then
						local x, y = MGArcade_Sprite_GetPos(gLayer, hornet.id)
						MGArcade_Sprite_SetTexture(gLayer, hornet.id, gHornetAttack_texture)
						hornet.time = GetTimer() + 500
						hornet.attack = true
						F_HornetFire(x, y)
					end
				elseif hornet.attack and TimerPassed(hornet.time) and hornet.attack then
					MGArcade_Sprite_SetTexture(gLayer, hornet.id, gHornetUp_texture)
					hornet.time = GetTimer() + 2500
					hornet.attack = false
					hornet.wingtime = GetTimer() + 100
					hornet.wingup = true
				end
			elseif hornet.state == HORNET_DEAD then
				local x, y = MGArcade_Sprite_GetPos(gLayer, hornet.id)
				if 240 <= y then
					MGArcade_Sprite_SetPos(gLayer, hornet.id, hornet.x, hornet.y)
					MGArcade_Sprite_SetVel(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetAcc(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetCollSize(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetRotSpeed(gLayer, hornet.id, 0)
					MGArcade_Sprite_SetRot(gLayer, hornet.id, 0)
					hornet.state = HORNET_PARKED
					local rand = math.random(1, 5)
					local respawntime = 0
					if rand == 1 then
						respawntime = 1000
					elseif rand == 2 then
						respawntime = 1500
					elseif rand == 3 then
						respawntime = 2000
					elseif rand == 4 then
						respawntime = 2500
					elseif rand == 5 then
						respawntime = 3000
					end
					hornet.time = GetTimer() + respawntime
				end
			end
			bFoundHornet = false
		end
	end
end

function C_HornetColl(lid, sid, clid, csid)
	if csid == gSquirrel and not bInvulnerabl then
		for i, hornets in tblHornets do
			if sid == hornets.id and gLives ~= 0 then
				bLifeChange = true
				gLives = gLives - 1
				if not bGameOver then
					SoundPlay2D("HornetStingHit")
				end
			end
		end
	end
	if sid == gSquirrel then
		return
	end
	for i, nut in tblNut do
		if csid == nut.id then
			F_RemoveNut(nut)
			for j, hornet in tblHornets do
				if sid == hornet.id and hornet.state == HORNET_FALLING then
					MGArcade_Sprite_SetVel(gLayer, hornet.id, -5, 45)
					MGArcade_Sprite_SetAcc(gLayer, hornet.id, -15, 85)
					MGArcade_Sprite_SetCollSize(gLayer, hornet.id, 0, 0)
					MGArcade_Sprite_SetRotSpeed(gLayer, hornet.id, 35)
					hornet.state = HORNET_DEAD
					if not bGameOver then
						gScore = gScore + 250
						SoundPlay2D("HornetDestroyed")
						MGArcade_Sprite_SetTextParam(gHUD, gScoreText, gScoreParam, gScore)
					end
					gHornetsDead = gHornetsDead + 1
					if 10 <= gHornetsDead and not bWaitForRemainingDeadHornets then
						--print("=====  10 dead ======")
						gHornetsLeft = 0
						bHornetSuspend = true
						gHornetsDead = 0
						bWaitForRemainingDeadHornets = true
					end
					if bWaitForRemainingDeadHornets then
						gHornetsLeft = gHornetsLeft - 1
						if gHornetsLeft <= 0 then
							gHornetsLeft = 0
							bat.time = GetTimer() + 1000
							--print("===== bat.time ======", bat.time)
							bWaitForRemainingDeadHornets = false
						end
					end
				end
			end
		end
	end
end

function F_GetRemainingAliveHornets()
	for i, hornet in tblHornets do
		if hornet.state == HORNET_FALLING then
			gHornetsLeft = gHornetsLeft + 1
		end
	end
	if gHornetsLeft == 0 then
		bWaitForRemainingDeadHornets = true
	end
	--print("===== gHornetsLeft ======", gHornetsLeft)
end

function F_MakeLives() -- ! Modified
	local tex_sprite1 = MGArcade_GetTextureID("Life", "Life_x")
	for i, life in tblLives do
		gLife = MGArcade_Layer_AddSprite(gHUD, cbLifeUpdate)
		MGArcade_Sprite_SetCol(gHUD, gLife, 255, 255, 255, 255)
		--[[
		MGArcade_Sprite_SetPos(gHUD, gLife, life.x, 15)
		]] -- Changed to:
		MGArcade_Sprite_SetPos(gHUD, gLife, life.x, 0)
		MGArcade_Sprite_SetSize(gHUD, gLife, 32, 32)
		MGArcade_Sprite_SetVel(gHUD, gLife, 0, 0)
		MGArcade_Sprite_SetAcc(gHUD, gLife, 0, 0)
		MGArcade_Sprite_SetTexture(gHUD, gLife, tex_sprite1)
		MGArcade_Sprite_SetVisible(gHUD, gLife, true)
		life.id = gLife
	end
end

function F_RemoveEcho(echo)
	MGArcade_Sprite_SetPos(gLayer, echo.id, echo.x, echo.y)
	MGArcade_Sprite_SetScale(gLayer, echo.id, 1, 1)
	MGArcade_Sprite_SetSize(gLayer, echo.id, 16, 32)
	MGArcade_Sprite_SetCollSize(gLayer, echo.id, 16, 32)
	MGArcade_Sprite_SetVel(gLayer, echo.id, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, echo.id, 0, 0)
	echo.sizeX = 16
	echo.sizeY = 32
end

function cbEchoUpdate(dt, lid, sid) -- ! Modified
	for i, echo in tblEchos do
		if echo.id == sid and echo.state == ECHO_THROWN then
			local x, y = MGArcade_Sprite_GetPos(lid, echo.id)
			if x <= -320 then
				F_RemoveEcho(echo)
				echo.state = ECHO_PARKED
				break
			end
			--[[
			echo.sizeX = echo.sizeX * 1.025
			echo.sizeY = echo.sizeY * 1.025
			]] -- Changed to:
			echo.sizeX = echo.sizeX + 0.6
			echo.sizeY = echo.sizeY + 0.6
			MGArcade_Sprite_SetSize(gLayer, echo.id, echo.sizeX, echo.sizeY)
			break
		end
	end
end

function C_EchoColl(lid, sid, clid, csid)
	if clid == gSquirrel then
		for i, echo in tblEchos do
			if echo.id == sid and echo.state == ECHO_THROWN then
				--print("===== Parking due to hit =====")
				F_RemoveEcho(echo)
				echo.state = ECHO_PARKED
				break
			end
		end
	end
end

function F_MakeEchos()
	local tex_sprite1 = MGArcade_GetTextureID("Echo", "Echo_x")
	for i, echo in tblEchos do
		local ec_ho = MGArcade_Layer_AddSprite(gLayer, cbEchoUpdate, C_EchoColl)
		MGArcade_Sprite_SetCol(gLayer, ec_ho, 255, 255, 255, 255)
		MGArcade_Sprite_SetPos(gLayer, ec_ho, echo.x, echo.y)
		MGArcade_Sprite_SetSize(gLayer, ec_ho, 16, 32)
		MGArcade_Sprite_SetCollSize(gLayer, ec_ho, 16, 32)
		MGArcade_Sprite_SetVel(gLayer, ec_ho, 0, 0)
		MGArcade_Sprite_SetAcc(gLayer, ec_ho, 0, 0)
		MGArcade_Sprite_SetTexture(gLayer, ec_ho, tex_sprite1)
		MGArcade_Sprite_SetVisible(gLayer, ec_ho, true)
		echo.id = ec_ho
	end
end

function cbSalmon(dt, lid, sid)
	if sid == gSalmon then
		if gSalmonState == SALMON_ACTIVE then
			local x, y = MGArcade_Sprite_GetPos(lid, sid)
			if x < -320 or 240 < y then
				if gEagleState == EAGLE_ACTIVE then
					local ex, ey = MGArcade_Sprite_GetPos(gLayer, gEagle)
					local ev = MGArcade_Sprite_GetVel(gLayer, gEagle)
					MGArcade_Sprite_SetPos(gLayer, gSalmon, ex + 20, ey + 32)
					MGArcade_Sprite_SetVel(gLayer, gSalmon, ev, 0)
					MGArcade_Sprite_SetAcc(gLayer, gSalmon, 0, 0)
					gSalmonState = SALMON_ACTIVE
				else
					F_ParkSalmon()
					gSalmonState = SALMON_PARKED
				end
			end
		elseif gSalmonState == SALMON_FIRED then
			local x, y = MGArcade_Sprite_GetPos(lid, sid)
			local px, py = MGArcade_Sprite_GetPos(gLayer, gSquirrel)
			local SalmonVelX = MGArcade_Sprite_GetVel(lid, sid)
			if y < py then
				MGArcade_Sprite_SetVel(lid, sid, SalmonVelX, 50)
			elseif y > py then
				MGArcade_Sprite_SetVel(lid, sid, SalmonVelX, -50)
			else
				MGArcade_Sprite_SetVel(lid, sid, SalmonVelX, 0)
			end
			if x < -320 or 240 < y then
				if gEagleState == EAGLE_ACTIVE then
					local ex, ey = MGArcade_Sprite_GetPos(gLayer, gEagle)
					local ev = MGArcade_Sprite_GetVel(gLayer, gEagle)
					MGArcade_Sprite_SetPos(gLayer, gSalmon, ex + 20, ey + 32)
					MGArcade_Sprite_SetVel(gLayer, gSalmon, ev, 0)
					MGArcade_Sprite_SetAcc(gLayer, gSalmon, 0, 0)
					gSalmonState = SALMON_ACTIVE
				else
					F_ParkSalmon()
					gSalmonState = SALMON_PARKED
				end
			end
		elseif gSalmonState == SALMON_FALLING then
			local x, y = MGArcade_Sprite_GetPos(lid, sid)
			if x < -320 or 240 < y then
				F_ParkSalmon()
				gSalmonState = SALMON_PARKED
			end
		end
	end
end

function F_ParkSalmon()
	MGArcade_Sprite_SetPos(gLayer, gSalmon, -1000, -1000)
	MGArcade_Sprite_SetCollSize(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetVel(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetVisible(gLayer, gSalmon, false)
end

function C_SalmonColl(lid, sid, clid, csid)
	if sid == gSalmon and csid == gSquirrel and not bInvulnerabl and gSalmonState == SALMON_FIRED then
		if gLives ~= 0 then
			bLifeChange = true
			gLives = gLives - 1
			if not bGameOver then
				SoundPlay2D("EagleHit")
			end
		end
		if gEagleState == EAGLE_ACTIVE then
			local ex, ey = MGArcade_Sprite_GetPos(gLayer, gEagle)
			local ev = MGArcade_Sprite_GetVel(gLayer, gEagle)
			MGArcade_Sprite_SetPos(gLayer, gSalmon, ex + 20, ey + 32)
			MGArcade_Sprite_SetVel(gLayer, gSalmon, ev, 0)
			MGArcade_Sprite_SetAcc(gLayer, gSalmon, 0, 0)
			gSalmonState = SALMON_ACTIVE
		else
			F_ParkSalmon()
			gSalmonState = SALMON_PARKED
		end
	end
end

function F_MakeEagle()
	gEagleUp = MGArcade_GetTextureID("EagleU", "EagleU_x")
	gEagleDn = MGArcade_GetTextureID("EagleD", "EagleD_x")
	gEagleMd = MGArcade_GetTextureID("EagleM", "EagleM_x")
	gEagleDd = MGArcade_GetTextureID("EagleDead", "EagleDead_x")
	gSalmonSprite = MGArcade_GetTextureID("Salmon", "Salmon_x")
	gCurrentEagleState = gEagleUp
	gSalmon = MGArcade_Layer_AddSprite(gLayer, cbSalmon, C_SalmonColl)
	MGArcade_Sprite_SetCol(gLayer, gSalmon, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gLayer, gSalmon, -1000, -1000)
	MGArcade_Sprite_SetSize(gLayer, gSalmon, 64, 16)
	MGArcade_Sprite_SetCollSize(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetVel(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gSalmon, 0, 0)
	MGArcade_Sprite_SetTexture(gLayer, gSalmon, gSalmonSprite)
	MGArcade_Sprite_SetVisible(gLayer, gSalmon, false)
	gSalmonState = SALMON_PARKED
	gEagle = MGArcade_Layer_AddSprite(gLayer, cbEagle, C_EagleColl)
	MGArcade_Sprite_SetCol(gLayer, gEagle, 255, 255, 255, 255)
	MGArcade_Sprite_SetPos(gLayer, gEagle, -1000, -1000)
	MGArcade_Sprite_SetSize(gLayer, gEagle, 128, 128)
	MGArcade_Sprite_SetCollSize(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetVel(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetTexture(gLayer, gEagle, gCurrentEagleState)
	MGArcade_Sprite_SetVisible(gLayer, gEagle, false)
	gEagleState = EAGLE_PARKED
end

function F_ParkEagle()
	MGArcade_Sprite_SetPos(gLayer, gEagle, -1000, -1000)
	MGArcade_Sprite_SetCol(gLayer, gEagle, 255, 255, 255, 255)
	MGArcade_Sprite_SetCollSize(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetVel(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetAcc(gLayer, gEagle, 0, 0)
	MGArcade_Sprite_SetTexture(gLayer, gEagle, gCurrentEagleState)
	MGArcade_Sprite_SetVisible(gLayer, gEagle, false)
end

function cbEagle(dt, lid, sid)
	if bWhereEaglesDare and gEagleLaunchTime <= GetTimer() then
		if gEagleState == EAGLE_PARKED then
			MGArcade_Sprite_SetPos(gLayer, gEagle, 320, 0)
			MGArcade_Sprite_SetCollSize(gLayer, gEagle, 64, 64)
			MGArcade_Sprite_SetVel(gLayer, gEagle, -25, 0)
			MGArcade_Sprite_SetAcc(gLayer, gEagle, 0, 0)
			MGArcade_Sprite_SetVisible(gLayer, gEagle, true)
			MGArcade_Sprite_SetPos(gLayer, gSalmon, 325, 32)
			MGArcade_Sprite_SetCollSize(gLayer, gSalmon, 64, 16)
			MGArcade_Sprite_SetVel(gLayer, gSalmon, -25, 0)
			MGArcade_Sprite_SetVisible(gLayer, gSalmon, true)
			gSalmonState = SALMON_ACTIVE
			gEagleHealth = 25
			gEagleState = EAGLE_ACTIVE
			gEagleWingTime = GetTimer() + 500
			gEagleAttactTime = GetTimer() + 5000
			if not bGameOver then
				SoundPlay2D("EagleEntrance")
			end
		elseif gEagleState == EAGLE_ACTIVE then
			local ex, ey = MGArcade_Sprite_GetPos(gLayer, gEagle)
			if ex < -320 then
				F_ParkEagle()
				gEagleState = EAGLE_PARKED
				bWhereEaglesDare = false
				F_ResetHornetTimes()
				bHornetSuspend = false
				F_HornetRespawnTimes()
			end
			if bEagleHit then
				if GetTimer() <= gEagleHitTime then
					if not bSetRed then
						MGArcade_Sprite_SetCol(gLayer, gEagle, 255, 0, 0, 255)
						red = 255
						bSetRed = true
					else
						red = red - 15
						MGArcade_Sprite_SetCol(gLayer, gEagle, red, 0, 0, 255)
					end
				elseif GetTimer() >= gEagleHitTime then
					MGArcade_Sprite_SetCol(gLayer, gEagle, 255, 255, 255, 255)
					bSetRed = false
					bEagleHit = false
				end
			end
			if gEagleWingTime <= GetTimer() then
				if gCurrentEagleState == gEagleUp then
					gCurrentEagleState = gEagleDn
					MGArcade_Sprite_SetTexture(gLayer, gEagle, gCurrentEagleState)
					gEagleWingTime = GetTimer() + 500
				elseif gCurrentEagleState == gEagleDn then
					gCurrentEagleState = gEagleUp
					MGArcade_Sprite_SetTexture(gLayer, gEagle, gCurrentEagleState)
					gEagleWingTime = GetTimer() + 500
				end
			end
			if gEagleAttactTime <= GetTimer() then
				MGArcade_Sprite_SetTexture(gLayer, gEagle, gEagleMd)
				gEagleAttactTime = GetTimer() + 5000
				gEagleWingTime = GetTimer() + 1000
				MGArcade_Sprite_SetAcc(gLayer, gSalmon, -95, 0)
				gSalmonState = SALMON_FIRED
				if not bGameOver then
					SoundPlay2D("EagleFire")
				end
			end
		elseif gEagleState == EAGLE_FALLING then
			MGArcade_Sprite_SetTexture(gLayer, gEagle, gEagleDd)
			MGArcade_Sprite_SetVel(gLayer, gEagle, -25, 25)
			MGArcade_Sprite_SetAcc(gLayer, gEagle, -25, 25)
			MGArcade_Sprite_SetVel(gLayer, gSalmon, -25, 45)
			MGArcade_Sprite_SetAcc(gLayer, gSalmon, -25, 45)
			gSalmonState = SALMON_FALLING
			gEagleState = EAGLE_DEAD
		elseif gEagleState == EAGLE_DEAD then
			local ex, ey = MGArcade_Sprite_GetPos(gLayer, gEagle)
			if 240 < ey then
				F_ParkEagle()
				gEagleState = EAGLE_PARKED
				bWhereEaglesDare = false
				F_ResetHornetTimes()
				bHornetSuspend = false
				F_HornetRespawnTimes()
			end
		end
	end
end

function C_EagleColl(lid, sid, clid, csid)
	if csid == gSquirrel and not bInvulnerabl and sid == gEagle and gLives ~= 0 then
		bLifeChange = true
		gLives = gLives - 1
		if not bGameOver then
			SoundPlay2D("EagleHit")
		end
	end
end

function F_MoveBackdrop1(sid, nid)
	local nx, ny = MGArcade_Sprite_GetPos(gBackDrop, nid)
	local x = nx + 511
	MGArcade_Sprite_SetPos(gLayer, sid, x, 0)
end

function F_MoveBackdrop2(sid, nid)
	local nx, ny = MGArcade_Sprite_GetPos(gBackDrop, nid)
	local x = nx + 511
	MGArcade_Sprite_SetPos(gLayer, sid, x, 112)
end

function C_TerrainColl(lid, sid, clid, csid)
end

function TimerPassed(time)
	if time <= GetTimer() then
		return true
	else
		return false
	end
end

function F_HornetRespawnTimes()
	local lastspawntime = 250
	for i, hornet in tblHornets do
		local rand = math.random(1, 5)
		local respawntime = 0
		if rand == 1 then
			respawntime = 1000
		elseif rand == 2 then
			respawntime = 1500
		elseif rand == 3 then
			respawntime = 2000
		elseif rand == 4 then
			respawntime = 2500
		elseif rand == 5 then
			respawntime = 750
		end
		respawntime = lastspawntime + respawntime
		hornet.time = GetTimer() + respawntime
		lastspawntime = respawntime
	end
end
