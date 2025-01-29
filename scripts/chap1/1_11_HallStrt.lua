function MissionSetup()
end

function MissionCleanup()
end

function main()
    --print("HALLOWEEN SHIT SHOULD BE ACTIVE!!")
    AreaLoadSpecialEntities("Halloween3", true)
    AreaEnsureSpecialEntitiesAreCreated()
    MissionSucceed(false, false, false)
end
