local cooking = require("cooking")

local params = {}
local containers = { MAXITEMSLOTS = 0 }

containers.params = params

function containers.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    end
end

--------------------------------------------------------------------------
--[[ backpack ]]
--------------------------------------------------------------------------

params.backpack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -70, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 3 do
    table.insert(params.backpack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.backpack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

params.icepack = params.backpack

--------------------------------------------------------------------------
--[[ spicepack ]]
--------------------------------------------------------------------------

params.spicepack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_icepack_2x3",
        animbuild = "ui_icepack_2x3",
        pos = Vector3(-5, -70, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 2 do
    table.insert(params.spicepack.widget.slotpos, Vector3(-162, -75 * y + 75, 0))
    table.insert(params.spicepack.widget.slotpos, Vector3(-162 + 75, -75 * y + 75, 0))
end

--------------------------------------------------------------------------
--[[ chester ]]
--------------------------------------------------------------------------

params.chester =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.chester.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

--------------------------------------------------------------------------
--[[ shadowchester ]]
--------------------------------------------------------------------------

params.shadowchester =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.shadowchester.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

--------------------------------------------------------------------------
--[[ hutch ]]
--------------------------------------------------------------------------

params.hutch = params.chester


--------------------------------------------------------------------------
--[[ Woby ]]
--------------------------------------------------------------------------

params.wobysmall =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_woby_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.wobysmall.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

params.wobybig = params.wobysmall

--------------------------------------------------------------------------
--[[ sewingmachine ]]
--------------------------------------------------------------------------

params.yotb_sewingmachine =
{

    widget =
    {
        slotpos =
        {
            Vector3(-(64 + 12), 0, 0),
            Vector3(0, 0, 0),
            Vector3(64 + 12, 0, 0),
        },

        slotbg =
        {
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" },
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" },
            { image = "yotb_sewing_slot.tex", atlas = "images/hud2.xml" },
        },

        animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
        pos = Vector3(0, 200, 0),
        side_align_tip = 100,

        buttoninfo =
        {
            text = STRINGS.ACTIONS.YOTB_SEW,
            position = Vector3(0, -65, 0),
        }
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.yotb_sewingmachine.itemtestfn(container, item, slot)
    --TODO: check if we actually accept the item
    return item:HasTag("yotb_pattern_fragment")
end

function params.yotb_sewingmachine.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.YOTB_SEW):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.YOTB_SEW.code, inst, ACTIONS.YOTB_SEW.mod_name)
    end
end

function params.yotb_sewingmachine.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end



--------------------------------------------------------------------------
--[[ cookpot ]]
--------------------------------------------------------------------------

params.cookpot =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.COOK,
            position = Vector3(0, -165, 0),
        }
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.cookpot.itemtestfn(container, item, slot)
    return cooking.IsCookingIngredient(item.prefab) and not container.inst:HasTag("burnt")
end

function params.cookpot.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.COOK):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
    end
end

function params.cookpot.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

params.archive_cookpot = params.cookpot
params.portablecookpot = params.cookpot

--------------------------------------------------------------------------
--[[ portablespicer]]
--------------------------------------------------------------------------

params.portablespicer =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
        },
        slotbg =
        {
            { image = "cook_slot_food.tex" },
            { image = "cook_slot_spice.tex" },
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.SPICE,
            position = Vector3(0, -93, 0),
        },
    },
    acceptsstacks = false,
    usespecificslotsforitems = true,
    type = "cooker",
}

function params.portablespicer.itemtestfn(container, item, slot)
    return item.prefab ~= "wetgoop"
        and (   (slot == 1 and item:HasTag("preparedfood") and not item:HasTag("spicedfood")) or
                (slot == 2 and item:HasTag("spice")) or
                (slot == nil and (item:HasTag("spice") or (item:HasTag("preparedfood") and not item:HasTag("spicedfood"))))
            )
        and not container.inst:HasTag("burnt")
end

function params.portablespicer.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.COOK):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
    end
end

function params.portablespicer.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

--------------------------------------------------------------------------
--[[ bundle_container ]]
--------------------------------------------------------------------------

params.bundle_container =
{
    widget =
    {
        slotpos =
        {
            Vector3(-37.5, 32 + 4, 0),
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0),
            Vector3(37.5, -(32 + 4), 0),
        },
        animbank = "ui_bundle_2x2",
        animbuild = "ui_bundle_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.WRAPBUNDLE,
            position = Vector3(0, -100, 0),
        }
    },
    type = "cooker",
}

function params.bundle_container.itemtestfn(container, item, slot)
    return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"))
end

function params.bundle_container.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.WRAPBUNDLE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.WRAPBUNDLE.code, inst, ACTIONS.WRAPBUNDLE.mod_name)
    end
end

function params.bundle_container.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end

--------------------------------------------------------------------------
--[[ construction_container ]]
--------------------------------------------------------------------------

params.construction_container =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_construction_4x1",
        animbuild = "ui_construction_4x1",
        pos = Vector3(300, 0, 0),
        top_align_tip = 50,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.APPLYCONSTRUCTION,
            position = Vector3(0, -94, 0),
        }
    },
    usespecificslotsforitems = true,
    type = "cooker",
}

for x = -1.5, 1.5, 1 do
    table.insert(params.construction_container.widget.slotpos, Vector3(x * 110, 8, 0))
end

function params.construction_container.itemtestfn(container, item, slot)

    local doer = container.inst.entity:GetParent()
    return doer ~= nil
        and doer.components.constructionbuilderuidata ~= nil
        and doer.components.constructionbuilderuidata:GetIngredientForSlot(slot) == item.prefab
end

function params.construction_container.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.APPLYCONSTRUCTION):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.APPLYCONSTRUCTION.code, inst, ACTIONS.APPLYCONSTRUCTION.mod_name)
    end
end

function params.construction_container.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end

--------------------------------------------------------------------------
--[[ mushroom_light ]]
--------------------------------------------------------------------------

params.mushroom_light =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_lamp_1x4",
        animbuild = "ui_lamp_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.mushroom_light.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("lightcontainer")) and not container.inst:HasTag("burnt")
end

--------------------------------------------------------------------------
--[[ mushroom_light2 ]]
--------------------------------------------------------------------------

params.mushroom_light2 = deepcopy(params.mushroom_light)

function params.mushroom_light2.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("spore") or item:HasTag("lightcontainer")) and not container.inst:HasTag("burnt")
end

--------------------------------------------------------------------------
--[[ winter_tree ]]
--------------------------------------------------------------------------

params.winter_tree =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(275, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

for y = 0, 3 do
    table.insert(params.winter_tree.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.winter_tree.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

function params.winter_tree.itemtestfn(container, item, slot)
    return item:HasTag("winter_ornament") and not container.inst:HasTag("burnt")
end

params.winter_twiggytree = params.winter_tree
params.winter_deciduoustree = params.winter_tree

--------------------------------------------------------------------------
--[[ sisturn ]]
--------------------------------------------------------------------------

params.sisturn =
{
    widget =
    {
        slotpos =
        {
            Vector3(-37.5, 32 + 4, 0),
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0),
            Vector3(37.5, -(32 + 4), 0),
        },
        slotbg =
        {
            { image = "sisturn_slot_petals.tex" },
            { image = "sisturn_slot_petals.tex" },
            { image = "sisturn_slot_petals.tex" },
            { image = "sisturn_slot_petals.tex" },
        },
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = Vector3(200, 0, 0),
        side_align_tip = 120,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.sisturn.itemtestfn(container, item, slot)
    return item.prefab == "petals"
end

--------------------------------------------------------------------------
--[[ livingtree_halloween ]]
--------------------------------------------------------------------------

params.livingtree_halloween =
{
    widget =
    {
        slotpos =
        {
            Vector3(-(64 + 12), 0, 0),
            Vector3(0, 0, 0),
            Vector3(64 + 12, 0, 0),
        },
        animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.livingtree_halloween.itemtestfn(container, item, slot)
    return item:HasTag("halloween_ornament") and not container.inst:HasTag("burnt")
end

--------------------------------------------------------------------------
--[[ icebox ]]
--------------------------------------------------------------------------

params.icebox =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.icebox.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

function params.icebox.itemtestfn(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

	if item:HasTag("smallcreature") then
		return false
	end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end

    return false
end

--------------------------------------------------------------------------
--[[ saltbox ]]
--------------------------------------------------------------------------

params.saltbox = deepcopy(params.icebox)

function params.saltbox.itemtestfn(container, item, slot)
	return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
		and item:HasTag("cookable")
		and not item:HasTag("deployable")
		and not item:HasTag("smallcreature")
		and item.replica.health == nil)
		or item:HasTag("saltbox_valid")
end

--------------------------------------------------------------------------
--[[ krampus_sack ]]
--------------------------------------------------------------------------

params.krampus_sack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(-5, -120, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 6 do
    table.insert(params.krampus_sack.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.krampus_sack.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

--------------------------------------------------------------------------
--[[ piggyback ]]
--------------------------------------------------------------------------

params.piggyback =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "ui_piggyback_2x6",
        pos = Vector3(-5, -50, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 5 do
    table.insert(params.piggyback.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
    table.insert(params.piggyback.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
end

--------------------------------------------------------------------------
--[[ teleportato ]]
--------------------------------------------------------------------------

params.teleportato_base =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(0, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.ACTIVATE.GENERIC,
            position = Vector3(0, -165, 0),
        },
    },
    type = "cooker",
}

function params.teleportato_base.itemtestfn(container, item, slot)
    return not item:HasTag("nonpotatable")
end

function params.teleportato_base.widget.buttoninfo.fn(inst, doer)
    --see teleportato.lua, not supported in multiplayer yet
    --CheckNextLevelSure(inst, doer)
end

--------------------------------------------------------------------------
--[[ treasurechest ]]
--------------------------------------------------------------------------

params.treasurechest =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.treasurechest.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

params.pandoraschest = params.treasurechest
params.skullchest = params.treasurechest
params.minotaurchest = params.treasurechest
params.terrariumchest = params.treasurechest
params.sunkenchest = params.treasurechest

params.quagmire_safe = deepcopy(params.treasurechest)
params.quagmire_safe.widget.animbank = "quagmire_ui_chest_3x3"
params.quagmire_safe.widget.animbuild = "quagmire_ui_chest_3x3"

params.dragonflychest = params.shadowchester

--------------------------------------------------------------------------
--[[ fish_box ]]
--------------------------------------------------------------------------

params.fish_box =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_fish_box_3x4",
        animbuild = "ui_fish_box_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.fish_box.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

function params.fish_box.itemtestfn(container, item, slot)
    return item:HasTag("smalloceancreature")
end


--------------------------------------------------------------------------
--[[ ocean fishing rod ]]
--------------------------------------------------------------------------

params.oceanfishingrod =
{

    widget =
    {
        slotpos =
        {
            Vector3(0,   32 + 4,  0),
            Vector3(0, -(32 + 4), 0),
        },
        slotbg =
        {
            { image = "fishing_slot_bobber.tex" },
            { image = "fishing_slot_lure.tex" },
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 60, 0),
    },
    acceptsstacks = false,
    usespecificslotsforitems = true,
    type = "hand_inv",
    excludefromcrafting = true,
}

function params.oceanfishingrod.itemtestfn(container, item, slot)
	return (slot == nil and (item:HasTag("oceanfishing_bobber") or item:HasTag("oceanfishing_lure")))
		or (slot == 1 and item:HasTag("oceanfishing_bobber"))
		or (slot == 2 and item:HasTag("oceanfishing_lure"))
end

--------------------------------------------------------------------------
--[[ slingshot ]]
--------------------------------------------------------------------------

params.slingshot =
{
    widget =
    {
        slotpos =
        {
            Vector3(0,   32 + 4,  0),
        },
        slotbg =
        {
            { image = "slingshot_ammo_slot.tex" },
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0),
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
    excludefromcrafting = true,
}

function params.slingshot.itemtestfn(container, item, slot)
	return item:HasTag("slingshotammo")
end


--------------------------------------------------------------------------
--[[ tacklecontainer ]]
--------------------------------------------------------------------------

params.tacklecontainer =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_tacklecontainer_3x2",
        animbuild = "ui_tacklecontainer_3x2",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.tacklecontainer.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

function params.tacklecontainer.itemtestfn(container, item, slot)
	return item:HasTag("oceanfishing_bobber") or item:HasTag("oceanfishing_lure")
end


--------------------------------------------------------------------------
--[[ supertacklecontainer ]]
--------------------------------------------------------------------------

params.supertacklecontainer =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_tacklecontainer_3x5",
        animbuild = "ui_tacklecontainer_3x5",
        pos = Vector3(0, 280, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1, -3, -1 do
    for x = 0, 2 do
        table.insert(params.supertacklecontainer.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 45, 0))
    end
end

params.supertacklecontainer.itemtestfn = params.tacklecontainer.itemtestfn

--------------------------------------------------------------------------
--[[ sacred_chest ]]
--------------------------------------------------------------------------

params.sacred_chest =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.sacred_chest.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

--------------------------------------------------------------------------
--[[ seedpouch ]]
--------------------------------------------------------------------------

params.seedpouch =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(-5, -120, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 6 do
    table.insert(params.seedpouch.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.seedpouch.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

function params.seedpouch.itemtestfn(container, item, slot)
    return item.prefab == "seeds" or string.match(item.prefab, "_seeds") or item:HasTag("treeseed")
end

params.seedpouch.priorityfn = params.seedpouch.itemtestfn

--------------------------------------------------------------------------
--[[ candybag ]]
--------------------------------------------------------------------------

params.candybag =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(-5, -120, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 6 do
    table.insert(params.candybag.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.candybag.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

function params.candybag.itemtestfn(container, item, slot)
    return item:HasTag("halloweencandy") or item:HasTag("halloween_ornament") or string.sub(item.prefab, 1, 8) == "trinket_"
end

params.candybag.priorityfn = params.candybag.itemtestfn

--------------------------------------------------------------------------
--[[ alterguardianhatshard ]]
--------------------------------------------------------------------------

params.alterguardianhatshard =
{
    widget =
    {
        slotpos = {
            Vector3(-2, 18, 0),
        },
        slotbg =
        {
            { image = "spore_slot.tex", atlas = "images/hud2.xml" },
        },
        animbank = "ui_alterguardianhat_1x1",
        animbuild = "ui_alterguardianhat_1x1",
        pos = Vector3(0, 160, 0),
    },
    acceptsstacks = false,
    type = "chest",
}

function params.alterguardianhatshard.itemtestfn(container, item, slot)
    return item:HasTag("spore")
end

--------------------------------------------------------------------------
--[[ alterguardianhat ]]
--------------------------------------------------------------------------

params.alterguardianhat =
{
    widget =
    {
        slotpos = {},
        slotbg = {},
        animbank = "ui_alterguardianhat_1x6",
        animbuild = "ui_alterguardianhat_1x6",
        pos = Vector3(106, 150, 0),
    },
    acceptsstacks = false,
    type = "hand_inv",
    excludefromcrafting = true,
}

local AGHAT_SLOTSTART = 95
local AGHAT_SLOTDIFF = 72
local SLOT_BG = { image = "spore_slot.tex", atlas = "images/hud2.xml" }
for i = 0, 4 do
    local sp = Vector3(0, AGHAT_SLOTSTART - (i*AGHAT_SLOTDIFF), 0)
    table.insert(params.alterguardianhat.widget.slotpos, sp)
    table.insert(params.alterguardianhat.widget.slotbg, SLOT_BG)
end

function params.alterguardianhat.itemtestfn(container, item, slot)
    return item:HasTag("spore")
end

--------------------------------------------------------------------------
--[[ pocketwatch ]]
--------------------------------------------------------------------------

params.pocketwatch =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_tacklecontainer_3x2",
        animbuild = "ui_tacklecontainer_3x2",
        pos = Vector3(-850, 100, 0),
        side_align_tip = 100,
    },
    type = "hand_inv",
    excludefromcrafting = true,
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.pocketwatch.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

function params.pocketwatch.itemtestfn(container, item, slot)
	return item:HasTag("pocketwatchpart")
end

--------------------------------------------------------------------------
--[[ quagmire_pot ]]
--------------------------------------------------------------------------

params.quagmire_pot =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "quagmire_ui_pot_1x4",
        animbuild = "quagmire_ui_pot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.quagmire_pot.itemtestfn(container, item, slot)
    return item:HasTag("quagmire_stewable")
        and item.prefab ~= "quagmire_sap"
        and ((item.components.inventoryitem ~= nil and not item.components.inventoryitem:IsHeld()) or
            not (item.prefab == "spoiled_food" or item:HasTag("preparedfood") or item:HasTag("overcooked") or container.inst:HasTag("takeonly")))
end

--------------------------------------------------------------------------
--[[ quagmire_pot_small ]]
--------------------------------------------------------------------------

params.quagmire_pot_small =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 8, 0),
            Vector3(0, 0, 0),
            Vector3(0, -(64 + 8), 0),
        },
        animbank = "quagmire_ui_pot_1x3",
        animbuild = "quagmire_ui_pot_1x3",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

params.quagmire_pot_small.itemtestfn = params.quagmire_pot.itemtestfn

--------------------------------------------------------------------------
--[[ quagmire_casseroledish ]]
--------------------------------------------------------------------------

params.quagmire_casseroledish = params.quagmire_pot

--------------------------------------------------------------------------
--[[ quagmire_casseroledish_small ]]
--------------------------------------------------------------------------

params.quagmire_casseroledish_small = params.quagmire_pot_small

--------------------------------------------------------------------------
--[[ quagmire_grill ]]
--------------------------------------------------------------------------

params.quagmire_grill = params.quagmire_pot

--------------------------------------------------------------------------
--[[ quagmire_grill_small ]]
--------------------------------------------------------------------------

params.quagmire_grill_small = params.quagmire_pot_small

--------------------------------------------------------------------------
--[[ quagmire_pot_syrup ]]
--------------------------------------------------------------------------

params.quagmire_pot_syrup =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 8, 0),
            Vector3(0, 0, 0),
            Vector3(0, -(64 + 8), 0),
        },
        animbank = "quagmire_ui_pot_1x3",
        animbuild = "quagmire_ui_pot_1x3",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.quagmire_pot_syrup.itemtestfn(container, item, slot)
    return item:HasTag("quagmire_stewable")
        and ((item.components.inventoryitem ~= nil and not item.components.inventoryitem:IsHeld()) or
            (item.prefab == "quagmire_sap" and not container.inst:HasTag("takeonly")))
end

--------------------------------------------------------------------------
--[[ quagmire_backpack_small ]]
--------------------------------------------------------------------------

params.quagmire_backpack_small =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(-50, -450, 0),
        side_align_tip = 100,
    },
    type = "backpack",
}

for x = 0, 3 do
    table.insert(params.quagmire_backpack_small.widget.slotpos, Vector3(-x * 75 - 75*.5, 120, 0))
end

--------------------------------------------------------------------------
--[[ quagmire_backpack ]]
--------------------------------------------------------------------------

params.quagmire_backpack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(-50, -450, 0),
        side_align_tip = 100,
    },
    type = "backpack",
}

for x = 0, 7 do
    table.insert(params.quagmire_backpack.widget.slotpos, Vector3(-x * 75 - 75*.5, 120, 0))
end

--------------------------------------------------------------------------

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

--------------------------------------------------------------------------

return containers
