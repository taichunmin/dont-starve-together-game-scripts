require "prefabutil"

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

local function MakeChest(name, bank, build, indestructible, custom_postinit, prefabs)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
        Asset("ANIM", "anim/ui_chest_3x2.zip"),
    }

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

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose

        if not indestructible then
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)

            MakeSmallBurnable(inst, nil, nil, true)
            MakeMediumPropagator(inst)
        end

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        MakeSnowCovered(inst)

        inst.OnSave = onsave 
        inst.OnLoad = onload

        if custom_postinit ~= nil then
            custom_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function pandora_custom_postinit(inst)
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

local function minotuar_custom_postinit(inst)
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

local function water_custom_postinit(inst)
	MakeInventoryFloatable(inst, "med", nil, 0.74)

    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoTaskInTime(0, function(inst)
		inst.components.floater:OnLandedServer()
	end)
end

return MakeChest("treasurechest", "chest", "treasure_chest", false, nil, { "collapse_small" }),
    MakePlacer("treasurechest_placer", "chest", "treasure_chest", "closed"),
    MakeChest("pandoraschest", "pandoras_chest", "pandoras_chest", true, pandora_custom_postinit, { "pandorachest_reset" }),
    MakeChest("minotaurchest", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_custom_postinit, { "collapse_small" }),
	MakeChest("waterchest", "chest", "treasure_chest", true, water_custom_postinit, { "collapse_small" })
