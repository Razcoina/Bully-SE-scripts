local bLoop = true

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    MissionDontFadeIn()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    DATLoad("TESTSTUD.DAT", 2)
    DATInit()
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    AreaRevertToDefaultPopulation()
    DATUnload(2)
    DATInit()
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    AreaTransitionPoint(35, POINTLIST._TESTSTUDSPAWNPLAYER)
    F_SetupGirls()
    CameraFade(500, 1)
    Wait(500)
    while bLoop do
        Wait(0)
    end
    MissionSucceed()
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_SetupGirls()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupGirls()")
    pedGirl01 = PedCreatePoint(38, POINTLIST._TESTSTUDGIRL1, 1)
    pedGirl02 = PedCreatePoint(74, POINTLIST._TESTSTUDGIRL2, 1)
    pedGirl03 = PedCreatePoint(137, POINTLIST._TESTSTUDGIRL3, 1)
    PedAlwaysUpdateAnimation(pedGirl01, true)
    PedAlwaysUpdateAnimation(pedGirl02, true)
    PedAlwaysUpdateAnimation(pedGirl03, true)
    Wait(1000)
    PedSetActionNode(pedGirl01, "/Global/WProps/PropInteract", "Act/WProps.act")
    PedSetActionNode(pedGirl02, "/Global/WProps/PropInteract", "Act/WProps.act")
    PedSetActionNode(pedGirl03, "/Global/WProps/PropInteract", "Act/WProps.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupGirls()")
end
