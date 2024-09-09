local assets =
{
    Asset("ANIM", "anim/evergreen_living_wood.zip"),
    Asset("MINIMAP_IMAGE", "livingtree"),
    Asset("MINIMAP_IMAGE", "livingtree_burnt"),
    Asset("MINIMAP_IMAGE", "livingtree_stump"),
}

local prefabs =
{
    "livinglog",
}

local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation("chop_burnt_tall")
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
end

local function Extinguish(inst)
    if inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst.components.lootdropper:SetLoot({})

    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
    end
end

local function OnBurnt(inst)
    inst:DoTaskInTime(0.5, Extinguish)
    inst.AnimState:PlayAnimation("burnt_tall", true)
    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")
    inst.MiniMapEntity:SetIcon("livingtree_burnt.png")
end

local function ondug(inst)
    inst.components.lootdropper:SpawnLootPrefab("livinglog")
    inst:Remove()
end

local function makestump(inst, instant)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("burnable")
    MakeMediumBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("hauntable")
    MakeHauntableIgnite(inst)
    RemovePhysicsColliders(inst)
    if instant then
        inst.AnimState:PlayAnimation("stump")
    else
        inst.AnimState:PushAnimation("stump")
    end
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(ondug)
    inst.components.workable:SetWorkLeft(1)
    inst:AddTag("stump")

    inst.MiniMapEntity:SetIcon("livingtree_stump.png")
end

local function onworked(inst, chopper, workleft)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livingtree_hit")
    inst.AnimState:PlayAnimation("chop")
    inst.AnimState:PushAnimation("idle", true)
end

local function ShakeCamera(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, .5, inst, 6)
end

local function onworkfinish(inst, chopper)
    local pt = inst:GetPosition()
    local hispos = chopper:GetPosition()
    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0

    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livingtree_die")

    if he_right then
        inst.AnimState:PlayAnimation("fallleft")
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation("fallright")
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    inst:DoTaskInTime(.4, ShakeCamera)

    makestump(inst)
end

local function OnHalloweenSetup(inst)
	if not inst:HasTag("burnt") and not inst:HasTag("stump") then
		local x, y, z = inst.Transform:GetWorldPosition()
		inst:Remove()
		local new_tree = SpawnPrefab("livingtree_halloween")
		new_tree.Transform:SetPosition(x, y, z)
		if new_tree.components.growable ~= nil then
			new_tree.components.growable:SetStage(#new_tree.components.growable.stages)
		end
	end
end

local function onsave(inst, data)
    if inst:HasTag("stump") then
        data.stump = true
    end

    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.stump then
            makestump(inst, true)
            if data.burnt or inst:HasTag("burnt") then
                DefaultBurntFn(inst)
            end
        elseif data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --livingtree_root deployspacing/2
    MakeObstaclePhysics(inst, .75)

    inst.MiniMapEntity:SetIcon("livingtree.png")

    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.AnimState:SetBank("evergreen_living_wood")
    inst.AnimState:SetBuild("evergreen_living_wood")
    inst.AnimState:PlayAnimation("idle", true)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"livinglog", "livinglog"})
    if TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode() then
        inst.components.lootdropper:AddChanceLoot("reskin_tool", 0.25)
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(20)
    inst.components.workable:SetOnWorkCallback(onworked)
    inst.components.workable:SetOnFinishCallback(onworkfinish)

    MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeMediumPropagator(inst)
    MakeHauntableWorkAndIgnite(inst)

    MakeSnowCovered(inst)

	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		inst:DoTaskInTime(0, OnHalloweenSetup)
	end

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("livingtree", fn, assets, prefabs)
