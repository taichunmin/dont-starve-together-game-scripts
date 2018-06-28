local assets =
{
    Asset("ANIM", "anim/quagmire_altar.zip"),
}

local prefabs =
{
    "quagmire_coin1",
    "quagmire_coin2",
    "quagmire_coin3",
    "quagmire_coin4",
}

local function OnKeyDirty(inst)
    if inst.foodid:value() > 0 and inst.klumpkey:value():len() > 0 then
        local name = string.format("quagmire_food_%03i", inst.foodid:value())
        LoadKlumpFile("images/quagmire_food_inv_images_"..name..".tex", inst.klumpkey:value())
        LoadKlumpFile("images/quagmire_food_inv_images_hires_"..name..".tex", inst.klumpkey:value())
        LoadKlumpFile("anim/dynamic/"..name..".dyn", inst.klumpkey:value())
        LoadKlumpString("STRINGS.NAMES."..string.upper(name), inst.klumpkey:value())
    end
end

local function OnFocusCamera(inst)
    TheFocalPoint:PushTempFocus(inst, 30, 30, 2)
end

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        if inst._camerafocustask == nil then
            inst._camerafocustask = inst:DoPeriodicTask(0, OnFocusCamera)
        end
    elseif inst._camerafocustask ~= nil then
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.AnimState:SetBank("quagmire_altar")
    inst.AnimState:SetBuild("quagmire_altar")
    inst.AnimState:PlayAnimation("idle_food")
    inst.AnimState:Hide("shadow")

    inst:AddTag("quagmire_altar")

    inst.foodid = net_byte(inst.GUID, "quagmire_altar.foodid", "keydirty")
    inst.klumpkey = net_string(inst.GUID, "quagmire_altar.klumpkey", "keydirty")
    inst._camerafocus = net_bool(inst.GUID, "quagmire_portal._camerafocus", "camerafocusdirty")
    inst._camerafocustask = nil
    inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("keydirty", OnKeyDirty)

        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_altar").master_postinit(inst)

    return inst
end

return Prefab("quagmire_altar", fn, assets, prefabs)
