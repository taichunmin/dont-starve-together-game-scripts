local assets =
{
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

---RED
local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:IsHurt() and not owner.components.oldager)
    and (owner.components.hunger and owner.components.hunger.current > 5 )then
        owner.components.health:DoDelta(TUNING.REDAMULET_CONVERSION,false,"redamulet")
        owner.components.hunger:DoDelta(-TUNING.REDAMULET_CONVERSION)
        inst.components.finiteuses:Use(1)
    end
end

local function onequip_red(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "torso_amulets")
    else
        owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")
    end

    inst.task = inst:DoPeriodicTask(TUNING.REDAMULET_CONVERSION_TIME, healowner, nil, owner)
end

local function onunequip_red(inst, owner)
    if owner.sg == nil or owner.sg.currentstate.name ~= "amulet_rebirth" then
        owner.AnimState:ClearOverrideSymbol("swap_body")
    end

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onequiptomodel_red(inst, owner, from_ground)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

---BLUE
local function onequip_blue(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "blueamulet")

    inst.freezefn = function(attacked, data)
        if data and data.attacker and data.attacker.components.freezable then
            data.attacker.components.freezable:AddColdness(0.67)
            data.attacker.components.freezable:SpawnShatterFX()
            inst.components.fueled:DoDelta(-0.03 * inst.components.fueled.maxfuel)
        end
    end

    inst:ListenForEvent("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end

end

local function onunequip_blue(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst:RemoveEventCallback("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
end

local function onequiptomodel_blue(inst, owner, from_ground)
    inst:RemoveEventCallback("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
end

---PURPLE
local function onequip_purple(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "purpleamulet")
    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, true)
    end
end

local function onunequip_purple(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, false)
    end
end

local function onequiptomodel_purple(inst, owner, from_ground)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, false)
    end
end

---GREEN

local function onequip_green(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "greenamulet")
    if owner.components.builder ~= nil then
        owner.components.builder.ingredientmod = TUNING.GREENAMULET_INGREDIENTMOD
    end
    inst.onitembuild = function(owner, data)
        --V2C: backward compatibility so that no data or discounted == nil still consumes a charge
        --     (discounted is newly added; in the past, it would always consume a charge)
        if not (data ~= nil and data.discounted == false) then
            inst.components.finiteuses:Use(1)
        end
    end
    inst:ListenForEvent("consumeingredients", inst.onitembuild, owner)

end

local function onunequip_green(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.builder ~= nil then
        owner.components.builder.ingredientmod = 1
    end
    inst:RemoveEventCallback("consumeingredients", inst.onitembuild, owner)
end

local function onequiptomodel_green(inst, owner, from_ground)
    if owner.components.builder ~= nil then
        owner.components.builder.ingredientmod = 1
    end
    inst:RemoveEventCallback("consumeingredients", inst.onitembuild, owner)
end

---ORANGE
local function pickup(inst, owner)
    local item = FindPickupableItem(owner, TUNING.ORANGEAMULET_RANGE, false)
    if item == nil then
        return
    end

    local didpickup = false
    if item.components.trap ~= nil then
        item.components.trap:Harvest(owner)
        didpickup = true
    end

    if owner.components.minigame_participator ~= nil then
        local minigame = owner.components.minigame_participator:GetMinigame()
        if minigame ~= nil then
            minigame:PushEvent("pickupcheat", { cheater = owner, item = item })
        end
    end

    --Amulet will only ever pick up items one at a time. Even from stacks.
    SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition())

    inst.components.finiteuses:Use(1)

    if not didpickup then
        local item_pos = item:GetPosition()
        if item.components.stackable ~= nil then
            item = item.components.stackable:Get()
        end

        owner.components.inventory:GiveItem(item, nil, item_pos)
    end
end

local function onequip_orange(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")
    inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, pickup, nil, owner)
end

local function onunequip_orange(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onequiptomodel_orange(inst, owner, from_ground)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

---YELLOW
local function onequip_yellow(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "torso_amulets")
    else
        owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "yellowamulet")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end

    if inst._light == nil or not inst._light:IsValid() then
        inst._light = SpawnPrefab("yellowamuletlight")
    end
    inst._light.entity:SetParent(owner.entity)

    if owner.components.bloomer ~= nil then
        owner.components.bloomer:PushBloom(inst, "shaders/anim.ksh", 1)
    else
        owner.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
    
    if inst.skin_equip_sound and owner.SoundEmitter then
        owner.SoundEmitter:PlaySound(inst.skin_equip_sound)
    end
end

local function turnoff_yellow(inst)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
end

local function onunequip_yellow(inst, owner)
    if owner.components.bloomer ~= nil then
        owner.components.bloomer:PopBloom(inst)
    else
        owner.AnimState:ClearBloomEffectHandle()
    end

    owner.AnimState:ClearOverrideSymbol("swap_body")

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    turnoff_yellow(inst)
end

local function onequiptomodel_yellow(inst, owner, from_ground)
    if owner.components.bloomer ~= nil then
        owner.components.bloomer:PopBloom(inst)
    else
        owner.AnimState:ClearBloomEffectHandle()
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    turnoff_yellow(inst)
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	end
end

local function SERVER_PlayFuelSound(inst)
	local owner = inst.components.inventoryitem.owner
	if owner == nil then
		inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	elseif inst.components.equippable:IsEquipped() and owner.SoundEmitter ~= nil then
		owner.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	else
		inst.playfuelsound:push()
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

---COMMON FUNCTIONS
--[[
local function unimplementeditem(inst)
    local player = ThePlayer
    player.components.talker:Say(GetString(player, "ANNOUNCE_UNIMPLEMENTED"))
    if player.components.health.currenthealth > 1 then
        player.components.health:DoDelta(-0.5 * player.components.health.currenthealth)
    end

    if inst.components.useableitem then
        inst.components.useableitem:StopUsingItem()
    end
end
--]]

local function commonfn(anim, tag, should_sink, can_refuel)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("amulets")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.foleysound = "dontstarve/movement/foley/jewlery"

	if can_refuel then
		inst.playfuelsound = net_event(inst.GUID, "amulet.playfuelsound")

		if not TheWorld.ismastersim then
			--delayed because we don't want any old events
			inst:DoTaskInTime(0, inst.ListenForEvent, "amulet.playfuelsound", CLIENT_PlayFuelSound)
		end
	end

    if not should_sink then
        MakeInventoryFloatable(inst, "med", nil, 0.6)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.is_magic_dapperness = true

    inst:AddComponent("inventoryitem")
    if should_sink then
        inst.components.inventoryitem:SetSinks(true)
    end

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.AMULET_SHADOW_LEVEL)

    return inst
end

local function red()
    local inst = commonfn("redamulet", "resurrector", true)

    inst.scrapbook_specialinfo = "REDAMULET"

    if not TheWorld.ismastersim then
        return inst
    end

    -- red amulet now falls off on death, so you HAVE to haunt it
    -- This is more straightforward for prototype purposes, but has side effect of allowing amulet steals
    -- inst.components.inventoryitem.keepondeath = true

    inst.components.equippable:SetOnEquip(onequip_red)
    inst.components.equippable:SetOnUnequip(onunequip_red)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_red)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.REDAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.REDAMULET_USES)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

    return inst
end

local BLUE_HAUNT_MUST_TAGS = { "freezable" }
local BLUE_HAUNT_CANT_TAGS = { "FX", "NOCLICK", "DECOR","INLIMBO" }
local function OnHauntBlue(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 10, BLUE_HAUNT_MUST_TAGS, BLUE_HAUNT_CANT_TAGS)
        for i, v in ipairs(ents) do
            if v.components.freezable ~= nil then
                v.components.freezable:AddColdness(.67)
                v.components.freezable:SpawnShatterFX()
            end
        end
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
    end
end

local function blue()
    local inst = commonfn("blueamulet", "HASHEATER")
    --HASHEATER (from heater component) added to pristine state for optimization

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(onequip_blue)
    inst.components.equippable:SetOnUnequip(onunequip_blue)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_blue)

    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, true)
    inst.components.heater.equippedheat = TUNING.BLUEGEM_COOLER

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.BLUEAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, OnHauntBlue, true, nil, true)

    return inst
end

local function purple()
    local inst = commonfn("purpleamulet")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.PURPLEAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    inst.components.equippable:SetOnEquip(onequip_purple)
    inst.components.equippable:SetOnUnequip(onunequip_purple)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_purple)

    inst.components.equippable.dapperness = -TUNING.DAPPERNESS_MED

    MakeHauntableLaunch(inst)

    return inst
end

local function green()
    local inst = commonfn("greenamulet")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(onequip_green)
    inst.components.equippable:SetOnUnequip(onunequip_green)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_green)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.GREENAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.GREENAMULET_USES)

    MakeHauntableLaunch(inst)

    return inst
end

local function orange()
    local inst = commonfn("orangeamulet", "repairshortaction", nil, true)

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst.components.inspectable.nameoverride = "unimplemented"
    -- inst:AddComponent("useableitem")
    -- inst.components.useableitem:SetOnUseFn(unimplementeditem)
    inst.components.equippable:SetOnEquip(onequip_orange)
    inst.components.equippable:SetOnUnequip(onunequip_orange)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_orange)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.ORANGEAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.ORANGEAMULET_USES)

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.NIGHTMARE
    inst.components.repairable.noannounce = true
	inst.components.repairable.onrepaired = SERVER_PlayFuelSound

    MakeHauntableLaunch(inst)

    return inst
end

local function yellow()
    local inst = commonfn("yellowamulet", nil, nil, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(onequip_yellow)
    inst.components.equippable:SetOnUnequip(onunequip_yellow)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_yellow)
    inst.components.equippable.walkspeedmult = 1.2
    inst.components.inventoryitem:SetOnDroppedFn(turnoff_yellow)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(TUNING.YELLOWAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled.accepting = true
	inst.components.fueled:SetTakeFuelFn(SERVER_PlayFuelSound)

    MakeHauntableLaunch(inst)

    inst._light = nil
    inst.OnRemoveEntity = turnoff_yellow

    return inst
end

local function yellowlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.65)
    inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("amulet", red, assets),
    Prefab("blueamulet", blue, assets),
    Prefab("purpleamulet", purple, assets),
    Prefab("orangeamulet", orange, assets, { "sand_puff" }),
    Prefab("greenamulet", green, assets),
    Prefab("yellowamulet", yellow, assets, { "yellowamuletlight" }),
    Prefab("yellowamuletlight", yellowlightfn)
