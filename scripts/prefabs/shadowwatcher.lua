local assets =
{
    Asset("ANIM", "anim/shadow_creatures_ground.zip"),
}

local function Disappear(inst)
    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end
    if inst.deathtask ~= nil then
        inst.deathtask:Cancel()
        inst.deathtask = nil
        inst.AnimState:PushAnimation("watcher_pst", false)
        inst:ListenForEvent("animqueueover", inst.Remove)
    end
end

local function OnInit(inst)
    if inst:IsInLight() then
        inst:Remove()
    else
        inst.entity:Show()
    end
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLightWatcher()

    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)
    inst:ListenForEvent("enterlight", Disappear)

    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_creatures_ground")
    inst.AnimState:PlayAnimation("watcher_pre")
    inst.AnimState:PushAnimation("watcher_loop", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)

    inst.entity:Hide()

    if ThePlayer == nil or CanEntitySeeInDark(ThePlayer) then
        inst:DoTaskInTime(0, inst.Remove)
    else
        --Delay light check until entity has been positioned
        inst:DoTaskInTime(0, OnInit)

        inst:ListenForEvent("nightvision", function(player, nightvision)
            if nightvision then
                inst:Remove()
            end
        end, ThePlayer)

        inst.deathtask = inst:DoTaskInTime(5 + 10 * math.random(), Disappear)
    end

    return inst
end

return Prefab("shadowwatcher", fn, assets)
