local assets =
{
    Asset("ANIM", "anim/townportaltalisman.zip"),
    Asset("INV_IMAGE", "townportaltalisman_active"),
}

local function OnEntityWake(inst)
    if inst.playingsound and not (inst:IsInLimbo() or inst:IsAsleep() or inst.SoundEmitter:PlayingSound("active")) then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/town_portal/talisman_active", "active")
    end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("active")
end

local function StartSoundLoop(inst)
    if not inst.playingsound then
        inst.playingsound = true
        OnEntityWake(inst)
    end
end

local function StopSoundLoop(inst)
    if inst.playingsound then
        inst.playingsound = nil
        inst.SoundEmitter:KillSound("active")
    end
end

local function DoActiveAnim(inst)
    inst.onanimqueueover = nil
    inst:RemoveEventCallback("animqueueover", DoActiveAnim)
    inst.AnimState:PlayAnimation("active_loop", true)
end

local function DoRiseAnims(inst)
    inst.animtask = nil
    inst.onanimqueueover = DoActiveAnim
    inst:ListenForEvent("animqueueover", DoActiveAnim)
    inst.AnimState:PlayAnimation("active_rise")
end

local function DoInactiveAnim(inst)
    inst.onanimqueueover = nil
    inst:RemoveEventCallback("animqueueover", DoInactiveAnim)
    inst.AnimState:PlayAnimation("inactive")
end

local function DoFallAnims(inst)
    inst.animtask = nil
    inst.onanimqueueover = DoInactiveAnim
    inst:ListenForEvent("animqueueover", DoInactiveAnim)
    inst.AnimState:PlayAnimation("active_fall")
end

local function OnLinkTownPortals(inst, other)
    inst.components.teleporter:Target(other)

    if inst.animtask ~= nil then
        inst.animtask:Cancel()
        inst.animtask = nil
    elseif inst.onanimqueueover ~= nil then
        inst:RemoveEventCallback("animqueueover", inst.onanimqueueover)
        inst.onanimqueueover = nil
    end

    if other ~= nil then
        inst.components.inventoryitem:ChangeImageName("townportaltalisman_active")
        if inst.components.inventoryitem:IsHeld() then
            inst.AnimState:PlayAnimation("active_loop", true)
			inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
        else
            if inst.AnimState:IsCurrentAnimation("active_shake2") then
                inst.AnimState:PlayAnimation("active_loop", true)
				inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
            elseif inst.AnimState:IsCurrentAnimation("active_fall") then
                inst.onanimqueueover = DoActiveAnim
                inst:ListenForEvent("animqueueover", DoActiveAnim)
                inst.AnimState:PushAnimation("active_rise", false)
            else
                inst.AnimState:PlayAnimation("active_shake", true)
                inst.animtask = inst:DoTaskInTime(.2 + math.random() * .4, DoRiseAnims)
            end
        end
        StartSoundLoop(inst)
        inst:AddTag("donotautopick")
    else
        inst.components.inventoryitem:ChangeImageName("townportaltalisman")
        if inst.components.inventoryitem:IsHeld() or inst.AnimState:IsCurrentAnimation("active_shake") then
            inst.AnimState:PlayAnimation("inactive")
        elseif inst.AnimState:IsCurrentAnimation("active_rise") then
            inst.onanimqueueover = DoInactiveAnim
            inst:ListenForEvent("animqueueover", DoInactiveAnim)
            inst.AnimState:PushAnimation("active_fall", false)
        else
            inst.AnimState:PlayAnimation("active_shake2", true)
            inst.animtask = inst:DoTaskInTime(.3 + math.random() * .3, DoFallAnims)
        end
        StopSoundLoop(inst)
        inst:RemoveTag("donotautopick")
    end
end

local function OnStartTeleporting(inst, doer)
    if doer:HasTag("player") then
        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
        end
    end

    inst.components.stackable:Get():Remove()
end

local function topocket(inst)
    if inst.animtask ~= nil then
        inst.animtask:Cancel()
        inst.animtask = nil
    elseif inst.onanimqueueover ~= nil then
        inst:RemoveEventCallback("animqueueover", inst.onanimqueueover)
        inst.onanimqueueover = nil
    else
        return
    end

    if inst.components.teleporter:IsActive() then
        inst.AnimState:PlayAnimation("active_loop", true)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    else
        inst.AnimState:PlayAnimation("inactive")
    end
end

local function GetStatus(inst)
    return inst.components.teleporter:IsActive() and "ACTIVE" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("townportaltalisman")
    inst.AnimState:SetBuild("townportaltalisman")
    inst.AnimState:PlayAnimation("inactive")
    inst.scrapbook_anim = "inactive"

    inst:AddTag("townportaltalisman")
    inst:AddTag("townportal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    MakeHauntableLaunch(inst)

    -------------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("teleporter")
    inst.components.teleporter.onActivate = OnStartTeleporting
    inst.components.teleporter.offset = 0
    inst.components.teleporter.saveenabled = false
    --inst:ListenForEvent("starttravelsound", StartTravelSound) -- triggered by player stategraph

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    -----------------------------
    inst:ListenForEvent("linktownportals", OnLinkTownPortals)
    inst:ListenForEvent("onputininventory", topocket)

    TheWorld:PushEvent("ms_registertownportal", inst)

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst:ListenForEvent("exitlimbo", OnEntityWake)
    inst:ListenForEvent("enterlimbo", OnEntitySleep)

    return inst
end

return Prefab("townportaltalisman", fn, assets)
