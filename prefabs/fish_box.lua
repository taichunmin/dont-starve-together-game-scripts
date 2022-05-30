require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/fish_box.zip"),
    Asset("ANIM", "anim/ui_fish_box_3x4.zip"),
}

local prefabs =
{
    "collapse_small",
	"boat_leak",
}

local FISH_BOX_SCALE = 1.3

local function splash(inst)
	if inst.AnimState:IsCurrentAnimation("opened") then
		inst.AnimState:PlayAnimation("splash")
		inst.AnimState:PushAnimation("opened", false)
	end
	inst.splash_task = inst:DoTaskInTime(3 + math.random() * 3, splash)
end

local function startsplashtask(inst)
	if inst.splash_task ~= nil then
		inst.splash_task:Cancel()
	end
	inst.splash_task = inst:DoTaskInTime(3 + math.random() * 3, splash)
end

local function stopsplashtask(inst)
	if inst.splash_task ~= nil then
		inst.splash_task:Cancel()
		inst.splash_task = nil
	end
end

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.AnimState:PushAnimation("opened", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/open")

	startsplashtask(inst)
end

local function onclose(inst)
	inst.AnimState:PlayAnimation("close")
	inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/close")

	stopsplashtask(inst)
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()

	local x, y, z = inst.Transform:GetWorldPosition()
	local oceanfish_to_spawn = {}

	for i=1,inst.components.container:GetNumSlots() do
		local item = inst.components.container:GetItemInSlot(i)

		if item ~= nil then
			if item.fish_def ~= nil then
				table.insert(oceanfish_to_spawn, item.fish_def.prefab)
				item:Remove()
			else
				inst.components.container:DropItemBySlot(i)
			end
		end
	end

	if #oceanfish_to_spawn > 0 then
		oceanfish_to_spawn = shuffleArray(oceanfish_to_spawn)

		for i=1,math.min(#oceanfish_to_spawn, 5) do
			local water_fish = SpawnPrefab(oceanfish_to_spawn[i])
			water_fish.Transform:SetPosition(x, y, z)

			water_fish.leaving = true
			water_fish.persists = false
		end
	end

    local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("metal")

	local boat = inst:GetCurrentPlatform()
	if boat ~= nil then
		boat:PushEvent("spawnnewboatleak", { pt = Vector3(x, y, z), leak_size = "med_leak", playsoundfx = true })
	end

    inst:Remove()
end

local function onhit(inst, worker)
	if inst.components.container ~= nil then
		if not inst.components.container:IsOpen() then
			inst.AnimState:PlayAnimation("hit_closed")
			inst.AnimState:PushAnimation("closed")
		end

		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/place")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst.Transform:SetScale(FISH_BOX_SCALE, FISH_BOX_SCALE, FISH_BOX_SCALE)

	inst.MiniMapEntity:SetPriority(4)
    inst.MiniMapEntity:SetIcon("fish_box.png")

    inst:AddTag("structure")

    inst.AnimState:SetBank("fish_box")
    inst.AnimState:SetBuild("fish_box")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("fish_box")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.FISH_BOX_PRESERVER_RATE)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("fish_box", fn, assets, prefabs),
    MakePlacer("fish_box_placer", "fish_box", "fish_box", "closed", nil, nil, nil, FISH_BOX_SCALE)
