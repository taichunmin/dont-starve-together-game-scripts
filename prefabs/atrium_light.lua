local assets =
{
    Asset("ANIM", "anim/atrium_light.zip")
}

local prefabs =
{
    "atrium_light_back",
    "atrium_light_light",
}

local function getstatus(inst)
    return inst.Light:IsEnabled() and "ON" or "OFF"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .45)

    inst.AnimState:SetBank("atrium_light")
    inst.AnimState:SetBuild("atrium_light")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("back")
    inst.AnimState:SetFinalOffset(2)

    inst.MiniMapEntity:SetIcon("atrium_light.png")

    inst.Light:Enable(false)
    inst.Light:SetRadius(8)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(.65)
    inst.Light:SetColour(200 / 255, 140 / 255, 140 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.highlightchildren = {}

        return inst
    end

    inst._back = SpawnPrefab("atrium_light_back")
    inst._back.entity:SetParent(inst.entity)

    inst._light = SpawnPrefab("atrium_light_light")
    inst._light.entity:SetParent(inst.entity)

    inst.highlightchildren = { inst._back, inst._light }

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeHauntableWork(inst)
    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)

    local function OnTurnedOff(_light)
        inst:RemoveEventCallback("animover", OnTurnedOff, _light)
        inst.AnimState:PlayAnimation("idle")
        inst._back.AnimState:PlayAnimation("idle")
        _light.AnimState:PlayAnimation("light_idle")
    end

    inst:ListenForEvent("atriumpowered", function(_, ispowered)
        if ispowered then
            if not inst.Light:IsEnabled() then
                inst.Light:Enable(true)
                inst:RemoveEventCallback("animover", OnTurnedOff, inst._light)
                inst.AnimState:PlayAnimation("idle_active")
                inst._back.AnimState:PlayAnimation("idle_active")
                inst._light.AnimState:PlayAnimation("light_turn_on")
                inst._light.AnimState:PushAnimation("light_idle_active", false)
            end
        elseif inst.Light:IsEnabled() then
            inst.Light:Enable(false)
            inst:ListenForEvent("animover", OnTurnedOff, inst._light)
            inst._light.AnimState:PlayAnimation("light_turn_off")
        end
    end, TheWorld)

    return inst
end

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "atrium_light" then
        table.insert(parent.highlightchildren, inst)
    end
end

local function back_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("atrium_light")
    inst.AnimState:SetBuild("atrium_light")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("front")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated

        return inst
    end

    inst.persists = false

    return inst
end

local function light_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("atrium_light")
    inst.AnimState:SetBuild("atrium_light")
    inst.AnimState:PlayAnimation("light_idle")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated

        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("atrium_light", fn, assets, prefabs),
    Prefab("atrium_light_back", back_fn, assets),
    Prefab("atrium_light_light", light_fn, assets)
