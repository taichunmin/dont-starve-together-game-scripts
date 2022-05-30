local upvalue = {}
local easing = require("easing")
local PlayerHud = require("screens/playerhud")
local ex_fns = require "prefabs/player_common_extensions"

local BEEFALO_COSTUMES = require("yotb_costumes")

local fns = {} -- a table to store local functions in so that we don't hit the 60 upvalues limit

local USE_MOVEMENT_PREDICTION = true

local DEFAULT_PLAYER_COLOUR = { 1, 1, 1, 1 }

local DANGER_ONEOF_TAGS = { "monster", "pig", "_combat" }
local DANGER_NOPIG_ONEOF_TAGS = { "monster", "_combat" }
function fns.IsNearDanger(inst, hounded_ok)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and not hounded_ok and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = inst.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    -- See entityreplica.lua (for _combat tag usage)
    local nospiderdanger = inst:HasTag("spiderwhisperer") or inst:HasTag("spiderdisguise")
    local nopigdanger = not inst:HasTag("monster")
    --Danger if:
    -- being targetted
    -- OR near monster that is not player
    -- ignore shadow monsters when not insane
    return FindEntity(inst, 10,
        function(target)
            return (target.components.combat ~= nil and target.components.combat.target == inst)
                or ((target:HasTag("monster") or (not nopigdanger and target:HasTag("pig"))) and
                    not target:HasTag("player") and
                    not (nospiderdanger and target:HasTag("spider")) and
                    not (inst.components.sanity:IsSane() and target:HasTag("shadowcreature")))
        end,
        nil, nil, nopigdanger and DANGER_NOPIG_ONEOF_TAGS or DANGER_ONEOF_TAGS) ~= nil
end

function fns.SetGymStartState(inst)
    inst.Transform:SetNoFaced()

	inst:PushEvent("on_enter_might_gym")
    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")
    inst:ShowActions(true)
end

function fns.SetGymStopState(inst)
    inst.Transform:SetFourFaced()

    inst.components.inventory:Show()
    inst:ShowActions(true)
end

function fns.YOTB_unlockskinset(inst, skinset)
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
        local bit = setbit(inst.yotb_skins_sets:value(), YOTB_COSTUMES[skinset])
        inst.yotb_skins_sets:set( bit )

        inst.components.talker:Say(GetString(inst, "ANNOUNCE_YOTB_LEARN_NEW_PATTERN"))
        inst:PushEvent("yotb_learnblueprint")

        if inst.player_classified ~= nil then
            inst.player_classified.hasyotbskin:set(true)
        end
    end
end

function fns.YOTB_issetunlocked(inst, skinset)
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
        local bit = checkbit(inst.yotb_skins_sets:value(), YOTB_COSTUMES[skinset])
        return inst.yotb_skins_sets:value() == bit
    end
end

function fns.YOTB_isskinunlocked(inst, skin)
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
        for i,set in pairs(BEEFALO_COSTUMES.costumes)do
            for t,setskin in ipairs(set.skins) do
                if setskin == skin then
                    if inst:YOTB_issetunlocked(i) then
                        return true
                    else
                        return false
                    end
                end
            end
        end
    end
end

function fns.YOTB_getrandomset(inst)
    if not inst.yotb_skins_sets:value() or inst.yotb_skins_sets:value() == 0 then
        local sets = {}
        for i,bit in pairs(YOTB_COSTUMES)do
            table.insert(sets,bit)
        end
        inst.yotb_skins_sets:set( sets[math.random(1,#sets)] )
    end
end

local function giveupstring(combat, target)
    return GetString(
        combat.inst,
        "COMBAT_QUIT",
        target ~= nil and (
            (target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
            (string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG")
        ) or nil
    )
end

local function battlecrystring(combat, target)
    return target ~= nil
        and target:IsValid()
        and GetString(
            combat.inst,
            "BATTLECRY",
            (target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
            (string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or
            target.prefab
        )
        or nil
end

local function GetStatus(inst, viewer)
    return (inst:HasTag("playerghost") and "GHOST")
        or (inst.hasRevivedPlayer and "REVIVER")
        or (inst.hasKilledPlayer and "MURDERER")
        or (inst.hasAttackedPlayer and "ATTACKER")
        or (inst.hasStartedFire and "FIRESTARTER")
        or nil
end

local function TryDescribe(descstrings, modifier)
    return descstrings ~= nil and (
            type(descstrings) == "string" and
            descstrings or
            descstrings[modifier] or
            descstrings.GENERIC
        ) or nil
end

local function TryCharStrings(inst, charstrings, modifier)
    return charstrings ~= nil and (
            TryDescribe(charstrings.DESCRIBE[string.upper(inst.prefab)], modifier) or
            TryDescribe(charstrings.DESCRIBE.PLAYER, modifier)
        ) or nil
end

local function GetDescription(inst, viewer)
    local modifier = inst.components.inspectable:GetStatus(viewer) or "GENERIC"
    return string.format(
            TryCharStrings(inst, STRINGS.CHARACTERS[string.upper(viewer.prefab)], modifier) or
            TryCharStrings(inst, STRINGS.CHARACTERS.GENERIC, modifier),
            inst:GetDisplayName()
        )
end

local TALLER_TALKER_OFFSET = Vector3(0, -700, 0)
local DEFAULT_TALKER_OFFSET = Vector3(0, -400, 0)
local function GetTalkerOffset(inst)
    local rider = inst.replica.rider
    return (rider ~= nil and rider:IsRiding() or inst:HasTag("playerghost"))
        and TALLER_TALKER_OFFSET
        or DEFAULT_TALKER_OFFSET
end

local TALLER_FROSTYBREATHER_OFFSET = Vector3(.3, 3.75, 0)
local DEFAULT_FROSTYBREATHER_OFFSET = Vector3(.3, 1.15, 0)
local function GetFrostyBreatherOffset(inst)
    local rider = inst.replica.rider
    return rider ~= nil and rider:IsRiding()
        and TALLER_FROSTYBREATHER_OFFSET
        or DEFAULT_FROSTYBREATHER_OFFSET
end

local function CanUseTouchStone(inst, touchstone)
    if inst.components.touchstonetracker ~= nil then
        return not inst.components.touchstonetracker:IsUsed(touchstone)
    elseif inst.player_classified ~= nil then
        return touchstone.GetTouchStoneID ~= nil and not table.contains(inst.player_classified.touchstonetrackerused:value(), touchstone:GetTouchStoneID())
    else
        return false
    end
end

local function GetTemperature(inst)
    if inst.components.temperature ~= nil then
        return inst.components.temperature:GetCurrent()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currenttemperature
    else
        return TUNING.STARTING_TEMP
    end
end

local function IsFreezing(inst)
    if inst.components.temperature ~= nil then
        return inst.components.temperature:IsFreezing()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currenttemperature < 0
    else
        return false
    end
end

local function IsOverheating(inst)
    if inst.components.temperature ~= nil then
        return inst.components.temperature:IsOverheating()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currenttemperature > TUNING.OVERHEAT_TEMP
    else
        return false
    end
end

local function GetMoisture(inst)
    if inst.components.moisture ~= nil then
        return inst.components.moisture:GetMoisture()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.moisture:value()
    else
        return 0
    end
end

local function GetMaxMoisture(inst)
    if inst.components.moisture ~= nil then
        return inst.components.moisture:GetMaxMoisture()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.maxmoisture:value()
    else
        return 100
    end
end

local function GetMoistureRateScale(inst)
    if inst.components.moisture ~= nil then
        return inst.components.moisture:GetRateScale()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.moistureratescale:value()
    else
        return RATE_SCALE.NEUTRAL
    end
end

local function GetStormLevel(inst)
    return inst.player_classified ~= nil and inst.player_classified.stormlevel:value() / 7 or 0
end

local function GetMoonstormLevel(inst)

    pos = { x = pos.x, y = pos.z }

    local depth = math.huge
    local node_edges = TheWorld.topology.nodes[node_index].validedges
    for _, edge_index in ipairs(node_edges) do
        local edge_nodes = TheWorld.topology.edgeToNodes[edge_index]
        local other_node_index = edge_nodes[1] ~= node_index and edge_nodes[1] or edge_nodes[2]
        if not _active_moonstorm_nodes[other_node_index] then
            local point_indices = TheWorld.topology.flattenedEdges[edge_index]
            local node1 = { x = TheWorld.topology.flattenedPoints[point_indices[1]][1], y = TheWorld.topology.flattenedPoints[point_indices[1]][2] }
            local node2 = { x = TheWorld.topology.flattenedPoints[point_indices[2]][1], y = TheWorld.topology.flattenedPoints[point_indices[2]][2] }

            depth = math.min(depth, DistPointToSegmentXYSq(pos, node1, node2))
        end
    end

    return depth
end

local function IsCarefulWalking(inst)
    return inst.player_classified ~= nil and inst.player_classified.iscarefulwalking:value()
end

local function ShouldAcceptItem(inst, item)
    if inst:HasTag("playerghost") then
        return item.prefab == "reviver" and inst:IsOnPassablePoint()
    else
        return item.components.inventoryitem ~= nil
    end
end

local function OnGetItem(inst, giver, item)
    if item ~= nil and item.prefab == "reviver" and inst:HasTag("playerghost") then
        if item.skin_sound then
            item.SoundEmitter:PlaySound(item.skin_sound)
        end
        item:PushEvent("usereviver", { user = giver })
        giver.hasRevivedPlayer = true
        AwardPlayerAchievement("hasrevivedplayer", giver)
        item:Remove()
        inst:PushEvent("respawnfromghost", { source = item, user = giver })

        inst.components.health:DeltaPenalty(TUNING.REVIVE_HEALTH_PENALTY)
        giver.components.sanity:DoDelta(TUNING.REVIVE_OTHER_SANITY_BONUS)
    elseif item ~= nil then
		if giver.components.age:GetAgeInDays() >= TUNING.ACHIEVEMENT_HELPOUT_GIVER_MIN_AGE and inst.components.age:GetAgeInDays() <= TUNING.ACHIEVEMENT_HELPOUT_RECEIVER_MAX_AGE then
			AwardPlayerAchievement("helping_hand", giver)
		end
    end
end

local function DropWetTool(inst, data)
    --Tool slip.
    if inst.components.moisture:GetSegs() < 4 or inst:HasTag("stronggrip") then
        return
    end

    local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if tool ~= nil and tool:GetIsWet() and math.random() < easing.inSine(TheWorld.state.wetness, 0, .15, inst.components.moisture:GetMaxMoisture()) then
        local projectile =
            data.weapon ~= nil and
            data.projectile == nil and
            (data.weapon.components.projectile ~= nil or data.weapon.components.complexprojectile ~= nil)

        if projectile then
            local num = data.weapon.components.stackable ~= nil and data.weapon.components.stackable:StackSize() or 1
            if num <= 1 then
                return
            end
            inst.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
            tool = data.weapon.components.stackable:Get(num - 1)
            tool.Transform:SetPosition(inst.Transform:GetWorldPosition())
            if tool.components.inventoryitem ~= nil then
                tool.components.inventoryitem:OnDropped()
            end
        else
            inst.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
            inst.components.inventory:DropItem(tool)
        end

        if tool.Physics ~= nil then
            local x, y, z = tool.Transform:GetWorldPosition()
            tool.Physics:Teleport(x, .3, z)

            local angle = (math.random() * 20 - 10) * DEGREES
            if data.target ~= nil and data.target:IsValid() then
                local x1, y1, z1 = inst.Transform:GetWorldPosition()
                x, y, z = data.target.Transform:GetWorldPosition()
                angle = angle + (
                    (x1 == x and z1 == z and math.random() * 2 * PI) or
                    (projectile and math.atan2(z - z1, x - x1)) or
                    math.atan2(z1 - z, x1 - x)
                )
            else
                angle = angle + math.random() * 2 * PI
            end
            local speed = projectile and 2 + math.random() or 3 + math.random() * 2
            tool.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
        end
        --Lock out from picking up for a while?
        --V2C: no need, the stategraph goes into busy state
    end
end

local function FrozenItems(item)
    return item:HasTag("frozen")
end

local function OnStartFireDamage(inst)
    local frozenitems = inst.components.inventory:FindItems(FrozenItems)
    for i, v in ipairs(frozenitems) do
        v:PushEvent("firemelt")
    end
end

local function OnStopFireDamage(inst)
    local frozenitems = inst.components.inventory:FindItems(FrozenItems)
    for i, v in ipairs(frozenitems) do
        v:PushEvent("stopfiremelt")
    end
end

--NOTE: On server we always get before lose attunement when switching effigies.
local function OnGotNewAttunement(inst, data)
    --can safely assume we are attuned if we just "got" an attunement
    if not inst._isrezattuned and
        data.proxy:IsAttunableType("remoteresurrector") then
        --NOTE: parenting automatically handles visibility
        SpawnPrefab("attune_out_fx").entity:SetParent(inst.entity)
        inst._isrezattuned = true
    end
end

local function OnAttunementLost(inst, data)
    --cannot assume that we are no longer attuned
    --to a type when we lose a single attunement!
    if inst._isrezattuned and
        data.proxy:IsAttunableType("remoteresurrector") and
        not inst.components.attuner:HasAttunement("remoteresurrector") then
        --remoterezsource flag means we're currently performing remote resurrection,
        --so we will lose attunement in the process, but we don't really want an fx!
        if not inst.remoterezsource then
            --NOTE: parenting automatically handles visibility
            SpawnPrefab(inst:HasTag("playerghost") and "attune_ghost_in_fx" or "attune_in_fx").entity:SetParent(inst.entity)
        end
        inst._isrezattuned = false
    end
end

--------------------------------------------------------------------------
--Audio events
--------------------------------------------------------------------------

local function OnGotNewItem(inst, data)
    if data.slot ~= nil or data.eslot ~= nil then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
    end
end

local function OnEquip(inst, data)
    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/wilson/equip_item")
end

local function OnPickSomething(inst, data)
    if data.object ~= nil and data.object.components.pickable ~= nil and data.object.components.pickable.picksound ~= nil then
        --Others can hear this
        inst.SoundEmitter:PlaySound(data.object.components.pickable.picksound)
    end
end

local function OnDropItem(inst)
    --Others can hear this
    inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
end

local function OnBurntHands(inst)
    --Others can hear this
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
end

--------------------------------------------------------------------------
--Action events
--------------------------------------------------------------------------

local function OnActionFailed(inst, data)
    if inst.components.talker ~= nil
		and not data.action.action.silent_fail
        and (data.reason ~= nil or
            not data.action.autoequipped or
            inst.components.inventory.activeitem == nil) then
        --V2C: Added edge case to suppress talking when failure is just due to
        --     action equip failure when your inventory is full.
        --     Note that action equip fail is an indirect check by testing
        --     whether your active slot is now empty or not.
        --     This is just to simplify making it consistent on client side.
        inst.components.talker:Say(GetActionFailString(inst, data.action.action.id, data.reason))
    end
end

local function OnWontEatFood(inst, data)
    if inst.components.talker ~= nil then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_EAT", "YUCKY"))
    end
end

--------------------------------------------------------------------------
--Temperamental events
--------------------------------------------------------------------------

local function OnStartedFire(inst, data)
    if data ~= nil and data.target ~= nil and data.target:HasTag("structure") and not data.target:HasTag("wildfireprotected") then
        inst.hasStartedFire = true
        inst.hasAttackedPlayer = nil
    end
end

--------------------------------------------------------------------------
--PVP events
--------------------------------------------------------------------------

local function OnAttackOther(inst, data)
    if data ~= nil and data.target ~= nil and data.target:HasTag("player") then
        inst.hasAttackedPlayer = true
    end
    if data.weapon then
        DropWetTool(inst, data)
    end
end

local function OnAreaAttackOther(inst, data)
    if data ~= nil and data.target ~= nil and data.target:HasTag("player") then
        inst.hasAttackedPlayer = true
    end
end

local function OnKilled(inst, data)
    if data ~= nil and data.victim ~= nil and data.victim:HasTag("player") then
        inst.hasKilledPlayer = true
        inst.hasRevivedPlayer = nil
    end
end

--------------------------------------------------------------------------
--Enlightenment events
--------------------------------------------------------------------------
fns.OnChangeArea = function(inst, area)
	local enable_lunacy = area ~= nil and area.tags and table.contains(area.tags, "lunacyarea")
	inst.components.sanity:EnableLunacy(enable_lunacy, "lunacyarea")
end

fns.OnAlterNight = function(inst)
	local enable_lunacy = TheWorld.state.isnight and TheWorld.state.isalterawake  
	inst.components.sanity:EnableLunacy(enable_lunacy, "alter_night")
end

fns.OnStormLevelChanged = function(inst, data)
	local in_moonstorm = data ~= nil and data.stormtype == STORM_TYPES.MOONSTORM and data.level > 0   
	inst.components.sanity:EnableLunacy(in_moonstorm, "moon_storm")
end

--------------------------------------------------------------------------
--Equipment Breaking Events
--------------------------------------------------------------------------

function fns.OnItemRanOut(inst, data)
    if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
        local sameTool = inst.components.inventory:FindItem(function(item)
            return item.prefab == data.prefab and
                item.components.equippable ~= nil and
                item.components.equippable.equipslot == data.equipslot
        end)
        if sameTool ~= nil then
            inst.components.inventory:Equip(sameTool)
        end
    end
end

function fns.OnUmbrellaRanOut(inst, data)
    if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
        local sameTool = inst.components.inventory:FindItem(function(item)
            return item:HasTag("umbrella") and
                item.components.equippable ~= nil and
                item.components.equippable.equipslot == data.equipslot
        end)
        if sameTool ~= nil then
            inst.components.inventory:Equip(sameTool)
        end
    end
end

function fns.ArmorBroke(inst, data)
    if data.armor ~= nil then
        local sameArmor = inst.components.inventory:FindItem(function(item)
            return item.prefab == data.armor.prefab
        end)
        if sameArmor ~= nil then
            inst.components.inventory:Equip(sameArmor)
        end
    end
end

--------------------------------------------------------------------------

local function RegisterActivePlayerEventListeners(inst)
    --HUD Audio events
    inst:ListenForEvent("gotnewitem", OnGotNewItem)
    inst:ListenForEvent("equip", OnEquip)
end

local function UnregisterActivePlayerEventListeners(inst)
    --HUD Audio events
    inst:RemoveEventCallback("gotnewitem", OnGotNewItem)
    inst:RemoveEventCallback("equip", OnEquip)
end

local function RegisterMasterEventListeners(inst)
    inst:ListenForEvent("itemranout", fns.OnItemRanOut)
    inst:ListenForEvent("umbrellaranout", fns.OnUmbrellaRanOut)
    inst:ListenForEvent("armorbroke", fns.ArmorBroke)

    --Audio events
    inst:ListenForEvent("picksomething", OnPickSomething)
    inst:ListenForEvent("dropitem", OnDropItem)

    --Speech events
    inst:ListenForEvent("actionfailed", OnActionFailed)
    inst:ListenForEvent("wonteatfood", OnWontEatFood)
    inst:ListenForEvent("working", DropWetTool)

    --Temperamental events
    inst:ListenForEvent("onstartedfire", OnStartedFire)

    --PVP events
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("onareaattackother", OnAreaAttackOther)
    inst:ListenForEvent("killed", OnKilled)

	--Cookbook events
    inst:ListenForEvent("learncookbookrecipe", ex_fns.OnLearnCookbookRecipe)
    inst:ListenForEvent("learncookbookstats", ex_fns.OnLearnCookbookStats)
    inst:ListenForEvent("oneat", ex_fns.OnEat)

    inst:ListenForEvent("learnplantstage", ex_fns.OnLearnPlantStage)
    inst:ListenForEvent("learnfertilizer", ex_fns.OnLearnFertilizer)
    inst:ListenForEvent("takeoversizedpicture", ex_fns.OnTakeOversizedPicture)

	-- Enlightenment events
	inst:ListenForEvent("changearea", fns.OnChangeArea)
	inst:ListenForEvent("stormlevel", fns.OnStormLevelChanged)
	inst:WatchWorldState("isnight", fns.OnAlterNight)
	inst:WatchWorldState("isalterawake", fns.OnAlterNight)
end

--------------------------------------------------------------------------
--Construction/Destruction helpers
--------------------------------------------------------------------------

local function AddActivePlayerComponents(inst)
    inst:AddComponent("hudindicatorwatcher")
    inst:AddComponent("playerhearing")
end

local function RemoveActivePlayerComponents(inst)
    inst:RemoveComponent("hudindicatorwatcher")
    inst:RemoveComponent("playerhearing")
end

local function ActivateHUD(inst)
    local hud = PlayerHud()
    TheFrontEnd:PushScreen(hud)
    if TheFrontEnd:GetFocusWidget() == nil then
        hud:SetFocus()
    end
    TheCamera:SetOnUpdateFn(not TheWorld:HasTag("cave") and function(camera)
        hud:UpdateClouds(camera)
        hud:UpdateDrops(camera)
    end or nil)
    hud:SetMainCharacter(inst)
end

local function DeactivateHUD(inst)
    TheCamera:SetOnUpdateFn(nil)
    TheFrontEnd:PopScreen(inst.HUD)
    inst.HUD = nil
end

local function ActivatePlayer(inst)
    inst.activatetask = nil

    TheWorld.minimap.MiniMap:DrawForgottenFogOfWar(true)
    if inst.player_classified ~= nil then
        inst.player_classified.MapExplorer:ActivateLocalMiniMap()

        if not (TheNet:GetIsHosting() or TheNet:GetServerFriendsOnly() or TheNet:GetServerLANOnly()) then
            AwardPlayerAchievement("join_game", ThePlayer)
        end
    end

    inst:PushEvent("playeractivated")
    TheWorld:PushEvent("playeractivated", inst)

    if inst == ThePlayer and not TheWorld.ismastersim then
        -- Clients save locally as soon as they spawn in, so it is
        -- easier to find the server to rejoin in case of a crash.
        SerializeUserSession(inst)
    end
end

local function DeactivatePlayer(inst)
    if inst.activatetask ~= nil then
        inst.activatetask:Cancel()
        inst.activatetask = nil
        return
    end

    if inst == ThePlayer and not TheWorld.ismastersim then
        -- For now, clients save their local minimap reveal cache
        -- and we need to trigger this here as well as on network
        -- disconnect.  On migration, we will hit this code first
        -- whereas normally we will hit the one in disconnection.
        SerializeUserSession(inst)
    end

    inst:PushEvent("playerdeactivated")
    TheWorld:PushEvent("playerdeactivated", inst)
end

--------------------------------------------------------------------------

local function OnPlayerJoined(inst)
    inst.jointask = nil

    -- "playerentered" is available on both server and client.
    -- - On clients, this is pushed whenever a player entity is added
    --   locally because it has come into range of your network view.
    -- - On servers, this message is identical to "ms_playerjoined", since
    --   players are always in network view range once they are connected.
    TheWorld:PushEvent("playerentered", inst)
    if TheWorld.ismastersim then
        TheWorld:PushEvent("ms_playerjoined", inst)
        --V2C: #spawn #despawn
        --     This was where we used to announce player joined.
        --     Now we announce as soon as you login to the lobby
        --     and not when you connect during shard migrations.
        --TheNet:Announce(string.format(STRINGS.UI.NOTIFICATION.JOINEDGAME, inst:GetDisplayName()), inst.entity, true, "join_game")

        --Register attuner server listeners here as "ms_playerjoined"
        --will trigger relinking saved attunements, and we don't want
        --to hit the callbacks to spawn fx for those
        inst:ListenForEvent("gotnewattunement", OnGotNewAttunement)
        inst:ListenForEvent("attunementlost", OnAttunementLost)
        inst._isrezattuned = inst.components.attuner:HasAttunement("remoteresurrector")
    end
end

local function OnCancelMovementPrediction(inst)
    inst.components.locomotor:Clear()
    inst:ClearBufferedAction()
    inst.sg:GoToState("idle", "cancel")
end

local function EnableMovementPrediction(inst, enable)
    if USE_MOVEMENT_PREDICTION and not TheWorld.ismastersim then
        inst:PushEvent("enablemovementprediction", enable)
        if enable then
            if inst.components.locomotor == nil then
                local isghost =
                    (inst.player_classified ~= nil and inst.player_classified.isghostmode:value()) or
                    (inst.player_classified == nil and inst:HasTag("playerghost"))

                inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
                if isghost then
                    ex_fns.ConfigureGhostLocomotor(inst)
                else
                    ex_fns.ConfigurePlayerLocomotor(inst)
                end

                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller.locomotor = inst.components.locomotor
                end

                inst:SetStateGraph(isghost and "SGwilsonghost_client" or "SGwilson_client")
                inst:ListenForEvent("cancelmovementprediction", OnCancelMovementPrediction)

                inst.entity:EnableMovementPrediction(true)
                print("Movement prediction enabled")
                inst.components.locomotor.is_prediction_enabled = true
                --This is unfortunate but it doesn't seem like you can send an rpc on the first
                --frame when a character is spawned
                inst:DoTaskInTime(0, function(inst)
                    SendRPCToServer(RPC.MovementPredictionEnabled)
                    end)
            end
        elseif inst.components.locomotor ~= nil then
            inst:RemoveEventCallback("cancelmovementprediction", OnCancelMovementPrediction)
            inst.entity:EnableMovementPrediction(false)
            inst:ClearBufferedAction()
            inst:ClearStateGraph()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller.locomotor = nil
            end
            inst:RemoveComponent("locomotor")
            print("Movement prediction disabled")
            --This is unfortunate but it doesn't seem like you can send an rpc on the first
            --frame when a character is spawned
            inst:DoTaskInTime(0, function(inst)
                SendRPCToServer(RPC.MovementPredictionDisabled)
                end)
        end
    end
end

function fns.EnableBoatCamera(inst, enable)
    inst:PushEvent("enableboatcamera", enable)
end

--Always on the bottom of the stack
local function PlayerActionFilter(inst, action)
    return not action.ghost_exclusive
end

local function SetGhostMode(inst, isghost)
    TheWorld:PushEvent("enabledynamicmusic", not isghost)
    inst.HUD.controls.status:SetGhostMode(isghost)
    inst.HUD.controls.secondary_status:SetGhostMode(isghost)
    if inst.components.revivablecorpse == nil then
        if isghost then
            TheMixer:PushMix("death")
        else
            TheMixer:PopMix("death")
        end
    end

    if inst.ghostenabled then
        if not TheWorld.ismastersim then
            if USE_MOVEMENT_PREDICTION then
                if inst.components.locomotor ~= nil then
                    inst:PushEvent("cancelmovementprediction")
                    if isghost then
                        ex_fns.ConfigureGhostLocomotor(inst)
                    else
                        ex_fns.ConfigurePlayerLocomotor(inst)
                    end
                end
                if inst.sg ~= nil then
                    inst:SetStateGraph(isghost and "SGwilsonghost_client" or "SGwilson_client")
                end
            end
            if isghost then
                ex_fns.ConfigureGhostActions(inst)
            else
                ex_fns.ConfigurePlayerActions(inst)
            end
        end
    end
end

local function OnSetOwner(inst)
    inst.name = inst.Network:GetClientName()
    inst.userid = inst.Network:GetUserID()
    inst.playercolour = inst.Network:GetPlayerColour()
    if TheWorld.ismastersim then
        TheNet:SetIsClientInWorld(inst.userid, true)
        inst.player_classified.Network:SetClassifiedTarget(inst)
    end

    if inst ~= nil and (inst == ThePlayer or TheWorld.ismastersim) then
        if inst.components.playercontroller == nil then
            EnableMovementPrediction(inst, Profile:GetMovementPredictionEnabled())
            fns.EnableBoatCamera(inst, Profile:IsBoatCameraEnabled())
            inst:AddComponent("playeractionpicker")
            inst:AddComponent("playercontroller")
            inst:AddComponent("playervoter")
            inst:AddComponent("playermetrics")
            inst.components.playeractionpicker:PushActionFilter(PlayerActionFilter, -99)
            TheWorld:ListenForEvent("serverpauseddirty", function() ex_fns.OnWorldPaused(inst) end)
            ex_fns.OnWorldPaused(inst)
        end
    elseif inst.components.playercontroller ~= nil then
        inst:RemoveComponent("playeractionpicker")
        inst:RemoveComponent("playercontroller")
        inst:RemoveComponent("playervoter")
        inst:RemoveComponent("playermetrics")
        DisableMovementPrediction(inst)
    end

    if inst == ThePlayer then
        if inst.HUD == nil then
            ActivateHUD(inst)
            AddActivePlayerComponents(inst)
            RegisterActivePlayerEventListeners(inst)
            inst.activatetask = inst:DoStaticTaskInTime(0, ActivatePlayer)

            if not ChatHistory:HasHistory() then
                ChatHistory:AddJoinMessageToHistory(
                    ChatTypes.Announcement,
                    nil,
                    string.format(STRINGS.UI.NOTIFICATION.JOINEDGAME, Networking_Announcement_GetDisplayName(inst.name)),
                    TheNet:GetClientTableForUser(inst.userid).colour or WHITE,
                    "join_game"
                )
            end
        end
    elseif inst.HUD ~= nil then
        UnregisterActivePlayerEventListeners(inst)
        RemoveActivePlayerComponents(inst)
        DeactivateHUD(inst)
        DeactivatePlayer(inst)
    end
end

local function AttachClassified(inst, classified)
    inst.player_classified = classified
    inst.ondetachclassified = function() inst:DetachClassified() end
    inst:ListenForEvent("onremove", inst.ondetachclassified, classified)
end

local function DetachClassified(inst)
    inst.player_classified = nil
    inst.ondetachclassified = nil
end

local function OnRemoveEntity(inst)
    if inst.jointask ~= nil then
        inst.jointask:Cancel()
    end

    if inst.player_classified ~= nil then
        if TheWorld.ismastersim then
            inst.player_classified:Remove()
            inst.player_classified = nil
            --No bit ops support, but in this case, + results in same as |
            inst.Network:RemoveUserFlag(
                USERFLAGS.CHARACTER_STATE_1 +
                USERFLAGS.CHARACTER_STATE_2 +
                USERFLAGS.CHARACTER_STATE_3 +
                (inst.ghostenabled and USERFLAGS.IS_GHOST or 0)
            )
        else
            inst.player_classified._parent = nil
            inst:RemoveEventCallback("onremove", inst.ondetachclassified, inst.player_classified)
            inst:DetachClassified()
        end
    end

    table.removearrayvalue(AllPlayers, inst)

    -- "playerexited" is available on both server and client.
    -- - On clients, this is pushed whenever a player entity is removed
    --   locally because it has gone out of range of your network view.
    -- - On servers, this message is identical to "ms_playerleft", since
    --   players are always in network view range until they disconnect.
    TheWorld:PushEvent("playerexited", inst)
    if TheWorld.ismastersim then
        TheWorld:PushEvent("ms_playerleft", inst)
        TheNet:SetIsClientInWorld(inst.userid, false)
    end

    if inst.HUD ~= nil then
        DeactivateHUD(inst)
    end

    if inst == ThePlayer then
        UnregisterActivePlayerEventListeners(inst)
        RemoveActivePlayerComponents(inst)
        DeactivatePlayer(inst)
    end
end

--------------------------------------------------------------------------
--Save/Load stuff
--------------------------------------------------------------------------
local function OnSave(inst, data)
    data.is_ghost = inst:HasTag("playerghost") or nil

    --Shard stuff
    data.migration = inst.migration

    --V2C: UNFORTUNATLEY, the sleeping hacks still need to be
    --     saved for snapshots or c_saves while sleeping
    if inst._sleepinghandsitem ~= nil then
        data.sleepinghandsitem = inst._sleepinghandsitem:GetSaveRecord()
    end
    if inst._sleepingactiveitem ~= nil then
        data.sleepingactiveitem = inst._sleepingactiveitem:GetSaveRecord()
    end
    --

    if inst.yotb_skins_sets then
        data.yotb_skins_sets = inst.yotb_skins_sets:value()
    end

    --Special case entities, since save references do not apply to networked players
    if inst.wormlight ~= nil then
        data.wormlight = inst.wormlight:GetSaveRecord()
    end

	if inst.last_death_position ~= nil then
		data.death_posx = inst.last_death_position.x
		data.death_posy = inst.last_death_position.y
		data.death_posz = inst.last_death_position.z
		data.death_shardid = inst.last_death_shardid
	end

	if IsConsole() then
		TheGameService:NotifyProgress("flush",inst.components.age:GetDisplayAgeInDays(), inst.userid)
		TheGameService:NotifyProgress("dayssaved",inst.components.age:GetDisplayAgeInDays(), inst.userid)
	end

    if inst._OnSave ~= nil then
        inst:_OnSave(data)
    end
end

local function OnPreLoad(inst, data)
    --Shard stuff
    inst.migration = data ~= nil and data.migration or nil
    inst.migrationpets = inst.migration ~= nil and {} or nil

    if inst._OnPreLoad ~= nil then
        inst:_OnPreLoad(data)
    end
end

local function OnLoad(inst, data)
    --If this character is being loaded then it isn't a new spawn
    inst.OnNewSpawn = nil
    inst._OnNewSpawn = nil
    inst.starting_inventory = nil
    if data ~= nil then
        if data.is_ghost then
			if data.death_posx ~= nil and data.death_posy ~= nil and data.death_posz ~= nil then
				inst.last_death_position = Vector3(data.death_posx, data.death_posy, data.death_posz)
				inst.last_death_shardid = data.death_shardid
			end

            ex_fns.OnMakePlayerGhost(inst, { loading = true })
        end

        --V2C: Sleeping hacks from snapshots or c_saves while sleeping
        if data.sleepinghandsitem ~= nil then
            local item = SpawnSaveRecord(data.sleepinghandsitem)
            if item ~= nil then
                inst.components.inventory.silentfull = true
                inst.components.inventory:Equip(item)
                inst.components.inventory.silentfull = false
            end
        end
        if data.sleepingactiveitem ~= nil then
            local item = SpawnSaveRecord(data.sleepingactiveitem)
            if item ~= nil then
                inst.components.inventory.silentfull = true
                inst.components.inventory:GiveItem(item)
                inst.components.inventory.silentfull = false
            end
        end
        --

        --Special case entities, since save references do not apply to networked players
        if data.wormlight ~= nil and inst.wormlight == nil then
            local wormlight = SpawnSaveRecord(data.wormlight)
            if wormlight ~= nil and wormlight.components.spell ~= nil then
                wormlight.components.spell:SetTarget(inst)
                if wormlight:IsValid() then
                    if wormlight.components.spell.target == nil then
                        wormlight:Remove()
                    else
                        wormlight.components.spell:ResumeSpell()
                    end
                end
            end
        end

        if data.yotb_skins_sets and IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
            inst.yotb_skins_sets:set(data.yotb_skins_sets)
        end
    end

	if IsConsole() then
		TheGameService:NotifyProgress("dayssaved",inst.components.age:GetDisplayAgeInDays(), inst.userid)
	end

    if inst._OnLoad ~= nil then
        inst:_OnLoad(data)
    end

    inst:DoTaskInTime(0, function()
        --V2C: HACK! enabled false instead of nil means it was overriden by weregoose on load.
        --     Please refactor drownable and this block to use POST LOAD timing instead.
        if inst.components.drownable ~= nil and inst.components.drownable.enabled ~= false then
            local my_x, my_y, my_z = inst.Transform:GetWorldPosition()

            if not TheWorld.Map:IsPassableAtPoint(my_x, my_y, my_z) then
            for k,v in pairs(Ents) do
                    if v:IsValid() and v:HasTag("multiplayer_portal") then
                        inst.Transform:SetPosition(v.Transform:GetWorldPosition())
                        inst:SnapCamera()
                    end
                end
            end
        end
    end)
end

--------------------------------------------------------------------------
--Sleep stuff (effect, not entity state)
--------------------------------------------------------------------------

--V2C: sleeping bag hacks
--     The gist of it is that when we sleep, we gotta temporarly unequip
--     our hand item so it doesn't drain fuel, and hide our active item
--     so that it doesn't show up on our cursor.  However, we do not want
--     anything to be dropped on the ground due to full inventory, and we
--     want everything restored silently to the same state when we wakeup.
local function OnSleepIn(inst)
    if inst._sleepinghandsitem ~= nil then
        --Should not get here...unless previously somehow got out of
        --sleeping state without properly going through wakeup state
        inst._sleepinghandsitem:Show()
        inst.components.inventory.silentfull = true
        inst.components.inventory:GiveItem(inst._sleepinghandsitem)
        inst.components.inventory.silentfull = false
    end
    if inst._sleepingactiveitem ~= nil then
        --Should not get here...unless previously somehow got out of
        --sleeping state without properly going through wakeup state
        inst.components.inventory.silentfull = true
        inst.components.inventory:GiveItem(inst._sleepingactiveitem)
        inst.components.inventory.silentfull = false
    end

    inst._sleepinghandsitem = inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
    if inst._sleepinghandsitem ~= nil then
        inst._sleepinghandsitem:Hide()
    end
    inst._sleepingactiveitem = inst.components.inventory:GetActiveItem()
    if inst._sleepingactiveitem ~= nil then
        inst.components.inventory:SetActiveItem(nil)
    end
end

--V2C: sleeping bag hacks
local function OnWakeUp(inst)
    if inst._sleepinghandsitem ~= nil then
        inst._sleepinghandsitem:Show()
        inst.components.inventory.silentfull = true
        inst.components.inventory:Equip(inst._sleepinghandsitem)
        inst.components.inventory.silentfull = false
        inst._sleepinghandsitem = nil
    end
    if inst._sleepingactiveitem ~= nil then
        inst.components.inventory.silentfull = true
        inst.components.inventory:GiveActiveItem(inst._sleepingactiveitem)
        inst.components.inventory.silentfull = false
        inst._sleepingactiveitem = nil
    end
end

--------------------------------------------------------------------------
--Spawing stuff
--------------------------------------------------------------------------

--Player cleanup usually called just before save/delete
--just before the the player entity is actually removed
local function OnDespawn(inst, migrationdata)
    if inst._OnDespawn ~= nil then
        inst:_OnDespawn(migrationdata)
    end

    --V2C: Unfortunately the sleeping bag code is incredibly garbage
    --     so we need all this extra cleanup to cover its edge cases
    if inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") then
        inst:ClearBufferedAction()
    end
    if inst.sleepingbag ~= nil then
        inst.sleepingbag.components.sleepingbag:DoWakeUp(true)
        inst.sleepingbag = nil
    end
    inst:OnWakeUp()
    --

    inst.components.debuffable:RemoveOnDespawn()
    inst.components.rider:ActualDismount()
    inst.components.bundler:StopBundling()
    inst.components.constructionbuilder:StopConstruction()

    if (GetGameModeProperty("drop_everything_on_despawn") or TUNING.DROP_EVERYTHING_ON_DESPAWN) and migrationdata == nil then
        inst.components.inventory:DropEverything()

		local followers = inst.components.leader.followers
		for k, v in pairs(followers) do
			if k.components.inventory ~= nil then
				k.components.inventory:DropEverything()
			elseif k.components.container ~= nil then
				k.components.container:DropEverything()
			end
		end
    else
        inst.components.inventory:DropEverythingWithTag("irreplaceable")
    end

    inst:PushEvent("player_despawn")

    inst.components.leader:HaveFollowersCachePlayerLeader()
    inst.components.leader:RemoveAllFollowers()

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    inst.components.locomotor:StopMoving()
    inst.components.locomotor:Clear()
end

--Will be triggered from SpawnNewPlayerOnServerFromSim
--only if it is a new spawn
local function OnNewSpawn(inst, starting_item_skins)
	ex_fns.GivePlayerStartingItems(inst, inst.starting_inventory, starting_item_skins)

	if TheWorld.components.playerspawner ~= nil and TheWorld.components.playerspawner:IsPlayersInitialSpawn(inst) then -- only give the late-starting assist on the very first time a player spawns (ie, not every time they respawn in Wilderness mode)
		local extra_starting_items = TUNING.EXTRA_STARTING_ITEMS[TheWorld.state.season]
		if extra_starting_items ~= nil and TheWorld.state.cycles >= TUNING.EXTRA_STARTING_ITEMS_MIN_DAYS then
			ex_fns.GivePlayerStartingItems(inst, extra_starting_items, starting_item_skins)
		end
		local seasonal_starting_items = TUNING.SEASONAL_STARTING_ITEMS[TheWorld.state.season]
		if seasonal_starting_items ~= nil and TheWorld.state.cycles > TheWorld.state.elapseddaysinseason then -- only if the world is not in the starting season.
			ex_fns.GivePlayerStartingItems(inst, seasonal_starting_items, starting_item_skins)
		end
	end

    if inst._OnNewSpawn ~= nil then
        inst:_OnNewSpawn()
        inst._OnNewSpawn = nil
    end
    inst.OnNewSpawn = nil
    inst.starting_inventory = nil
    TheWorld:PushEvent("ms_newplayerspawned", inst)
end

--------------------------------------------------------------------------
--Pet stuff
--------------------------------------------------------------------------

local function DoEffects(pet)
    SpawnPrefab(pet:HasTag("flying") and "spawn_fx_small_high" or "spawn_fx_small").Transform:SetPosition(pet.Transform:GetWorldPosition())
end

local function OnSpawnPet(inst, pet)
    --Delayed in case we need to relocate for migration spawning
    pet:DoTaskInTime(0, DoEffects)
    if pet.components.spawnfader ~= nil then
        pet.components.spawnfader:FadeIn()
    end
end

local function OnDespawnPet(inst, pet)
    DoEffects(pet)
    pet:Remove()
end

--------------------------------------------------------------------------
--HUD/Camera/FE interface
--------------------------------------------------------------------------

local function IsActionsVisible(inst)
    --V2C: This flag is a hack for hiding actions during sleep states
    --     since controls and HUD are technically not "disabled" then
    return inst.player_classified ~= nil and inst.player_classified.isactionsvisible:value()
end

local function IsHUDVisible(inst)
    return inst.player_classified.ishudvisible:value()
end

local function ShowActions(inst, show)
    if TheWorld.ismastersim then
        inst.player_classified:ShowActions(show)
    end
end

local function ShowHUD(inst, show)
    if TheWorld.ismastersim then
        inst.player_classified:ShowHUD(show)
    end
end

fns.ShowPopUp = function(inst, popup, show, ...)
    if TheWorld.ismastersim and inst.userid then
        SendRPCToClient(CLIENT_RPC.ShowPopup, inst.userid, popup.code, popup.mod_name, show, ...)
    end
end

local function SetCameraDistance(inst, distance)
    if TheWorld.ismastersim then
        inst.player_classified.cameradistance:set(distance or 0)
    end
end

local function SetCameraZoomed(inst, iszoomed)
    if TheWorld.ismastersim then
        inst.player_classified.iscamerazoomed:set(iszoomed)
    end
end

local function SnapCamera(inst, resetrot)
    if TheWorld.ismastersim then
        --Forces a netvar to be dirty regardless of value
        inst.player_classified.camerasnap:set_local(false)
        inst.player_classified.camerasnap:set(resetrot == true)
    end
end

local function ShakeCamera(inst, mode, duration, speed, scale, source_or_pt, maxDist)
    if source_or_pt ~= nil and maxDist ~= nil then
        local distSq = source_or_pt.entity ~= nil and inst:GetDistanceSqToInst(source_or_pt) or inst:GetDistanceSqToPoint(source_or_pt:Get())
        local k = math.max(0, math.min(1, distSq / (maxDist * maxDist)))
        scale = easing.outQuad(k, scale, -scale, 1)
    end

    --normalize for net_byte
    duration = math.floor((duration >= 16 and 16 or duration) * 16 + .5) - 1
    speed = math.floor((speed >= 1 and 1 or speed) * 256 + .5) - 1
    scale = math.floor((scale >= 8 and 8 or scale) * 32 + .5) - 1

    if scale > 0 and speed > 0 and duration > 0 then
        if TheWorld.ismastersim then
            --Forces a netvar to be dirty regardless of value
            inst.player_classified.camerashakemode:set_local(mode)
            inst.player_classified.camerashakemode:set(mode)
            --
            inst.player_classified.camerashaketime:set(duration)
            inst.player_classified.camerashakespeed:set(speed)
            inst.player_classified.camerashakescale:set(scale)
        end
        if inst.HUD ~= nil then
            TheCamera:Shake(
                mode,
                (duration + 1) / 16,
                (speed + 1) / 256,
                (scale + 1) / 32
            )
        end
    end
end

local function ScreenFade(inst, isfadein, time, iswhite)
    if TheWorld.ismastersim then
        --truncate to half of net_smallbyte, so we can include iswhite flag
        time = time ~= nil and math.min(31, math.floor(time * 10 + .5)) or 0
        inst.player_classified.fadetime:set(iswhite and time + 32 or time)
        inst.player_classified.isfadein:set(isfadein)
    end
end

local function ScreenFlash(inst, intensity)
    if TheWorld.ismastersim then
        --normalize for net_tinybyte
        intensity = math.floor((intensity >= 1 and 1 or intensity) * 8 + .5) - 1
        if intensity >= 0 then
            --Forces a netvar to be dirty regardless of value
            inst.player_classified.screenflash:set_local(intensity)
            inst.player_classified.screenflash:set(intensity)
            TheWorld:PushEvent("screenflash", (intensity + 1) / 8)
        end
    end
end

--------------------------------------------------------------------------

local function ApplyScale(inst, source, scale)
    if TheWorld.ismastersim and source ~= nil then
        if scale ~= 1 and scale ~= nil then
            if inst._scalesource == nil then
                inst._scalesource = { [source] = scale }
                inst.Transform:SetScale(scale, scale, scale)
            elseif inst._scalesource[source] ~= scale then
                inst._scalesource[source] = scale
                local scale = 1
                for k, v in pairs(inst._scalesource) do
                    scale = scale * v
                end
                inst.Transform:SetScale(scale, scale, scale)
            end
        elseif inst._scalesource ~= nil and inst._scalesource[source] ~= nil then
            inst._scalesource[source] = nil
            if next(inst._scalesource) == nil then
                inst._scalesource = nil
                inst.Transform:SetScale(1, 1, 1)
            else
                local scale = 1
                for k, v in pairs(inst._scalesource) do
                    scale = scale * v
                end
                inst.Transform:SetScale(scale, scale, scale)
            end
        end
    end
end

local function ApplyAnimScale(inst, source, scale)
    if TheWorld.ismastersim and source ~= nil then
        if scale ~= 1 and scale ~= nil then
            if inst._animscalesource == nil then
                inst._animscalesource = { [source] = scale }
                inst.AnimState:SetScale(scale, scale, scale)
            elseif inst._animscalesource[source] ~= scale then
                inst._animscalesource[source] = scale
                local scale = 1
                for k, v in pairs(inst._animscalesource) do
                    scale = scale * v
                end
                inst.AnimState:SetScale(scale, scale, scale)
            end
        elseif inst._animscalesource ~= nil and inst._animscalesource[source] ~= nil then
            inst._animscalesource[source] = nil
            if next(inst._animscalesource) == nil then
                inst._animscalesource = nil
                inst.AnimState:SetScale(1, 1, 1)
            else
                local scale = 1
                for k, v in pairs(inst._animscalesource) do
                    scale = scale * v
                end
                inst.AnimState:SetScale(scale, scale, scale)
            end
        end
    end
end

--------------------------------------------------------------------------
-- (NOTES)JBK: Used to apply overrides to skins for states on things like Wurt.
local function ApplySkinOverrides(inst)
    if inst.CustomSetSkinMode ~= nil then
        inst:CustomSetSkinMode(inst.overrideskinmode or "normal_skin", inst.overrideskinmodebuild)
    else
        inst.AnimState:SetBank("wilson")
        inst.components.skinner:SetSkinMode(inst.overrideskinmode or "normal_skin", inst.overrideskinmodebuild)
    end
end

--------------------------------------------------------------------------
--V2C: Used by multiplayer_portal_moon for saving certain character traits
--     when rerolling a new character.
local function SaveForReroll(inst)
    --NOTE: ignoring returned refs, should be ok
    local data =
    {
        age = inst.components.age ~= nil and inst.components.age:OnSave() or nil,
        builder = inst.components.builder ~= nil and inst.components.builder:OnSave() or nil,
        petleash = inst.components.petleash ~= nil and inst.components.petleash:OnSave() or nil,
        maps = inst.player_classified ~= nil and inst.player_classified.MapExplorer ~= nil and inst.player_classified.MapExplorer:RecordAllMaps() or nil,
    }
    return next(data) ~= nil and data or nil
end

local function LoadForReroll(inst, data)
    if data.age ~= nil and inst.components.age ~= nil then
        inst.components.age:OnLoad(data.age)
    end
    if data.builder ~= nil and inst.components.builder ~= nil then
        inst.components.builder:OnLoad(data.builder)
    end
    if data.petleash ~= nil and inst.components.petleash ~= nil then
        inst.components.petleash:OnLoad(data.petleash)
    end
    if data.maps ~= nil and inst.player_classified ~= nil and inst.player_classified.MapExplorer ~= nil then
        inst.player_classified.MapExplorer:LearnAllMaps(data.maps)
    end
end

local function OnWintersFeastMusic(inst)
    if ThePlayer ~= nil and  ThePlayer == inst then
        ThePlayer:PushEvent("isfeasting")
    end
end

local function OnHermitMusic(inst)
    if ThePlayer ~= nil and  ThePlayer == inst then
        ThePlayer:PushEvent("playhermitmusic")
    end
end

local function OnSharkSound(inst)
    if ThePlayer ~= nil and  ThePlayer == inst then
        if inst._sharksoundparam:value() <= 1 then
            if not TheFocalPoint.SoundEmitter:PlayingSound("shark") then
                TheFocalPoint.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/swim_LP" ,"shark")
            end
            TheFocalPoint.SoundEmitter:SetParameter("shark", "distance", inst._sharksoundparam:value())
        else
            TheFocalPoint.SoundEmitter:KillSound("shark")
        end
    end
end

--------------------------------------------------------------------------

--V2C: starting_inventory passed as a parameter here is now deprecated
--     set .starting_inventory property during master_postinit instead
local function MakePlayerCharacter(name, customprefabs, customassets, common_postinit, master_postinit, starting_inventory)
    local assets =
    {
        Asset("ANIM", "anim/player_basic.zip"),
        Asset("ANIM", "anim/player_idles_shiver.zip"),
        Asset("ANIM", "anim/player_idles_lunacy.zip"),
        Asset("ANIM", "anim/player_actions.zip"),
        Asset("ANIM", "anim/player_actions_axe.zip"),
        Asset("ANIM", "anim/player_actions_pickaxe.zip"),
        Asset("ANIM", "anim/player_actions_shovel.zip"),
        Asset("ANIM", "anim/player_actions_blowdart.zip"),
        Asset("ANIM", "anim/player_actions_slingshot.zip"),
        Asset("ANIM", "anim/player_actions_eat.zip"),

        Asset("ANIM", "anim/player_actions_item.zip"),
        Asset("ANIM", "anim/player_cave_enter.zip"),
        Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
        Asset("ANIM", "anim/player_actions_useitem.zip"),
        Asset("ANIM", "anim/player_actions_bugnet.zip"),
        Asset("ANIM", "anim/player_actions_unsaddle.zip"),
        Asset("ANIM", "anim/player_actions_fishing.zip"),
        Asset("ANIM", "anim/player_actions_fishing_ocean.zip"),
        Asset("ANIM", "anim/player_actions_fishing_ocean_new.zip"),
        Asset("ANIM", "anim/player_actions_pocket_scale.zip"),
        Asset("ANIM", "anim/player_actions_boomerang.zip"),
        Asset("ANIM", "anim/player_actions_whip.zip"),
        Asset("ANIM", "anim/player_actions_till.zip"),
        Asset("ANIM", "anim/player_actions_feast_eat.zip"),
        Asset("ANIM", "anim/player_actions_farming.zip"),
        Asset("ANIM", "anim/player_actions_cowbell.zip"),
        Asset("ANIM", "anim/player_actions_reversedeath.zip"),

        Asset("ANIM", "anim/player_boat.zip"),
        Asset("ANIM", "anim/player_boat_plank.zip"),
        Asset("ANIM", "anim/player_oar.zip"),
        Asset("ANIM", "anim/player_boat_hook.zip"),
        Asset("ANIM", "anim/player_boat_net.zip"),
        Asset("ANIM", "anim/player_boat_sink.zip"),
        Asset("ANIM", "anim/player_boat_jump.zip"),

        Asset("ANIM", "anim/player_boat_jumpheavy.zip"),
        Asset("ANIM", "anim/player_boat_channel.zip"),
        Asset("ANIM", "anim/player_bush_hat.zip"),
        Asset("ANIM", "anim/player_attacks.zip"),
        --Asset("ANIM", "anim/player_idles.zip"),--Moved to global.lua for use in Item Collection
        Asset("ANIM", "anim/player_rebirth.zip"),
        Asset("ANIM", "anim/player_jump.zip"),
        Asset("ANIM", "anim/player_amulet_resurrect.zip"),
        Asset("ANIM", "anim/player_teleport.zip"),
        Asset("ANIM", "anim/wilson_fx.zip"),
        Asset("ANIM", "anim/player_one_man_band.zip"),

        Asset("ANIM", "anim/player_slurtle_armor.zip"),
        Asset("ANIM", "anim/player_staff.zip"),
        Asset("ANIM", "anim/player_cointoss.zip"),
        Asset("ANIM", "anim/player_spooked.zip"),
        Asset("ANIM", "anim/player_hit_darkness.zip"),
        Asset("ANIM", "anim/player_hit_spike.zip"),
        Asset("ANIM", "anim/player_lunge.zip"),
        Asset("ANIM", "anim/player_multithrust.zip"),
        Asset("ANIM", "anim/player_superjump.zip"),
        Asset("ANIM", "anim/player_attack_leap.zip"),
        Asset("ANIM", "anim/player_book_attack.zip"),
        Asset("ANIM", "anim/player_pocketwatch_portal.zip"),

        Asset("ANIM", "anim/player_parryblock.zip"),
        Asset("ANIM", "anim/player_attack_prop.zip"),
        Asset("ANIM", "anim/player_actions_reading.zip"),
        Asset("ANIM", "anim/player_strum.zip"),
        Asset("ANIM", "anim/player_frozen.zip"),
        Asset("ANIM", "anim/player_shock.zip"),
        Asset("ANIM", "anim/player_tornado.zip"),
        Asset("ANIM", "anim/goo.zip"),
        Asset("ANIM", "anim/shadow_hands.zip"),
        Asset("ANIM", "anim/player_wrap_bundle.zip"),
        Asset("ANIM", "anim/player_hideseek.zip"),

        Asset("ANIM", "anim/player_wardrobe.zip"),
        Asset("ANIM", "anim/player_skin_change.zip"),
        Asset("ANIM", "anim/player_receive_gift.zip"),
        Asset("ANIM", "anim/shadow_skinchangefx.zip"),
        Asset("ANIM", "anim/player_townportal.zip"),
        Asset("ANIM", "anim/player_channel.zip"),
        Asset("ANIM", "anim/player_construct.zip"),
        Asset("SOUND", "sound/sfx.fsb"),
        Asset("SOUND", "sound/wilson.fsb"),
        --Asset("ANIM", "anim/player_ghost_withhat.zip"),--Moved to global.lua for use in Item Collection
        Asset("ANIM", "anim/player_revive_ghosthat.zip"),

        Asset("ANIM", "anim/player_revive_to_character.zip"),
        Asset("ANIM", "anim/player_revive_from_corpse.zip"),
        Asset("ANIM", "anim/player_knockedout.zip"),
        Asset("ANIM", "anim/player_emotesxl.zip"),
        Asset("ANIM", "anim/player_emotes_dance0.zip"),
        Asset("ANIM", "anim/player_emotes_sit.zip"),
        Asset("ANIM", "anim/player_emotes.zip"), -- item emotes
        Asset("ANIM", "anim/player_emote_extra.zip"), -- item emotes
        Asset("ANIM", "anim/player_emotes_dance2.zip"), -- item emotes
        Asset("ANIM", "anim/player_mount_emotes_extra.zip"), -- item emotes

        Asset("ANIM", "anim/player_mount_emotes_dance2.zip"), -- item emotes
        Asset("ANIM", "anim/player_mount_pet.zip"),
        Asset("ANIM", "anim/player_hatdance.zip"),
        Asset("ANIM", "anim/player_bow.zip"),
        Asset("ANIM", "anim/tears.zip"),
        Asset("ANIM", "anim/puff_spawning.zip"),
        Asset("ANIM", "anim/attune_fx.zip"),
        Asset("ANIM", "anim/player_idles_groggy.zip"),
        Asset("ANIM", "anim/player_groggy.zip"),
        Asset("ANIM", "anim/player_encumbered.zip"),
        Asset("ANIM", "anim/player_encumbered_fast.zip"),
        Asset("ANIM", "anim/player_encumbered_jump.zip"),

        Asset("ANIM", "anim/player_sandstorm.zip"),
        Asset("ANIM", "anim/player_tiptoe.zip"),
        Asset("IMAGE", "images/colour_cubes/ghost_cc.tex"),
        Asset("IMAGE", "images/colour_cubes/mole_vision_on_cc.tex"),
        Asset("IMAGE", "images/colour_cubes/mole_vision_off_cc.tex"),
        Asset("ANIM", "anim/player_mount.zip"),
        Asset("ANIM", "anim/player_mount_travel.zip"),
        Asset("ANIM", "anim/player_mount_actions.zip"),
        Asset("ANIM", "anim/player_mount_actions_item.zip"),
        Asset("ANIM", "anim/player_mount_actions_reading.zip"),
        Asset("ANIM", "anim/player_mount_unique_actions.zip"),
        Asset("ANIM", "anim/player_mount_actions_useitem.zip"),
        Asset("ANIM", "anim/player_mount_one_man_band.zip"),
        Asset("ANIM", "anim/player_mount_boat_jump.zip"),
        Asset("ANIM", "anim/player_mount_boat_sink.zip"),
        Asset("ANIM", "anim/player_mount_blowdart.zip"),
        Asset("ANIM", "anim/player_mount_slingshot.zip"),
        Asset("ANIM", "anim/player_mount_shock.zip"),
        Asset("ANIM", "anim/player_mount_frozen.zip"),
        Asset("ANIM", "anim/player_mount_groggy.zip"),
        Asset("ANIM", "anim/player_mount_encumbered.zip"),

        Asset("ANIM", "anim/player_mount_sandstorm.zip"),
        Asset("ANIM", "anim/player_mount_hit_darkness.zip"),
        Asset("ANIM", "anim/player_mount_emotes.zip"),
        Asset("ANIM", "anim/player_mount_emotes_dance0.zip"),
        Asset("ANIM", "anim/player_mount_emotesxl.zip"),
        Asset("ANIM", "anim/player_mount_emotes_sit.zip"),
        Asset("ANIM", "anim/player_mount_bow.zip"),
        Asset("ANIM", "anim/player_mount_cointoss.zip"),
        Asset("ANIM", "anim/player_mount_hornblow.zip"),
        Asset("ANIM", "anim/player_mount_strum.zip"),

        Asset("ANIM", "anim/player_mighty_gym.zip"),
        Asset("ANIM", "anim/mighty_gym.zip"),        

        Asset("INV_IMAGE", "skull_"..name),

        Asset("SCRIPT", "scripts/prefabs/player_common_extensions.lua"),
    }

    local prefabs =
    {
        "brokentool",
        "frostbreath",
        "mining_fx",
        "mining_ice_fx",
        "mining_moonglass_fx",
        "die_fx",
        "ghost_transform_overlay_fx",
        "attune_out_fx",
        "attune_in_fx",
        "attune_ghost_in_fx",
        "staff_castinglight",
		"staff_castinglight_small",
        "staffcastfx",
        "staffcastfx_mount",
        "book_fx",
        "book_fx_mount",
        "emote_fx",
        "tears",
        "shock_fx",
        "splash",
        "globalmapicon",
        "lavaarena_player_revive_from_corpse_fx",
        "superjump_fx",
		"washashore_puddle_fx",
		"spawnprotectionbuff",
        "battreefx",

        -- Player specific classified prefabs
        "player_classified",
        "inventory_classified",
    }

    if starting_inventory ~= nil or customprefabs ~= nil then
        local prefabs_cache = {}
        for i, v in ipairs(prefabs) do
            prefabs_cache[v] = true
        end

        if starting_inventory ~= nil then
            for i, v in ipairs(starting_inventory) do
                if not prefabs_cache[v] then
                    table.insert(prefabs, v)
                    prefabs_cache[v] = true
                end
            end
        end

        if customprefabs ~= nil then
            for i, v in ipairs(customprefabs) do
                if not prefabs_cache[v] then
                    table.insert(prefabs, v)
                    prefabs_cache[v] = true
                end
            end
        end
    end

    if customassets ~= nil then
        for i, v in ipairs(customassets) do
            table.insert(assets, v)
        end
    end

	local function SetInstanceFunctions(inst)
		-- we're bumping against the limit of upvalues in a lua function so work around by breaking this assignment out into its own function
        inst.AttachClassified = AttachClassified
        inst.DetachClassified = DetachClassified
        inst.OnRemoveEntity = OnRemoveEntity
        inst.CanExamine = nil -- Can be overridden; Needs to be on client as well for actions
        inst.ActionStringOverride = nil -- Can be overridden; Needs to be on client as well for actions
        inst.CanUseTouchStone = CanUseTouchStone -- Didn't want to make touchstonetracker a networked component
        inst.GetTemperature = GetTemperature -- Didn't want to make temperature a networked component
        inst.IsFreezing = IsFreezing -- Didn't want to make temperature a networked component
        inst.IsOverheating = IsOverheating -- Didn't want to make temperature a networked component
        inst.GetMoisture = GetMoisture -- Didn't want to make moisture a networked component
        inst.GetMaxMoisture = GetMaxMoisture -- Didn't want to make moisture a networked component
        inst.GetMoistureRateScale = GetMoistureRateScale -- Didn't want to make moisture a networked component
        inst.GetStormLevel = GetStormLevel -- Didn't want to make stormwatcher a networked component
        inst.IsCarefulWalking = IsCarefulWalking -- Didn't want to make carefulwalking a networked component
        inst.EnableMovementPrediction = EnableMovementPrediction
        inst.EnableBoatCamera = fns.EnableBoatCamera
        inst.ShakeCamera = ShakeCamera
        inst.SetGhostMode = SetGhostMode
        inst.IsActionsVisible = IsActionsVisible
	end

    local max_range = TUNING.MAX_INDICATOR_RANGE * 1.5

    local function ShouldTrackfn(inst, viewer)
        return  inst:IsValid() and
                not inst:HasTag("noplayerindicator") and
                not inst:HasTag("hiding") and
                inst:IsNear(inst, max_range) and
                not inst.entity:FrustumCheck() and
                CanEntitySeeTarget(viewer, inst)
    end

    local function OnUnderLeafCanopy(inst)
        
    end

    local function OnChangeCanopyZone(inst, underleaves)
        inst._underleafcanopy:set(underleaves)
    end

    local function fn()
        local inst = CreateEntity()

        table.insert(AllPlayers, inst)

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()
        inst.entity:AddLightWatcher()
        inst.entity:AddNetwork()

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("wilson")
        --We don't need to set the build because we'll rely on the skinner component to set the appropriate build/skin
        --V2C: turns out we do need to set the build for debug spawn
        if IsRestrictedCharacter(name) then
            --Peter: We can't set the standard build on a restricted character until after full spawning occurs and then the spinner will handle it, but we still want to give it a default build for cases vito's debug c_spawn cases
            inst.AnimState:SetBuild("wilson")
        else
            inst.AnimState:SetBuild(name)
        end
        inst.AnimState:PlayAnimation("idle")

        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Hide("HAT")
        inst.AnimState:Hide("HAIR_HAT")
        inst.AnimState:Show("HAIR_NOHAT")
        inst.AnimState:Show("HAIR")
        inst.AnimState:Show("HEAD")
        inst.AnimState:Hide("HEAD_HAT")

        inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
        inst.AnimState:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
        inst.AnimState:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
        inst.AnimState:OverrideSymbol("snap_fx", "player_actions_fishing_ocean_new", "snap_fx")

        --Additional effects symbols for hit_darkness animation
        inst.AnimState:AddOverrideBuild("player_hit_darkness")
        inst.AnimState:AddOverrideBuild("player_receive_gift")
        inst.AnimState:AddOverrideBuild("player_actions_uniqueitem")
        inst.AnimState:AddOverrideBuild("player_wrap_bundle")
        inst.AnimState:AddOverrideBuild("player_lunge")
        inst.AnimState:AddOverrideBuild("player_attack_leap")
        inst.AnimState:AddOverrideBuild("player_superjump")
        inst.AnimState:AddOverrideBuild("player_multithrust")
        inst.AnimState:AddOverrideBuild("player_parryblock")
        inst.AnimState:AddOverrideBuild("player_emote_extra")
        inst.AnimState:AddOverrideBuild("player_boat_plank")
        inst.AnimState:AddOverrideBuild("player_boat_net")
        inst.AnimState:AddOverrideBuild("player_boat_sink")
        inst.AnimState:AddOverrideBuild("player_oar")

        inst.AnimState:AddOverrideBuild("player_actions_fishing_ocean_new")
        inst.AnimState:AddOverrideBuild("player_actions_farming")
        inst.AnimState:AddOverrideBuild("player_actions_cowbell")


        inst.DynamicShadow:SetSize(1.3, .6)

        inst.MiniMapEntity:SetIcon(name..".png")
        inst.MiniMapEntity:SetPriority(10)
        inst.MiniMapEntity:SetCanUseCache(false)
        inst.MiniMapEntity:SetDrawOverFogOfWar(true)

        --Default to electrocute light values
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(.5)
        inst.Light:SetFalloff(.65)
        inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
        inst.Light:Enable(false)

        inst.LightWatcher:SetLightThresh(.075)
        inst.LightWatcher:SetMinLightThresh(0.61) --for sanity.
        inst.LightWatcher:SetDarkThresh(.05)

        MakeCharacterPhysics(inst, 75, .5)

        inst:AddTag("player")
        inst:AddTag("scarytoprey")
        inst:AddTag("character")
        inst:AddTag("lightningtarget")
        inst:AddTag(UPGRADETYPES.WATERPLANT.."_upgradeuser")
        inst:AddTag(UPGRADETYPES.MAST.."_upgradeuser")
        inst:AddTag("usesvegetarianequipment")

		SetInstanceFunctions(inst)

        inst.foleysound = nil --Characters may override this in common_postinit
        inst.playercolour = DEFAULT_PLAYER_COLOUR --Default player colour used in case it doesn't get set properly
        inst.ghostenabled = GetGhostEnabled(TheNet:GetServerGameMode())

        if GetGameModeProperty("revivable_corpse") then
            inst:AddComponent("revivablecorpse")
        end

        if GetGameModeProperty("spectator_corpse") then
            inst:AddComponent("spectatorcorpse")
        end

        inst.jointask = inst:DoTaskInTime(0, OnPlayerJoined)
        inst:ListenForEvent("setowner", OnSetOwner)

        inst:AddComponent("talker")
        inst.components.talker:SetOffsetFn(GetTalkerOffset)

        inst:AddComponent("frostybreather")
        inst.components.frostybreather:SetOffsetFn(GetFrostyBreatherOffset)

        inst:AddComponent("playervision")
        inst:AddComponent("areaaware")
        inst.components.areaaware:SetUpdateDist(.45)

        inst:AddComponent("attuner")
        --attuner server listeners are not registered until after "ms_playerjoined" has been pushed

        inst:AddComponent("playeravatardata")
        inst:AddComponent("constructionbuilderuidata")

        inst:AddComponent("inkable")

        inst:AddComponent("cookbookupdater")
        inst:AddComponent("plantregistryupdater")

        inst:AddComponent("walkableplatformplayer")

		if TheNet:GetServerGameMode() == "lavaarena" then
            inst:AddComponent("healthsyncer")
        end

		inst.isplayer = true

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        --trader (from trader component) added to pristine state for optimization
        inst:AddTag("trader")

        --debuffable (from debuffable component) added to pristine state for optimization
        inst:AddTag("debuffable")

        --Sneak these into pristine state for optimization
        inst:AddTag("_health")
        inst:AddTag("_hunger")
        inst:AddTag("_sanity")
        inst:AddTag("_builder")
        inst:AddTag("_combat")
        inst:AddTag("_moisture")
        inst:AddTag("_sheltered")
        inst:AddTag("_rider")

        inst.userid = ""

        inst:AddComponent("embarker")
        inst.components.embarker.embark_speed = TUNING.WILSON_RUN_SPEED

        inst._sharksoundparam = net_float(inst.GUID, "localplayer._sharksoundparam","sharksounddirty")
        inst._winters_feast_music = net_event(inst.GUID, "localplayer._winters_feast_music")
        inst._hermit_music = net_event(inst.GUID, "localplayer._hermit_music")
        inst._underleafcanopy = net_bool(inst.GUID, "localplayer._underleafcanopy","underleafcanopydirty")

        if IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
            inst.yotb_skins_sets = net_shortint(inst.GUID, "player.yotb_skins_sets")
            inst:DoTaskInTime(0,fns.YOTB_getrandomset)
        end

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("localplayer._winters_feast_music", OnWintersFeastMusic)
            inst:ListenForEvent("localplayer._hermit_music", OnHermitMusic)

            inst:AddComponent("hudindicatable")
            inst.components.hudindicatable:SetShouldTrackFunction(ShouldTrackfn)
        end

        inst:ListenForEvent("sharksounddirty", OnSharkSound)  
        inst:ListenForEvent("underleafcanopydirty", OnUnderLeafCanopy)        

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false --handled in a special way

        --Remove these tags so that they can be added properly when replicating components below
        inst:RemoveTag("_health")
        inst:RemoveTag("_hunger")
        inst:RemoveTag("_sanity")
        inst:RemoveTag("_builder")
        inst:RemoveTag("_combat")
        inst:RemoveTag("_moisture")
        inst:RemoveTag("_sheltered")
        inst:RemoveTag("_rider")

        -- Setting this here in case some component wants to modify skins.
        inst.ApplySkinOverrides = ApplySkinOverrides

        --No bit ops support, but in this case, + results in same as |
        inst.Network:RemoveUserFlag(
            USERFLAGS.CHARACTER_STATE_1 +
            USERFLAGS.CHARACTER_STATE_2 +
            USERFLAGS.CHARACTER_STATE_3 +
            (inst.ghostenabled and USERFLAGS.IS_GHOST or 0)
        )

        inst.player_classified = SpawnPrefab("player_classified")
        inst.player_classified.entity:SetParent(inst.entity)

        inst:ListenForEvent("death", ex_fns.OnPlayerDeath)
        if inst.ghostenabled then
            --Ghost events (Edit stategraph to push makeplayerghost instead of makeplayerdead to enter ghost state)
            inst:ListenForEvent("makeplayerghost", ex_fns.OnMakePlayerGhost)
            inst:ListenForEvent("respawnfromghost", ex_fns.OnRespawnFromGhost)
            inst:ListenForEvent("ghostdissipated", ex_fns.OnPlayerDied)
        elseif inst.components.revivablecorpse ~= nil then
            inst:ListenForEvent("respawnfromcorpse", ex_fns.OnRespawnFromPlayerCorpse)
            inst:ListenForEvent("playerdied", ex_fns.OnMakePlayerCorpse)
        else
            inst:ListenForEvent("playerdied", ex_fns.OnPlayerDied)
        end

        inst:AddComponent("bloomer")
        inst:AddComponent("colouradder")
        inst:AddComponent("birdattractor")

        inst:AddComponent("maprevealable")
        inst.components.maprevealable:SetIconPriority(10)

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        ex_fns.ConfigurePlayerLocomotor(inst)


        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
        inst.components.combat.GetGiveUpString = giveupstring
        inst.components.combat.GetBattleCryString = battlecrystring
        inst.components.combat.hiteffectsymbol = "torso"
        inst.components.combat.pvp_damagemod = TUNING.PVP_DAMAGE_MOD -- players shouldn't hurt other players very much
        inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
        inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)

        local gamemode = TheNet:GetServerGameMode()
        if gamemode == "lavaarena" then
            event_server_data("lavaarena", "prefabs/player_common").master_postinit(inst)
        elseif gamemode == "quagmire" then
            event_server_data("quagmire", "prefabs/player_common").master_postinit(inst)
        end

        MakeMediumBurnableCharacter(inst, "torso")
        inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
        inst.components.burnable.nocharring = true

        MakeLargeFreezableCharacter(inst, "torso")
        inst.components.freezable:SetResistance(4)
        inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

        inst:AddComponent("inventory")
        --players handle inventory dropping manually in their stategraph
        inst.components.inventory:DisableDropOnDeath()

        inst:AddComponent("bundler")
        inst:AddComponent("constructionbuilder")

        -- Player labeling stuff
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus
        inst.components.inspectable.getspecialdescription = GetDescription

        -- Player avatar popup inspection
        inst:AddComponent("playerinspectable")

        inst:AddComponent("temperature")
        inst.components.temperature.usespawnlight = true
        if GetGameModeProperty("no_temperature") then
            inst.components.temperature:SetTemp(TUNING.STARTING_TEMP)
        end

        inst:AddComponent("moisture")
        inst:AddComponent("sheltered")
        inst:AddComponent("stormwatcher")
        inst:AddComponent("sandstormwatcher")
        inst:AddComponent("moonstormwatcher")
        inst:AddComponent("carefulwalker")

        if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
            inst:AddComponent("spooked")
            inst:ListenForEvent("spooked", ex_fns.OnSpooked)
        end
		if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
            inst:AddComponent("wintertreegiftable")
		end

        -------

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH)
        inst.components.health.nofadeout = true

        inst:AddComponent("hunger")
        inst.components.hunger:SetMax(TUNING.WILSON_HUNGER)
        inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
        inst.components.hunger:SetKillRate(TUNING.WILSON_HEALTH / TUNING.STARVE_KILL_TIME)
        if GetGameModeProperty("no_hunger") then
            inst.components.hunger:Pause()
        end

        inst:AddComponent("sanity")
        inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
        inst.components.sanity.ignore = GetGameModeProperty("no_sanity")

        inst:AddComponent("builder")

        -------

        inst:AddComponent("wisecracker")
        inst:AddComponent("distancetracker")

        inst:AddComponent("catcher")

        inst:AddComponent("playerlightningtarget")

        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(ShouldAcceptItem)
        inst.components.trader.onaccept = OnGetItem
        inst.components.trader.deleteitemonaccept = false

        -------

        if not GetGameModeProperty("no_eating") then
            inst:AddComponent("eater")
        end
	    inst:AddComponent("foodaffinity")

        inst:AddComponent("leader")
        inst:AddComponent("age")
        inst:AddComponent("rider")

        inst:AddComponent("petleash")
        inst.components.petleash:SetMaxPets(1)
        inst.components.petleash:SetOnSpawnFn(OnSpawnPet)
        inst.components.petleash:SetOnDespawnFn(OnDespawnPet)

        inst:AddComponent("grue")
        inst.components.grue:SetSounds("dontstarve/charlie/warn","dontstarve/charlie/attack")

        inst:AddComponent("pinnable")
        inst:AddComponent("debuffable")
        inst.components.debuffable:SetFollowSymbol("headbase", 0, -200, 0)

        inst:AddComponent("workmultiplier")

        inst:AddComponent("grogginess")
        inst.components.grogginess:SetResistance(3)
        inst.components.grogginess:SetKnockOutTest(ex_fns.ShouldKnockout)

        inst:AddComponent("sleepingbaguser")

        inst:AddComponent("colourtweener")
        inst:AddComponent("touchstonetracker")

        inst:AddComponent("skinner")

        if not GetGameModeProperty("hide_received_gifts") then
            inst:AddComponent("giftreceiver")
        end

		if TheWorld.has_ocean then
	        inst:AddComponent("drownable")
		end

        inst:AddComponent("steeringwheeluser")
		inst:AddComponent("walkingplankuser")

		inst:AddComponent("singingshelltrigger")
        inst.components.singingshelltrigger.trigger_range = TUNING.SINGINGSHELL_TRIGGER_RANGE

        inst:AddComponent("timer")

        inst:AddInherentAction(ACTIONS.PICK)
        inst:AddInherentAction(ACTIONS.SLEEPIN)
        inst:AddInherentAction(ACTIONS.CHANGEIN)

        inst:SetStateGraph("SGwilson")

        RegisterMasterEventListeners(inst)

        --HUD interface
        inst.IsHUDVisible = IsHUDVisible
        inst.ShowActions = ShowActions
        inst.ShowHUD = ShowHUD
        inst.ShowPopUp = fns.ShowPopUp
        inst.SetCameraDistance = SetCameraDistance
        inst.SetCameraZoomed = SetCameraZoomed
        inst.SnapCamera = SnapCamera
        inst.ScreenFade = ScreenFade
        inst.ScreenFlash = ScreenFlash
        inst.YOTB_unlockskinset = fns.YOTB_unlockskinset
        inst.YOTB_issetunlocked = fns.YOTB_issetunlocked
        inst.YOTB_isskinunlocked = fns.YOTB_isskinunlocked

        inst.IsNearDanger = fns.IsNearDanger
        inst.SetGymStartState = fns.SetGymStartState
        inst.SetGymStopState = fns.SetGymStopState

        --Other
        inst._scalesource = nil
        inst.ApplyScale = ApplyScale
		inst.ApplyAnimScale = ApplyAnimScale	-- use this one if you don't want to have thier speed increased

        if inst.starting_inventory == nil then
            inst.starting_inventory = starting_inventory
        end

		inst.skeleton_prefab = "skeleton_player"

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        --V2C: sleeping bag hacks
        inst.OnSleepIn = OnSleepIn
        inst.OnWakeUp = OnWakeUp

        inst._OnSave = inst.OnSave
        inst._OnPreLoad = inst.OnPreLoad
        inst._OnLoad = inst.OnLoad
        inst._OnNewSpawn = inst.OnNewSpawn
        inst._OnDespawn = inst.OnDespawn
        inst.OnSave = OnSave
        inst.OnPreLoad = OnPreLoad
        inst.OnLoad = OnLoad
        inst.OnNewSpawn = OnNewSpawn
        inst.OnDespawn = OnDespawn

		fns.OnAlterNight(inst)

        --V2C: used by multiplayer_portal_moon
        inst.SaveForReroll = SaveForReroll
        inst.LoadForReroll = LoadForReroll

        inst:ListenForEvent("startfiredamage", OnStartFireDamage)
        inst:ListenForEvent("stopfiredamage", OnStopFireDamage)
        inst:ListenForEvent("burnt", OnBurntHands)
        inst:ListenForEvent("onchangecanopyzone", OnChangeCanopyZone)
--[[
        inst:ListenForEvent("stormlevel", function(owner, data)
            if data.stormtype == STORM_TYPES.MOONSTORM and data.level > 0 then
                print("5")
                TheWorld.components.moonstormlightningmanager.sparks_per_sec_mod = 0.1
            else
                print("1")
                TheWorld.components.moonstormlightningmanager.sparks_per_sec_mod = 1.0
            end
        end)
]]
        TheWorld:PushEvent("ms_playerspawn", inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakePlayerCharacter
