

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

local function createglass(name, preinit, postinit)

    local assets =
    {
        Asset("ANIM", "anim/moonglass.zip"),
    }

    if name == "moonglass_charged" then
        assets =
        {
            Asset("ANIM", "anim/moonglass_charged.zip"),
        }
    end

    local function fn()
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

		inst:AddTag("moonglass_piece")

        if preinit then
           inst = preinit(inst)
        end

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

        if postinit then
           inst = postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function onpickup(inst)
    inst.Light:Enable(false)
end

local function ondropped(inst)
    inst.Light:Enable(true)
end

local function infused_preinit(inst)
    inst.entity:AddLight()
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("moonglass_charged")
    inst.AnimState:SetBuild("moonglass_charged")
    inst:AddTag("show_spoilage")

    inst.Light:SetColour(111/255, 111/255, 227/255)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(1)
    inst.Light:Enable(true)

    return inst
end

local function infused_postinit(inst)
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.MOONGLASS_CHARGED_PERISH_TIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "moonglass"

    inst:ListenForEvent("onputininventory", onpickup)
    inst:ListenForEvent("ondropped", ondropped)
    return inst
end

return createglass("moonglass"),
       createglass("moonglass_charged", infused_preinit, infused_postinit)
