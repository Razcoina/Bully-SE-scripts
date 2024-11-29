--[[ Changes to this file:
	* Removed unused local variables
	* Modified function F_TableInit, may require testing
	* Modified function MissionSetup, may require testing
	* Modified function MissionCleanup, may require testing
	* Modified function main, may require testing
	* Modified function F_InitDATLoad, may require testing
]]

ImportScript("Library/BikeRace_util.lua")
local tblRace, tblPlayer, tblRacer, tblShortcut, tblHighlightedNode, tblPersistentEntity, missionName
local raceLevel = 0
local gReward = 1500
--[[
local signedUp = true
]] -- Not present in original script
local nispath, nispathlook, szSpecialGroupToCleanup

function F_TableInit() -- ! Modified
	if shared.g3_R08_CurrentRace == 0 then
		tblRace = {
			laps = 1,
			path = PATH._3_R08_RACE,
			missionCode = "3_R08",
			reward = 2000,
			countdown_ped = tblOwner,
			path_smoothing = 1,
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK1"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 32,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 0,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 10,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.2
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 34,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 25,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {
			{
				path = PATH._3_R08_SCUT1,
				start_node = 5,
				end_node = 32
			},
			{
				path = PATH._3_R08_SCUT2,
				start_node = 94,
				end_node = 110
			},
			{
				path = PATH._3_R08_SCUT3,
				start_node = 104,
				end_node = 110,
				jump_nodes = { 11 }
			}
		}
		tblHighlightedNode = {
			3,
			10,
			17,
			24,
			27,
			30,
			34,
			41,
			45,
			49,
			55,
			60,
			71,
			75,
			77,
			80,
			84,
			89,
			97,
			102,
			105,
			110,
			113,
			127,
			130,
			134,
			138,
			142,
			147,
			150,
			156,
			159,
			163,
			168,
			170,
			176,
			184,
			192,
			205,
			206
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 1 then
		tblRace = {
			laps = 1,
			path = PATH._2_04_RACE,
			missionCode = "3_R08",
			reward = 2500,
			auto_lineup = true,
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK2"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._2_04_PLAYERRICH,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._2_04_PLAYERBIKERICH
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._2_04_PREP1,
				bike_start_pos = POINTLIST._2_04_PREP1BIKE,
				model = 30,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._2_04_PREP2,
				bike_start_pos = POINTLIST._2_04_PREP2BIKE,
				model = 17,
				bike_model = 273,
				max_sprint_speed = 0.86,
				max_normal_speed = 0.73,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 0,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 1
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._2_04_PREP3,
				bike_start_pos = POINTLIST._2_04_PREP3BIKE,
				model = 40,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {
			{
				path = PATH._2_04_RICHSHORTCUT01,
				start_node = 7,
				end_node = 11
			},
			{
				path = PATH._2_04_RICHSHORTCUT02,
				start_node = 38,
				end_node = 44
			},
			{
				path = PATH._2_04_RICHSHORTCUT03,
				start_node = 46,
				end_node = 54
			},
			{
				path = PATH._2_04_RICHSHORTCUT04,
				start_node = 58,
				end_node = 63
			},
			{
				path = PATH._2_04_RICHSHORTCUT05,
				start_node = 63,
				end_node = 70
			}
		}
		tblHighlightedNode = {
			1,
			2,
			4,
			5,
			7,
			11,
			14,
			18,
			20,
			23,
			25,
			26,
			27,
			30,
			32,
			34,
			35,
			37,
			38,
			40,
			43,
			45,
			46,
			48,
			51,
			53,
			54,
			57,
			63,
			70
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 2 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = { 127 },
			laps = 1,
			reward = 3500,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_BWTC"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 9,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				weapon = MODELENUM._POLO,
				ammo = 1,
				model = 16,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 27,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			1,
			2,
			3,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			20,
			21,
			24,
			25,
			26,
			28,
			29,
			30,
			31,
			32,
			33,
			34,
			35,
			36,
			37,
			38,
			39,
			40,
			41,
			42,
			43,
			44,
			45,
			47
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 3 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 2,
			reward = 3000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK1"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {
			{
				path = PATH._3_R08_SCUT1,
				start_node = 3,
				end_node = 7,
				jump_nodes = { 1 }
			},
			{
				path = PATH._3_R08_SCUT2,
				start_node = 4,
				end_node = 8,
				jump_nodes = { 1 }
			},
			{
				path = PATH._3_R08_SCUT3,
				start_node = 14,
				end_node = 18,
				jump_nodes = { 1 }
			},
			{
				path = PATH._3_R08_SCUT4,
				start_node = 17,
				end_node = 20,
				jump_nodes = { 2 }
			},
			{
				path = PATH._3_R08_SCUT6,
				start_node = 29,
				end_node = 37
			},
			{
				path = PATH._3_R08_SCUT7,
				start_node = 31,
				end_node = 35,
				jump_nodes = { 1 }
			},
			{
				path = PATH._3_R08_SCUT9,
				start_node = 48,
				end_node = 62,
				jump_nodes = { 5, 7 }
			}
		}
		tblHighlightedNode = {
			2,
			9,
			15,
			18,
			24,
			29,
			36,
			39,
			45,
			49,
			52,
			54,
			56,
			59
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 4 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {},
			laps = 1,
			reward = 5000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_BWAC"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 8,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 13,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			1,
			2,
			3,
			5,
			6,
			8,
			9,
			11,
			14,
			16,
			17,
			19,
			21,
			25,
			29,
			34,
			35,
			37,
			38,
			39,
			41,
			43,
			44,
			45,
			48,
			50,
			52,
			53,
			54,
			55,
			57,
			58,
			61,
			62,
			63,
			65,
			66,
			70,
			73,
			74,
			77,
			79,
			80,
			81,
			82,
			83,
			85,
			87,
			89,
			90,
			92,
			94,
			96,
			98,
			100,
			103,
			104,
			106,
			108,
			111
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 5 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 1,
			reward = 3000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK3"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {
			{
				path = PATH._3_R08_SCUT1,
				start_node = 27,
				end_node = 32,
				jump_nodes = { 1 }
			},
			{
				path = PATH._3_R08_SCUT2,
				start_node = 32,
				end_node = 40,
				jump_nodes = { 1 }
			}
		}
		tblHighlightedNode = {
			1,
			3,
			6,
			9,
			12,
			14,
			16,
			18,
			19,
			21,
			23,
			25,
			27,
			29,
			31,
			34,
			36,
			40,
			44,
			46,
			47
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 6 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 1,
			reward = 3500,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK4"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			2,
			3,
			4,
			5,
			7,
			8,
			10,
			13,
			14,
			15,
			17,
			19,
			22,
			24,
			25,
			27,
			29,
			31,
			33,
			35,
			37,
			39,
			41
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 7 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 1,
			reward = 4000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK5"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {
			{
				path = PATH._3_R08_SCUT1,
				start_node = 0,
				end_node = 3,
				jump_nodes = { 1 }
			}
		}
		tblHighlightedNode = {
			0,
			1,
			3,
			4,
			6,
			8,
			10,
			12,
			14,
			16,
			18,
			19,
			21,
			23,
			25,
			28,
			30,
			31,
			33,
			35,
			37,
			38,
			39,
			40,
			42,
			45,
			47,
			51,
			54,
			57,
			60
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 8 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 2,
			reward = 4500,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK6"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			2,
			4,
			5,
			6,
			7,
			8,
			10,
			12,
			14,
			15,
			16,
			18,
			20,
			22,
			24,
			26,
			28,
			30,
			32,
			33
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 9 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {},
			laps = 2,
			reward = 2500,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK2"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			2,
			4,
			5,
			8,
			9,
			10,
			11,
			13,
			15,
			17,
			18,
			19,
			20,
			21,
			23,
			25,
			26,
			27,
			28,
			29,
			30,
			32
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 10 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 2,
			reward = 2000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK1"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			1,
			3,
			5,
			8,
			10,
			11,
			13,
			15,
			17,
			19,
			22
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 11 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 2,
			reward = 4000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_NCC"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			0,
			3,
			6,
			9,
			11,
			13,
			15,
			17,
			18,
			19,
			20,
			22,
			24,
			26
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 12 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = { 13 },
			laps = 1,
			reward = 5000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_BWVLC"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			2,
			3,
			5,
			7,
			9,
			11,
			13,
			15,
			17,
			19,
			21,
			22,
			23,
			24,
			26,
			28,
			30,
			32
		}
		tblPersistentEntity = {}
	elseif shared.g3_R08_CurrentRace == 13 then
		tblRace = {
			path = PATH._3_R08_RACE,
			jump_nodes = {
				14,
				25,
				28,
				47,
				52,
				57
			},
			laps = 1,
			reward = 3000,
			missionCode = "3_R08",
			soundTrack = "MS_BikeRace02.rsm",
			volume = MUSIC_DEFAULT_VOLUME + 0.25,
			unlock = "3_R08_UNLOCK3"
		}
		tblPlayer = {
			id = nil,
			bike = nil,
			start_pos = POINTLIST._3_R08_PLAYER,
			area_code = 0,
			bike_model = 273,
			bike_start_pos = POINTLIST._3_R08_PLAYERBIKE
		}
		tblRacer = {
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED1,
				bike_start_pos = POINTLIST._3_R08_PED1BIKE,
				model = 24,
				bike_model = 273,
				max_sprint_speed = 0.82,
				max_normal_speed = 0.79,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 30,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.65
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED2,
				bike_start_pos = POINTLIST._3_R08_PED2BIKE,
				model = 11,
				bike_model = 273,
				max_sprint_speed = 0.81,
				max_normal_speed = 0.8,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 40,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.6
			},
			{
				id = nil,
				bike = nil,
				blip = nil,
				start_pos = POINTLIST._3_R08_PED3,
				bike_start_pos = POINTLIST._3_R08_PED3BIKE,
				model = 28,
				bike_model = 273,
				max_sprint_speed = 0.83,
				max_normal_speed = 0.81,
				catch_up_dist = 20,
				catch_up_speed = 1.6,
				slow_down_dist = 25,
				slow_down_speed = 0.35,
				shortcut_odds = 100,
				shooting_odds = 0,
				trick_odds = 0,
				target = nil,
				sprint_freq = 0,
				sprint_duration = 0,
				sprint_likelyhood = 0,
				aggressiveness = 0.8
			}
		}
		tblShortcut = {}
		tblHighlightedNode = {
			1,
			2,
			3,
			9,
			11,
			18,
			22,
			24,
			26
		}
		tblPersistentEntity = {}
		--[[
	else
		TextPrintString("ERROR: You must sign up for a race before running this mission -- Jak", 3, 2)
	]] -- Not present in original script
	end
end

function MissionSetup() -- ! Modified
	GarageSetIsDeactivated(true)
	SoundEnableInteractiveMusic(false)
	--[[
	if signedUp == true then
		DATInit()
		WeaponRequestModel(300)
		VehicleOverrideAmbient(2, 2, 0, 0)
	end
	]] -- Not present in original script
	DATInit()
	WeaponRequestModel(300)
	VehicleOverrideAmbient(2, 2, 0, 0)
end

function MissionCleanup() -- ! Modified
	EnablePOI(true, true)
	AreaRevertToDefaultPopulation()
	VehicleRevertToDefaultAmbient()
	RaceDeleteRacers()
	RaceCleanup()
	shared.gPlayerIncapacitated = nil
	PedSetMissionCritical(gPlayer, false)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	SoundEnableSpeech_ActionTree()
	F_MakePlayerSafeForNIS(false)
	UnLoadAnimationGroup("3_G3")
	shared.gRefreshRacePosters = true
	shared.g3_R08_CurrentRace = nil
	GarageSetIsDeactivated(false)
	SoundEnableInteractiveMusic(true)
	SoundStopInteractiveStream()
	--[[
	if signedUp == true then
		for i, entity in tblPersistentEntity do
			DeletePersistentEntity(entity.poolIndex, entity.type)
		end
		if szSpecialGroupToCleanup then
			AreaLoadSpecialEntities(szSpecialGroupToCleanup, false)
		end
		VehicleRevertToDefaultAmbient()
		AreaRevertToDefaultPopulation()
		DATUnload(2)
		if tblRace.won == true then
			shared.g3_R08_CurrentRace = nil
			shared.g3_R08_LevelAttained = raceLevel
		end
	end
	]] -- Not present in original script
	for i, entity in tblPersistentEntity do
		DeletePersistentEntity(entity.poolIndex, entity.type)
	end
	if szSpecialGroupToCleanup then
		AreaLoadSpecialEntities(szSpecialGroupToCleanup, false)
	end
	VehicleRevertToDefaultAmbient()
	AreaRevertToDefaultPopulation()
	DATUnload(2)
	if tblRace.won == true then
		shared.g3_R08_CurrentRace = nil
		shared.g3_R08_LevelAttained = raceLevel
	end
end

function main() -- ! Modified
	LoadAnimationGroup("3_G3")
	while not shared.g3_R08_CurrentRace do
		Wait(0)
	end
	DisablePOI(true, true)
	PedSetMissionCritical(gPlayer, true, cbCritPlayer)
	--[[
	if signedUp == true then
	]] -- Not present in original script
	--print("faded")
	F_InitDATLoad()
	VehicleOverrideAmbient(0, 0, 0, 0)
	AreaClearAllPeds()
	AreaOverridePopulation(4, 0, 0, 0, 0, 0, 0, 1, 1, 0, 2, 0, 0)
	AreaClearAllVehicles()
	F_NISRace(nispath, nispathlook)
	VehicleOverrideAmbient(1, 1, 0, 0)
	bWin, szFailReason, gReward = RaceControl()
	if bWin then
		StatAddToInt(179, gReward)
		MissionSucceed(false, false, false, gReward)
	else
		SoundPlayMissionEndMusic(false, 8)
		if szFailReason then
			MissionFail(false, true, szFailReason)
		else
			MinigameSetCompletion("GKART_YOULOSE", false)
			while MinigameIsShowingCompletion() do
				Wait(0)
			end
			MissionFail(false, false)
		end
	end
	--print("controlled")
	--[[
	else
		SoundPlayMissionEndMusic(false, 8)
		MissionFail()
	end
	]] -- Not present in original script
end

function F_InitDATLoad()
	if shared.g3_R08_CurrentRace == 0 then
		DATLoad("3_R08_rich.DAT", 2)
		raceLevel = 1
		nispath, nispathlook = PATH._3_R08_RICHPATHCAM, PATH._3_R08_RICHPATHCAMLOOK
	elseif shared.g3_R08_CurrentRace == 1 then
		DATLoad("2_04.DAT", 2)
		raceLevel = 2
		nispath, nispathlook = PATH._2_04_INTROPATH, PATH._2_04_INTROLOOK
	elseif shared.g3_R08_CurrentRace == 2 then
		DATLoad("3_R08_business.DAT", 2)
		raceLevel = 3
	elseif shared.g3_R08_CurrentRace == 3 then
		DATLoad("3_R08_poor.DAT", 2)
		raceLevel = 4
	elseif shared.g3_R08_CurrentRace == 4 then
		DATLoad("3_R08_school.DAT", 2)
		raceLevel = 5
	elseif shared.g3_R08_CurrentRace == 5 then
		DATLoad("3_R08_richShortA.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 6 then
		DATLoad("3_R08_richShortB.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 7 then
		DATLoad("3_R08_richShortC.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 8 then
		DATLoad("3_R08_richShortAM.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 9 then
		DATLoad("3_R08_BusShortA.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 10 then
		DATLoad("3_R08_BusShortB.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 11 then
		DATLoad("3_R08_PoorShortA.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 12 then
		DATLoad("3_R08_RichShortD.DAT", 2)
		raceLevel = 1
	elseif shared.g3_R08_CurrentRace == 13 then
		DATLoad("3_R08_BusShortC.DAT", 2)
		raceLevel = 1
		--[[
	else
		TextPrintString("ERROR: You must sign up for a race before launching mission -- Jak", 3, 2)
		signedUp = false
	]] -- Not present in original script
	end
	if shared.g3_R08_CurrentRace == 0 then
		nispath, nispathlook = PATH._3_R08_RICHPATHCAM, PATH._3_R08_RICHPATHCAMLOOK
	elseif shared.g3_R08_CurrentRace == 1 then
		nispath, nispathlook = PATH._2_04_INTROPATH, PATH._2_04_INTROLOOK
	elseif shared.g3_R08_CurrentRace == 2 then
		nispath, nispathlook = PATH._3_R08_BUSPATHCAM, PATH._3_R08_BUSPATHCAMLOOK
	elseif shared.g3_R08_CurrentRace == 3 then
		nispath, nispathlook = PATH._3_R08_POORPATHCAM, PATH._3_R08_POORPATHCAMLOOK
	elseif shared.g3_R08_CurrentRace == 4 then
		nispath, nispathlook = PATH._3_R08_SCHOOLPATHCAMLOOK, PATH._3_R08_SCHOOLPATHCAM
	else
		nispath, nispathlook = PATH._3_R08_PATHCAM, PATH._3_R08_PATHCAMLOOK
	end
	F_TableInit()
	F_MakePlayerSafeForNIS(true, false, true, false)
	SetParam_Race(tblRace)
	SetParam_Player(tblPlayer)
	SetParam_Racers(tblRacer)
	SetParam_HighlightedNodes(tblHighlightedNode)
	SetParam_Shortcuts(tblShortcut)
	RaceSetup()
	for i, entity in tblPersistentEntity do
		entity.poolIndex, entity.type = CreatePersistentEntity(entity.id, entity.x, entity.y, entity.z, entity.heading, entity.visibleArea)
	end
end

function F_NISRace(path, pathlook)
	local x, y, z = PlayerGetPosXYZ()
	F_ClearRacerWeapons(tblRacer)
	F_DeleteUnusedVehicles(x, y, z, 20)
	CameraSetWidescreen(true)
	Wait(500)
	F_RacerSpeech(tblRacer, 1)
	CameraFade(500, 1)
	CameraSetPath(path, true)
	CameraLookAtPath(pathlook, true)
	CameraSetSpeed(5, 5, 5)
	CameraLookAtPathSetSpeed(5, 5, 5)
	Wait(1200)
	F_RacerSpeech(tblRacer, 2)
	Wait(1200)
	F_RacerSpeech(tblRacer, 3)
	Wait(1000)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	CameraFade(500, 0)
	Wait(550)
	SoundStopInteractiveStream(0)
	SoundEnableInteractiveMusic(false)
	CameraReturnToPlayer()
	CameraFade(500, 1)
	Wait(1350)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
end

function F_RacerSpeech(tblOfTheRace, nRacer)
	if PedIsValid(tblOfTheRace[nRacer].id) then
		SoundPlayScriptedSpeechEvent(tblOfTheRace[nRacer].id, "TRASH_TALK_TEAM", 0, "jumbo", nil)
	end
end

function F_ClearRacerWeapons(tblOfTheRace)
	for i, entry in tblOfTheRace do
		if PedIsValid(entry.id) then
			--print("[F_ClearRacerWeapons] >> Destroying Weapons", i)
			PedClearAllWeapons(entry.id)
		end
	end
end

function cbCritPlayer()
	shared.gPlayerIncapacitated = true
	TextPrintString("", 1, 1)
end
