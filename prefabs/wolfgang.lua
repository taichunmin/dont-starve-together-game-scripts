local easing = require("easing")
local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
    Asset("ANIM", "anim/player_mount_wolfgang.zip"),
    Asset("SOUND", "sound/wolfgang.fsb"),
}

local start_inv =
{
    default =
    {
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WOLFGANG
end

local prefabs = FlattenTree(start_inv, true)

local function OnMounted(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "mounted_mightiness", 1 / inst._mightiness_scale)
end

local function OnDismounted(inst)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "mounted_mightiness")
end

local function applymightiness(inst)
    local percent = inst.components.hunger:GetPercent()

    local damage_mult = TUNING.WOLFGANG_ATTACKMULT_NORMAL
    local hunger_rate = TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL
    local health_max = TUNING.WOLFGANG_HEALTH_NORMAL

    local mighty_scale = 1.25
    local wimpy_scale = .9

    if inst.strength == "mighty" then
        local mighty_start = (TUNING.WOLFGANG_START_MIGHTY_THRESH/TUNING.WOLFGANG_HUNGER)
        local mighty_percent = math.max(0, (percent - mighty_start) / (1 - mighty_start))
        damage_mult = easing.linear(mighty_percent, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX - TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, 1)
        health_max = easing.linear(mighty_percent, TUNING.WOLFGANG_HEALTH_NORMAL, TUNING.WOLFGANG_HEALTH_MIGHTY - TUNING.WOLFGANG_HEALTH_NORMAL, 1)
        hunger_rate = easing.linear(mighty_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, TUNING.WOLFGANG_HUNGER_RATE_MULT_MIGHTY - TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, 1)
        inst._mightiness_scale = easing.linear(mighty_percent, 1, mighty_scale - 1, 1)
    elseif inst.strength == "wimpy" then
        local wimpy_start = (TUNING.WOLFGANG_START_WIMPY_THRESH/TUNING.WOLFGANG_HUNGER)
        local wimpy_percent = math.min(1, percent / wimpy_start)
        damage_mult = easing.linear(wimpy_percent, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MAX - TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, 1)
        health_max = easing.linear(wimpy_percent, TUNING.WOLFGANG_HEALTH_WIMPY, TUNING.WOLFGANG_HEALTH_NORMAL - TUNING.WOLFGANG_HEALTH_WIMPY, 1)
        hunger_rate = easing.linear(wimpy_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL - TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, 1)
        inst._mightiness_scale = easing.linear(wimpy_percent, wimpy_scale, 1 - wimpy_scale, 1)
    else
        inst._mightiness_scale = 1
    end

    inst:ApplyScale("mightiness", inst._mightiness_scale)
    inst.components.hunger:SetRate(hunger_rate*TUNING.WILSON_HUNGER_RATE)
    inst.components.combat.damagemultiplier = damage_mult

    local health_percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(health_max)
    inst.components.health:SetPercent(health_percent, true)

    if inst.components.rider:IsRiding() then
        OnMounted(inst)
    end
end

local function becomewimpy(inst, silent)
    if inst.strength == "wimpy" then
        return
    end

    inst.components.skinner:SetSkinMode("wimpy_skin", "wolfgang_skinny")

    if not silent then
        inst.sg:PushEvent("powerdown")
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_NORMALTOWIMPY"))
        inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_medtosml")
    end

    inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_small_LP"
    inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_small"
    inst.strength = "wimpy"
end

local function becomenormal(inst, silent)
    if inst.strength == "normal" then
        return
    end

    inst.components.skinner:SetSkinMode("normal_skin", "wolfgang")

    if not silent then
        if inst.strength == "mighty" then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_MIGHTYTONORMAL"))
            inst.sg:PushEvent("powerdown")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_lrgtomed")
        elseif inst.strength == "wimpy" then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_WIMPYTONORMAL"))
            inst.sg:PushEvent("powerup")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_smtomed")
        end
    end

    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil
    inst.strength = "normal"
end

local function becomemighty(inst, silent)
    if inst.strength == "mighty" then
        return
    end

    inst.components.skinner:SetSkinMode("mighty_skin", "wolfgang_mighty")

    if not silent then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_NORMALTOMIGHTY"))
        inst.sg:PushEvent("powerup")
        inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_medtolrg")
    end

    inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_large_LP"
    inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_large"
    inst.strength = "mighty"
end

local function onhungerchange(inst, data, forcesilent)
    if inst.sg:HasStateTag("nomorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead() then
        return
    end

    local silent = inst.sg:HasStateTag("silentmorph") or not inst.entity:IsVisible() or forcesilent

    if inst.strength == "mighty" then
        if inst.components.hunger.current < TUNING.WOLFGANG_END_MIGHTY_THRESH then
            if silent and inst.components.hunger.current < TUNING.WOLFGANG_START_WIMPY_THRESH then
                becomewimpy(inst, true)
            else
                becomenormal(inst, silent)
            end
        end
    elseif inst.strength == "wimpy" then
        if inst.components.hunger.current > TUNING.WOLFGANG_END_WIMPY_THRESH then
            if silent and inst.components.hunger.current > TUNING.WOLFGANG_START_MIGHTY_THRESH then
                becomemighty(inst, true)
            else
                becomenormal(inst, silent)
            end
        end
    elseif inst.components.hunger.current > TUNING.WOLFGANG_START_MIGHTY_THRESH then
        becomemighty(inst, silent)
    elseif inst.components.hunger.current < TUNING.WOLFGANG_START_WIMPY_THRESH then
        becomewimpy(inst, silent)
    end

    applymightiness(inst)
end

local function onnewstate(inst)
    if inst._wasnomorph ~= inst.sg:HasStateTag("nomorph") then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onhungerchange(inst)
        end
    end
end

local function onbecamehuman(inst, data)
    if inst._wasnomorph == nil then
        if not (data ~= nil and data.corpse) then
            inst.strength = "normal"
        end
        inst._wasnomorph = inst.sg:HasStateTag("nomorph")
        inst.talksoundoverride = nil
        inst.hurtsoundoverride = nil
        inst:ListenForEvent("hungerdelta", onhungerchange)
        inst:ListenForEvent("newstate", onnewstate)
        onhungerchange(inst, nil, true)
    end
end

local function onbecameghost(inst, data)
    if inst._wasnomorph ~= nil then
        if not (data ~= nil and data.corpse) then
            inst.strength = "normal"
        end
        inst._wasnomorph = nil
        inst.talksoundoverride = nil
        inst.hurtsoundoverride = nil
        inst:RemoveEventCallback("hungerdelta", onhungerchange)
        inst:RemoveEventCallback("newstate", onnewstate)
    end
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    --Restore absolute health value from loading after mightiness scaling
    local loadhealth = inst._loadhealth or inst.components.health.currenthealth
    inst._loadhealth = nil

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    elseif inst:HasTag("corpse") then
        onbecameghost(inst, { corpse = true })
    else
        onbecamehuman(inst)
    end

    inst.components.health:SetPercent(loadhealth / inst.components.health.maxhealth, true)
end

local function onpreload(inst, data)
    if data ~= nil and data.health ~= nil then
        inst._loadhealth = data.health.health
    end
end

--------------------------------------------------------------------------

local BASE_PHYSICS_RADIUS = .5
local AVATAR_SCALE = 1.5

local function lavaarena_onisavatardirty(inst)
    inst:SetPhysicsRadiusOverride(inst._isavatar:value() and AVATAR_SCALE * BASE_PHYSICS_RADIUS or BASE_PHYSICS_RADIUS)
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    if TheNet:GetServerGameMode() == "lavaarena" then
        inst._isavatar = net_bool(inst.GUID, "wolfgang._isavatar", "isavatardirty")

        if not TheWorld.ismastersim then
            inst:ListenForEvent("isavatardirty", lavaarena_onisavatardirty)
        end

        lavaarena_onisavatardirty(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_ovenmaster")
        inst:AddTag("quagmire_shopper")
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.strength = "normal"
    inst._mightiness_scale = 1
    inst._wasnomorph = nil
    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil

    inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)

    if TheNet:GetServerGameMode() == "lavaarena" then
        inst.OnIsAvatarDirty = lavaarena_onisavatardirty
        event_server_data("lavaarena", "prefabs/wolfgang").master_postinit(inst)
    else
        inst.components.health:SetMaxHealth(TUNING.WOLFGANG_HEALTH_NORMAL)
        inst.components.hunger.current = TUNING.WOLFGANG_START_HUNGER

        inst.components.sanity.night_drain_mult = 1.1
        inst.components.sanity.neg_aura_mult = 1.1

        inst.OnPreLoad = onpreload
        inst.OnLoad = onload
        inst.OnNewSpawn = onload
    end

    inst:ListenForEvent("mounted", OnMounted)
    inst:ListenForEvent("dismounted", OnDismounted)
end

return MakePlayerCharacter("wolfgang", prefabs, assets, common_postinit, master_postinit)
