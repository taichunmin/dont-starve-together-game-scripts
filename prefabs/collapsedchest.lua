local prefabs =
{
	"construction_rebuild_container",
	"collapse_small",
}

local function OnPicked(inst, picker, loot)
	local empty = true
	if inst.chest and inst.chest.components.container then
		local loots = {}
		for k, v in pairs(inst.chest.components.container.slots) do
			table.insert(loots, v)
		end
		if #loots > 0 then
			local item = loots[math.random(#loots)]
			if picker and picker.components.inventory then
				item = inst.chest.components.container:RemoveItem(item, true, nil, true)
				picker.components.inventory:GiveItem(item, nil, inst:GetPosition())
			else
				local slot = inst.chest.components.container:GetItemSlot(item)
				inst.chest.components.container:DropItemBySlot(slot, inst:GetPosition(), true)
			end
		end
		empty = inst.chest.components.container:IsEmpty()
	end
	if empty then
		inst.components.constructionsite:DropAllMaterials()
		local fx = SpawnPrefab("collapse_small")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx:SetMaterial("wood")
		inst:Remove()
	elseif inst.burnt then
		inst.AnimState:PlayAnimation("collapsed_hit_burnt")
		inst.AnimState:PushAnimation("collapsed_burnt", false)
	else
		inst.AnimState:PlayAnimation("collapsed_hit")
		inst.AnimState:PushAnimation("collapsed_idle", false)
	end
end

local function OnSink(inst, data)
	if inst.chest and inst.chest.components.container then
		local pos = inst:GetPosition()
		inst.chest.components.container:DropEverything(pos, true)
		inst.chest.components.container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS, pos)
	end
	inst.components.constructionsite:DropAllMaterials()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function SetChest(inst, chest, burnt)
	inst.chest = chest
	if chest.components.workable then
		chest.components.workable:SetWorkable(false)
	end
	chest:RemoveFromScene()
	chest.entity:SetParent(inst.entity)
	chest.Transform:SetPosition(0, 0, 0)

	if burnt then
		inst.burnt = true
		inst.AnimState:PlayAnimation("collapsed_burnt")
	end
end

local function OnConstructed(inst, doer)
	if inst.components.constructionsite:IsComplete() then
		if inst.chest then
			inst.chest.entity:SetParent(nil)
			inst.chest.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.chest:ReturnToScene()
			if inst.chest.components.workable then
				inst.chest.components.workable:SetWorkable(true)
			end
			inst.chest:PushEvent("restoredfromcollapsed")
		end
		inst:Remove()
	else
		if inst.burnt then
			inst.AnimState:PlayAnimation("collapsed_hit_burnt")
			inst.AnimState:PushAnimation("collapsed_burnt", false)
		else
			inst.AnimState:PlayAnimation("collapsed_hit")
			inst.AnimState:PushAnimation("collapsed_idle", false)
		end
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_wood")
	end
end

local function OnSave(inst, data)
	data.burnt = inst.burnt or nil

	if inst.chest then
		local refs
		data.chest, refs = inst.chest:GetSaveRecord()
		return refs
	end
end

local function OnLoad(inst, data, newents)
	if data then
		if data.chest then
			local chest = SpawnSaveRecord(data.chest, newents)
			if chest then
				inst:SetChest(chest)
			end
		end
		if data.burnt then
			inst.burnt = true
			inst.AnimState:PlayAnimation("collapsed_burnt")
		end
	end
end

local function MakeCollapsedChest(name, build, bank)
	local assets =
	{
		Asset("ANIM", "anim/"..build..".zip"),
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation("collapsed_idle")

		inst:AddTag("pickable_rummage_str")

		--constructionsite (from constructionsite component) added to pristine state for optimization
		inst:AddTag("constructionsite")

		--Rebuild action strings.
		inst:AddTag("rebuildconstructionsite")

		inst:SetPrefabNameOverride("collapsedchest")

		MakeSnowCoveredPristine(inst)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("constructionsite")
		inst.components.constructionsite:SetConstructionPrefab("construction_rebuild_container")
		inst.components.constructionsite:SetOnConstructedFn(OnConstructed)

		inst:AddComponent("pickable")
		inst.components.pickable.picksound = "dontstarve/wilson/pickup_wood"
		inst.components.pickable.onpickedfn = OnPicked
		inst.components.pickable:SetUp(nil, 0)

		inst:AddComponent("hauntable")
		inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

		inst:ListenForEvent("onsink", OnSink)

		MakeSnowCovered(inst)

		inst.SetChest = SetChest
		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

		return inst
	end

	return Prefab(name, fn, assets)
end

return MakeCollapsedChest("collapsed_treasurechest", "treasure_chest_upgraded", "chest_upgraded"),
	MakeCollapsedChest("collapsed_dragonflychest", "dragonfly_chest_upgraded", "dragonfly_chest_upgraded")
