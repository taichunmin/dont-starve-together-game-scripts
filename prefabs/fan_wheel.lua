local assets =
{
    Asset("ANIM", "anim/fan_wheel.zip"),
}

local function AlignToTarget(inst, target)
    inst.Transform:SetRotation(target.Transform:GetRotation())
end

local function ToggleSpin(inst, spin)
    if spin then
        if not inst._toggle then
            inst._toggle = true
            inst.AnimState:PlayAnimation("spin_pre")
            inst.AnimState:PushAnimation("spin_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/fan_twirl_LP", "twirl")
        end
    elseif inst._toggle then
        inst._toggle = false
        inst.AnimState:PlayAnimation("spin_pst")
        inst.AnimState:PushAnimation("idle")
        inst.SoundEmitter:KillSound("twirl")
    end
end

local function CreateFanWheelFX(proxy)
    local parent = proxy.entity:GetParent()
    if parent == nil then
        --shouldn't.. mmkay?
        return
    end

    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddFollower()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("fan_wheel")
    inst.AnimState:SetBuild("fan_wheel")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetParent(parent.entity)
    inst.Follower:FollowSymbol(parent.GUID, "swap_object", 0, -114, 0)

    inst:DoPeriodicTask(0, AlignToTarget, nil, parent)
    AlignToTarget(inst, parent)

    inst._toggle = false
    inst:ListenForEvent("isspinningdirty", function() ToggleSpin(inst, proxy._isspinning:value()) end, proxy)
    ToggleSpin(inst, proxy._isspinning:value())

    inst:ListenForEvent("onremove", function() inst:Remove() end, proxy)
end

local function SetSpinning(inst, isspinning)
    inst._isspinning:set(isspinning)
end

local function transfertostatemem(inst, sg)
    if sg.statemem.followfx == nil then
        sg.statemem.followfx = { inst }
    else
        table.insert(sg.statemem.followfx, inst)
    end
end

local function delayedremove(inst)
    inst._timeout = inst:DoTaskInTime(0, inst.Remove)
end

local function StartUnequipping(inst, item)
    local parent = inst.entity:GetParent()
    if parent == nil or
        item.components.inventoryitem == nil or
        item.components.inventoryitem.owner ~= parent then
        --not held anymore
        inst:Remove()
        return
    end

    --The trick here is that we want to keep the fx around if
    --the character is going to animate putting the item away

    --Remove immediately if it gets dropped at anytime
    inst:ListenForEvent("ondropped", function() inst:Remove() end, item)

    --Now we try to pass the reference to this fx over to the
    --character's stategraph, which will handle cleanup there

    --If we're in the item_in state, push this fx to statemem
    if parent.sg.currentstate.name ~= "item_in" then
        inst._timeout = inst:DoTaskInTime(0, delayedremove)
        inst:ListenForEvent("newstate", function(parent, data)
            if data.statename ~= "item_in" then
                inst:Remove()
            else
                inst._timeout:Cancel()
                transfertostatemem(inst, parent.sg)
            end
        end, parent)
    else
        transfertostatemem(inst, parent.sg)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    -----------------------------------------------------
    inst:AddTag("FX")

    --Delay one frame so that we are parented properly before starting the effect
    --or in case we are about to be removed
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, CreateFanWheelFX)
    end

    inst._isspinning = net_bool(inst.GUID, "fan_wheel._isspinning", "isspinningdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetSpinning = SetSpinning
    inst.StartUnequipping = StartUnequipping

    inst.persists = false

    return inst
end

return Prefab("fan_wheel", fn, assets)
