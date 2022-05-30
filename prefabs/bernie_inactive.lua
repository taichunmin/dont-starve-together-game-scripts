--Inventory item version
local assets =
{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("INV_IMAGE", "bernie_dead"),
	Asset("MINIMAP_IMAGE", "bernie"),
}

local prefabs =
{
    "bernie_active",
    "beardhair",
    "beefalowool",
    "silk",
    "small_puff",
}

local function getstatus(inst)
    return inst.components.fueled:IsEmpty() and "BROKEN" or nil
end

--------------------------------------------------------------------------

local function dodecay(inst)
    if inst.components.lootdropper == nil then
        inst:AddComponent("lootdropper")
    end
    inst.components.lootdropper:SpawnLootPrefab("beardhair")
    inst.components.lootdropper:SpawnLootPrefab("beefalowool")
    inst.components.lootdropper:SpawnLootPrefab("silk")
    SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function startdecay(inst)
    if inst._decaytask == nil then
        inst._decaytask = inst:DoTaskInTime(TUNING.BERNIE_DECAY_TIME, dodecay)
    end
end

local function stopdecay(inst)
    if inst._decaytask ~= nil then
        inst._decaytask:Cancel()
        inst._decaytask = nil
    end
end

local function onsave(inst, data)
    if inst._decaytask ~= nil then
        local time = TUNING.BERNIE_DECAY_TIME - GetTaskRemaining(inst._decaytask)
        data.decaytime = time > 0 and time or nil
    end
end

local function onload(inst, data)
    if inst._decaytask ~= nil and data ~= nil and data.decaytime ~= nil then
        local remaining = math.max(0, TUNING.BERNIE_DECAY_TIME - data.decaytime)
        inst._decaytask:Cancel()
        inst._decaytask = inst:DoTaskInTime(remaining, dodecay)
    end
end

--------------------------------------------------------------------------

local function tryreanimate(inst)
    local target = nil
    local rangesq = 256 --[[16 * 16]]
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if v.components.sanity:IsCrazy() and v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                target = v
            end
        end
    end
    if target ~= nil then
        local skin_name = nil
        if inst:GetSkinName() ~= nil then
            skin_name = inst:GetSkinName().."_active"
        end
        local active = SpawnPrefab("bernie_active", skin_name, inst.skin_id, nil)
        if active ~= nil then
            --Transform fuel % into health.
            active.components.health:SetPercent(inst.components.fueled:GetPercent())
            active.Transform:SetPosition(inst.Transform:GetWorldPosition())
            active.Transform:SetRotation(inst.Transform:GetRotation())
            local bigcd = inst.components.timer:GetTimeLeft("transform_cd")
            if bigcd ~= nil then
                active.components.timer:StartTimer("transform_cd", bigcd)
            end
            inst:Remove()
        end
    end
end

local function activate(inst)
    if inst._activatetask == nil then
        inst._activatetask = inst:DoPeriodicTask(1, tryreanimate)
    end
end

local function deactivate(inst)
    if inst._activatetask ~= nil then
        inst._activatetask:Cancel()
        inst._activatetask = nil
    end
end

local function bernie_swap_object_helper(owner, skin_build, symbol, guid)
    if skin_build ~= nil then
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, symbol, guid, "bernie_build")
        owner.AnimState:OverrideItemSkinSymbol("swap_object_bernie", skin_build, symbol.."_idle_willow", guid, "bernie_build")
    else
        owner.AnimState:OverrideSymbol("swap_object", "bernie_build", symbol)
        owner.AnimState:OverrideSymbol("swap_object_bernie", "bernie_build", symbol.."_idle_willow")
    end
end

local function onfuelchange(section, oldsection, inst)
    if inst.components.fueled:IsEmpty() then
        if not inst._isdeadstate then
            inst._isdeadstate = true
            inst.components.equippable.dapperness = 0
            inst.components.insulator:SetInsulation(0)
            inst.AnimState:PlayAnimation("dead_loop")
            local prefix_name = "bernie"
            if inst:GetSkinName() ~= nil then
                prefix_name = inst:GetSkinName()
            end
            inst.components.inventoryitem:ChangeImageName(prefix_name.."_dead")
            if not inst.components.inventoryitem:IsHeld() then
                deactivate(inst)
                startdecay(inst)
            elseif inst.components.equippable:IsEquipped() then
                bernie_swap_object_helper(inst.components.inventoryitem.owner, inst:GetSkinBuild(), "swap_bernie_dead", inst.GUID)
            end
        end
    elseif inst._isdeadstate then
        inst._isdeadstate = nil
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
        inst.AnimState:PlayAnimation("inactive")
        inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
        if not inst.components.inventoryitem:IsHeld() then
            stopdecay(inst)
            if inst.entity:IsAwake() then
                activate(inst)
            end
        elseif inst.components.equippable:IsEquipped() then
            bernie_swap_object_helper(inst.components.inventoryitem.owner, inst:GetSkinBuild(), "swap_bernie", inst.GUID)
            inst.components.fueled:StartConsuming()
        end
    end
end

local function topocket(inst, owner)
    stopdecay(inst)
    deactivate(inst)
end

local function toground(inst)
    if inst.components.fueled:IsEmpty() then
        startdecay(inst)
    elseif inst.entity:IsAwake() then
        activate(inst)
    end
end

local function onentitywake(inst)
    if not (inst.components.inventoryitem:IsHeld() or inst.components.fueled:IsEmpty()) then
        activate(inst)
    end
end

--------------------------------------------------------------------------

local function OnEquip(inst, owner)
    if inst:GetSkinBuild() ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
    end

    if inst.components.fueled:IsEmpty() then
        bernie_swap_object_helper(owner, inst:GetSkinBuild(), "swap_bernie_dead", inst.GUID)
    else
        bernie_swap_object_helper(owner, inst:GetSkinBuild(), "swap_bernie", inst.GUID)
        inst.components.fueled:StartConsuming()
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst._lastowner ~= owner then
        if inst._lastowner ~= nil then
            inst:RemoveEventCallback("onattackother", inst._onattackother, inst._lastowner)
        end
        inst._lastowner = owner
        inst:ListenForEvent("onattackother", inst._onattackother, owner)
    end
end

local function OnUnequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.fueled:StopConsuming()

    if inst._lastowner ~= nil then
        inst:RemoveEventCallback("onattackother", inst._onattackother, inst._lastowner)
        inst._lastowner = nil
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.DynamicShadow:SetSize(1, .5)

    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("inactive")

    inst.MiniMapEntity:SetIcon("bernie.png")

    inst:AddTag("nopunch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._isdeadstate = nil
    inst._decaytask = nil
    inst._activatetask = nil

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.restrictedtag = "bernieowner"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled.rate = TUNING.BERNIE_FUEL_RATE
    inst.components.fueled:InitializeFuelLevel(TUNING.BERNIE_FUEL)
    inst.components.fueled:SetSectionCallback(onfuelchange)

    inst:AddComponent("timer")

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    toground(inst)

    MakeHauntableLaunch(inst)

    inst.OnEntitySleep = deactivate
    inst.OnEntityWake = onentitywake

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst._onattackother = function(attacker)--, data)
        if not (attacker.components.rider ~= nil and attacker.components.rider:IsRiding() or inst.components.fueled:IsEmpty()) then
            inst.components.fueled:DoDelta(-.01 * TUNING.BERNIE_FUEL)
        end
    end

    return inst
end

return Prefab("bernie_inactive", fn, assets, prefabs)
