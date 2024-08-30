
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['fortcubes\\menu\\data\\trees.lua'] = {}
NSFLua['fortcubes\\menu\\data\\trees.lua'].LAST_SECTION = ""
NSFLua['fortcubes\\menu\\data\\trees.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local trees = {
    {pos = Number3(-49, 0, 60), rot = Rotation(0, 0.2, 0), scale = 0.75},
    {pos = Number3(-42, -0.5, 65), rot = Rotation(0, -2.9, 0), scale = 0.65},
    {pos = Number3(-31, -1, 65), rot = Rotation(0, -0.3, 0), scale = 0.7},
    {pos = Number3(-22, -0.5, 70), rot = Rotation(0, -1.2, 0), scale = 0.85},
    {pos = Number3(-10, -1, 70), rot = Rotation(0, -2.9, 0), scale = 0.65},
    {pos = Number3(0, -1.5, 65), rot = Rotation(0, 0.2, 0), scale = 0.75},
    {pos = Number3(8, -0.5, 70), rot = Rotation(0, 0, 0), scale = 0.8},

    {pos = Number3(-63, -2-2, 80), rot = Rotation(0, 0.3, 0), scale = 0.75},
    {pos = Number3(-56, -2-2, 80), rot = Rotation(0, -0.3, 0), scale = 0.8},
    {pos = Number3(-45, 0-2, 80), rot = Rotation(0, -1.2, 0), scale = 0.75},
    {pos = Number3(-40, -2, 85), rot = Rotation(0, 0.2, 0), scale = 0.75},
    {pos = Number3(-29, -1-2, 85), rot = Rotation(0, 0, 0), scale = 0.7},
    {pos = Number3(-25, -0.5-2, 90), rot = Rotation(0, 0, 0), scale = 0.85},
    {pos = Number3(-16, 0-2, 90), rot = Rotation(0, -2.9, 0), scale = 0.85},
    {pos = Number3(-5, -1.5-2, 85), rot = Rotation(0, 0.2, 0), scale = 0.75},
    {pos = Number3(2, -0.5-2, 80), rot = Rotation(0, -0.3, 0), scale = 0.8},

    {pos = Number3(-17, -3, -70), rot = Rotation(0, -0.2, 0), scale = 0.75},
    {pos = Number3(-8, -4, -70), rot = Rotation(0, 1.2, 0), scale = 0.85},
    {pos = Number3(0, -2, -70), rot = Rotation(0, 0.4, 0), scale = 0.95},
    {pos = Number3(9, -3, -70), rot = Rotation(0, 2.5, 0), scale = 0.75},
    {pos = Number3(18, -3, -70), rot = Rotation(0, 0, 0), scale = 0.85},
    {pos = Number3(25, -4, -70), rot = Rotation(0, -0.2, 0), scale = 0.75},
    {pos = Number3(34, -3, -67), rot = Rotation(0, 1.2, 0), scale = 0.7},
    {pos = Number3(42, -3, -67), rot = Rotation(0, 0.4, 0), scale = 0.85},
    {pos = Number3(50, -2, -63), rot = Rotation(0, 2.5, 0), scale = 0.75},
    {pos = Number3(57, -3, -63), rot = Rotation(0, -0.2, 0), scale = 0.7},

    {pos = Number3(-17+3, -3, -80), rot = Rotation(0, -1.2, 0), scale = 0.75},
    {pos = Number3(-8+7, -3, -80), rot = Rotation(0, 2.52, 0), scale = 0.85},
    {pos = Number3(0+2, -4, -80), rot = Rotation(0, 0.1, 0), scale = 0.95},
    {pos = Number3(9+7, -3, -80), rot = Rotation(0, 2.5, 0), scale = 0.75},
    {pos = Number3(18+7, -2, -80), rot = Rotation(0, 0, 0), scale = 0.85},
    {pos = Number3(25+5, -4, -80), rot = Rotation(0, -0.2, 0), scale = 0.75},
    {pos = Number3(34+3, -3, -78), rot = Rotation(0, 1.2, 0), scale = 0.7},
    {pos = Number3(42+1, -3, -78), rot = Rotation(0, 0.4, 0), scale = 0.85},
    {pos = Number3(50+2, -4, -74), rot = Rotation(0, 0.1, 0), scale = 0.75},
    {pos = Number3(57+7, -2, -74), rot = Rotation(0, -0.2, 0), scale = 0.7},

    {pos = Number3(-35, -3, -115), rot = Rotation(0, 1.1, 0), scale = 0.75},
    {pos = Number3(-45, -5, -110), rot = Rotation(0, -0.2, 0), scale = 0.85},
    {pos = Number3(-50, 0, -100), rot = Rotation(0, 0.4, 0), scale = 0.8},
    {pos = Number3(-55, -3, -96), rot = Rotation(0, -0.4, 0), scale = 0.85},
    {pos = Number3(-60, -5, -80), rot = Rotation(0, 0, 0), scale = 0.89},
    {pos = Number3(-65, 0, -70), rot = Rotation(0, 1.1, 0), scale = 0.83},
    {pos = Number3(-70, 0, -60), rot = Rotation(0, -0, 0), scale = 0.8},
    {pos = Number3(-80, -3, -45), rot = Rotation(0, 0, 0), scale = 0.75},
    {pos = Number3(-85, 0, -30), rot = Rotation(0, 1.1, 0), scale = 0.85},
    {pos = Number3(-90, -5, -15), rot = Rotation(0, -0.2, 0), scale = 0.83},
    {pos = Number3(-100, -2, 0), rot = Rotation(0, 0, 0), scale = 0.8},
    {pos = Number3(-100, -2, 15), rot = Rotation(0, -1.1, 0), scale = 0.86},
    {pos = Number3(-100, 0, 30), rot = Rotation(0, 0.2, 0), scale = 0.85},
    {pos = Number3(-95, -2, 45), rot = Rotation(0, -0.2, 0), scale = 0.75},
    {pos = Number3(-95, -3, 60), rot = Rotation(0, 1.1, 0), scale = 0.8},
    {pos = Number3(-90, -5, 75), rot = Rotation(0, 0, 0), scale = 0.85},
    {pos = Number3(-85, -2, 90), rot = Rotation(0, 0.4, 0), scale = 0.8},
    {pos = Number3(-80, 0, 105), rot = Rotation(0, -0.2, 0), scale = 0.7},
    {pos = Number3(-80, -3, 105), rot = Rotation(0, 0, 0), scale = 0.75},

    {pos = Number3(-67, -5, -57), rot = Rotation(0, 1.1, 0), scale = 0.85},
    {pos = Number3(-76, 0, -64), rot = Rotation(0, 0.2, 0), scale = 0.85},
    {pos = Number3(-86, -3, -72), rot = Rotation(0,-0.4, 0), scale = 0.9},
    {pos = Number3(-93, 0, -66), rot = Rotation(0, 1.1, 0), scale = 0.8},
    {pos = Number3(-100, 0, -59), rot = Rotation(0, 1.1, 0), scale = 0.9},
    {pos = Number3(-115, 0, -53), rot = Rotation(0, -0, 0), scale = 0.9},
    {pos = Number3(-120, -3, -45), rot = Rotation(0, 0, 0), scale = 0.85},
    {pos = Number3(-120, -2, -33), rot = Rotation(0, 1.1, 0), scale = 0.95},
    {pos = Number3(-125, -5, -13), rot = Rotation(0, -0.2, 0), scale = 0.8},
    {pos = Number3(-130, 0, 0), rot = Rotation(0, 0, 0), scale = 0.9},
    {pos = Number3(-130, -2, 13), rot = Rotation(0, -1.1, 0), scale = 0.8},
    {pos = Number3(-130, -3, 35), rot = Rotation(0, 0.2, 0), scale = 0.95},
    {pos = Number3(-125, 0, 43), rot = Rotation(0, -0.2, 0), scale = 0.85},

    {pos = Number3(20, 0, 74), rot = Rotation(0, 0.2, 0), scale = 0.8},
    {pos = Number3(26, 0, 70), rot = Rotation(0, 0, 0), scale = 0.65},
    {pos = Number3(33, 0, 68), rot = Rotation(0, 0, 0), scale = 0.7},
    {pos = Number3(38, 0, 62), rot = Rotation(0, -1.1, 0), scale = 0.8},
    {pos = Number3(44, 0, 56), rot = Rotation(0, 0.73, 0), scale = 0.65},
    {pos = Number3(50, 0, 50), rot = Rotation(0, 0.73, 0), scale = 0.7},
    {pos = Number3(58, 0, 42), rot = Rotation(0, 0, 0), scale = 0.75},
    {pos = Number3(66, 0, 34), rot = Rotation(0, -1.1, 0), scale = 0.8},
    {pos = Number3(74, 0, 26), rot = Rotation(0, 0, 0), scale = 0.65},
    {pos = Number3(76, 0, 18), rot = Rotation(0, -0.2, 0), scale = 0.75},
    {pos = Number3(78, 0, 10), rot = Rotation(0, 1.1, 0), scale = 0.7},
    {pos = Number3(80, 0, 2), rot = Rotation(0, -1.1, 0), scale = 0.75},
    {pos = Number3(78, 0, -6), rot = Rotation(0, 0.73, 0), scale = 0.65},
    {pos = Number3(78, 0, -14), rot = Rotation(0, 0, 0), scale = 0.75},
    {pos = Number3(76, 0, -22), rot = Rotation(0, 0.2, 0), scale = 0.8},
    {pos = Number3(74, 0, -30), rot = Rotation(0, 0.73, 0), scale = 0.8},
    {pos = Number3(70, 0, -38), rot = Rotation(0, -1.1, 0), scale = 0.7},
    {pos = Number3(66, 0, -46), rot = Rotation(0, 0.73, 0), scale = 0.65},
    {pos = Number3(60, 0, -52), rot = Rotation(0, 0, 0), scale = 0.75},
    {pos = Number3(62, 0, -58), rot = Rotation(0, -1.1, 0), scale = 0.7},
}

return trees