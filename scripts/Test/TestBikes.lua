function MissionSetup()
    local x, y, z = 1, 30, 27
    PlayerSetHealth(200)
    AreaTransitionXYZ(31, x, y, z)
end

function MissionCleanup()
end

function main()
    while mission_completed == false do
        Wait(0)
    end
end
