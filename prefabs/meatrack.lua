require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/meat_rack.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("ANIM", "anim/meat.zip"),

    Asset("ANIM", "anim/meat_monster.zip"),
    Asset("ANIM", "anim/meat_small.zip"),
    Asset("ANIM", "anim/meat_human.zip"),
    Asset("ANIM", "anim/drumstick.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("ANIM", "anim/batwing.zip"),
    Asset("ANIM", "anim/plant_meat.zip"),
    Asset("ANIM", "anim/eel.zip"),
    Asset("ANIM", "anim/kelp.zip"),

    Asset("ANIM", "anim/meatrack_hermit.zip"),
    Asset("MINIMAP_IMAGE", "meatrack_hermit"),
}

local prefabs =
{
    -- everything it can "produce" and might need symbol swaps from
    "smallmeat",
    "smallmeat_dried",
    "monstermeat",
    "monstermeat_dried",
    "humanmeat",
    "humanmeat_dried",
    "meat",
    "meat_dried",
    "drumstick", -- uses smallmeat_dried
    "batwing", --uses smallmeat_dried
    "fish", -- uses smallmeat_dried
    "froglegs", -- uses smallmeat_dried
    "fishmeat", -- uses smallmeat_dried
    "fishmeat_small", -- uses meat_dried
    "eel",
    "collapse_small",
    "kelp",
    "kelp_dried",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.dryer ~= nil then
        inst.components.dryer:DropItem()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.dryer ~= nil and inst.components.dryer:IsDrying() then
            inst.AnimState:PlayAnimation("hit_full")
            inst.AnimState:PushAnimation("drying_pre", false)
            inst.AnimState:PushAnimation("drying_loop", true)
        elseif inst.components.dryer ~= nil and inst.components.dryer:IsDone() then
            inst.AnimState:PlayAnimation("hit_full")
            inst.AnimState:PushAnimation("idle_full", false)
        else
            inst.AnimState:PlayAnimation("hit_empty")
            inst.AnimState:PushAnimation("idle_empty", false)
        end
    end
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.dryer ~= nil then
		local pst = inst.components.dryer.foodtype == FOODTYPE.MEAT and "" or "_NOTMEAT"
        return (inst.components.dryer:IsDone() and "DONE"..pst)
            or (inst.components.dryer:IsDrying() and
                (TheWorld.state.israining and "DRYINGINRAIN"..pst or "DRYING"..pst))
            or nil
    end
end

local function onstartdrying(inst, ingredient, buildfile)
    if POPULATING then
        inst.AnimState:PlayAnimation("drying_loop", true)
    else
        inst.AnimState:PlayAnimation("drying_pre")
        inst.AnimState:PushAnimation("drying_loop", true)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/put_meat_rack")
    inst.AnimState:OverrideSymbol("swap_dried", buildfile or "meat_rack_food", ingredient)
end

local function ondonedrying(inst, product, buildfile)
    if POPULATING then
        inst.AnimState:PlayAnimation("idle_full")
    else
        inst.AnimState:PlayAnimation("drying_pst")
        inst.AnimState:PushAnimation("idle_full", false)
    end
    inst.AnimState:OverrideSymbol("swap_dried", buildfile or "meat_rack_food", product)
end

local function onharvested(inst)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_empty", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/meat_rack_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeMeatrack(name, common_postinit, master_postinit)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon("meatrack.png")

        inst:AddTag("structure")

        MakeSnowCoveredPristine(inst)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        MakeHauntableWork(inst)

        inst:AddComponent("dryer")
        inst.components.dryer:SetStartDryingFn(onstartdrying)
        inst.components.dryer:SetDoneDryingFn(ondonedrying)
        inst.components.dryer:SetOnHarvestFn(onharvested)

        inst:AddComponent("inspectable")

        inst.components.inspectable.getstatus = getstatus
        MakeSnowCovered(inst)
        inst:ListenForEvent("onbuilt", onbuilt)

        inst.OnSave = onsave
        inst.OnLoad = onload

        if master_postinit then
            master_postinit(inst)
        end

        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end


local function meatrack_common(inst)
    inst.AnimState:SetBank("meat_rack")
    inst.AnimState:SetBuild("meat_rack")
    inst.AnimState:PlayAnimation("idle_empty")
end

local function meatrack_hermit(inst)
    inst.MiniMapEntity:SetIcon("meatrack_hermit.png")

    inst.AnimState:SetBank("meatrack_hermit")
    inst.AnimState:SetBuild("meatrack_hermit")
    inst.AnimState:PlayAnimation("idle_empty")

	inst:AddTag("antlion_sinkhole_blocker")

end

local function meatrack_master(inst)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- should be DRY
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
end

local function meatrack_hermit_master(inst)

end


return MakeMeatrack("meatrack", meatrack_common, meatrack_master),
        MakePlacer("meatrack_placer", "meat_rack", "meat_rack", "idle_empty",
        nil, nil, nil, nil, nil, nil,
        function(inst)
            inst.AnimState:Hide("mouseover")
        end),
        MakeMeatrack("meatrack_hermit", meatrack_hermit, meatrack_hermit_master)
