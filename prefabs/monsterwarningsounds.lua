local easing = require("easing")

local MAX_SOUND_RANGE = 30 --max distance for sound to be heard at min volume
local RANGE_BUFFER = 10 --buffer for sound to "bleed" over the monster's range

local monster_params =
{
    deerclops =
    {
        range = 40, --deerclopsspawner.lua::HASSLER_SPAWN_DIST
        levels =
        {
            {
                sound = "dontstarve/creatures/deerclops/distant",
                distance = 25,
            },
            {
                sound = "dontstarve/creatures/deerclops/distant",
                distance = 20,
            },
            {
                sound = "dontstarve/creatures/deerclops/distant",
                distance = 15,
            },
            {
                sound = "dontstarve/creatures/deerclops/distant",
                distance = 5,
            },
        }
    },
    bearger =
    {
        range = 40, --beargerspawner.lua::HASSLER_SPAWN_DIST
        levels =
        {
            {
                sound = "dontstarve_DLC001/creatures/bearger/distant",
                distance = 25,
            },
            {
                sound = "dontstarve_DLC001/creatures/bearger/distant",
                distance = 20,
            },
            {
                sound = "dontstarve_DLC001/creatures/bearger/distant",
                distance = 15,
            },
            {
                sound = "dontstarve_DLC001/creatures/bearger/distant",
                distance = 5,
            },
        },
    },
    krampus =
    {
        range = 30, --kramped.lua::SPAWN_DIST
        levels =
        {
            {
                sound = "dontstarve/creatures/krampus/beenbad_lvl1",
                distance = 0,
            },
            {
                sound = "dontstarve/creatures/krampus/beenbad_lvl2",
                distance = 0,
            },
            {
                sound = "dontstarve/creatures/krampus/beenbad_lvl3",
                distance = 0,
            },
        },
    },
}

local function PlayWarningSound(proxy, sound, range, theta, radius)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:SetParent(TheFocalPoint.entity)

    --Sound starts fading when source is out of range
    --At 2x range + RANGE_BUFFER, sound is offset by MAX_SOUND_RANGE
    local distsq = TheFocalPoint:GetDistanceSqToInst(proxy)
    if distsq > range * range then
        radius = easing.inQuad(math.sqrt(distsq) - range, radius, MAX_SOUND_RANGE - radius, range + RANGE_BUFFER)
    end

    inst.Transform:SetPosition(radius * math.cos(theta), 0, radius * math.sin(theta))
    inst.SoundEmitter:PlaySound(sound)

    inst:Remove()
end

local function OnRandDirty(inst)
    if inst._params == nil or inst._level == nil or inst._rand:value() <= 0 then
        return
    end

    --Delay one frame so that we are positioned properly before starting the effect
    --or in case we are about to be removed
    local leveldata = inst._params.levels[inst._level]
    inst:DoTaskInTime(0, PlayWarningSound, leveldata.sound, inst._params.range, inst._rand:value() / 255 * 2 * PI, leveldata.distance)
    inst._params = nil
    inst._level = nil
end

local function makewarning(params, level)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst._rand = net_byte(inst.GUID, "_rand", "randdirty")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst._params = params
            inst._level = level
            inst:ListenForEvent("randdirty", OnRandDirty)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst._rand:set(math.random(255))
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end
end

local t = {}
for monster, params in pairs(monster_params) do
    for level = 1, #params.levels do
        table.insert(t, Prefab(monster.."warning_lvl"..level, makewarning(params, level)))
    end
end
return unpack(t)
