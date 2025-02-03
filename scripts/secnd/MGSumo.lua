local gSpeedReduction = 6
local gCurrentSizes = {
    20,
    25,
    30
}
local gPlayerSize = 25
local gSizeDelta = 3
local gInitialSizeDelta = 4
local gGrowthDivisor = 1
local playerWins = false
local gPlayerShip = -1
local gInvulnerable = false
local gInvulnerableTime = -1
local gTotalInvulnerableTime = 3000
local gPlayerDied = false
local gDeathTime = -1
local gTotalDeathTime = 2000
local gCurrentNoEnemies = 3
local gSpriteFunctions = {}
local gSpeed = 200
local rSpeed = 120
local gColors = {
    {
        r = 0,
        g = 128,
        b = 0
    },
    {
        r = 0,
        g = 0,
        b = 128
    },
    {
        r = 120,
        g = 0,
        b = 0
    }
}
local gFoodGood = {}
local gFoodBad = {}
local gGameLevel = 1
local gPlayerStamina = 0
local gPlayerLevelUp = 10
local gPlayerLives = 3
local gLifeSprites = {}
local gMainLayerW = 300
local gMainLayerH = 215
local gSP = {}
local gEnemySumos = {}
local gMaxFood = 10
local gMaxEnemies = 4
local removeX, removeY = -1000, -1000
local gSpawnTime = 500
local gLastSpawn = -1
local gFacing = "F"
local gPlayerAllowMove = true
local gEnemySumoWhoHit = -1
local gAnimStage = 1
local gEnemySumoTime = 0
local gAnimationRateTime = 60
local gEnemyRateTime = 100
local gPlayerEnd = false
local gAngels = {}
local gAngelsCreated = 0
local gCurrentAngel
local gScore = 100
local scaleSpeedVal = 0.3
local gHighScore = 0
local gHighScoreConst = 0
local gbShowingInfo = false

function MissionSetup()
    MissionDontFadeIn()
    SoundDisableSpeech_ActionTree()
    SoundStopAmbiences()
    PlayerSetControl(0)
    PlayerSetInvulnerable(true)
    PedIgnoreStimuli(gPlayer, true)
    PedIgnoreAttacks(gPlayer, true)
    NonMissionPedGenerationDisable()
    AreaClearAllPeds()
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    if AreaGetVisible() == 30 then
        gHighScoreConst = 5
    end
end

function MissionCleanup()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    SoundStopStream()
    SoundEnableSpeech_ActionTree()
    SoundRestartAmbiences()
    PedIgnoreStimuli(gPlayer, false)
    PedIgnoreAttacks(gPlayer, false)
    PlayerSetInvulnerable(false)
    NonMissionPedGenerationEnable()
    MinigameDestroy()
    PlayerSetControl(1)
    if shared.NerdVendettaRunning then
        if gHighScoreAchieved then
            shared.ConSumoFinished = 100
        else
            shared.ConSumoFinished = 0
        end
    end
end

function F_RemoveSprite(lid, sid)
    MGArcade_Sprite_SetVisible(lid, sid, false)
    MGArcade_Sprite_SetCollSize(lid, sid, 0, 0)
    MGArcade_Sprite_SetVel(lid, sid, 0, 0)
    MGArcade_Sprite_SetAcc(lid, sid, 0, 0)
    MGArcade_Sprite_SetPos(lid, sid, removeX, removeY)
    for i, sId in gSP do
        if sId.id == sid then
            sId.created = false
            break
        end
    end
    for i, sId in gEnemySumos do
        if sId.id == sid then
            sId.created = false
            break
        end
    end
end

function F_GetVel(no)
    if no <= 0 then
        if no < -170 then
            return -170
        elseif -10 < no then
            return 0
        else
            return no
        end
    elseif 170 < no then
        return 170
    elseif no < 10 then
        return 0
    else
        return no
    end
end

function F_abs(no)
    if no < 0 then
        return -1 * no, -1
    else
        return no, 1
    end
end

function C_Enemy(lid, sid, clid, csid)
    if gEnemySumoWhoHit ~= sid and csid == gPlayerShip and not gInvulnerable and not gPlayerDied and not gPlayerEnd then
        local vx, vy = MGArcade_Sprite_GetVel(lid, sid)
        local vx1, vy1 = MGArcade_Sprite_GetVel(clid, csid)
        vx1 = F_GetVel(vx1)
        vy1 = F_GetVel(vy1)
        if vx1 == 0 and vy1 == 0 then
            if F_abs(vx) > F_abs(vy) then
                vx1 = -vx
                vy1 = vx / 2
            else
                vx1 = vy / 2
                vy1 = -vy
            end
        end
        MGArcade_Sprite_SetVel(clid, csid, -vx1 * 2, -vy1 * 2)
        MGArcade_Sprite_SetAcc(clid, csid, vx1 * 2, vy1 * 2)
        gPlayerAllowMove = false
        gPlayerBumped = GetTimer()
        gEnemySumoWhoHit = sid
        SoundPlay2D("Bounce")
    end
end

function C_Weak(lid, sid, clid, csid)
    if csid == gPlayerShip and not gPlayerDied and not gPlayerEnd then
        local index = F_GetTargetIndex(sid)
        local increase = gSP[index].sSize / gGrowthDivisor
        gPlayerStamina = gPlayerStamina + gSP[index].sSize / 2
        gScore = gScore + increase
        MGArcade_Sprite_SetTextParam(gInfoLayer, gScoreText, gScoreParam, gScore)
        MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBar, gPlayerStamina * 10 / gGameLevel, 10)
        F_RemoveSprite(lid, sid)
        if gPlayerStamina >= gPlayerLevelUp then
            gPlayerStamina = 0
            if gInitialSizeDelta then
                gPlayerSize = gPlayerSize + gInitialSizeDelta
                table.insert(gCurrentSizes, gCurrentSizes[gCurrentNoEnemies] + gInitialSizeDelta)
                gInitialSizeDelta = nil
            else
                gPlayerSize = gPlayerSize + gSizeDelta
                table.insert(gCurrentSizes, gCurrentSizes[gCurrentNoEnemies] + gSizeDelta)
            end
            gCurrentNoEnemies = gCurrentNoEnemies + 1
            gGameLevel = gGameLevel + 1
            gPlayerLevelUp = 10 * gGameLevel
            F_UpdateAllEnemies(lid)
            MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBar, 0, 10)
            MGArcade_Sprite_SetSize(lid, gPlayerShip, gPlayerSize, gPlayerSize)
            MGArcade_Sprite_SetCollSize(lid, gPlayerShip, gPlayerSize, gPlayerSize)
            gScore = gScore + gPlayerSize
            MGArcade_Sprite_SetTextParam(gInfoLayer, gScoreText, gScoreParam, gScore)
            gSpeed = gSpeed - gSpeedReduction
            SoundPlay2D("SumoLevelUp")
            if shared.NerdVendettaRunning then
                --print("SOUND SPEECH PLAYING COOL")
                local randomCoin = math.random(0, 100)
                if randomCoin < 50 then
                    randomCoin = math.random(0, 100)
                    if 70 < randomCoin then
                        SoundPlayScriptedSpeechEvent(gFatty, "SEE_SOMETHING_COOL", 0, "jumbo", true)
                    elseif 30 < randomCoin then
                        SoundPlayScriptedSpeechEvent(gFatty, "CONGRATULATIONS", 0, "jumbo", true)
                    else
                        SoundPlayScriptedSpeechEvent(gFatty, "LAUGH_FRIENDLY", 0, "jumbo", true)
                    end
                else
                    randomCoin = math.random(0, 100)
                    if 70 < randomCoin then
                        SoundPlayScriptedSpeechEvent(gAlgie, "SEE_SOMETHING_COOL", 0, "jumbo", true)
                    elseif 30 < randomCoin then
                        SoundPlayScriptedSpeechEvent(gAlgie, "CONGRATULATIONS", 0, "jumbo", true)
                    else
                        SoundPlayScriptedSpeechEvent(gAlgie, "LAUGH_FRIENDLY", 0, "jumbo", true)
                    end
                end
            end
        else
            SoundPlay2D("EatGood")
        end
        if shared.NerdVendettaRunning and not gDefeatedFatty and gScore > gHighScore then
            SoundStopCurrentSpeechEvent(gFatty)
            SoundPlayScriptedSpeechEvent(gFatty, "BIKE_SEE_TRICK", 0, "jumbo", true)
            gDefeatedFatty = true
        end
    end
end

function C_Mid(lid, sid, clid, csid)
    if csid == gPlayerShip and not gInvulnerable and not gPlayerDied and not gPlayerEnd then
        local index = F_GetTargetIndex(sid)
        F_RemoveSprite(lid, sid)
        gPlayerStamina = gPlayerStamina - gSP[index].sSize / 2
        if gPlayerStamina < 0 then
            MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBar, 0, 10)
            F_PlayerLoseLife(clid)
            SoundPlay2D("Death")
        else
            local increase = gSP[index].sSize / gGrowthDivisor
            gScore = gScore - increase
            MGArcade_Sprite_SetTextParam(gInfoLayer, gScoreText, gScoreParam, gScore)
            MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBar, gPlayerStamina * 10 / gGameLevel, 10)
            SoundPlay2D("EatBad")
        end
    end
end

function C_Strong(lid, sid, clid, csid)
    if csid == gPlayerShip and not gInvulnerable and not gPlayerDied and not gPlayerEnd then
        F_RemoveSprite(lid, sid)
        F_PlayerLoseLife(clid)
        SoundPlay2D("Death")
    end
end

function F_PlayerResetToCentre(lid)
    MGArcade_Sprite_SetPos(lid, gPlayerShip, 0, 0)
    gInvulnerable = true
    gInvulnerableTime = GetTimer()
    gBlinkTime = GetTimer()
    gBlinkColor = false
    MGArcade_Sprite_SetVisible(lid, gPlayerShip, gBlinkColor)
end

function F_PlayerLoseLife(lid)
    if shared.NerdVendettaRunning then
        --print("PLAYING SOUND FOR FATTY")
        local randomCoin = math.random(0, 100)
        if randomCoin < 50 then
            randomCoin = math.random(0, 100)
            if 70 < randomCoin then
                SoundPlayScriptedSpeechEvent(gFatty, "SEE_SOMETHING_CRAP", 0, "jumbo", true)
            elseif 30 < randomCoin then
                SoundPlayScriptedSpeechEvent(gFatty, "BUMP_RUDE", 0, "jumbo", true)
            else
                SoundPlayScriptedSpeechEvent(gFatty, "ALLY_ABOUT_TO_LEAVE", 0, "jumbo", true)
            end
        else
            randomCoin = math.random(0, 100)
            if 70 < randomCoin then
                SoundPlayScriptedSpeechEvent(gAlgie, "SEE_SOMETHING_CRAP", 0, "jumbo", true)
            elseif 30 < randomCoin then
                SoundPlayScriptedSpeechEvent(gAlgie, "BUMP_RUDE", 0, "jumbo", true)
            else
                SoundPlayScriptedSpeechEvent(gAlgie, "ALLY_ABOUT_TO_LEAVE", 0, "jumbo", true)
            end
        end
    end
    if 0 < gPlayerLives then
        MGArcade_Sprite_SetVisible(gInfoLayer, gLifeSprites[gPlayerLives], false)
        F_CreateAngel(lid)
    end
    gPlayerLives = gPlayerLives - 1
    if gPlayerLives <= 0 then
        gPlayerEnd = true
    else
        MGArcade_Sprite_SetVisible(lid, gPlayerShip, false)
        gPlayerDied = true
        gDeathTime = GetTimer()
    end
end

function main()
    MinigameCreate("ARCADE", false)
    SoundPlayStream("Arc_SUMO_Menu.rsm", 1, 0, 0)
    while MinigameIsReady() == false do
        Wait(0)
    end
    Wait(2)
    if shared.NerdVendettaRunning then
        gHighScore = MinigameGetHighScore(gHighScoreConst, 0)
        local px, py, pz = PlayerGetPosXYZ()
        gFatty = shared.vendettaFatty
        gAlgie = shared.vendettaAlgie
        gBucky = shared.vendettaBucky
        PedSetPosXYZ(gFatty, px, py + 1, pz)
        PedSetPosXYZ(gAlgie, px, py - 1, pz)
        PedSetPosXYZ(gBucky, -723.8684, 39.938946, -2.3328907)
        PedFaceObject(gFatty, gPlayer, 3, 0)
        PedFaceObject(gAlgie, gPlayer, 3, 0)
        PedFaceObject(gBucky, gPlayer, 3, 0)
    end
    MinigameStart()
    MinigameEnableHUD(true)
    MGArcade_LoadTextures("MG_Sumo")
    CameraFade(1000, 1)
    Wait(1100)
    sSideBarLeft = MGArcade_GetTextureID("Sumo_Sidescreen_left")
    sSideBarRight = MGArcade_GetTextureID("Sumo_Sidescreen_right")
    MGArcade_InitScreen(128, 128, 128, sSideBarLeft, sSideBarRight)
    introLayer = MGArcade_CreateLayer(640, 480, 2)
    gSpriteFunctions = {
        C_Weak,
        C_Mid,
        C_Strong
    }
    sStartScreen = MGArcade_GetTextureID("Sumo_Startscreen")
    MGArcade_Layer_SetPos(introLayer, 0, 0)
    MGArcade_Layer_SetCol(introLayer, 0, 0, 0, 255)
    MGArcade_Layer_SetScale(introLayer, 1, 1)
    gStartScreen = MGArcade_Layer_AddSprite(introLayer)
    MGArcade_Sprite_SetCol(introLayer, gStartScreen, 200, 200, 200, 255)
    MGArcade_Sprite_SetPos(introLayer, gStartScreen, 0, 0)
    MGArcade_Sprite_SetSize(introLayer, gStartScreen, 640 - 128, 480 - 64)
    MGArcade_Sprite_SetCollSize(introLayer, gStartScreen, 0, 0)
    MGArcade_Sprite_SetVisible(introLayer, gStartScreen, true)
    MGArcade_Sprite_SetTexture(introLayer, gStartScreen, sStartScreen)
    gStartText = MGArcade_Layer_AddSprite(introLayer)
    MGArcade_Sprite_SetCol(introLayer, gStartText, 150, 150, 150, 255)
    MGArcade_Sprite_SetPos(introLayer, gStartText, -100, 170)
    MGArcade_Sprite_SetSize(introLayer, gStartText, 1, 1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(introLayer, gStartText, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(introLayer, gStartText, 1.4, 1.4)
    end
    MGArcade_Sprite_SetCollSize(introLayer, gStartText, 0, 0)
    MGArcade_Sprite_SetVisible(introLayer, gStartText, true)
    MGArcade_Sprite_SetFont(introLayer, gStartText, 1)
    MGArcade_Sprite_SetText(introLayer, gStartText, "ARCADE_BTNSTRT")
    gExitText = MGArcade_Layer_AddSprite(introLayer)
    MGArcade_Sprite_SetCol(introLayer, gExitText, 150, 150, 150, 255)
    MGArcade_Sprite_SetPos(introLayer, gExitText, -100, 200)
    MGArcade_Sprite_SetSize(introLayer, gExitText, 1, 1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(introLayer, gExitText, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(introLayer, gExitText, 1.4, 1.4)
    end
    MGArcade_Sprite_SetCollSize(introLayer, gExitText, 0, 0)
    MGArcade_Sprite_SetVisible(introLayer, gExitText, true)
    MGArcade_Sprite_SetFont(introLayer, gExitText, 1)
    MGArcade_Sprite_SetText(introLayer, gExitText, "ARCADE_BTNEXIT")
    F_PrepareTextures()
    gSumoTimer = GetTimer()
    gEnemySumoTime = GetTimer()
    gFoodGood = {
        sApple,
        sRice,
        sFish
    }
    gFoodBad = {
        sAppleR,
        sRiceR,
        sFishR
    }
    local startAlpha = 255
    local gDown = true
    while not IsButtonBeingPressed(7, 0) and MinigameIsActive() do
        if gDown then
            if 150 < startAlpha then
                startAlpha = startAlpha - 5
            else
                gDown = false
            end
        elseif startAlpha < 255 then
            startAlpha = startAlpha + 5
            if 255 < startAlpha then
                startAlpha = 255
            end
        else
            gDown = true
        end
        MGArcade_Sprite_SetCol(introLayer, gStartText, 150, 150, 150, startAlpha)
        Wait(0)
    end
    local lid
    if MinigameIsActive() then
        CameraFade(500, 0)
        Wait(500)
        MGArcade_Sprite_SetVisible(introLayer, gStartScreen, false)
        CameraFade(500, 1)
        bgid = MGArcade_CreateLayer(gMainLayerW * 2, gMainLayerH * 2, 1)
        gDojo = MGArcade_Layer_AddSprite(bgid)
        MGArcade_Sprite_SetCol(bgid, gStartScreen, 128, 128, 128, 200)
        MGArcade_Sprite_SetPos(bgid, gDojo, 0, 0)
        MGArcade_Sprite_SetSize(bgid, gDojo, gMainLayerW * 2, gMainLayerH * 2)
        MGArcade_Sprite_SetCollSize(bgid, gDojo, 0, 0)
        MGArcade_Sprite_SetVisible(bgid, gDojo, true)
        MGArcade_Sprite_SetTexture(bgid, gDojo, sDojo)
        MGArcade_Layer_SetPos(bgid, 0, 20)
        MGArcade_Layer_SetCol(bgid, 0, 0, 0, 255)
        MGArcade_Layer_SetScale(bgid, 1, 1)
        lid = MGArcade_CreateLayer(gMainLayerW * 2, gMainLayerH * 2, 100, C_LayerUpdate)
        MGArcade_Layer_SetPos(lid, 0, 20)
        MGArcade_Layer_SetCol(lid, 0, 0, 0, 0)
        MGArcade_Layer_SetScale(lid, 1, 1)
        gInfoLayer = MGArcade_CreateLayer(640, 20, 8)
        MGArcade_Layer_SetPos(gInfoLayer, 0, -200)
        MGArcade_Layer_SetCol(gInfoLayer, 32, 32, 32, 255)
        MGArcade_Layer_SetScale(gInfoLayer, 1, 1)
        gStaminaBarBG = MGArcade_Layer_AddSprite(gInfoLayer)
        MGArcade_Sprite_SetCol(gInfoLayer, gStaminaBarBG, 128, 128, 128, 200)
        MGArcade_Sprite_SetPos(gInfoLayer, gStaminaBarBG, 0, 0)
        MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBarBG, 100, 10)
        MGArcade_Sprite_SetCollSize(gInfoLayer, gStaminaBarBG, 0, 0)
        MGArcade_Sprite_SetVisible(gInfoLayer, gStaminaBarBG, true)
        gStaminaBar = MGArcade_Layer_AddSprite(gInfoLayer)
        MGArcade_Sprite_SetCol(gInfoLayer, gStaminaBar, 128, 0, 0, 255)
        MGArcade_Sprite_SetPos(gInfoLayer, gStaminaBar, 0, 0)
        MGArcade_Sprite_SetSize(gInfoLayer, gStaminaBar, 0, 10)
        MGArcade_Sprite_SetCollSize(gInfoLayer, gStaminaBar, 0, 0)
        MGArcade_Sprite_SetVisible(gInfoLayer, gStaminaBar, true)
        for i = 1, gPlayerLives do
            gLifeSprites[i] = MGArcade_Layer_AddSprite(gInfoLayer)
            MGArcade_Sprite_SetPos(gInfoLayer, gLifeSprites[i], i * 15 - gMainLayerW, 0)
            MGArcade_Sprite_SetSize(gInfoLayer, gLifeSprites[i], 10, 10)
            MGArcade_Sprite_SetCollSize(gInfoLayer, gLifeSprites[i], 0, 0)
            MGArcade_Sprite_SetVisible(gInfoLayer, gLifeSprites[i], true)
            MGArcade_Sprite_SetTexture(gInfoLayer, gLifeSprites[i], sSumoF)
        end
        gScoreText = MGArcade_Layer_AddSprite(gInfoLayer)
        MGArcade_Sprite_SetCol(gInfoLayer, gScoreText, 200, 200, 200, 255)
        MGArcade_Sprite_SetPos(gInfoLayer, gScoreText, 128, -9)
        MGArcade_Sprite_SetSize(gInfoLayer, gScoreText, 0.1, 0.1)
        MGArcade_Sprite_SetScale(gInfoLayer, gScoreText, 0.4, 0.4)
        MGArcade_Sprite_SetCollSize(gInfoLayer, gScoreText, 0, 0)
        MGArcade_Sprite_SetVisible(gInfoLayer, gScoreText, true)
        gScoreParam = MGArcade_Sprite_AddTextParam(gInfoLayer, gScoreText, gScore)
        MGArcade_Sprite_SetText(gInfoLayer, gScoreText, "ARCADE_SSCORE")
        F_TutorialScreen(lid)
        gPlayerShip = MGArcade_Layer_AddSprite(lid, C_PlayerUpdate)
        MGArcade_Sprite_SetTexture(lid, gPlayerShip, sSumoF)
        MGArcade_Sprite_SetPos(lid, gPlayerShip, 0, 0)
        MGArcade_Sprite_SetSize(lid, gPlayerShip, gPlayerSize, gPlayerSize)
        MGArcade_Sprite_SetCollSize(lid, gPlayerShip, gPlayerSize, gPlayerSize)
        MGArcade_Sprite_SetVel(lid, gPlayerShip, 0, 0)
        MGArcade_Sprite_SetAcc(lid, gPlayerShip, 0, 0)
        MGArcade_Sprite_SetVisible(lid, gPlayerShip, true)
        for i = 1, gMaxFood do
            table.insert(gSP, {
                id = false,
                created = false,
                sType = 0,
                sSize = 1,
                sTex = 0
            })
        end
        for i = 1, gMaxEnemies do
            table.insert(gEnemySumos, {
                id = false,
                created = false,
                sSize = 1,
                side = 1
            })
        end
        for i = 1, gPlayerLives do
            table.insert(gAngels, { id = false, created = false })
        end
        gLastSpawn = GetTimer()
        F_PlayerResetToCentre(lid)
    end
    while MinigameIsActive() do
        if gPlayerEnd then
            SoundStopStream()
            SoundPlay2D("Gong")
            MGArcade_Sprite_SetCollSize(lid, gPlayerShip, 0, 0)
            MGArcade_Sprite_SetVisible(lid, gPlayerShip, false)
            Wait(1000)
            SoundPlayStreamNoLoop("Arc_SUMO_Lose.rsm", 1, 0)
            gGameOverSprite = MGArcade_Layer_AddSprite(lid, C_PlayerUpdate)
            MGArcade_Sprite_SetTexture(lid, gGameOverSprite, sGameOver)
            MGArcade_Sprite_SetPos(lid, gGameOverSprite, 0, 0)
            MGArcade_Sprite_SetSize(lid, gGameOverSprite, 256, 64)
            MGArcade_Sprite_SetVisible(lid, gGameOverSprite, true)
            local alpha = 0
            MGArcade_Sprite_SetCol(lid, gGameOverSprite, 255, 255, 255, alpha)
            Wait(500)
            while alpha < 255 do
                alpha = alpha + 5
                if 255 < alpha then
                    alpha = 255
                end
                MGArcade_Sprite_SetCol(lid, gGameOverSprite, 255, 255, 255, alpha)
                Wait(0)
            end
            Wait(3000)
            MGArcade_Sprite_SetVisible(lid, gGameOverSprite, false)
            F_HighScoreScreen(lid)
            MGArcade_SetCancelConfirm(false)
            CameraFade(500, 0)
            Wait(500)
            SoundStopStream()
            MinigameEnd()
        end
        Wait(0)
    end
    playerWins = true
    if shared.NerdVendettaRunning then
        if gHighScoreAchieved then
            playerWins = true
            MissionDontFadeInAfterCompetion()
        else
            playerWins = false
        end
    end
    MinigameEnableHUD(false)
    if MinigameIsActive() then
        Wait(1000)
    end
    MinigameEnd()
    if playerWins then
        MissionSucceed(false, false, false)
    else
        MissionFail(true, false)
    end
end

function F_UpdateAllEnemies(lid)
end

function F_GetTargetIndex(sid)
    for i, sId in gSP do
        if sId.id == sid then
            return i
        end
    end
end

function F_CreateAngel(lid)
    gAngelsCreated = gAngelsCreated + 1
    gAngels[gAngelsCreated] = {
        id = false,
        created = false,
        alpha = 255,
        timer = GetTimer(),
        texture = sSumoAngel
    }
    gAngels[gAngelsCreated].id = MGArcade_Layer_AddSprite(lid)
    local x, y = MGArcade_Sprite_GetPos(lid, gPlayerShip)
    MGArcade_Sprite_SetSize(lid, gAngels[gAngelsCreated].id, gPlayerSize, gPlayerSize)
    MGArcade_Sprite_SetTexture(lid, gAngels[gAngelsCreated].id, sSumoAngel)
    MGArcade_Sprite_SetPos(lid, gAngels[gAngelsCreated].id, x, y)
    MGArcade_Sprite_SetVel(lid, gAngels[gAngelsCreated].id, 0, -50)
    MGArcade_Sprite_SetAcc(lid, gAngels[gAngelsCreated].id, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gAngels[gAngelsCreated].id, true)
    gCurrentAngel = gAngelsCreated
end

function F_CreateEnemySumo(lid)
    local rSide = math.random(1, 4)
    local iSprite = false
    local newSprite = false
    for i, sId in gEnemySumos do
        if not sId.id then
            iSprite = i
            newSprite = true
            break
        elseif not sId.created then
            iSprite = i
            break
        end
    end
    if not iSprite then
        return false
    end
    if newSprite then
        gEnemySumos[iSprite].id = MGArcade_Layer_AddSprite(lid, C_SpriteUpdate, C_Enemy)
    end
    gEnemySumos[iSprite].created = true
    gEnemySumos[iSprite].sSize = gCurrentNoEnemies
    gEnemySumos[iSprite].side = rSide
    MGArcade_Sprite_SetSize(lid, gEnemySumos[iSprite].id, gCurrentSizes[gCurrentNoEnemies], gCurrentSizes[gCurrentNoEnemies])
    MGArcade_Sprite_SetCollSize(lid, gEnemySumos[iSprite].id, gCurrentSizes[gCurrentNoEnemies], gCurrentSizes[gCurrentNoEnemies])
    local x, y, vx, vy, ax, ay
    if rSide == 1 then
        x, y = -gMainLayerW, math.random(-gMainLayerH, gMainLayerH)
        vx, vy = rSpeed - gCurrentNoEnemies * 5, 0
        if gAnimStage == 1 then
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoR)
        else
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoR2)
        end
    elseif rSide == 2 then
        x, y = gMainLayerW, math.random(-gMainLayerH, gMainLayerH)
        vx, vy = -rSpeed + gCurrentNoEnemies * 5, 0
        if gAnimStage == 1 then
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoL)
        else
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoL2)
        end
    elseif rSide == 3 then
        x, y = math.random(-gMainLayerW, gMainLayerW), -gMainLayerH
        vx, vy = 0, rSpeed - gCurrentNoEnemies * 5
        if gAnimStage == 1 then
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoF)
        else
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoF2)
        end
    elseif rSide == 4 then
        x, y = math.random(-gMainLayerW, gMainLayerW), gMainLayerH
        vx, vy = 0, -rSpeed + gCurrentNoEnemies * 5
        if gAnimStage == 1 then
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoB)
        else
            MGArcade_Sprite_SetTexture(lid, gEnemySumos[iSprite].id, sESumoB2)
        end
    end
    MGArcade_Sprite_SetPos(lid, gEnemySumos[iSprite].id, x, y)
    MGArcade_Sprite_SetVel(lid, gEnemySumos[iSprite].id, vx, vy)
    MGArcade_Sprite_SetAcc(lid, gEnemySumos[iSprite].id, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gEnemySumos[iSprite].id, true)
end

function F_AnimateEnemySumos(lid)
    if gAnimStage == 1 then
        gAnimStage = 2
    else
        gAnimStage = 1
    end
    for i, sId in gEnemySumos do
        if sId.id then
            if sId.side == 1 then
                if gAnimStage == 1 then
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoR)
                else
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoR2)
                end
            elseif sId.side == 2 then
                if gAnimStage == 1 then
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoL)
                else
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoL2)
                end
            elseif sId.side == 3 then
                if gAnimStage == 1 then
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoF)
                else
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoF2)
                end
            elseif sId.side == 4 then
                if gAnimStage == 1 then
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoB)
                else
                    MGArcade_Sprite_SetTexture(lid, sId.id, sESumoB2)
                end
            end
        end
    end
end

function F_CreateTarget(lid)
    local iSprite = false
    local newSprite = false
    for i, sId in gSP do
        if not sId.id then
            iSprite = i
            newSprite = true
            break
        elseif not sId.created then
            iSprite = i
            break
        end
    end
    if not iSprite then
        return false
    end
    local eType = math.random(1, 4)
    local rNum = 1
    local rSide = math.random(1, 4)
    local lType = 1
    if eType == 4 then
        rNum = gCurrentNoEnemies
        lType = 3
    elseif eType == 3 then
        rNum = gCurrentNoEnemies - 1
        lType = 2
    else
        rNum = math.random(1, gCurrentNoEnemies - 2)
    end
    if newSprite then
        gSP[iSprite].id = MGArcade_Layer_AddSprite(lid, C_SpriteUpdate, gSpriteFunctions[lType])
    else
        MGArcade_Sprite_SetCollFunc(lid, gSP[iSprite].id, gSpriteFunctions[lType])
    end
    gSP[iSprite].created = true
    gSP[iSprite].sType = lType
    gSP[iSprite].sSize = rNum
    local texture = ""
    if lType == 1 then
        texture = RandomTableElement(gFoodGood)
    elseif lType == 2 then
        texture = RandomTableElement(gFoodBad)
    elseif lType == 3 then
        texture = sBlowFish
    end
    MGArcade_Sprite_SetTexture(lid, gSP[iSprite].id, texture)
    MGArcade_Sprite_SetSize(lid, gSP[iSprite].id, gCurrentSizes[rNum], gCurrentSizes[rNum])
    MGArcade_Sprite_SetCollSize(lid, gSP[iSprite].id, gCurrentSizes[rNum], gCurrentSizes[rNum])
    local x, y, vx, vy, ax, ay
    if rSide == 1 then
        x, y = -gMainLayerW, math.random(-(gMainLayerH - gCurrentSizes[rNum]), gMainLayerH - gCurrentSizes[rNum])
        vx, vy = rSpeed - rNum * 5, 0
    elseif rSide == 2 then
        x, y = gMainLayerW, math.random(-(gMainLayerH - gCurrentSizes[rNum]), gMainLayerH - gCurrentSizes[rNum])
        vx, vy = -rSpeed + rNum * 5, 0
    elseif rSide == 3 then
        x, y = math.random(-(gMainLayerW - gCurrentSizes[rNum]), gMainLayerW - gCurrentSizes[rNum]), -gMainLayerH
        vx, vy = 0, rSpeed - rNum * 5
    elseif rSide == 4 then
        x, y = math.random(-(gMainLayerW - gCurrentSizes[rNum]), gMainLayerW - gCurrentSizes[rNum]), gMainLayerH
        vx, vy = 0, -rSpeed + rNum * 5
    end
    MGArcade_Sprite_SetPos(lid, gSP[iSprite].id, x, y)
    MGArcade_Sprite_SetVel(lid, gSP[iSprite].id, vx, vy)
    MGArcade_Sprite_SetAcc(lid, gSP[iSprite].id, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gSP[iSprite].id, true)
    MGArcade_Sprite_SetScale(lid, gSP[iSprite].id, 1, 1)
    if lType == 3 then
        MGArcade_Sprite_SetScaleSpeed(lid, gSP[iSprite].id, -scaleSpeedVal, -scaleSpeedVal)
    else
        MGArcade_Sprite_SetScaleSpeed(lid, gSP[iSprite].id, 0, 0)
    end
end

local canMove = false
local stickX, stickY, sposx, sposy

function C_LayerUpdate(dt, lid)
    local L2_2 = false
    if gbShowingInfo then
        return
    end
    stickX = -GetStickValue(16, 0)
    stickY = -GetStickValue(17, 0)
    if IsButtonPressed(0, 0) then
        stickX = -1
    end
    if IsButtonPressed(1, 0) then
        stickX = 1
    end
    if IsButtonPressed(2, 0) then
        stickY = -1
    end
    if IsButtonPressed(3, 0) then
        stickY = 1
    end
    local stick2Y = GetStickValue(19, 0)
    canMove = false
    sposx, sposy = MGArcade_Sprite_GetPos(lid, gPlayerShip)
    svelx, svely = MGArcade_Sprite_GetVel(lid, gPlayerShip)
    if GetTimer() - gEnemySumoTime > gEnemyRateTime then
        F_AnimateEnemySumos(lid)
        gEnemySumoTime = GetTimer()
    end
    if gPlayerAllowMove then
        if stickX < -0.3 then
            if gFacing ~= "L" then
                MGArcade_Sprite_SetTexture(lid, gPlayerShip, sSumoL)
                gSumoTimer = GetTimer()
                gSumoFirst = true
                gFacing = "L"
            else
                MainSumoAnim(lid, gPlayerShip, sSumoL2, sSumoL)
                L2_2 = true
            end
            if sposx <= -gMainLayerW + gPlayerSize + 5 then
                svelx = 0
            else
                svelx = stickX * gSpeed
            end
        elseif 0.3 < stickX then
            if gFacing ~= "R" then
                MGArcade_Sprite_SetTexture(lid, gPlayerShip, sSumoR)
                gSumoTimer = GetTimer()
                gSumoFirst = true
                gFacing = "R"
            else
                MainSumoAnim(lid, gPlayerShip, sSumoR2, sSumoR)
                L2_2 = true
            end
            if sposx >= gMainLayerW - gPlayerSize - 5 then
                svelx = 0
            else
                svelx = stickX * gSpeed
            end
        else
            svelx = 0
        end
        if stickY < -0.3 then
            if gFacing ~= "B" and -0.3 <= stickX and stickX <= 0.3 then
                MGArcade_Sprite_SetTexture(lid, gPlayerShip, sSumoB)
                gSumoTimer = GetTimer()
                gSumoFirst = true
                gFacing = "B"
            elseif L2_2 == false then
                MainSumoAnim(lid, gPlayerShip, sSumoB2, sSumoB)
            end
            if sposy <= -gMainLayerH + gPlayerSize + 5 then
                svely = 0
            else
                svely = stickY * gSpeed
            end
        elseif 0.3 < stickY then
            if gFacing ~= "F" and -0.3 <= stickX and stickX <= 0.3 then
                MGArcade_Sprite_SetTexture(lid, gPlayerShip, sSumoF)
                gSumoTimer = GetTimer()
                gSumoFirst = true
                gFacing = "F"
            elseif L2_2 == false then
                MainSumoAnim(lid, gPlayerShip, sSumoF2, sSumoF)
            end
            if sposy >= gMainLayerH - gPlayerSize - 5 then
                svely = 0
            else
                svely = stickY * gSpeed
            end
        else
            svely = 0
        end
        if not gPlayerEnd then
            MGArcade_Sprite_SetVel(lid, gPlayerShip, svelx, svely)
        else
            MGArcade_Sprite_SetVel(lid, gPlayerShip, 0, 0)
        end
    else
        if GetTimer() - gPlayerBumped > 1000 then
            MGArcade_Sprite_SetVel(lid, gPlayerShip, 0, 0)
            MGArcade_Sprite_SetAcc(lid, gPlayerShip, 0, 0)
            gPlayerAllowMove = true
            gEnemySumoWhoHit = -1
        end
        if sposx <= -gMainLayerW + gPlayerSize + 5 then
        end
    end
    if gPlayerDied and GetTimer() - gDeathTime > gTotalDeathTime then
        gPlayerDied = false
        F_PlayerResetToCentre(lid)
    end
    if gCurrentAngel then
        for i, angel in gAngels do
            if angel.id and angel.alpha then
                angel.alpha = angel.alpha - 3
                --print("NEW ALPHA IS:", angel.alpha)
                if 0 >= angel.alpha then
                    angel.alpha = 0
                end
                if GetTimer() - angel.timer > 100 then
                    if angel.texture == sSumoAngel then
                        MGArcade_Sprite_SetTexture(lid, gAngels[gAngelsCreated].id, sSumoAngel2)
                        angel.texture = sSumoAngel2
                    else
                        MGArcade_Sprite_SetTexture(lid, gAngels[gAngelsCreated].id, sSumoAngel)
                        angel.texture = sSumoAngel
                    end
                    angel.timer = GetTimer()
                end
                MGArcade_Sprite_SetCol(lid, angel.id, 255, 255, 255, angel.alpha)
                if 0 >= angel.alpha then
                    angel.alpha = false
                end
            end
        end
    end
    if gInvulnerable then
        if GetTimer() - gInvulnerableTime > gTotalInvulnerableTime then
            gInvulnerable = false
            MGArcade_Sprite_SetVisible(lid, gPlayerShip, true)
        elseif not gBlinkColor then
            if GetTimer() - gBlinkTime > 50 then
                gBlinkColor = not gBlinkColor
                MGArcade_Sprite_SetVisible(lid, gPlayerShip, gBlinkColor)
                gBlinkTime = GetTimer()
            end
        elseif GetTimer() - gBlinkTime > 300 then
            gBlinkColor = not gBlinkColor
            MGArcade_Sprite_SetVisible(lid, gPlayerShip, gBlinkColor)
            gBlinkTime = GetTimer()
        end
    end
    if (sposx < -gMainLayerW or sposx > gMainLayerW or sposy < -gMainLayerH or sposy > gMainLayerH) and sposx1 ~= removeX and sposy1 ~= removeY then
        F_PlayerResetToCentre(lid)
    end
    if GetTimer() - gLastSpawn > gSpawnTime then
        F_CreateTarget(lid)
        F_CreateEnemySumo(lid)
        gLastSpawn = GetTimer()
    end
end

function C_PlayerUpdate(dt, lid, sid)
end

local sposx1, sposy1

function C_SpriteUpdate(dt, lid, sid)
    sposx1, sposy1 = MGArcade_Sprite_GetPos(lid, sid)
    if (sposx1 < -gMainLayerW or sposx1 > gMainLayerW or sposy1 < -gMainLayerH or sposy1 > gMainLayerH) and sposx1 ~= removeX and sposy1 ~= removeY then
        F_RemoveSprite(lid, sid)
    end
    texture = MGArcade_Sprite_GetTexture(lid, sid)
    if texture == sBlowFish then
        scalex, scaley = MGArcade_Sprite_GetScale(lid, sid)
        speedx = MGArcade_Sprite_GetScaleSpeed(lid, sid)
        MGArcade_Sprite_SetCollSize(lid, sid, scalex, scaley)
        if speedx < 0 and scalex <= 0.8 then
            MGArcade_Sprite_SetScaleSpeed(lid, sid, scaleSpeedVal, scaleSpeedVal)
        elseif speedx > 0 and scalex >= 1 then
            MGArcade_Sprite_SetScaleSpeed(lid, sid, -scaleSpeedVal, -scaleSpeedVal)
        end
    end
end

function C_SpriteColl(lid, sid, clid, csid)
    MGArcade_Sprite_SetPos(lid, sid, math.random(-160, 160), math.random(-120, 120))
    MGArcade_Sprite_SetVel(lid, sid, math.random(-30, 30), math.random(-30, 30))
    MGArcade_Sprite_SetPos(clid, csid, math.random(-160, 160), math.random(-120, 120))
    MGArcade_Sprite_SetVel(clid, csid, math.random(-30, 30), math.random(-30, 30))
end

function MainSumoAnim(lid, sid, sprite1, sprite2)
    if GetTimer() - gSumoTimer > gAnimationRateTime then
        gSumoTimer = GetTimer()
        if gSumoFirst then
            MGArcade_Sprite_SetTexture(lid, sid, sprite1)
        else
            MGArcade_Sprite_SetTexture(lid, sid, sprite2)
        end
        gSumoFirst = not gSumoFirst
    end
end

function F_PrepareTextures()
    sDojo = MGArcade_GetTextureID("Dojo_bg")
    sApple = MGArcade_GetTextureID("Apple", "Apple_x")
    sAppleR = MGArcade_GetTextureID("Apple_rotten", "Apple_rotten_x")
    sRice = MGArcade_GetTextureID("Rice_fresh", "Rice_fresh_x")
    sRiceR = MGArcade_GetTextureID("Rice_rotten", "Rice_rotten_x")
    sFish = MGArcade_GetTextureID("Fish_fresh", "Fish_fresh_x")
    sFishR = MGArcade_GetTextureID("Fish_rotten", "Fish_rotten_x")
    sSumoF = MGArcade_GetTextureID("SumoFront", "SumoFront_x")
    sSumoB = MGArcade_GetTextureID("SumoBack", "SumoBack_x")
    sSumoL = MGArcade_GetTextureID("SumoLeft", "SumoLeft_x")
    sSumoR = MGArcade_GetTextureID("SumoRight", "SumoRight_x")
    sSumoF2 = MGArcade_GetTextureID("SumoFront2", "SumoFront2_x")
    sSumoB2 = MGArcade_GetTextureID("SumoBack2", "SumoBack2_x")
    sSumoL2 = MGArcade_GetTextureID("SumoLeft2", "SumoLeft2_x")
    sSumoR2 = MGArcade_GetTextureID("SumoRight2", "SumoRight2_x")
    sESumoR = MGArcade_GetTextureID("EnemyRight", "EnemyRight_x")
    sESumoL = MGArcade_GetTextureID("EnemyLeft", "EnemyLeft_x")
    sESumoF = MGArcade_GetTextureID("EnemyFront", "EnemyFront_x")
    sESumoB = MGArcade_GetTextureID("EnemyBack", "EnemyBack_x")
    sESumoR2 = MGArcade_GetTextureID("EnemyRight2", "EnemyRight2_x")
    sESumoL2 = MGArcade_GetTextureID("EnemyLeft2", "EnemyLeft2_x")
    sESumoF2 = MGArcade_GetTextureID("EnemyFront2", "EnemyFront2_x")
    sESumoB2 = MGArcade_GetTextureID("EnemyBack2", "EnemyBack2_x")
    sSumoAngel = MGArcade_GetTextureID("Sumo_angel", "Sumo_angel_x")
    sSumoAngel2 = MGArcade_GetTextureID("Sumo_angel2", "Sumo_angel2_x")
    sStars = MGArcade_GetTextureID("Stars", "Stars_x")
    sStars2 = MGArcade_GetTextureID("Stars2", "Stars2_x")
    sStars3 = MGArcade_GetTextureID("Stars3", "Stars3_x")
    sStink = MGArcade_GetTextureID("Stink", "Stink_x")
    sBlowFish = MGArcade_GetTextureID("Blowfish", "Blowfish_x")
    sGameOver = MGArcade_GetTextureID("GameOver", "GameOver_x")
end

function C_UpdateAngel(dt, lid, sid)
end

function F_TutorialScreen(lid)
    gbShowingInfo = true
    local yLoc = -200
    local foodXLoc = -224
    local textXLoc = -48
    local textYLoc = -208
    local textSize = 0.9
    if GetLanguage() == 7 then
        textSize = 0.6
    end
    local tCol = {
        255,
        255,
        255,
        255
    }
    gTutSprite00 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite00, 495, 400)
    MGArcade_Sprite_SetCol(lid, gTutSprite00, 0, 0, 0, 128)
    MGArcade_Sprite_SetPos(lid, gTutSprite00, 0, -16)
    MGArcade_Sprite_SetVisible(lid, gTutSprite00, true)
    gTutText01 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gTutText01, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gTutText01, foodXLoc, yLoc)
    MGArcade_Sprite_SetSize(lid, gTutText01, 0.1, 0.1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(lid, gTutText01, textSize, textSize)
    else
        MGArcade_Sprite_SetScale(lid, gTutText01, 1.1, 1.1)
    end
    MGArcade_Sprite_SetCollSize(lid, gTutText01, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gTutText01, true)
    MGArcade_Sprite_SetFont(lid, gTutText01, 1)
    MGArcade_Sprite_SetText(lid, gTutText01, "ARCADE_SUMO_I01")
    gTutText02 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gTutText02, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gTutText02, textXLoc, textYLoc + 96)
    MGArcade_Sprite_SetSize(lid, gTutText02, 0.1, 0.1)
    MGArcade_Sprite_SetScale(lid, gTutText02, textSize, textSize)
    MGArcade_Sprite_SetCollSize(lid, gTutText02, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gTutText02, true)
    MGArcade_Sprite_SetFont(lid, gTutText02, 1)
    MGArcade_Sprite_SetText(lid, gTutText02, "ARCADE_SUMO_I02")
    gTutText03 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gTutText03, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gTutText03, textXLoc, textYLoc + 150)
    MGArcade_Sprite_SetSize(lid, gTutText03, 0.1, 0.1)
    MGArcade_Sprite_SetScale(lid, gTutText03, textSize, textSize)
    MGArcade_Sprite_SetCollSize(lid, gTutText03, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gTutText03, true)
    MGArcade_Sprite_SetFont(lid, gTutText03, 1)
    MGArcade_Sprite_SetText(lid, gTutText03, "ARCADE_SUMO_I03")
    gTutText04 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gTutText04, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gTutText04, textXLoc, textYLoc + 214)
    MGArcade_Sprite_SetSize(lid, gTutText04, 0.1, 0.1)
    MGArcade_Sprite_SetScale(lid, gTutText04, textSize, textSize)
    MGArcade_Sprite_SetCollSize(lid, gTutText04, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gTutText04, true)
    MGArcade_Sprite_SetFont(lid, gTutText04, 1)
    MGArcade_Sprite_SetText(lid, gTutText04, "ARCADE_SUMO_I04")
    gTutText05 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gTutText05, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gTutText05, textXLoc, textYLoc + 278)
    MGArcade_Sprite_SetSize(lid, gTutText05, 0.1, 0.1)
    MGArcade_Sprite_SetScale(lid, gTutText05, textSize, textSize)
    MGArcade_Sprite_SetCollSize(lid, gTutText05, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gTutText05, true)
    MGArcade_Sprite_SetFont(lid, gTutText05, 1)
    MGArcade_Sprite_SetText(lid, gTutText05, "ARCADE_SUMO_I05")
    gTutSprite02 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite02, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite02, sApple)
    MGArcade_Sprite_SetPos(lid, gTutSprite02, foodXLoc, yLoc + 96)
    MGArcade_Sprite_SetVisible(lid, gTutSprite02, true)
    gTutSprite03 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite03, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite03, sFish)
    MGArcade_Sprite_SetPos(lid, gTutSprite03, foodXLoc + 64, yLoc + 96)
    MGArcade_Sprite_SetVisible(lid, gTutSprite03, true)
    gTutSprite04 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite04, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite04, sRice)
    MGArcade_Sprite_SetPos(lid, gTutSprite04, foodXLoc + 128, yLoc + 96)
    MGArcade_Sprite_SetVisible(lid, gTutSprite04, true)
    gTutSprite05 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite05, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite05, sAppleR)
    MGArcade_Sprite_SetPos(lid, gTutSprite05, foodXLoc, yLoc + 150)
    MGArcade_Sprite_SetVisible(lid, gTutSprite05, true)
    gTutSprite06 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite06, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite06, sFishR)
    MGArcade_Sprite_SetPos(lid, gTutSprite06, foodXLoc + 64, yLoc + 150)
    MGArcade_Sprite_SetVisible(lid, gTutSprite06, true)
    gTutSprite07 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite07, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite07, sRiceR)
    MGArcade_Sprite_SetPos(lid, gTutSprite07, foodXLoc + 128, yLoc + 150)
    MGArcade_Sprite_SetVisible(lid, gTutSprite07, true)
    gTutSprite01 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite01, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite01, sESumoF)
    MGArcade_Sprite_SetPos(lid, gTutSprite01, foodXLoc + 128, yLoc + 278)
    MGArcade_Sprite_SetVisible(lid, gTutSprite01, true)
    gTutSprite08 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetSize(lid, gTutSprite08, 32, 32)
    MGArcade_Sprite_SetTexture(lid, gTutSprite08, sBlowFish)
    MGArcade_Sprite_SetPos(lid, gTutSprite08, foodXLoc + 128, yLoc + 214)
    MGArcade_Sprite_SetVisible(lid, gTutSprite08, true)
    gStartText1 = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gStartText1, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gStartText1, -100, yLoc + 330)
    MGArcade_Sprite_SetSize(lid, gStartText1, 1, 1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(lid, gStartText1, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(lid, gStartText1, 1.4, 1.4)
    end
    MGArcade_Sprite_SetCollSize(lid, gStartText1, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gStartText1, true)
    MGArcade_Sprite_SetFont(lid, gStartText1, 1)
    MGArcade_Sprite_SetText(lid, gStartText1, "ARCADE_BTNSTRT")
    gExitText = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gExitText, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(lid, gExitText, -100, yLoc + 355)
    MGArcade_Sprite_SetSize(lid, gExitText, 1, 1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(lid, gExitText, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(lid, gExitText, 1.4, 1.4)
    end
    MGArcade_Sprite_SetCollSize(lid, gExitText, 0, 0)
    MGArcade_Sprite_SetVisible(lid, gExitText, true)
    MGArcade_Sprite_SetFont(lid, gExitText, 1)
    MGArcade_Sprite_SetText(lid, gExitText, "ARCADE_BTNEXIT")
    while not IsButtonBeingPressed(7, 0) and MinigameIsActive() do
        Wait(0)
    end
    SoundStopStream()
    if MinigameIsActive() then
        SoundPlay2D("Gong")
        Wait(1000)
        SoundPlayStream("Arc_SUMO_Game01.rsm", 1, 0, 1.5)
    end
    MGArcade_Sprite_SetVisible(lid, gTutText01, false)
    MGArcade_Sprite_SetVisible(lid, gTutText02, false)
    MGArcade_Sprite_SetVisible(lid, gTutText03, false)
    MGArcade_Sprite_SetVisible(lid, gTutText04, false)
    MGArcade_Sprite_SetVisible(lid, gTutText05, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite00, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite01, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite02, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite03, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite04, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite05, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite06, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite07, false)
    MGArcade_Sprite_SetVisible(lid, gTutSprite08, false)
    MGArcade_Sprite_SetVisible(lid, gStartText1, false)
    MGArcade_Sprite_SetVisible(lid, gExitText, false)
    gbShowingInfo = false
end

function F_HighScoreScreen(lid)
    local hsY = -100
    tblHS = {
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(gHighScoreConst, 0),
            y = hsY + 20,
            flash = false,
            text = "ARCADE_SSCORE"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(gHighScoreConst, 1),
            y = hsY + 40,
            flash = false,
            text = "ARCADE_SSCORE"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(gHighScoreConst, 2),
            y = hsY + 60,
            flash = false,
            text = "ARCADE_SSCORE"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(gHighScoreConst, 3),
            y = hsY + 80,
            flash = false,
            text = "ARCADE_SSCORE"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(gHighScoreConst, 4),
            y = hsY + 100,
            flash = false,
            text = "ARCADE_SSCORE"
        }
    }
    local scR, scG, scB = 255, 255, 255
    shared.layer = lid
    gHighScoreBKG = MGArcade_Layer_AddSprite(lid)
    shared.gHighScoreBKG = gHighScoreBKG
    MGArcade_Sprite_SetSize(lid, gHighScoreBKG, 256, 220)
    MGArcade_Sprite_SetCol(lid, gHighScoreBKG, 0, 0, 0, 128)
    MGArcade_Sprite_SetPos(lid, gHighScoreBKG, 0, -30)
    MGArcade_Sprite_SetVisible(lid, gHighScoreBKG, true)
    gHighScoreText = MGArcade_Layer_AddSprite(lid)
    MGArcade_Sprite_SetCol(lid, gHighScoreText, scR, scG, scB, 255)
    MGArcade_Sprite_SetPos(lid, gHighScoreText, -72, -130)
    MGArcade_Sprite_SetSize(lid, gHighScoreText, 1, 1)
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(lid, gHighScoreText, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(lid, gHighScoreText, 1.4, 1.4)
    end
    MGArcade_Sprite_SetVisible(lid, gHighScoreText, true)
    MGArcade_Sprite_SetFont(lid, gHighScoreText, 1)
    MGArcade_Sprite_SetText(lid, gHighScoreText, "ARCADE_HIGHSCORE")
    local flashscore = 0
    flashscore = 1 + MinigameSetHighScoreFromID(gHighScoreConst, gScore, "ARCADE_JIM")
    if flashscore == 1 then
        if shared.NerdVendettaRunning then
            --print("SOUND SPEECH PLAYING AT END")
            SoundPlayScriptedSpeechEvent(gFatty, "CONGRATULATIONS", 0, "jumbo", true)
            gHighScoreAchieved = true
        end
    elseif shared.NerdVendettaRunning then
        --print("SOUND SPEECH PLAYING AT END")
        SoundPlayScriptedSpeechEvent(gFatty, "DISGUST", 0, "jumbo", true)
    end
    for i, score in tblHS do
        score.id = MGArcade_Layer_AddSprite(lid)
        MGArcade_Sprite_SetCol(lid, score.id, scR, scG, scB, 255)
        MGArcade_Sprite_SetPos(lid, score.id, -100, score.y)
        MGArcade_Sprite_SetSize(lid, score.id, 1, 1)
        if GetLanguage() == 7 then
            MGArcade_Sprite_SetScale(lid, score.id, 0.8, 0.8)
        else
            MGArcade_Sprite_SetScale(lid, score.id, 1.4, 1.4)
        end
        MGArcade_Sprite_SetVisible(lid, score.id, true)
        MGArcade_Sprite_SetFont(lid, score.id, 1)
        MGArcade_Sprite_SetTextToScoreName(lid, score.id, gHighScoreConst, i - 1)
    end
    for i, score in tblHS do
        score.id2 = MGArcade_Layer_AddSprite(lid)
        MGArcade_Sprite_SetCol(lid, score.id2, scR, scG, scB, 255)
        MGArcade_Sprite_SetPos(lid, score.id2, -15, score.y)
        MGArcade_Sprite_SetSize(lid, score.id2, 1, 1)
        if GetLanguage() == 7 then
            MGArcade_Sprite_SetScale(lid, score.id2, 0.8, 0.8)
        else
            MGArcade_Sprite_SetScale(lid, score.id2, 1.4, 1.4)
        end
        MGArcade_Sprite_SetVisible(lid, score.id2, true)
        MGArcade_Sprite_SetFont(lid, score.id2, 1)
        MGArcade_Sprite_SetText(lid, score.id2, score.text)
        local ScoreParam = MGArcade_Sprite_AddTextParam(lid, score.id2, 0)
        MGArcade_Sprite_SetTextParam(lid, score.id2, ScoreParam, MinigameGetHighScore(gHighScoreConst, i - 1))
    end
    --print("INIT HIGHSCORE 3")
    local flashTime = GetTimer() + 100
    local bOn = false
    local xPress = true
    local gWait = true
    local gWaitingTimer = GetTimer()
    while gWait do
        if 0 < flashscore and flashTime <= GetTimer() then
            if bOn then
                MGArcade_Sprite_SetVisible(lid, tblHS[flashscore].id, true)
                bOn = false
            elseif not bOn then
                MGArcade_Sprite_SetVisible(lid, tblHS[flashscore].id, false)
                bOn = true
            end
            flashTime = GetTimer() + 100
        end
        if GetTimer() - gWaitingTimer > 80000 then
            gWait = false
        end
        if IsButtonBeingPressed(7, 0) or not MinigameIsActive() then
            gWait = false
        end
        Wait(0)
    end
    --print("INIT HIGHSCORE 4")
end
