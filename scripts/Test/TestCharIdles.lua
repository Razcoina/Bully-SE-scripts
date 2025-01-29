local gPeds = {}
local gPedModels = {
    30,
    11,
    16,
    26,
    45,
    146,
    67,
    39,
    17,
    135,
    80,
    139,
    71,
    50,
    74,
    66,
    68,
    63
}
local bMissionRunning = true

function MissionSetup()
    DATLoad("TestCharIdles.DAT", 2)
    DATInit()
end

function MissionCleanup()
    DATUnload(2)
end

function F_CreatePeds()
    local ped
    for i = 1, 18 do
        --print("I is: ", i)
        ped = PedCreatePoint(gPedModels[i], POINTLIST._CHARACTERS, i)
        if i ~= 9 then
            PedClearAllWeapons(ped)
        end
        PedSetAsleep(ped, true)
        PedSetCheap(ped, true)
        table.insert(gPeds, ped)
        Wait(0)
    end
end

function F_DeletePeds()
    while table.getn(gPeds) > 0 do
        if gPeds[1] and PedIsValid(gPeds[1]) then
            PedDelete(gPeds[1])
        end
        table.remove(gPeds, 1)
        Wait(0)
    end
end

function main()
    AreaTransitionPoint(22, POINTLIST._PLAYER, 1)
    CameraReturnToPlayer()
    CameraReset()
    LoadPedModels({
        30,
        11,
        16,
        26,
        45,
        146,
        67,
        39,
        17,
        135,
        80,
        139,
        71,
        50,
        74,
        66,
        68,
        63
    })
    F_CreatePeds()
    while true do
        TextPrintString("Press ~L2~ + ~x~ to create peds again or ~L2~ + ~t~ to quit", 5, 2)
        if not bButtonPressed then
            if IsButtonPressed(7, 0) and IsButtonPressed(11, 0) then
                F_DeletePeds()
                F_CreatePeds()
                bButtonPressed = true
            elseif IsButtonPressed(9, 0) and IsButtonPressed(11, 0) then
                break
            end
        elseif not IsButtonPressed(7, 0) and not IsButtonPressed(9, 0) then
            bButtonPressed = false
        end
        Wait(0)
    end
    TextPrintString("", 1, 2)
    MissionSucceed()
end
