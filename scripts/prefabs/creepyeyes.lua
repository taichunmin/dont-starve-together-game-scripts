local assets =
{
    Asset("ANIM", "anim/eyes_darkness.zip"),
}

local function Blink(inst)
    inst.AnimState:PlayAnimation("blink_"..inst.animname)
    inst.AnimState:PushAnimation("idle_"..inst.animname, true)
    inst.blinktask = inst:DoTaskInTime(0.5 + math.random(), Blink)
end

local function Disappear(inst)
    if inst.blinktask ~= nil then
        inst.blinktask:Cancel()
        inst.blinktask = nil
    end
    if inst.deathtask ~= nil then
        inst.deathtask:Cancel()
        inst.deathtask = nil
        inst.AnimState:PushAnimation("disappear_"..inst.animname, false)
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
    inst:ListenForEvent("enterlight", inst.Remove)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3, 5)
    inst.components.playerprox:SetOnPlayerNear(Disappear)

    inst.animname = tostring(math.random(3))
    inst.AnimState:SetBank("eyes_darkness")
    inst.AnimState:SetBuild("eyes_darkness")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:PlayAnimation("appear_"..inst.animname)
    inst.AnimState:PushAnimation("idle_"..inst.animname, true)

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

        inst.blinktask = inst:DoTaskInTime(1 + math.random(), Blink)
        inst.deathtask = inst:DoTaskInTime(10 + 5 * math.random(), Disappear)
    end

    return inst
end

return Prefab("creepyeyes", fn, assets)
