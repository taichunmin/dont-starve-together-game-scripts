--Inventory item version
local assets =
{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("INV_IMAGE", "bernie_dead"),
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
        local active = SpawnPrefab("bernie_active")
        if active ~= nil then
            --Transform fuel % into health.
            active.components.health:SetPercent(inst.components.fueled:GetPercent())
            active.Transform:SetPosition(inst.Transform:GetWorldPosition())
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

local function onfuelchange(section, oldsection, inst)
    if inst.components.fueled:IsEmpty() then
        if not inst._isdeadstate then
            inst._isdeadstate = true
            inst.AnimState:PlayAnimation("dead_loop")
            inst.components.inventoryitem:ChangeImageName("bernie_dead")
            if not inst.components.inventoryitem:IsHeld() then
                deactivate(inst)
                startdecay(inst)
            end
        end
    elseif inst._isdeadstate then
        inst._isdeadstate = nil
        inst.AnimState:PlayAnimation("inactive")
        inst.components.inventoryitem:ChangeImageName()
        if not inst.components.inventoryitem:IsHeld() then
            stopdecay(inst)
            if inst.entity:IsAwake() then
                activate(inst)
            end
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("inactive")

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

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.BERNIE_FUEL)
    inst.components.fueled:SetSectionCallback(onfuelchange)

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    toground(inst)

    MakeHauntableLaunch(inst)

    inst.OnEntitySleep = deactivate
    inst.OnEntityWake = onentitywake

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return Prefab("bernie_inactive", fn, assets, prefabs)
