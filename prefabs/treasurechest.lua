require "prefabutil"

local SUNKEN_PHYSICS_RADIUS = .45

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeChest(name, bank, build, indestructible, master_postinit, prefabs, assets, common_postinit, force_non_burnable)
    local default_assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
        Asset("ANIM", "anim/ui_chest_3x2.zip"),
    }
    assets = assets ~= nil and JoinArrays(assets, default_assets) or default_assets

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon(name..".png")

        inst:AddTag("structure")
        inst:AddTag("chest")

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("closed")

		MakeSnowCoveredPristine(inst)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true


        if not indestructible then
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)

            if not force_non_burnable then
                MakeSmallBurnable(inst, nil, nil, true)
                MakeMediumPropagator(inst)
            end
        end

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        MakeSnowCovered(inst)

		-- Save / load is extended by some prefab variants
        inst.OnSave = onsave
        inst.OnLoad = onload

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------
--[[ pandora ]]
--------------------------------------------------------------------------

local function pandora_master_postinit(inst)
    inst:ListenForEvent("resetruins", function()
        local was_open = inst.components.container:IsOpen()

        if inst.components.scenariorunner == nil then
            inst.components.container:Close()
            inst.components.container:DropEverythingWithTag("irreplaceable")
            inst.components.container:DestroyContents()

            inst:AddComponent("scenariorunner")
            inst.components.scenariorunner:SetScript("chest_labyrinth")
            inst.components.scenariorunner:Run()
        end

        if not inst:IsAsleep() then
            if not was_open then
                inst.AnimState:PlayAnimation("hit")
                inst.AnimState:PushAnimation("closed", false)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/chest_retrap")
            end

            SpawnPrefab("pandorachest_reset").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end, TheWorld)
end

--------------------------------------------------------------------------
--[[ minotaur ]]
--------------------------------------------------------------------------

local function minotuar_master_postinit(inst)
    inst:ListenForEvent("resetruins", function()
        inst.components.container:Close()
        inst.components.container:DropEverything()

        if not inst:IsAsleep() then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetMaterial("wood")
        end

        inst:Remove()
    end, TheWorld)
end


--------------------------------------------------------------------------
--[[ Terrarium ]]
--------------------------------------------------------------------------

local function terrarium_GetStatus(inst)
    return inst.fx ~= nil and "SHIMMER" 
			or inst:HasTag("burnt") and "BURNT"
			or nil
end

local function terrarium_removefx(inst)
	if inst.fx ~= nil then
		inst.fx:Remove()
		inst.fx = nil
		inst:RemoveEventCallback("onburnt", terrarium_removefx)
		inst:RemoveEventCallback("onopen", terrarium_removefx)
		inst.SoundEmitter:KillSound("shimmer")
	end
end

local function terrarium_master_postinit(inst)
    inst.components.inspectable.getstatus = terrarium_GetStatus

	if TUNING.SPAWN_EYEOFTERROR then
		inst:DoTaskInTime(0, function(i)
			if i.components.scenariorunner ~= nil then
				i.fx = SpawnPrefab("terrariumchest_fx")
				i.fx.entity:SetParent(i.entity)

				i:ListenForEvent("onburnt", terrarium_removefx)
				i:ListenForEvent("onopen", terrarium_removefx)

				inst.SoundEmitter:PlaySound("terraria1/terrarium/shimmer_chest_lp", "shimmer")
			end
		end)
	end
end

local function terrariumchest_fx_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBuild("terrariumchest_fx")
	inst.AnimState:SetBank("terrariumchest_fx")
	inst.AnimState:PlayAnimation("idle_back", true)
	inst.AnimState:SetFinalOffset(1)
	

	if not TheNet:IsDedicated() then
		local fx_front = CreateEntity()
		fx_front.entity:AddTransform()
		fx_front.entity:AddAnimState()
		fx_front.entity:SetParent(inst.entity)

		fx_front:AddTag("FX")
		fx_front:AddTag("CLASSIFIED")

		fx_front.AnimState:SetBuild("terrariumchest_fx")
		fx_front.AnimState:SetBank("terrariumchest_fx")
		fx_front.AnimState:PlayAnimation("idle_front", true)
		fx_front.AnimState:SetFinalOffset(-3)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------
--[[ sunken ]]
--------------------------------------------------------------------------

local function sunken_onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            inst.components.container:Close()
        end
    end
end

local function sunken_OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function sunken_OnEquip(inst, owner)
    if inst.components.container ~= nil then
		inst.components.container:Close()
	end
    owner.AnimState:OverrideSymbol("swap_body", "swap_sunken_treasurechest", "swap_body")
end

local function sunken_OnSubmerge(inst)
	if inst.components.container ~= nil then
		inst.components.container:Close()
	end
end

local function sunken_GetStatus(inst)
    return (inst.components.container ~= nil and not inst.components.container.canbeopened) and "LOCKED" or nil
end

local function sunken_common_postinit(inst)
	inst:AddTag("heavy")

	MakeHeavyObstaclePhysics(inst, SUNKEN_PHYSICS_RADIUS)
	inst:SetPhysicsRadiusOverride(SUNKEN_PHYSICS_RADIUS)
end

local function sunken_master_postinit(inst)
    inst.components.workable:SetOnWorkCallback(sunken_onhit)

    inst.components.inspectable.getstatus = sunken_GetStatus

	inst:AddComponent("heavyobstaclephysics")
	inst.components.heavyobstaclephysics:SetRadius(SUNKEN_PHYSICS_RADIUS)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(sunken_OnEquip)
    inst.components.equippable:SetOnUnequip(sunken_OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst.components.container.canbeopened = false

	inst:AddComponent("submersible")
	inst:AddComponent("symbolswapdata")
    inst.components.symbolswapdata:SetData("swap_sunken_treasurechest", "swap_body")

	inst:ListenForEvent("on_submerge", sunken_OnSubmerge)
end

return MakeChest("treasurechest", "chest", "treasure_chest", false, nil, { "collapse_small" }),
    MakePlacer("treasurechest_placer", "chest", "treasure_chest", "closed"),
    MakeChest("pandoraschest", "pandoras_chest", "pandoras_chest", true, pandora_master_postinit, { "pandorachest_reset" }),
    MakeChest("minotaurchest", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }),
    MakeChest("terrariumchest", "chest", "treasurechest_terrarium", false, terrarium_master_postinit, { "collapse_small", "terrariumchest_fx" }, { Asset("ANIM", "anim/treasurechest_terrarium.zip") }),
	Prefab("terrariumchest_fx", terrariumchest_fx_fn, { Asset("ANIM", "anim/terrariumchest_fx.zip") }, { "collapse_small" }),
	MakeChest("sunkenchest", "sunken_treasurechest", "sunken_treasurechest", false, sunken_master_postinit, { "collapse_small", "underwater_salvageable", "splash_green" }, { Asset("ANIM", "anim/swap_sunken_treasurechest.zip") }, sunken_common_postinit, true)
