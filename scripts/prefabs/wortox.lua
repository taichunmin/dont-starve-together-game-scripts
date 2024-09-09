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

local function IsValidVictim(victim, explosive)
    return wortox_soul_common.HasSoul(victim) and (victim.components.health:IsDead() or explosive)
end

local function OnRestoreSoul(victim)
    victim.nosoultask = nil
end

local function OnEntityDropLoot(inst, data)
    local victim = data.inst
    if victim ~= nil and
        victim.nosoultask == nil and
        victim:IsValid() and
        (   victim == inst or
            (   not inst.components.health:IsDead() and
                IsValidVictim(victim, data.explosive) and
                inst:IsNear(victim, TUNING.WORTOX_SOULEXTRACT_RANGE)
            )
        ) then
        --V2C: prevents multiple Wortoxes in range from spawning multiple souls per corpse
        victim.nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
        wortox_soul_common.SpawnSoulsAt(victim, wortox_soul_common.GetNumSouls(victim))
    end
end

local function OnEntityDeath(inst, data)
    if data.inst ~= nil then
        data.inst._soulsource = data.afflicter -- Mark the victim.
        if (data.inst.components.lootdropper == nil or data.inst.components.lootdropper.forcewortoxsouls or data.explosive) then -- NOTES(JBK): Explosive entities do not drop loot.
            OnEntityDropLoot(inst, data)
        end
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
        wortox_soul_common.SpawnSoulsAt(trap, data.numsouls)
    end
end

local function OnMurdered(inst, data)
    if data.incinerated then
        return -- NOTES(JBK): Do not give souls for this.
    end
    local victim = data.victim
    if victim ~= nil and
        victim.nosoultask == nil and
        victim:IsValid() and
        (   not inst.components.health:IsDead() and
            wortox_soul_common.HasSoul(victim)
        ) then
        --V2C: prevents multiple Wortoxes in range from spawning multiple souls per corpse
        victim.nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
        wortox_soul_common.GiveSouls(inst, wortox_soul_common.GetNumSouls(victim) * (data.stackmult or 1), inst:GetPosition())
    end
end

local function OnHarvestTrapSouls(inst, data)
    if (data.numsouls or 0) > 0 then
        wortox_soul_common.GiveSouls(inst, data.numsouls, data.pos or inst:GetPosition())
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

local function TryToOnRespawnedFromGhost(inst)
    if not inst.components.health:IsDead() and not inst:HasTag("playerghost") then
        OnRespawnedFromGhost(inst)
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

local function GetSouls(inst)
    local souls = inst.components.inventory:FindItems(IsSoul)
    local count = 0
    for i, v in ipairs(souls) do
        count = count + GetStackSize(v)
    end
    return souls, count
end

local function DropSouls(inst, souls, dropcount)
    if dropcount <= 0 then
        return
    end
    table.sort(souls, SortByStackSize)
    local pos = inst:GetPosition()
    for _, v in ipairs(souls) do
        local vcount = GetStackSize(v)
        if vcount < dropcount then
            inst.components.inventory:DropItem(v, true, true, pos)
            dropcount = dropcount - vcount
        else
            if vcount == dropcount then
                inst.components.inventory:DropItem(v, true, true, pos)
            else
                v = v.components.stackable:Get(dropcount)
                v.Transform:SetPosition(pos:Get())
                v.components.inventoryitem:OnDropped(true)
            end
            break
        end
    end
end

local function OnReroll(inst)
    local souls, count = GetSouls(inst)
    DropSouls(inst, souls, count)
end

local function ClearSoulOverloadTask(inst)
    inst._souloverloadtask = nil
end

local function CheckSoulsAdded(inst)
    inst._checksoulstask = nil
    local souls, count = GetSouls(inst)
    if count > TUNING.WORTOX_MAX_SOULS then
        if inst._souloverloadtask then
            inst._souloverloadtask:Cancel()
            inst._souloverloadtask = nil
        end
        inst._souloverloadtask = inst:DoTaskInTime(1.2, ClearSoulOverloadTask) -- NOTES(JBK): This is >1.1 max keep it in sync with "[WST]"
        --convert count to drop count
        count = count - math.floor(TUNING.WORTOX_MAX_SOULS / 2) + math.random(0, 2) - 1
        DropSouls(inst, souls, count)
        inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
        inst:PushEvent("souloverload")
    elseif count > TUNING.WORTOX_MAX_SOULS * TUNING.WORTOX_WISECRACKER_TOOMANY then
        inst:PushEvent("soultoomany") -- This event is not used elsewhere outside of wisecracker.
    end
end

local function CheckSoulsRemoved(inst)
    inst._checksoulstask = nil
    local count = 0
    for i, v in ipairs(inst.components.inventory:FindItems(IsSoul)) do
        count = count + GetStackSize(v)
        if count >= TUNING.WORTOX_MAX_SOULS * TUNING.WORTOX_WISECRACKER_TOOFEW then
            return
        end
    end
    inst:PushEvent(count > 0 and "soultoofew" or "soulempty") -- These events are not used elsewhere outside of wisecracker.
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

local function CanBlinkTo(pt)
    return TheWorld.Map:IsPassableAtPoint(pt:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pt) -- NOTES(JBK): Keep in sync with blinkstaff. [BATELE]
end

local function CanBlinkFromWithMap(pt)
    return true -- NOTES(JBK): Change this if there is a reason to anchor Wortox when trying to use the map to teleport.
end

local function ReticuleTargetFn(inst)
    return ControllerReticle_Blink_GetPosition(inst, inst.CanBlinkTo)
end

local function CanSoulhop(inst, souls)
    if inst.replica.inventory:Has("wortox_soul", souls or 1) then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then
            return true
        end
    end
    return false
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil then
        local canblink
        if inst.checkingmapactions then
            canblink = inst.CanBlinkFromWithMap(inst:GetPosition())
        else
            canblink = inst.CanBlinkTo(pos)
        end
        if canblink and inst.CanSoulhop and inst:CanSoulhop() then
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
    inst.components.hunger:DoDelta(TUNING.CALORIES_MED)
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

local function PutSoulOnCooldown(item)
    if not IsSoul(item) then
        return
    end

    if item.components.rechargeable ~= nil then
        item.components.rechargeable:Discharge(TUNING.WORTOX_FREEHOP_TIMELIMIT)
    end
end

local function RemoveSoulCooldown(item)
    if not IsSoul(item) then
        return
    end

    if item.components.rechargeable ~= nil then
        item.components.rechargeable:SetPercent(1)
    end
end

local function SetNetvar(inst)
    if inst.player_classified ~= nil then
        assert(inst._freesoulhop_counter >= 0 and inst._freesoulhop_counter <= 7, "Player _freesoulhop_counter out of range: "..tostring(inst._freesoulhop_counter))
        inst.player_classified.freesoulhops:set(inst._freesoulhop_counter)
    end
end

local function ClearSoulhopCounter(inst)
    inst._freesoulhop_counter = 0
    inst._soulhop_cost = 0
    SetNetvar(inst)
end

local function FinishPortalHop(inst)
    if inst._freesoulhop_counter > 0 then
        if inst.components.inventory ~= nil then
            inst.components.inventory:ConsumeByName("wortox_soul", math.max(math.ceil(inst._soulhop_cost), 1))
        end
        ClearSoulhopCounter(inst)
    end
end

local function TryToPortalHop(inst, souls, consumeall)
    local invcmp = inst.components.inventory
    if invcmp == nil then
        return false
    end

    souls = souls or 1
    local _, soulscount = GetSouls(inst)
    if soulscount < souls then
        return false
    end

    inst._freesoulhop_counter = inst._freesoulhop_counter + souls
    inst._soulhop_cost = inst._soulhop_cost + souls

    if not consumeall and inst._freesoulhop_counter < TUNING.WORTOX_FREEHOP_HOPSPERSOUL then
        inst._soulhop_cost = inst._soulhop_cost - souls -- Make it free.
        invcmp:ForEachItem(PutSoulOnCooldown)
    else
        invcmp:ForEachItem(RemoveSoulCooldown)
        inst:FinishPortalHop()
    end
    SetNetvar(inst)

    return true
end

local function OnFreesoulhopsChanged(inst, data)
    inst._freesoulhop_counter = data and data.current or 0
end

--------------------------------------------------------------------------

local function CLIENT_Wortox_HostileTest(inst, target)
	if target.HostileToPlayerTest ~= nil then
		return target:HostileToPlayerTest(inst)
	end
    return (target:HasTag("hostile") or target:HasTag("pig") or target:HasTag("catcoon"))
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("playermonster")
    inst:AddTag("monster")
    inst:AddTag("soulstealer")

    --souleater (from souleater component) added to pristine state for optimization
    inst:AddTag("souleater")

    inst._freesoulhop_counter = 0
    inst.CanSoulhop = CanSoulhop
    inst.CanBlinkTo = CanBlinkTo
    inst.CanBlinkFromWithMap = CanBlinkFromWithMap
    inst:ListenForEvent("setowner", OnSetOwner)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst.HostileTest = CLIENT_Wortox_HostileTest
    if not TheWorld.ismastersim then
        inst:ListenForEvent("freesoulhopschanged", OnFreesoulhopsChanged)
    end
end

local function OnSave(inst, data)
    data.freehops = inst._freesoulhop_counter
    data.soulhopcost = inst._soulhop_cost
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    inst._freesoulhop_counter = data.freehops or 0
    inst._soulhop_cost = data.soulhopcost or 0
    inst:DoTaskInTime(0, SetNetvar)
end

local function master_postinit(inst)
    ClearSoulhopCounter(inst)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.TryToPortalHop = TryToPortalHop
    inst.FinishPortalHop = FinishPortalHop

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
    inst:ListenForEvent("ms_playerreroll", OnReroll)

    inst:DoTaskInTime(0, TryToOnRespawnedFromGhost) -- NOTES(JBK): Player loading in with zero health will still be alive here delay a frame to get loaded values.
end

return MakePlayerCharacter("wortox", prefabs, assets, common_postinit, master_postinit)
