require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/catcoon_den.zip"),
}

local prefabs =
{
    "catcoon",
    "log",
    "rope",
    "twigs",
    "collapse_small",
	"trinket_22",
}

SetSharedLootTable( 'catcoonden',
{
    {'log',			1.00},
    {'log',			1.00},
    {'twigs',		1.00},
    {'twigs',		1.00},
    --{'trinket_22',	1.00},
})

local MAX_LIVES = 9

local function onhammered(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    inst.components.lootdropper:DropLoot()
    inst.components.inventory:DropEverything(false, true)

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onhit(inst)
    if not inst.playing_dead_anim then
        inst.AnimState:PlayAnimation("hit", false)
    end
end

local function OnEntityWake(inst)
    if inst.lives_left <= 0 and inst.delay_end <= GetTime() then
        inst.lives_left = MAX_LIVES
	    inst.components.activatable.inactive = true

        if inst.components.childspawner ~= nil then
            inst.components.childspawner:SetMaxChildren(1)
            inst.components.childspawner:StartRegen()
            inst.components.childspawner:StartSpawning()
        end
		inst.components.inventory:ForEachItem(function(v) v:Remove() end)
    end
    if inst.playing_dead_anim then
        if inst.lives_left > 0 then
            inst.playing_dead_anim = nil
            inst.AnimState:PlayAnimation("idle")
        end
    elseif inst.lives_left <= 0 then
        inst.playing_dead_anim = true
        inst.AnimState:PlayAnimation("dead", true)
		inst.components.inventory:ForEachItem(function(v) v:Remove() end)
	    inst.components.activatable.inactive = false

    end
end

local function OnEntitySleep(inst)
	if inst.lives_left <= 0 then
		inst.components.inventory:ForEachItem(function(v) v:Remove() end)
	end
end

local function OnChildKilled(inst, child)
    inst.lives_left = inst.lives_left - 1
    if inst.lives_left <= 0 then
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StopRegen()
            inst.components.childspawner:StopSpawning()
            inst.components.childspawner:SetMaxChildren(0)
        end

        inst.delay_end = GetTime() + TUNING.CATCOONDEN_REPAIR_TIME + (TheWorld.state.season ~= "summer" and (math.random() * TUNING.CATCOONDEN_REPAIR_TIME_VAR) or 0)
    end
end


local function OnInventoryFull(inst, leftovers)
	if leftovers ~= nil then
		local target_slot, target_age = nil, TheWorld.components.worldstate:GetWorldAge() + 1
		for k, age in pairs(inst._inv_age) do
			if age < target_age then
				target_age = age
				target_slot = k
			end
		end

		if target_slot ~= nil then
			local inv = inst.components.inventory
			local old_item = inv:RemoveItemBySlot(target_slot)
			if old_item ~= nil then
				old_item:Remove()
			end
			inv:GiveItem(leftovers, target_slot)
		end
	end
end

local function OnCachedItemAtHome(inst, data)
	if data ~= nil and data.slot ~= nil and not POPULATING then
		inst._inv_age[data.slot] = TheWorld.components.worldstate:GetWorldAge()
	end
end

local function CacheItemsAtHome(inst, catcoon)
	catcoon.components.inventory:TransferInventory(inst)
end

local function OnRansacked(inst, doer)
    inst.components.activatable.inactive = true

	if doer ~= nil then
		for k, child in pairs(inst.components.childspawner.childrenoutside) do
			if child:IsNear(inst, TUNING.CATCOON_DEN_LEASH_MAX_DIST) then
				if child.components.follower ~= nil and child.components.follower.leader == doer then
					child.components.follower:StopFollowing()
				end

				child.components.combat:SuggestTarget(doer) 
			end
		end
	end

	if inst.components.childspawner ~= nil then
		inst.components.childspawner:ReleaseAllChildren(doer)
	end

	for i = 1, inst.components.inventory.maxslots do
		local item = inst.components.inventory:GetItemInSlot(i)
		if item ~= nil then
			inst.components.inventory:DropItem(item, true, true)
			inst._inv_age[i] = 0
			return true
		end
	end

	return false, "EMPTY_CATCOONDEN"
end

local function onsave(inst, data)
    if inst.lives_left > 0 then
        data.lives_left = inst.lives_left
    elseif inst.delay_end > GetTime() then
        data.delay_remaining = inst.delay_end - GetTime()
    end
	data._inv_age = inst._inv_age
end

local function onload(inst, data)
    if data ~= nil then
		if data._inv_age ~= nil then
			for i = 1, inst.components.inventory.maxslots do
				inst._inv_age[i] = data._inv_age[i] or 0
			end
		end

		inst.lives_left = data.lives_left or 0
		if inst.lives_left <= 0 then
			if inst.components.childspawner ~= nil then
				inst.components.childspawner:StopRegen()
				inst.components.childspawner:StopSpawning()
				inst.components.childspawner:SetMaxChildren(0)
			end
            inst.delay_end = GetTime() + (data.delay_remaining or 0)
		end
    end
end

local function getstatus(inst, viewer)
    return inst.lives_left <= 0 and "EMPTY" or nil
end

local function canspawn(inst)
    return not (TheWorld.state.israining and inst.components.rainimmunity == nil)
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.CATCOONDEN_RELEASE_TIME, TUNING.CATCOONDEN_REGEN_TIME)
end

local function GetActivateVerb(inst)
	return "RANSACK"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("catcoonden.png")

    inst.AnimState:SetBank("catcoon_den")
    inst.AnimState:SetBuild("catcoon_den")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("beaverchewable") -- by werebeaver
    inst:AddTag("catcoonden")
    inst:AddTag("no_hideandseek")

	inst.GetActivateVerb = GetActivateVerb

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -------------------
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "catcoon"
    inst.components.childspawner:SetRegenPeriod(TUNING.CATCOONDEN_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.CATCOONDEN_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.CATCOONDEN_MAXCHILDREN)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.CATCOONDEN_RELEASE_TIME, TUNING.CATCOONDEN_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.CATCOONDEN_REGEN_TIME, TUNING.CATCOONDEN_ENABLED)
    if not TUNING.CATCOONDEN_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = TUNING.CATCOONDEN_INV_SIZE
	inst.components.inventory.HandleLeftoversFn = OnInventoryFull
	inst.CacheItemsAtHome = CacheItemsAtHome	-- after the max slots has been reached, the oldest items will be removed to make room for the new items
	inst._inv_age = {}
	for i = 1, TUNING.CATCOONDEN_INV_SIZE do
		inst._inv_age[i] = 0					-- initialized for retrofitting
	end
	inst:ListenForEvent("gotnewitem", OnCachedItemAtHome)

    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()

    inst.playing_dead_anim = nil
    inst.delay_end = 0
    inst.lives_left = MAX_LIVES
    inst.components.childspawner.onchildkilledfn = OnChildKilled

    ---------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('catcoonden')
	
	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnRansacked
    inst.components.activatable.inactive = true

    MakeMediumBurnable(inst)
    AddToRegrowthManager(inst)
    MakeSmallPropagator(inst)

    ---------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst)

    inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableIgnite(inst)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("catcoonden", fn, assets, prefabs)
