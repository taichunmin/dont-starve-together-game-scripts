local assets =
{
    Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "fossilized_break_fx",
    "lavaarena_groundlift",
    "lavaarena_groundliftembers",
    "lavaarena_groundliftrocks",
    "lavaarena_groundliftwarning",
    "lavaarena_groundliftempty",
    "lavaarena_battlestandard_damager",
    "lavaarena_creature_teleport_medium_fx",
    "boaron",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(5.25, 1.75)
    inst.Transform:SetFourFaced()

    inst:SetPhysicsRadiusOverride(1.5)
    MakeCharacterPhysics(inst, 500, inst.physicsradiusoverride)

    inst.AnimState:SetBank("boarrior")
    inst.AnimState:SetBuild("lavaarena_boarrior_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:AddOverrideBuild("fossilized")

    inst:AddTag("LA_mob")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("epic")

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

    event_server_data("lavaarena", "prefabs/lavaarena_boarrior").master_postinit(inst)

    return inst
end

return Prefab("boarrior", fn, assets, prefabs)
