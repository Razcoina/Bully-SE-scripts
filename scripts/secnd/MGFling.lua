--[[ Changes to this file:
    * Modified function MissionSetup, may require testing
    * Modified function F_LoadingScreen, may require testing
    * Modified function F_InitGame, may require testing
    * Modified function F_HighScoreScreen, may require testing
    * Modified function F_InstructScreen, may require testing
]]

local playerWins = false
local bInstPhase = false
local gHUD = 0
local gLayer = 0
local gBananaLayer = 0
local gGround = 0
local gClouds = 0
local gMonkey = 0
local gLives = 3
local gSpider = 0
local gBanana = 0
local gPoo = 0
local gLife = 0
local gAmmo = 0
local tblBananas = {}
local tblSpiders = {}
local tblPoo = {}
local tblLives = {}
local tblAmmo = {}
local bPressX = false
local bPressR1 = false
local bLifeChange = false
local bThrow = false
local bSetRegen = false
local bNotChattering = false
local bPressTriangle = false
local bEndTheGame = false
local lives = 3
local bDead = false
local bInvulnerabl = false
local spiderVel = 35
local spiderAcc = 10.5
local spiderWalkAcc = 0
local gSpiderWalkTime = 3500
local spawntime = 0
local lasttime = 0
local gMonkeySprite0 = 0
local gMonkeySprite1 = 0
local allAmmo = 10
local regenTime = 0
local BANANA_PARKED = 0
local BANANA_SPAWN = 1
local BANANA_FALLING = 2
local BANANA_GROUND = 3
local BANANA_LEFT = 4
local BANANA_RIGHT = 5
local SPIDER_PARKED = 0
local SPIDER_FALLING = 1
local SPIDER_GROUND = 2
local SPIDER_LEFT = 4
local SPIDER_RIGHT = 5
local Stage = 0
local POO_PARKED = 0
local POO_THROWN = 1
local LIFE_PARKED = 0
local LIFE_TAKEN = 1
local AMMO_PARKED = 0
local AMMO_SPENT = 1
local bPressCross = false
local bPressRight = false
local bPressLeft = false
local bGameOver = false
local bGameOn = false
local gSpiderSprite0 = 0
local gSpiderSprite1 = 0
local bSpiderWalking = false
local bSpiderWalkLoop = false
local monkeyFlipTime = 0
local spiderFlipTime = 0
local gScore = 0
local gScoreText = 0
local gScoreParam = 0
local gameOverTimeOut = 0
local blink = false
local InvulnerablTime = GetTimer() + 9999999

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
    MGArcade_LoadTextures("MG_Fling")                             -- Added this
    sSideBarLeft = MGArcade_GetTextureID("Monkey_SideScreen_left") -- Added this
    sSideBarRight = MGArcade_GetTextureID("Monkey_SideScreen_right") -- Added this
    --[[
    MGArcade_InitScreen(0, 0, 0)
    ]] -- Changed to:
    MGArcade_InitScreen(0, 0, 0, sSideBarLeft, sSideBarRight)
end

function MissionCleanup()
    SoundStopStream()
    SoundRestartAmbiences()
    PlayerSetInvulnerable(false)
    MinigameDestroy()
    SoundEnableInteractiveMusic(true)
    SoundRestartAmbiences()
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
    SoundPlayStream("Arc_MonkeyFlingMenu01.rsm", 1, 0, 0)
    F_InitGame()
    if MinigameIsActive() then
        monkeyFlipTime = GetTimer() + 250
        spiderFlipTime = GetTimer() + 250
        difficultyTime = GetTimer()
        Wait(250)
        bInstPhase = true
    end
    while MinigameIsActive() do
        if bInstPhase then
            F_InstructScreen()
            bInstPhase = false
        end
        if not bGameOver and MinigameIsActive() then
            F_Difficulty()
            F_UpdateSpiders()
            F_UpdateBananas()
            F_PooGenerator()
            if bInvulnerabl then
                --print("=== turning off invulnerable ====")
                bInvulnerabl = false
                MGArcade_Sprite_SetCollSize(gLayer, gMonkey, 64, 64)
            end
            if bLifeChange and not bGameOver then
                if not bNotChattering and not bGameOver then
                    SoundLoopPlay2D("MonkeyTalkLoop", false)
                    bNotChattering = true
                end
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
                    bInvulnerabl = true
                    --print("==== Invulnerable ===")
                    bDead = true
                    MGArcade_Sprite_SetTexture(gLayer, gMonkey, gMonkeyDead)
                    MGArcade_Sprite_SetAcc(gLayer, gMonkey, 0, 0)
                    MGArcade_Sprite_SetVel(gLayer, gMonkey, 0, 0)
                    local bContinue = false
                    local deadTime = GetTimer() + 2000
                    while not bContinue do
                        local x, y = MGArcade_Sprite_GetPos(gLayer, gMonkey)
                        if deadTime <= GetTimer() then
                            bContinue = true
                        end
                        F_Difficulty()
                        F_UpdateSpiders()
                        F_UpdateBananas()
                        F_PooGenerator()
                        Wait(0)
                    end
                    MGArcade_Sprite_SetAcc(gLayer, gMonkey, 0, 0)
                    MGArcade_Sprite_SetVel(gLayer, gMonkey, 0, 0)
                    MGArcade_Sprite_SetTexture(gLayer, gMonkey, gMonkeyCurrentFrame)
                    blink = true
                    bDead = false
                    MGArcade_Sprite_SetCollSize(gLayer, gMonkey, 64, 64)
                    InvulnerablTime = GetTimer() + 4000
                    --print("==== Set Invuln time=====", InvulnerablTime)
                    while blink do
                        for i = 1, 10 do
                            if i == 1 or i == 3 or i == 5 or i == 7 or i == 9 then
                                MGArcade_Sprite_SetVisible(gLayer, gMonkey, true)
                                Wait(250)
                            else
                                MGArcade_Sprite_SetVisible(gLayer, gMonkey, false)
                                Wait(250)
                            end
                            F_Difficulty()
                            F_UpdateSpiders()
                            F_UpdateBananas()
                            F_PooGenerator()
                        end
                        blink = false
                        Wait(0)
                    end
                    bInvulnerabl = false
                    --print("==== Not Invulnerable ===")
                    MGArcade_Sprite_SetVisible(gLayer, gMonkey, true)
                    MGArcade_Sprite_SetCollSize(gLayer, gMonkey, 64, 64)
                elseif lives == 0 and not bGameOver then
                    --print("==== Dead and Dead ====")
                    bDead = true
                    MGArcade_Sprite_SetTexture(gLayer, gMonkey, gMonkeyDead)
                    MGArcade_Sprite_SetAcc(gLayer, gMonkey, 0, 0)
                    MGArcade_Sprite_SetVel(gLayer, gMonkey, 0, 0)
                    MGArcade_Sprite_SetCollSize(gLayer, gMonkey, 0, 0)
                    bGameOver = true
                    F_GameOverScreen()
                    gameOverTimeOut = GetTimer() + 5000
                end
                bLifeChange = false
            end
        elseif bGameOver then
            if not (not IsButtonBeingPressed(7, 0) or bPressCross) or GetTimer() <= gameOverTimeOut then
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
    if MinigameIsSuccess() then
        Wait(1000)
        playerWins = true
    end
    if playerWins then
        TextPrintString("You win!", 1)
    else
        TextPrintString("GAME OVER.", 1)
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

function F_Difficulty()
    if Stage == 0 and difficultyTime + 60000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        Stage = 1
    elseif Stage == 1 and difficultyTime + 120000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        spiderWalkAcc = spiderWalkAcc + 1
        Stage = 2
    elseif Stage == 2 and difficultyTime + 180000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        spiderWalkAcc = spiderWalkAcc + 1
        Stage = 3
    elseif Stage == 3 and difficultyTime + 240000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        spiderWalkAcc = spiderWalkAcc + 1
        Stage = 4
    elseif Stage == 4 and difficultyTime + 300000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        spiderWalkAcc = spiderWalkAcc + 1
        Stage = 5
    elseif Stage == 5 and difficultyTime + 360000 <= GetTimer() then
        spiderVel = spiderVel * 1.25
        spiderAcc = spiderAcc * 1.05
        spiderWalkAcc = spiderWalkAcc + 1
        Stage = 6
    end
end

function F_LoadingScreen() -- ! Modfied
    local loadingScreen = MGArcade_GetTextureID("Monkey_StartScreen")
    gStartScreen = MGArcade_CreateLayer(512, 400, 300, C_LayerUpdate)
    MGArcade_Layer_SetPos(gStartScreen, 0, 0)
    MGArcade_Layer_SetCol(gStartScreen, 255, 255, 255, 255)
    MGArcade_Layer_SetScale(gStartScreen, 1, 1)
    gLoadScreen = MGArcade_Layer_AddSprite(gStartScreen)
    MGArcade_Sprite_SetCol(gStartScreen, gLoadScreen, 255, 255, 255, 255)
    MGArcade_Sprite_SetPos(gStartScreen, gLoadScreen, 0, 0)
    MGArcade_Sprite_SetSize(gStartScreen, gLoadScreen, 512, 400)
    MGArcade_Sprite_SetTexture(gStartScreen, gLoadScreen, loadingScreen)
    MGArcade_Sprite_SetVisible(gStartScreen, gLoadScreen, true)
    gStartText = MGArcade_Layer_AddSprite(gStartScreen)
    MGArcade_Sprite_SetCol(gStartScreen, gStartText, 50, 50, 50, 255)
    MGArcade_Sprite_SetPos(gStartScreen, gStartText, -80, 100)
    MGArcade_Sprite_SetSize(gStartScreen, gStartText, 1, 1)
    --[[
    MGArcade_Sprite_SetScale(gStartScreen, gStartText, 1, 1)
    ]] -- Changed to:
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(gStartScreen, gStartText, 0.8, 0.8)
    else
        MGArcade_Sprite_SetScale(gStartScreen, gStartText, 1, 1)
    end
    MGArcade_Sprite_SetCollSize(gStartScreen, gStartText, 0, 0)
    MGArcade_Sprite_SetVisible(gStartScreen, gStartText, true)
    MGArcade_Sprite_SetFont(gStartScreen, gStartText, 1)
    MGArcade_Sprite_SetText(gStartScreen, gStartText, "ARCADE_BTNSTRT")
    gExitText = MGArcade_Layer_AddSprite(gStartScreen)
    MGArcade_Sprite_SetCol(gStartScreen, gExitText, 50, 50, 50, 255)
    --[[
    MGArcade_Sprite_SetPos(gStartScreen, gExitText, -80, 120)
    ]] -- Changed to:
    MGArcade_Sprite_SetPos(gStartScreen, gExitText, -80, 125)
    MGArcade_Sprite_SetSize(gStartScreen, gExitText, 1, 1)
    --[[
    MGArcade_Sprite_SetScale(gStartScreen, gExitText, 1, 1)
    ]] -- Changed to:
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(gStartScreen, gExitText, 0.8, 0.8)
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

function F_InitGame() -- ! Modified
    --[[
    MGArcade_LoadTextures("MG_Fling")
    ]]                                                               -- Removed this
    sSideBarLeft = MGArcade_GetTextureID("Monkey_SideScreen_left") -- Added this
    sSideBarRight = MGArcade_GetTextureID("Monkey_SideScreen_right") -- Added this
    MGArcade_InitScreen(0, 0, 0, sSideBarLeft, sSideBarRight)     -- Added this
    F_LoadingScreen()
    if not MinigameIsActive() then
        return
    end
    local tex_sprite0 = MGArcade_GetTextureID("Sunset")
    gHUD = MGArcade_CreateLayer(512, 32, 48, C_LayerUpdate)
    --[[
    MGArcade_Layer_SetPos(gHUD, 0, -216)
    ]] -- Changed to:
    MGArcade_Layer_SetPos(gHUD, 0, -200)
    MGArcade_Layer_SetCol(gHUD, 204, 153, 0, 128)
    MGArcade_Layer_SetScale(gHUD, 1, 1)
    gScoreText = MGArcade_Layer_AddSprite(gHUD)
    MGArcade_Sprite_SetCol(gHUD, gScoreText, 200, 200, 200, 255)
    MGArcade_Sprite_SetPos(gHUD, gScoreText, 0, -12)
    MGArcade_Sprite_SetSize(gHUD, gScoreText, 0.1, 0.1)
    MGArcade_Sprite_SetScale(gHUD, gScoreText, 0.5, 0.5)
    MGArcade_Sprite_SetCollSize(gHUD, gScoreText, 0, 0)
    MGArcade_Sprite_SetVisible(gHUD, gScoreText, true)
    gScoreParam = MGArcade_Sprite_AddTextParam(gHUD, gScoreText, 0)
    MGArcade_Sprite_SetText(gHUD, gScoreText, "ARCADE_SCORE")
    gLayer = MGArcade_CreateLayer(512, 400, 100, C_LayerUpdate)
    --[[
    MGArcade_Layer_SetPos(gLayer, 0, 0)
    ]] -- Changed to:
    MGArcade_Layer_SetPos(gLayer, 0, 16)
    MGArcade_Layer_SetCol(gLayer, 0, 0, 0, 255)
    MGArcade_Layer_SetScale(gLayer, 1, 1)
    gJungle = MGArcade_Layer_AddSprite(gLayer)
    MGArcade_Sprite_SetCol(gLayer, gGround, 255, 255, 255, 255)
    MGArcade_Sprite_SetPos(gLayer, gJungle, 0, 0)
    MGArcade_Sprite_SetSize(gLayer, gJungle, 512, 400)
    MGArcade_Sprite_SetTexture(gLayer, gJungle, tex_sprite0)
    MGArcade_Sprite_SetVisible(gLayer, gJungle, true)
    gGround = MGArcade_Layer_AddSprite(gLayer, cbStaticObjects, C_StaticCol)
    MGArcade_Sprite_SetCol(gLayer, gGround, 10, 255, 10, 255)
    MGArcade_Sprite_SetPos(gLayer, gGround, 0, 200)
    MGArcade_Sprite_SetSize(gLayer, gGround, 512, 10)
    MGArcade_Sprite_SetVel(gLayer, gGround, 0, 0)
    MGArcade_Sprite_SetAcc(gLayer, gGround, 0, 0)
    MGArcade_Sprite_SetVisible(gLayer, gGround, false)
    gClouds = MGArcade_Layer_AddSprite(gLayer, cbStaticObjects, C_StaticCol)
    MGArcade_Sprite_SetCol(gLayer, gClouds, 238, 238, 238, 255)
    MGArcade_Sprite_SetPos(gLayer, gClouds, 0, -200)
    MGArcade_Sprite_SetSize(gLayer, gClouds, 512, 10)
    MGArcade_Sprite_SetVel(gLayer, gClouds, 0, 0)
    MGArcade_Sprite_SetAcc(gLayer, gClouds, 0, 0)
    MGArcade_Sprite_SetVisible(gLayer, gClouds, false)
    gMonkeySprite0 = MGArcade_GetTextureID("Monkey", "Monkey_x")
    gMonkeySprite1 = MGArcade_GetTextureID("MonkeyLeft", "MonkeyLeft_x")
    gMonkeyDead = MGArcade_GetTextureID("Monkey_dead", "Monkey_dead_x")
    gMonkeyCurrentFrame = gMonkeySprite0
    gMonkey = MGArcade_Layer_AddSprite(gLayer, cbMonkeyUpdate, C_MonkeyColl)
    MGArcade_Sprite_SetCol(gLayer, gMonkey, 255, 255, 255, 255)
    MGArcade_Sprite_SetPos(gLayer, gMonkey, 0, 164)
    MGArcade_Sprite_SetSize(gLayer, gMonkey, 64, 64)
    MGArcade_Sprite_SetVel(gLayer, gMonkey, 0, 0)
    MGArcade_Sprite_SetAcc(gLayer, gMonkey, 0, 0)
    MGArcade_Sprite_SetCollSize(gLayer, gMonkey, 64, 64)
    MGArcade_Sprite_SetTexture(gLayer, gMonkey, gMonkeyCurrentFrame)
    MGArcade_Sprite_SetVisible(gLayer, gMonkey, false)
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
    tblPoo = {
        {
            state = POO_PARKED,
            id = 0,
            x = -110,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = -90,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = -60,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = -30,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = -10,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 10,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 30,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 60,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 90,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 120,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 150,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 180,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 210,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 240,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 270,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 300,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 330,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 360,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 390,
            y = 300
        },
        {
            state = POO_PARKED,
            id = 0,
            x = 420,
            y = 300
        }
    }
    tblLives = {
        {
            state = LIFE_PARKED,
            id = 0,
            x = 240
        },
        {
            state = LIFE_PARKED,
            id = 0,
            x = 204
        },
        {
            state = LIFE_PARKED,
            id = 0,
            x = 168
        }
    }
    tblAmmo = {
        {
            state = AMMO_PARKED,
            id = 0,
            x = -242
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -218
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -194
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -170
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -146
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -122
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -98
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -74
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -50
        },
        {
            state = AMMO_PARKED,
            id = 0,
            x = -26
        }
    }
    F_MakeAmmo()
    F_MakeLives()
    F_MakePoo()
    F_MakeBananas()
    F_MakeSpider()
end

function F_UpdateSpiders()
end

function F_FlipSpiderAmin(spider)
    if spider.CurrentFrame == gSpiderSprite0 then
        spider.CurrentFrame = gSpiderSprite1
    else
        spider.CurrentFrame = gSpiderSprite0
    end
    spider.fliptime = GetTimer() + 250
end

function F_SpiderFindX()
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
        x = math.random(128, 240)
    elseif sect == 2 then
        x = math.random(0, 127)
    elseif sect == 3 then
        x = math.random(-240, 128)
    elseif sect == 4 then
        x = math.random(-127, 0)
    end
    return x
end

function F_UpdateBananas()
end

function cbAmmoUpdate(dt, lid, sid)
end

function cbLifeUpdate(dt, lid, sid)
end

function C_LayerUpdate(dt, layerID)
end

function C_StaticCol(lid, sid, clid, csid)
end

function C_SpiderColl(lid, sid, clid, csid)
    if csid == gMonkey and not bInvulnerabl then
        if sid == tblSpiders[1].id then
            spider = tblSpiders[1]
        elseif sid == tblSpiders[2].id then
            spider = tblSpiders[2]
        elseif sid == tblSpiders[3].id then
            spider = tblSpiders[3]
        elseif sid == tblSpiders[4].id then
            spider = tblSpiders[4]
        end
        if 0 <= gLives then
            --print("==== Monkey Still Has lives ====")
            bLifeChange = true
            gLives = gLives - 1
            sid = spider.id
            MGArcade_Sprite_SetVel(lid, sid, 0, 0)
            MGArcade_Sprite_SetPos(lid, sid, spider.x, spider.y)
            local rand = math.random(1, 4)
            if rand == 1 then
                spawntime = GetTimer() + 2000 + lasttime
                lasttime = 2000
            elseif rand == 2 then
                spawntime = GetTimer() + 2000 + lasttime
                lasttime = 2000
            elseif rand == 3 then
                spawntime = GetTimer() + 4000 + lasttime
                lasttime = 4000
            elseif rand == 4 then
                spawntime = GetTimer() + 5000 + lasttime
                lasttime = 5000
            end
            spider.time = spawntime
            spider.state = SPIDER_PARKED
            if not bGameOver then
                SoundPlay2D("SpiderBiteMonk")
            end
        elseif gLives < 0 then
            gLives = 0
            --print("==== Monkey Still Has no lives possibly ====")
        end
    else
        for i, poo in tblPoo do
            if csid == poo.id then
                for j, spider in tblSpiders do
                    if sid == spider.id then
                        F_ParkSpider(spider)
                        spider.state = SPIDER_PARKED
                        if not bGameOver then
                            gScore = gScore + 2
                            MGArcade_Sprite_SetTextParam(gHUD, gScoreText, gScoreParam, gScore)
                            if not bGameOver then
                                SoundPlay2D("SpiderGetsHit")
                            end
                        end
                        break
                    end
                end
                F_ParkPoo(csid)
                break
            end
        end
    end
end

function F_ParkSpider(spider)
    MGArcade_Sprite_SetVel(gLayer, spider.id, 0, 0)
    MGArcade_Sprite_SetAcc(gLayer, spider.id, 0, 0)
    MGArcade_Sprite_SetPos(gLayer, spider.id, spider.x, spider.y)
    MGArcade_Sprite_SetCol(gLayer, spider.id, 255, 255, 255, 255)
    local rand = math.random(1, 4)
    if rand == 1 then
        spawntime = GetTimer() + 2000 + lasttime
        lasttime = 2000
    elseif rand == 2 then
        spawntime = GetTimer() + 2000 + lasttime
        lasttime = 2000
    elseif rand == 3 then
        spawntime = GetTimer() + 4000 + lasttime
        lasttime = 4000
    elseif rand == 4 then
        spawntime = GetTimer() + 5000 + lasttime
        lasttime = 5000
    end
    spider.time = spawntime
end

function cbSpiderUpdate(dt, lid, sid)
    if bGameOn then
        if sid == tblSpiders[1].id then
            spider = tblSpiders[1]
        elseif sid == tblSpiders[2].id then
            spider = tblSpiders[2]
        elseif sid == tblSpiders[3].id then
            spider = tblSpiders[3]
        elseif sid == tblSpiders[4].id then
            spider = tblSpiders[4]
        end
        if spider.state == SPIDER_PARKED then
            if TimerPassed(spider.time) then
                local x = F_SpiderFindX()
                MGArcade_Sprite_SetCol(gLayer, spider.id, 255, 255, 255, 255)
                MGArcade_Sprite_SetPos(gLayer, spider.id, x, -185)
                MGArcade_Sprite_SetVel(gLayer, spider.id, 0, spiderVel)
                MGArcade_Sprite_SetAcc(gLayer, spider.id, 0, spiderAcc)
                MGArcade_Sprite_SetRot(gLayer, spider.id, 0)
                MGArcade_Sprite_SetCollSize(gLayer, spider.id, 32, 32)
                spider.state = SPIDER_FALLING
                spider.fliptime = GetTimer() + 250
                if not bGameOver then
                    SoundPlay2D("SpiderPopOff")
                end
            end
        elseif spider.state == SPIDER_FALLING then
            local x, y = MGArcade_Sprite_GetPos(gLayer, spider.id)
            if 180 <= y then
                MGArcade_Sprite_SetVel(gLayer, spider.id, 0, 0)
                MGArcade_Sprite_SetAcc(gLayer, spider.id, 0, 0)
                spider.state = SPIDER_GROUND
            end
        elseif spider.state == SPIDER_GROUND then
            spider.fliptime = GetTimer() + 250
            local px, py = MGArcade_Sprite_GetPos(gLayer, gMonkey)
            local sx, sy = MGArcade_Sprite_GetPos(gLayer, spider.id)
            if px > sx then
                MGArcade_Sprite_SetRot(gLayer, spider.id, -90)
                MGArcade_Sprite_SetVel(gLayer, spider.id, 50, 0)
                MGArcade_Sprite_SetAcc(gLayer, spider.id, spiderWalkAcc, 0)
                spider.state = SPIDER_RIGHT
            elseif px < sx then
                MGArcade_Sprite_SetRot(gLayer, spider.id, 90)
                MGArcade_Sprite_SetVel(gLayer, spider.id, -50, 0)
                MGArcade_Sprite_SetAcc(gLayer, spider.id, spiderWalkAcc, 0)
                spider.state = SPIDER_LEFT
            end
            spider.time = GetTimer() + gSpiderWalkTime
        elseif spider.state == SPIDER_RIGHT then
            local sx, sy = MGArcade_Sprite_GetPos(gLayer, spider.id)
            if TimerPassed(spider.fliptime) then
                F_FlipSpiderAmin(spider)
            end
            MGArcade_Sprite_SetTexture(gLayer, spider.id, spider.CurrentFrame)
            MGArcade_Sprite_SetCol(gLayer, spider.id, 255, 255, 255, spider.fadetime)
            spider.fadetime = spider.fadetime - 20
            if 240 <= sx then
                MGArcade_Sprite_SetRot(gLayer, spider.id, -90)
                MGArcade_Sprite_SetVel(gLayer, spider.id, 0, 0)
                MGArcade_Sprite_SetVel(gLayer, spider.id, 50, 0)
                spider.state = SPIDER_LEFT
            end
            if GetTimer() >= spider.time then
                F_ParkSpider(spider)
                spider.state = SPIDER_PARKED
            end
        elseif spider.state == SPIDER_LEFT then
            local sx, sy = MGArcade_Sprite_GetPos(gLayer, spider.id)
            if TimerPassed(spider.fliptime) then
                F_FlipSpiderAmin(spider)
            end
            MGArcade_Sprite_SetTexture(gLayer, spider.id, spider.CurrentFrame)
            MGArcade_Sprite_SetCol(gLayer, spider.id, 255, 255, 255, spider.fadetime)
            spider.fadetime = spider.fadetime - 20
            if sx <= -240 then
                MGArcade_Sprite_SetRot(gLayer, spider.id, 90)
                MGArcade_Sprite_SetVel(gLayer, spider.id, 0, 0)
                MGArcade_Sprite_SetVel(gLayer, spider.id, -50, 0)
                spider.state = SPIDER_RIGHT
            end
            if GetTimer() >= spider.time then
                F_ParkSpider(spider)
                spider.state = SPIDER_PARKED
            end
        end
    end
end

function C_BananaColl(lid, sid, clid, csid)
    if csid == gMonkey then
        for i, banana in tblBananas do
            if sid == banana.id and (banana.state == BANANA_FALLING or banana.state == BANANA_GROUND) then
                MGArcade_Sprite_SetPos(gLayer, sid, banana.x, banana.y)
                MGArcade_Sprite_SetVel(lid, sid, 0, 0)
                MGArcade_Sprite_SetAcc(lid, sid, 0, 0)
                banana.state = BANANA_SPAWN
                if banana.state == BANANA_FALLING then
                    if not bGameOver then
                        SoundPlay2D("MonkeyHit")
                    end
                    if not bGameOver then
                        gScore = gScore + 3
                        SoundPlay2D("MonkeyEat")
                    end
                elseif not bGameOver then
                    gScore = gScore + 3
                    SoundPlay2D("MonkeyEat")
                end
                MGArcade_Sprite_SetTextParam(gHUD, gScoreText, gScoreParam, gScore)
                for k = 1, 5 do
                    for j = 1, 10 do
                        if tblAmmo[j].state == AMMO_SPENT then
                            MGArcade_Sprite_SetVisible(gHUD, tblAmmo[j].id, true)
                            tblAmmo[j].state = AMMO_PARKED
                            break
                        end
                    end
                end
                break
            end
        end
    end
end

function cbBananaUpdate(dt, lid, sid)
    if lid == gLayer then
        for i, banana in tblBananas do
            if sid == banana.id and banana.state == BANANA_FALLING then
                local x, y = MGArcade_Sprite_GetPos(lid, sid)
                if 180 <= y then
                    MGArcade_Sprite_SetVel(lid, sid, 0, 0)
                    MGArcade_Sprite_SetAcc(lid, sid, 0, 0)
                    banana.state = BANANA_GROUND
                    break
                end
            end
        end
    end
end

function C_MonkeyColl(lid, sid, clid, csid)
end

local lastdt = 0

function cbMonkeyUpdate(dt, lid, sid)
    if not bGameOver and bGameOn and not bDead then
        local stickX
        stickX = -GetStickValue(16, 0)
        local px = MGArcade_Sprite_GetPos(gLayer, gMonkey)
        if IsButtonPressed(0, 0) and not bPressLeft then
            MGArcade_Sprite_SetVel(lid, sid, -140, 0)
            if bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", true)
                bNotChattering = false
            end
            bPressLeft = true
        end
        if not IsButtonPressed(0, 0) and bPressLeft then
            MGArcade_Sprite_SetVel(lid, sid, 0, 0)
            if not bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", false)
                bNotChattering = true
            end
            bPressLeft = false
        end
        if IsButtonPressed(1, 0) and not bPressRight then
            MGArcade_Sprite_SetVel(lid, sid, 140, 0)
            if bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", true)
                bNotChattering = false
            end
            bPressRight = true
        end
        if not IsButtonPressed(1, 0) and bPressRight then
            MGArcade_Sprite_SetVel(lid, sid, 0, 0)
            if not bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", false)
                bNotChattering = true
            end
            bPressRight = false
        end
        if 220 <= px or px <= -220 then
            if 220 <= px then
                if stickX <= -0.4 then
                    MGArcade_Sprite_SetVel(lid, sid, -140, 0)
                elseif not bPressLeft then
                    MGArcade_Sprite_SetVel(lid, sid, 0, 0)
                    if not bNotChattering and not bGameOver then
                        SoundLoopPlay2D("MonkeyTalkLoop", false)
                        bNotChattering = true
                    end
                end
            elseif px <= -220 then
                if 0.4 <= stickX then
                    MGArcade_Sprite_SetVel(lid, sid, 140, 0)
                elseif not bPressRight then
                    MGArcade_Sprite_SetVel(lid, sid, 0, 0)
                    if not bNotChattering and not bGameOver then
                        SoundLoopPlay2D("MonkeyTalkLoop", false)
                        bNotChattering = true
                    end
                end
            end
        elseif stickX <= -0.4 then
            if bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", true)
                bNotChattering = false
            end
            MGArcade_Sprite_SetVel(lid, sid, -140, 0)
        elseif 0.4 <= stickX then
            if bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", true)
                bNotChattering = false
            end
            MGArcade_Sprite_SetVel(lid, sid, 140, 0)
        elseif not bPressLeft and not bPressRight then
            if not bNotChattering and not bGameOver then
                SoundLoopPlay2D("MonkeyTalkLoop", false)
                bNotChattering = true
            end
            MGArcade_Sprite_SetVel(lid, sid, 0, 0)
            MGArcade_Sprite_SetAcc(lid, sid, 0, 0)
        end
        local x, y = MGArcade_Sprite_GetVel(lid, sid)
        if x ~= 0 and TimerPassed(monkeyFlipTime) then
            if gMonkeyCurrentFrame == gMonkeySprite0 then
                gMonkeyCurrentFrame = gMonkeySprite1
            else
                gMonkeyCurrentFrame = gMonkeySprite0
            end
            MGArcade_Sprite_SetTexture(lid, sid, gMonkeyCurrentFrame)
            monkeyFlipTime = GetTimer() + 250
        end
        if IsButtonPressed(7, 0) and not bPressX then
            local x, y = MGArcade_Sprite_GetPos(lid, sid)
            F_ThrowPoo(x, y)
            bPressX = true
        end
        if not IsButtonPressed(7, 0) and bPressX then
            bPressX = false
        end
        if IsButtonPressed(12, 0) and not bPressR1 then
            local x, y = MGArcade_Sprite_GetPos(lid, sid)
            F_ThrowPoo(x, y)
            bPressR1 = true
        end
        if not IsButtonPressed(12, 0) and bPressR1 then
            bPressR1 = false
        end
    end
end

function cbStaticObjects(dt, lid, sid)
end

function F_ParkPoo(sid)
    for i, poo in tblPoo do
        if poo.id == sid then
            MGArcade_Sprite_SetPos(gLayer, sid, poo.x, poo.y)
            MGArcade_Sprite_SetVel(gLayer, sid, 0, 0)
            MGArcade_Sprite_SetAcc(gLayer, sid, 0, 0)
            poo.state = POO_PARKED
            break
        end
    end
end

function C_PooColl(lid, sid, clid, csid)
    if csid == gMonkey then
    else
        for i, banana in tblBananas do
            if csid == banana.id and banana.state == BANANA_SPAWN then
                MGArcade_Sprite_SetVel(gLayer, csid, 0, 40)
                banana.state = BANANA_FALLING
                if not bGameOver then
                    SoundPlay2D("BananaTreeHit")
                    SoundPlay2D("BannaTreeFall")
                end
                F_ParkPoo(sid)
                break
            end
        end
    end
end

function cbPooUpdate(dt, lid, sid)
    if lid == gLayer then
        for i, poo in tblPoo do
            if sid == poo.id then
                local x, y = MGArcade_Sprite_GetPos(lid, poo.id)
                if poo.state == POO_THROWN and y <= -200 then
                    MGArcade_Sprite_SetPos(gLayer, sid, poo.x, poo.y)
                    MGArcade_Sprite_SetVel(gLayer, sid, 0, 0)
                    MGArcade_Sprite_SetAcc(gLayer, sid, 0, 0)
                    poo.state = POO_PARKED
                end
                break
            end
        end
    end
end

function F_ThrowPoo(x, y)
    for j = 10, 1, -1 do
        if tblAmmo[j].state == AMMO_PARKED then
            for i, poo in tblPoo do
                if poo.state == POO_PARKED then
                    MGArcade_Sprite_SetPos(gLayer, poo.id, x, y - 40)
                    MGArcade_Sprite_SetVel(gLayer, poo.id, 0, -110)
                    poo.state = POO_THROWN
                    if not bGameOver then
                        SoundPlay2D("PooFling")
                    end
                    break
                end
            end
            if gMonkeyCurrentFrame == gMonkeySprite0 then
                gMonkeyCurrentFrame = gMonkeySprite1
            else
                gMonkeyCurrentFrame = gMonkeySprite0
            end
            MGArcade_Sprite_SetTexture(gLayer, gMonkey, gMonkeyCurrentFrame)
            MGArcade_Sprite_SetVisible(gHUD, tblAmmo[j].id, false)
            tblAmmo[j].state = AMMO_SPENT
            break
        end
    end
end

function F_PooGenerator()
    allAmmo = 10
    for i, poo in tblAmmo do
        if poo.state == AMMO_SPENT then
            allAmmo = allAmmo - 1
        end
    end
    if allAmmo == 0 and not bSetRegen then
        bSetRegen = true
        regenTime = GetTimer()
    elseif 1 <= allAmmo then
        bSetRegen = false
    elseif bSetRegen and allAmmo == 0 and TimerPassed(regenTime + 2000) then
        for j = 1, 10 do
            if tblAmmo[j].state == AMMO_SPENT then
                MGArcade_Sprite_SetVisible(gHUD, tblAmmo[j].id, true)
                tblAmmo[j].state = AMMO_PARKED
                bSetRegen = false
                break
            end
        end
    end
end

function F_MakeAmmo()
    local tex_sprite1 = MGArcade_GetTextureID("Poo", "Poo_x")
    for i, ammo in tblAmmo do
        gAmmo = MGArcade_Layer_AddSprite(gHUD, cbAmmoUpdate)
        MGArcade_Sprite_SetCol(gHUD, gAmmo, 153, 102, 0, 255)
        MGArcade_Sprite_SetPos(gHUD, gAmmo, ammo.x, 0)
        MGArcade_Sprite_SetSize(gHUD, gAmmo, 24, 24)
        MGArcade_Sprite_SetVel(gHUD, gAmmo, 0, 0)
        MGArcade_Sprite_SetAcc(gHUD, gAmmo, 0, 0)
        MGArcade_Sprite_SetTexture(gHUD, gAmmo, tex_sprite1)
        MGArcade_Sprite_SetVisible(gHUD, gAmmo, true)
        ammo.id = gAmmo
    end
end

function F_MakeLives()
    local tex_sprite1 = MGArcade_GetTextureID("Life", "Life_x")
    for i, life in tblLives do
        gLife = MGArcade_Layer_AddSprite(gHUD, cbLifeUpdate)
        MGArcade_Sprite_SetCol(gHUD, gLife, 255, 255, 255, 255)
        MGArcade_Sprite_SetPos(gHUD, gLife, life.x, 0)
        MGArcade_Sprite_SetSize(gHUD, gLife, 32, 32)
        MGArcade_Sprite_SetVel(gHUD, gLife, 0, 0)
        MGArcade_Sprite_SetAcc(gHUD, gLife, 0, 0)
        MGArcade_Sprite_SetTexture(gHUD, gLife, tex_sprite1)
        MGArcade_Sprite_SetVisible(gHUD, gLife, true)
        life.id = gLife
    end
end

function F_MakePoo()
    local tex_sprite1 = MGArcade_GetTextureID("Poo", "Poo_x")
    poopsprite = tex_sprite1
    for i, poo in tblPoo do
        gPoo = MGArcade_Layer_AddSprite(gLayer, cbPooUpdate, C_PooColl)
        MGArcade_Sprite_SetCol(gLayer, gPoo, 255, 255, 255, 255)
        MGArcade_Sprite_SetPos(gLayer, gPoo, poo.x, poo.y)
        MGArcade_Sprite_SetSize(gLayer, gPoo, 16, 16)
        MGArcade_Sprite_SetVel(gLayer, gPoo, 0, 0)
        MGArcade_Sprite_SetAcc(gLayer, gPoo, 0, 0)
        MGArcade_Sprite_SetCollSize(gLayer, gPoo, 16, 16)
        MGArcade_Sprite_SetTexture(gLayer, gPoo, tex_sprite1)
        MGArcade_Sprite_SetVisible(gLayer, gPoo, true)
        poo.id = gPoo
    end
end

function F_MakeBananas()
    local tex_sprite1 = MGArcade_GetTextureID("Banana", "Banana_x")
    gBananaSprite = tex_sprite1
    for i, banana in tblBananas do
        gBanana = MGArcade_Layer_AddSprite(gLayer, cbBananaUpdate, C_BananaColl)
        MGArcade_Sprite_SetCol(gLayer, gBanana, 255, 255, 255, 255)
        MGArcade_Sprite_SetPos(gLayer, gBanana, banana.x, banana.y)
        MGArcade_Sprite_SetSize(gLayer, gBanana, 32, 32)
        MGArcade_Sprite_SetVel(gLayer, gBanana, 0, 0)
        MGArcade_Sprite_SetAcc(gLayer, gBanana, 0, 0)
        MGArcade_Sprite_SetCollSize(gLayer, gBanana, 32, 32)
        MGArcade_Sprite_SetTexture(gLayer, gBanana, tex_sprite1)
        MGArcade_Sprite_SetVisible(gLayer, gBanana, true)
        banana.id = gBanana
        banana.state = BANANA_SPAWN
    end
end

function F_MakeSpider()
    gSpiderSprite0 = MGArcade_GetTextureID("Spider", "Spider_x")
    gSpiderSprite1 = MGArcade_GetTextureID("Spider2", "Spider2_x")
    tblSpiders = {
        {
            state = SPIDER_PARKED,
            id = 0,
            time = 0,
            x = -100,
            y = -300,
            fliptime = 0,
            CurrentFrame = gSpiderSprite0,
            fadetime = 0
        },
        {
            state = SPIDER_PARKED,
            id = 0,
            time = 0,
            x = -50,
            y = -300,
            fliptime = 0,
            CurrentFrame = gSpiderSprite0,
            fadetime = 0
        },
        {
            state = SPIDER_PARKED,
            id = 0,
            time = 0,
            x = 50,
            y = -300,
            fliptime = 0,
            CurrentFrame = gSpiderSprite0,
            fadetime = 0
        },
        {
            state = SPIDER_PARKED,
            id = 0,
            time = 0,
            x = 100,
            y = -300,
            fliptime = 0,
            CurrentFrame = gSpiderSprite0,
            fadetime = 0
        }
    }
    for i, spider in tblSpiders do
        gSpider = MGArcade_Layer_AddSprite(gLayer, cbSpiderUpdate, C_SpiderColl)
        MGArcade_Sprite_SetCol(gLayer, gSpider, 255, 255, 255, 255)
        MGArcade_Sprite_SetPos(gLayer, gSpider, spider.x, spider.y)
        MGArcade_Sprite_SetSize(gLayer, gSpider, 32, 32)
        MGArcade_Sprite_SetVel(gLayer, gSpider, 0, 0)
        MGArcade_Sprite_SetAcc(gLayer, gSpider, 0, 0)
        MGArcade_Sprite_SetCollSize(gLayer, gSpider, 32, 32)
        MGArcade_Sprite_SetTexture(gLayer, gSpider, spider.CurrentFrame)
        MGArcade_Sprite_SetVisible(gLayer, gSpider, true)
        spider.id = gSpider
        local rand = math.random(1, 4)
        if rand == 1 then
            spawntime = GetTimer() + 2000 + lasttime
            lasttime = 2000
        elseif rand == 2 then
            spawntime = GetTimer() + 2000 + lasttime
            lasttime = 2000
        elseif rand == 3 then
            spawntime = GetTimer() + 4000 + lasttime
            lasttime = 4000
        elseif rand == 4 then
            spawntime = GetTimer() + 5000 + lasttime
            lasttime = 5000
        end
        spider.time = spawntime
    end
end

function TimerPassed(time)
    if time <= GetTimer() then
        return true
    else
        return false
    end
end

function F_GameOverScreen()
    SoundStopStream()
    Wait(100)
    SoundPlayStreamNoLoop("Arc_MonkeyFlingLose.rsm", 1)
    local overScreen = MGArcade_GetTextureID("GameOver", "GameOver_x")
    gGameOverLayer = MGArcade_CreateLayer(512, 400, 1, C_LayerUpdate)
    MGArcade_Layer_SetPos(gGameOverLayer, 0, 0)
    MGArcade_Layer_SetCol(gGameOverLayer, 0, 0, 0, 200)
    MGArcade_Layer_SetScale(gGameOverLayer, 1, 1)
    gOverScreen = MGArcade_Layer_AddSprite(gGameOverLayer)
    MGArcade_Sprite_SetCol(gGameOverLayer, gOverScreen, 255, 255, 255, 255)
    MGArcade_Sprite_SetPos(gGameOverLayer, gOverScreen, 0, 0)
    MGArcade_Sprite_SetSize(gGameOverLayer, gOverScreen, 256, 64)
    MGArcade_Sprite_SetTexture(gGameOverLayer, gOverScreen, overScreen)
    MGArcade_Sprite_SetVisible(gGameOverLayer, gOverScreen, true)
    Wait(4000)
    SoundStopStream()
    SoundPlayStream("Arc_MonkeyFlingMenu01.rsm", 1)
end

function F_HighScoreScreen() -- ! Modified
    local hsY = -100
    tblHS = {
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(1, 0),
            y = hsY + 20,
            flash = false,
            text = "CMG_03"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(1, 1),
            y = hsY + 40,
            flash = false,
            text = "CMG_03"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(1, 2),
            y = hsY + 60,
            flash = false,
            text = "CMG_03"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(1, 3),
            y = hsY + 80,
            flash = false,
            text = "CMG_03"
        },
        {
            id = 0,
            id2 = 0,
            score = MinigameGetHighScore(1, 4),
            y = hsY + 100,
            flash = false,
            text = "CMG_03"
        }
    }
    local scR, scG, scB = 255, 255, 102
    local textSize = 1.4    -- Added this
    if GetLanguage() == 7 then -- Added this
        textSize = 0.7
    end
    gHighScoreText = MGArcade_Layer_AddSprite(gGameOverLayer)
    MGArcade_Sprite_SetCol(gGameOverLayer, gHighScoreText, scR, scG, scB, 255)
    MGArcade_Sprite_SetPos(gGameOverLayer, gHighScoreText, -80, -120)
    MGArcade_Sprite_SetSize(gGameOverLayer, gHighScoreText, 1, 1)
    --[[
    MGArcade_Sprite_SetScale(gGameOverLayer, gHighScoreText, 1.4, 1.4)
    ]] -- Changed to:
    MGArcade_Sprite_SetScale(gGameOverLayer, gHighScoreText, textSize, textSize)
    MGArcade_Sprite_SetVisible(gGameOverLayer, gHighScoreText, true)
    MGArcade_Sprite_SetFont(gGameOverLayer, gHighScoreText, 1)
    MGArcade_Sprite_SetText(gGameOverLayer, gHighScoreText, "ARCADE_HIGHSCORE")
    local flashscore = 0
    flashscore = 1 + MinigameSetHighScoreFromID(1, gScore, "ARCADE_JIM")
    for i, score in tblHS do
        score.id = MGArcade_Layer_AddSprite(gGameOverLayer)
        MGArcade_Sprite_SetCol(gGameOverLayer, score.id, scR, scG, scB, 255)
        MGArcade_Sprite_SetPos(gGameOverLayer, score.id, -100, score.y)
        MGArcade_Sprite_SetSize(gGameOverLayer, score.id, 1, 1)
        --[[
        MGArcade_Sprite_SetScale(gGameOverLayer, score.id, 1.4, 1.4)
        ]] -- Changed to:
        MGArcade_Sprite_SetScale(gGameOverLayer, score.id, textSize, textSize)
        MGArcade_Sprite_SetVisible(gGameOverLayer, score.id, true)
        MGArcade_Sprite_SetFont(gGameOverLayer, score.id, 1)
        MGArcade_Sprite_SetTextToScoreName(gGameOverLayer, score.id, 1, i - 1)
    end
    for i, score in tblHS do
        score.id2 = MGArcade_Layer_AddSprite(gGameOverLayer)
        MGArcade_Sprite_SetCol(gGameOverLayer, score.id2, scR, scG, scB, 255)
        MGArcade_Sprite_SetPos(gGameOverLayer, score.id2, 40, score.y)
        MGArcade_Sprite_SetSize(gGameOverLayer, score.id2, 1, 1)
        --[[
        MGArcade_Sprite_SetScale(gGameOverLayer, score.id2, 1.4, 1.4)
        ]] -- Changed to:
        MGArcade_Sprite_SetScale(gGameOverLayer, score.id2, textSize, textSize)
        MGArcade_Sprite_SetVisible(gGameOverLayer, score.id2, true)
        MGArcade_Sprite_SetFont(gGameOverLayer, score.id2, 1)
        MGArcade_Sprite_SetText(gGameOverLayer, score.id2, score.text)
        local ScoreParam = MGArcade_Sprite_AddTextParam(gGameOverLayer, score.id2, 0)
        MGArcade_Sprite_SetTextParam(gGameOverLayer, score.id2, ScoreParam, MinigameGetHighScore(1, i - 1))
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
        F_UpdateSpiders()
        F_UpdateBananas()
        if not (not IsButtonBeingPressed(7, 0) or xPress) or GetTimer() >= highScoreTimer then
            CameraFade(1000, 0)
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

function F_InstructScreen() -- ! Modified
    bGameOn = false
    gInstructScreen = MGArcade_CreateLayer(495, 400, 150, C_LayerUpdate)
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
    gTutSprite00 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite00, 495, 400)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite00, 0, 0, 0, 128)
    MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite00, 0, -16)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite00, true)
    gTutText01 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutText01, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutText01, foodXLoc + 60, yLoc)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutText01, 0.1, 0.1)
    --[[
    MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, 1.1, 1.1)
    ]] -- Changed to:
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, textSize, textSize)
    else
        MGArcade_Sprite_SetScale(gInstructScreen, gTutText01, 1.1, 1.1)
    end
    MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText01, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText01, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gTutText01, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gTutText01, "ARCADE_FLININST")
    gTutText02 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutText02, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutText02, textXLoc, textYLoc + 112)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutText02, 0.1, 0.1)
    MGArcade_Sprite_SetScale(gInstructScreen, gTutText02, textSize, textSize)
    MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText02, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText02, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gTutText02, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gTutText02, "ARCADE_FLNG_102")
    gTutText03 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutText03, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutText03, textXLoc, textYLoc + 166)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutText03, 0.1, 0.1)
    MGArcade_Sprite_SetScale(gInstructScreen, gTutText03, textSize, textSize)
    MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText03, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText03, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gTutText03, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gTutText03, "ARCADE_FLNG_103")
    gTutText04 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutText04, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutText04, textXLoc, textYLoc + 230)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutText04, 0.1, 0.1)
    MGArcade_Sprite_SetScale(gInstructScreen, gTutText04, textSize, textSize)
    MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText04, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText04, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gTutText04, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gTutText04, "ARCADE_FLNG_104")
    gTutText05 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutText05, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutText05, textXLoc, textYLoc + 294)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutText05, 0.1, 0.1)
    MGArcade_Sprite_SetScale(gInstructScreen, gTutText05, textSize, textSize)
    MGArcade_Sprite_SetCollSize(gInstructScreen, gTutText05, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText05, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gTutText05, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gTutText05, "ARCADE_FLNG_105")
    gTutSprite01 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite01, 64, 64)
    MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite01, gMonkeySprite0)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite01, sCol[1], sCol[2], sCol[3], sCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite01, foodXLoc + 128, yLoc + 112)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite01, true)
    gTutSprite02 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite02, 32, 32)
    MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite02, gBananaSprite)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite02, sCol[1], sCol[2], sCol[3], sCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite02, foodXLoc + 128, yLoc + 166)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite02, true)
    gTutSprite03 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite03, 64, 64)
    MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite03, gSpiderSprite0)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite03, sCol[1], sCol[2], sCol[3], sCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite03, foodXLoc + 128, yLoc + 230)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite03, true)
    gTutSprite04 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetSize(gInstructScreen, gTutSprite04, 32, 32)
    MGArcade_Sprite_SetTexture(gInstructScreen, gTutSprite04, poopsprite)
    MGArcade_Sprite_SetCol(gInstructScreen, gTutSprite04, sCol[1], sCol[2], sCol[3], sCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gTutSprite04, foodXLoc + 128, yLoc + 294)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite04, true)
    gStartText1 = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gStartText1, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gStartText1, -100, yLoc + 330)
    MGArcade_Sprite_SetSize(gInstructScreen, gStartText1, 1, 1)
    --[[
    MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, 1.4, 1.4)
    ]] -- Changed to:
    if GetLanguage() == 7 then
        MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, textSize, textSize)
    else
        MGArcade_Sprite_SetScale(gInstructScreen, gStartText1, 1.4, 1.4)
    end
    MGArcade_Sprite_SetCollSize(gInstructScreen, gStartText1, 0, 0)
    MGArcade_Sprite_SetVisible(gInstructScreen, gStartText1, true)
    MGArcade_Sprite_SetFont(gInstructScreen, gStartText1, 1)
    MGArcade_Sprite_SetText(gInstructScreen, gStartText1, "ARCADE_BTNSTRT")
    gExitText = MGArcade_Layer_AddSprite(gInstructScreen)
    MGArcade_Sprite_SetCol(gInstructScreen, gExitText, tCol[1], tCol[2], tCol[3], tCol[4])
    MGArcade_Sprite_SetPos(gInstructScreen, gExitText, -78, yLoc + 360)
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
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText01, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText02, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText03, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText04, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutText05, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite00, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite01, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite02, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite03, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gTutSprite04, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gStartText1, false)
    MGArcade_Sprite_SetVisible(gInstructScreen, gExitText, false)
    if MinigameIsActive() then
        SoundPlayStream("Arc_MonkeyFlingGame01.rsm", 1, 0, 0)
        Wait(250)
        MGArcade_Sprite_SetVisible(gLayer, gMonkey, true)
        bGameOn = true
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
