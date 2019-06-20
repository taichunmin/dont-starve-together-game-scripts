local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wathgrithr.fsb"),
}

local prefabs =
{
    "wathgrithr_spirit",
    "wathgrithr_bloodlustbuff_other",
    "wathgrithr_bloodlustbuff_self",
}

local start_inv =
{
    default =
    {
        "spear_wathgrithr",
        "wathgrithrhat",
        "meat",
        "meat",
        "meat",
        "meat",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WATHGRITHR
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local smallScale = .5
local medScale = .7
local largeScale = 1.1

local function spawnspirit(inst, x, y, z, scale)
    local fx = SpawnPrefab("wathgrithr_spirit")
    fx.Transform:SetPosition(x, y, z)
    fx.Transform:SetScale(scale, scale, scale)
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable") or
                victim:HasTag("companion"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function onkilled(inst, data)
    local victim = data.victim
    if IsValidVictim(victim) then
        -- local delta = victim.components.combat.defaultdamage * 0.25
        -- inst.components.health:DoDelta(delta, false, "battleborn")
        -- inst.components.sanity:DoDelta(delta)

        if not victim.components.health.nofadeout and (victim:HasTag("epic") or math.random() < .1) then
            local time = victim.components.health.destroytime or 2
            local x, y, z = victim.Transform:GetWorldPosition()
            local scale = (victim:HasTag("smallcreature") and smallScale)
                        or (victim:HasTag("largecreature") and largeScale)
                        or medScale
            inst:DoTaskInTime(time, spawnspirit, x, y, z, scale)
        end
    end
end

local BATTLEBORN_STORE_TIME = 3
local BATTLEBORN_DECAY_TIME = 5
local BATTLEBORN_TRIGGER_THRESHOLD = 1

local function battleborn_onattack(inst, data)
    local victim = data.target
    if not inst.components.health:IsDead() and IsValidVictim(victim) then
        local total_health = victim.components.health:GetMaxWithPenalty()
        local damage = data.weapon ~= nil and data.weapon.components.weapon.damage or inst.components.combat.defaultdamage
        local percent = (damage <= 0 and 0)
                    or (total_health <= 0 and math.huge)
                    or damage / total_health
        --math and clamp does account for 0 and infinite cases
        local delta = math.clamp(victim.components.combat.defaultdamage * .25 * percent, .33, 2)

        --decay stored battleborn
        if inst.battleborn > 0 then
            local dt = GetTime() - inst.battleborn_time - BATTLEBORN_STORE_TIME
            if dt >= BATTLEBORN_DECAY_TIME then
                inst.battleborn = 0
            elseif dt > 0 then
                local k = dt / BATTLEBORN_DECAY_TIME
                inst.battleborn = Lerp(inst.battleborn, 0, k * k)
            end
        end

        --store new battleborn
        inst.battleborn = inst.battleborn + delta
        inst.battleborn_time = GetTime()

        --consume battleborn if enough has been stored
        if inst.battleborn > BATTLEBORN_TRIGGER_THRESHOLD then
            inst.components.health:DoDelta(inst.battleborn, false, "battleborn")
            inst.components.sanity:DoDelta(inst.battleborn)
            inst.battleborn = 0
        end
    end
end

local function ondeath(inst)
    inst.battleborn = 0
end

local function common_postinit(inst)
    inst:AddTag("valkyrie")

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_butcher")
        inst:AddTag("quagmire_shopper")
    end

    inst.components.talker.mod_str_fn = Umlautify
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.talker_path_override = "dontstarve_DLC001/characters/"

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODTYPE.MEAT, FOODTYPE.GOODIES })
    end

    inst.components.health:SetMaxHealth(TUNING.WATHGRITHR_HEALTH)
    inst.components.hunger:SetMax(TUNING.WATHGRITHR_HUNGER)
    inst.components.sanity:SetMax(TUNING.WATHGRITHR_SANITY)

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wathgrithr").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        --event_server_data("quagmire", "prefabs/wathgrithr").master_postinit(inst)
    else
        inst.components.combat.damagemultiplier = TUNING.WATHGRITHR_DAMAGE_MULT
        inst.components.health:SetAbsorptionAmount(TUNING.WATHGRITHR_ABSORPTION)

        inst:ListenForEvent("killed", onkilled)
        inst:ListenForEvent("onattackother", battleborn_onattack)
    end

    inst:ListenForEvent("death", ondeath)

    inst.battleborn = 0
    inst.battleborn_time = 0
end

return MakePlayerCharacter("wathgrithr", prefabs, assets, common_postinit, master_postinit)
