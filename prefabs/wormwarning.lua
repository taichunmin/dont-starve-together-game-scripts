local SPAWN_DIST = 30 --hounded.lua::SPAWN_DIST

local WARNING_LEVEL_DISTANCE =
{
    SPAWN_DIST + 30,
    SPAWN_DIST + 20,
    SPAWN_DIST + 10,
    SPAWN_DIST,
}

local function PlayWarningSound(proxy, radius)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:SetParent(TheFocalPoint.entity)

    local theta = math.random() * 2 * PI

    inst.Transform:SetPosition(radius * math.cos(theta), 0, radius * math.sin(theta))
    inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/distant")

    inst:Remove()
end

local function makewarning(distance)
    return function()
        local inst = CreateEntity()

        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame in case we are about to be removed
            inst:DoTaskInTime(0, PlayWarningSound, distance)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end
end

local t = {}
for level, distance in ipairs(WARNING_LEVEL_DISTANCE) do
    table.insert(t, Prefab("wormwarning_lvl"..level, makewarning(distance)))
end
return unpack(t)