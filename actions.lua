require "class"
require "bufferedaction"
require "debugtools"
require 'util'

local function DefaultRangeCheck(doer, target)
    if target == nil then
        return
    end
    local target_x, target_y, target_z = target.Transform:GetWorldPosition()
    local doer_x, doer_y, doer_z = doer.Transform:GetWorldPosition()
    local dst = distsq(target_x, target_z, doer_x, doer_z)
    return dst <= 16
end

--Positional parameters have been deprecated, pass in a table instead.
Action = Class(function(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn)
    if data == nil then
        data = {}
    end
    if type(data) ~= "table" then
        --#TODO: get rid of the positional parameters all together, this warning here is for mods that may be using the old interface.
        print("WARNING: Positional Action parameters are deprecated. Please pass action a table instead.")
        print(string.format("Action defined at %s", debugstack_oneline(4)))
        local priority = data
        data = {priority=priority, instant=instant, rmb=rmb, ghost_valid=ghost_valid, ghost_exclusive=ghost_exclusive, canforce=canforce, rangecheckfn=rangecheckfn}
    end

    self.priority = data.priority or 0
    self.fn = function() return false end
    self.strfn = nil
    self.instant = data.instant or false
    self.rmb = data.rmb or nil -- note! This actually only does something for tools, everything tests 'right' in componentactions
    self.distance = data.distance or nil
    self.mindistance = data.mindistance or nil
    self.ghost_exclusive = data.ghost_exclusive or false
    self.ghost_valid = self.ghost_exclusive or data.ghost_valid or false -- If it's ghost-exclusive, then it must be ghost-valid
    self.mount_valid = data.mount_valid or false
    self.encumbered_valid = data.encumbered_valid or false
    self.canforce = data.canforce or nil
    self.rangecheckfn = self.canforce ~= nil and data.rangecheckfn or nil
    self.mod_name = nil

    --new params, only supported by passing via data field
    self.actionmeter = data.actionmeter or nil
end)

ACTIONS =
{
    REPAIR = Action({ mount_valid=true, encumbered_valid=true }),
    READ = Action({ mount_valid=true }),
    DROP = Action({ priority=-1, mount_valid=true, encumbered_valid=true }),
    TRAVEL = Action(),
    CHOP = Action(),
    ATTACK = Action({ priority=2, canforce=true, mount_valid=true }), -- No custom range check, attack already handles that
    EAT = Action({ mount_valid=true }),
    PICK = Action({ canforce=true, rangecheckfn=DefaultRangeCheck }),
    PICKUP = Action({ priority=1 }),
    MINE = Action(),
    DIG = Action({ rmb=true }),
    GIVE = Action({ mount_valid=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    GIVETOPLAYER = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    GIVEALLTOPLAYER = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    FEEDPLAYER = Action({ priority=3, rmb=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    DECORATEVASE = Action(),
    COOK = Action({ priority=1, mount_valid=true }),
    FILL = Action(),
    DRY = Action(),
    ADDFUEL = Action({ mount_valid=true }),
    ADDWETFUEL = Action({ mount_valid=true }),
    LIGHT = Action({ priority=-4 }),
    EXTINGUISH = Action({ priority=0 }),
    LOOKAT = Action({ priority=-3, instant=true, ghost_valid=true, mount_valid=true, encumbered_valid=true }),
    TALKTO = Action({ priority=3, instant=true, mount_valid=true, encumbered_valid=true }),
    WALKTO = Action({ priority=-4, ghost_valid=true, mount_valid=true, encumbered_valid=true }),
    BAIT = Action(),
    CHECKTRAP = Action({ priority=2 }),
    BUILD = Action({ mount_valid=true }),
    PLANT = Action(),
    HARVEST = Action(),
    GOHOME = Action(),
    SLEEPIN = Action(),
    CHANGEIN = Action({ priority=-1 }),
    EQUIP = Action({ priority=0,instant=true, mount_valid=true, encumbered_valid=true }),
    UNEQUIP = Action({ priority=-2,instant=true, mount_valid=true, encumbered_valid=true }),
    --OPEN_SHOP = Action(),
    SHAVE = Action({ mount_valid=true }),
    STORE = Action(),
    RUMMAGE = Action({ priority=-1, mount_valid=true }),
    DEPLOY = Action({ distance=1.1 }),
    PLAY = Action({ mount_valid=true }),
    CREATE = Action(),
    JOIN = Action(),
    NET = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    CATCH = Action({ priority=3, distance=math.huge, mount_valid=true }),
    FISH = Action(),
    REEL = Action({ instant=true }),
    POLLINATE = Action(),
    FERTILIZE = Action(),
    SMOTHER = Action({ priority=1 }),
    MANUALEXTINGUISH = Action({ priority=1 }),
    LAYEGG = Action(),
    HAMMER = Action({ priority=3 }),
    TERRAFORM = Action(),
    JUMPIN = Action({ ghost_valid=true, encumbered_valid=true }),
    TELEPORT = Action({ rmb=true, distance=2 }),
    RESETMINE = Action({ priority=3 }),
    ACTIVATE = Action(),
    MURDER = Action({ priority=0, mount_valid=true }),
    HEAL = Action({ mount_valid=true }),
    INVESTIGATE = Action(),
    UNLOCK = Action(),
    USEKLAUSSACKKEY = Action(),
    TEACH = Action({ mount_valid=true }),
    TURNON = Action({ priority=2 }),
    TURNOFF = Action({ priority=2 }),
    SEW = Action({ mount_valid=true }),
    STEAL = Action(),
    USEITEM = Action({ priority=1, instant=true }),
    TAKEITEM = Action(),
    MAKEBALLOON = Action({ mount_valid=true }),
    CASTSPELL = Action({ priority=-1, rmb=true, distance=20, mount_valid=true }),
    BLINK = Action({ priority=10, rmb=true, distance=36, mount_valid=true }),
    COMBINESTACK = Action({ mount_valid=true }),
    TOGGLE_DEPLOY_MODE = Action({ priority=1, instant=true }),
    SUMMONGUARDIAN = Action({ rmb=false, distance=5 }),
    HAUNT = Action({ rmb=false, mindistance=2, ghost_valid=true, ghost_exclusive=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    UNPIN = Action(),
    STEALMOLEBAIT = Action({ rmb=false, distance=.75 }),
    MAKEMOLEHILL = Action({ priority=4, rmb=false, distance=0 }),
    MOLEPEEK = Action({ rmb=false, distance=1 }),
    FEED = Action({ rmb=true, mount_valid=true }),
    UPGRADE = Action({ rmb=true }),
    HAIRBALL = Action({ rmb=false, distance=3 }),
    CATPLAYGROUND = Action({ rmb=false, distance=1 }),
    CATPLAYAIR = Action({ rmb=false, distance=2 }),
    FAN = Action({ rmb=true, mount_valid=true }),
    DRAW = Action(),
    BUNDLE = Action({ rmb=true, priority=2 }),
    BUNDLESTORE = Action({ instant=true }),
    WRAPBUNDLE = Action({ instant=true }),
    UNWRAP = Action({ rmb=true, priority=2 }),
    STARTCHANNELING = Action({ distance=2.1 }),
    STOPCHANNELING = Action({ instant=true, distance=2.1 }),

    TOSS = Action({ rmb=true, distance=8, mount_valid=true }),
    NUZZLE = Action(),
    WRITE = Action(),
    ATTUNE = Action(),
    REMOTERESURRECT = Action({ rmb=false, ghost_valid=true, ghost_exclusive=true }),
    REVIVE_CORPSE = Action({ rmb=false, actionmeter=true }),
    MIGRATE = Action({ rmb=false, encumbered_valid=true, ghost_valid=true }),
    MOUNT = Action({ priority=1, rmb=true, encumbered_valid=true }),
    DISMOUNT = Action({ priority=1, instant=true, rmb=true, mount_valid=true, encumbered_valid=true }),
    SADDLE = Action({ priority=1 }),
    UNSADDLE = Action({ priority=3, rmb=false }),
    BRUSH = Action({ priority=3, rmb=false }),
    ABANDON = Action({ rmb=true }),
    PET = Action(),

    CASTAOE = Action({ priority=10, rmb=true, distance=8 }),

    --Quagmire
    TILL = Action({ distance=0.5 }),
    PLANTSOIL = Action(),
    INSTALL = Action(),
    TAPTREE = Action({priority=1, rmb=true}),
    SLAUGHTER = Action({ canforce=true, rangecheckfn=DefaultRangeCheck }),
    REPLATE = Action(),
    SALT = Action(),
}

ACTION_IDS = {}
for k, v in orderedPairs(ACTIONS) do
    v.str = STRINGS.ACTIONS[k] or "ACTION"
    v.id = k
    table.insert(ACTION_IDS, k)
    v.code = #ACTION_IDS
end

ACTION_MOD_IDS = {} --This will be filled in when mods add actions via AddAction in modutil.lua

----set up the action functions!

ACTIONS.EAT.fn = function(act)
    local obj = act.target or act.invobject
    if obj ~= nil and obj.components.edible ~= nil and act.doer.components.eater ~= nil then
        return act.doer.components.eater:Eat(obj, act.doer)
    end
end

ACTIONS.STEAL.fn = function(act)
    local owner = act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem.owner or nil
    if owner ~= nil then
        return act.doer.components.thief:StealItem(owner, act.target, act.attack == true)
    end
end

ACTIONS.MAKEBALLOON.fn = function(act)
    if act.doer ~= nil and
        act.invobject ~= nil and
        act.invobject.components.balloonmaker ~= nil and
        act.doer:HasTag("balloonomancer") then
        if act.doer.components.sanity ~= nil then
            if act.doer.components.sanity.current < TUNING.SANITY_TINY then
                return false
            end
            act.doer.components.sanity:DoDelta(-TUNING.SANITY_TINY)
        end
        --Spawn it to either side of doer's current facing with some variance
        local x, y, z = act.doer.Transform:GetWorldPosition()
        local angle = act.doer.Transform:GetRotation()
        local angle_offset = GetRandomMinMax(-10, 10)
        angle_offset = angle_offset + (angle_offset < 0 and -65 or 65)
        angle = (angle + angle_offset) * DEGREES
        act.invobject.components.balloonmaker:MakeBalloon(
            x + .5 * math.cos(angle),
            0,
            z - .5 * math.sin(angle)
        )
        return true
    end
end

ACTIONS.EQUIP.fn = function(act)
    if act.doer.components.inventory ~= nil then
        return act.doer.components.inventory:Equip(act.invobject)
    end
end

ACTIONS.UNEQUIP.strfn = function(act)
    return (act.invobject ~= nil and
            act.invobject:HasTag("heavy") or
            GetGameModeProperty("non_item_equips") or
            act.doer.replica.inventory:GetNumSlots() <= 0)
        and "HEAVY"
        or nil
end

ACTIONS.UNEQUIP.fn = function(act)
    if act.invobject ~= nil and act.doer.components.inventory ~= nil then
        if act.invobject.components.inventoryitem.cangoincontainer and not GetGameModeProperty("non_item_equips") then
            act.doer.components.inventory:GiveItem(act.invobject)
        else
            act.doer.components.inventory:DropItem(act.invobject, true, true)
        end
        return true
    end
end

ACTIONS.PICKUP.strfn = function(act)
    return act.target ~= nil
        and act.target:HasTag("heavy")
        and "HEAVY"
        or nil
end

ACTIONS.PICKUP.fn = function(act)
    if act.doer.components.inventory ~= nil and
        act.target ~= nil and
        act.target.components.inventoryitem ~= nil and
        (act.target.components.inventoryitem.canbepickedup or
        (act.target.components.inventoryitem.canbepickedupalive and not act.doer:HasTag("player"))) and
        not (act.target:IsInLimbo() or
            (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning()) or
            (act.target.components.projectile ~= nil and act.target.components.projectile:IsThrown())) then

        if act.doer.components.itemtyperestrictions ~= nil and not act.doer.components.itemtyperestrictions:IsAllowed(act.target) then
            return false, "restriction"
        elseif act.target.components.container ~= nil and act.target.components.container:IsOpen() and not act.target.components.container:IsOpenedBy(act.doer) then
            return false, "inuse"
        end

        act.doer:PushEvent("onpickupitem", { item = act.target })

        --special case for trying to carry two backpacks
        if not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
            local item = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
            if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
                
                --act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
                act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
            else
                act.doer.components.inventory:DropItem(act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot))
            end
            act.doer.components.inventory:Equip(act.target)
            return true
        end

        if act.target.components.equippable ~= nil and act.doer:HasTag("player") then
            local equip = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
            if equip == nil or act.doer.components.inventory:GetNumSlots() <= 0 then
                act.doer.components.inventory:Equip(act.target)
                return true
            elseif GetGameModeProperty("non_item_equips") then
                act.doer.components.inventory:DropItem(equip)
                act.doer.components.inventory:Equip(act.target)
                return true
            end
        end
        act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
        return true
    end
end

ACTIONS.REPAIR.fn = function(act)
    if act.target ~= nil and act.target.components.repairable ~= nil then
        local material
        if act.doer ~= nil and
            act.doer.components.inventory ~= nil and
            act.doer.components.inventory:IsHeavyLifting() and
            not (act.doer.components.rider ~= nil and
                act.doer.components.rider:IsRiding()) then
            material = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        else
            material = act.invobject
        end
        if material ~= nil and material.components.repairer ~= nil then
            return act.target.components.repairable:Repair(act.doer, material)
        end
    end
end

ACTIONS.SEW.strfn = function(act)
    return act.invobject ~= nil
        and (act.invobject:HasTag("tape") and "PATCH")
        or nil
end

ACTIONS.SEW.fn = function(act)
    if act.target ~= nil and
        act.invobject ~= nil and
        act.target.components.fueled ~= nil and
        act.invobject.components.sewing ~= nil then
        return act.invobject.components.sewing:DoSewing(act.target, act.doer)
    end
end

ACTIONS.RUMMAGE.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil and targ.components.container ~= nil then
        if targ.components.container:IsOpenedBy(act.doer) then
            targ.components.container:Close()
            act.doer:PushEvent("closecontainer", { container = targ })
            return true
        elseif targ.components.container:IsOpen() then
            return false, "INUSE"
        elseif targ.components.container.canbeopened then
            local owner = targ.components.inventoryitem ~= nil and targ.components.inventoryitem:GetGrandOwner() or nil
            if owner ~= nil and targ.components.quagmire_stewer ~= nil then
                if owner == act.doer then
                    owner.components.inventory:DropItem(targ, true, true)
                elseif owner.components.container ~= nil and owner.components.container:IsOpenedBy(act.doer) then
                    owner.components.container:DropItem(targ)
                else
                    --Silent fail, should not reach here
                    return true
                end
            end
            --Silent fail for opening containers in the dark
            if CanEntitySeeTarget(act.doer, targ) then
                act.doer:PushEvent("opencontainer", { container = targ })
                targ.components.container:Open(act.doer)
            end
            return true
        end
    end
end

ACTIONS.RUMMAGE.strfn = function(act)
    local targ = act.target or act.invobject
    return targ ~= nil
        and (   targ.replica.container ~= nil and
                targ.replica.container:IsOpenedBy(act.doer) and
                "CLOSE" or
                (act.target ~= nil and act.target:HasTag("winter_tree") and "DECORATE")
            )
        or nil
end

ACTIONS.DROP.fn = function(act)
    return act.doer.components.inventory ~= nil
        and act.doer.components.inventory:DropItem(
                act.invobject,
                act.options.wholestack and
                not (act.invobject ~= nil and
                    act.invobject.components.stackable ~= nil and
                    act.invobject.components.stackable.forcedropsingle),
                false,
                act.pos)
        or nil
end

ACTIONS.DROP.strfn = function(act)
    if act.invobject ~= nil and not act.invobject:HasActionComponent("deployable") then
        return (act.invobject:HasTag("trap") and "SETTRAP")
            or (act.invobject:HasTag("mine") and "SETMINE")
            or (act.invobject.prefab == "pumpkin_lantern" and "PLACELANTERN")
            or nil
    end
end

ACTIONS.LOOKAT.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil and targ.components.inspectable ~= nil then
        local desc = targ.components.inspectable:GetDescription(act.doer)
        if desc ~= nil then
            if act.doer.components.playercontroller == nil or
                not act.doer.components.playercontroller.directwalking then
                act.doer.components.locomotor:Stop()
            end
            if act.doer.components.talker ~= nil then
                act.doer.components.talker:Say(desc, 2.5, targ.components.inspectable.noanim)
            end
            return true
        end
    end
end

ACTIONS.READ.fn = function(act)
    local targ = act.target or act.invobject
    if targ ~= nil and
        act.doer ~= nil and
        targ.components.book ~= nil and
        act.doer.components.reader ~= nil then
        return act.doer.components.reader:Read(targ)
    end
end

ACTIONS.TALKTO.fn = function(act)
    local targ = act.target or act.invobject
    if targ and targ.components.talkable then
        act.doer.components.locomotor:Stop()

        if act.target.components.maxwelltalker then
            if not act.target.components.maxwelltalker:IsTalking() then
                act.target:PushEvent("talkedto")
                act.target.task = act.target:StartThread(function() act.target.components.maxwelltalker:DoTalk(act.target) end)
            end
        end
        return true
    end
end

ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject))
        return true
    end
end

ACTIONS.DEPLOY.fn = function(act)
    if act.invobject and act.invobject.components.deployable and act.invobject.components.deployable:CanDeploy(act.pos) then
        local obj = (act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)) or 
        (act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject))
        if obj then
            if obj.components.deployable:Deploy(act.pos, act.doer, act.rotation) then
                return true
            else
                act.doer.components.inventory:GiveItem(obj)
            end
        end
    end
end

ACTIONS.DEPLOY.strfn = function(act)
    return act.invobject ~= nil
        and (   (act.invobject:HasTag("groundtile") and "GROUNDTILE") or
                (act.invobject:HasTag("wallbuilder") and "WALL") or
                (act.invobject:HasTag("fencebuilder") and "FENCE") or
                (act.invobject:HasTag("gatebuilder") and "GATE") or
                (act.invobject:HasTag("eyeturret") and "TURRET")    )
        or nil
end

ACTIONS.TOGGLE_DEPLOY_MODE.strfn = ACTIONS.DEPLOY.strfn

ACTIONS.SUMMONGUARDIAN.fn = function(act)
    if act.doer and act.target and act.target.components.guardian then
        act.target.components.guardian:Call()
    end
end

ACTIONS.CHECKTRAP.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:Harvest(act.doer)
        return true
    end
end

local function DoToolWork(act, workaction)
    if act.target.components.workable ~= nil and
        act.target.components.workable:CanBeWorked() and
        act.target.components.workable.action == workaction then
        act.target.components.workable:WorkedBy(
            act.doer,
            (   act.invobject ~= nil and
                act.invobject.components.tool ~= nil and
                act.invobject.components.tool:GetEffectiveness(workaction)
            ) or
            (   act.doer ~= nil and
                act.doer.components.worker ~= nil and
                act.doer.components.worker:GetEffectiveness(workaction)
            ) or
            1
        )
    end
    return true
end

ACTIONS.CHOP.fn = function(act)
    return DoToolWork(act, ACTIONS.CHOP)
end

ACTIONS.MINE.fn = function(act)
    return DoToolWork(act, ACTIONS.MINE)
end

ACTIONS.HAMMER.fn = function(act)
    return DoToolWork(act, ACTIONS.HAMMER)
end

ACTIONS.DIG.fn = function(act)
    return DoToolWork(act, ACTIONS.DIG)
end

ACTIONS.FERTILIZE.fn = function(act)
    if act.target ~= nil and act.invobject ~= nil and act.invobject.components.fertilizer ~= nil then
        if act.target.components.crop ~= nil and not (act.target.components.crop:IsReadyForHarvest() or act.target:HasTag("withered")) then
            return act.target.components.crop:Fertilize(act.invobject, act.doer)
        elseif act.target.components.grower ~= nil and act.target.components.grower:IsEmpty() then
            act.target.components.grower:Fertilize(act.invobject, act.doer)
            return true
        elseif act.target.components.pickable ~= nil and act.target.components.pickable:CanBeFertilized() then
            act.target.components.pickable:Fertilize(act.invobject, act.doer)
            return true
        elseif act.target.components.quagmire_fertilizable ~= nil then
            act.target.components.quagmire_fertilizable:Fertilize(act.invobject, act.doer)
            return true
        end
    end
end


ACTIONS.SMOTHER.fn = function(act)
    if act.target.components.burnable and act.target.components.burnable:IsSmoldering() then
        local smotherer = act.invobject or act.doer
        act.target.components.burnable:SmotherSmolder(smotherer)
        return true
    end
end

ACTIONS.MANUALEXTINGUISH.fn = function(act)
    if act.invobject:HasTag("frozen") and act.target.components.burnable and act.target.components.burnable:IsBurning() then
        act.target.components.burnable:Extinguish(true, TUNING.SMOTHERER_EXTINGUISH_HEAT_PERCENT, act.invobject)
        return true
    end
end

ACTIONS.NET.fn = function(act)
    if act.target ~= nil and
        act.target.components.workable ~= nil and
        act.target.components.workable:CanBeWorked() and
        act.target.components.workable:GetWorkAction() == ACTIONS.NET and
        not (act.target.components.health ~= nil and act.target.components.health:IsDead()) then
        act.target.components.workable:WorkedBy(act.doer)
    end
    return true
end

ACTIONS.CATCH.fn = function(act)
    return true
end

ACTIONS.FISH.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod then
        fishingrod:StartFishing(act.target, act.doer)
    end
    return true
end

ACTIONS.REEL.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod and fishingrod:IsFishing() then
        if fishingrod:HasHookedFish() then
            fishingrod:Reel()
        elseif fishingrod:FishIsBiting() then
            fishingrod:Hook()
        else
            fishingrod:StopFishing()
        end
    end
    return true
end

ACTIONS.REEL.strfn = function(act)
    local fishingrod = act.invobject.replica.fishingrod
    if fishingrod ~= nil and fishingrod:GetTarget() == act.target then
        if fishingrod:HasHookedFish() then
            return "REEL"
        elseif act.doer:HasTag("nibble") then
            return "HOOK"
        else
            return "CANCEL"
        end
    end
end

ACTIONS.PICK.fn = function(act)
    if act.target ~= nil and act.target.components.pickable ~= nil then
        act.target.components.pickable:Pick(act.doer)
        return true
    end
end

ACTIONS.ATTACK.fn = function(act)
    if act.doer.sg ~= nil and act.doer.sg:HasStateTag("thrusting") then
        local weapon = act.doer.components.combat:GetWeapon()
        return weapon ~= nil
            and weapon.components.multithruster ~= nil
            and weapon.components.multithruster:StartThrusting(act.doer)
    end
    act.doer.components.combat:DoAttack(act.target)
    return true
end

ACTIONS.ATTACK.strfn = function(act)
    if act.target ~= nil then
        --act.invobject is weapon
        if act.invobject ~= nil and act.doer.replica.combat ~= nil then
            if act.doer.replica.combat:CanExtinguishTarget(act.target, act.invobject) then
                return "RANGEDSMOTHER"
            elseif act.doer.replica.combat:CanLightTarget(act.target, act.invobject) then
                return "RANGEDLIGHT"
            elseif act.target:HasTag("mole") and act.invobject:HasTag("hammer") then
                return "WHACK"
            end
        end

        if act.target:HasTag("smashable") then
            return "SMASHABLE"
        end
    end
end

ACTIONS.COOK.fn = function(act)
    if act.target.components.cooker ~= nil then
        local cook_pos = act.target:GetPosition()
        local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)

        --V2C: position usually matters for listeners of "killed" event
        ingredient.Transform:SetPosition(cook_pos:Get())

        if not act.target.components.cooker:CanCook(ingredient, act.doer) then
            act.doer.components.inventory:GiveItem(ingredient, nil, cook_pos)
            return false
        end

        if ingredient.components.health ~= nil and ingredient.components.combat ~= nil then
            act.doer:PushEvent("killed", { victim = ingredient })
        end

        local product = act.target.components.cooker:CookItem(ingredient, act.doer)
        if product ~= nil then
            act.doer.components.inventory:GiveItem(product, nil, cook_pos)
            return true
        elseif ingredient:IsValid() then
            act.doer.components.inventory:GiveItem(ingredient, nil, cook_pos)
        end
        return false
    elseif act.target.components.stewer ~= nil then
        if act.target.components.stewer:IsCooking() then
            --Already cooking
            return true
        end
        local container = act.target.components.container
        if container ~= nil and container:IsOpen() and not container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.stewer:CanCook() then
            return false
        end
        act.target.components.stewer:StartCooking()
        return true
    elseif act.target.components.cookable ~= nil
        and act.invobject ~= nil
        and act.invobject.components.cooker ~= nil then

        local cook_pos = act.target:GetPosition()

        --Intentional use of 3D dist check for birds.
        if act.doer:GetPosition():Dist(cook_pos) > 2 then
            return false, "TOOFAR"
        end

        local owner = act.target.components.inventoryitem:GetGrandOwner()
        local container = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
        local stacked = act.target.components.stackable ~= nil and act.target.components.stackable:IsStack()
        local ingredient = stacked and act.target.components.stackable:Get() or act.target

        if ingredient ~= act.target then
            --V2C: position usually matters for listeners of "killed" event
            ingredient.Transform:SetPosition(cook_pos:Get())
        end

        if not act.invobject.components.cooker:CanCook(ingredient, act.doer) then
            if container ~= nil then
                container:GiveItem(ingredient, nil, cook_pos)
            elseif stacked and ingredient ~= act.target then
                act.target.components.stackable:SetStackSize(act.target.components.stackable:StackSize() + 1)
                ingredient:Remove()
            end
            return false
        end

        if ingredient.components.health ~= nil and ingredient.components.combat ~= nil then
            act.doer:PushEvent("killed", { victim = ingredient })
        end

        local product = act.invobject.components.cooker:CookItem(ingredient, act.doer)
        if product ~= nil then
            if container ~= nil then
                container:GiveItem(product, nil, cook_pos)
            else
                product.Transform:SetPosition(cook_pos:Get())
                if stacked and product.Physics ~= nil then
                    local angle = math.random() * 2 * PI
                    local speed = math.random() * 2
                    product.Physics:SetVel(speed * math.cos(angle), GetRandomWithVariance(8, 4), speed * math.sin(angle))
                end
            end
            return true
        elseif ingredient:IsValid() then
            if container ~= nil then
                container:GiveItem(ingredient, nil, cook_pos)
            elseif stacked and ingredient ~= act.target then
                act.target.components.stackable:SetStackSize(act.target.components.stackable:StackSize() + 1)
                ingredient:Remove()
            end
        end
        return false
    end
end

ACTIONS.FILL.fn = function(act)
    return act.target ~= nil
        and act.invobject ~= nil
        and act.invobject.components.fillable ~= nil
        and act.target:HasTag("watersource")
        and act.invobject.components.fillable:Fill()
end

ACTIONS.DRY.fn = function(act)
    if act.target.components.dryer then
        if not act.target.components.dryer:CanDry(act.invobject) then
            return false
        end

        local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
        if not act.target.components.dryer:StartDrying(ingredient) then
            act.doer.components.inventory:GiveItem(ingredient, nil, act.target:GetPosition())
            return false 
        end
        return true
    end
end

ACTIONS.ADDFUEL.fn = function(act)
    if act.doer.components.inventory then
        local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
        if fuel then
            if act.target.components.fueled:TakeFuelItem(fuel, act.doer) then
                return true
            else
                --print("False")
                act.doer.components.inventory:GiveItem(fuel)
            end
        end
    end
end

ACTIONS.ADDWETFUEL.fn = function(act)
    if act.doer.components.inventory then
        local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
        if fuel then
            if act.target.components.fueled:TakeFuelItem(fuel, act.doer) then
                return true
            else
                -- print("False")
                act.doer.components.inventory:GiveItem(fuel)
            end
        end
    end
end

ACTIONS.GIVE.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("gemsocket") and "SOCKET" or nil
end

ACTIONS.GIVE.stroverridefn = function(act)
    --Quagmire action strings
    if act.target ~= nil and act.invobject ~= nil then
        if act.target.nameoverride ~= nil and act.invobject:HasTag("quagmire_stewer") then
            return subfmt(STRINGS.ACTIONS.GIVE[string.upper(act.target.nameoverride)], { item = act.invobject:GetBasicDisplayName() })
        elseif act.target:HasTag("quagmire_altar") then
            if act.invobject.prefab == "quagmire_portal_key" then
                return STRINGS.ACTIONS.GIVE.SOCKET
            elseif act.invobject.prefab:sub(1, 14) == "quagmire_food_" then
                local dish = act.invobject.basedish
                if dish == nil then
                    local i = act.invobject.prefab:find("_", 15)
                    if i ~= nil then
                        dish = STRINGS.NAMES[string.upper(act.invobject.prefab:sub(1, i - 1))]
                    end
                end
                local str = dish ~= nil and STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR[string.upper(dish)] or nil
                if str ~= nil then
                    return subfmt(str, { food = act.invobject:GetBasicDisplayName() })
                end
            end
            return subfmt(STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR.GENERIC, { food = act.invobject:GetBasicDisplayName() })
        end
    end
end

ACTIONS.GIVE.fn = function(act)
    if act.target ~= nil then
        if act.target.components.trader ~= nil then
            local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
            if not able then
                return false, reason
            end
            act.target.components.trader:AcceptGift(act.doer, act.invobject)
            return true
        elseif act.target.components.quagmire_cookwaretrader ~= nil then
            return act.target.components.quagmire_cookwaretrader:AcceptCookware(act.doer, act.invobject)
        elseif act.target.components.quagmire_altar ~= nil then
            return act.target.components.quagmire_altar:AcceptFoodTribute(act.doer, act.invobject)
        end
    end
end

ACTIONS.GIVETOPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target.components.trader ~= nil and
        act.target.components.inventory ~= nil and
        (act.target.components.inventory:IsOpenedBy(act.target) or act.target:HasTag("playerghost")) then
        if act.target.components.inventory:CanAcceptCount(act.invobject, 1) <= 0 then
            return false, "FULL"
        end
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, 1)
        return true
    end
end

ACTIONS.GIVEALLTOPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target.components.trader ~= nil and
        act.target.components.inventory ~= nil and
        act.target.components.inventory:IsOpenedBy(act.target) then
        local count = act.target.components.inventory:CanAcceptCount(act.invobject)
        if count <= 0 then
            return false, "FULL"
        end
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, count)
        return true
    end
end

ACTIONS.FEEDPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target:IsValid() and
        act.target.sg:HasStateTag("idle") and
        not (act.target.sg:HasStateTag("busy") or
            act.target.sg:HasStateTag("attacking") or
            act.target.sg:HasStateTag("sleeping") or
            act.target:HasTag("playerghost")) and
        act.target.components.eater ~= nil and
        act.invobject.components.edible ~= nil and
        act.target.components.eater:CanEat(act.invobject) and
        (TheNet:GetPVPEnabled() or
        not (act.invobject:HasTag("badfood") or
            act.invobject:HasTag("spoiled"))) then

        if act.target.components.eater:PrefersToEat(act.invobject) then
            local food = act.invobject.components.inventoryitem:RemoveFromOwner()
            if food ~= nil then
                act.target:AddChild(food)
                food:RemoveFromScene()
                food.components.inventoryitem:HibernateLivingItem()
                food.persists = false
                act.target.sg:GoToState(
                    (act.target:HasTag("beaver") and "beavereat") or
                    (food.components.edible.foodtype == FOODTYPE.MEAT and "eat") or
                    "quickeat",
                    {feed=food,feeder=act.doer}
                )
                return true
            end
        else
            act.target:PushEvent("wonteatfood", { food = act.invobject })
            return true -- the action still "succeeded", there's just no result on this end
        end
    end
end

ACTIONS.DECORATEVASE.fn = function(act)
    if act.target ~= nil and act.target.components.vase ~= nil and act.target.components.vase.enabled then
        act.target.components.vase:Decorate(act.doer, act.invobject)
        return true
    end
end

ACTIONS.STORE.fn = function(act)
    if act.target.components.container ~= nil and act.invobject.components.inventoryitem ~= nil and act.doer.components.inventory ~= nil then
        if act.target.components.container:IsOpen() and not act.target.components.container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.container:CanTakeItemInSlot(act.invobject) then
            return false, "NOTALLOWED"
        end

        local forceopen = act.target.components.quagmire_stewer ~= nil and act.target.components.inventoryitem ~= nil
        local forcedrop = forceopen and act.target.components.inventoryitem:GetGrandOwner() or nil
        if forcedrop ~= nil and forcedrop ~= act.doer then
            --Silent fail, should not reach here
            return true
        end

        local item = act.invobject.components.inventoryitem:RemoveFromOwner(act.target.components.container.acceptsstacks)
        if item ~= nil then
            if forcedrop ~= nil then
                forcedrop.components.inventory:DropItem(act.target, true, true)
            end
            if forceopen or act.target.components.inventoryitem == nil then
                act.target.components.container:Open(act.doer)
            end

            if not act.target.components.container:GiveItem(item, nil, nil, false) then
                if act.doer.components.playercontroller ~= nil and
                    act.doer.components.playercontroller.isclientcontrollerattached then
                    act.doer.components.inventory:GiveItem(item)
                else
                    act.doer.components.inventory:GiveActiveItem(item)
                end
                return false
            end
            return true
        end
    elseif act.invobject ~= nil and
        act.invobject.components.occupier ~= nil and
        act.target.components.occupiable ~= nil and
        act.target.components.occupiable:CanOccupy(act.invobject) then
        return act.target.components.occupiable:Occupy(act.invobject.components.inventoryitem:RemoveFromOwner())
    end
end

ACTIONS.BUNDLESTORE.fn = ACTIONS.STORE.fn

ACTIONS.STORE.strfn = function(act)
    if act.target ~= nil then
        return ((act.target.prefab == "cookpot" or act.target:HasTag("quagmire_stewer")) and "COOK")
            or (act.target.prefab == "birdcage" and "IMPRISON")
            or (act.target:HasTag("winter_tree") and "DECORATE")
            or nil
    end
end

ACTIONS.BUILD.fn = function(act)
    if act.doer.components.builder ~= nil then
        return act.doer.components.builder:DoBuild(act.recipe, act.pos, act.rotation, act.skin)
    end
end

ACTIONS.PLANT.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("winter_treestand") and "PLANTER" or nil
end

ACTIONS.PLANT.fn = function(act)
    if act.doer.components.inventory ~= nil then
        local seed = act.doer.components.inventory:RemoveItem(act.invobject)
        if seed ~= nil then
            if act.target.components.grower ~= nil and act.target.components.grower:PlantItem(seed) then
                return true
            elseif act.target:HasTag("winter_treestand")
                and act.target.components.burnable ~= nil
                and not (act.target.components.burnable:IsBurning() or
                        act.target.components.burnable:IsSmoldering()) then
                act.target:PushEvent("plantwintertreeseed", { seed = seed })
                return true
            else
                act.doer.components.inventory:GiveItem(seed)
            end
        end
    end
end

ACTIONS.HARVEST.fn = function(act)
    if act.target.components.crop ~= nil then
        local harvested--[[, product]] = act.target.components.crop:Harvest(act.doer)
        return harvested
    elseif act.target.components.harvestable ~= nil then
        return act.target.components.harvestable:Harvest(act.doer)
    elseif act.target.components.stewer ~= nil then
        return act.target.components.stewer:Harvest(act.doer)
    elseif act.target.components.dryer ~= nil then
        return act.target.components.dryer:Harvest(act.doer)
    elseif act.target.components.occupiable ~= nil and act.target.components.occupiable:IsOccupied() then
        local item = act.target.components.occupiable:Harvest(act.doer)
        if item ~= nil then
            act.doer.components.inventory:GiveItem(item)
            return true
        end
	elseif act.target.components.quagmire_tappable ~= nil then
		return act.target.components.quagmire_tappable:Harvest(act.doer)
    end
end

ACTIONS.HARVEST.strfn = function(act)
    if act.target ~= nil and act.target.prefab == "birdcage" then
        return "FREE"
    end
    if act.target ~= nil and act.target.components.crop and act.target:HasTag("withered") then
        return "WITHERED"
    end
end

ACTIONS.LIGHT.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.lighter ~= nil then
        if act.doer ~= nil then
            act.doer:PushEvent("onstartedfire", { target = act.target })
        end
        act.invobject.components.lighter:Light(act.target)
        return true
    end
end

ACTIONS.SLEEPIN.fn = function(act)
    if act.doer ~= nil then
        local bag =
            (act.invobject ~= nil and act.invobject.components.sleepingbag ~= nil and act.invobject) or
            (act.target ~= nil and act.target.components.sleepingbag ~= nil and act.target) or
            nil
        if bag ~= nil then
            bag.components.sleepingbag:DoSleep(act.doer)
            return true
        end
    end
end

ACTIONS.CHANGEIN.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("dressable") and "DRESSUP" or nil
end

ACTIONS.CHANGEIN.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.wardrobe ~= nil then

        local success, reason = act.target.components.wardrobe:CanBeginChanging(act.doer)
        if not success then
            return false, reason
        end

        --Silent fail for opening wardrobe in the dark
        if CanEntitySeeTarget(act.doer, act.target) then
            act.target.components.wardrobe:BeginChanging(act.doer)
        end
        return true
    end
end

ACTIONS.SHAVE.strfn = function(act)
    return (act.target == nil or act.target == act.doer)
        and TheInput:ControllerAttached()
        and "SELF"
        or nil
end

ACTIONS.SHAVE.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.shaver ~= nil then
        local shavee = act.target or act.doer
        if shavee ~= nil and shavee.components.beard ~= nil then
            return shavee.components.beard:Shave(act.doer, act.invobject)
        end
    end
end

ACTIONS.PLAY.fn = function(act)
    if act.invobject and act.invobject.components.instrument then
        return act.invobject.components.instrument:Play(act.doer)
    end
end

ACTIONS.POLLINATE.fn = function(act)
    if act.doer.components.pollinator ~= nil then
        if act.target ~= nil then
            return act.doer.components.pollinator:Pollinate(act.target)
        else
            return act.doer.components.pollinator:CreateFlower()
        end
    end
end

ACTIONS.TERRAFORM.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.terraformer ~= nil then
        return act.invobject.components.terraformer:Terraform(act.pos, true)
    end
end

ACTIONS.EXTINGUISH.fn = function(act)
    if act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning() then
        if act.target.components.fueled ~= nil and not act.target.components.fueled:IsEmpty() then
            act.target.components.fueled:ChangeSection(-1)
        else
            act.target.components.burnable:Extinguish()
        end
        return true
    end
end

ACTIONS.LAYEGG.fn = function(act)
    if act.target.components.pickable ~= nil and not act.target.components.pickable.canbepicked then
        return act.target.components.pickable:Regen()
    end
end

ACTIONS.INVESTIGATE.fn = function(act)
    local investigatePos = act.doer.components.knownlocations ~= nil and act.doer.components.knownlocations:GetLocation("investigate") or nil
    if investigatePos ~= nil then
        act.doer.components.knownlocations:RememberLocation("investigate", nil)
        --try to get a nearby target
        if act.doer.components.combat ~= nil then
            act.doer.components.combat:TryRetarget()
        end
        return true
    end
end

ACTIONS.GOHOME.fn = function(act)
    --this is gross. make it better later.
    if act.doer.force_onwenthome_message then
        act.doer:PushEvent("onwenthome")
    end
    if act.target ~= nil then
        if act.target.components.spawner ~= nil then
            return act.target.components.spawner:GoHome(act.doer)
        elseif act.target.components.childspawner ~= nil then
            return act.target.components.childspawner:GoHome(act.doer)
        elseif act.target.components.hideout ~= nil then
            return act.target.components.hideout:GoHome(act.doer)
        end
        act.target:PushEvent("onwenthome", { doer = act.doer })
        act.doer:Remove()
        return true
    elseif act.pos ~= nil then
        act.doer:Remove()
        return true
    end
end

ACTIONS.JUMPIN.strfn = function(act)
    return act.doer ~= nil and act.doer:HasTag("playerghost") and "HAUNT" or nil
end

ACTIONS.JUMPIN.fn = function(act)
    if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "jumpin_pre" then
        if act.target ~= nil and
            act.target.components.teleporter ~= nil and
            act.target.components.teleporter:IsActive() then
            act.doer.sg:GoToState("jumpin", { teleporter = act.target })
            return true
        end
        act.doer.sg:GoToState("idle")
    end
end

ACTIONS.TELEPORT.strfn = function(act)
    return act.target ~= nil and "TOWNPORTAL" or nil
end

ACTIONS.TELEPORT.fn = function(act)
    if act.doer ~= nil and act.doer.sg ~= nil then
        local teleporter
        if act.invobject ~= nil then
            if act.doer.sg.currentstate.name == "dolongaction" then
                teleporter = act.invobject
            end
        elseif act.target ~= nil
            and act.doer.sg.currentstate.name == "give" then
            teleporter = act.target
        end
        if teleporter ~= nil and teleporter:HasTag("teleporter") then
            act.doer.sg:GoToState("entertownportal", { teleporter = teleporter })
            return true
        end
    end
end

ACTIONS.RESETMINE.fn = function(act)
    if act.target.components.mine ~= nil then
        act.target.components.mine:Reset()
        return true
    end
end

ACTIONS.ACTIVATE.fn = function(act)
    if act.target.components.activatable ~= nil and act.target.components.activatable:CanActivate(act.doer) then
        local success, msg = act.target.components.activatable:DoActivate(act.doer)
        return (success ~= false), msg -- note: for legacy reasons, nil will be true
    end
end

ACTIONS.ACTIVATE.strfn = function(act)
    if act.target.GetActivateVerb ~= nil then
        return act.target:GetActivateVerb(act.doer)
    end
end

ACTIONS.HAUNT.fn = function(act)
    if act.target ~= nil and
        act.target:IsValid() and
        not act.target:IsInLimbo() and
        act.target.components.hauntable ~= nil and
        not (act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem:IsHeld()) and
        not (act.target:HasTag("haunted") or act.target:HasTag("catchable")) then
        act.doer:PushEvent("haunt", { target = act.target })
        act.target.components.hauntable:DoHaunt(act.doer)
        return true
    end
end

ACTIONS.MURDER.fn = function(act)
    local murdered = act.invobject or act.target
    if murdered ~= nil and murdered.components.health ~= nil then
        local x, y, z = act.doer.Transform:GetWorldPosition()
        murdered.components.inventoryitem:RemoveFromOwner(true)
        murdered.Transform:SetPosition(x, y, z)

        if murdered.components.health.murdersound ~= nil then
            act.doer.SoundEmitter:PlaySound(murdered.components.health.murdersound)
        end

        if murdered.components.lootdropper ~= nil then
            murdered.causeofdeath = act.doer
            local pos = Vector3(x, y, z)
            local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
            for i = 1, stacksize do
                local loots = murdered.components.lootdropper:GenerateLoot()
                for k, v in pairs(loots) do
                    local loot = SpawnPrefab(v)
                    if loot ~= nil then
                        act.doer.components.inventory:GiveItem(loot, nil, pos)
                    end
                end
            end
        end

        act.doer:PushEvent("killed", { victim = murdered })
        murdered:Remove()

        return true
    end
end

ACTIONS.HEAL.strfn = function(act)
    return (act.target == nil or act.target == act.doer)
        and TheInput:ControllerAttached()
        and "SELF"
        or nil
end

ACTIONS.HEAL.fn = function(act)
    if act.invobject and act.invobject.components.healer then
        local target = act.target or act.doer
        return act.invobject.components.healer:Heal(target)
    elseif act.invobject and act.invobject.components.maxhealer then
        local target = act.target or act.doer
        return act.invobject.components.maxhealer:Heal(target)
    end
end

ACTIONS.UNLOCK.fn = function(act)
    if act.target.components.lock ~= nil then
        if act.target.components.lock:IsLocked() then
            act.target.components.lock:Unlock(act.invobject, act.doer)
        --else
            --act.target.components.lock:Lock(act.doer)
        end
        return true
    end
end

ACTIONS.USEKLAUSSACKKEY.fn = function(act)
    if act.target.components.klaussacklock ~= nil then
        local able, reason = act.target.components.klaussacklock:UseKey(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        return true
    end
end

ACTIONS.TEACH.fn = function(act)
    if act.invobject ~= nil then
        local target = act.target or act.doer
        if act.invobject.components.teacher ~= nil then
            return act.invobject.components.teacher:Teach(target)
        elseif act.invobject.components.maprecorder ~= nil then
            local success, reason = act.invobject.components.maprecorder:TeachMap(target)
            if success or reason == "BLANK" then
                return true
            end
            return success, reason
        end
    end
end

ACTIONS.TURNON.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and not tar.components.machine:IsOn() then
        tar.components.machine:TurnOn(tar)
        return true
    end
end

ACTIONS.TURNOFF.strfn = function(act)
    local tar = act.target
    return tar ~= nil and tar:HasTag("hasemergencymode") and "EMERGENCY" or nil
end

ACTIONS.TURNOFF.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and tar.components.machine:IsOn() then
        tar.components.machine:TurnOff(tar)
        return true
    end
end

ACTIONS.USEITEM.fn = function(act)
    if act.invobject ~= nil and
        act.invobject.components.useableitem ~= nil and
        act.invobject.components.useableitem:CanInteract() and
        act.doer.components.inventory ~= nil and
        act.doer.components.inventory:IsOpenedBy(act.doer) then
        act.invobject.components.useableitem:StartUsingItem()
    end
end

ACTIONS.TAKEITEM.fn = function(act)
    --Use this for taking a specific item as opposed to having an item be generated as it is in Pick/ Harvest
    if act.target ~= nil and act.target.components.shelf ~= nil and act.target.components.shelf.cantakeitem then
        act.target.components.shelf:TakeItem(act.doer)
        return true
    end
end

ACTIONS.TAKEITEM.strfn = function(act)
    return act.target.prefab == "birdcage" and "BIRDCAGE" or "GENERIC"
end

ACTIONS.TAKEITEM.stroverridefn = function(act)
    local item = act.target.takeitem ~= nil and act.target.takeitem:value() or nil
    return item ~= nil and subfmt(STRINGS.ACTIONS.TAKEITEM.ITEM, { item = item:GetBasicDisplayName() }) or nil
end

ACTIONS.CASTSPELL.strfn = function(act)
    return act.invobject ~= nil and act.invobject.spelltype or nil
end

ACTIONS.CASTSPELL.fn = function(act)
    --For use with magical staffs
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then
        staff.components.spellcaster:CastSpell(act.target, act.pos)
        return true
    end
end


ACTIONS.BLINK.fn = function(act)
    if act.invobject and act.invobject.components.blinkstaff then
        return act.invobject.components.blinkstaff:Blink(act.pos, act.doer)
    end
end

ACTIONS.COMBINESTACK.fn = function(act)
    local target = act.target
    local invobj = act.invobject
    if invobj and target and invobj.prefab == target.prefab and target.components.stackable and not target.components.stackable:IsFull() then
        target.components.stackable:Put(invobj)
        return true
    end 
end

ACTIONS.TRAVEL.fn = function(act)
    if act.target and act.target.travel_action_fn then
        act.target.travel_action_fn(act.doer)
        return true
    end
end

ACTIONS.UNPIN.fn = function(act)
    if act.doer ~= act.target and act.target.components.pinnable and act.target.components.pinnable:IsStuck() then
        act.target:PushEvent("unpinned")
        return true
    end
end

ACTIONS.STEALMOLEBAIT.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer.prefab == "mole" then
        act.target.selectedasmoletarget = nil
        act.target:PushEvent("onstolen", { thief = act.doer })
        return true
    end
end

ACTIONS.MAKEMOLEHILL.fn = function(act)
    if act.doer and act.doer.prefab == "mole" then
        local molehill = SpawnPrefab("molehill")
        molehill.Transform:SetPosition(act.doer.Transform:GetWorldPosition())
        molehill:AdoptChild(act.doer)
        act.doer.needs_home_time = nil
        return true
    end
end

ACTIONS.MOLEPEEK.fn = function(act)
    if act.doer and act.doer.prefab == "mole" then
        act.doer:PushEvent("peek")
        return true
    end
end

ACTIONS.FEED.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.eater ~= nil and act.target.components.eater:CanEat(act.invobject) then
        act.target.components.eater:Eat(act.invobject, act.doer)
        local murdered =
            act.target:IsValid() and
            act.target.components.health ~= nil and
            act.target.components.health:IsDead() and
            act.target or nil

        if murdered ~= nil then
            murdered.causeofdeath = act.doer

            local owner = murdered.components.inventoryitem ~= nil and murdered.components.inventoryitem.owner or nil
            if owner ~= nil then
                --In inventory or container:
                --Slightly different from MURDER action since victim ate and died
                --in place, so there should be no looting animation, and the loot
                --should always replace the victim's old slot.
                local grandowner = murdered.components.inventoryitem:GetGrandOwner()
                local x, y, z = grandowner.Transform:GetWorldPosition()
                murdered.components.inventoryitem:RemoveFromOwner(true)
                murdered.Transform:SetPosition(x, y, z)

                if murdered.components.health.murdersound ~= nil and grandowner.SoundEmitter ~= nil then
                    grandowner.SoundEmitter:PlaySound(murdered.components.health.murdersound)
                end

                if murdered.components.lootdropper ~= nil then
                    local container = owner.components.inventory or owner.components.container
                    if container ~= nil then
                        local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
                        for i = 1, stacksize do
                            local loots = murdered.components.lootdropper:GenerateLoot()
                            for k, v in pairs(loots) do
                                local loot = SpawnPrefab(v)
                                if loot ~= nil then
                                    container:GiveItem(loot, murdered.prevslot)
                                end
                            end
                        end
                    end
                end
            end

            act.doer:PushEvent("killed", { victim = murdered })

            if owner ~= nil then
                murdered:Remove()
            end
        end
        return true
    end

--[[    local murdered = act.invobject or act.target
    if murdered ~= nil and murdered.components.health ~= nil then
        local x, y, z = act.doer.Transform:GetWorldPosition()
        murdered.components.inventoryitem:RemoveFromOwner(true)
        murdered.Transform:SetPosition(x, y, z)

        if murdered.components.health.murdersound ~= nil then
            act.doer.SoundEmitter:PlaySound(murdered.components.health.murdersound)
        end

        if murdered.components.lootdropper ~= nil then
            murdered.causeofdeath = act.doer
            local pos = Vector3(x, y, z)
            local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
            for i = 1, stacksize do
                local loots = murdered.components.lootdropper:GenerateLoot()
                for k, v in pairs(loots) do
                    local loot = SpawnPrefab(v)
                    if loot ~= nil then
                        act.doer.components.inventory:GiveItem(loot, nil, pos)
                    end
                end
            end
        end

        act.doer:PushEvent("killed", { victim = murdered })
        murdered:Remove()

        return true
    end]]
end

ACTIONS.HAIRBALL.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        return true
    end
end

ACTIONS.CATPLAYGROUND.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        if act.target then
            if math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH -- Only bother attacking if it's a penguin or weaker
            and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
            and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target))
            and not act.target:HasTag("player") then
                act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
            elseif math.random() < TUNING.CATCOON_PICKUP_ITEM_CHANCE and act.target.components.inventoryitem and act.target.components.inventoryitem.canbepickedup then
                act.target:Remove()
            end
        end
        return true
    end
end

ACTIONS.CATPLAYAIR.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        if act.target and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE
        and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH -- Only bother attacking if it's a penguin or weaker
        and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
        and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target)) then
            act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
        end
        act.doer.last_play_air_time = GetTime()
        return true
    end
end

ACTIONS.FAN.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.fan ~= nil then
        return act.invobject.components.fan:Fan(act.target or act.doer)
    end
end

ACTIONS.TOSS.fn = function(act)
    if act.invobject and act.doer then
        if act.invobject.components.complexprojectile and act.doer.components.inventory then
            local projectile = act.doer.components.inventory:DropItem(act.invobject, false)
            if projectile then
                local pos = nil
                if act.target then
                    pos = act.target:GetPosition()
                    projectile.components.complexprojectile.targetoffset = {x=0,y=1.5,z=0}
                else
                    pos = act.pos
                end
                projectile.components.complexprojectile:Launch(pos, act.doer)
                return true
            end
        end
    end
end

ACTIONS.UPGRADE.fn = function(act)
    if act.invobject and act.target
        and act.invobject.components.upgrader
        and act.invobject.components.upgrader:CanUpgrade(act.target, act.doer) then
        return act.target.components.upgradeable:Upgrade(act.invobject)
    end
end

ACTIONS.NUZZLE.fn = function(act)
    if act.target then
        --print(string.format("%s loves %s!", act.doer.prefab, act.target.prefab))
        return true
    end
end

ACTIONS.WRITE.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.writeable ~= nil and
        not act.target.components.writeable:IsWritten() then

        if act.target.components.writeable:IsBeingWritten() then
            return false, "INUSE"
        end

        --Silent fail for writing in the dark
        if CanEntitySeeTarget(act.doer, act.target) then
            act.target.components.writeable:BeginWriting(act.doer)
        end
        return true
    end
end

ACTIONS.ATTUNE.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.attunable ~= nil then
        return act.target.components.attunable:LinkToPlayer(act.doer)
    end
end

ACTIONS.MIGRATE.fn = function(act)
    --fail reasons: "NODESTINATION"
    return act.doer ~= nil
        and act.target ~= nil
        and act.target.components.worldmigrator ~= nil
        and act.target.components.worldmigrator:Activate(act.doer)
end

ACTIONS.REMOTERESURRECT.fn = function(act)
    if act.doer ~= nil and act.doer.components.attuner ~= nil and act.doer:HasTag("playerghost") then
        local target = act.doer.components.attuner:GetAttunedTarget("remoteresurrector")
        if target ~= nil then
            act.doer:PushEvent("respawnfromghost", { source = target })
            return true
        end
    end
end

ACTIONS.REVIVE_CORPSE.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.revivablecorpse ~= nil then
        --Silent fail
        if act.target.components.revivablecorpse:CanBeRevivedBy(act.doer) then
            act.target.components.revivablecorpse:Revive(act.doer)
        end
        return true
    end
end

ACTIONS.MOUNT.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable == nil
        or not act.target.components.rideable.canride
        or (act.target.components.health ~= nil and
            act.target.components.health:IsDead())
        or (act.target.components.freezable and
            act.target.components.freezable:IsFrozen()) then
        return false
    elseif act.target.components.rideable:IsBeingRidden() then
        return false, "INUSE"
    end
    act.doer.components.rider:Mount(act.target)
    return true
end

ACTIONS.DISMOUNT.fn = function(act)
    if act.doer == act.target and act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding() then
        act.doer.components.rider:Dismount()
        return true
    end
end

ACTIONS.SADDLE.fn = function(act) if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable ~= nil then
        --V2C: currently, rideable component implies saddleable always
        act.doer:PushEvent("saddle", { target = act.target })
        act.doer.components.inventory:RemoveItem(act.invobject)
        act.target.components.rideable:SetSaddle(act.doer, act.invobject)
        return true
    end
end

ACTIONS.UNSADDLE.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable ~= nil then
        --V2C: currently, rideable component implies saddleable always
        act.doer:PushEvent("saddle", { target = act.target })
        act.target.components.rideable:SetSaddle(act.doer, nil)
        return true
    end
end

ACTIONS.BRUSH.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.brushable ~= nil then
        act.target.components.brushable:Brush(act.doer, act.invobject)
        return true
    end
end

ACTIONS.ABANDON.fn = function(act)
    if act.doer.components.petleash ~= nil then
        if not (act.doer.components.builder ~= nil and act.doer.components.builder.accessible_tech_trees.ORPHANAGE > 0) then
            --we could've been in range but the pet was out of range
            local x, y, z = act.doer.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y, z, 10, { "critterlab" }) <= 0 then
                return false
            end
        end
        act.doer.components.petleash:DespawnPet(act.target)
        return true
    end
end

ACTIONS.PET.fn = function(act)
    if act.target ~= nil and act.doer.components.petleash ~= nil then
        act.target.components.crittertraits:OnPet(act.doer)
        return true
    end
end

require("components/drawingtool")
ACTIONS.DRAW.stroverridefn = function(act)
    local item = FindEntityToDraw(act.target, act.invobject)
    return item ~= nil
        and subfmt(STRINGS.ACTIONS.DRAWITEM, { item = item.drawnameoverride or item:GetBasicDisplayName() })
        or nil
end

ACTIONS.DRAW.fn = function(act)
    if act.invobject ~= nil and
        act.target ~= nil and
        act.invobject.components.drawingtool ~= nil and
        act.target.components.drawable ~= nil and
        act.target.components.drawable:CanDraw() then
        local image, src = act.invobject.components.drawingtool:GetImageToDraw(act.target)
        if image == nil then
            return false, "NOIMAGE"
        end
        act.invobject.components.drawingtool:Draw(act.target, image, src)
        return true
    end
end

ACTIONS.STARTCHANNELING.fn = function(act)
    return act.target ~= nil and act.target.components.channelable:StartChanneling(act.doer)
end

ACTIONS.STOPCHANNELING.fn = function(act)
    if act.target ~= nil then
        act.target.components.channelable:StopChanneling(true)
    end
    return true
end

ACTIONS.BUNDLE.fn = function(act)
    local target = act.invobject or act.target
    if target ~= nil and
        act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:CanStartBundling() then
        --Silent fail for bundling in the dark
        if CanEntitySeeTarget(act.doer, act.doer) then
            return act.doer.components.bundler:StartBundling(target)
        end
        return true
    end
end

ACTIONS.WRAPBUNDLE.fn = function(act)
    if act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:IsBundling(act.target) then
        if act.target.components.container ~= nil and not act.target.components.container:IsEmpty() then
            return act.doer.components.bundler:FinishBundling()
        elseif act.doer.components.talker ~= nil then
            act.doer.components.talker:Say(GetActionFailString(act.doer, "WRAPBUNDLE", "EMPTY"))
        end
        return true
    end
end

ACTIONS.UNWRAP.fn = function(act)
    local target = act.target or act.invobject
    if target ~= nil and
        target.components.unwrappable ~= nil and
        target.components.unwrappable.canbeunwrapped then
        target.components.unwrappable:Unwrap(act.doer)
        return true
    end
end

ACTIONS.CASTAOE.strfn = function(act)
    return act.invobject ~= nil and string.upper(act.invobject.prefab) or nil
end

ACTIONS.CASTAOE.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.aoespell ~= nil and act.invobject.components.aoespell:CanCast(act.doer, act.pos) then
        act.invobject.components.aoespell:CastSpell(act.doer, act.pos)
        return true
    end
end

--Quagmire
ACTIONS.TILL.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.quagmire_tiller ~= nil then
        return act.invobject.components.quagmire_tiller:Till(act.pos, act.doer)
    end
end

ACTIONS.PLANTSOIL.fn = function(act)
    if act.invobject ~= nil and
        act.doer.components.inventory ~= nil and
        act.target ~= nil and act.target:HasTag("soil") then
        local seed = act.doer.components.inventory:RemoveItem(act.invobject)
        if seed ~= nil then
            if seed.components.quagmire_plantable ~= nil and seed.components.quagmire_plantable:Plant(act.target, act.doer) then
                return true
            end
            act.doer.components.inventory:GiveItem(seed)
        end
    end
end

ACTIONS.INSTALL.fn = function(act)
    if act.invobject ~= nil and act.target ~= nil then
        if act.invobject.components.quagmire_installable ~= nil and
            act.invobject.components.quagmire_installable.installprefab ~= nil and
            act.target.components.quagmire_installations ~= nil and
            act.target.components.quagmire_installations:IsEnabled() then
            local part = SpawnPrefab(act.invobject.components.quagmire_installable.installprefab)
            if part ~= nil then
                act.invobject:Remove()
                act.target.components.quagmire_installations:Install(part)
                return true
            end
        elseif act.invobject.components.quagmire_saltextractor ~= nil
            and act.target.components.quagmire_saltpond ~= nil
            and act.invobject.components.quagmire_saltextractor:DoInstall(act.target) then
            act.invobject:Remove()
            return true
        end
    end
end

ACTIONS.TAPTREE.fn = function(act)
    if act.target ~= nil and  act.target.components.quagmire_tappable ~= nil then
        if act.target.components.quagmire_tappable:IsTapped() then
            act.target.components.quagmire_tappable:UninstallTap(act.doer)
            return true
        elseif act.invobject ~= nil and act.invobject.components.quagmire_tapper ~= nil then
            act.target.components.quagmire_tappable:InstallTap(act.doer, act.invobject)
            return true
        end
    end
end

ACTIONS.TAPTREE.strfn = function(act)
    return not act.target:HasTag("tappable") and "UNTAP" or nil
end

ACTIONS.SLAUGHTER.stroverridefn = function(act)
    return act.invobject ~= nil
        and act.invobject.GetSlaughterActionString ~= nil
        and act.invobject:GetSlaughterActionString(act.target)
        or nil
end

ACTIONS.SLAUGHTER.fn = function(act)
    if act.invobject.components.quagmire_slaughtertool ~= nil and act.invobject:IsValid() and act.doer:IsValid() then
        if act.target == nil then
            return false, "TOOFAR"
        elseif not (act.target:IsValid() and act.target:HasTag("canbeslaughtered")) then
            return false
        elseif not (act.target:IsInLimbo() or act.doer:IsNear(act.target, 2)) then
            return false, "TOOFAR"
        elseif act.target.components.health ~= nil and not act.target.components.health:IsDead() then
            act.invobject.components.quagmire_slaughtertool:Slaughter(act.doer, act.target)
            return true
        end
    end
end

ACTIONS.REPLATE.stroverridefn = function(act)
    --Quagmire action strings
    local replatable_inst = (act.target ~= nil and act.target:HasTag("quagmire_replatable") and act.target) or (act.invobject ~= nil and act.invobject:HasTag("quagmire_replatable") and act.invobject) or nil
    if replatable_inst ~= nil then
        local i = replatable_inst.prefab:find("_", 15)
        if i ~= nil then
            local dish = STRINGS.NAMES[string.upper(replatable_inst.prefab:sub(1, i - 1))]
            return dish ~= nil and subfmt(STRINGS.ACTIONS.REPLATE.FMT, { dish = dish }) or nil
        end
    end
end

ACTIONS.REPLATE.fn = function(act)
    if act.target ~= nil and act.invobject ~= nil then
        local replater = act.target.components.quagmire_replater or act.invobject.components.quagmire_replater
        local replatable = act.target.components.quagmire_replatable or act.invobject.components.quagmire_replatable
        if replater ~= nil and replatable ~= nil and replater ~= replatable then
            if replater.basedish ~= replatable.basedish then
                return false, "MISMATCH"
            elseif replater.dishtype == replatable.dishtype then
                return false, "SAMEDISH"
            end

            local dishtype = replater.dishtype
            local owner = replatable.inst.components.inventoryitem:GetGrandOwner()
            if owner ~= nil then
                local inventory = owner.components.inventory or owner.components.container
                local replater_owner = replater.inst.components.inventoryitem.owner
                if replater_owner == nil then
                    --new plate on the ground
                    inventory:DropItem(replatable.inst, true, false, replater.inst:GetPosition())
                    replater.inst:Remove()
                    replatable:Replate(dishtype, nil, act.doer)
                elseif replatable.inst == act.invobject then
                    --new plate in inventory
                    --spawn new entity so UI animates on clients
                    local replater_container = replater_owner.components.inventory or replater_owner.components.container
                    local replater_slot = replater_container:GetItemSlot(replater.inst)
                    local prefab = replatable.inst.prefab
                    local perish = replatable.inst.components.perishable ~= nil and replatable.inst.components.perishable:GetPercent() or nil
                    local salted = replatable.inst:HasTag("quagmire_salted")
                    replatable.inst:Remove()
                    replater.inst:Remove()
                    local newitem = SpawnPrefab(prefab)
                    if perish ~= nil then
                        newitem.components.perishable:SetPercent(perish)
                    end
                    if salted then
                        newitem.components.quagmire_saltable:Salt(0, true)
                    end
                    newitem.components.quagmire_replatable:Replate(dishtype, true, act.doer)
                    replater_container:GiveItem(newitem, replater_slot, replater_owner:GetPosition())
                else
                    --food plate in inventory
                    --spawn new entity so UI animates on clients
                    local slot = inventory:GetItemSlot(replatable.inst)
                    local prefab = replatable.inst.prefab
                    local perish = replatable.inst.components.perishable ~= nil and replatable.inst.components.perishable:GetPercent() or nil
                    local salted = replatable.inst:HasTag("quagmire_salted")
                    replatable.inst:Remove()
                    replater.inst:Remove()
                    local newitem = SpawnPrefab(prefab)
                    if perish ~= nil then
                        newitem.components.perishable:SetPercent(perish)
                    end
                    if salted then
                        newitem.components.quagmire_saltable:Salt(0, true)
                    end
                    newitem.components.quagmire_replatable:Replate(dishtype, true, act.doer)
                    inventory:GiveItem(newitem, slot, owner:GetPosition())
                end
            else
                --food plate on the ground
                replater.inst:Remove()
                replatable:Replate(dishtype)
            end
            return true
        end
    end
end

ACTIONS.SALT.fn = function(act)
    if act.target ~= nil and act.target.components.quagmire_saltable ~= nil then
        if act.invobject.components.stackable ~= nil then
            act.invobject.components.stackable:Get():Remove()
        else
            act.invobject:Remove()
        end

        local owner = act.target.components.inventoryitem:GetGrandOwner()
        if owner ~= nil then
            --food plate in inventory
            --spawn new entity so UI animates on clients
            local inventory = owner.components.inventory or owner.components.container
            local slot = inventory:GetItemSlot(act.target)
            local prefab = act.target.prefab
            local perish = act.target.components.perishable ~= nil and act.target.components.perishable:GetPercent() or nil
            local replated = act.target.components.quagmire_replatable ~= nil and act.target.components.quagmire_replatable.dishtype or nil
            act.target:Remove()
            local newitem = SpawnPrefab(prefab)
            if perish ~= nil then
                newitem.components.perishable:SetPercent(perish)
            end
            if replated ~= nil then
                newitem.components.quagmire_replatable:Replate(replated, true)
            end
            newitem.components.quagmire_saltable:Salt(1, true)
            inventory:GiveItem(newitem, slot, owner:GetPosition())
        else
            --food plate on the ground
            act.target.components.quagmire_saltable:Salt(1)
        end
        return true
    end
end
