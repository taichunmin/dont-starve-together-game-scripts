local assets =
{
    Asset("ANIM", "anim/moonglass.zip"),
}

local GLASS_NAMES = {"f1", "f2", "f3"}

local function set_glass_type(inst, name)
    if inst.glassname == nil or (name ~= nil and inst.glassname ~= name) then
        inst.glassname = name or (GLASS_NAMES[math.random(#GLASS_NAMES)])

        inst.AnimState:PlayAnimation(inst.glassname)
    end
end

local function on_save(inst, data)
    data.glassname = inst.glassname
end

local function on_load(inst, data)
    set_glass_type(inst, data ~= nil and data.glassname or nil)
end

local function moonglass()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("moonglass")
    inst.AnimState:SetBuild("moonglass")

    inst.AnimState:PlayAnimation("f1")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunchAndSmash(inst)

    if not POPULATING then
        set_glass_type(inst, nil)
    end

    inst.OnSave = on_save
    inst.OnLoad = on_load

    return inst
end

return Prefab("moonglass", moonglass, assets)
