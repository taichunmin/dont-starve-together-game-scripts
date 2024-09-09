local front_assets =
{
    Asset("ANIM", "anim/pollen_cloud.zip"),
}

local ocean_assets =
{
    Asset("ANIM", "anim/pollen_chum.zip"),
}

local front_prefabs =
{
    "waterplant_pollen_fx_ocean",
}

local ocean_prefabs =
{
    "chumpiece",
}

local FISH_HASTAGS = { "herd_oceanfish_small_9" }
local FISH_NOTAGS = { "FX", "DECOR", "INLIMBO" }
local FISH_RANGE = TUNING.OCEANFISH.SPRINKLER_DETECT_RANGE * 3
local function spawn_ocean_pollen(inst)
    local px, py, pz = inst.Transform:GetWorldPosition()

    local chum = SpawnPrefab("waterplant_pollen_fx_ocean")
    chum.Transform:SetPosition(px, py, pz)

    -- If we have a source flower and the number of nearby fish is low, try to release ours.
    -- This way we get the flavour of the pollen feeding the fish, but the spawning can be controlled
    -- so there's not a huge horde of sprinkler fish.
    if inst._source_flower ~= nil and inst._source_flower:IsValid() then
        local nearby_fish = TheSim:FindEntities(px, py, pz, FISH_RANGE, FISH_HASTAGS, FISH_NOTAGS)
        if nearby_fish == nil or #nearby_fish < 3 then
            inst._source_flower:PushEvent("pollenlanded")
        end
    end
end

local function front_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pollen_cloud")
    inst.AnimState:SetBuild("pollen_cloud")
    inst.AnimState:PlayAnimation("pollen")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst:AddTag("pollen")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(35 * FRAMES, spawn_ocean_pollen)

    inst:ListenForEvent("animover", inst.Remove)

    -- inst._source_flower = nil

    inst.persists = false

    return inst
end

local FADE_FRAMES = TUNING.WATERPLANT.POLLEN_FADETIME / FRAMES
local FADE_RATE = 1/FADE_FRAMES -- Fade by 100% over fade time, in frames
local function update_fade(inst)
    inst._fade_value = (inst._fade_value and inst._fade_value - FADE_RATE) or 1
    inst.AnimState:OverrideMultColour(1, 1, 1, inst._fade_value)
end

local function client_fading_dirty(inst)
    if inst._fade_task == nil then
        inst._fade_task = inst:DoPeriodicTask(FRAMES, update_fade)
    end
end

local function on_piece_removed(piece)
    local parent_aoe = piece._source
    if parent_aoe ~= nil and parent_aoe:IsValid() then
        parent_aoe._chumpieces[piece] = nil
        parent_aoe._numpieces = parent_aoe._numpieces - 1

        -- The persists test is functionally just checking if we've started dispersing;
        -- see on_timer_done
        if parent_aoe.persists then
            parent_aoe:_spawn_chum_piece()
        end
    end
end

local MAX_PIECES = 5
local function spawn_chum_piece(inst)
    if inst._numpieces < MAX_PIECES then
        local x, y, z = inst.Transform:GetWorldPosition()
        local theta = math.random() * TWOPI
        local offset = (math.sqrt(math.random()) * 2) + 2
        local spawnx, spawnz = x + math.cos(theta) * offset, z + math.sin(theta) * offset
        if TheWorld.Map:IsOceanAtPoint(spawnx, y, spawnz, false) then
            local piece = SpawnPrefab("chumpiece")

            piece.Transform:SetPosition(spawnx, 0, spawnz)
            piece._source = inst
            inst._chumpieces[piece] = true
            inst._numpieces = inst._numpieces + 1

            piece:ListenForEvent("onremove", on_piece_removed)
        end
    end
end

local function on_timer_done(inst, data)
    if data.name == "disperse" then
        inst.persists = false

        inst.SoundEmitter:KillSound("spore_loop")

        inst:RemoveTag("chum")

        inst._fading:set(true)

        inst:DoTaskInTime(TUNING.WATERPLANT.POLLEN_FADETIME, inst.Remove)
    end
end

local function on_ocean_removed(inst)
    for k, v in pairs(inst._chumpieces) do
        if k:IsValid() then
            k:Remove()
        end
    end
end

local function ocean_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pollen_chum")
    inst.AnimState:SetBuild("pollen_chum")
    inst.AnimState:PlayAnimation("fish_chum_base_pre")
    inst.AnimState:PushAnimation("fish_chum_base_idle", true)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("chum")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("pollen")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")

    inst._fading = net_bool(inst.GUID, "waterplant_pollen_fx_ocean._fading", "fadingdirty")

    inst.entity:SetPristine()

    -- Every non-dedicated server needs to start a fade when it's set.
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("fadingdirty", client_fading_dirty)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst._chumpieces = {}
    inst._numpieces = 0
    inst._spawn_chum_piece = spawn_chum_piece -- facilitates the circular function dependency for piece "onremove" listener
    inst:DoPeriodicTask(1.0, spawn_chum_piece)

    inst:ListenForEvent("timerdone", on_timer_done)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disperse", TUNING.WATERPLANT.POLLEN_DURATION)

    inst:ListenForEvent("onremove", on_ocean_removed)

    return inst
end

return Prefab("waterplant_pollen_fx", front_fn, front_assets, front_prefabs),
        Prefab("waterplant_pollen_fx_ocean", ocean_fn, ocean_assets, ocean_prefabs)
