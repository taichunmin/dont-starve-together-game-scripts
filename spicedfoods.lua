require("tuning")

local spicedfoods = {}

local function oneaten_garlic(inst, eater)
    if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
        not (eater.components.health ~= nil and eater.components.health:IsDead()) and
        not eater:HasTag("playerghost") then
        eater.components.debuffable:AddDebuff("buff_playerabsorption", "buff_playerabsorption")
    end
end

local function oneaten_sugar(inst, eater)
    if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
        not (eater.components.health ~= nil and eater.components.health:IsDead()) and
        not eater:HasTag("playerghost") then
        eater.components.debuffable:AddDebuff("buff_workeffectiveness", "buff_workeffectiveness")
    end
end

local function oneaten_chili(inst, eater)
    if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
        not (eater.components.health ~= nil and eater.components.health:IsDead()) and
        not eater:HasTag("playerghost") then
        eater.components.debuffable:AddDebuff("buff_attack", "buff_attack")
    end
end

local SPICES =
{
    SPICE_GARLIC = { oneatenfn = oneaten_garlic, prefabs = { "buff_playerabsorption" } },
    SPICE_SUGAR  = { oneatenfn = oneaten_sugar, prefabs = { "buff_workeffectiveness" } },
    SPICE_CHILI  = { oneatenfn = oneaten_chili, prefabs = { "buff_attack" } },
}

function GenerateSpicedFoods(foods)
    for foodname, fooddata in pairs(foods) do
        for spicenameupper, spicedata in pairs(SPICES) do
            local newdata = shallowcopy(fooddata)
            local spicename = string.lower(spicenameupper)
            if foodname == "wetgoop" then
                newdata.test = function(cooker, names, tags) return names[spicename] end
                newdata.priority = -10
            else
                newdata.test = function(cooker, names, tags) return names[foodname] and names[spicename] end
                newdata.priority = 100
            end
            newdata.cooktime = .12
            newdata.stacksize = nil
            newdata.spice = spicenameupper
            newdata.basename = foodname
            newdata.name = foodname.."_"..spicename
            newdata.floater = {"med", nil, {0.85, 0.7, 0.85}}
            spicedfoods[newdata.name] = newdata

            if spicename == "spice_chili" then
                if newdata.temperature == nil then
                    --Add permanent "heat" to regular food
                    newdata.temperature = TUNING.HOT_FOOD_BONUS_TEMP
                    newdata.temperatureduration = TUNING.FOOD_TEMP_LONG
                    newdata.nochill = true
                elseif newdata.temperature > 0 then
                    --Upgarde "hot" food to permanent heat
                    newdata.temperatureduration = math.max(newdata.temperatureduration, TUNING.FOOD_TEMP_LONG)
                    newdata.nochill = true
                end
            end

            if spicedata.prefabs ~= nil then
                --make a copy (via ArrayUnion) if there are dependencies from the original food
                newdata.prefabs = newdata.prefabs ~= nil and ArrayUnion(newdata.prefabs, spicedata.prefabs) or spicedata.prefabs
            end

            if spicedata.oneatenfn ~= nil then
                if newdata.oneatenfn ~= nil then
                    local oneatenfn_old = newdata.oneatenfn
                    newdata.oneatenfn = function(inst, eater)
                        spicedata.oneatenfn(inst, eater)
                        oneatenfn_old(inst, eater)
                    end
                else
                    newdata.oneatenfn = spicedata.oneatenfn
                end
            end
        end
    end
end

GenerateSpicedFoods(require("preparedfoods"))
GenerateSpicedFoods(require("preparedfoods_warly"))

return spicedfoods
