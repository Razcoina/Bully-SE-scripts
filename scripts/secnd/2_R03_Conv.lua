function F_ConversationOver()
    --print("set the conversation variable to true")
    shared.gConversationOver_2_R03 = true
end

function main()
    Wait(100)
    while PedInConversation(gPlayer) do
        Wait(10)
    end
end
