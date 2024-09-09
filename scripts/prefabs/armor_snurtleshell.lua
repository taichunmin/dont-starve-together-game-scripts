local assets =
{
    Asset("ANIM", "anim/armor_slurtleshell.zip"),
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function ProtectionLevels(inst, data)
    local equippedArmor = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
    if equippedArmor ~= nil then
        if inst.sg:HasStateTag("shell") then
            equippedArmor.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        else
            equippedArmor.components.armor:SetAbsorption(TUNING.ARMORSNURTLESHELL_ABSORPTION)
            equippedArmor.components.useableitem:StopUsingItem()
        end
    end
end

local TARGET_MUST_TAGS = { "_combat" }
local TARGET_CANT_TAGS = { "INLIMBO" }
local function droptargets(inst)
    inst.task = nil

    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and owner.sg:HasStateTag("shell") then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 20, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
        for i, v in ipairs(ents) do
            if v.components.combat ~= nil and v.components.combat.target == owner then
                v.components.combat:SetTarget(nil)
            end
        end
    end
end

local function onuse(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
        owner.sg:GoToState("shell_enter")
        if inst.task ~= nil then
            inst.task:Cancel()
        end
        inst.task = inst:DoTaskInTime(5, droptargets)
    end
end

local function onstopuse(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body_tall", "armor_slurtleshell", "swap_body_tall")
    inst:ListenForEvent("blocked", OnBlocked, owner)
    inst:ListenForEvent("newstate", ProtectionLevels, owner)

    -- check for slurtlehat pairing achievement
    if owner:HasTag("player") then
		local equipped_head = owner.components.inventory ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
		if equipped_head ~= nil and equipped_head.prefab == "slurtlehat" then
			AwardPlayerAchievement("snail_armour_set", owner)
		end
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body_tall")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    inst:RemoveEventCallback("newstate", ProtectionLevels, owner)
    onstopuse(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_slurtleshell")
    inst.AnimState:SetBuild("armor_slurtleshell")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("shell")

    inst.foleysound = "dontstarve/movement/foley/shellarmour"

    MakeInventoryFloatable(inst, "med", 0.2, 0.70)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORSNURTLESHELL, TUNING.ARMORSNURTLESHELL_ABSORPTION)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(onuse)
    inst.components.useableitem:SetOnStopUseFn(onstopuse)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("armorsnurtleshell", fn, assets)
