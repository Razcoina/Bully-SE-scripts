function F_UnlockModelChanges()
    if IsMissionAvailable("1_05") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
    end
    if IsMissionAvailable("1_07") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
        PedSetUniqueModelStatus(8, -1)
        PedSetUniqueModelStatus(209, -1)
    end
    if IsMissionAvailable("1_08") then
        PedSetUniqueModelStatus(3, -1)
        PedSetUniqueModelStatus(95, -1)
        PedSetUniqueModelStatus(14, -1)
        PedSetUniqueModelStatus(93, -1)
    end
    if IsMissionAvailable("2_S04") then
        PedSetUniqueModelStatus(6, -1)
    end
    if IsMissionAvailable("1_G1") then
        PedSetUniqueModelStatus(3, -1)
        PedSetUniqueModelStatus(95, -1)
    end
    if IsMissionAvailable("2_06") then
        PedSetUniqueModelStatus(38, -1)
        PedSetUniqueModelStatus(167, -1)
        PedSetUniqueModelStatus(94, -1)
        PedSetUniqueModelStatus(182, -1)
        PedSetUniqueModelStatus(30, -1)
        PedSetUniqueModelStatus(214, -1)
    end
    if IsMissionAvailable("2_03") then
        PedSetUniqueModelStatus(31, -1)
        PedSetUniqueModelStatus(213, -1)
        PedSetUniqueModelStatus(32, -1)
        PedSetUniqueModelStatus(40, -1)
        PedSetUniqueModelStatus(211, -1)
    end
    if IsMissionAvailable("2_G2") then
        PedSetUniqueModelStatus(38, -1)
        PedSetUniqueModelStatus(167, -1)
        PedSetUniqueModelStatus(94, -1)
        PedSetUniqueModelStatus(182, -1)
    end
    if IsMissionAvailable("2_07") then
        PedSetUniqueModelStatus(28, -1)
    end
    if IsMissionAvailable("2_05") then
        PedSetUniqueModelStatus(75, -1)
        PedSetUniqueModelStatus(31, -1)
    end
    if IsMissionAvailable("2_08") then
        PedSetUniqueModelStatus(64, -1)
    end
    if IsMissionAvailable("2_09") then
        PedSetUniqueModelStatus(135, -1)
    end
    if IsMissionAvailable("2_S06") then
        PedSetUniqueModelStatus(55, -1)
    end
    if IsMissionAvailable("3_S10") then
        PedSetUniqueModelStatus(32, -1)
        PedSetUniqueModelStatus(30, -1)
        PedSetUniqueModelStatus(214, -1)
    end
    if IsMissionAvailable("3_04") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
    end
    if IsMissionAvailable("3_G3") then
        PedSetUniqueModelStatus(25, -1)
        PedSetUniqueModelStatus(96, -1)
    end
    if IsMissionAvailable("3_05") then
        PedSetUniqueModelStatus(25, -1)
        PedSetUniqueModelStatus(96, -1)
    end
    if IsMissionAvailable("3_06") then
        PedSetUniqueModelStatus(25, -1)
        PedSetUniqueModelStatus(96, -1)
    end
    if IsMissionAvailable("2_02") then
        PedSetUniqueModelStatus(70, -1)
        PedSetUniqueModelStatus(235, -1)
    end
    if IsMissionAvailable("4_02") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
    end
    if IsMissionAvailable("4_04") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
        PedSetUniqueModelStatus(11, -1)
        PedSetUniqueModelStatus(11, -1)
    end
    if IsMissionAvailable("4_G4") then
        PedSetUniqueModelStatus(14, -1)
        PedSetUniqueModelStatus(93, -1)
    end
    if IsMissionAvailable("5_04") then
        PedSetUniqueModelStatus(55, -1)
    end
    if IsMissionAvailable("5_01") then
        PedSetUniqueModelStatus(4, -1)
        PedSetUniqueModelStatus(208, -1)
        PedSetUniqueModelStatus(3, -1)
        PedSetUniqueModelStatus(95, -1)
    end
    if IsMissionAvailable("5_03") then
        PedSetUniqueModelStatus(25, -1)
        PedSetUniqueModelStatus(96, -1)
        PedSetUniqueModelStatus(29, -1)
        PedSetUniqueModelStatus(201, -1)
    end
    if IsMissionAvailable("5_02") then
        PedSetUniqueModelStatus(33, -1)
        PedSetUniqueModelStatus(34, -1)
        PedSetUniqueModelStatus(212, -1)
    end
    if IsMissionAvailable("5_06") then
        PedSetUniqueModelStatus(75, -1)
    end
    if IsMissionAvailable("5_07a") then
        PedSetUniqueModelStatus(75, -1)
    end
    if IsMissionAvailable("6_02") then
        PedSetUniqueModelStatus(75, -1)
    end
    if IsMissionAvailable("1_S01") then
        PedSetUniqueModelStatus(61, -1)
        PedSetUniqueModelStatus(57, -1)
    end
    if IsMissionAvailable("4_S12") then
        PedSetUniqueModelStatus(63, -1)
    end
    if IsMissionAvailable("3_S11") then
        PedSetUniqueModelStatus(63, -1)
        PedSetUniqueModelStatus(57, -1)
    end
end

function F_MissionCompleteModelChanges()
    if IsMissionCompleated("1_05") then
        PedSetUniqueModelStatus(4, 1)
    end
    if IsMissionCompleated("1_07") then
        PedSetUniqueModelStatus(4, 1)
        PedSetUniqueModelStatus(8, 1)
    end
    if IsMissionCompleated("1_08") then
        PedSetUniqueModelStatus(3, 1)
        PedSetUniqueModelStatus(14, 1)
    end
    if IsMissionCompleated("2_S04") then
        PedSetUniqueModelStatus(6, 1)
    end
    if IsMissionCompleated("1_G1") then
        PedSetUniqueModelStatus(3, 1)
    end
    if IsMissionCompleated("2_06") then
        PedSetUniqueModelStatus(38, 1)
        PedSetUniqueModelStatus(30, 1)
    end
    if IsMissionCompleated("2_03") then
        PedSetUniqueModelStatus(31, 1)
        PedSetUniqueModelStatus(32, 1)
        PedSetUniqueModelStatus(40, 1)
    end
    if IsMissionCompleated("2_G2") then
        PedSetUniqueModelStatus(38, 1)
    end
    if IsMissionCompleated("2_05") then
        PedSetUniqueModelStatus(31, 1)
    end
    if IsMissionCompleated("2_07") then
        PedSetUniqueModelStatus(28, 1)
    end
    if IsMissionCompleated("2_08") then
        PedSetUniqueModelStatus(64, 1)
    end
    if IsMissionCompleated("2_B") then
        PedSetUniqueModelStatus(135, 2)
    end
    if IsMissionCompleated("2_S06") then
        PedSetUniqueModelStatus(55, 1)
    end
    if IsMissionCompleated("3_S10") then
        PedSetUniqueModelStatus(32, 1)
        PedSetUniqueModelStatus(30, 1)
    end
    if IsMissionCompleated("3_04") then
        PedSetUniqueModelStatus(4, 1)
    end
    if IsMissionCompleated("3_G3") then
        PedSetUniqueModelStatus(25, 1)
    end
    if IsMissionCompleated("3_05") then
        PedSetUniqueModelStatus(25, 1)
    end
    if IsMissionCompleated("3_06") then
        PedSetUniqueModelStatus(25, 1)
    end
    if IsMissionCompleated("2_02") then
        PedSetUniqueModelStatus(70, 1)
    end
    if IsMissionCompleated("4_02") then
        PedSetUniqueModelStatus(4, 1)
    end
    if IsMissionCompleated("4_04") then
        PedSetUniqueModelStatus(4, 1)
        PedSetUniqueModelStatus(11, 1)
        PedSetUniqueModelStatus(11, 1)
    end
    if IsMissionCompleated("4_G4") then
        PedSetUniqueModelStatus(14, 1)
    end
    if IsMissionCompleated("5_04") then
        PedSetUniqueModelStatus(55, 1)
    end
    if IsMissionCompleated("5_01") then
        PedSetUniqueModelStatus(4, 1)
        PedSetUniqueModelStatus(3, 1)
    end
    if IsMissionCompleated("5_03") then
        PedSetUniqueModelStatus(25, 1)
        PedSetUniqueModelStatus(29, 1)
    end
    if IsMissionCompleated("5_02") then
        PedSetUniqueModelStatus(33, 1)
        PedSetUniqueModelStatus(34, 1)
    end
    if IsMissionCompleated("1_S01") then
        PedSetUniqueModelStatus(61, 1)
        PedSetUniqueModelStatus(57, 1)
    end
    if IsMissionCompleated("4_S12") then
        PedSetUniqueModelStatus(63, 1)
    end
    if IsMissionCompleated("3_S03") then
        PedSetUniqueModelStatus(61, -1)
    end
    if IsMissionCompleated("3_S11") then
        PedSetUniqueModelStatus(63, 1)
        PedSetUniqueModelStatus(57, 1)
    end
    if IsMissionCompleated("6_B") then
        PedSetUniqueModelStatus(48, -1)
        PedSetUniqueModelStatus(2, 1)
    end
end

function F_MissionFactionChanges()
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 4)
    elseif IsMissionCompleated("1_B") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 4)
    elseif IsMissionCompleated("1_11x2") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 0)
    elseif IsMissionCompleated("1_11x1") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 2)
    elseif IsMissionCompleated("1_07") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 0)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(11, 13, 1)
    else
        PedSetDefaultTypeToTypeAttitude(11, 13, 1)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 4)
    elseif IsMissionCompleated("5_09") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 1)
    elseif IsMissionCompleated("4_B2") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 4)
    elseif IsMissionCompleated("4_G4") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 3)
    elseif IsMissionCompleated("3_B") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 4)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(1, 13, 3)
    else
        PedSetDefaultTypeToTypeAttitude(1, 13, 2)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 4)
    elseif IsMissionCompleated("5_09") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 1)
    elseif IsMissionCompleated("3_S10") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 4)
    elseif IsMissionCompleated("3_02") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 3)
    elseif IsMissionCompleated("2_B") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 4)
    elseif IsMissionCompleated("2_05") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 0)
    elseif IsMissionCompleated("2_03") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 1)
    elseif IsMissionCompleated("1_B") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 2)
    elseif IsMissionCompleated("1_11x2") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 2)
    elseif IsMissionCompleated("1_11x1") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 2)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(5, 13, 2)
    else
        PedSetDefaultTypeToTypeAttitude(5, 13, 2)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 4)
    elseif IsMissionCompleated("5_03") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 2)
    elseif IsMissionCompleated("5_09") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 1)
    elseif IsMissionCompleated("3_B") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 4)
    elseif IsMissionCompleated("3_05") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 0)
    elseif IsMissionCompleated("3_S10") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 1)
    elseif IsMissionCompleated("3_01") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 3)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(4, 13, 2)
    else
        PedSetDefaultTypeToTypeAttitude(4, 13, 2)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 4)
    elseif IsMissionCompleated("5_09") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 1)
    elseif IsMissionCompleated("4_B2") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 4)
    elseif IsMissionCompleated("4_01") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 1)
    elseif IsMissionCompleated("4_02") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 2)
    elseif IsMissionCompleated("1_11x2") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 1)
    elseif IsMissionCompleated("1_11x1") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 2)
    elseif IsMissionCompleated("1_09") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 1)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(2, 13, 2)
    else
        PedSetDefaultTypeToTypeAttitude(2, 13, 2)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(3, 13, 4)
    elseif IsMissionCompleated("5_B") then
        PedSetDefaultTypeToTypeAttitude(3, 13, 4)
    elseif IsMissionCompleated("4_B2") then
        PedSetDefaultTypeToTypeAttitude(3, 13, 0)
    else
        PedSetDefaultTypeToTypeAttitude(3, 13, 1)
    end
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(6, 13, 4)
    elseif IsMissionCompleated("5_09") then
        PedSetDefaultTypeToTypeAttitude(6, 13, 1)
    elseif IsMissionCompleated("1_04") then
        PedSetDefaultTypeToTypeAttitude(6, 13, 3)
    else
        PedSetDefaultTypeToTypeAttitude(6, 13, 2)
    end
    PedSetDefaultTypeToTypeAttitude(0, 13, 1)
    if IsMissionCompleated("6_B") then
        PedSetDefaultTypeToTypeAttitude(8, 13, 3)
    else
        PedSetDefaultTypeToTypeAttitude(8, 13, 2)
    end
    PedSetDefaultTypeToTypeAttitude(9, 13, 2)
end
