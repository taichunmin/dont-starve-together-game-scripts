require "prefabutil"

local tacklecontainer_sounds =
{
    open = "hookline_2/characters/hermit/tacklebox/small_open",
    close = "hookline_2/characters/hermit/tacklebox/small_close",
}

local supertacklecontainer_sounds =
{
    open = "hookline_2/characters/hermit/tacklebox/large_open",
    close = "hookline_2/characters/hermit/tacklebox/large_close",
}

local function onopen(inst)
    if inst:HasTag("burnt") then
        return
    end

    inst.AnimState:PlayAnimation("open")
    local skin_name = inst:GetSkinName() or inst._baseinventoryimagename
    inst.components.inventoryitem:ChangeImageName(skin_name .. "_open")
    inst.SoundEmitter:PlaySound(inst._sounds.open)
end

local function onclose(inst)
    if inst:HasTag("burnt") then
        return
    end
    
    if inst.components.inventoryitem.owner == nil then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
    else
        inst.AnimState:PlayAnimation("closed", false)
    end
    local skin_name = inst:GetSkinName()
    if skin_name then
        inst.components.inventoryitem:ChangeImageName(skin_name)
    else
        inst.components.inventoryitem:ChangeImageName()
    end
    inst.SoundEmitter:PlaySound(inst._sounds.close)
end

local function OnPutInInventory(inst)
	inst.components.container:Close()
	inst.AnimState:PlayAnimation("closed", false)
end

local function onburnt(inst)
	inst.components.container:DropEverything()
	DefaultBurntFn(inst)
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

local function MakeTackleContainer(name, bank, build, assets)
    assets = assets or {}
    table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon(name..".png")

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("closed")
        inst.scrapbook_anim = "closed"

		MakeInventoryPhysics(inst)

        local swap_data = {bank = bank, anim = "closed"}
        MakeInventoryFloatable(inst, "small", 0.2, nil, nil, nil, swap_data)

        inst.entity:SetPristine()

        inst:AddTag("portablestorage")

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
		inst.components.container.droponopen = true


		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

		inst:AddComponent("lootdropper")

		MakeSmallBurnable(inst)
		inst.components.burnable:SetOnBurntFn(onburnt)
		MakeMediumPropagator(inst)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst._baseinventoryimagename = name
        if name == "supertacklecontainer" then
            inst._sounds = supertacklecontainer_sounds
        else
            inst._sounds = tacklecontainer_sounds
        end

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeTackleContainer("tacklecontainer", "tacklecontainer", "tacklecontainer", { Asset("ANIM", "anim/ui_tacklecontainer_3x2.zip"), Asset("INV_IMAGE", "tacklecontainer_open") }),
	MakeTackleContainer("supertacklecontainer", "supertacklecontainer", "supertacklecontainer", { Asset("ANIM", "anim/ui_tacklecontainer_3x5.zip"), Asset("INV_IMAGE", "supertacklecontainer_open") })