require "prefabutil"

local prefabs =
{
    "collapse_small",
}

local assets =
{
    Asset("ANIM", "anim/sisturn.zip"),
	Asset("ANIM", "anim/ui_chest_2x2.zip"),
}

local FLOWER_LAYERS =
{
	"flower1_roof",
	"flower2_roof",
	"flower1",
	"flower2",
}

local function IsFullOfFlowers(inst)
	return inst.components.container ~= nil and inst.components.container:IsFull()
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/hit")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")

		if inst.components.container ~= nil then
			inst.components.container:DropEverything()
		end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/hit")
end

local function update_saityaura(inst)
	if IsFullOfFlowers(inst) then
		if inst.components.sanityaura == nil then
			inst:AddComponent("sanityaura")
		end
		inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
	elseif inst.components.sanityaura ~= nil then
		inst:RemoveComponent("sanityaura")
	end
end

local function update_idle_anim(inst)
    if inst:HasTag("burnt") then
		return
	end

	if IsFullOfFlowers(inst) then
		inst.AnimState:PlayAnimation("on_pre")
		inst.AnimState:PushAnimation("on", true)
        inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/sisturn/LP","sisturn_on")
	else
		inst.AnimState:PlayAnimation("on_pst")
		inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("sisturn_on")
	end
end

local function RemoveDecor(inst, data)
    if data ~= nil and data.slot ~= nil and FLOWER_LAYERS[data.slot] then
		inst.AnimState:Hide(FLOWER_LAYERS[data.slot])
    end
	update_saityaura(inst)
	update_idle_anim(inst)
	TheWorld:PushEvent("ms_updatesisturnstate", {inst = inst, is_active = IsFullOfFlowers(inst)})
end

local function AddDecor(inst, data)
    if data ~= nil and data.slot ~= nil and FLOWER_LAYERS[data.slot] and not inst:HasTag("burnt") then
		inst.AnimState:Show(FLOWER_LAYERS[data.slot])
    end
	update_saityaura(inst)
	update_idle_anim(inst)

	local is_full = IsFullOfFlowers(inst)
	TheWorld:PushEvent("ms_updatesisturnstate", {inst = inst, is_active = is_full})

	local doer = is_full and inst.components.container ~= nil and inst.components.container.currentuser or nil
	if doer ~= nil and doer.components.talker ~= nil and doer:HasTag("ghostlyfriend") then
		doer.components.talker:Say(GetString(doer, "ANNOUNCE_SISTURN_FULL"), nil, nil, true)
	end
end

local function getstatus(inst)
	local num_decor = inst.components.container ~= nil and inst.components.container:NumItems() or 0
	local num_slots = inst.components.container ~= nil and inst.components.container.numslots or 1
	return num_decor >= num_slots and "LOTS_OF_FLOWERS"
			or num_decor > 0 and "SOME_FLOWERS"
			or nil
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.burnt and inst.components.burnable ~= nil then
		inst.components.burnable.onburnt(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .5)

    inst:AddTag("structure")

    inst.AnimState:SetBank("sisturn")
    inst.AnimState:SetBuild("sisturn")
    inst.AnimState:PlayAnimation("idle")
	for _, v in ipairs(FLOWER_LAYERS) do
		inst.AnimState:Hide(v)
	end

	inst.MiniMapEntity:SetIcon("sisturn.png")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sisturn")


    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    inst:ListenForEvent("itemget", AddDecor)
    inst:ListenForEvent("itemlose", RemoveDecor)
    inst:ListenForEvent("onbuilt", onbuilt)

	if TheWorld.components.sisturnregistry == nil then
		TheWorld:AddComponent("sisturnregistry")
	end
	TheWorld.components.sisturnregistry:Register(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    return inst
end

return Prefab("sisturn", fn, assets, prefabs),
       MakePlacer("sisturn_placer", "sisturn", "sisturn", "placer")
