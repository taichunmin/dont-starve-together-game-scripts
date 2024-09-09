
require "prefabutil"
require "maputil"

local entities = {}
local WIDTH = 0
local HEIGHT = 0

function AncientArchiveInit(ents, map_width, map_height)
    entities = ents
    WIDTH = map_width
    HEIGHT = map_height
end

function AncientArchivePass(entities, map_width, map_height, world, add_entity_fn)

    AncientArchiveInit(entities, map_width, map_height)

    local products = {"archive_resonator_item","refined_dust","turfcraftingstation"}
    local index = 1
    if entities["archive_lockbox_dispencer"] then
        for i,prop in pairs(entities["archive_lockbox_dispencer"]) do
            if not prop.data then
                prop.data = {}
            end
            prop.data.product_orchestrina = products[index]
            index = index > 2 and 1 or index + 1
        end

        if #entities["archive_lockbox_dispencer"] < 3 then
            local need = 3-#entities["archive_lockbox_dispencer"]
            need = 3
            for i=1, need do
                local list = {}
                for i,dat in pairs(entities["archive_lockbox_dispencer_temp"]) do
                    table.insert(list,i)
                end
                local random = math.random(1,#list)

                local newprop = entities["archive_lockbox_dispencer_temp"][list[random]]
                if newprop and not newprop.data then
                    newprop.data = {}
                end
                newprop.data.product_orchestrina = products[index]
                index = index > 2 and 1 or index + 1
                table.insert(entities["archive_lockbox_dispencer"],newprop)
                entities["archive_lockbox_dispencer_temp"][list[random]] = nil
            end
        end
    end

    entities["archive_lockbox_dispencer_temp"] = nil

    return entities
end