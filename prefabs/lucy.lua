local assets =
{
    Asset("ANIM", "anim/lucy_axe.zip"),
    Asset("ANIM", "anim/swap_lucy_axe.zip"),
	Asset("MINIMAP_IMAGE", "lucy_axe"),
}

local prefabs =
{
    "lucy_transform_fx",
    "lucy_ground_transform_fx",

    -- Lucy specific classified prefabs
    "lucy_classified",
}

--------------------------------------------------------------------------

local function AttachClassified(inst, classified)
    inst.lucy_classified = classified
    inst.ondetachclassified = function() inst:DetachClassified() end
    inst:ListenForEvent("onremove", inst.ondetachclassified, classified)
end

local function DetachClassified(inst)
    inst.lucy_classified = nil
    inst.ondetachclassified = nil
end

local function OnRemoveEntity(inst)
    if inst.lucy_classified ~= nil then
        if TheWorld.ismastersim then
            inst.lucy_classified:Remove()
            inst.lucy_classified = nil
        else
            inst.lucy_classified._parent = nil
            inst:RemoveEventCallback("onremove", inst.ondetachclassified, inst.lucy_classified)
            inst:DetachClassified()
        end
    end
end

local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("onremove", inst._oncontainerremoved, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("onremove", inst._oncontainerremoved, inst._container)
        inst._container = nil
    end
end

local function PostMigration(inst)
    inst.components.talker:StopIgnoringAll("migration")
end

local function topocket(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
    inst.lucy_classified:SetTarget(owner.components.inventoryitem ~= nil and owner.components.inventoryitem.owner or owner)

    if owner ~= nil and owner.migration ~= nil then
        inst.components.talker:IgnoreAll("migration")
        inst:DoTaskInTime(.2, PostMigration)
    end
end

local function toground(inst)
    unstore(inst)
    --No target means everyone receives it
    inst.lucy_classified:SetTarget(nil)
end

--------------------------------------------------------------------------

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_lucy_axe", "swap_lucy_axe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function ondonetalking(inst)
    inst.localsounds.SoundEmitter:KillSound("talk")
end

local function ontalk(inst)
    local sound = inst.lucy_classified ~= nil and inst.lucy_classified:GetTalkSound() or nil
    if sound ~= nil then
        inst.localsounds.SoundEmitter:KillSound("talk")
        inst.localsounds.SoundEmitter:PlaySound(sound)
    elseif not inst.localsounds.SoundEmitter:PlayingSound("talk") then
        inst.localsounds.SoundEmitter:PlaySound("dontstarve/characters/woodie/lucytalk_LP", "talk")
    end
end

local function CustomOnHaunt(inst)
    if inst.components.sentientaxe ~= nil then
        inst.components.sentientaxe:Say(STRINGS.LUCY.on_haunt)
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("lucy_axe.png")

    inst.AnimState:SetBank("Lucy_axe")
    inst.AnimState:SetBuild("Lucy_axe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    inst.AttachClassified = AttachClassified
    inst.DetachClassified = DetachClassified
    inst.OnRemoveEntity = OnRemoveEntity

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(.9, .4, .4)
    inst.components.talker.offset = Vector3(0, 0, 0)
    inst.components.talker.symbol = "swap_object"

    --Dedicated server does not need to spawn the local sound fx
    if not TheNet:IsDedicated() then
        inst.localsounds = CreateEntity()
        inst.localsounds:AddTag("FX")
        --[[Non-networked entity]]
        inst.localsounds.entity:AddTransform()
        inst.localsounds.entity:AddSoundEmitter()
        inst.localsounds.entity:SetParent(inst.entity)
        inst.localsounds:Hide()
        inst.localsounds.persists = false
        inst:ListenForEvent("ontalk", ontalk)
        inst:ListenForEvent("donetalking", ondonetalking)
    end

    local swap_data = {sym_build = "swap_lucy_axe", bank = "Lucy_axe"}
    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2}, true, -11, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sentientaxe")

    inst.lucy_classified = SpawnPrefab("lucy_classified")
    inst.lucy_classified.entity:SetParent(inst.entity)
    inst.lucy_classified._parent = inst
    inst.lucy_classified:SetTarget(nil)

    inst._container = nil

    inst._oncontainerownerchanged = function(container)
        topocket(inst, container)
    end

    inst._oncontainerremoved = function()
        unstore(inst)
    end

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    -------
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE * .5)

    -------
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 2)

    -------

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("possessedaxe")
    inst.components.possessedaxe.revert_fx = "lucy_ground_transform_fx"
    inst.components.possessedaxe.transform_fx = "lucy_transform_fx"

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    return inst
end

return Prefab("lucy", fn, assets, prefabs)
