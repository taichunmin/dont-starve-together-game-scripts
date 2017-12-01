local assets =
{
    Asset("ANIM", "anim/lavaarena_turtillus_basic.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "fossilized_break_fx",
    "lavaarena_creature_teleport_small_fx",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2.5, 1.75)
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(.8, .8, .8)

    inst:SetPhysicsRadiusOverride(.8)
    MakeCharacterPhysics(inst, 150, inst.physicsradiusoverride)

    inst.AnimState:SetBank("turtillus")
    inst.AnimState:SetBuild("lavaarena_turtillus_basic")
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

    event_server_data("lavaarena", "prefabs/lavaarena_turtillus").master_postinit(inst)

    return inst
end

return Prefab("turtillus", fn, assets, prefabs)
