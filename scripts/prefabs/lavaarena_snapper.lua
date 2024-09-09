local assets =
{
    Asset("ANIM", "anim/lavaarena_snapper_basic.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local assets_fx =
{
    Asset("ANIM", "anim/gooball_fx.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "fossilized_break_fx",
    "gooball_projectile",
    "goo_spit_fx",
    "lavaarena_battlestandard_damager",
    "lavaarena_creature_teleport_small_fx",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, .75)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 100, .75)

    inst.AnimState:SetBank("snapper")
    inst.AnimState:SetBuild("lavaarena_snapper_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:AddOverrideBuild("fossilized")

    inst:AddTag("LA_mob")
    inst:AddTag("monster")
    inst:AddTag("hostile")

    --fossilizable (from fossilizable component) added to pristine state for optimization
    inst:AddTag("fossilizable")

    ------------------------------------------

    if TheWorld.components.lavaarenamobtracker ~= nil then
        TheWorld.components.lavaarenamobtracker:StartTracking(inst)
    end

    ------------------------------------------

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_snapper").snapper_postinit(inst)

    return inst
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetFinalOffset(3)

    inst.Transform:SetTwoFaced()

    inst:Hide()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_snapper").goospit_postinit(inst)

    return inst
end

return Prefab("snapper", fn, assets, prefabs),
    Prefab("goo_spit_fx", fxfn, assets_fx)
