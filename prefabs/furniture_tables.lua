local function GetStatus(inst)
	return (inst:HasTag("burnt") and "BURNT") or
		(inst:HasTag("hasfurnituredecoritem") and "HAS_ITEM") or
		nil
end

--
local function AbleToAcceptDecor(inst, item, giver)
    return (item ~= nil)
end

local function OnDecorGiven(inst, item, giver)
    if not item then return end

    inst.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/table/food")

    if item.Physics then item.Physics:SetActive(false) end
    if item.Follower then item.Follower:FollowSymbol(inst.GUID, "swap_object") end
end

local function OnDecorTaken(inst, item)
    -- Item might be nil if it's taken in a way that destroys it.
    if item then
        if item.Physics then item.Physics:SetActive(true) end
        if item.Follower then item.Follower:StopFollowing() end
    end
end

--
local function TossDecorItem(inst)
    local item = inst.components.furnituredecortaker:TakeItem()
    if item then
        inst.components.lootdropper:FlingItem(item)
    end
end

local function OnHammer(inst, worker, workleft, workcount)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function OnHammered(inst, worker)
    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()

    TossDecorItem(inst)

    inst:Remove()
end

--
local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)

    inst.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")
end

--
local function on_ignite(inst, source, doer)
    inst._controlled_burn = doer and doer:HasTag("controlled_burner") or source and source:HasTag("controlled_burner") or nil
    DefaultBurnFn(inst)
end
local function on_extinguish(inst)
    inst._controlled_burn = nil
    DefaultExtinguishFn(inst)
end
local function OnBurnt(inst)
    local item = inst.components.furnituredecortaker:TakeItem()
    if item then
        inst.components.lootdropper:FlingItem(item)
        if not inst._controlled_burn and item.components.burnable ~= nil then
            item.components.burnable:Ignite()
        end
    end

    -- TakeItem will set this to true, but we're burnt now, so we don't want to be enabled.
    inst.components.furnituredecortaker:SetEnabled(false)
end

--
local function OnSave(inst, data)
    if (inst.components.burnable and inst.components.burnable:IsBurning()) or inst:HasTag("burnt") then
        data.burnt = true
    end
    data.controlled_burn = inst._controlled_burn
end

local function OnLoad(inst, data)
    if data then
        inst._controlled_burn = data.controlled_burn
    end
end

local function OnLoadPostPass(inst, newents, data)
    -- Do this in postpass so the decor component can properly load a decor item if it has one.
    if data and data.burnt then
        inst:PushEvent("onburnt")
        inst.components.burnable.onburnt(inst)
    end
end

--
local function AddTable(results, prefab_name, data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.bank..".zip"),
        Asset("ANIM", "anim/"..data.build..".zip"),
    }

    local prefabs =
    {
        "collapse_small",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:SetDeploySmartRadius(data.deploy_smart_radius) --recipe min_spacing/2

        MakeObstaclePhysics(inst, 0.7)

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetFinalOffset(-1)

        inst.Transform:SetFourFaced()

        inst:AddTag("decortable")
        inst:AddTag("structure")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        --
        local furnituredecortaker = inst:AddComponent("furnituredecortaker")
        furnituredecortaker.abletoaccepttest = AbleToAcceptDecor
        furnituredecortaker.ondecorgiven = OnDecorGiven
        furnituredecortaker.ondecortaken = OnDecorTaken

        --
        local inspectable = inst:AddComponent("inspectable")
        inspectable.getstatus = GetStatus
        inspectable.nameoverride = "WOOD_TABLE"

        --
        inst:AddComponent("lootdropper")

        --
        local savedrotation = inst:AddComponent("savedrotation")
        savedrotation.dodelayedpostpassapply = true

        --
        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.HAMMER)
        workable:SetWorkLeft(5)
        workable:SetOnWorkCallback(OnHammer)
        workable:SetOnFinishCallback(OnHammered)

        --
        MakeHauntableWork(inst)

        --
        MakeMediumBurnable(inst, nil, nil, true)
        inst.components.burnable:SetOnIgniteFn(on_ignite)
        inst.components.burnable:SetOnExtinguishFn(on_extinguish)
        MakeMediumPropagator(inst)

        --
        inst:ListenForEvent("onbuilt", OnBuilt)
        inst:ListenForEvent("onburnt", OnBurnt)
        inst:ListenForEvent("ondeconstructstructure", TossDecorItem)

        --
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnLoadPostPass = OnLoadPostPass

        return inst
    end

    table.insert(results, Prefab(prefab_name, fn, assets, prefabs))
    table.insert(results, MakePlacer(prefab_name.."_placer", data.bank, data.build, "idle", nil, nil, nil, nil, 105, "four"))
end

local result_tables = {}
local WOOD_TABLE_DATA = {
    bank = "wood_table",
    build = "wood_table_round",
	deploy_smart_radius = 0.875,
}
AddTable(result_tables, "wood_table_round", WOOD_TABLE_DATA)

local WOOD_TABLE_2_DATA = {
    bank = "wood_table",
    build = "wood_table_square",
	deploy_smart_radius = 0.875,
}
AddTable(result_tables, "wood_table_square", WOOD_TABLE_2_DATA)

return unpack(result_tables)