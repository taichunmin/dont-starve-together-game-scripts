local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/willow.fsb"),
}

local prefabs =
{
    "lavaarena_bernie",
}

local start_inv =
{
    default =
    {
        "lighter",
        "bernie_inactive",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WILLOW
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function sanityfn(inst)
    local x, y, z = inst.Transform:GetWorldPosition() 
    local delta = 0
    local max_rad = 10
    local ents = TheSim:FindEntities(x, y, z, max_rad, { "fire" })
    for i, v in ipairs(ents) do
        if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
            local rad = v.components.burnable:GetLargestLightRadius() or 1
            local sz = TUNING.SANITYAURA_TINY * math.min(max_rad, rad) / max_rad
            local distsq = inst:GetDistanceSqToInst(v) - 9
            -- shift the value so that a distance of 3 is the minimum
            delta = delta + sz / math.max(1, distsq)
        end
    end
    return delta
end

local function common_postinit(inst)
    inst:AddTag("pyromaniac")
    inst:AddTag("expertchef")

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst:AddTag("bernie_reviver")

        inst:AddComponent("pethealthbar")
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    end
end

local function UpdateSanityTemperature(inst)
    --Don't chill all the way to 0, or temperature
    --update fluctuations can still cause freezing
    if TheWorld.state.temperature > 1 then
        local sanity = inst.components.sanity:GetPercent()
        if sanity < TUNING.WILLOW_CHILL_START then
            inst.components.temperature:SetModifier(
                "sanity",
                math.max(
                    1 - TheWorld.state.temperature,
                    sanity > TUNING.WILLOW_CHILL_END and
                    easing.outQuad(sanity - TUNING.WILLOW_CHILL_END, TUNING.WILLOW_SANITY_CHILLING, -TUNING.WILLOW_SANITY_CHILLING, TUNING.WILLOW_CHILL_START - TUNING.WILLOW_CHILL_END) or
                    TUNING.WILLOW_SANITY_CHILLING
                )
            )
            return
        end
    end

    inst.components.temperature:RemoveModifier("sanity")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE
    inst.components.health.fire_timestart = TUNING.WILLOW_FIRE_IMMUNITY

    inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
    inst.components.sanity.custom_rate_fn = sanityfn
    inst.components.sanity.rate_modifier = TUNING.WILLOW_SANITY_MODIFIER

    inst:DoPeriodicTask(.1, UpdateSanityTemperature, 0)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/willow").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/willow").master_postinit(inst)
    end
end

return MakePlayerCharacter("willow", prefabs, assets, common_postinit, master_postinit)
