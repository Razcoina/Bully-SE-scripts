--[[ Changes to this file:
	* Modified the gnome outfit
]]

function scloth()
	local ONE_PIECE = true
	local MULTI_PIECE = false
	local LONGSLEEVE = true
	local SHORTSLEEVE = false
	ClothingDefineOutfit("Underwear", "CLT_Undies", "Hair", "P_SSleeves11", "none", "none", "SP_Briefs", "SP_Socks", SHORTSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Starting", "CLT_Start", "Hair", "B_Jacket6", "none", "none", "B_Pants2", "P_Sneakers2", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Uniform", "CLT_Uniform", "Hair", "S_Sweater5", "none", "none", "S_Pants1", "P_Sneakers2", SHORTSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Boxing", "CLT_BOX_OUTFIT", "Hair", "SP_BOXING_T", "SP_Boxing_G_L", "SP_Boxing_G_R", "SP_BOXING_L", "SP_BOXING_ft", SHORTSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Boxing NG", "CLT_BOX_NG", "Hair", "SP_BOXING_T", "none", "none", "SP_BOXING_L", "SP_BOXING_ft", SHORTSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Wrestling", "CLT_WRS_OUTFIT", "SP_Wrestling_H", "SP_Wrestling_T", "none", "none", "SP_Wrestling_L", "SP_Wrestling_ft", SHORTSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Mascot", "CLT_MASCOT", "SP_Mascot_H", "none", "none", "none", "none", "SP_Mascot_B", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("MascotNoHead", "CLT_MASCOT", "Hair", "none", "none", "none", "none", "SP_Mascot_B", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Orderly", "CLT_OLY_OUTFIT", "Hair", "SP_Orderly_T", "none", "none", "SP_Orderly_P", "SP_Orderly_B", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Halloween", "CLT_HALLOW", "SP_Ween_H", "SP_Ween_T", "none", "none", "SP_Ween_L", "B_Boots1", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("PJ", "CLT_PJ", "Hair", "SP_PJ_T", "none", "none", "SP_PJ_L", "SP_Socks", SHORTSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Prison", "CLT_Prison", "Hair", "SP_Prison_T", "none", "none", "SP_Prison_L", "P_Boots2", SHORTSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Grotto Master", "CLT_DM", "SP_DM_H", "SP_DM_T", "none", "none", "B_Pants2", "P_Boots2", SHORTSLEEVE, MULTI_PIECE)
	--[[
	ClothingDefineOutfit("Gnome", "CLT_Gnome", "SP_Opo_H", "SP_Gnome_T", "none", "none", "SP_Gnome_L", "SP_Gnome_ft", LONGSLEEVE, ONE_PIECE)
	]] -- Changed to:
	ClothingDefineOutfit("Gnome", "CLT_Gnome", "SP_Gnome_H", "SP_Gnome_T", "none", "none", "SP_Gnome_L", "SP_Gnome_ft", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Fast Food", "CLT_Fastfood", "SP_Fries_H", "SP_Fries_T", "none", "none", "SP_Fries_L", "P_Boots2", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Gold Suit", "CLT_Rocker", "SP_Goldsuit_H", "SP_Goldsuit_T", "none", "none", "SP_Goldsuit_L", "SP_Goldsuit_ft", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("BMX Champion", "CLT_BMX", "SP_BikeHelmet", "SP_BikeJersey", "none", "none", "B_Pants2", "P_Boots2", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Gym Strip", "CLT_gym", "Hair", "S_SSleeves4", "S_Wristband4", "S_Wristband3", "S_Shorts1", "P_Sneakers1", SHORTSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Ninja_BLK", "CLT_NinjaBLK", "SP_Ninja_H", "SP_Ninja_T", "none", "none", "SP_Ninja_L", "SP_Ninja_Ft", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Ninja_WHT", "CLT_NinjaWHT", "SP_NinjaW_H", "SP_NinjaW_T", "none", "none", "SP_NinjaW_L", "SP_NinjaW_Ft", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Ninja_RED", "CLT_NinjaRED", "SP_NinjaR_H", "SP_NinjaR_T", "none", "none", "SP_NinjaR_L", "SP_NinjaR_Ft", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("Columbus", "CLT_Columbus", "SP_Colum_H", "SP_Colum_T", "none", "none", "SP_Colum_L", "SP_Colum_FT", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Nutcracker", "CLT_Nutcracker", "SP_Nutcrack_H", "SP_Nutcrack_T", "none", "none", "SP_Nutcrack_L", "SP_Nutcrack_FT", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Elf", "CLT_Elf", "SP_Elf_H", "SP_Elf_T", "none", "none", "SP_Elf_L", "SP_Elf_FT", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Marching Band", "CLT_MBand", "SP_MBand_H", "SP_MBand_T", "none", "none", "SP_MBand_L", "SP_MBand_FT", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Nascar", "CLT_Nascar", "SP_Nascar_H", "SP_Nascar_T", "none", "none", "SP_Nascar_L", "SP_Nascar_FT", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("80 Rocker", "CLT_80Rocker", "SP_80Rocker_H", "SP_80Rocker_T", "none", "SP_80Bracer", "SP_80Rocker_L", "SP_80Rocker_FT", SHORTSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Panda", "CLT_Panda", "SP_Panda_H", "none", "none", "none", "none", "SP_Panda_B", LONGSLEEVE, ONE_PIECE)
	ClothingDefineOutfit("Alien", "CLT_Alien", "SP_Alien_H", "SP_Alien_T", "none", "none", "SP_Alien_L", "P_Boots4", LONGSLEEVE, MULTI_PIECE)
	ClothingDefineOutfit("NerdJimmy", "CLT_Nerd", "SP_Nerd_H", "SP_Nerd_T", "none", "SP_NerdWatch", "SP_Nerd_L", "SP_Nerd_FT", SHORTSLEEVE, ONE_PIECE)
end

scloth()
scloth = nil
