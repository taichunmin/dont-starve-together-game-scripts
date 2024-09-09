local assets = nil

local prefabs =
{
    "alterguardian_lasertrail",
}

-- Generate a shuffled list of evenly spaced points in the circle radius.
-- We factor in the inst position here because it's better than going to C++
-- for every spawn later.
local POINTS_ANGLEDIFF = PI/18
local RADIUS = math.sqrt(TUNING.ALTERGUARDIAN_PHASE3_SUMMONRSQ)
local function GeneratePoints(inst)
    local ix, _, iz = inst.Transform:GetWorldPosition()

    local angle = 0
    while angle < TWOPI do
        local x = ix + RADIUS * math.cos(angle)
        local z = iz + RADIUS * math.sin(angle)
        table.insert(inst._points, {x, z})
        angle = angle + POINTS_ANGLEDIFF
    end

    shuffleArray(inst._points)
end

-- Spawn an FX at one of the circle points, regenerating them first if necessary.
local function spawn_fx(inst)
    if #inst._points <= 0 then
        GeneratePoints(inst)
    end

    local next_point = table.remove(inst._points)
    local x, z = next_point[1], next_point[2]

    local fx = SpawnPrefab("alterguardian_lasertrail")
    fx.Transform:SetPosition(x, 0, z)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst._points = {}

    inst:DoPeriodicTask(3*FRAMES, spawn_fx)

    return inst
end

return Prefab("alterguardian_phase3circle", fn, assets, prefabs)
