function F_AmOnMission1()
    --DebugPrint("F_AmOnMission1() start")
    if shared.g206Subquest ~= -1 then
        --DebugPrint("F_AmOnMission1(): true, returning 0")
        return 0
    else
        --DebugPrint("F_AmOnMission1(): false, returning 1")
        return 1
    end
    --DebugPrint("F_AmOnMission1() finish")
end

function F_AmOnMission2()
    --DebugPrint("F_AmOnMission2() start")
    if shared.g206Subquest ~= -1 then
        --DebugPrint("F_AmOnMission2(): true, returning 0")
        return 0
    else
        --DebugPrint("F_AmOnMission2(): false, returning 1")
        return 1
    end
    --DebugPrint("F_AmOnMission2() finish")
end

function F_AmOnMission3()
    --DebugPrint("F_AmOnMission3() start")
    if shared.g206Subquest ~= -1 then
        --DebugPrint("F_AmOnMission3(): true, returning 0")
        return 0
    else
        --DebugPrint("F_AmOnMission3(): false, returning 1")
        return 1
    end
    --DebugPrint("F_AmOnMission3() finish")
end

function F_AmOnMission4()
    --DebugPrint("F_AmOnMission4() start")
    if shared.g206Subquest ~= -1 then
        --DebugPrint("F_AmOnMission4(): true, returning 0")
        return 0
    else
        --DebugPrint("F_AmOnMission4(): false, returning 1")
        return 1
    end
    --DebugPrint("F_AmOnMission4() finish")
end

function F_SetMission(subq)
    --DebugPrint("F_SetMission(" .. subq .. ") start")
    shared.g206ChangeSubquest = true
    shared.g206Subquest = subq
    --DebugPrint("F_SetMission() finish")
    return 0
end

function main()
    --DebugPrint("2_06supplemental.lua main() start")
    while PedInConversation(gPlayer) do
        Wait(0)
    end
    --DebugPrint("2_06supplemental.lua main() end")
end
