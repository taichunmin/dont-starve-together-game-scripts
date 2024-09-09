local assets =
{
    Asset("ANIM", "anim/charlie_basic.zip"),
}

local prefabs =
{
    
}

local KNOWS_CHARLIE_LOOKUP = {
    winona  = true,
    waxwell = true,
}

local CAST_SOUND_NAME = "castloopsound"
local AMB_SOUND_NAME  = "ambsound"

--------------------------------------------------------------------------

local function EnableDynamicShadow(inst)
    inst.DynamicShadow:Enable(true)
end

local function DisableDynamicShadow(inst)
    inst.DynamicShadow:Enable(false)
end

local function PlayDespawnSound(inst)
    inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_leave")
end

local function OnRemove(inst)
    inst.SoundEmitter:KillSound(AMB_SOUND_NAME)
    inst.SoundEmitter:KillSound(CAST_SOUND_NAME)

    -- Charliecutscene cmp save/load will handle this not running.
    if inst.atrium ~= nil and inst.atrium.components.charliecutscene ~= nil then
        inst.atrium.components.charliecutscene:Finish()
    end
end

--------------------------------------------------------------------------

local function StartCasting(inst, cast_time)
    inst.SoundEmitter:PlaySound("rifts2/charlie/casting_lp", CAST_SOUND_NAME)

    inst.AnimState:PlayAnimation("cast_pre")
    inst.AnimState:PushAnimation("cast_idle")
end

local function Despawn(inst)
    inst.SoundEmitter:KillSound(CAST_SOUND_NAME)

    inst.SoundEmitter:PlaySound("rifts2/charlie/casting_pst")

    inst.AnimState:PlayAnimation("cast_pst")
    inst.AnimState:PushAnimation("idle")
    inst.AnimState:PushAnimation("spawn_out")

    inst:DoTaskInTime((60 + 60) * FRAMES, PlayDespawnSound)
    inst:DoTaskInTime((60 + 60 + 45) * FRAMES, DisableDynamicShadow)

    local despawn_time = (60 + 60 + 100) * FRAMES -- Animation lengths.
    inst.removetask = inst:DoTaskInTime(despawn_time, inst.Remove)
end

local function StartCastingWithDelay(inst, delay, cast_time)
    inst:DoTaskInTime(delay, inst.StartCasting)
    inst:DoTaskInTime(delay + cast_time, inst.Despawn)
end

--------------------------------------------------------------------------

local function DisplayNameFn(inst)
    if ThePlayer ~= nil and KNOWS_CHARLIE_LOOKUP[ThePlayer.prefab] then
        return STRINGS.NAMES[string.upper(inst.prefab)]
    else
        return STRINGS.NAMES[string.upper(inst.prefab.."_ALT")]
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst.DynamicShadow:SetSize(3, 2)
    inst.DynamicShadow:Enable(false)

    inst.Transform:SetTwoFaced()

	inst:AddTag("character")
    inst:AddTag("charlie_npc")

    inst.AnimState:SetBank("charlie_basic")
    inst.AnimState:SetBuild("charlie_basic")
    inst.AnimState:PlayAnimation("spawn")
    inst.AnimState:PushAnimation("idle", true)

    inst.entity:SetPristine()

    inst.displaynamefn = DisplayNameFn

    if not TheWorld.ismastersim then
        return inst
    end

    inst.StartCasting = StartCasting
    inst.Despawn = Despawn
    inst.StartCastingWithDelay = StartCastingWithDelay

    inst:AddComponent("inspectable")

    inst.persists = false

    inst.OnRemoveEntity = OnRemove

    inst:DoTaskInTime(22*FRAMES, EnableDynamicShadow)

    inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_arrive")
    inst.SoundEmitter:PlaySound("rifts2/charlie/charlie_amb", AMB_SOUND_NAME)

    return inst
end

return
        Prefab("charlie_npc", fn, assets, prefabs)
