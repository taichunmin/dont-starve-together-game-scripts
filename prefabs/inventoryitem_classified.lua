local function OnRemoveEntity(inst)
    if inst._parent ~= nil then
        inst._parent.inventoryitem_classified = nil
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for inventory item")
    elseif inst._parent.replica.inventoryitem ~= nil then
        inst._parent.replica.inventoryitem:AttachClassified(inst)
    else
        inst._parent.inventoryitem_classified = inst
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function OnImageDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("imagechange")
    end
end

local function SerializePercentUsed(inst, percent)
    inst.percentused:set((percent == nil and 255) or (percent <= 0 and 0) or math.clamp(math.floor(percent * 100 + .5), 1, 100))
end

local function DeserializePercentUsed(inst)
    if inst.percentused:value() ~= 255 and inst._parent ~= nil then
        inst._parent:PushEvent("percentusedchange", { percent = inst.percentused:value() / 100 })
    end
end

local function SerializePerish(inst, percent)
    inst.perish:set(percent ~= nil and math.clamp(math.floor(percent * 62 + .5), 0, 62) or 63)
end

--V2C: used to force color refresh when spoilage changes around 50%/20%
local function ForcePerishDirty(inst)
    inst.perish:set_local(inst.perish:value())
    inst.perish:set(inst.perish:value())
end

local function DeserializePerish(inst)
    if inst.perish:value() ~= 63 and inst._parent ~= nil then
        inst._parent:PushEvent("perishchange", { percent = inst.perish:value() / 62 })
    end
end

local function SerializeRecharge(inst, percent, overtime)
    if percent == nil then
        inst.recharge:set(255)
    elseif percent <= 0 then
        inst.recharge:set(0)
    elseif percent >= 1 then
        inst.recharge:set(180)
    elseif overtime then
        inst.recharge:set_local(math.min(179, math.floor(percent * 180 + .5)))
    else
        inst.recharge:set(math.min(179, math.floor(percent * 180 + .5)))
    end
end

local function OnRechargeTick(inst)
    inst._recharge = inst._recharge + 180 * FRAMES / inst.rechargetime:value()
    if inst._recharge < 179.99 then
        inst.recharge:set_local(math.floor(inst._recharge))
    else
        inst.recharge:set_local(179)
        inst._rechargetask:Cancel()
        inst._rechargetask = nil
        inst._recharge = nil
    end
    if inst._parent ~= nil then
        inst._parent:PushEvent("rechargechange", { percent = (inst._recharge or 179.99) / 180, overtime = true })
    end
end

local function OnRechargeDirty(inst)
    if inst.recharge:value() < 180 and inst.rechargetime:value() >= 0 then
        inst._recharge = inst.recharge:value()
        if inst._rechargetask == nil then
            inst._rechargetask = inst:DoPeriodicTask(FRAMES, OnRechargeTick)
        end
    elseif inst._rechargetask ~= nil then
        inst._rechargetask:Cancel()
        inst._rechargetask = nil
        inst._recharge = nil
    end
end

local function DeserializeRecharge(inst)
    if inst.recharge:value() < 181 then
        OnRechargeDirty(inst)
        if inst._parent ~= nil then
            inst._parent:PushEvent("rechargechange", { percent = inst.recharge:value() / 180 })
        end
    end
end

local function SerializeRechargeTime(inst, t)
    inst.rechargetime:set((t == nil and -2) or (t >= math.huge and -1) or t)
end

local function DeserializeRechargeTime(inst)
    if inst.rechargetime:value() >= -1 then
        OnRechargeDirty(inst)
        if inst._parent ~= nil then
            inst._parent:PushEvent("rechargetimechange", { t = inst.rechargetime:value() >= 0 and inst.rechargetime:value() or math.huge })
        end
    end
end

local function OnStackSizeDirty(parent)
    TheWorld:PushEvent("stackitemdirty", parent)
end

local function OnIsWetDirty(parent)
    local inventoryitem = parent.replica.inventoryitem
    if inventoryitem ~= nil then
        parent:PushEvent("wetnesschange", inventoryitem:IsWet())
    end
end

local function RegisterNetListeners(inst)
    inst:ListenForEvent("imagedirty", OnImageDirty)
    inst:ListenForEvent("percentuseddirty", DeserializePercentUsed)
    inst:ListenForEvent("perishdirty", DeserializePerish)
    inst:ListenForEvent("rechargedirty", DeserializeRecharge)
    inst:ListenForEvent("rechargetimedirty", DeserializeRechargeTime)
    inst:ListenForEvent("stacksizedirty", OnStackSizeDirty, inst._parent)
    inst:ListenForEvent("iswetdirty", OnIsWetDirty, inst._parent)
end

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() --So we can follow parent's sleep state
    end
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.image = net_hash(inst.GUID, "inventoryitem.image", "imagedirty")
    inst.atlas = net_hash(inst.GUID, "inventoryitem.atlas", "imagedirty")
    inst.cangoincontainer = net_bool(inst.GUID, "inventoryitem.cangoincontainer")
    inst.canonlygoinpocket = net_bool(inst.GUID, "inventoryitem.canonlygoinpocket")
    inst.src_pos =
    {
        isvalid = net_bool(inst.GUID, "inventoryitem.src_pos.isvalid"),
        x = net_float(inst.GUID, "inventoryitem.src_pos.x"),
        z = net_float(inst.GUID, "inventoryitem.src_pos.z"),
    }
    inst.percentused = net_byte(inst.GUID, "inventoryitem.percentused", "percentuseddirty")
    inst.perish = net_smallbyte(inst.GUID, "inventoryitem.perish", "perishdirty")
    inst.recharge = net_byte(inst.GUID, "inventoryitem.recharge", "rechargedirty")
    inst.rechargetime = net_float(inst.GUID, "inventoryitem.rechargetime", "rechargetimedirty")
    inst.deploymode = net_tinybyte(inst.GUID, "deployable.mode")
    inst.deployspacing = net_tinybyte(inst.GUID, "deployable.spacing")
    inst.deployrestrictedtag = net_hash(inst.GUID, "deployable.restrictedtag")
    inst.usegridplacer = net_bool(inst.GUID, "deployable.usegridplacer")
    inst.attackrange = net_float(inst.GUID, "weapon.attackrange")
    inst.walkspeedmult = net_byte(inst.GUID, "equippable.walkspeedmult")
    inst.equiprestrictedtag = net_hash(inst.GUID, "equippable.restrictedtag")
    inst.moisture = net_float(inst.GUID, "inventoryitemmoisture.moisture")

    inst.image:set(0)
    inst.atlas:set(0)
    inst.cangoincontainer:set(true)
    inst.canonlygoinpocket:set(false)
    inst.src_pos.isvalid:set(false)
    inst.percentused:set(255)
    inst.perish:set(63)
    inst.recharge:set(255)
    inst.rechargetime:set(-2)
    inst.deploymode:set(DEPLOYMODE.NONE)
    inst.deployspacing:set(DEPLOYSPACING.DEFAULT)
    inst.deployrestrictedtag:set(0)
    inst.usegridplacer:set(false)
    inst.attackrange:set(-99)
    inst.walkspeedmult:set(1)
    inst.equiprestrictedtag:set(0)
    inst.moisture:set(0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.DeserializePercentUsed = DeserializePercentUsed
        inst.DeserializePerish = DeserializePerish
        inst.DeserializeRecharge = DeserializeRecharge
        inst.DeserializeRechargeTime = DeserializeRechargeTime
        inst.OnEntityReplicated = OnEntityReplicated

        --inst._rechargetask = nil

        --Delay net listeners until after initial values are deserialized
        inst:DoStaticTaskInTime(0, RegisterNetListeners)
        return inst
    end

    inst.persists = false

    inst.SerializePercentUsed = SerializePercentUsed
    inst.SerializePerish = SerializePerish
    inst.ForcePerishDirty = ForcePerishDirty
    inst.SerializeRecharge = SerializeRecharge
    inst.SerializeRechargeTime = SerializeRechargeTime

    return inst
end

return Prefab("inventoryitem_classified", fn)
