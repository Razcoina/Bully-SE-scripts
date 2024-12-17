--[[ Changed to this file:
	* Added one local variable
	* Modified value of one local variable
	* Modified function F_IntroCinematic, may require testing
	* Modified function F_EndIntroCinematic, may require testing
	* Modified function F_RunMinigameLoop, may require testing
	* Modified function F_MinigameFinished, may require testing
]]

local nCurrentClass
local bStageLoaded = false
local missionSuccess = false
local L3_1 = 0 -- ! Cannot recover original name
local nCurrentQuestion = 1
local QT_HIGHEST = 0
local QT_LOWEST = 1
local QT_FASTEST = 2
local QT_SLOWEST = 3
local QT_TALLEST = 4
local QT_SHORTEST = 5
local QT_FATTEST = 6
local QT_THINNEST = 7
local QT_DIFFERENCE = 8
local QT_TRIANGLES = 9
local QT_CIRCLES = 10
local QT_SQUARES = 11
local QT_LONG = 12
local QT_SHORT = 13
local QT_EQUATION = 14
local TEX_CIRCLE = 2
local TEX_SQUARE = 3
local TEX_TRIANGL01 = 4
local TEX_TRIANGL02 = 5
local TEX_TRIANGL03 = 6
local TEX_TRIANGL04 = 7
local TEX_TRIANGL05 = 8
local TEX_TRIANGL06 = 9
local TEX_HEIGHT_BARN = 10
local TEX_HEIGHT_BIRDHOUSE = 11
local TEX_HEIGHT_CATHEDRAL = 12
local TEX_HEIGHT_DOGHOUSE = 13
local TEX_HEIGHT_EIFFLTOWER = 14
local TEX_HEIGHT_HOUSE = 15
local TEX_HEIGHT_MAILBOX = 16
local TEX_HEIGHT_PHONEBOOTH = 17
local TEX_HEIGHT_PYRAMID = 18
local TEX_HEIGHT_SKYSCRAPER = 19
local TEX_HEIGHT_TENT = 20
local TEX_HEIGHT_TOMBSTONE = 21
local TEX_SIZE_AMOEBA = 22
local TEX_SIZE_ANT = 23
local TEX_SIZE_BASKETBALL = 24
local TEX_SIZE_BRIDGE = 25
local TEX_SIZE_CHAIR = 26
local TEX_SIZE_DUMPTRUCK = 27
local TEX_SIZE_FRUITBASKET = 28
local TEX_SIZE_KCAR = 29
local TEX_SIZE_KEY = 30
local TEX_SIZE_MOSQUITO = 31
local TEX_SIZE_SATURN = 32
local TEX_SIZE_SHIP = 33
local TEX_SIZE_SLICEPIZZA = 34
local TEX_SIZE_THUMBTACK = 35
local TEX_SIZE_WATERMELON = 36
local TEX_SIZE_WHALE = 37
local TEX_SPEED_BIKE = 38
local TEX_SPEED_GOLFCART = 39
local TEX_SPEED_LAWNMOW = 40
local TEX_SPEED_PERSON = 41
local TEX_SPEED_PLANE = 42
local TEX_SPEED_PUPPY = 43
local TEX_SPEED_RACECAR = 44
local TEX_SPEED_ROCKET = 45
local TEX_SPEED_SLOTH = 46
local TEX_SPEED_SNAIL = 47
local TEX_SPEED_TRAIN = 48
local TEX_SPEED_TURTLE = 49
local TEX_SPEED_WORM = 50
local tblMath01 = {
	{
		questionType = QT_EQUATION,
		title = "3 + 4 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"8",
			"7",
			"6",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "50 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"5x9",
			"2+38",
			"5+45",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "6x6 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"30",
			"48",
			"36",
			nil,
			nil
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL02,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"3",
			"1",
			"4",
			"2",
			nil
		}
	},
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SIZE_FRUITBASKET,
			TEX_SIZE_SATURN,
			TEX_SIZE_MOSQUITO,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "12 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"3x6",
			"17-6",
			"20-8",
			nil,
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SIZE_MOSQUITO,
			TEX_SIZE_FRUITBASKET,
			TEX_SIZE_SATURN,
			nil,
			nil
		}
	},
	{
		questionType = QT_LOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"230",
			"203",
			"320",
			"220",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "8 + 3 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			"12",
			"9",
			"11",
			"13",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1/2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"0.5",
			"0.25",
			"0.05",
			nil,
			nil
		}
	},
	{
		questionType = QT_SLOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SPEED_ROCKET,
			TEX_SPEED_BIKE,
			TEX_SPEED_SLOTH,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "120 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"8x12",
			"70+30",
			"3x40",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "7 - 5 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"2",
			"4",
			"6",
			"9",
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_SPEED_BIKE,
			TEX_SIZE_DUMPTRUCK,
			TEX_SPEED_PERSON,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "99 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"24x4",
			"9+11",
			"11x9",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "12 + ? = 21",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			"11",
			"7",
			"9",
			"8",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "35 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"29+7",
			"7x5",
			"12x3",
			"41-7",
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_SPEED_ROCKET,
			TEX_SPEED_WORM,
			TEX_SPEED_RACECAR,
			TEX_SIZE_WATERMELON,
			nil,
			nil
		}
	},
	{
		questionType = QT_SQUARES,
		title = nil,
		texture = nil,
		numItems = 5,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"3",
			"5",
			"4",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0.5x34 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"15",
			"17",
			"135",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "15 - 6 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"9",
			"7",
			"11",
			"8",
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SPEED_WORM,
			TEX_SPEED_GOLFCART,
			TEX_SPEED_RACECAR,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0.5 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"1/5",
			"1/2",
			"2/5",
			nil,
			nil
		}
	},
	{
		questionType = QT_TALLEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_BIRDHOUSE,
			TEX_HEIGHT_PYRAMID,
			TEX_SIZE_CHAIR,
			nil,
			nil,
			nil
		}
	},
	{
		questionType = QT_HIGHEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			"67",
			"77",
			"79",
			"66",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "7 + 3 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"10",
			"11",
			"9",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "24 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"12+8",
			"12x3",
			"27-4",
			"12x2",
			nil
		}
	}
}
local tblMath02 = {
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			TEX_SIZE_WATERMELON,
			TEX_SIZE_WHALE,
			TEX_SIZE_DUMPTRUCK,
			nil,
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			TEX_SPEED_SLOTH,
			TEX_HEIGHT_PHONEBOOTH,
			TEX_SIZE_BRIDGE,
			nil,
			nil
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL03,
		numItems = nil,
		numSelections = 5,
		correctSelect = 5,
		selections = {
			"1",
			"2",
			"4",
			"6",
			"3"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1500 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"15x10",
			"30x50",
			"3x50",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "18 - ? = 5",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"13",
			"9",
			"12",
			"8",
			nil
		}
	},
	{
		questionType = QT_TALLEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_SIZE_AMOEBA,
			TEX_HEIGHT_EIFFLTOWER,
			TEX_HEIGHT_MAILBOX,
			nil,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "100 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"6x15",
			"25x4",
			"50x1",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"2x2",
			"9-7",
			"1+2",
			nil,
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			TEX_HEIGHT_CATHEDRAL,
			TEX_SIZE_FRUITBASKET,
			TEX_SIZE_WHALE,
			nil,
			nil,
			nil
		}
	},
	{
		questionType = QT_HIGHEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			"107.7",
			"701.1",
			"771",
			"177.2",
			nil
		}
	},
	{
		questionType = QT_SHORTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_BARN,
			TEX_HEIGHT_BIRDHOUSE,
			TEX_HEIGHT_SKYSCRAPER,
			nil,
			nil
		}
	},
	{
		questionType = QT_SLOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_SPEED_PUPPY,
			TEX_SPEED_TURTLE,
			TEX_SPEED_TRAIN,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1/4 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"0.75",
			"0.4",
			"0.25",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "8 + 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"9",
			"10",
			"11",
			"12",
			nil
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL02,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"3",
			"1",
			"4",
			"2",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "144 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"14x11",
			"12x12",
			"20x7",
			nil,
			nil
		}
	},
	{
		questionType = QT_SHORTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_PHONEBOOTH,
			TEX_HEIGHT_BIRDHOUSE,
			TEX_HEIGHT_SKYSCRAPER,
			TEX_HEIGHT_HOUSE,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "55 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"1x55",
			"2x5",
			"15+50",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "13 - ? = 5",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"8",
			"9",
			"7",
			"4",
			nil
		}
	},
	{
		questionType = QT_CIRCLES,
		title = nil,
		texture = nil,
		numItems = 6,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"7",
			"6",
			"5",
			nil,
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_SIZE_SHIP,
			TEX_SPEED_PLANE,
			TEX_SIZE_MOSQUITO,
			TEX_SPEED_LAWNMOW,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0.75 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"3/4",
			"1/3",
			"2/3",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "15 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"8+6",
			"6x3",
			"3x5",
			nil,
			nil
		}
	},
	{
		questionType = QT_LOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"677",
			"776",
			"796",
			"799",
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			TEX_SIZE_DUMPTRUCK,
			TEX_SIZE_KEY,
			TEX_SIZE_CHAIR,
			nil,
			nil,
			nil
		}
	}
}
local tblMath03 = {
	{
		questionType = QT_EQUATION,
		title = "1Kg = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"100g",
			"10g",
			"1000g",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "36 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"6x6",
			"7x5",
			"32+3",
			nil,
			nil
		}
	},
	{
		questionType = QT_TALLEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_BARN,
			TEX_HEIGHT_CATHEDRAL,
			TEX_HEIGHT_TOMBSTONE,
			TEX_HEIGHT_DOGHOUSE,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0.5 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"1/5",
			"1/2",
			"2/5",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "360 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"180x2",
			"60x4",
			"358-2",
			nil,
			nil
		}
	},
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			TEX_SIZE_SLICEPIZZA,
			TEX_HEIGHT_PYRAMID,
			TEX_SIZE_SHIP,
			nil,
			nil
		}
	},
	{
		questionType = QT_SLOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			TEX_SPEED_PUPPY,
			TEX_SPEED_ROCKET,
			TEX_SPEED_BIKE,
			TEX_SPEED_SNAIL,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "16 + 10 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"26",
			"22",
			"24",
			"28",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "2 + 9 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"11",
			"13",
			"14",
			"12",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "400 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"25x20",
			"19x12",
			"380+30",
			"20x20",
			nil
		}
	},
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SPEED_RACECAR,
			TEX_SPEED_LAWNMOW,
			TEX_SPEED_SNAIL,
			nil,
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			TEX_SIZE_BRIDGE,
			TEX_SIZE_SHIP,
			TEX_SIZE_SATURN,
			nil,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "10 - 10 + 7 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"6",
			"12",
			"7",
			"11",
			"8"
		}
	},
	{
		questionType = QT_LOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"3224",
			"2234",
			"2243",
			"4223",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "6 + 5 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"12",
			"9",
			"8",
			"11",
			"13"
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL05,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"5",
			"3",
			"4",
			"7",
			"6"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "6/18 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"0.5",
			"1/3",
			"0.666",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1g = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 3,
		selections = {
			"0.1Kg",
			"0.01Kg",
			"0.001Kg",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "17 - ? = 11",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"5",
			"6",
			"8",
			"9",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "2 + 7 + 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"8",
			"10",
			"7",
			"11",
			nil
		}
	},
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			TEX_SIZE_SHIP,
			TEX_SIZE_WHALE,
			TEX_SIZE_SATURN,
			nil,
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_SIZE_WHALE,
			TEX_SPEED_LAWNMOW,
			TEX_HEIGHT_TOMBSTONE,
			TEX_SIZE_AMOEBA,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "190 - ? = 30",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"120",
			"80",
			"90",
			"160",
			nil
		}
	},
	{
		questionType = QT_SQUARES,
		title = nil,
		texture = nil,
		numItems = 7,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"11",
			"10",
			"7",
			"9",
			"8"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "13 + 8 + 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"20",
			"22",
			"23",
			"19",
			"18"
		}
	}
}
local tblMath04 = {
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			TEX_SPEED_PERSON,
			TEX_SPEED_SLOTH,
			TEX_SPEED_GOLFCART,
			TEX_SPEED_PLANE,
			nil
		}
	},
	{
		questionType = QT_LOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"0.12",
			"0.09",
			"0.2",
			"0.17",
			nil
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL05,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"5",
			"3",
			"4",
			"7",
			"6"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "49 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"7x8",
			"57-8",
			"7x6",
			"32+16",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		--[[
		title = "0.625Kg = ?",
		]] -- Changed to:
		title = ".625Kg = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"62.5g",
			"625g",
			"6.25g",
			nil,
			nil
		}
	},
	{
		questionType = QT_CIRCLES,
		title = nil,
		texture = nil,
		numItems = 8,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"8",
			"6",
			"5",
			"7",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"0x125",
			"24-42",
			"2/4",
			nil,
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_HEIGHT_SKYSCRAPER,
			TEX_SPEED_ROCKET,
			TEX_SIZE_SLICEPIZZA,
			TEX_SPEED_SNAIL,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "6 + 8 + ? = 17",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 2,
		selections = {
			"5",
			"3",
			"7",
			"4",
			"8"
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_SIZE_MOSQUITO,
			TEX_SIZE_AMOEBA,
			TEX_SIZE_ANT,
			TEX_SPEED_SNAIL,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1/4 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"0.75",
			"0.4",
			"0.5",
			"0.25",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "13 + 8 + 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"20",
			"22",
			"23",
			"19",
			"18"
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_SPEED_PLANE,
			TEX_SPEED_ROCKET,
			TEX_SPEED_TRAIN,
			TEX_SIZE_KCAR,
			nil,
			nil
		}
	},
	{
		questionType = QT_SHORTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_PHONEBOOTH,
			TEX_HEIGHT_BIRDHOUSE,
			TEX_HEIGHT_SKYSCRAPER,
			TEX_HEIGHT_HOUSE,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "15 - ? = 6",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"7",
			"8",
			"5",
			"9",
			"6"
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL06,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"4",
			"3",
			"1",
			"2",
			nil
		}
	},
	{
		questionType = QT_SLOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_SPEED_PUPPY,
			TEX_SPEED_TURTLE,
			TEX_SPEED_TRAIN,
			TEX_SPEED_BIKE,
			nil
		}
	},
	{
		questionType = QT_SQUARES,
		title = nil,
		texture = nil,
		numItems = 7,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"11",
			"10",
			"7",
			"9",
			"8"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "3000 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			"20x40",
			"15x12",
			"50x60",
			"5x60",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1 + 4 - 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"4",
			"5",
			"3",
			"6",
			"2"
		}
	},
	{
		questionType = QT_THINNEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_SIZE_BASKETBALL,
			TEX_SIZE_KEY,
			TEX_SIZE_KCAR,
			TEX_SPEED_SLOTH,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "17 + 8 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 2,
		selections = {
			"22",
			"25",
			"28",
			"21",
			"23"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1200 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"20x60",
			"40x32",
			"50x20",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "48500g = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			"48.5Kg",
			"485Kg",
			"4.85Kg",
			nil,
			nil
		}
	}
}
local tblMath05 = {
	{
		questionType = QT_EQUATION,
		title = "13 + 8 + 2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"20",
			"22",
			"23",
			"19",
			"18"
		}
	},
	{
		questionType = QT_LOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"3224",
			"2234",
			"2243",
			"4223",
			nil
		}
	},
	{
		questionType = QT_SHORTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 2,
		selections = {
			TEX_HEIGHT_HOUSE,
			TEX_HEIGHT_DOGHOUSE,
			TEX_HEIGHT_TENT,
			TEX_HEIGHT_BARN,
			TEX_HEIGHT_PHONEBOOTH
		}
	},
	{
		questionType = QT_EQUATION,
		title = "2 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 2,
		selections = {
			"2x2",
			"9-7",
			"1+2",
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "689g = ?",
		texture = nil,
		numItems = nil,
		numSelections = 3,
		correctSelect = 1,
		selections = {
			".689Kg",
			"6.89Kg",
			"68.9Kg",
			nil,
			nil
		}
	},
	{
		questionType = QT_SQUARES,
		title = nil,
		texture = nil,
		numItems = 8,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"11",
			"9",
			"10",
			"8",
			"7"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "? + 6 - 3 = 11",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 2,
		selections = {
			"9",
			"8",
			"11",
			"6",
			"5"
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			TEX_SPEED_LAWNMOW,
			TEX_SPEED_PERSON,
			TEX_SPEED_PLANE,
			TEX_SIZE_SLICEPIZZA,
			nil,
			nil
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL04,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"6",
			"3",
			"1",
			"4",
			"7"
		}
	},
	{
		questionType = QT_HIGHEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 5,
		selections = {
			"3.83",
			"33.0",
			"8.33",
			"3.1",
			"33.8"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "255 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"8x6",
			"25.1x10",
			"25x10.1",
			"5x51",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "0.75 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 4,
		selections = {
			"4/3",
			"1/3",
			"2/3",
			"3/4",
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_SIZE_BRIDGE,
			TEX_SIZE_SHIP,
			TEX_SIZE_ANT,
			TEX_HEIGHT_PYRAMID,
			nil,
			nil
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_SPEED_PLANE,
			TEX_SPEED_PERSON,
			TEX_SIZE_KCAR,
			TEX_SIZE_ANT,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1.25 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"4/3",
			"1/3",
			"0.45x3",
			"5/4",
			"3/4"
		}
	},
	{
		questionType = QT_SLOWEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			TEX_HEIGHT_PYRAMID,
			TEX_SIZE_ANT,
			TEX_SIZE_AMOEBA,
			TEX_SIZE_SATURN,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "12 + 6 - 11 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 4,
		selections = {
			"9",
			"6",
			"10",
			"7",
			"5"
		}
	},
	{
		questionType = QT_EQUATION,
		title = "3.14 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 3,
		selections = {
			"3+14",
			"31x0.4",
			"31.4x0.1",
			"1.7x2",
			"34.1x0.2"
		}
	},
	{
		questionType = QT_TRIANGLES,
		title = nil,
		texture = TEX_TRIANGL05,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			"5",
			"7",
			"4",
			"6",
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "7 + ? + 3 = 17",
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 1,
		selections = {
			"7",
			"6",
			"10",
			"11",
			"8"
		}
	},
	{
		questionType = QT_FASTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 2,
		selections = {
			TEX_SPEED_PUPPY,
			TEX_SPEED_ROCKET,
			TEX_SPEED_BIKE,
			TEX_SPEED_SNAIL,
			nil
		}
	},
	{
		questionType = QT_SHORTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 3,
		selections = {
			TEX_HEIGHT_BARN,
			TEX_HEIGHT_CATHEDRAL,
			TEX_HEIGHT_TOMBSTONE,
			TEX_HEIGHT_EIFFLTOWER,
			nil
		}
	},
	{
		questionType = QT_FATTEST,
		title = nil,
		texture = nil,
		numItems = nil,
		numSelections = 5,
		correctSelect = 1,
		selections = {
			TEX_HEIGHT_CATHEDRAL,
			TEX_SIZE_FRUITBASKET,
			TEX_SIZE_WHALE,
			TEX_SIZE_SLICEPIZZA,
			TEX_SPEED_SLOTH,
			nil,
			nil
		}
	},
	{
		questionType = QT_EQUATION,
		title = "1/8 = ?",
		texture = nil,
		numItems = nil,
		numSelections = 4,
		correctSelect = 1,
		selections = {
			"0.125",
			"1/4x2",
			"0.520",
			"0.25",
			nil
		}
	}
}
local tblClasses = {}
tblClasses[1] = {
	questionTable = tblMath01,
	timer = 90,
	passPercent = 70,
	timeIncr = 0,
	timeDecr = 0,
	grade = 1
}
tblClasses[2] = {
	questionTable = tblMath02,
	timer = 80,
	passPercent = 75,
	timeIncr = 0,
	timeDecr = 0,
	grade = 2
}
tblClasses[3] = {
	questionTable = tblMath03,
	timer = 70,
	passPercent = 80,
	timeIncr = 0,
	timeDecr = 0,
	grade = 3
}
tblClasses[4] = {
	questionTable = tblMath04,
	timer = 70,
	passPercent = 85,
	timeIncr = 0,
	timeDecr = 0,
	grade = 4
}
tblClasses[5] = {
	questionTable = tblMath05,
	timer = 80,
	passPercent = 90,
	timeIncr = 0,
	timeDecr = 0,
	grade = 5
}
local gInsultModels = {
	70,
	66,
	69,
	142,
	139
}

function F_RunQuestion(question)
	if question.questionType == QT_EQUATION then
		ClassMathSetEquation(question.title, question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_HIGHEST then
		ClassMathSetHighest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_LOWEST then
		ClassMathSetLowest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_DIFFERENCE then
		ClassMathSetDifference(question.numSelections, question.correctSelect, question.selections[1], question.selections[2])
	elseif question.questionType == QT_TRIANGLES then
		ClassMathSetTriangles(question.texture, question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_TALLEST then
		ClassMathSetTallest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_SHORTEST then
		ClassMathSetShortest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_FASTEST then
		ClassMathSetFastest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_SLOWEST then
		ClassMathSetSlowest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_FATTEST then
		ClassMathSetFattest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_THINNEST then
		ClassMathSetThinnest(question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_SQUARES then
		ClassMathSetSquares(question.numItems, question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	elseif question.questionType == QT_CIRCLES then
		ClassMathSetCircles(question.numItems, question.numSelections, question.correctSelect, question.selections[1], question.selections[2], question.selections[3], question.selections[4], question.selections[5])
	end
end

function MissionSetup()
	DATLoad("ClassLoc.DAT", 2)
	DATLoad("C9.DAT", 2)
	DATInit()
	MissionDontFadeIn()
	SoundEnableInteractiveMusic(false)
	AreaTransitionPoint(15, POINTLIST._C9_PSTART, nil, true)
	MinigameCreate("MATH", false)
	while not MinigameIsReady() do
		--print("STUCK MISSION SETUP")
		Wait(0)
	end
	PlayerSetMinPunishmentPoints(0)
	HUDSaveVisibility()
	HUDClearAllElements()
	ToggleHUDComponentVisibility(42, true)
	Wait(2)
	SoundStopPA()
	SoundStopCurrentSpeechEvent()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	SoundDisableSpeech_ActionTree()
end

function main()
	while not bStageLoaded do
		Wait(0)
		print("STUCK HERE")
	end
	F_MakePlayerSafeForNIS(true)
	PlayerWeaponHudLock(true)
	PlayerSetControl(0)
	VehicleOverrideAmbient(0, 0, 0, 0)
	AreaClearAllPeds()
	AreaSetDoorLocked("DT_CLASSR_DOORL", true)
	LoadActionTree("Act/Conv/C9.act")
	LoadAnimationGroup("NPC_Adult")
	LoadAnimationGroup("MINI_React")
	LoadAnimationGroup("UBO")
	LoadAnimationGroup("ENGLISHCLASS")
	LoadAnimationGroup("SBULL_X")
	F_IntroCinematic()
end

function F_IntroCinematic() -- ! Modified
	PedSetPosPoint(gPlayer, POINTLIST._C9_PSTART, 1)
	hattrick = PedCreatePoint(61, POINTLIST._C9_HATTRICK)
	student1 = PedCreatePoint(3, POINTLIST._C9_STUDENTS, 1)
	student2 = PedCreatePoint(35, POINTLIST._C9_STUDENTS, 2)
	student3 = PedCreatePoint(66, POINTLIST._C9_STUDENTS, 3)
	Wait(1500)
	GeometryInstance("kidchair", true, -560.141, 322.159, -1.48522, false)
	PedIgnoreStimuli(hattrick, true)
	PedIgnoreStimuli(student1, true)
	PedIgnoreStimuli(student2, true)
	PedIgnoreStimuli(student3, true)
	PedSetAsleep(hattrick, true)
	CameraSetWidescreen(true)
	Wait(1000)
	--[[
	PedFaceHeading(hattrick, 0, 0)
	]] -- Removed this
	if not F_CheckIfPrefect() then
		CameraFade(1000, 1)
	end
	CameraSetXYZ(-562.5938, 323.06516, -0.722657, -562.10114, 322.19528, -0.698963)
	PedFollowPath(student1, PATH._C9_STUDENT1, 0, 0)
	PedFollowPath(student2, PATH._C9_STUDENT2, 0, 0)
	PedFollowPath(student3, PATH._C9_STUDENT3, 0, 0)
	PedStop(gPlayer)
	PedIgnoreStimuli(gPlayer, true)
	PedFollowPath(gPlayer, PATH._C9_PLAYERPATH, 0, 0)
	PedPathNodeReachedDistance(gPlayer, 0.5)
	if nCurrentClass == 1 then
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 1, "large")
	elseif nCurrentClass == 2 then
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 2, "large")
	elseif nCurrentClass == 3 then
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 3, "large")
	elseif nCurrentClass == 4 then
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 4, "large")
	elseif nCurrentClass == 5 then
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 5, "large")
	end
	Wait(5000)
	PedSetPosPoint(gPlayer, POINTLIST._C9_PLAYERSIT, 1)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	Wait(1000)
	CameraSetFOV(40)
	CameraSetXYZ(-560.63806, 321.6818, -1.018964, -560.3866, 322.64926, -0.993759)
	PedSetActionNode(gPlayer, "/Global/C9/PlayerSit", "Act/Conv/C9.act")
	Wait(1800)
	CameraFade(500, 0)
	Wait(600)
	F_CleanPrefect()
	CameraFade(0, 1)
	F_EndIntroCinematic()
end

function F_EndIntroCinematic() -- ! Modified
	MinigameStart()
	ClassMathSetNumQuestions(getTableSize(tblClasses[nCurrentClass].questionTable))
	F_RunQuestion(tblClasses[nCurrentClass].questionTable[nCurrentQuestion])
	--[[
	SoundPlayStream("MS_MathClass.rsm", 0.85, 0, 0)
	]] -- Changed to:
	SoundPlayStream("MS_MathClass.rsm", 0.15, 0, 0)
	F_InitRules()
end

function F_InitRules()
	if tblClasses[nCurrentClass].timer then
		if tblClasses[nCurrentClass].timeIncr then
			ClassMathSetTimer(tblClasses[nCurrentClass].timer, tblClasses[nCurrentClass].timeIncr)
		else
			ClassMathSetTimer(tblClasses[nCurrentClass].timer, 0)
		end
	end
	if tblClasses[nCurrentClass].passPercent then
		ClassMathSetScorePercentage(tblClasses[nCurrentClass].passPercent)
	end
	local dif = (100 - tblClasses[nCurrentClass].passPercent) / 2
	ClassMathSetScoreMsg(tblClasses[nCurrentClass].passPercent, "MGMA_SCMSG1")
	ClassMathSetScoreMsg(tblClasses[nCurrentClass].passPercent + dif, "MGMA_SCMSG2")
	ClassMathSetScoreMsg(100, "MGMA_SCMSG3")
	ClassMathSetTrigFunc(15, F_ChangeMusic)
	F_RunMinigameLoop()
end

function F_RunMinigameLoop() -- ! Modified
	CameraSetWidescreen(false)
	MinigameEnableHUD(true)
	Wait(1000)
	CameraSetFOV(30)
	CameraSetXYZ(-561.0058, 321.40848, -0.828353, -560.6053, 322.3187, -0.724545)
	while MinigameIsActive() do
		Wait(0)
		if ClassMathGetScorePercentage() >= tblClasses[nCurrentClass].passPercent then
			missionSuccess = true
		end
		if ClassMathValidAnswer() == true then
			SoundPlay2D("MathCorrect")
			Wait(100)
		elseif ClassMathInvalidAnswer() == true then
			ClassMathSubtractTime(tblClasses[nCurrentClass].timeDecr)
			SoundPlay2D("MathIncorrect")
			Wait(100)
			--[[
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 12, "large")
			]] -- Changed to:
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 12, "generic", true)
		end
		if ClassMathAnswerGiven() == true then
			nCurrentQuestion = nCurrentQuestion + 1
			if nCurrentQuestion <= getTableSize(tblClasses[nCurrentClass].questionTable) then
				F_RunQuestion(tblClasses[nCurrentClass].questionTable[nCurrentQuestion])
			else
				ClassMathFinished()
			end
		end
		if gStartedLoop and GetTimer() - gStartedLoop > 13000 then
			SoundLoopPlay2D("TimeWarningLOOP", false)
		end
	end
	F_MinigameFinished()
end

function getTableSize(tbl)
	count = 0
	for i, entry in tbl do
		count = count + 1
	end
	return count
end

function F_MinigameFinished() -- ! Modified
	MinigameEnableHUD(false)
	CameraSetWidescreen(true)
	PedFaceObject(gPlayer, hattrick, 2, 0)
	PedSetActionNode(gPlayer, "/Global/C9/PlayerSit/PlayerStand", "Act/Conv/C9.act")
	while PedIsPlaying(gPlayer, "/Global/C9/PlayerSit/PlayerStand", true) do
		Wait(0)
	end
	--[[
	SoundStopCurrentSpeechEvent(hattrick)
	]] -- Removed this
	if missionSuccess then
		if nCurrentClass == 1 then
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 6, "large", true)
		elseif nCurrentClass == 2 then
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 7, "large", true)
		elseif nCurrentClass == 3 then
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 8, "large", true)
		elseif nCurrentClass == 4 then
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 9, "large", true)
		elseif nCurrentClass == 5 then
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 6, "large", true)
		end
		PedSetActionNode(gPlayer, "/Global/C9/PlayerVictory/PlayerVictory03", "Act/Conv/C9.act")
	else
		--[[
		SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 11, "large", true)
		]]                         -- Moved this inside the following if:
		if nCurrentClass == 1 then -- Adde this
			SoundPlayScriptedSpeechEvent(hattrick, "ClassMath", 11, "large", true)
		end
		SoundPlay2D("Fatigued01")
		PedSetActionNode(gPlayer, "/Global/C9/PlayerFail", "Act/Conv/C9.act")
		PedSetActionNode(hattrick, "/Global/C9/TeacherDisgust", "Act/Conv/C9.act")
	end
	SoundLoopPlay2D("TimeWarningLOOP", false)
	if missionSuccess and not bIsRepeatable then
		PlayerSetGrade(3, tblClasses[nCurrentClass].grade)
	end
	if not bIsRepeatable then
		if 0 < tblClasses[nCurrentClass].grade then
			MinigameSetGrades(3, tblClasses[nCurrentClass].grade - 1)
		else
			MinigameSetGrades(3, tblClasses[nCurrentClass].grade)
		end
		SoundFadeoutStream()
		if missionSuccess then
			SoundPlayMissionEndMusic(true, 9)
		else
			SoundPlayMissionEndMusic(false, 9)
		end
		while MinigameIsShowingGrades() do
			Wait(0)
		end
		if missionSuccess and nCurrentClass == 5 then
			CameraFade(500, 0)
			Wait(500)
			CameraSetXYZ(-560.21686, 320.88766, -0.310778, -560.04767, 319.90237, -0.288369)
			SoundStopCurrentSpeechEvent(hattrick)
			PedStop(hattrick)
			PedClearObjectives(hattrick)
			PedFaceHeading(hattrick, 0, 0)
			CameraFade(500, 1)
			Wait(500)
			F_PlaySpeechAndWait(hattrick, "ClassMath", 10, "large")
		end
	end
	Wait(1000)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	if missionSuccess then
		if not bIsRepeatable then
			F_EndCinematic()
		end
		MissionSucceed(false, true, false)
	else
		SoundPlayMissionEndMusic(false, 9)
		MissionFail(true, false)
	end
	CameraReturnToPlayer()
	CameraReset()
end

function F_EndCinematic()
	local victoryAnim, unlockText, unlockTextRoom
	if nCurrentClass == 1 then
		ClothingGivePlayer("SP_Einstein", 0)
		victoryAnim = "/Global/C9/PlayerVictory/"
		unlockText = "MGMA_Unlock01"
	elseif nCurrentClass == 2 then
		ClothingGivePlayer("SP_MathShirt", 1)
		victoryAnim = "/Global/C9/PlayerVictory/Unlocks/SuccessMed1"
		unlockText = "MGMA_Unlock02"
	elseif nCurrentClass == 3 then
		ClothingGivePlayer("SP_PieShirt", 1)
		victoryAnim = "/Global/C9/PlayerVictory/Unlocks/SuccessHi2"
		unlockText = "MGMA_Unlock03"
	elseif nCurrentClass == 4 then
		ClothingGivePlayer("SP_HipShirt", 1)
		victoryAnim = "/Global/C9/PlayerVictory/Unlocks/SuccessHi1"
		unlockText = "MGMA_Unlock04"
	elseif nCurrentClass == 5 then
		ClothingGivePlayerOutfit("NerdJimmy")
		victoryAnim = "/Global/C9/PlayerVictory/Unlocks/SuccessHi3"
		unlockText = "MGMA_Unlock05"
		unlockTextRoom = "MGMA_Unlock06"
	end
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME + 1000)
	PlayerSetControl(0)
	AreaTransitionPoint(2, POINTLIST._C9_PEND, nil, true)
	NonMissionPedGenerationDisable()
	HUDRestoreVisibility()
	PlayerWeaponHudLock(false)
	CameraAllowChange(true)
	PedSetWeaponNow(gPlayer, -1, 0)
	SoundEnableSpeech_ActionTree()
	CameraSetWidescreen(true)
	while not AreaGetVisible() == 2 do
		Wait(0)
	end
	transitioned = true
	CameraFade(1000, 1)
	Wait(1000)
	MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
	SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "speech")
	PedSetActionNode(gPlayer, victoryAnim, "Act/Conv/C9.act")
	if unlockTextRoom then
		TutorialShowMessage(unlockTextRoom, -1, true)
		Wait(3000)
	end
	while PedIsPlaying(gPlayer, victoryAnim, true) do
		Wait(0)
	end
	NonMissionPedGenerationEnable()
	TutorialRemoveMessage()
	CameraSetWidescreen(false)
	PedLockTarget(gPlayer, -1)
end

function F_CalcTime()
	initTimer = GetTimer()
	while true do
		if IsButtonPressed(0, 0) then
			endTimer = GetTimer()
			break
		end
		Wait(0)
	end
	--print("[ScottieP] --> TIMER ", endTimer - initTimer)
end

function F_SetStage(param)
	nCurrentClass = param
	bStageLoaded = true
	--print("[ScottieP] --> nCurrentClass = " .. nCurrentClass)
end

function F_SetStageRepeatable(param)
	nCurrentClass = param
	bStageLoaded = true
	bIsRepeatable = true
	--print("[ScottieP] --> nCurrentClass = " .. nCurrentClass)
end

function F_ChangeMusic()
	--print("CHANGING MUSIC")
	SoundPlay2D("TimeTransition")
	SoundLoopPlay2D("TimeWarningLOOP", true)
	gStartedLoop = GetTimer()
end

function F_CheckIfPrefect()
	if shared.bBustedClassLaunched then
		local prefectModels = {
			49,
			50,
			51,
			52
		}
		local prefectModel = prefectModels[math.random(1, 4)]
		LoadModels({ prefectModel })
		prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
		PedStop(prefect)
		PedClearObjectives(prefect)
		PedIgnoreStimuli(prefect, true)
		PedFaceObject(gPlayer, prefect, 2, 0)
		PedFaceObject(prefect, gPlayer, 3, 1, false)
		PedSetInvulnerable(prefect, true)
		PedSetPedToTypeAttitude(prefect, 3, 2)
		CameraSetXYZ(-562.8464, 317.35223, -0.673942, -563.56836, 316.66055, -0.686741)
		CameraFade(-1, 1)
		SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
		PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
		PedSetActionNode(gPlayer, "/Global/C9/PlayerFail", "Act/Conv/C9.act")
		Wait(3000)
		PedSetActionNode(gPlayer, "/Global/C9/Release", "Act/Conv/C9.act")
		shared.bBustedClassLaunched = false
		return true
	end
	return false
end

function F_CleanPrefect()
	if prefect and PedIsValid(prefect) then
		PedDelete(prefect)
	end
end

function F_Socialize(pedId, bDisableX, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 23, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 24, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 25, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 26, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 32, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 35, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 28, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 29, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 30, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 33, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 36, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 34, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 31, bDisableO)
end

function MissionCleanup()
	HUDRestoreVisibility()
	SoundRestartPA()
	SoundEnableInteractiveMusic(true)
	PlayerWeaponHudLock(false)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	SoundFadeoutStream()
	PedSetActionNode(gPlayer, "/Global/C9/Release", "Act/Conv/C9.act")
	MinigameDestroy()
	SoundStopStream()
	SoundEnableSpeech_ActionTree()
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("UBO")
	UnLoadAnimationGroup("MINI_React")
	UnLoadAnimationGroup("ENGLISHCLASS")
	UnLoadAnimationGroup("SBULL_X")
	if not transitioned then
		AreaTransitionPoint(2, POINTLIST._C9_PEND)
	end
	PedClearObjectives(gPlayer)
	PedStop(gPlayer)
	PlayerSetPunishmentPoints(0)
	F_MakePlayerSafeForNIS(false)
	if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
		PlayerSetHealth(PedGetMaxHealth(gPlayer))
	end
	PedSetFlag(gPlayer, 128, false)
	PlayerSetControl(1)
	DATUnload(2)
end
