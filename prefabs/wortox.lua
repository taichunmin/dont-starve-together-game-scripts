local MakePlayerCharacter = require("prefabs/player_common")
local wortox_soul_common = require("prefabs/wortox_soul_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SCRIPT", "scripts/prefabs/wortox_soul_common.lua"),
    Asset("SOUND", "sound/wortox.fsb"),
    Asset("ANIM", "anim/player_idles_wortox.zip"),
    Asset("ANIM", "anim/wortox_portal.zip"),
}

local prefabs =
{
    "wortox_soul_spawn",
    "wortox_portal_jumpin_fx",
    "wortox_portal_jumpout_fx",
    "wortox_eat_soul_fx",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WORTOX
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

for k, v in pairs(start_inv) do
    for i1, v1 in ipairs(v) do
        if not table.contains(prefabs, v1) then
            table.insert(prefabs, v1)
        end
    end
end

--------------------------------------------------------------------------

local function IsValidVictim(victim)
    return wortox_soul_common.HasSoul(victim) and victim.components.health:IsDead()
end

local function OnRestoreSoul(victim)
    victim.nosoultask = nil
end

local function SpawnSoulAt(x, y, z, victim)
    local fx = SpawnPrefab("wortox_soul_spawn")
    fx.Transform:SetPosition(x, y, z)
    fx:Setup(victim)
end

local function SpawnSoulsAt(victim, numsouls)
    local x, y, z = victim.Transform:GetWorldPosition()
    if numsouls == 2 then
        local theta = math.random() * 2 * PI
        local radius = .4 + math.random() * .1
        SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
        theta = GetRandomWithVariance(theta + PI, PI / 15)
        SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
    else
        SpawnSoulAt(x, y, z, victim)
        if numsouls > 1 then
            numsouls = numsouls - 1
            local theta0 = math.random() * 2 * PI
            local dtheta = 2 * PI / numsouls
            local thetavar = dtheta / 10
            local theta, radius
            for i = 1, numsouls do
                theta = GetRandomWithVariance(theta0 + dtheta * i, thetavar)
                radius = 1.6 + math.random() * .4
                SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim)
            end
        end
    end
end

local function OnEntityDropLoot(inst, data)
    local victim = data.inst
    if victim ~= nil and
        victim.nosoultask == nil and
        victim:IsValid() and
        (   victim == inst or
            (   not inst.components.health:IsDead() and
                IsValidVictim(victim) and
                inst:IsNear(victim, TUNING.WORTOX_SOULEXTRACT_RANGE)
            )
        ) then
        --V2C: prevents multiple Wortoxes in range from spawning multiple souls per corpse
        victim.nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
        SpawnSoulsAt(victim, wortox_soul_common.GetNumSouls(victim))
    end
end

local function OnEntityDeath(inst, data)
    if data.inst ~= nil and data.inst.components.lootdropper == nil then
        OnEntityDropLoot(inst, data)
    end
end

local function OnStarvedTrapSouls(inst, data)
    local trap = data.trap
    if trap ~= nil and
        trap.nosoultask == nil and
        (data.numsouls or 0) > 0 and
        trap:IsValid() and
        inst:IsNear(trap, TUNING.WORTOX_SOULEXTRACT_RANGE) then
        --V2C: prevents multiple Wortoxes in range from spawning multiple souls per trap
        trap.nosoultask = trap:DoTaskInTime(5, OnRestoreSoul)
        SpawnSoulsAt(trap, data.numsouls)
    end
end

local function GiveSouls(inst, num, pos)
    local soul = SpawnPrefab("wortox_soul")
    if soul.components.stackable ~= nil then
        soul.components.stackable:SetStackSize(num)
    end
    inst.components.inventory:GiveItem(soul, nil, pos)
end

local function OnMurdered(inst, data)
    local victim = data.victim
    if victim ~= nil and
        victim.nosoultask == nil and
        victim:IsValid() and
        (   not inst.components.health:IsDead() and
            wortox_soul_common.HasSoul(victim)
        ) then
        --V2C: prevents multiple Wortoxes in range from spawning multiple souls per corpse
        victim.nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
        GiveSouls(inst, wortox_soul_common.GetNumSouls(victim) * (data.stackmult or 1), inst:GetPosition())
    end
end

local function OnHarvestTrapSouls(inst, data)
    if (data.numsouls or 0) > 0 then
        GiveSouls(inst, data.numsouls, data.pos or inst:GetPosition())
    end
end

local function OnRespawnedFromGhost(inst)
    if inst._onentitydroplootfn == nil then
        inst._onentitydroplootfn = function(src, data) OnEntityDropLoot(inst, data) end
        inst:ListenForEvent("entity_droploot", inst._onentitydroplootfn, TheWorld)
    end
    if inst._onentitydeathfn == nil then
        inst._onentitydeathfn = function(src, data) OnEntityDeath(inst, data) end
        inst:ListenForEvent("entity_death", inst._onentitydeathfn, TheWorld)
    end
    if inst._onstarvedtrapsoulsfn == nil then
        inst._onstarvedtrapsoulsfn = function(src, data) OnStarvedTrapSouls(inst, data) end
        inst:ListenForEvent("starvedtrapsouls", inst._onstarvedtrapsoulsfn, TheWorld)
    end
end

local function OnBecameGhost(inst)
    if inst._onentitydroplootfn ~= nil then
        inst:RemoveEventCallback("entity_droploot", inst._onentitydroplootfn, TheWorld)
        inst._onentitydroplootfn = nil
    end
    if inst._onentitydeathfn ~= nil then
        inst:RemoveEventCallback("entity_death", inst._onentitydeathfn, TheWorld)
        inst._onentitydeathfn = nil
    end
    if inst._onstarvedtrapsoulsfn ~= nil then
        inst:RemoveEventCallback("starvedtrapsouls", inst._onstarvedtrapsoulsfn, TheWorld)
        inst._onstarvedtrapsoulsfn = nil
    end
end

local function IsSoul(item)
    return item.prefab == "wortox_soul"
end

local function GetStackSize(item)
    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end

local function SortByStackSize(l, r)
    return GetStackSize(l) < GetStackSize(r)
end

local function CheckSoulsAdded(inst)
    inst._checksoulstask = nil
    local souls = inst.components.inventory:FindItems(IsSoul)
    local count = 0
    for i, v in ipairs(souls) do
        count = count + GetStackSize(v)
    end
    if count > TUNING.WORTOX_MAX_SOULS then
        --convert count to drop count
        count = count - math.floor(TUNING.WORTOX_MAX_SOULS / 2) + math.random(0, 2) - 1
        table.sort(souls, SortByStackSize)
        local pos = inst:GetPosition()
        for i, v in ipairs(souls) do
            local vcount = GetStackSize(v)
            if vcount < count then
                inst.components.inventory:DropItem(v, true, true, pos)
                count = count - vcount
            else
                if vcount == count then
                    inst.components.inventory:DropItem(v, true, true, pos)
                else
                    v = v.components.stackable:Get(count)
                    v.Transform:SetPosition(pos:Get())
                    v.components.inventoryitem:OnDropped(true)
                end
                break
            end
        end
        inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
        inst:PushEvent("souloverload")
    elseif count > TUNING.WORTOX_MAX_SOULS * .8 then
        inst:PushEvent("soultoomany")
    end
end

local function CheckSoulsRemoved(inst)
    inst._checksoulstask = nil
    local count = 0
    for i, v in ipairs(inst.components.inventory:FindItems(IsSoul)) do
        count = count + GetStackSize(v)
        if count >= TUNING.WORTOX_MAX_SOULS * .2 then
            return
        end
    end
    inst:PushEvent(count > 0 and "soultoofew" or "soulempty")
end

local function CheckSoulsRemovedAfterAnim(inst, anim)
    if inst.AnimState:IsCurrentAnimation(anim) then
        inst._checksoulstask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + 2 * FRAMES, CheckSoulsRemoved)
    else
        CheckSoulsRemoved(inst)
    end
end

local function OnGotNewItem(inst, data)
    if data.item ~= nil and data.item.prefab == "wortox_soul" then
        if inst._checksoulstask ~= nil then
            inst._checksoulstask:Cancel()
        end
        inst._checksoulstask = inst:DoTaskInTime(0, CheckSoulsAdded)
    end
end

local function OnDropItem(inst, data)
    if data.item ~= nil and data.item.prefab == "wortox_soul" and inst.sg:HasStateTag("doing") then
        if inst._checksoulstask ~= nil then
            inst._checksoulstask:Cancel()
        end
        inst._checksoulstask = inst:DoTaskInTime(0, CheckSoulsRemovedAfterAnim, "pickup_pst")
    end
end

--------------------------------------------------------------------------

local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function ReticuleTargetFn(inst)
    local rotation = inst.Transform:GetRotation() * DEGREES
    local pos = inst:GetPosition()
    pos.y = 0
    for r = 13, 4, -.5 do
        local offset = FindWalkableOffset(pos, rotation, r, 1, false, true, NoHoles)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.z = pos.z + offset.z
            return pos
        end
    end
    for r = 13.5, 16, .5 do
        local offset = FindWalkableOffset(pos, rotation, r, 1, false, true, NoHoles)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.z = pos.z + offset.z
            return pos
        end
    end
    pos.x = pos.x + math.cos(rotation) * 13
    pos.z = pos.z - math.sin(rotation) * 13
    return pos
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil and inst.replica.inventory:Has("wortox_soul", 1) then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then
            return { ACTIONS.BLINK }
        end
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end

--------------------------------------------------------------------------

local function OnEatSoul(inst, soul)
    inst.components.hunger:DoDelta(TUNING.CALORIES_MEDSMALL)
    inst.components.sanity:DoDelta(-TUNING.SANITY_TINY)
    if inst._checksoulstask ~= nil then
        inst._checksoulstask:Cancel()
    end
    inst._checksoulstask = inst:DoTaskInTime(.2, CheckSoulsRemovedAfterAnim, "eat")
end

local function OnSoulHop(inst)
    if inst._checksoulstask ~= nil then
        inst._checksoulstask:Cancel()
    end
    inst._checksoulstask = inst:DoTaskInTime(.5, CheckSoulsRemovedAfterAnim, "wortox_portal_jumpout")
end

--------------------------------------------------------------------------

local function CLIENT_Wortox_HostileTest(inst, target)
    return (target:HasTag("hostile") or target:HasTag("pig") or target:HasTag("catcoon"))
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("playermonster")
    inst:AddTag("monster")
    inst:AddTag("soulstealer")

    --souleater (from souleater component) added to pristine state for optimization
    inst:AddTag("souleater")

    inst:ListenForEvent("setowner", OnSetOwner)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst.HostileTest = CLIENT_Wortox_HostileTest
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.customidleanim = "idle_wortox"

    inst.components.health:SetMaxHealth(TUNING.WORTOX_HEALTH)
    inst.components.hunger:SetMax(TUNING.WORTOX_HUNGER)
    inst.components.sanity:SetMax(TUNING.WORTOX_SANITY)
    inst.components.sanity.neg_aura_mult = TUNING.WORTOX_SANITY_AURA_MULT

    if inst.components.eater ~= nil then
        inst.components.eater:SetAbsorptionModifiers(TUNING.WORTOX_FOOD_MULT, TUNING.WORTOX_FOOD_MULT, TUNING.WORTOX_FOOD_MULT)
    end

    inst.components.foodaffinity:AddPrefabAffinity("pomegranate", TUNING.AFFINITY_15_CALORIES_TINY)
    inst.components.foodaffinity:AddPrefabAffinity("pomegranate_cooked", TUNING.AFFINITY_15_CALORIES_SMALL)

    inst:AddComponent("souleater")
    inst.components.souleater:SetOnEatSoulFn(OnEatSoul)

    inst._checksoulstask = nil

    inst:ListenForEvent("gotnewitem", OnGotNewItem)
    inst:ListenForEvent("dropitem", OnDropItem)
    inst:ListenForEvent("soulhop", OnSoulHop)
    inst:ListenForEvent("murdered", OnMurdered)
    inst:ListenForEvent("harvesttrapsouls", OnHarvestTrapSouls)
    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
    inst:ListenForEvent("ms_becameghost", OnBecameGhost)

    OnRespawnedFromGhost(inst)
end

return MakePlayerCharacter("wortox", prefabs, assets, common_postinit, master_postinit)
