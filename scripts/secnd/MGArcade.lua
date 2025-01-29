local playerWins = false
local collisionTable = {}
local scaleXTable = {}
local scaleYTable = {}
local spriteCount = 20

function MissionSetup()
    PlayerSetControl(0)
    PlayerSetInvulnerable(true)
    PedIgnoreStimuli(gPlayer, true)
    PedIgnoreAttacks(gPlayer, true)
    AreaTransitionPoint(15, POINTLIST._SV_SCHOOLENGLISH, 1)
    MinigameCreate("ARCADE", false)
end

function MissionCleanup()
    PlayerSetInvulnerable(false)
    MinigameDestroy()
    PlayerSetControl(1)
end

local frameCount = 0

function main()
    while MinigameIsReady() == false do
        Wait(0)
    end
    Wait(2)
    MinigameStart()
    MinigameEnableHUD(true)
    CameraFade(1000, 1)
    Wait(1100)
    MGArcade_InitScreen(0, 0, 0)
    MGArcade_LoadTextures("MG_Fend")
    aTexture = MGArcade_GetTextureID("FSquir", "FSquir_x")
    local lid, sid
    lid = MGArcade_CreateLayer(320, 240, 100, C_LayerUpdate)
    MGArcade_Layer_SetPos(lid, 0, 0)
    MGArcade_Layer_SetCol(lid, 255, 255, 255, 255)
    MGArcade_Layer_SetScale(lid, 1, 1)
    for i = 1, spriteCount do
        sid = MGArcade_Layer_AddSprite(lid, C_SpriteUpdate, C_SpriteColl)
        MGArcade_Sprite_SetCol(lid, sid, 0, 0, 255, 255)
        MGArcade_Sprite_SetPos(lid, sid, math.random(-160, 160), math.random(-120, 120))
        MGArcade_Sprite_SetVel(lid, sid, math.random(-30, 30), math.random(-30, 30))
        if math.random(0, 100) > 50 then
            MGArcade_Sprite_SetTexture(lid, sid, aTexture)
        end
        local sizeX = math.random(1, 50)
        local sizeY = math.random(1, 50)
        MGArcade_Sprite_SetSize(lid, sid, sizeX, sizeY)
        if math.random(1, 100) > 50 then
            scaleXTable[sid] = math.random(1, 200) / 100
            scaleYTable[sid] = math.random(1, 200) / 100
            MGArcade_Sprite_SetScale(lid, sid, scaleXTable[sid], scaleYTable[sid])
        else
            scaleXTable[sid] = -1
            scaleYTable[sid] = -1
            MGArcade_Sprite_SetScale(lid, sid, 1, 1)
        end
        MGArcade_Sprite_SetAcc(lid, sid, math.random(-15, 15), math.random(-15, 15))
        local colType = math.random(0, 4)
        if colType == 0 then
            MGArcade_Sprite_SetCollSize(lid, sid, sizeX)
        elseif colType == 1 then
            MGArcade_Sprite_SetCollSize(lid, sid, sizeX, sizeY)
        elseif colType == 2 then
            MGArcade_Sprite_SetCollSize(lid, sid, math.random(1, 50))
        elseif colType == 3 then
            MGArcade_Sprite_SetCollSize(lid, sid, math.random(1, 50), math.random(1, 50))
        elseif colType == 4 then
            MGArcade_Sprite_SetCollSize(lid, sid, math.random(1, 50), math.random(1, 50))
        end
        MGArcade_Sprite_SetVisible(lid, sid, true)
        collisionTable[sid] = 0
    end
    while MinigameIsActive() do
        frameCount = frameCount + 3.14 / 512
        Wait(0)
    end
    if MinigameIsSuccess() then
        Wait(1000)
        playerWins = true
    end
    MinigameEnableHUD(false)
    if playerWins then
        TextPrintString("You win!", 1)
    else
        TextPrintString("GAME OVER.", 1)
    end
    Wait(1000)
    MinigameEnd()
    if playerWins then
        MissionSucceed()
    else
        MissionFail()
    end
end

function C_LayerUpdate(dt, layerID)
    local stickX, stickY
    stickX = -GetStickValue(16, 0)
    stickY = -GetStickValue(17, 0)
    MGArcade_Layer_SetPos(layerID, 320 * stickX, 240 * stickY)
    stickX = -GetStickValue(18, 0)
    stickY = -GetStickValue(19, 0)
    if stickX < 0 then
        stickX = 1 + stickX
        stickX = stickX * 0.5
        stickX = stickX + 0.5
    else
        stickX = stickX + 1
    end
    if stickY < 0 then
        stickY = 1 + stickY
        stickY = stickY * 0.5
        stickY = stickY + 0.5
    else
        stickY = stickY + 1
    end
    MGArcade_Layer_SetScale(layerID, stickX + 1, stickY + 1)
end

function C_SpriteUpdate(dt, lid, sid)
    local sposx, sposy, svelx, svely
    sposx, sposy = MGArcade_Sprite_GetPos(lid, sid)
    svelx, svely = MGArcade_Sprite_GetVel(lid, sid)
    if 160 < sposx then
        MGArcade_Sprite_SetPos(lid, sid, 160, sposy)
        MGArcade_Sprite_SetVel(lid, sid, -svelx, svely)
    elseif sposx < -160 then
        MGArcade_Sprite_SetPos(lid, sid, -160, sposy)
        MGArcade_Sprite_SetVel(lid, sid, -svelx, svely)
    end
    if 120 < sposy then
        MGArcade_Sprite_SetPos(lid, sid, sposx, 120)
        MGArcade_Sprite_SetVel(lid, sid, svelx, -svely)
    elseif sposy < -120 then
        MGArcade_Sprite_SetPos(lid, sid, sposx, -120)
        MGArcade_Sprite_SetVel(lid, sid, svelx, -svely)
    end
    if collisionTable[sid] == 1 then
        MGArcade_Sprite_SetCol(lid, sid, 255, 0, 0, 255)
    else
        MGArcade_Sprite_SetCol(lid, sid, 0, 0, 255, 255)
    end
    if scaleXTable[sid] ~= -1 then
        MGArcade_Sprite_SetScale(lid, sid, 0.25 + scaleXTable[sid] * (1 + math.cos(frameCount)), 0.25 + scaleYTable[sid] * (1 + math.sin(frameCount)))
    end
    collisionTable[sid] = 0
end

function C_SpriteColl(lid, sid, clid, csid)
    collisionTable[sid] = 1
end
