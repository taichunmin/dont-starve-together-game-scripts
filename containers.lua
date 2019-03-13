local cooking = require("cooking")

local params = {}
local containers = { MAXITEMSLOTS = 0 }

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
}

for y = 0, 3 do
    table.insert(params.backpack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.backpack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

--------------------------------------------------------------------------
--[[ icepack ]]
--------------------------------------------------------------------------

params.icepack =
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
}

for y = 0, 2 do
    table.insert(params.icepack.widget.slotpos, Vector3(-162, -75 * y + 75, 0))
    table.insert(params.icepack.widget.slotpos, Vector3(-162 + 75, -75 * y + 75, 0))
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

function params.cookpot.widget.buttoninfo.fn(inst)
    if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.COOK):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
    end
end

function params.cookpot.widget.buttoninfo.validfn(inst)
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
    return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle"))
end

function params.bundle_container.widget.buttoninfo.fn(inst)
    if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.WRAPBUNDLE):Do()
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

function params.construction_container.widget.buttoninfo.fn(inst)
    if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.APPLYCONSTRUCTION):Do()
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
    return item:HasTag("lightbattery") and not container.inst:HasTag("burnt")
end

--------------------------------------------------------------------------
--[[ mushroom_light2 ]]
--------------------------------------------------------------------------

params.mushroom_light2 = deepcopy(params.mushroom_light)

function params.mushroom_light2.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("spore")) and not container.inst:HasTag("burnt")
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

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end

    return false
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

params.quagmire_safe = deepcopy(params.treasurechest)
params.quagmire_safe.widget.animbank = "quagmire_ui_chest_3x3"
params.quagmire_safe.widget.animbuild = "quagmire_ui_chest_3x3"

params.dragonflychest = params.shadowchester

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
}

for y = 0, 6 do
    table.insert(params.candybag.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.candybag.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

function params.candybag.itemtestfn(container, item, slot)
    return item:HasTag("halloweencandy") or item:HasTag("halloween_ornament") or string.sub(item.prefab, 1, 8) == "trinket_"
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
