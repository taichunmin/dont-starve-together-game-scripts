local assets =
{
    Asset("ANIM", "anim/fish_chum.zip"),
}

local prefabs =
{
    "chumpiece",
}

local DURATION = 20

local FISH_SPAWN_DELAY = 2.5
local FISH_SPAWN_DELAY_VARIANCE = 2.5
local FISH_SPAWN_MAX_OFFSET = 8

local CHUM_PIECE_SPAWN_RADIUS = 3
local CHUM_PIECE_SPAWN_FREQUENCY = 0.5
local MAX_CHUM_PIECES = 7

local FISH_SPAWN_ATTEMPTS = 5

local EXTRA_MAX_FISH_ALLOWED = 10

local function DoDisperse(inst)
    inst.SoundEmitter:KillSound("spore_loop")
    inst.persists = false
    inst:RemoveTag("chum")
    inst:DoTaskInTime(2, inst.Remove) --anim len + 0.5 sec

    inst.AnimState:PlayAnimation("fish_chum_base_pst")
end

local function OnTimerDone(inst, data)
    if data.name == "disperse" then
        DoDisperse(inst)
    end
end

local function OnRemove(inst)
    for k, v in pairs(inst._chumpieces) do
        if k:IsValid() then
            k:Remove()
        end
    end
end

local FISHABLE_TAGS = {"oceanfish", "oceanfishable"}
local function SpawnFishSchool(inst)
    local retry = false
    local x, y, z = inst.Transform:GetWorldPosition()

    local num_fish = #TheSim:FindEntities(x, y, z, TUNING.SCHOOL_SPAWNER_FISH_CHECK_RADIUS, FISHABLE_TAGS)
    if num_fish < TUNING.SCHOOL_SPAWNER_MAX_FISH + EXTRA_MAX_FISH_ALLOWED then
        local theta = math.random() * 2 * PI
        local spawn_offset = Vector3(math.cos(theta) * FISH_SPAWN_MAX_OFFSET, 0, math.sin(theta) * FISH_SPAWN_MAX_OFFSET)

        local num_fish_spawned = TheWorld.components.schoolspawner:SpawnSchool(Vector3(x, y, z), nil, spawn_offset)
        if num_fish_spawned == nil or num_fish_spawned == 0 then
            retry = true
        end
    else
        retry = true
    end

    inst._remaining_fish_spawn_attempts = inst._remaining_fish_spawn_attempts - 1

    retry = inst._remaining_fish_spawn_attempts <= 0 and false or retry
    if retry then
        inst:DoTaskInTime(.5, SpawnFishSchool)
    else
        inst._spawn_fish_school_task = nil
    end
end

local function OnPieceRemoved(piece)
    local chum_aoe = piece._source
    if chum_aoe ~= nil then
        chum_aoe._chumpieces[piece] = nil
        chum_aoe._num_chumpieces = chum_aoe._num_chumpieces - 1

        if chum_aoe.persists then
            chum_aoe:_spawn_chum_piece_fn()
        end
    end
end

local function SpawnChumPieces(inst)
    if inst._num_chumpieces < MAX_CHUM_PIECES then
        local x, y, z = inst.Transform:GetWorldPosition()
        local theta = math.random() * PI * 2
        local offset = math.random() * CHUM_PIECE_SPAWN_RADIUS
        local spawnx, spawnz = x + math.cos(theta) * offset, z + math.sin(theta) * offset
        if TheWorld.Map:IsOceanAtPoint(spawnx, 0, spawnz, false) then
            local piece = SpawnPrefab("chumpiece")

            piece.Transform:SetPosition(spawnx, 0, spawnz)
            piece._source = inst
            inst._chumpieces[piece] = true
            inst._num_chumpieces = inst._num_chumpieces + 1

            piece:ListenForEvent("onremove", OnPieceRemoved)
        end
    end
end

local function OnSave(inst, data)
    if inst._remaining_fish_spawn_attempts ~= nil and inst._remaining_fish_spawn_attempts > 0 then
        data.remaining_fish_spawn_attempts = inst._remaining_fish_spawn_attempts
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.remaining_fish_spawn_attempts ~= nil and data.remaining_fish_spawn_attempts > 0 then
            inst._remaining_fish_spawn_attempts = data.remaining_fish_spawn_attempts
        else
            if inst._spawn_fish_school_task ~= nil then
                inst._spawn_fish_school_task:Cancel()
                inst._spawn_fish_school_task = nil
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fish_chum")
    inst.AnimState:SetBuild("fish_chum")
    inst.AnimState:PlayAnimation("fish_chum_base_pre")
    -- inst.AnimState:SetTime(19 * FRAMES)
    inst.AnimState:PushAnimation("fish_chum_base_idle", true)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("chum")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._remaining_fish_spawn_attempts = FISH_SPAWN_ATTEMPTS

    inst._spawn_chum_piece_fn = SpawnChumPieces

    inst._chumpieces = {}
    inst._num_chumpieces = 0
    inst:DoPeriodicTask(CHUM_PIECE_SPAWN_FREQUENCY, SpawnChumPieces)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disperse", DURATION)

    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onremove", OnRemove)

    inst._spawn_fish_school_task = inst:DoTaskInTime(FISH_SPAWN_DELAY + math.random() * FISH_SPAWN_DELAY_VARIANCE, SpawnFishSchool)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function chumpiecefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    -- inst.entity:AddAnimState()
    -- inst.AnimState:SetBank("flint")
    -- inst.AnimState:SetBuild("flint")
    -- inst.AnimState:PlayAnimation("idle")
    -- inst.AnimState:SetMultColour(1, 0, 0, 1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("edible")
    inst.components.edible.secondaryfoodtype = FOODTYPE.MEAT

    return inst
end

return Prefab("chum_aoe", fn, assets, prefabs),
    Prefab("chumpiece", chumpiecefn)
