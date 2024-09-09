local assets =
{
    Asset("ANIM", "anim/nightmare_timepiece.zip"),
}

local DEFAULT_STATE =
{
    anim = "idle_1",
    inventory = "nightmare_timepiece",
}

local STATES =
{
    calm = DEFAULT_STATE,
    warn =
    {
        anim = "idle_2",
        inventory = "nightmare_timepiece_warn",
    },
    wild =
    {
        anim = "idle_3",
        inventory = "nightmare_timepiece_nightmare",
    },
    dawn = DEFAULT_STATE,
}

for k, v in pairs(STATES) do
    if v.inventory ~= "nightmare_timepiece" then
        table.insert(assets, Asset("INV_IMAGE", v.inventory))
    end
end

local function GetStatus(inst)
    return (TheWorld.state.isnightmarewarn and "WARN")
        or (TheWorld.state.isnightmarecalm and "CALM")
        or (TheWorld.state.isnightmaredawn and "DAWN")
        or (not TheWorld.state.isnightmarewild and "NOMAGIC")
        or (TheWorld.state.nightmaretimeinphase < .33 and "WAXING")
        or (TheWorld.state.nightmaretimeinphase < .66 and "STEADY")
        or "WANING"
end

local function OnNightmarePhaseChanged(inst, phase)
    local state = STATES[phase] or DEFAULT_STATE
    inst.AnimState:PlayAnimation(state.anim)
    inst.components.inventoryitem:ChangeImageName(state.inventory)
end

local function toground(inst)
    if inst._owner ~= nil then
        inst._owner:RemoveEventCallback("onremove", toground, inst)

        if inst._owner.components.inventory == nil or not inst._owner.components.inventory:Has(inst.prefab, 1) then
            inst._owner:RemoveTag("nightmaretracker")
        end

        inst._owner = nil
    end
end

local function topocket(inst, owner)
    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
    if owner ~= inst._owner then
        toground(inst)
        owner:AddTag("nightmaretracker")
        owner:ListenForEvent("onremove", toground, inst)
        inst._owner = owner
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmare_watch")
    inst.AnimState:SetBuild("nightmare_timepiece")
    inst.AnimState:PlayAnimation("idle_1")
    inst.scrapbook_anim = "idle_1"

    MakeInventoryFloatable(inst, "med", nil, 0.62)

    inst.scrapbook_specialinfo = "NIGHTMARETIMEPIECE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    inst:WatchWorldState("nightmarephase", OnNightmarePhaseChanged)
    OnNightmarePhaseChanged(inst, TheWorld.state.nightmarephase)

    inst._owner = nil
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    return inst
end

return Prefab("nightmare_timepiece", fn, assets)
