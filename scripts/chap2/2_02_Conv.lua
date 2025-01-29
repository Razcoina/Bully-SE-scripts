function F_PlayerGotComicCond()
    return shared.g2_02_GotComic == true and 1 or 0
end

function F_PlayerSetReturnedComic()
    shared.g2_02_ReturnedComic = true
end
