require 'util'
require 'vecutil'
local BEEF_HASTAGS = {"beefalo"}

local function CanCastFishingNetAtPoint(thrower, target_x, target_z)
    local min_throw_distance = 2
    local thrower_x, thrower_y, thrower_z = thrower.Transform:GetWorldPosition()

    if TheWorld.Map:IsOceanAtPoint(target_x, 0, target_z) and VecUtil_LengthSq(target_x - thrower_x, target_z - thrower_z) > min_throw_distance * min_throw_distance then
        return true
    end
	return false
end

local function Row(inst, doer, pos, actions)
    local map = TheWorld.Map

    local platform_under_cursor = map:GetPlatformAtPoint(pos.x, pos.z)

    local doer_x, doer_y, doer_z = doer.Transform:GetWorldPosition()
    local my_platform = doer:GetCurrentPlatform()
    local is_controller_attached = doer.components.playercontroller.isclientcontrollerattached

    local is_hovering_cursor_over_my_platform = false
    if not is_controller_attached then
        is_hovering_cursor_over_my_platform = my_platform ~= nil and (my_platform == platform_under_cursor)
    end

    if is_hovering_cursor_over_my_platform or my_platform == nil then
        return
    end

    if CLIENT_REQUESTED_ACTION == ACTIONS.ROW_FAIL then
        table.insert(actions, ACTIONS.ROW_FAIL)
    elseif doer ~= nil and not doer:HasTag("is_row_failing") then
        local animation_fail_time = (doer.AnimState:IsCurrentAnimation("row_pre") and (30/30)) or (4/30)

        if doer:HasTag("is_rowing") and doer.AnimState:GetCurrentAnimationTime() < animation_fail_time then
            table.insert(actions, ACTIONS.ROW_FAIL)
        elseif not is_controller_attached then
            table.insert(actions, ACTIONS.ROW)
        else
            local my_platform_x, my_platform_y, my_platform_z = my_platform.Transform:GetWorldPosition()
            local dir_x, dir_z = VecUtil_Normalize(doer_x - my_platform_x, doer_z - my_platform_z)
            local test_length = 0.5
            -- So the position on the client/server don't quite match and the server position doesn't stick as tight to the
            -- area surrounding the boat so give a little leeway when checking to see if there's water around you when the client
            -- is requesting to row
            if ThePlayer ~= doer then
                test_length = 0.75
            end
            local test_x, test_z = doer_x + dir_x * test_length, doer_z + dir_z * test_length
            local found_water = not map:IsVisualGroundAtPoint(test_x, 0, test_z) and map:GetPlatformAtPoint(test_x, test_z) == nil
            if found_water then
                table.insert(actions, ACTIONS.ROW_CONTROLLER)
            end
        end
    end
end

local function PlantRegistryResearch(inst, doer, actions)
    if inst ~= doer and (doer.CanExamine == nil or doer:CanExamine()) then
        local plantinspector = doer.replica.inventory and doer.replica.inventory:EquipHasTag("plantinspector") or false
        local plantkin = doer:HasTag("plantkin")

        if plantinspector and ((inst.GetPlantRegistryKey and inst.GetResearchStage) or inst.GetFertilizerKey) then
            local act = CLIENT_REQUESTED_ACTION
            if (not TheNet:IsDedicated() and doer == ThePlayer) then
                if (inst:HasTag("plantresearchable") and not ThePlantRegistry:KnowsPlantStage(inst:GetPlantRegistryKey(), inst:GetResearchStage())) or
                (inst:HasTag("fertilizerresearchable") and not ThePlantRegistry:KnowsFertilizer(inst:GetFertilizerKey())) then
                    act = ACTIONS.PLANTREGISTRY_RESEARCH
                else
                    act = ACTIONS.PLANTREGISTRY_RESEARCH_FAIL
                end
            end
            if act == ACTIONS.PLANTREGISTRY_RESEARCH or act == ACTIONS.PLANTREGISTRY_RESEARCH_FAIL then
                table.insert(actions, act)
            end
        end

        if (plantinspector or plantkin) and (inst:HasTag("farmplantstress") or inst:HasTag("weedplantstress")) then
            table.insert(actions, ACTIONS.ASSESSPLANTHAPPINESS)
        end
    end
end

local function GetFishingAction(doer, fishing_target)
	if doer:HasTag("fishing_idle") then
		if fishing_target ~= nil and not fishing_target:HasTag("projectile") then
			if fishing_target:HasTag("oceachfishing_catchable") then -- not fishing_target:HasTag("partiallyhooked") then
				if fishing_target:HasTag("fishinghook") then
					return ACTIONS.OCEAN_FISHING_STOP
				else
					return ACTIONS.OCEAN_FISHING_CATCH
				end
			end
			return ACTIONS.OCEAN_FISHING_REEL
		end
	end
	return nil
end

-- SCENE		using an object in the world
-- USEITEM		using an inventory item on an object in the world
-- POINT		using an inventory item on a point in the world
-- EQUIPPED		using an equiped item on yourself or a target object in the world
-- INVENTORY	using an inventory item

local COMPONENT_ACTIONS =
{
    SCENE = --args: inst, doer, actions, right
    {
        activatable = function(inst, doer, actions, right)
            if inst:HasTag("inactive") then
				if right or (inst.replica.inventoryitem == nil and not inst:HasTag("activatable_forceright")) then
					if not inst:HasTag("smolder") and not inst:HasTag("fire") then
		                table.insert(actions, ACTIONS.ACTIVATE)
					end
				end
            end
        end,

        anchor = function(inst, doer, actions, right)
            if not inst:HasTag("burnt") then
                if not inst:HasTag("anchor_raised") or inst:HasTag("anchor_transitioning") then
                    table.insert(actions, ACTIONS.RAISE_ANCHOR)
                elseif inst:HasTag("anchor_raised") then
                    table.insert(actions, ACTIONS.LOWER_ANCHOR)
                end
            end
        end,

        battery = function(inst, doer, actions)
            if inst:HasTag("battery") and doer:HasTag("batteryuser") then
                table.insert(actions, ACTIONS.CHARGE_FROM)
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


		yotc_racestart = function(inst, doer, actions, right)
			if right and not (inst:HasTag("burnt") or inst:HasTag("fire") or inst:HasTag("race_on")) then
				table.insert(actions, ACTIONS.START_CARRAT_RACE)
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
                not IsEntityDead(inst, true) and
                inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer) then
                table.insert(actions, ACTIONS.ATTACK)
            end
        end,

        constructionsite = function(inst, doer, actions)
            if not inst:HasTag("burnt") and not inst:HasTag("smolder") and not inst:HasTag("fire") then
                table.insert(actions,
                    not (doer.components.playercontroller ~= nil and
                        doer.components.playercontroller.isclientcontrollerattached) and
                    inst.replica.constructionsite:IsBuilder(doer) and
                    ACTIONS.STOPCONSTRUCTION or
                    ACTIONS.CONSTRUCT)
            end
        end,

        container = function(inst, doer, actions, right)
            if inst:HasTag("bundle") then
                if right and inst.replica.container:IsOpenedBy(doer) then
                    table.insert(actions, doer.components.constructionbuilderuidata ~= nil and doer.components.constructionbuilderuidata:GetContainer() == inst and ACTIONS.APPLYCONSTRUCTION or ACTIONS.WRAPBUNDLE)
                end
            elseif not inst:HasTag("burnt")
                and inst.replica.container:CanBeOpened()
                and doer.replica.inventory ~= nil
                and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                table.insert(actions, ACTIONS.RUMMAGE)
            end
        end,

        crittertraits = function(inst, doer, actions, right)
            if inst.replica.follower ~= nil and inst.replica.follower:GetLeader() == doer then
                if right then
                    if inst.replica.container then -- Added for wobysmall
                        table.insert(actions, ACTIONS.PET)
                    elseif doer.replica.builder ~= nil
                       and doer.replica.builder:GetTechTrees().ORPHANAGE > 0
                       and not inst:HasTag("noabandon") then
                        table.insert(actions, ACTIONS.ABANDON)
                    end
                elseif inst.replica.container == nil then
                    table.insert(actions, ACTIONS.PET)
                end
            end
        end,

        crop = function(inst, doer, actions)
            if (inst:HasTag("readyforharvest") or inst:HasTag("withered")) and doer.replica.inventory ~= nil then
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        cyclable = function(inst, doer, actions, right)
            if right and inst:HasTag("cancycle") then
                table.insert(actions, ACTIONS.CYCLE)
            end
        end,

        dryer = function(inst, doer, actions)
            if inst:HasTag("dried") and not inst:HasTag("burnt") then
                table.insert(actions, ACTIONS.HARVEST)
            end
        end,

        farmplanttendable = function(inst, doer, actions)
            if inst:HasTag("tendable_farmplant") and not inst:HasTag("fire") and not inst:HasTag("smolder") and not doer:HasTag("mime") then
                table.insert(actions, ACTIONS.INTERACT_WITH)
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
        
        heavyobstacleusetarget = function(inst, doer, actions, right)
            local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if right and item ~= nil and item:HasTag("heavy") and inst:HasTag("can_use_heavy")
                and (inst.use_heavy_obstacle_action_filter == nil or inst.use_heavy_obstacle_action_filter(inst, doer, item)) then
                
                table.insert(actions, ACTIONS.USE_HEAVY_OBSTACLE)
            end
        end,

        plantresearchable = function(inst, doer, actions, right)
            if not right then
                PlantRegistryResearch(inst, doer, actions)
            end
        end,

		prototyper = function(inst, doer, actions, right)
			if not right then
                table.insert(actions, ACTIONS.OPEN_CRAFTING)
			end
		end,

        fertilizerresearchable = function(inst, doer, actions, right)
            if right then
                PlantRegistryResearch(inst, doer, actions)
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
                (not inst:HasTag("spider") or (doer:HasTag("spiderwhisperer") and right)) and
                (right or not inst:HasTag("heavy")) and
                not (right and inst.replica.container ~= nil and inst.replica.equippable == nil) then
                table.insert(actions, ACTIONS.PICKUP)
            end
        end,

        kitcoon = function(inst, doer, actions, right)
            if right then
	            if inst.replica.follower ~= nil and inst.replica.follower:GetLeader() == doer then
					if doer:HasTag("near_kitcoonden") and FindEntity(inst, TUNING.KITCOON_NEAR_DEN_DIST, nil, {"kitcoonden"}) ~= nil then
	                    table.insert(actions, ACTIONS.RETURN_FOLLOWER)
					else
	                    table.insert(actions, ACTIONS.ABANDON)
					end
	            end
			else
                table.insert(actions, ACTIONS.PET)
            end
        end,

		hideandseekhidingspot = function(inst, doer, actions, right)
            if right then
				table.insert(actions, ACTIONS.HIDEANSEEK_FIND)
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

        mast = function(inst, doer, actions, right)

            if inst:HasTag("sailraised") then
                if not doer:HasTag("is_furling") then
                    return table.insert(actions, ACTIONS.LOWER_SAIL_BOOST)
                else
                    if doer.AnimState:IsCurrentAnimation("pull_big_pre") or doer.AnimState:IsCurrentAnimation("pull_big_lag") or doer.AnimState:IsCurrentAnimation("pull_big_loop") then
                        return table.insert(actions, ACTIONS.LOWER_SAIL_FAIL)
                    elseif doer.AnimState:IsCurrentAnimation("pull_small_loop") or doer.AnimState:IsCurrentAnimation("pull_small_pre") then
                        return table.insert(actions, ACTIONS.LOWER_SAIL_BOOST)
                    end
                end
            elseif inst:HasTag("saillowered") and not inst:HasTag("sail_transitioning") then
                table.insert(actions, ACTIONS.RAISE_SAIL)
            end
        end,

        mine = function(inst, doer, actions, right)
            if right and inst:HasTag("minesprung") and not inst:HasTag("mine_not_reusable") then
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

        portablestructure = function(inst, doer, actions, right)
            if right and not inst:HasTag("fire") and
                (not inst:HasTag("mastercookware") or doer:HasTag("masterchef")) then

                if  not inst.candismantle or inst.candismantle(inst) then
                    local container = inst.replica.container
                    if (container == nil or (container:CanBeOpened() and not container:IsOpenedBy(doer)))  then
                        table.insert(actions, ACTIONS.DISMANTLE)
                    end
                end
            end
        end,

        projectile = function(inst, doer, actions)
            if inst:HasTag("catchable") and doer:HasTag("cancatch") then
                table.insert(actions, ACTIONS.CATCH)
            end
        end,

        repairable = function(inst, doer, actions, right)
            if right and
                    (doer.replica.inventory ~= nil and doer.replica.inventory:IsHeavyLifting()) and
                    not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                if item ~= nil then
                    if (inst:HasTag("repairable_sculpture") and item:HasTag("work_sculpture"))
                            or (inst:HasTag("repairable_moon_altar") and item:HasTag("work_moon_altar")) then
                        table.insert(actions, ACTIONS.REPAIR)
                    end
                end
            end
        end,

        revivablecorpse = function(inst, doer, actions, right)
            if inst.components.revivablecorpse:CanBeRevivedBy(doer) then
                table.insert(actions, ACTIONS.REVIVE_CORPSE)
            end
        end,

        rideable = function(inst, doer, actions, right)
            if right and inst:HasTag("rideable") and

               not inst:HasTag("hitched") and
               (not inst:HasTag("dogrider_only") or
               (inst:HasTag("dogrider_only") and doer:HasTag("dogrider"))) then

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
            if (doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper")) and
               (not inst:HasTag("spiderden") or doer:HasTag("spiderwhisperer")) then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end,

        steeringwheel = function(inst, doer, actions, right)
            if not inst:HasTag("occupied") and not inst:HasTag("fire") then
                table.insert(actions, ACTIONS.STEER_BOAT)
            end
        end,

        stewer = function(inst, doer, actions, right)
            if not inst:HasTag("burnt") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                if inst:HasTag("donecooking") then
                    table.insert(actions, ACTIONS.HARVEST)
                elseif right and (
                    (   inst:HasTag("readytocook") and
                        --(not inst:HasTag("professionalcookware") or doer:HasTag("professionalchef")) and
                        (not inst:HasTag("mastercookware") or doer:HasTag("masterchef"))
                    ) or
                    (   inst.replica.container ~= nil and
                        inst.replica.container:IsFull() and
                        inst.replica.container:IsOpenedBy(doer)
                    )
                ) then
                    table.insert(actions, ACTIONS.COOK)
                end
            end
        end,

		storytellingprop = function(inst, doer, actions, right)
            if right and inst:HasTag("storytellingprop") and doer:HasTag("storyteller") then
                table.insert(actions, ACTIONS.TELLSTORY)
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

        questowner = function(inst, doer, actions, right)
            if right and (inst.CanBeActivatedBy_Client == nil or inst:CanBeActivatedBy_Client(doer)) then
                if inst:HasTag("questing") then
                    table.insert(actions, ACTIONS.ABANDON_QUEST)
                else
                    table.insert(actions, ACTIONS.BEGIN_QUEST)
                end
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

        trophyscale = function(inst, doer, actions, right)
            if right then
                if (doer.replica.inventory ~= nil and doer.replica.inventory:IsHeavyLifting()) and
                    not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then

                    local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
                    if item ~= nil then
                        for _,v in pairs(TROPHYSCALE_TYPES) do
                            if inst:HasTag("trophyscale_"..v) and item:HasTag("weighable_"..v) and item.replica.inventoryitem ~= nil and item.replica.inventoryitem:IsGrandOwner(doer) then
                                table.insert(actions, ACTIONS.COMPARE_WEIGHABLE)
                                return
                            end
                        end
                    end
                elseif inst:HasTag("trophycanbetaken") and
                    not inst:HasTag("burnt") and
                    not inst:HasTag("fire") then

                    table.insert(actions, ACTIONS.REMOVE_FROM_TROPHYSCALE)
                end
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

        groomer = function(inst, doer, actions, right)
            if inst:HasTag("groomer") and not inst:HasTag("fire") and not inst:HasTag("burnt") and not inst:HasTag("hitcher") and right then
                table.insert(actions, ACTIONS.CHANGEIN)
            end
        end,

        hitcher = function(inst, doer, actions, right)
            if inst:HasTag("hitcher") and not inst:HasTag("fire") and not inst:HasTag("burnt") and not inst:HasTag("hitcher_locked")  then
                table.insert(actions, ACTIONS.HITCHUP)
            end

            -- [TODO] this needs to confirm that beefalo is the owners beef.
            if not inst:HasTag("hitcher") and not inst:HasTag("fire") and not inst:HasTag("burnt") and not inst:HasTag("hitcher_locked") and not right then
                table.insert(actions, ACTIONS.UNHITCH)
            end
        end,

        markable = function(inst, doer, actions, right)
            if inst:HasTag("markable") then
                table.insert(actions, ACTIONS.MARK)
            end
        end,

        markable_proxy = function(inst, doer, actions, right)
            if inst:HasTag("markable_proxy") then
                table.insert(actions, ACTIONS.MARK)
            end
        end,

        walkingplank = function(inst, doer, actions, right)
            if right then
                if doer:HasTag("on_walkable_plank") then
                    table.insert(actions, ACTIONS.ABANDON_SHIP)
                else
                    if inst:HasTag("interactable") then
                        if inst:HasTag("plank_extended") then
                            table.insert(actions, ACTIONS.RETRACT_PLANK)
                        else
                            table.insert(actions, ACTIONS.EXTEND_PLANK)
                        end
                    end
                end
            else
                if inst:HasTag("interactable") then
                    if inst:HasTag("plank_extended") then
                        table.insert(actions, ACTIONS.MOUNT_PLANK)
                    end
                end
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

        winch = function(inst, doer, actions, right)
            if right and inst:HasTag("takeshelfitem") then
                table.insert(actions, ACTIONS.UNLOAD_WINCH)
            end
        end,

        wintersfeasttable = function(inst, doer, actions, right)
            if right and inst:HasTag("readyforfeast") and not inst:HasTag("fire") and not inst:HasTag("burnt") then
				table.insert(actions, ACTIONS.WINTERSFEAST_FEAST)
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

        yotc_racecompetitor = function(inst, doer, actions, right)
            if (inst:HasTag("has_prize") or inst:HasTag("has_no_prize"))
                    and not IsEntityDead(inst) then
                table.insert(actions, ACTIONS.PICKUP)
            end
        end,

        yotb_stager = function(inst, doer, actions, right)
            if inst:HasTag("yotb_conteststartable") and IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
                table.insert(actions, ACTIONS.YOTB_STARTCONTEST)
            end
            if inst:HasTag("has_prize") then
                table.insert(actions, ACTIONS.INTERACT_WITH)
            end
        end,

        yotb_sewer = function(inst, doer, actions, right)
            if not inst:HasTag("burnt") and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                if right and (inst:HasTag("readytosew") or
                    (   inst.replica.container ~= nil and
                        inst.replica.container:IsFull() and
                        inst.replica.container:IsOpenedBy(doer)
                    )) then

                    table.insert(actions, ACTIONS.YOTB_SEW)
                end
            end
        end,

        mightygym = function(inst, doer, actions, right)
            if doer:HasTag("player") and doer:HasTag("strongman") and 
                not inst:HasTag("hasstrongman") then
                
                if right and inst:HasTag("loaded") then
                    -- TODO: unload gym action
                    table.insert(actions, ACTIONS.UNLOAD_GYM)
                else
                    table.insert(actions, ACTIONS.ENTER_GYM)
                end
            end
        end,
    },

    USEITEM = --args: inst, doer, target, actions, right
    {
        appraisable = function(inst, doer, target, actions)
            if target:HasTag("appraiser") then
                table.insert(actions, ACTIONS.APPRAISE)
            end
        end,

        bait = function(inst, doer, target, actions)
            if target:HasTag("canbait") then
                table.insert(actions, ACTIONS.BAIT)
            end
        end,

        bathbomb = function(inst, doer, target, actions)
            if inst:HasTag("bathbomb") and target:HasTag("bathbombable") then
                table.insert(actions, ACTIONS.BATHBOMB)
            end
        end,

        boatpatch = function(inst, doer, target, actions)
            if inst:HasTag("boat_patch") and target:HasTag("boat_leak") then
                table.insert(actions, ACTIONS.REPAIR_LEAK)
            end
        end,

        brush = function(inst, doer, target, actions, right)
            if not right and target:HasTag("brushable") then
                table.insert(actions, ACTIONS.BRUSH)
            end
        end,

        carnivalgameitem = function(inst, doer, target, actions, right)
			if target:HasTag("carnivalgame_canfeed") then
				if target.prefab == "carnivalgame_feedchicks_nest" then
					table.insert(actions, ACTIONS.CARNIVALGAME_FEED)
				end
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
            if target.prefab ~= nil and inst:HasTag(target.prefab.."_plans") then
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
            local ishandfed = target:HasTag("handfed")

            if not (target.replica.rider ~= nil and target.replica.rider:IsRiding()) and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) and
                not target:HasTag("wereplayer") then

                if right or iscritter then
                    for k, v in pairs(FOODGROUP) do
                        if target:HasTag(v.name.."_eater") then
                            for i, v2 in ipairs(v.types) do
                                if inst:HasTag("edible_"..v2) then
                                    if iscritter or ishandfed then
                                        if (target.replica.follower ~= nil and target.replica.follower:GetLeader() == doer) or target:HasTag("fedbyall") then
                                            table.insert(actions, ACTIONS.FEED)
                                        end
                                    elseif target:HasTag("player") then
                                        if TheNet:GetPVPEnabled() or 
                                            (target:HasTag("strongstomach") and inst:HasTag("monstermeat")) or
                                            (inst:HasTag("spoiled") and target:HasTag("ignoresspoilage") and not 
                                                (inst:HasTag("badfood") or inst:HasTag("unsafefood"))) or not -- ignoresspoilage still checks for unsage foods
                                            (inst:HasTag("badfood") or inst:HasTag("unsafefood") or inst:HasTag("spoiled")) then
                                            table.insert(actions, ACTIONS.FEEDPLAYER)
                                        end
                                    elseif (target:HasTag("small_livestock") or ishandfed)
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
                            if iscritter or ishandfed then
                                if (target.replica.follower ~= nil and target.replica.follower:GetLeader() == doer) or target:HasTag("fedbyall") then
                                    table.insert(actions, ACTIONS.FEED)
                                end
                            elseif target:HasTag("player") then
                                if TheNet:GetPVPEnabled() or 
                                    (target:HasTag("strongstomach") and inst:HasTag("monstermeat")) or
                                    (inst:HasTag("spoiled") and target:HasTag("ignoresspoilage") and not 
                                        (inst:HasTag("badfood") or inst:HasTag("unsafefood"))) or not -- ignoresspoilage still checks for unsage foods
                                    (inst:HasTag("badfood") or inst:HasTag("unsafefood") or inst:HasTag("spoiled")) then
                                    table.insert(actions, ACTIONS.FEEDPLAYER) 
                                end
                            elseif (target:HasTag("small_livestock") or ishandfed)
                                and target.replica.inventoryitem ~= nil
                                and target.replica.inventoryitem:IsHeld() then
                                table.insert(actions, ACTIONS.FEED)
                            end
                            return
                        end
                    end
                end

                if target:HasTag("compostingbin_accepts_items")
                    and not inst:HasTag("edible_ELEMENTAL")
                    and not inst:HasTag("edible_GEARS")
                    and not inst:HasTag("edible_INSECT")
                    and not inst:HasTag("edible_BURNT") then

                    table.insert(actions, ACTIONS.ADDCOMPOSTABLE)
                end
            end
        end,

        fan = function(inst, doer, target, actions)
            table.insert(actions, ACTIONS.FAN)
        end,

        farmplantable = function(inst, doer, target, actions)
            if target:HasTag("soil") and not target:HasTag("NOCLICK") then
                table.insert(actions, ACTIONS.PLANTSOIL)
            end
        end,

        fertilizer = function(inst, doer, target, actions)
            if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) and
                (   --[[crop]] (target:HasTag("notreadyforharvest") and not target:HasTag("withered")) or
                    --[[grower]] target:HasTag("fertile") or target:HasTag("infertile") or
                    --[[pickable]] target:HasTag("barren") or
                    --[[quagmire_fertilizable]] target:HasTag("fertilizable")
                ) or
                --[[self_fertilizable]] ( (target == nil or target == doer) and
                                        inst:HasTag("fertilizer") and
                                        doer:HasTag("self_fertilizable") and
                                        doer.replica.health ~= nil and
                                        doer.replica.health:CanHeal()   ) then
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

        forcecompostable = function(inst, doer, target, actions)
            if target:HasTag("compostingbin_accepts_items") then
                table.insert(actions, ACTIONS.ADDCOMPOSTABLE)
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

        ghostlyelixir = function(inst, doer, target, actions)
            if target:HasTag("ghostlyelixirable") then
                table.insert(actions, ACTIONS.GIVE)
            end
        end,

		halloweenpotionmoon = function(inst, doer, target, actions)
			if not target:HasTag("DECOR") then
				table.insert(actions, ACTIONS.HALLOWEENMOONMUTATE)
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
            local inventoryitem = inst.replica.inventoryitem
            if inventoryitem ~= nil and inventoryitem:CanOnlyGoInPocket() then
                --not tradable
            elseif inventoryitem ~= nil
                and target.replica.container ~= nil
                and target.replica.container:CanBeOpened()
                and inventoryitem:IsGrandOwner(doer) then
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
                    not target:HasTag("wereplayer") and
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

        itemweigher = function(inst, doer, target, actions)
            for _,v in pairs(TROPHYSCALE_TYPES) do
                if inst:HasTag("trophyscale_"..v) and target:HasTag("weighable_"..v) and target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer) then
                    table.insert(actions, ACTIONS.WEIGH_ITEM)
                    return
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
            if target:HasTag("canlight") and not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO")) then
                table.insert(actions, ACTIONS.LIGHT)
            end
        end,

        maprecorder = function(inst, doer, target, actions)
            if doer == target and target:HasTag("player") then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        moonrelic = function(inst, doer, target, actions)
            if target:HasTag("moontrader") and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
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

        oceanfishingrod = function(inst, doer, target, actions)
            if target:HasTag("fishable") then
				table.insert(actions, ACTIONS.OCEAN_FISHING_POND)
            end
        end,

        plantable = function(inst, doer, target, actions)
            if target:HasTag("fertile") or target:HasTag("fullfertile") then
                table.insert(actions, ACTIONS.PLANT)
            end
        end,

        pocketwatch = function(inst, doer, target, actions)
            if inst:HasTag("pocketwatch_inactive") and doer:HasTag("pocketwatchcaster") and inst.pocketwatch_CanTarget ~= nil and inst:pocketwatch_CanTarget(doer, target) then
				if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("pocketwatch_mountedcast") then
	                table.insert(actions, ACTIONS.CAST_POCKETWATCH)
				end
            end
        end,

        preservative = function(inst, doer, target, actions, right)
			if right and target.replica.health == nil
				and (target:HasTag("fresh") or target:HasTag("stale") or target:HasTag("spoiled"))
				and target:HasTag("cookable")
				and not target:HasTag("deployable")
				and not target:HasTag("smallcreature") then
					table.insert(actions, ACTIONS.APPLYPRESERVATIVE)
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
                            or (inst:HasTag("health_"..v) and target:HasTag("healthrepairable"))
                            or (inst:HasTag("freshen_"..v) and (target:HasTag("fresh") or target:HasTag("stale") or target:HasTag("spoiled"))) then
                            table.insert(actions, ACTIONS.REPAIR)
                        end
                        return
                    end
                end
            end
        end,

        saddler = function(inst, doer, target, actions)
            if target:HasTag("saddleable") and not target:HasTag("dogrider_only") then
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
            if target:HasTag("bearded") and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
                local is_den = target:HasTag("spiderden")
                if is_den and doer:HasTag("spiderwhisperer") then
                    table.insert(actions, ACTIONS.SHAVE)
                elseif not is_den then
                    table.insert(actions, ACTIONS.SHAVE)
                end
            end
        end,

        sleepingbag = function(inst, doer, target, actions)
           if (doer == target and doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper")) and
              (not inst:HasTag("spiderden") or doer:HasTag("spiderwhisperer")) then
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

        soul = function(inst, doer, target, actions)
            if doer == target and target:HasTag("souleater") then
                table.insert(actions, ACTIONS.EAT)
            end
        end,

        stackable = function(inst, doer, target, actions)
            if inst.prefab == target.prefab and inst.AnimState:GetSkinBuild() == target.AnimState:GetSkinBuild() and --inst.skinname == target.skinname (this does not work on clients, so we're going to use the AnimState hack instead)
                target.replica.stackable ~= nil and
                not target.replica.stackable:IsFull() and
                target.replica.inventoryitem ~= nil and
                not target.replica.inventoryitem:IsHeld() then
                table.insert(actions, ACTIONS.COMBINESTACK)
            end
        end,

        summoningitem = function(inst, doer, target, actions, right)
			if not target.inlimbo and target.replica.follower ~= nil and target.replica.follower:GetLeader() == doer and doer:HasTag("ghostfriend_summoned") then
				table.insert(actions, ACTIONS.CASTUNSUMMON)
			end
        end,

		tacklesketch = function(inst, doer, target, actions)
			if target:HasTag("tacklestation") and
				not (target:HasTag("fire") or target:HasTag("smolder")) then

				table.insert(actions, ACTIONS.GIVE_TACKLESKETCH)
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

        treegrowthsolution = function(inst, doer, target, actions)
            if target:HasTag("tree") and
                not target:HasTag("monster") and
                not target:HasTag("fire") and
                not target:HasTag("burnt") and
                not target:HasTag("stump") and
                not target:HasTag("leif") and
                not target:HasTag("no_force_grow") then

                table.insert(actions, ACTIONS.ADVANCE_TREE_GROWTH)
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
                    return
                end
            end
        end,

        useabletargeteditem = function(inst, doer, target, actions)
            if target ~= nil then
				if (target.prefab ~= nil and inst:HasTag(target.prefab.."_targeter") and not inst:HasTag("inuse_targeted")) 
					or (inst.UseableTargetedItem_ValidTarget ~= nil and inst.UseableTargetedItem_ValidTarget(inst, target, doer)) then

					table.insert(actions, ACTIONS.USEITEMON)
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
            local inventoryitem = inst.replica.inventoryitem
            if inventoryitem ~= nil and
                target.replica.container ~= nil and
                target.replica.container:CanBeOpened() then
                -- put weapons into chester, don't attack him unless forcing attack with key press
                if not inventoryitem:CanOnlyGoInPocket() and
                    not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    (   (inst.prefab ~= "spoiled_food" and inst:HasTag("quagmire_stewable") and target:HasTag("quagmire_stewer") and target.replica.container:IsOpenedBy(doer)) or
                        not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel"))
                    ) then
                    table.insert(actions, target:HasTag("bundle") and ACTIONS.BUNDLESTORE or ACTIONS.STORE)
                end
            elseif target.replica.constructionsite ~= nil then
                if not (inventoryitem ~= nil and inventoryitem:CanOnlyGoInPocket()) and
                    not (GetGameModeProperty("non_item_equips") and inst.replica.equippable ~= nil) and
                    not (target:HasTag("BURNABLE_fueled") and inst:HasTag("BURNABLE_fuel")) then
                    table.insert(actions, target.replica.constructionsite:IsBuilder(doer) and ACTIONS.BUNDLESTORE or ACTIONS.CONSTRUCT)
                end
            elseif not right and
                doer.replica.combat ~= nil and
                doer.replica.combat:CanTarget(target) and
                (inst:HasTag("projectile") or inst:HasTag("rangedweapon") or not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())) and
				not inst:HasTag("outofammo") then
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

		weighable = function(inst, doer, target, actions)
			if target:HasTag("structure") then
				if not target:HasTag("burnt") then
					for _,v in pairs(TROPHYSCALE_TYPES) do
						if target:HasTag("trophyscale_"..v) and inst:HasTag("weighable_"..v) then
							table.insert(actions, ACTIONS.COMPARE_WEIGHABLE)
							return
						end
					end
				end
			elseif target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer) then
				for _,v in pairs(TROPHYSCALE_TYPES) do
					if target:HasTag("trophyscale_"..v) and inst:HasTag("weighable_"..v) then
						table.insert(actions, ACTIONS.WEIGH_ITEM)
						return
					end
				end
			end
		end,

        winter_treeseed = function(inst, doer, target, actions)
            if target:HasTag("winter_treestand") and not (target:HasTag("fire") or target:HasTag("smolder") or target:HasTag("burnt")) then
                table.insert(actions, ACTIONS.PLANT)
            end
        end,

        watersource = function(inst, doer, target, actions)
            if target:HasTag("fillable") then
                table.insert(actions, ACTIONS.FILL)
            end
        end,

        wax = function(inst, doer, target, actions)
            if target:HasTag("waxable") then
                table.insert(actions, ACTIONS.WAX)
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
            if target:HasTag("canbeslaughtered") and not IsEntityDead(target) then
                table.insert(actions, ACTIONS.SLAUGHTER)
            end
        end,

        spidermutator = function(inst, doer, target, actions)
            if target:HasTag("spider") and not IsEntityDead(target) then
                table.insert(actions, ACTIONS.MUTATE_SPIDER)
            end
        end,

        bedazzler = function(inst, doer, target, actions)
            if doer:HasTag("spiderwhisperer") and target:HasTag("spiderden") and target:HasTag("bedazzleable") and not target:HasTag("bedazzled") then
               table.insert(actions, ACTIONS.BEDAZZLE) 
            end
        end,

        pocketwatch_dismantler = function (inst, doer, target, actions)
            if doer:HasTag("clockmaker") and target:HasTag("pocketwatch") then
                table.insert(actions, ACTIONS.DISMANTLE_POCKETWATCH)
            end
        end,
    },

    POINT = --args: inst, doer, pos, actions, right
    {
        blinkstaff = function(inst, doer, pos, actions, right)
            local x,y,z = pos:Get()
            if right and (TheWorld.Map:IsAboveGroundAtPoint(x,y,z) or TheWorld.Map:GetPlatformAtPoint(x,z) ~= nil) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") then
                table.insert(actions, ACTIONS.BLINK)
            end
        end,

        complexprojectile = function(inst, doer, pos, actions, right)
            if right and not TheWorld.Map:IsGroundTargetBlocked(pos) 
				and (inst.replica.equippable == nil or not inst.replica.equippable:IsRestricted(doer)) then

                table.insert(actions, ACTIONS.TOSS)
            end
        end,

        deployable = function(inst, doer, pos, actions, right)
            if right and inst.replica.inventoryitem ~= nil then
                if CLIENT_REQUESTED_ACTION == ACTIONS.DEPLOY_TILEARRIVE or CLIENT_REQUESTED_ACTION == ACTIONS.DEPLOY then
                    --CanDeploy will still run before the actual deploy itself.
                    table.insert(actions, CLIENT_REQUESTED_ACTION)
                elseif inst.replica.inventoryitem:CanDeploy(pos, nil, doer, (doer.components.playercontroller ~= nil and doer.components.playercontroller.deployplacer ~= nil) and doer.components.playercontroller.deployplacer.Transform:GetRotation() or 0) then
                    if inst:HasTag("tile_deploy") then
                        table.insert(actions, ACTIONS.DEPLOY_TILEARRIVE)
                    else
                        table.insert(actions, ACTIONS.DEPLOY)
                    end
                end
            end
        end,

        fishingnet = function(inst, doer, pos, actions, right)
            if right and CanCastFishingNetAtPoint(doer, pos.x, pos.z) then
                table.insert(actions, ACTIONS.CAST_NET)
            end
        end,

        fishingrod = function(inst, doer, pos, actions, right)
			if right and CanCastFishingNetAtPoint(doer, pos.x, pos.z) then
				table.insert(actions, ACTIONS.FISH_OCEAN)
			end
        end,

        inventoryitem = function(inst, doer, pos, actions, right)
            if not right and inst.replica.inventoryitem:IsHeldBy(doer) then
                table.insert(actions, ACTIONS.DROP)
            end
        end,

        oar = function(inst, doer, pos, actions, right)
            if right then
                Row(inst, doer, pos, actions)
            end
        end,

		oceanfishingrod = function(inst, doer, pos, actions, right)
            if right then
				local rod = inst.replica.oceanfishingrod
				if rod ~= nil then
					local target = rod:GetTarget()
					if target == nil then
						if CanCastFishingNetAtPoint(doer, pos.x, pos.z) then
							table.insert(actions, ACTIONS.OCEAN_FISHING_CAST)
						end
					else
						local action = GetFishingAction(doer, target)
						if action ~= nil then
							table.insert(actions, action)
						end
					end
				end
            end
        end,

		oceanthrowable = function(inst, doer, pos, actions, right)
            if right then
                if CanCastFishingNetAtPoint(doer, pos.x, pos.z) then
                    table.insert(actions, ACTIONS.OCEAN_TOSS)
                end
            end
        end,

		spellcaster = function(inst, doer, pos, actions, right)
            if right then
                local cast_on_water = inst:HasTag("castonpointwater")
                if inst:HasTag("castonpoint") then
                    local px, py, pz = pos:Get()
                    if TheWorld.Map:IsAboveGroundAtPoint(px, py, pz, cast_on_water) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") then
                        table.insert(actions, ACTIONS.CASTSPELL)
                    end
                elseif cast_on_water then
                    local px, py, pz = pos:Get()
                    if TheWorld.Map:IsOceanAtPoint(px, py, pz, false) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") then
                        table.insert(actions, ACTIONS.CASTSPELL)
                    end
                end
            end
        end,

        terraformer = function(inst, doer, pos, actions, right)
            if right and
                ((inst:HasTag("plow") and TheWorld.Map:CanPlowAtPoint(pos:Get())) or
                (not inst:HasTag("plow") and TheWorld.Map:CanTerraformAtPoint(pos:Get()))) then
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

        farmtiller = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:CanTillSoilAtPoint(pos.x, pos.y, pos.z) then
                table.insert(actions, ACTIONS.TILL)
            end
        end,

        quagmire_tiller = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:CanTillSoilAtPoint(pos) then
                table.insert(actions, ACTIONS.TILL)
            end
        end,

        wateryprotection = function(inst, doer, pos, actions, right)
            if right and TheWorld.Map:GetTileAtPoint(pos:Get()) == GROUND.FARMING_SOIL then
                table.insert(actions, ACTIONS.POUR_WATER_GROUNDTILE)
            end
        end,

        fillable = function(inst, doer, pos, actions, right)
            if inst:HasTag("fillable_showoceanaction") and TheWorld.Map:IsOceanAtPoint(pos.x, 0, pos.z) then
                table.insert(actions, ACTIONS.FILL_OCEAN)
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

        carnivalgameitem = function(inst, doer, target, actions, right)
			if target:HasTag("carnivalgame_canfeed") then
				if target.prefab == "carnivalgame_feedchicks_nest" then
					table.insert(actions, ACTIONS.CARNIVALGAME_FEED)
				end
			end
        end,

        complexprojectile = function(inst, doer, target, actions, right)
            if right and
                not (doer.components.playercontroller ~= nil and doer.components.playercontroller.isclientcontrollerattached) and
                not TheWorld.Map:IsGroundTargetBlocked(target:GetPosition()) and
				(inst.replica.equippable == nil or not inst.replica.equippable:IsRestricted(doer)) then
                
                table.insert(actions, ACTIONS.TOSS)
            end
        end,

        fishingrod = function(inst, doer, target, actions, right)
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

        fishingnet = function(inst, doer, target, actions, right)
            local pos_x, pos_y, pos_z = target.Transform:GetWorldPosition()
            if right and CanCastFishingNetAtPoint(doer, pos_x, pos_z) then
                table.insert(actions, ACTIONS.CAST_NET)
            end
        end,

        lighter = function(inst, doer, target, actions, right)
            if right and target:HasTag("canlight") and not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO")) then
                table.insert(actions, ACTIONS.LIGHT)
            end
        end,

        mightydumbbell = function(inst, doer, target, actions, right)
            if right and doer == target then
                if inst:HasTag("lifting") then
                    table.insert(actions, ACTIONS.STOP_LIFT_DUMBBELL)
                else
                    table.insert(actions, ACTIONS.LIFT_DUMBBELL)
                end
            end
        end,

        oar = function(inst, doer, target, actions, right)
            if right then
                --Only the keyboard/mouse needs the ability to arbitrarily click on scene objects to row.
                --The controller does not and if you allow it to, it will sometimes show the wrong ground hint text.
                if not doer.components.playercontroller.isclientcontrollerattached then
                    Row(inst, doer, target:GetPosition(), actions)
                end
            end
        end,

		oceanfishingrod = function(inst, doer, target, actions, right)
			local x, y, z = target.Transform:GetWorldPosition()
            if right then
				local rod = inst.replica.oceanfishingrod
				local fishing_target = rod ~= nil and rod:GetTarget() or nil
				if (target == fishing_target or target == doer) then
					local action = GetFishingAction(doer, fishing_target)
					if action ~= nil then
						table.insert(actions, action)
					end
				end
			else
				if target:HasTag("fishable") then
					table.insert(actions, ACTIONS.OCEAN_FISHING_POND)
				end
            end

        end,

        oceanthrowable = function(inst, doer, target, actions, right)
            if right and
                not (doer.components.playercontroller ~= nil and
                    doer.components.playercontroller.isclientcontrollerattached) and
                TheWorld.Map:IsOceanAtPoint(target:GetPosition():Get()) then
                table.insert(actions, ACTIONS.OCEAN_TOSS)
            end
        end,

        spellcaster = function(inst, doer, target, actions, right)
            if right and not target:HasTag("nomagic") and (
                    inst:HasTag("castontargets") or
                    (inst:HasTag("castonrecipes") and AllRecipes[target.prefab] ~= nil and not FunctionOrValue(AllRecipes[target.prefab].no_deconstruction, target)) or
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
                and (inst:HasTag("projectile") or inst:HasTag("rangedweapon") or not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()))
				and not inst:HasTag("outofammo") then
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

        wateryprotection = function(inst, doer, target, actions, right)
            if right and (target:HasTag("withered") or target:HasTag("fire") or target:HasTag("smolder")) then
                table.insert(actions, ACTIONS.POUR_WATER)
            end
        end,

        fillable = function(inst, doer, target, actions, right)
            if right and target:HasTag("watersource") then
                table.insert(actions, ACTIONS.FILL)
            end
        end,
    },

    INVENTORY = --args: inst, doer, actions, right
    {
--     balloonmaker = function(inst, doer, actions)
--         if doer:HasTag("balloonomancer") then
--             table.insert(actions, ACTIONS.MAKEBALLOON)
--         end
--     end,

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
            if doer.components.playercontroller ~= nil and not doer.components.playercontroller.deploy_mode then
                local inventoryitem = inst.replica.inventoryitem
				if inventoryitem ~= nil and inventoryitem:IsGrandOwner(doer) and inventoryitem:IsDeployable(doer) then
					table.insert(actions, ACTIONS.TOGGLE_DEPLOY_MODE)
				end
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
            if inst.replica.equippable:IsEquipped() then
                table.insert(actions, ACTIONS.UNEQUIP)
            elseif not inst.replica.equippable:IsRestricted(doer) then
                table.insert(actions, ACTIONS.EQUIP)
            end
        end,

        fan = function(inst, doer, actions)
            table.insert(actions, ACTIONS.FAN)
        end,

        fertilizer = function(inst, doer, actions)
            if inst:HasTag("fertilizer") and
                doer:HasTag("self_fertilizable") and
                doer.replica.health ~= nil and
                doer.replica.health:CanHeal() then
                table.insert(actions, ACTIONS.FERTILIZE)
            end
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

        plantresearchable = function(inst, doer, actions, right)
            PlantRegistryResearch(inst, doer, actions)
        end,

        fertilizerresearchable = function(inst, doer, actions, right)
            PlantRegistryResearch(inst, doer, actions)
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

        maprecorder = function(inst, doer, actions)
            if doer:HasTag("player") then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        mapspotrevealer = function(inst, doer, actions, right)
            if doer:HasTag("player") then
                table.insert(actions, ACTIONS.TEACH)
            end
        end,

        murderable = function(inst, doer, actions)
            table.insert(actions, ACTIONS.MURDER)
        end,

        oceanfishingtackle = function(inst, doer, actions, right)
            if doer.replica.inventory ~= nil and not doer.replica.inventory:IsHeavyLifting() then
                local rod = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if rod ~= nil and rod.replica.container ~= nil and rod.replica.container:IsOpenedBy(doer) and rod:HasTag("accepts_oceanfishingtackle") and rod.replica.container:CanTakeItemInSlot(inst) then
                    table.insert(actions, ACTIONS.CHANGE_TACKLE)
                end
            end
        end,

        pocketwatch = function(inst, doer, actions)
            if inst:HasTag("pocketwatch_inactive") and doer:HasTag("pocketwatchcaster") and inst:HasTag("pocketwatch_castfrominventory") then
				if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("pocketwatch_mountedcast") then
	                table.insert(actions, ACTIONS.CAST_POCKETWATCH)
				end
            end
        end,

        reloaditem  = function(inst, doer, actions, right)
            if doer.replica.inventory ~= nil and not doer.replica.inventory:IsHeavyLifting() then
                local hand_item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if hand_item ~= nil and hand_item.replica.container ~= nil and hand_item.replica.container:IsOpenedBy(doer) and hand_item.replica.container:CanTakeItemInSlot(inst) then
                    table.insert(actions, ACTIONS.CHANGE_TACKLE)
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

        simplebook = function(inst, doer, actions)
            table.insert(actions, ACTIONS.READ)
        end,

        sleepingbag = function(inst, doer, actions)
            if (doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper")) and 
               (not inst:HasTag("spiderden") or doer:HasTag("spiderwhisperer")) then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end,

        soul = function(inst, doer, actions)
            if doer:HasTag("souleater") then
                table.insert(actions, ACTIONS.EAT)
            end
        end,

        spellcaster = function(inst, doer, actions)
            if inst:HasTag("castfrominventory") then
                table.insert(actions, ACTIONS.CASTSPELL)
            end
        end,

        summoningitem = function(inst, doer, actions)
			if doer:HasTag("ghostfriend_notsummoned") then
				table.insert(actions, ACTIONS.CASTSUMMON)
			elseif doer:HasTag("ghostfriend_summoned") then
				table.insert(actions, ACTIONS.COMMUNEWITHSUMMONED)
			end
        end,

        singable = function(inst, doer, actions, right)
            local songdata = inst.songdata
            if doer:HasTag("battlesinger") and songdata then
                --this really belongs in a replica like object, but this is the only usage that would need it.
                --if this is needed in the future, don't copy the code, write either a client component, or a replica.
                local cansing = false
                if doer.components.singinginspiration then
                    cansing = songdata.INSTANT or not doer.components.singinginspiration:IsSongActive(songdata)
                else
                    local issongactive = false
                    if doer.player_classified then
                        for i, v in ipairs(doer.player_classified.inspirationsongs) do
                            if v:value() == songdata.battlesong_netid then
                                issongactive = true
                                break
                            end
                        end
                    end
                    cansing = songdata.INSTANT or not issongactive
                end

                if cansing then
                    table.insert(actions, ACTIONS.SING)
                else
                    table.insert(actions, ACTIONS.SING_FAIL)
                end
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

        upgrademodule = function(inst, doer, actions, right)
            if doer:HasTag("upgrademoduleowner") then
                local success = doer.CanUpgradeWithModule == nil or doer:CanUpgradeWithModule(inst)

                if success then
                    table.insert(actions, ACTIONS.APPLYMODULE)
                else
                    table.insert(actions, ACTIONS.APPLYMODULE_FAIL)
                end
            end
        end,

        upgrademoduleremover = function(inst, doer, actions, right)
            if doer:HasTag("upgrademoduleowner") then
                local success = doer.CanRemoveModules == nil or doer:CanRemoveModules()

                if success then
                    table.insert(actions, ACTIONS.REMOVEMODULES)
                else
                    table.insert(actions, ACTIONS.REMOVEMODULES_FAIL)
                end
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

        useabletargeteditem = function(inst, doer, actions, right)
            if inst:HasTag("useabletargeteditem_inventorydisable")
                    and inst:HasTag("inuse_targeted") then
                table.insert(actions, ACTIONS.STOPUSINGITEM)
            end
        end,

        yotb_skinunlocker = function(inst, doer, actions, right)
            if doer:HasTag("player") then
                table.insert(actions, ACTIONS.YOTB_UNLOCKSKIN)
            end
        end,

        followerherder = function(inst, doer, actions, right)
            if doer:HasTag("spiderwhisperer") then
                table.insert(actions, ACTIONS.HERD_FOLLOWERS)
            end
        end,

        repellent = function(inst, doer, actions, right)
            if doer:HasTag("spiderwhisperer") then
                table.insert(actions, ACTIONS.REPEL)
            end
        end,

        mightydumbbell = function(inst, doer, actions)
            if doer:HasTag("strongman") and 
              (inst.replica.equippable ~= nil and inst.replica.equippable:IsEquipped()) then
                if inst:HasTag("lifting") then
                    table.insert(actions, ACTIONS.STOP_LIFT_DUMBBELL)
                else
                    table.insert(actions, ACTIONS.LIFT_DUMBBELL)
                end
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
            t = CheckModComponentActions(self, modname)
            t = t and t[actiontype] or nil
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
            t = CheckModComponentActions(self, modname)
            t = t and t.ISVALID or nil
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
