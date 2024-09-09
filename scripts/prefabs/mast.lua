local assets =
{
    Asset("ANIM", "anim/boat_mast2_wip.zip"),
    Asset("INV_IMAGE", "mast_item"),
    Asset("ANIM", "anim/seafarer_mast.zip"),
    Asset("MINIMAP_IMAGE", "mast"),
}

local malbatross_assets =
{
    Asset("ANIM", "anim/boat_mast_malbatross_wip.zip"),
    Asset("ANIM", "anim/boat_mast_malbatross_knots_wip.zip"),
    Asset("ANIM", "anim/boat_mast_malbatross_opens_wip.zip"),
    Asset("ANIM", "anim/boat_mast_malbatross_build.zip"),

    Asset("ANIM", "anim/seafarer_mast_malbatross.zip"), -- item
    Asset("MINIMAP_IMAGE", "mast_malbatross"),
}

local yotd_assets =
{
    Asset("ANIM", "anim/yotd_boat_mast.zip"),

    Asset("ANIM", "anim/yotd_boat_mast_kit.zip"),

    Asset("INV_IMAGE", "mast_yotd_item"),
    Asset("MINIMAP_IMAGE", "mast_yotd"),
}

local upgrade_assets =
{
    lamp =
    {
        Asset("ANIM", "anim/mastupgrade_lamp.zip"),
    },
    lightningrod =
    {
        Asset("ANIM", "anim/mastupgrade_lightningrod.zip"),
    },
}

local prefabs =
{
	"boat_mast_sink_fx",
	"collapse_small",
    "mast_item", -- deprecated but kept for existing worlds and mods
    "mastupgrade_lamp",
    "mastupgrade_lightningrod",
}

local malbatross_prefabs =
{
	"boat_malbatross_mast_sink_fx",
	"collapse_small",
    "mast_malbatross_item", -- deprecated but kept for existing worlds and mods
    "mastupgrade_lamp",
    "mastupgrade_lightningrod",
}

local yotd_prefabs =
{
    "collapse_small",
    "mast_yotd_sink_fx",
    "mastupgrade_lamp",
    "mastupgrade_lightningrod",
}

local LIGHT_RADIUS = { MIN=2, MAX=5 }
local LIGHT_COLOUR = Vector3(180 / 255, 195 / 255, 150 / 255)
local LIGHT_INTENSITY = { MIN=0.4, MAX=0.8 }
local LIGHT_FALLOFF = .9

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    if inst.components.mast and hammerer ~= inst.components.mast.boat then
        inst.components.mast:SetBoat(nil)
    end

    inst:Remove()
end

local function on_hit(inst, hitter)
    if inst.components.mast and not inst.components.mast.is_sail_transitioning then
        if inst.components.mast.is_sail_raised ~= inst.components.mast.inverted then
            inst.AnimState:PlayAnimation("open2_hit")
            inst.AnimState:PushAnimation("open_loop",true)
        else
            inst.AnimState:PlayAnimation("closed_hit")
            inst.AnimState:PushAnimation("closed",false)
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/place")
end

local function lamp_fuelupdate(inst)
    if inst._lamp ~= nil and inst._lamp:IsValid() then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst.Light:SetIntensity(Lerp(LIGHT_INTENSITY.MIN, LIGHT_INTENSITY.MAX, fuelpercent))
        inst.Light:SetRadius(Lerp(LIGHT_RADIUS.MIN, LIGHT_RADIUS.MAX, fuelpercent))
        inst.Light:SetFalloff(LIGHT_FALLOFF)
    end
end

local function lamp_turnoff(inst)
    inst.Light:Enable(false)

    if inst._lamp ~= nil and inst._lamp:IsValid() then
        inst._lamp:PushEvent("mast_lamp_off")
    end
end

local function lamp_turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()

        if not inst._lamp then
            local upgrade_prefab = (inst.saved_upgraded_from_item ~= nil and inst.saved_upgraded_from_item.upgrade_override)
                or "mastupgrade_lamp"
            if inst.saved_upgraded_from_item ~= nil and inst.saved_upgraded_from_item.linked_skinname then
                inst._lamp = SpawnPrefab(upgrade_prefab, inst.saved_upgraded_from_item.linked_skinname, inst.saved_upgraded_from_item.skin_id )
            else
                inst._lamp = SpawnPrefab(upgrade_prefab)
            end
            inst._lamp._mast = inst
            lamp_fuelupdate(inst)

            if inst.highlightchildren ~= nil then
                table.insert(inst.highlightchildren, inst._lamp)
            else
                inst.highlightchildren = { inst._lamp }
            end

            inst._lamp.entity:SetParent(inst.entity)
            inst._lamp.entity:AddFollower():FollowSymbol(inst.GUID, "mastupgrade_lamp", 0, 0, 0)
        end

        inst.Light:Enable(true)

        lamp_fuelupdate(inst)

        inst._lamp:PushEvent("mast_lamp_on")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function upgrade_lamp(inst, no_built_callback)
    local fueled = inst:AddComponent("fueled")
    fueled:InitializeFuelLevel(TUNING.MAST_LAMP_LIGHTTIME)
    fueled:SetDepletedFn(lamp_turnoff)
    fueled:SetUpdateFn(lamp_fuelupdate)
    fueled:SetTakeFuelFn(lamp_turnon)
    fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    fueled.accepting = true
    fueled.canbespecialextinguished = true

    inst:AddTag("firefuellight")

    lamp_turnon(inst)

    inst.components.upgradeable.upgradetype = nil

    if not no_built_callback then
        inst._lamp:PushEvent("onbuilt")
    end
end

local function upgrade_lightningrod(inst, no_built_callback)
    local upgrade_prefab = (inst.saved_upgraded_from_item ~= nil and inst.saved_upgraded_from_item.upgrade_override)
        or "mastupgrade_lightningrod"
    if inst.saved_upgraded_from_item ~= nil and inst.saved_upgraded_from_item.linked_skinname then
        inst._lightningrod = SpawnPrefab(upgrade_prefab, inst.saved_upgraded_from_item.linked_skinname, inst.saved_upgraded_from_item.skin_id )
    else
        inst._lightningrod = SpawnPrefab(upgrade_prefab)
    end

    inst._lightningrod.entity:SetParent(inst.entity)

    local top = nil
    if inst.saved_upgraded_from_item ~= nil and inst.saved_upgraded_from_item.linked_skinname then
        top = SpawnPrefab(upgrade_prefab.."_top", inst.saved_upgraded_from_item.linked_skinname .. "_top", inst.saved_upgraded_from_item.skin_id )
    else
        top = SpawnPrefab(upgrade_prefab.."_top")
    end
    top.entity:SetParent(inst.entity)
    top.entity:AddFollower():FollowSymbol(inst.GUID, "mastupgrade_lightningrod_top", 0, 0, 0)

    inst._lightningrod._mast = inst
    inst._lightningrod._top = top

    if inst.highlightchildren ~= nil then
        table.insert(inst.highlightchildren, inst._lightningrod)
        table.insert(inst.highlightchildren, inst._lightningrod._top)
    else
        inst.highlightchildren = { inst._lightningrod, inst._lightningrod._top }
    end

    inst.components.upgradeable.upgradetype = nil

    if not no_built_callback then
        inst._lightningrod:PushEvent("onbuilt")
    end
end

local function OnUpgrade(inst, performer, upgraded_from_item)
    if upgraded_from_item.linked_skinname ~= nil then
        inst.saved_upgraded_from_item = {}
        inst.saved_upgraded_from_item.linked_skinname = upgraded_from_item.linked_skinname
        inst.saved_upgraded_from_item.skin_id = upgraded_from_item.skin_id
    end

    if upgraded_from_item.upgrade_override then
        inst.saved_upgraded_from_item = inst.saved_upgraded_from_item or {}
        inst.saved_upgraded_from_item.upgrade_override = upgraded_from_item.upgrade_override
    end

    local numupgrades = inst.components.upgradeable.numupgrades
    if numupgrades == 1 then
        upgrade_lamp(inst)
    elseif numupgrades == 2 then
        upgrade_lightningrod(inst)
    end
end

local function onburnt(inst)
	inst:AddTag("burnt")

	local mast = inst.components.mast
	if mast.boat ~= nil then
		mast.boat.components.boatphysics:RemoveMast(mast)
    end
    if mast.rudder ~= nil then
        mast.rudder:Remove()
    end

    inst:RemoveComponent("mast")

    lamp_turnoff(inst)

    inst.components.upgradeable.upgradetype = nil
    if inst.components.fueled ~= nil then
        inst:RemoveComponent("fueled")
    end

    if inst._lamp ~= nil and inst._lamp:IsValid() then
        inst._lamp:PushEvent("mast_burnt")
        inst._lamp:Remove()
        inst._lamp = nil
    end

    if inst._lightningrod ~= nil and inst._lightningrod:IsValid() then
        inst._lightningrod:PushEvent("mast_burnt")
        inst._lightningrod:Remove()
        inst._lightningrod = nil
    end
end

local function ondeconstructstructure(inst, caster)
    if inst._lamp ~= nil and inst._lamp:IsValid() then
        inst._lamp:PushEvent("ondeconstructstructure", caster)
    end

    if inst._lightningrod ~= nil and inst._lightningrod:IsValid() then
        inst._lightningrod:PushEvent("ondeconstructstructure", caster)
    end
end

local function lootsetup(lootdropper)
    local inst = lootdropper.inst
    local recipe = inst._lamp ~= nil and AllRecipes[inst._lamp.prefab] or inst._lightningrod ~= nil and AllRecipes[inst._lightningrod.prefab] or nil

    if recipe ~= nil then
        local loots = lootdropper:GetRecipeLoot(recipe)

        if #loots > 0 then
            lootdropper:SetLoot(loots)
        end
    end
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end

	if inst.components.mast == nil or inst.components.mast.boat == nil then
		data.rotation = inst.Transform:GetRotation()
		data.is_sail_raised = inst.components.mast and inst.components.mast.is_sail_raised or false
    end

    if inst._lamp ~= nil then
        data.lamp_fuel = inst.components.fueled.currentfuel
        data.saved_upgraded_from_item = inst.saved_upgraded_from_item
    elseif inst._lightningrod ~= nil then
        data.lightningrod = true
        data.lightningrod_chargeleft = inst._lightningrod.chargeleft
        data.saved_upgraded_from_item = inst.saved_upgraded_from_item
    end
end

local function onload(inst, data)
	if data ~= nil then
		if data.burnt then
			inst.components.burnable.onburnt(inst)
			inst:PushEvent("onburnt")
		end
		if data.rotation then
			inst.Transform:SetRotation(data.rotation)
		end

		if inst.components.mast ~= nil and (data.is_sail_raised == not inst.components.mast.inverted) then
			if inst.components.mast.inverted then
				inst.components.mast:SailFurled()
			else
				inst.components.mast:SailUnfurled()
			end
        end

        if data.lamp_fuel ~= nil then
            inst.saved_upgraded_from_item = data.saved_upgraded_from_item
            upgrade_lamp(inst)
            inst.components.fueled:InitializeFuelLevel(math.max(0, data.lamp_fuel))
            if data.lamp_fuel == 0 then
                lamp_turnoff(inst)
            else
                lamp_turnon(inst)
            end
        elseif data.lightningrod ~= nil then
            inst.saved_upgraded_from_item = data.saved_upgraded_from_item
            upgrade_lightningrod(inst, true)
            if data.lightningrod_chargeleft ~= nil and data.lightningrod_chargeleft > 0 then
                inst._lightningrod:_setchargedfn(data.lightningrod_chargeleft)
            end
        end
	end
end

local function fn_pre(inst)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --item deployspacing/2
    MakeObstaclePhysics(inst, .2)

    inst.Light:Enable(false)
    --inst.Light:SetIntensity(LIGHT_INTENSITY.MAX)
    inst.Light:SetColour(LIGHT_COLOUR.x, LIGHT_COLOUR.y, LIGHT_COLOUR.z)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    --inst.Light:SetRadius(LIGHT_RADIUS.MAX)

    inst.Transform:SetEightFaced()

    inst:AddTag("structure")
    inst:AddTag("mast")
	inst:AddTag("rotatableobject")
end

local function fn_pst(inst)
    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable.ignorefuel = true
    inst:ListenForEvent("onburnt", onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("hauntable")
    inst:AddComponent("inspectable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("mast")

    -- The mast loot that this drops is generated from the uncraftable recipe; see recipes.lua for the items.
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetup)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
    inst.components.workable:SetOnWorkCallback(on_hit)

    inst:AddComponent("upgradeable")
    inst.components.upgradeable.upgradetype = UPGRADETYPES.MAST
    inst.components.upgradeable.onupgradefn = OnUpgrade

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)

    inst.OnSave = onsave
    inst.OnLoad = onload
end

local function fn()

    local inst = CreateEntity()

    fn_pre(inst)

    inst.AnimState:SetBank("mast_01")
    inst.AnimState:SetBuild("boat_mast2_wip")
    inst.AnimState:PlayAnimation("closed")
    inst.scrapbook_anim = "open_loop"

    inst.MiniMapEntity:SetIcon("mast.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_facing  = FACING_DOWN

    fn_pst(inst)

	if inst.components.mast ~= nil then
		inst.components.mast.sink_fx = "boat_mast_sink_fx"
	end

    return inst
end

local function malbatrossfn()

    local inst = CreateEntity()

    fn_pre(inst)

    inst.AnimState:SetBank("mast_malbatross")
    inst.AnimState:SetBuild("boat_mast_malbatross_build")
    inst.AnimState:PlayAnimation("closed")
    inst.scrapbook_anim = "open_loop"

    inst.MiniMapEntity:SetIcon("mast_malbatross.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_specialinfo = "MASTMALBATROSS"
    inst.scrapbook_facing  = FACING_DOWN

    fn_pst(inst)

    inst.components.mast.sail_force = TUNING.BOAT.MAST.MALBATROSS.SAIL_FORCE
  --  inst.components.mast.max_velocity_mod = TUNING.BOAT.MAST.MALBATROSS.MAX_VELOCITY_MOD
    inst.components.mast.rudder_turn_drag = TUNING.BOAT.MAST.MALBATROSS.RUDDER_TURN_DRAG
    inst.components.mast.max_velocity = TUNING.BOAT.MAST.MALBATROSS.MAX_VELOCITY
    inst.components.mast:SetReveseDeploy(true)

	if inst.components.mast ~= nil then
		inst.components.mast.sink_fx = "boat_malbatross_mast_sink_fx"
	end

    return inst
end

local function yotd_fn()
    local inst = CreateEntity()

    fn_pre(inst)

    inst.AnimState:SetBank("mast_01")
    inst.AnimState:SetBuild("yotd_boat_mast")
    inst.AnimState:PlayAnimation("closed")
    inst.scrapbook_anim = "open_loop"

    inst.MiniMapEntity:SetIcon("mast_yotd.png")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_facing  = FACING_DOWN

    fn_pst(inst)

    if inst.components.mast then
        inst.components.mast.sink_fx = "mast_yotd_sink_fx"
    end

    return inst
end

-- Item functions
local function setondeploy(inst, prefab)
    inst.components.deployable.ondeploy = function(inst2, pt, deployer, rotation)
        local mast = SpawnPrefab( prefab, inst2.linked_skinname, inst2.skin_id )
        if not mast then return end

        mast.Physics:SetCollides(false)
        mast.Physics:Teleport(pt.x, 0, pt.z)
        mast.Physics:SetCollides(true)
        mast.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/place")
        mast.AnimState:PlayAnimation("place")
        mast.AnimState:PushAnimation("closed", false)
        if rotation then
            mast.Transform:SetRotation(rotation)
            mast.save_rotation = true
        end

        inst2:Remove()
    end
end


local function item_fn_pre(inst)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("boat_accessory")
    inst:AddTag("deploykititem")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "med", 0.25, 0.83)
end

local function item_fn_pst(inst)
    inst:AddComponent("deployable")
    setondeploy(inst, "mast")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.MAST)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

    MakeLargeBurnable(inst)
    MakeLargePropagator(inst)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeHauntableLaunch(inst)
end

local function item_fn()
    local inst = CreateEntity()

    item_fn_pre(inst)

    inst.AnimState:SetBank("seafarer_mast")
    inst.AnimState:SetBuild("seafarer_mast")
    inst.AnimState:PlayAnimation("IDLE")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    item_fn_pst(inst)

    return inst
end

local function malbatross_item_fn()
    local inst = CreateEntity()

    item_fn_pre(inst)

    inst.AnimState:SetBank("seafarer_mast_malbatross")
    inst.AnimState:SetBuild("seafarer_mast_malbatross")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    item_fn_pst(inst)

    setondeploy(inst ,"mast_malbatross")

    return inst
end

local function yotd_item_fn()
    local inst = CreateEntity()

    item_fn_pre(inst)

    inst.AnimState:SetBank("seafarer_mast")
    inst.AnimState:SetBuild("yotd_boat_mast_kit")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    item_fn_pst(inst)

    setondeploy(inst, "mast_yotd")

    return inst
end

return Prefab("mast", fn, assets, prefabs),
       Prefab("mast_item", item_fn, assets),
       MakePlacer("mast_item_placer", "mast_01", "boat_mast2_wip", "closed", nil,nil,nil,nil,0,"eight"),

       Prefab("mast_malbatross", malbatrossfn, malbatross_assets, malbatross_prefabs),
       Prefab("mast_malbatross_item", malbatross_item_fn, malbatross_assets),
       MakePlacer("mast_malbatross_item_placer", "mast_malbatross", "boat_mast_malbatross_build", "closed", nil,nil,nil,nil,0,"eight"),

       Prefab("mast_yotd", yotd_fn, yotd_assets, yotd_prefabs),
       Prefab("mast_yotd_item", yotd_item_fn, yotd_assets),
       MakePlacer("mast_yotd_item_placer", "mast_01", "yotd_boat_mast", "closed", nil, nil, nil, nil, 0, "eight")