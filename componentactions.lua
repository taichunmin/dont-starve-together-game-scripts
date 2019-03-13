require 'util'

local COMPONENT_ACTIONS =
{
    SCENE = --args: inst, doer, actions, right
    {
        activatable = function(inst, doer, actions)
            if inst:HasTag("inactive") then
                table.insert(actions, ACTIONS.ACTIVATE)
            end
        end,

        book = function(inst, doer, actions)
            if doer:HasTag("reader") then
                table.insert(actions, ACTIONS.READ)
            end
        end,

        burnable = function(inst, doer, actions)
            if inst:HasTag("smolder") then
                table.insert(actions, ACTIONS.SMOTHER)
            end
        end,

        bundlemaker = function(inst, doer, actions, right)
            if right then
                table.insert(actions, ACTIONS.BUNDLE)
            end
        end,

        catcher = function(inst, doer, actions)
            if inst:HasTag("cancatch") then
                table.insert(actions, ACTIONS.CATCH)
            end
        end,

        channelable = function(inst, doer, actions, right)
            if right and inst:HasTag("channelable") then
                if not inst:HasTag("channeled") then
                    table.insert(actions, ACTIONS.STARTCHANNELING)
                elseif doer:HasTag("channeling") then
                    table.insert(actions, ACTIONS.STOPCHANNELING)
                end
            end
        end,

        combat = function(inst, doer, actions, right)
            if not right and
                doer:CanDoAction(ACTIONS.ATTACK) and
                inst.replica.health ~= nil and not inst.replica.health:IsDead() and
                inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer) then
                table.insert(actions, ACTIONS.ATTACK)
            end
        end,

        constructionsite = function(inst, doer, actions)
            table.insert(actions,
                not (doer.components.playercontroller ~= nil and
                    doer.components.playercontroller.isclientcontrollerattached) and
                inst.replica.constructionsite:IsBuilder(doer) and
                ACTIONS.STOPCONSTRUCTION or
                ACTIONS.CONSTRUCT)
        end,

        container = function(inst, doer, actions, right)
            if inst:HasTag("bundle") then
                if right and inst.replica.container:IsOpenedBy(doer) then
                    table.insert(actions, doer.components.constructionbuilderuidata ~= nil and doer.components.constructionbuilderuidata:GetContainer() == inst and ACTIONS.APPLYCONSTRUCTION or ACTIONS.WRAPBUNDLE)
                end
            elseif not inst:HasTag("burnt") and
                inst.replica.container:CanBeOpened() and
                doer.replica.inventory ~= nil and
                not (doer.replica.rider ~= nil and
                    doer.replica.rider:IsRiding()) then
                table.insert(actions, ACTIONS.RUMMAGE)
            end
        end,

        crittertraits = function(inst, doer, actions, right)
            if inst.replica.follower ~= nil and inst.replica.follower:GetLeader() == doer then
                if right and
                    doer.replica.builder ~= nil and
                    doer.replica.builder:GetTechTrees().ORPHANAGE > 0 then
                    table.insert(actions, ACTIONS.ABANDON)
                else
                    --V2C: @Scott: Should this always be available???
                    table.insert(actions, ACTIONS.PET)
                end
            end
        end,

        crop = function(inst, doer, actions)
            if (inst:HasTag("readyforharvest") or inst:HasTag("withered")) and doer.replica.inventory ~= nil then
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        dryer = function(inst, doer, actions)
            if inst:HasTag("dried") and not inst:HasTag("burnt") then 
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        harvestable = function(inst, doer, actions)
            if inst:HasTag("harvestable") then
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        hauntable = function(inst, doer, actions)
            if not (inst:HasTag("haunted") or inst:HasTag("catchable")) then
                table.insert(actions, ACTIONS.HAUNT)
            end
        end,

        inspectable = function(inst, doer, actions)
            if inst ~= doer and
                (doer.CanExamine == nil or doer:CanExamine()) and
                (doer.sg == nil or (doer.sg:HasStateTag("idle") and not doer.sg:HasStateTag("moving") or doer.sg:HasStateTag("channeling"))) and
                (doer:HasTag("idle") and not doer:HasTag("moving") or doer:HasTag("channeling")) then
                --Check state graph as well in case there is movement prediction
                table.insert(actions, ACTIONS.LOOKAT)
            end
        end,

        inventoryitem = function(inst, doer, actions, right)
            if inst.replica.inventoryitem:CanBePickedUp() and
                doer.replica.inventory ~= nil and
                (doer.replica.inventory:GetNumSlots() > 0 or inst.replica.equippable ~= nil) and
                not (inst:HasTag("catchable") or inst:HasTag("fire") or inst:HasTag("smolder")) and
                (right or not inst:HasTag("heavy")) and
                not (right and inst.replica.container ~= nil and inst.replica.equippable == nil) then
                table.insert(actions, ACTIONS.PICKUP)
            end
        end,

        lock = function(inst, doer, actions)
            if inst:HasTag("unlockable") then
                table.insert(actions, ACTIONS.UNLOCK)
            end
        end,

        machine = function(inst, doer, actions, right)
            if right and not inst:HasTag("cooldown") and
                not inst:HasTag("fueldepleted") and
                not (inst.replica.equippable ~= nil and
                    not inst.replica.equippable:IsEquipped() and
                    inst.replica.inventoryitem ~= nil and
                    inst.replica.inventoryitem:IsHeld()) and
                not inst:HasTag("alwayson") and
                not inst:HasTag("emergency") then
                table.insert(actions, inst:HasTag("turnedon") and ACTIONS.TURNOFF or ACTIONS.TURNON)
            end
        end,

        mine = function(inst, doer, actions, right)
            if right and inst:HasTag("minesprung") then
                table.insert(actions, ACTIONS.RESETMINE)
            end
        end,

        occupiable = function(inst, doer, actions)
            if inst:HasTag("occupied") then
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        pinnable = function(inst, doer, actions)
            if not doer:HasTag("pinned") and inst:HasTag("pinned") and inst ~= doer then
                table.insert(actions, ACTIONS.UNPIN)
            end
        end,

        pickable = function(inst, doer, actions)
            if inst:HasTag("pickable") and not (inst:HasTag("fire") or inst:HasTag("intense")) then
                table.insert(actions, ACTIONS.PICK)
            end
        end,

        projectile = function(inst, doer, actions)
            if inst:HasTag("catchable") and doer:HasTag("cancatch") then
                table.insert(actions, ACTIONS.CATCH)
            end
        end,

        repairable = function(inst, doer, actions, right)
            if right and
                inst:HasTag("repairable_sculpture") and
                doer.replica.inventory ~= nil and
                doer.replica.inventory:IsHeavyLifting() and
                not (doer.replica.rider ~= nil and
                    doer.replica.rider:IsRiding()) then
                local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                if item ~= nil and item:HasTag("work_sculpture") then
                    table.insert(actions, ACTIONS.REPAIR)
                end
            end
        end,

        revivablecorpse = function(inst, doer, actions, right)
            if inst.components.revivablecorpse:CanBeRevivedBy(doer) then
                table.insert(actions, ACTIONS.REVIVE_CORPSE)
            end
        end,

        rideable = function(inst, doer, actions, right)
            if right and inst:HasTag("rideable") then
                local rider = doer.replica.rider
                if rider ~= nil and not rider:IsRiding() then
                    table.insert(actions, ACTIONS.MOUNT)
                end
            end
        end,

        rider = function(inst, doer, actions)
            if inst == doer and inst.replica.rider:IsRiding() then
                table.insert(actions, ACTIONS.DISMOUNT)
            end
        end,

        shelf = function(inst, doer, actions)
            if inst:HasTag("takeshelfitem") then
                table.insert(actions, ACTIONS.TAKEITEM)
            end
        end,

        --[[
        shop = function()
            table.insert(actions, ACTIONS.OPEN_SHOP)
        end,
        --]]


        sleepingbag = function(inst, doer, actions)
            if doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper") then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end,

        stewer = function(inst, doer, actions, right)
            if not inst:HasTag("burnt") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                if inst:HasTag("donecooking") then
                    table.insert(actions, ACTIONS.HARVEST)
                elseif right and
                    (inst:HasTag("readytocook")
                    or (inst.replica.container ~= nil and
                        inst.replica.container:IsFull() and
                        inst.replica.container:IsOpenedBy(doer))) then
                    table.insert(actions, ACTIONS.COOK)
                end
            end
        end,

		madsciencelab = function(inst, doer, actions, right)
            if right and
                (inst:HasTag("readytocook")
                or (inst.replica.container ~= nil and
                    inst.replica.container:IsFull() and
                    inst.replica.container:IsOpenedBy(doer))) then
                table.insert(actions, ACTIONS.COOK)
            end
        end,

        talkable = function(inst, doer, actions)
            if inst:HasTag("maxwellnottalking") then
                table.insert(actions, ACTIONS.TALKTO)
            end
        end,

        teleporter = function(inst, doer, actions, right)
            if inst:HasTag("teleporter") then
                if not inst:HasTag("townportal") then
                    table.insert(actions, ACTIONS.JUMPIN)
                elseif right and not doer:HasTag("channeling") then
                    table.insert(actions, ACTIONS.TELEPORT)
                end
            end
        end,

        trap = function(inst, doer, actions)
            if inst:HasTag("trapsprung") then
                table.insert(actions, ACTIONS.CHECKTRAP)
            end 
        end,

        unwrappable = function(inst, doer, actions, right)
            if right and inst:HasTag("unwrappable") then
                table.insert(actions, ACTIONS.UNWRAP)
            end
        end,

        worldmigrator = function(inst, doer, actions)
            if inst:HasTag("migrator") then
                table.insert(actions, ACTIONS.MIGRATE)
            end
        end,

        wardrobe = function(inst, doer, actions, right)
            if inst:HasTag("wardrobe") and not inst:HasTag("fire") and (right or not inst:HasTag("dressable")) then
                table.insert(actions, ACTIONS.CHANGEIN)
            end
        end,

        writeable = function(inst, doer, actions)
            if inst:HasTag("writeable") then
                table.insert(actions, ACTIONS.WRITE)
            end
        end,

        attunable = function(inst, doer, actions)
            if doer.components.attuner ~= nil and --V2C: this is on clients too
                not doer.components.attuner:IsAttunedTo(inst) then
                table.insert(actions, ACTIONS.ATTUNE)
            end
        end,

        quagmire_tappable = function(inst, doer, actions, right)
            if not inst:HasTag("tappable") and not inst:HasTag("fire") then
                if right then
                    --TAPTREE action also untaps the tree
                    table.insert(actions, inst:HasTag("tapped_harvestable") and doer.replica.inventory:EquipHasTag("CHOP_tool") and ACTIONS.HARVEST or ACTIONS.TAPTREE)
                elseif inst:HasTag("tapped_harvestable") then
                    table.insert(actions, ACTIONS.HARVEST)
                end
            end
        end,
    },

    USEITEM = --args: inst, doer, target, actions, right
    {
        bait = function(inst, doer, target, actions)
            if target:HasTag("canbait") then
                table.insert(actions, ACTIONS.BAIT)
            end
        end,

        brush = function(inst, doer, target, actions, right)
            if not right and target:HasTag("brushable") then
                table.insert(actions, ACTIONS.BRUSH)
            end
        end,

        cookable = function(inst, doer, target, actions)
            if target:HasTag("cooker") and
                not target:HasTag("fueldepleted") and
                (not target:HasTag("dangerouscooker") or doer:HasTag("expertchef")) and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer)))
                then
                table.insert(actions, ACTIONS.COOK)
            end
        end,

        constructionplans = function(inst, doer, target, actions)
            if inst:HasTag(target.prefab.."_plans") then
                table.insert(actions, ACTIONS.CONSTRUCT)
            end
        end,

        cooker = function(inst, doer, target, actions)
            if (not inst:HasTag("dangerouscooker") or doer:HasTag("expertchef")) and
                target:HasTag("cookable") and
                not (inst:HasTag("fueldepleted") or
                    target:HasTag("fire") or
                    target:HasTag("catchable")) then
                local inventoryitem = target.replica.inventoryitem
                if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                        not (inventoryitem ~= nil and inventoryitem:IsGrandOwner(doer))) and
                    (inventoryitem == nil or inventoryitem:IsHeld() or inventoryitem:CanBePickedUp()) then
                    table.insert(actions, ACTIONS.COOK)
                end
            end
        end,

        drawingtool = function(inst, doer, target, actions)
            if target:HasTag("drawable") then
                table.insert(actions, ACTIONS.DRAW)
            end
        end,

        dryable = function(inst, doer, target, actions)
            if target:HasTag("candry") and inst:HasTag("dryable") and not target:HasTag("burnt") then
                table.insert(actions, ACTIONS.DRY)
            end
        end,

        edible = function(inst, doer, target, actions, right)
            local iscritter = target:HasTag("critter")
            if right or iscritter and
                not (target.replica.rider ~= nil and target.replica.rider:IsRiding()) and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) then
                for k, v in pairs(FOODGROUP) do
                    if target:HasTag(v.name.."_eater") then
                        for i, v2 in ipairs(v.types) do
                            if inst:HasTag("edible_"..v2) then
                                if iscritter then
                                    if target.replica.follower ~= nil and target.replica.follower:GetLeader() == doer then
                                        table.insert(actions, ACTIONS.FEED)
                                    end
                                elseif target:HasTag("player") then
                                    if TheNet:GetPVPEnabled() or not (inst:HasTag("badfood") or inst:HasTag("spoiled")) then
                                    table.insert(actions, ACTIONS.FEEDPLAYER)
                                    end
                                elseif target:HasTag("small_livestock")
                                    and target.replica.inventoryitem ~= nil
                                    and target.replica.inventoryitem:IsHeld() then
                                    table.insert(actions, ACTIONS.FEED)
                                end
                                return
                            end
                        end
                    end
                end
                for k, v in pairs(FOODTYPE) do
                    if inst:HasTag("edible_"..v) and target:HasTag(v.."_eater") then
                        if iscritter then
                            if target.replica.follower ~= nil and target.replica.follower:GetLeader() == doer then
                                table.insert(actions, ACTIONS.FEED)
                            end
                        elseif target:HasTag("player") then
                            if TheNet:GetPVPEnabled() or not (inst:HasTag("badfood") or inst:HasTag("spoiled")) then
                            table.insert(actions, ACTIONS.FEEDPLAYER)
                            end
                        elseif target:HasTag("small_livestock")
                            and target.replica.inventoryitem ~= nil
                            and target.replica.inventoryitem:IsHeld() then
                            table.insert(actions, ACTIONS.FEED)
                        end
                        return
                    end
                end
            end
        end,

        fan = function(inst, doer, target, actions)
            table.insert(actions, ACTIONS.FAN)
        end,

        fertilizer = function(inst, doer, target, actions)
            if --[[crop]] (target:HasTag("notreadyforharvest") and not target:HasTag("withered")) or
                --[[grower]] target:HasTag("fertile") or target:HasTag("infertile") or
                --[[pickable]] target:HasTag("barren") or
                --[[quagmire_fertilizable]] target:HasTag("fertilizable") then
                table.insert(actions, ACTIONS.FERTILIZE)
            end
        end,

        fillable = function(inst, doer, target, actions)
            if target:HasTag("watersource") then
                table.insert(actions, ACTIONS.FILL)
            end
        end,

        fishingrod = function(inst, doer, target, actions)
            if target:HasTag("fishable") and not inst.replica.fishingrod:HasCaughtFish() then
                if target ~= inst.replica.fishingrod:GetTarget() then
                    table.insert(actions, ACTIONS.FISH)
                elseif doer.sg == nil or doer.sg:HasStateTag("fishing") then
                    table.insert(actions, ACTIONS.REEL)
                end
            end
        end,

        fuel = function(inst, doer, target, actions)
            if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
                or (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer)) then
                if inst.prefab ~= "spoiled_food" and
                    inst:HasTag("quagmire_stewable") and
                    target:HasTag("quagmire_stewer") and
                    target.replica.container ~= nil and
                    target.replica.container:IsOpenedBy(doer) then
                    return
                end
                for k, v in pairs(FUELTYPE) do
                    if inst:HasTag(v.."_fuel") then
                        if target:HasTag(v.."_fueled") then
                            table.insert(actions, inst:GetIsWet() and ACTIONS.ADDWETFUEL or ACTIONS.ADDFUEL)
                        end
                        return
                    end
                end
            end
        end,

        healer = function(inst, doer, target, actions)
            if target.replica.health ~= nil and target.replica.health:CanHeal() then
                table.insert(actions, ACTIONS.HEAL)
            end
        end,

        maxhealer = function(inst, doer, target, actions)
            if target.replica.health ~= nil and target.replica.health:CanHeal() then
                table.insert(actions, ACTIONS.HEAL)
            end
        end,

        inventoryitem = function(inst, doer, target, actions, right)
            if target.replica.container ~= nil and
                target.replica.container:CanBeOpened() and
                inst.replica.inventoryitem ~= nil and
                inst.replica.inventoryitem:IsGrandOwner(doer) then
                if not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    (   (inst.prefab ~= "spoiled_food" and inst:HasTag("quagmire_stewable") and target:HasTag("quagmire_stewer") and target.replica.container:IsOpenedBy(doer)) or
                        not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel"))
                    ) then
                    table.insert(actions, target:HasTag("bundle") and ACTIONS.BUNDLESTORE or ACTIONS.STORE)
                end
            elseif target.replica.constructionsite ~= nil then
                if not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel")) then
                    table.insert(actions, target.replica.constructionsite:IsBuilder(doer) and ACTIONS.BUNDLESTORE or ACTIONS.CONSTRUCT)
                end
            elseif target:HasTag("playerghost") then
                if inst.prefab == "reviver" then
                    table.insert(actions, ACTIONS.GIVETOPLAYER)
                end
            elseif target:HasTag("player") then
                if not (target.replica.rider ~= nil and target.replica.rider:IsRiding()) and
                    not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) then
                    table.insert(actions,
                        not (doer.components.playercontroller ~= nil and
                            doer.components.playercontroller:IsControlPressed(CONTROL_FORCE_STACK)) and
                        inst.replica.stackable ~= nil and
                        inst.replica.stackable:IsStack() and
                        ACTIONS.GIVEALLTOPLAYER or
                        ACTIONS.GIVETOPLAYER)
                end
            elseif not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                if target:HasTag("alltrader") then
                    table.insert(actions, ACTIONS.GIVE)
                elseif inst.prefab == "reviver" and target:HasTag("ghost") then
                    table.insert(actions, ACTIONS.GIVE)
                end
            end
        end,

        key = function(inst, doer, target, actions)
            for k, v in pairs(LOCKTYPE) do
                if target:HasTag(v.."_lock") then
                    if inst:HasTag(v.."_key") then
                        table.insert(actions, ACTIONS.UNLOCK)
                    end
                    return
                end
            end
        end,

		klaussackkey = function(inst, doer, target, actions)
            if target:HasTag("klaussacklock") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) and
                inst:HasTag("klaussackkey") then

                table.insert(actions, ACTIONS.USEKLAUSSACKKEY)
            end
        end,

        lighter = function(inst, doer, target, actions)
            if target:HasTag("canlight") and not (target:HasTag("fueldepleted") or target:HasTag("INLIMBO")) then
                table.insert(actions, ACTIONS.LIGHT)
            end
        end,

        maprecorder = function(inst, doer, target, actions)
            if doer == target and target:HasTag("player") then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        moonrelic = function(inst, doer, target, actions)
            if target:HasTag("moontrader") then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

        occupier = function(inst, doer, target, actions)
            for k, v in pairs(OCCUPANTTYPE) do
                if target:HasTag(v.."_occupiable") then
                    if inst:HasTag(v) then
                        table.insert(actions, ACTIONS.STORE)
                    end
                    return
                end
            end
        end,

        plantable = function(inst, doer, target, actions)
            if target:HasTag("fertile") or target:HasTag("fullfertile") then
                table.insert(actions, ACTIONS.PLANT)
            end
        end,

        repairer = function(inst, doer, target, actions, right)
            if right then
                if doer.replica.rider ~= nil and doer.replica.rider:IsRiding() then
                    if not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer)) then
                        return
                    end
                elseif doer.replica.inventory ~= nil and doer.replica.inventory:IsHeavyLifting() then
                    return
                end
                for k, v in pairs(MATERIALS) do
                    if target:HasTag("repairable_"..v) then
                        if (inst:HasTag("work_"..v) and target:HasTag("workrepairable"))
                            or (inst:HasTag("health_"..v) and target.replica.health ~= nil and not target.replica.health:IsFull())
                            or (inst:HasTag("freshen_"..v) and (target:HasTag("fresh") or target:HasTag("stale") or target:HasTag("spoiled"))) then
                            table.insert(actions, ACTIONS.REPAIR)
                        end
                        return
                    end
                end
            end
        end,

        saddler = function(inst, doer, target, actions)
            if target:HasTag("saddleable") then
                table.insert(actions, ACTIONS.SADDLE)
            end
        end,

        sewing = function(inst, doer, target, actions)
            if target:HasTag("needssewing") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) then
                table.insert(actions, ACTIONS.SEW)
            end
        end,

        shaver = function(inst, doer, target, actions)
            if target:HasTag("bearded") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                table.insert(actions, ACTIONS.SHAVE)
            end
        end,

        sleepingbag = function(inst, doer, target, actions)
           if doer == target and doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper") then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end,

        smotherer = function(inst, doer, target, actions)
            if target:HasTag("smolder") then
                table.insert(actions, ACTIONS.SMOTHER)
            elseif inst:HasTag("frozen") and target:HasTag("fire") and
                not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsHeld()) then
                table.insert(actions, ACTIONS.MANUALEXTINGUISH)
            end
        end,

        stackable = function(inst, doer, target, actions)
            if inst.prefab == target.prefab and inst.skinname == target.skinname and
                target.replica.stackable ~= nil and
                not target.replica.stackable:IsFull() and
                target.replica.inventoryitem ~= nil and
                not target.replica.inventoryitem:IsHeld() then
                table.insert(actions, ACTIONS.COMBINESTACK)
            end
        end,

        teacher = function(inst, doer, target, actions)
            if doer == target and target.replica.builder ~= nil then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        tool = function(inst, doer, target, actions, right)
            if not target:HasTag("INLIMBO") then
                for k, v in pairs(TOOLACTIONS) do
                    if inst:HasTag(k.."_tool") then
                        if target:IsActionValid(ACTIONS[k], right) then
                            table.insert(actions, ACTIONS[k])
                            return
                        end
                    end
                end
            end
        end,

        tradable = function(inst, doer, target, actions)
            if target:HasTag("trader") and
                not (target:HasTag("player") or target:HasTag("ghost")) and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

        unsaddler = function(inst, doer, target, actions, right)
            if not right and target:HasTag("saddled") then
                table.insert(actions, ACTIONS.UNSADDLE)
            end
        end,

        upgrader = function(inst, doer, target, actions)
            for k,v in pairs(UPGRADETYPES) do
                if inst:HasTag(v.."_upgrader") 
                    and doer:HasTag(v.."_upgradeuser")
                    and target:HasTag(v.."_upgradeable") then
                    table.insert(actions, ACTIONS.UPGRADE)
                end
            end
        end,

        vasedecoration = function(inst, doer, target, actions)
            if target:HasTag("vase") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) and
                inst:HasTag("vasedecoration") then
                
                table.insert(actions, ACTIONS.DECORATEVASE)
            end
        end,

        weapon = function(inst, doer, target, actions, right)
            if inst.replica.inventoryitem ~= nil and
                target.replica.container ~= nil and
                target.replica.container:CanBeOpened() then
                -- put weapons into chester, don't attack him unless forcing attack with key press
                if not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    (   (inst.prefab ~= "spoiled_food" and inst:HasTag("quagmire_stewable") and target:HasTag("quagmire_stewer") and target.replica.container:IsOpenedBy(doer)) or
                        not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel"))
                    ) then
                    table.insert(actions, target:HasTag("bundle") and ACTIONS.BUNDLESTORE or ACTIONS.STORE)
                end
            elseif target.replica.constructionsite ~= nil then
                if not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel")) then
                    table.insert(actions, target.replica.constructionsite:IsBuilder(doer) and ACTIONS.BUNDLESTORE or ACTIONS.CONSTRUCT)
                end
            elseif not right and
                doer.replica.combat ~= nil and
                doer.replica.combat:CanTarget(target) and
                (inst:HasTag("projectile") or inst:HasTag("rangedweapon") or not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())) then
                if target.replica.combat == nil then
                    -- lighting or extinguishing fires
                    table.insert(actions, ACTIONS.ATTACK)
                elseif target.replica.combat:CanBeAttacked(doer) and
                    not doer.replica.combat:IsAlly(target) and
                    not (doer:HasTag("player") and target:HasTag("player")) and
                    not (inst:HasTag("tranquilizer") and not target:HasTag("sleeper")) and
                    not (inst:HasTag("lighter") and (target:HasTag("canlight") or target:HasTag("nolight"))) then
                    table.insert(actions, ACTIONS.ATTACK)
                end
            end
        end,

        winter_treeseed = function(inst, doer, target, actions)
            if target:HasTag("winter_treestand") and not (target:HasTag("fire") or target:HasTag("smolder") or target:HasTag("burnt")) then
                table.insert(actions, ACTIONS.PLANT)
            end
        end,

        quagmire_plantable = function(inst, doer, target, actions)
            if target:HasTag("soil") then
                table.insert(actions, ACTIONS.PLANTSOIL)
            end
        end,

        quagmire_installable = function(inst, doer, target, actions)
            if target:HasTag("installations") then
                table.insert(actions, ACTIONS.INSTALL)
            end
        end,

        quagmire_stewer = function(inst, doer, target, actions)
            if target:HasTag("quagmire_cookwaretrader") then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

        quagmire_stewable = function(inst, doer, target, actions)
            if target:HasTag("quagmire_altar") then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

        quagmire_saltextractor = function(inst, doer, target, actions)
            if target:HasTag("saltpond") then
                table.insert(actions, ACTIONS.INSTALL)
            end
        end,

        quagmire_portalkey = function(inst, doer, target, actions)
            if target:HasTag("quagmire_altar") then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

        quagmire_tapper = function(inst, doer, target, actions)
            if target:HasTag("tappable") and not inst:HasTag("fire") and not inst:HasTag("burnt") then
                table.insert(actions, ACTIONS.TAPTREE)
            end
        end,

        quagmire_replater = function(inst, doer, target, actions)
            if target:HasTag("quagmire_replatable") then
                table.insert(actions, ACTIONS.REPLATE)
            end
        end,

        quagmire_replatable = function(inst, doer, target, actions)
            if target:HasTag("quagmire_replater") then
                table.insert(actions, ACTIONS.REPLATE)
            end
        end,

        quagmire_salter = function(inst, doer, target, actions)
            if target:HasTag("quagmire_saltable") then
                table.insert(actions, ACTIONS.SALT)
            end
        end,

        quagmire_slaughtertool = function(inst, doer, target, actions)
            if target:HasTag("canbeslaughtered") and target.replica.health ~= nil and not target.replica.health:IsDead() then
                table.insert(actions, ACTIONS.SLAUGHTER)
            end
        end,
    },

    POINT = --args: inst, doer, pos, actions, right
    {
        blinkstaff = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:IsAboveGroundAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos) then
                table.insert(actions, ACTIONS.BLINK)
            end
        end,

        complexprojectile = function(inst, doer, pos, actions, right)
            if right and not TheWorld.Map:IsGroundTargetBlocked(pos) then
                table.insert(actions, ACTIONS.TOSS)
            end
        end,

        deployable = function(inst, doer, pos, actions, right)
            if right and inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:CanDeploy(pos) then
                table.insert(actions, ACTIONS.DEPLOY)
            end
        end,

        inventoryitem = function(inst, doer, pos, actions, right)
            if not right and inst.replica.inventoryitem:IsHeldBy(doer) then
                table.insert(actions, ACTIONS.DROP)
            end
        end,

        spellcaster = function(inst, doer, pos, actions, right)
            if right and inst:HasTag("castonpoint") and
                TheWorld.Map:IsAboveGroundAtPoint(pos:Get()) and
                not TheWorld.Map:IsGroundTargetBlocked(pos) then
                table.insert(actions, ACTIONS.CASTSPELL)
            end
        end,

        terraformer = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:CanTerraformAtPoint(pos:Get()) then
                table.insert(actions, ACTIONS.TERRAFORM)
            end
        end,

        aoespell = function(inst, doer, pos, actions, right)
            if right and
                (   inst.components.aoetargeting == nil or inst.components.aoetargeting:IsEnabled()
                ) and
                (   inst.components.aoetargeting ~= nil and inst.components.aoetargeting.alwaysvalid or
                    (TheWorld.Map:IsAboveGroundAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos))
                ) then
                table.insert(actions, ACTIONS.CASTAOE)
            end
        end,

        quagmire_tiller = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:CanTillSoilAtPoint(pos) then
                table.insert(actions, ACTIONS.TILL)
            end
        end,
    },

    EQUIPPED = --args: inst, doer, target, actions, right
    {
        brush = function(inst, doer, target, actions, right)
            if not right and target:HasTag("brushable") then
                table.insert(actions, ACTIONS.BRUSH)
            end
        end,

        complexprojectile = function(inst, doer, target, actions, right)
            if right and
                not (doer.components.playercontroller ~= nil and
                    doer.components.playercontroller.isclientcontrollerattached) and
                not TheWorld.Map:IsGroundTargetBlocked(target:GetPosition()) then
                table.insert(actions, ACTIONS.TOSS)
            end
        end,

        fishingrod = function(inst, doer, target, actions)
            if target:HasTag("fishable") and not inst.replica.fishingrod:HasCaughtFish() then
                if target ~= inst.replica.fishingrod:GetTarget() then
                    table.insert(actions, ACTIONS.FISH)
                elseif doer.sg == nil or doer.sg:HasStateTag("fishing") then
                    table.insert(actions, ACTIONS.REEL)
                end
            end
        end,

        key = function(inst, doer, target, actions)
            for k, v in pairs(LOCKTYPE) do
                if target:HasTag(v.."_lock") then
                    if inst:HasTag(v.."_key") then
                        table.insert(actions, ACTIONS.UNLOCK)
                    end
                    return
                end
            end
        end,

        cooker = function(inst, doer, target, actions, right)
            if right and
                (not inst:HasTag("dangerouscooker") or doer:HasTag("expertchef")) and
                target:HasTag("cookable") and
                not (inst:HasTag("fueldepleted") or
                    target:HasTag("fire") or
                    target:HasTag("catchable")) then
                local inventoryitem = target.replica.inventoryitem
                if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                        not (inventoryitem ~= nil and inventoryitem:IsGrandOwner(doer))) and
                    (inventoryitem == nil or inventoryitem:IsHeld() or inventoryitem:CanBePickedUp()) then
                    table.insert(actions, ACTIONS.COOK)
                end
            end
        end,

        lighter = function(inst, doer, target, actions, right)
            if right and target:HasTag("canlight") and not (target:HasTag("fueldepleted") or target:HasTag("INLIMBO")) then
                table.insert(actions, ACTIONS.LIGHT)
            end
        end,

        spellcaster = function(inst, doer, target, actions, right)
            if right and (
                    inst:HasTag("castontargets") or
                    (inst:HasTag("castonrecipes") and AllRecipes[target.prefab] ~= nil) or
                    (target:HasTag("locomotor") and (
                        inst:HasTag("castonlocomotors") or
                        (inst:HasTag("castonlocomotorspvp") and (target == doer or TheNet:GetPVPEnabled() or not (target:HasTag("player") and doer:HasTag("player"))))
                    )) or
                    (inst:HasTag("castonworkable") and (target:HasTag("CHOP_workable") or target:HasTag("DIG_workable") or target:HasTag("HAMMER_workable") or target:HasTag("MINE_workable"))) or
                    (inst:HasTag("castoncombat") and doer.replica.combat ~= nil and doer.replica.combat:CanTarget(target))
                ) then
                table.insert(actions, ACTIONS.CASTSPELL)
            end
        end,

        tool = function(inst, doer, target, actions, right)
            if not target:HasTag("INLIMBO") then
                for k, v in pairs(TOOLACTIONS) do
                    if inst:HasTag(k.."_tool") then
                        if target:IsActionValid(ACTIONS[k], right) then
                            if not right or ACTIONS[k].rmb or not target:HasTag("smolder") then
                                table.insert(actions, ACTIONS[k])
                                return
                            end
                        end
                    end
                end
            end
        end,

        unsaddler = function(inst, doer, target, actions, right)
            if target:HasTag("saddled") and not right then
                table.insert(actions, ACTIONS.UNSADDLE)
            end
        end,

        weapon = function(inst, doer, target, actions, right)
            if not right
                and doer.replica.combat ~= nil
                and (inst:HasTag("projectile") or inst:HasTag("rangedweapon") or not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())) then
                if doer.replica.combat:CanExtinguishTarget(target, inst) or
                    doer.replica.combat:CanLightTarget(target, inst) then
                    table.insert(actions, ACTIONS.ATTACK)
                elseif not target:HasTag("wall")
                    and target.replica.combat ~= nil
                    and doer.replica.combat:CanTarget(target)
                    and target.replica.combat:CanBeAttacked(doer)
                    and not doer.replica.combat:IsAlly(target) then
                    if target:HasTag("mole") and inst:HasTag("hammer") then
                        table.insert(actions, ACTIONS.ATTACK)
                    elseif not (doer:HasTag("player") and target:HasTag("player"))
                        and not (inst:HasTag("tranquilizer") and not target:HasTag("sleeper")) then
                        table.insert(actions, ACTIONS.ATTACK)
                    end
                end
            end
        end,
    },

    INVENTORY = --args: inst, doer, actions, right
    {
        balloonmaker = function(inst, doer, actions)
            if doer:HasTag("balloonomancer") then
                table.insert(actions, ACTIONS.MAKEBALLOON)
            end
        end,

        book = function(inst, doer, actions)
            if doer:HasTag("reader") then
                table.insert(actions, ACTIONS.READ)
            end
        end,

        bundlemaker = function(inst, doer, actions)
            if doer.replica.inventory:GetActiveItem() ~= inst then
                table.insert(actions, ACTIONS.BUNDLE)
            end
        end,

        container = function(inst, doer, actions)
            if not inst:HasTag("burnt") then
                local container = inst.replica.container
                if container:CanBeOpened() and
                    doer.replica.inventory ~= nil and
                    not (container:IsSideWidget() and
                        doer.components.playercontroller ~= nil and
                        doer.components.playercontroller.isclientcontrollerattached) then
                    table.insert(actions, ACTIONS.RUMMAGE)
                end
            end
        end,

        deployable = function(inst, doer, actions)
            if doer.components.playercontroller ~= nil and
                not doer.components.playercontroller.deploy_mode and
                inst.replica.inventoryitem ~= nil and
                inst.replica.inventoryitem:IsGrandOwner(doer) then
                table.insert(actions, ACTIONS.TOGGLE_DEPLOY_MODE)
            end
        end,

        edible = function(inst, doer, actions, right)
            if (right or inst.replica.equippable == nil) and
                not (doer.replica.inventory:GetActiveItem() == inst and
                    doer.replica.rider ~= nil and
                    doer.replica.rider:IsRiding()) then
                for k, v in pairs(FOODGROUP) do
                    if doer:HasTag(v.name.."_eater") then
                        for i, v2 in ipairs(v.types) do
                            if inst:HasTag("edible_"..v2) then
                                table.insert(actions, ACTIONS.EAT)
                                return
                            end
                        end
                    end
                end
                for k, v in pairs(FOODTYPE) do
                    if inst:HasTag("edible_"..v) and doer:HasTag(v.."_eater") then
                        table.insert(actions, ACTIONS.EAT)
                        return
                    end
                end
            end
        end,

        equippable = function(inst, doer, actions)
            table.insert(actions, inst.replica.equippable:IsEquipped() and ACTIONS.UNEQUIP or ACTIONS.EQUIP)
        end,

        fan = function(inst, doer, actions)
            table.insert(actions, ACTIONS.FAN)
        end,

        --[[
        fuel = function(inst, doer, target, actions)
            for k, v in pairs(FUELTYPE) do
                if inst:HasTag(v.."_fuel") then
                    if target:HasTag(v.."_fueled") then
                        table.insert(actions, ACTIONS.ADDFUEL)
                    end
                    return
                end
            end
        end,
        --]]

        healer = function(inst, doer, actions)
            if doer.replica.health ~= nil and doer.replica.health:CanHeal() then
                table.insert(actions, ACTIONS.HEAL)
            end
        end,

        maxhealer = function(inst, doer, actions)
            if doer.replica.health ~= nil and doer.replica.health:CanHeal() then
                table.insert(actions, ACTIONS.HEAL)
            end
        end,

        health = function(inst, doer, actions)
            if inst.replica.health:CanMurder() then
                table.insert(actions, ACTIONS.MURDER)
            end
        end,

        inspectable = function(inst, doer, actions)
            if inst ~= doer and (doer.CanExamine == nil or doer:CanExamine()) then
                table.insert(actions, ACTIONS.LOOKAT)
            end
        end,

        instrument = function(inst, doer, actions)
            table.insert(actions, ACTIONS.PLAY)
        end,

        --[[
        inventoryitem = function(inst, doer, actions)
            table.insert(actions, ACTIONS.DROP)
        end,
        --]]

        maprecorder = function(inst, doer, actions)
            if doer:HasTag("player") then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        machine = function(inst, doer, actions, right)
            if right and not inst:HasTag("cooldown") and
                not inst:HasTag("fueldepleted") and
                not (inst.replica.equippable ~= nil and
                    not inst.replica.equippable:IsEquipped() and
                    inst.replica.inventoryitem ~= nil and
                    inst.replica.inventoryitem:IsHeld()) then
                if inst:HasTag("turnedon") then
                    table.insert(actions, ACTIONS.TURNOFF)
                else
                    table.insert(actions, ACTIONS.TURNON)
                end
            end
        end,

        shaver = function(inst, doer, actions)
            if doer:HasTag("bearded") and
                not (doer.replica.inventory:GetActiveItem() == inst and
                    doer.replica.rider ~= nil and
                    doer.replica.rider:IsRiding()) then
                --Don't show mouse active item Shave action when mounted
                --because it's confusing and looks like you're trying to
                --shave your beefalo mount.
                table.insert(actions, ACTIONS.SHAVE)
            end
        end,
		
        sleepingbag = function(inst, doer, actions)
            if doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper") then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end,

        spellcaster = function(inst, doer, actions)
            if inst:HasTag("castfrominventory") then
                table.insert(actions, ACTIONS.CASTSPELL)
            end
        end,

        talkable = function(inst, doer, actions)
            if inst:HasTag("maxwellnottalking") then
                table.insert(actions, ACTIONS.TALKTO)
            end
        end,

        teacher = function(inst, doer, actions)
            if doer.replica.builder ~= nil then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        teleporter = function(inst, doer, actions)
            if inst:HasTag("teleporter") and not doer:HasTag("channeling") then
                table.insert(actions, ACTIONS.TELEPORT)
            end
        end,

        unwrappable = function(inst, doer, actions, right)
            if doer.replica.inventory:GetActiveItem() ~= inst and inst:HasTag("unwrappable") then
                table.insert(actions, ACTIONS.UNWRAP)
            end
        end,

        useableitem = function(inst, doer, actions)
            if not inst:HasTag("inuse") and
                inst.replica.equippable ~= nil and
                inst.replica.equippable:IsEquipped() and
                doer.replica.inventory ~= nil and
                doer.replica.inventory:IsOpenedBy(doer) then
                table.insert(actions, ACTIONS.USEITEM)
            end
        end,
    },

    ISVALID = --args: inst, action, right
    {
        workable = function(inst, action, right)
            return (right or action ~= ACTIONS.HAMMER) and
                inst:HasTag(action.id.."_workable")
        end,
    },
}

local ACTION_COMPONENT_NAMES = {}
local ACTION_COMPONENT_IDS = {}

local function RemapComponentActions()
    for k, v in orderedPairs(COMPONENT_ACTIONS) do
        for cmp, fn in orderedPairs(v) do
            if ACTION_COMPONENT_IDS[cmp] == nil then
                table.insert(ACTION_COMPONENT_NAMES, cmp)
                ACTION_COMPONENT_IDS[cmp] = #ACTION_COMPONENT_NAMES
            end
        end
    end
end
RemapComponentActions()
assert(#ACTION_COMPONENT_NAMES <= 255, "Increase actioncomponents network data size.")

local MOD_COMPONENT_ACTIONS = {}
local MOD_ACTION_COMPONENT_NAMES = {}
local MOD_ACTION_COMPONENT_IDS = {}

local function ModComponentWarning(self, modname)
    print("ERROR: Mod component actions are out of sync for mod "..(modname or "unknown")..". This is likely a result of your mod's calls to AddComponentAction not happening on both the server and the client.")
    print("self.modactioncomponents is\n"..(dumptable(self.modactioncomponents) or ""))
    print("MOD_COMPONENT_ACTIONS is\n"..(dumptable(MOD_COMPONENT_ACTIONS) or ""))
end

local function CheckModComponentActions(self, modname)
    return MOD_COMPONENT_ACTIONS[modname] or ModComponentWarning(self, modname)
end

local function CheckModComponentNames(self, modname)
    return MOD_ACTION_COMPONENT_NAMES[modname] or ModComponentWarning(self, modname)
end

local function CheckModComponentIds(self, modname)
    return MOD_ACTION_COMPONENT_IDS[modname] or ModComponentWarning(self, modname)
end

function AddComponentAction(actiontype, component, fn, modname)
    if MOD_COMPONENT_ACTIONS[modname] == nil then
        MOD_COMPONENT_ACTIONS[modname] = { [actiontype] = {} }
        MOD_ACTION_COMPONENT_NAMES[modname] = {}
        MOD_ACTION_COMPONENT_IDS[modname] = {}
    elseif MOD_COMPONENT_ACTIONS[modname][actiontype] == nil then
        MOD_COMPONENT_ACTIONS[modname][actiontype] = {}
    end
    MOD_COMPONENT_ACTIONS[modname][actiontype][component] = fn
    table.insert(MOD_ACTION_COMPONENT_NAMES[modname], component)
    MOD_ACTION_COMPONENT_IDS[modname][component] = #MOD_ACTION_COMPONENT_NAMES[modname]
end

function EntityScript:RegisterComponentActions(name)
    local id = ACTION_COMPONENT_IDS[name]
    if id ~= nil then
        table.insert(self.actioncomponents, id)
        if self.actionreplica ~= nil then
            self.actionreplica.actioncomponents:set(self.actioncomponents)
        end
    end
    for modname, idmap in pairs(MOD_ACTION_COMPONENT_IDS) do
        id = idmap[name]
        if id ~= nil then
            if self.modactioncomponents == nil then
                self.modactioncomponents = { [modname] = {} }
            elseif self.modactioncomponents[modname] == nil then
                self.modactioncomponents[modname] = {}
            end
            table.insert(self.modactioncomponents[modname], id)
            if self.actionreplica ~= nil then
                self.actionreplica.modactioncomponents[modname]:set(self.modactioncomponents[modname])
            end
        end
    end
end

function EntityScript:UnregisterComponentActions(name)
    local id = ACTION_COMPONENT_IDS[name]
    if id ~= nil then
        for i, v in ipairs(self.actioncomponents) do
            if v == id then
                table.remove(self.actioncomponents, i)
                if self.actionreplica ~= nil then
                    self.actionreplica.actioncomponents:set(self.actioncomponents)
                end
                break
            end
        end
    end
    if self.modactioncomponents ~= nil then
        for modname, cmplist in pairs(self.modactioncomponents) do
            id = CheckModComponentIds(self, modname)[name]
            for i, v in ipairs(cmplist) do
                if v == id then
                    table.remove(cmplist, i)
                    if self.actionreplica ~= nil then
                        self.actionreplica.modactioncomponents[modname]:set(cmplist)
                    end
                    break
                end
            end
        end
    end
end

function EntityScript:CollectActions(actiontype, ...)
    local t = COMPONENT_ACTIONS[actiontype]
    if t == nil then
        print("Action type", actiontype, "doesn't exist in the table of component actions. Is your component name correct in AddComponentAction?")
        return
    end
    for i, v in ipairs(self.actioncomponents) do
        local collector = t[ACTION_COMPONENT_NAMES[v]]
        if collector ~= nil then
            collector(self, ...)
        end
    end
    if self.modactioncomponents ~= nil then
        for modname, cmplist in pairs(self.modactioncomponents) do
            t = CheckModComponentActions(self, modname)[actiontype]
            if t ~= nil then
                local namemap = CheckModComponentNames(self, modname)
                for i, v in ipairs(cmplist) do
                    local collector = t[namemap[v]]
                    if collector ~= nil then
                        collector(self, ...)
                    end
                end
            end
        end
    end
end

function EntityScript:IsActionValid(action, right)
    if action.rmb and action.rmb ~= right then
        return false
    end
    local t = COMPONENT_ACTIONS.ISVALID
    for i, v in ipairs(self.actioncomponents) do
        local vaildator = t[ACTION_COMPONENT_NAMES[v]]
        if vaildator ~= nil and vaildator(self, action, right) then
            return true
        end
    end
    if self.modactioncomponents ~= nil then
        for modname, cmplist in pairs(self.modactioncomponents) do
            t = CheckModComponentActions(self, modname).ISVALID
            if t ~= nil then
                local namemap = CheckModComponentNames(self, modname)
                for i, v in ipairs(cmplist) do
                    local vaildator = t[namemap[v]]
                    if vaildator ~= nil and vaildator(self, action, right) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function EntityScript:HasActionComponent(name)
    local id = ACTION_COMPONENT_IDS[name]
    if id ~= nil then
        for i, v in ipairs(self.actioncomponents) do
            if v == id then
                return true
            end
        end
    end
    if self.modactioncomponents ~= nil then
        for modname, cmplist in pairs(self.modactioncomponents) do
            id = CheckModComponentIds(self, modname)[name]
            if id ~= nil then
                for i, v in ipairs(cmplist) do
                    if v == id then
                        return true
                    end
                end
            end
        end
    end
    return false
end
