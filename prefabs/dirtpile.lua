local assets =
{
    Asset("ANIM", "anim/koalefant_tracks.zip"),
    Asset("ANIM", "anim/smoke_puff_small.zip"),
}

local prefabs =
{
    "small_puff"
}

local AUDIO_HINT_MIN = 10
local AUDIO_HINT_MAX = 60

local function GetVerb()
    return "INVESTIGATE"
end

local function OnInvestigated(inst, doer)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    --print("dirtpile - OnInvestigated", pt)

    local hunter = TheWorld.components.hunter
    if hunter ~= nil then
        hunter:OnDirtInvestigated(pt, doer)
    end

    SpawnPrefab("small_puff").Transform:SetPosition(pt:Get())
    --PlayFX(pt, "small_puff", "smoke_puff_small", "puff", "dontstarve/common/deathpoof", nil, Vector3(216/255, 154/255, 132/255))
    inst:Remove()
end

--[[
local function OnAudioHint(inst)
    --print("dirtpile - OnAudioHint")

    local distsq = inst:GetDistanceSqToInst(ThePlayer)
    if distsq > AUDIO_HINT_MIN*AUDIO_HINT_MIN and distsq < AUDIO_HINT_MAX*AUDIO_HINT_MAX then
        --print("    playing hint")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/grunt")
    end

    inst:DoTaskInTime(math.random(7, 14), OnAudioHint)
end
--]]

local function create()
    --print("dirtpile - create")

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("dirtpile")

    inst.AnimState:SetBank("track")
    inst.AnimState:SetBuild("koalefant_tracks")
    --inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    --inst.AnimState:SetLayer( LAYER_BACKGROUND )
    --inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:PlayAnimation("idle_pile")

    --inst.Transform:SetRotation(math.random(360))

    inst.GetActivateVerb = GetVerb

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("activatable")

    --set required
    inst.components.activatable.OnActivate = OnInvestigated
    inst.components.activatable.inactive = true

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        OnInvestigated(inst, haunter)
        return true
    end)

    --inst:DoTaskInTime(1, OnAudioHint)

    inst.persists = false
    return inst
end

return Prefab("dirtpile", create, assets, prefabs)