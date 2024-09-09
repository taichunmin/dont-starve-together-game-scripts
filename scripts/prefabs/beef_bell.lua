local assets =
{
    Asset("ANIM", "anim/cowbell.zip"),

    Asset("INV_IMAGE", "beef_bell"),
    Asset("INV_IMAGE", "beef_bell_linked"),
}

local function on_player_dismounted(inst, data)
    local mount = data and data.target or nil
    if mount and mount:IsValid() then
        mount:PushEvent("despawn")
    end
end
local function on_player_despawned(inst)
    for beef, _ in pairs(inst.components.leader.followers) do
		if not beef.components.health:IsDead() then
            beef._marked_for_despawn = true -- Used inside beefalo prefab.
            local dismounting = false
			if beef.components.rideable ~= nil then
				beef.components.rideable.canride = false
                local rider = beef.components.rideable.rider
                if rider and rider.components.rider then
                    dismounting = true
                    rider.components.rider:Dismount()
                    rider:ListenForEvent("dismounted", on_player_dismounted)
                end
			end
			if beef.components.health ~= nil then
				beef.components.health:SetInvincible(true)
			end

            if not dismounting then
                beef:PushEvent("despawn")
            end
        end
    end
end

local function get_other_player_linked_bell(inst, other)
    if other.components.inventory ~= nil then
        return other.components.inventory:FindItem(function(item)
            return (item ~= inst) and (item.prefab == "beef_bell") and item:_HasBeefalo()
        end)
    elseif other.components.container ~= nil then
        return other.components.container:FindItem(function(item)
            return (item ~= inst) and (item.prefab == "beef_bell") and item:_HasBeefalo()
        end)
    else
        return nil
    end
end

local function on_put_in_inventory(inst, owner)
	-- If the bell being picked up has a beefalo...
	if owner ~= nil and inst:_HasBeefalo() then
		owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
		-- ...look for another bell in the picking up player's inventory and drop it.
		local other_bell = get_other_player_linked_bell(inst, owner)
		if other_bell ~= nil then
			if owner.components.inventory ~= nil then
				if owner:HasTag("player") then
					owner.components.inventory:DropItem(other_bell, true, true)
				end
			elseif owner.components.container ~= nil and owner.components.inventoryitem ~= nil then
				--backpacks can be picked up, so don't allow multiple bells
				owner.components.container:DropItem(other_bell)
			end
		end
    end
end

local function cleanup_bell(inst)
    inst:RemoveTag("nobundling")
    inst.components.inventoryitem:ChangeImageName("beef_bell")
    inst.AnimState:PlayAnimation("idle1", true)
end

local function on_beef_disappeared(inst, beef)
    cleanup_bell(inst)

    inst.components.useabletargeteditem:StopUsingItem()
end

local function has_beefalo(inst)
    return inst.components.leader:CountFollowers() > 0
end

local function get_beefalo(inst)
    for beef, v in pairs(inst.components.leader.followers) do
        if v then
            return beef
        end
    end

    return nil
end

local function on_used_on_beefalo(inst, target, user)
    if target.SetBeefBellOwner ~= nil then

        -- This may run with a nil user on load.
        if user ~= nil and get_other_player_linked_bell(inst, user) ~= nil then
            return false, "BEEF_BELL_HAS_BEEF_ALREADY"
        end

        local beef_set_successful, failreason = target:SetBeefBellOwner(inst, user)

        if beef_set_successful then
            inst.components.inventoryitem:ChangeImageName("beef_bell_linked")
            inst.AnimState:PlayAnimation("idle2", true)
            inst:AddTag("nobundling")
        end

        if failreason == nil then
            return beef_set_successful
        else
            local full_failreason = string.upper(inst.prefab).."_"..failreason
            return beef_set_successful, full_failreason
        end
    else
        return false, "BEEF_BELL_INVALID_TARGET"
    end
end

local function on_stop_use(inst)
    -- drop skins.
    if inst:GetBeefalo() then
        inst:GetBeefalo():UnSkin()
    end

    inst.components.leader:RemoveAllFollowers()

    cleanup_bell(inst)
end

local function on_bell_save(inst, data)
    for beef, _ in pairs(inst.components.leader.followers) do
        data.clothing = (beef.components.skinner_beefalo
                and beef.components.skinner_beefalo.clothing)
                or nil
        data.beef_record = beef:GetSaveRecord()
        break
    end
end

local function on_bell_load(inst, data)
    if data and data.beef_record then
        local beef = SpawnSaveRecord(data.beef_record)
        if beef ~= nil then
            inst.components.useabletargeteditem:StartUsingItem(beef)
            if data.clothing then
                beef.components.skinner_beefalo:reloadclothing(data.clothing)
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cowbell")
    inst.AnimState:SetBuild("cowbell")
    inst.AnimState:PlayAnimation("idle1", true)

    MakeInventoryFloatable(inst)

    inst:AddTag("bell")
    inst:AddTag("donotautopick")

    inst.scrapbook_specialinfo = "BEEFBELL"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(on_put_in_inventory)

    inst:AddComponent("useabletargeteditem")
    inst.components.useabletargeteditem:SetTargetPrefab("beefalo")
    inst.components.useabletargeteditem:SetOnUseFn(on_used_on_beefalo)
    inst.components.useabletargeteditem:SetOnStopUseFn(on_stop_use)
    inst.components.useabletargeteditem:SetInventoryDisable(true)

    inst:AddComponent("leader")
    inst.components.leader.onremovefollower = on_beef_disappeared

    inst:AddComponent("migrationpetowner")
    inst.components.migrationpetowner:SetPetFn(get_beefalo)

    inst._HasBeefalo = has_beefalo
    inst.GetBeefalo = get_beefalo
    inst.OnSave = on_bell_save
    inst.OnLoad = on_bell_load

    inst:ListenForEvent("player_despawn", on_player_despawned)

    return inst
end

return Prefab("beef_bell", fn, assets)
