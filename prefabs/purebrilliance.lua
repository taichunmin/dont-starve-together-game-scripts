local assets =
{
    Asset("ANIM", "anim/purebrilliance.zip"),
    Asset("INV_IMAGE", "purebrilliance"),
}

local prefabs =
{
    "wurt_merm_planar",
    "purebrilliance_castfx",
    "purebrilliance_castfx_mount",
}

local assets_fx =
{
    Asset("ANIM", "anim/purebrilliance.zip"),
}

local function CommonSetupAnims(inst, anim)
    inst.AnimState:SetBank("purebrilliance")
    inst.AnimState:SetBuild("purebrilliance")
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetSymbolLightOverride("pb_energy_loop", .5)
    inst.AnimState:SetSymbolLightOverride("pb_ray", .5)
    inst.AnimState:SetSymbolLightOverride("SparkleBit", .5)
    inst.AnimState:SetLightOverride(.1)
end

local function PushCheerEvent(inst)
    if inst:HasTag("lunarminion") and not inst.components.health:IsDead() then
        inst:PushEvent("cheer")
    end
end

local function Wurt_MermSpellFn(inst, target, pos, doer)
    for follower, _ in pairs(doer.components.leader.followers) do
        if follower:HasTag("lunarminion") and not follower.components.health:IsDead() then
            follower:DoTaskInTime(.3*math.random(), PushCheerEvent)
            follower:AddDebuff("wurt_merm_planar", "wurt_merm_planar")
        end
    end

    if inst.components.stackable ~= nil then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    CommonSetupAnims(inst, "idle")

    inst:AddTag("purebrilliance")
    inst:AddTag("mermbuffcast")

    inst.pickupsound = "gem"

    MakeInventoryFloatable(inst, "small", .1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    --
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")
    --
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellType(SPELLTYPES.WURT_LUNAR)
    inst.components.spellcaster:SetSpellFn(Wurt_MermSpellFn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.canonlyuseonlocomotorspvp = true

    inst.lightcolour = {53/255, 132/255, 148/255}
    inst.fxprefab = "purebrilliance_castfx"
    inst.castsound = "meta4/casting/lunar"

    --
    MakeHauntableLaunch(inst)

    return inst
end

--Used as symbol follower by winona_battery_high
local function symbolfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    CommonSetupAnims(inst, "idle_sparkle")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.persists = false

    return inst
end

return Prefab("purebrilliance", fn, assets, prefabs),
    Prefab("purebrilliance_symbol_fx", symbolfxfn, assets_fx)
