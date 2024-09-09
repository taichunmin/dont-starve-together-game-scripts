local Mixer = require("mixer")

local amb = "set_ambience/ambience"
local cloud = "set_ambience/cloud"
local music = "set_music/soundtrack"
local voice = "set_sfx/voice"
local movement ="set_sfx/movement"
local creature ="set_sfx/creature"
local player ="set_sfx/player"
local HUD ="set_sfx/HUD"
local sfx ="set_sfx/sfx"
local slurp ="set_sfx/everything_else_muted"

--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)

TheMixer:AddNewMix("normal", 2, 1,
{
    [amb] = .8,
    [cloud] = 0,
    [music] = 1,
    [voice] = 1,
    [movement] = 1,
    [creature] = 1,
    [player] = 1,
    [HUD] = 1,
    [sfx] = 1,
    [slurp] = 1,
})

TheMixer:AddNewMix("high", 2, 3,
{
    [amb] = .2,
    [cloud] = 1,
    [music] = .5,
    [voice] = .7,
    [movement] = .7,
    [creature] = .7,
    [player] = .7,
    [HUD] = 1,
    [sfx] = .7,
    [slurp] = 1,
})

TheMixer:AddNewMix("start", 1, 0,
{
    [amb] = .8,
    [cloud] = 0,
    [music] = 1,
    [voice] = 1,
    [movement] = 1,
    [creature] = 1,
    [player] = 1,
    [HUD] = .5,
    [sfx] = 1,
    [slurp] = 1,
})

TheMixer:AddNewMix("serverpause", 0, 2147483647,
{
    [amb] = 0,
    [cloud] = 0,
    [music] = 0,
    [voice] = 0,
    [movement] = 0,
    [creature] = 0,
    [player] = 0,
    [HUD] = 1,
    [sfx] = 0,
    [slurp] = 0,
})

TheMixer:AddNewMix("pause", 1, 4,
{
    [amb] = .1,
    [cloud] = .1,
    [music] = 0,
    [voice] = 0,
    [movement] = 0,
    [creature] = 0,
    [player] = 0,
    [HUD] = .6,
    [sfx] = 0,
    [slurp] = 0,
})

TheMixer:AddNewMix("death", 1, 6,
{
    [amb] = .2,
    [cloud] = .2,
    [music] = 0,
    [voice] = 1,
    [movement] = .8,
    [creature] = .8,
    [player] = 1,
    [HUD] = 1,
    [sfx] = .8,
    [slurp] = .8,
})

TheMixer:AddNewMix("slurp", 1, 1,
{
    [amb] = .2,
    [cloud] = .2,
    [music] = .5,
    [voice] = .7,
    [movement] = .7,
    [creature] = .7,
    [player] = .7,
    [HUD] = 1,
    [sfx] = .7,
    [slurp] = 1,
})

TheMixer:AddNewMix("lobby", 2, 8,
{
    [amb] = 0,
    [cloud] = 0,
    [music] = 1,
    [voice] = 0,
    [movement] = 0,
    [creature] = 0,
    [player] = 0,
    [HUD] = .6,
    [sfx] = 0,
    [slurp] = 0,
})

TheMixer:AddNewMix("moonstorm", 2, 8,
{
    [amb] = 1,
    [cloud] = 0,
    [music] = .3,
    [voice] = .3,
    [movement] = .3,
    [creature] = .3,
    [player] = 1,
    [HUD] = 1,
    [sfx] = .3,
    [slurp] = 0,
})

--------------------------------------------------------------------------

--quagmire uses the same one as lavaarena
TheMixer:AddNewMix("lavaarena_normal", .1, 1,
{
    [amb] = .8,
    [cloud] = 0,
    [music] = 1,
    [voice] = 1,
    [movement] = 1,
    [creature] = 1,
    [player] = 1,
    [HUD] = 1,
    [sfx] = 1,
    [slurp] = 1,
})

TheMixer:AddNewMix("moonstorm", 2, 8,
{
    [amb] = 1,
    [cloud] = 0,
    [music] = .3,
    [voice] = .3,
    [movement] = .3,
    [creature] = .3,
    [player] = 1,
    [HUD] = 1,
    [sfx] = .3,
    [slurp] = 0,
})

TheMixer:AddNewMix("silence", 0, 8,
{
    [amb] = 0,
    [cloud] = 0,
    [music] = .2,
    [voice] = 0,
    [movement] = 0,
    [creature] = 0,
    [player] = 0,
    [HUD] = 0,
    [sfx] = 1,
    [slurp] = 0,
})

TheMixer:AddNewMix("flying", 2, 3,
{
    [amb] = .4,
    [cloud] = .4,
    [music] = .7,
    [voice] = .2,
    [movement] = .2,
    [creature] = .2,
    [player] = 1,
    [HUD] = 1,
    [sfx] = .2,
    [slurp] = 0,
})
