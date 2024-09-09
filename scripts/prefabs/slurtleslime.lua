local assets =
{
    Asset("ANIM", "anim/slurtle_slime.zip"),
}

local prefabs =
{
    "explode_small",
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    DefaultBurnFn(inst)
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    DefaultExtinguishFn(inst)
end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("slurtle_slime")
    inst.AnimState:SetBuild("slurtle_slime")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("explosive")

    --[[
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.1)
    inst.Light:SetRadius(0.1)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)
    --]]

    MakeInventoryFloatable(inst, "med", nil, 0.73)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel.fueltype = FUELTYPE.CAVE

    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst, 3 + math.random() * 3)
    MakeSmallPropagator(inst)
    --V2C: Remove default OnBurnt handler, as it conflicts with
    --explosive component's OnBurnt handler for removing itself
    inst.components.burnable:SetOnBurntFn(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.SLURTLESLIME_EXPLODE_DAMAGE
    inst.components.explosive.buildingdamage = 1
    inst.components.explosive.lightonexplode = false

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("slurtleslime", fn, assets, prefabs)
