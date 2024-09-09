--------------------------------------------------------------------------
-- This file exists because player_common got too big for lua.
-- It had too may local variables and functions.
--------------------------------------------------------------------------

local screen_fade_time = .4

--------------------------------------------------------------------------
-- Component Callback Functions
--------------------------------------------------------------------------

local function ShouldKnockout(inst)
    return DefaultKnockoutTest(inst) and not inst.sg:HasStateTag("yawn")
end

local function GetHopDistance(inst, speed_mult)
	return speed_mult < 0.8 and TUNING.WILSON_HOP_DISTANCE_SHORT
			or speed_mult >= 1.2 and TUNING.WILSON_HOP_DISTANCE_FAR
			or TUNING.WILSON_HOP_DISTANCE
end

local function ConfigurePlayerLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    inst.components.locomotor.fasteronroad = true
    inst.components.locomotor:SetFasterOnCreep(inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetTriggersCreep(not inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetAllowPlatformHopping(true)
	inst.components.locomotor:EnableHopDelay(true)
	inst.components.locomotor.hop_distance_fn = GetHopDistance
	inst.components.locomotor.pusheventwithdirection = true
end

local function ConfigureGhostLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4 is base
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6 is base
    inst.components.locomotor.fasteronroad = false
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor:SetAllowPlatformHopping(false)
	inst.components.locomotor.pusheventwithdirection = true
end

--------------------------------------------------------------------------
-- Death and Ghost Functions
--------------------------------------------------------------------------

--Pushed/popped when dying/resurrecting
local function GhostActionFilter(inst, action)
    return action.ghost_valid
end

local function ConfigurePlayerActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(GhostActionFilter)
    end
end

local function ConfigureGhostActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PushActionFilter(GhostActionFilter, 99)
    end
end

local function PausedActionFilter(inst, action)
    return action.paused_valid
end

local function UnpausePlayerActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(PausedActionFilter)
    end
end

local function PausePlayerActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(PausedActionFilter) --always pop the filter in case one is already there.
        inst.components.playeractionpicker:PushActionFilter(PausedActionFilter, 999)
    end
end

local function OnWorldPaused(inst)
    if TheNet:IsServerPaused(true) then
        PausePlayerActions(inst)
    else
        UnpausePlayerActions(inst)
    end
end

local function RemoveDeadPlayer(inst, spawnskeleton)
    if spawnskeleton and TheSim:HasPlayerSkeletons() and inst.skeleton_prefab ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        -- Spawn a skeleton
        local skel = SpawnPrefab(inst.skeleton_prefab)
        if skel ~= nil then
            skel.Transform:SetPosition(x, y, z)
            -- Set the description
            skel:SetSkeletonDescription(inst.prefab, inst:GetDisplayName(), inst.deathcause, inst.deathpkname, inst.userid)
            skel:SetSkeletonAvatarData(inst.deathclientobj)
        end

        -- Death FX
        SpawnPrefab("die_fx").Transform:SetPosition(x, y, z)
    end

    if not GetGhostEnabled() and not GetGameModeProperty("revivable_corpse") then
		local followers = inst.components.leader.followers
		for k, v in pairs(followers) do
			if k.components.inventory ~= nil then
				k.components.inventory:DropEverything()
			elseif k.components.container ~= nil then
				k.components.container:DropEverything()
			end
		end
	end

    inst:OnDespawn()
    DeleteUserSession(inst)
    inst:Remove()
end

local function FadeOutDeadPlayer(inst, spawnskeleton)
    inst:ScreenFade(false, screen_fade_time, true)
    inst:DoTaskInTime(screen_fade_time * 1.25, RemoveDeadPlayer, spawnskeleton)
end

--Player has completed death sequence
local function OnPlayerDied(inst, data)
    inst:DoTaskInTime(3, FadeOutDeadPlayer, data ~= nil and data.skeleton)
end

local function IsCharlieRose(item)
	return item.prefab == "charlierose"
end

--Player has initiated death sequence
local function OnPlayerDeath(inst, data)
    if inst:HasTag("playerghost") then
        --ghosts should not be able to die atm
        return
    end

	if IsConsole() then
		TheGameService:NotifyProgress("dayssurvived",inst.components.age:GetAgeInDays(), inst.userid)
	end

    inst:ClearBufferedAction()

    if inst.components.revivablecorpse then
        inst.components.inventory:Hide()
	else
		if inst.components.skilltreeupdater:IsActivated("winona_charlie_2") then
			local rose = inst.components.inventory:FindItem(IsCharlieRose)
			if rose then
				if rose.components.stackable then
					rose.components.stackable:Get():Remove()
                else
                    rose:Remove()
				end
				inst.charlie_vinesave = true
			end
		end
		if inst.charlie_vinesave then
			inst.components.inventory:Hide()
		else
			inst.components.inventory:Close()
			inst.components.age:PauseAging()
		end
    end
    inst:PushEvent("ms_closepopups")

    inst.deathclientobj = TheNet:GetClientTableForUser(inst.userid)
    inst.deathcause = data ~= nil and data.cause or "unknown"
	inst.last_death_position = Vector3(inst.Transform:GetWorldPosition())
	inst.last_death_shardid = TheShard:GetShardId()

    if data == nil or data.afflicter == nil then
        inst.deathpkname = nil
    elseif data.afflicter.overridepkname ~= nil then
        inst.deathpkname = data.afflicter.overridepkname
        inst.deathbypet = data.afflicter.overridepkpet
    else
        local killer = data.afflicter.components.follower ~= nil and data.afflicter.components.follower:GetLeader() or nil
        if killer ~= nil and
            killer.components.petleash ~= nil and
            killer.components.petleash:IsPet(data.afflicter) then
            inst.deathbypet = true
        else
            killer = data.afflicter
        end
        inst.deathpkname = killer:HasTag("player") and killer:GetDisplayName() or nil
    end

	if not (inst.ghostenabled or inst.components.revivablecorpse or inst.charlie_vinesave) then
        if inst.deathcause ~= "file_load" then
            inst.player_classified:AddMorgueRecord()

            local announcement_string = GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet)
            if announcement_string ~= "" then
                TheNet:AnnounceDeath(announcement_string, inst.entity)
            end
        end
        --Early delete in case client disconnects before removal timeout
        DeleteUserSession(inst)
    end
end

local function CommonActualRez(inst)
    inst.player_classified.MapExplorer:EnableUpdate(true)

    if inst.components.revivablecorpse ~= nil then
        inst.components.inventory:Show()
    else
        inst.components.inventory:Open()
        inst.components.age:ResumeAging()
    end

    inst.components.health.canheal = true
    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:Resume()
    end
    if not GetGameModeProperty("no_temperature") then
        inst.components.temperature:SetTemp() --nil param will resume temp
    end
    inst.components.frostybreather:Enable()

    MakeMediumBurnableCharacter(inst, "torso")
    inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
    inst.components.burnable.nocharring = true

    MakeLargeFreezableCharacter(inst, "torso")
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

    inst:AddComponent("grogginess")
    inst.components.grogginess:SetResistance(3)
    inst.components.grogginess:SetKnockOutTest(ShouldKnockout)

	inst:AddComponent("slipperyfeet")

    inst.components.moisture:ForceDry(false, inst)

    inst.components.sheltered:Start()

    inst.components.debuffable:Enable(true)

    --don't ignore sanity any more
    inst.components.sanity.ignore = GetGameModeProperty("no_sanity")

    ConfigurePlayerLocomotor(inst)
    ConfigurePlayerActions(inst)

    if inst.rezsource ~= nil then
        local announcement_string = GetNewRezAnnouncementString(inst, inst.rezsource)
        if announcement_string ~= "" then
            TheNet:AnnounceResurrect(announcement_string, inst.entity)
        end
        inst.rezsource = nil
    end
    inst.remoterezsource = nil

	inst.last_death_position = nil
	inst.last_death_shardid = nil

	inst:RemoveTag("reviving")
end

local function DoActualRez(inst, source, item)
    local x, y, z
    if source ~= nil then
        x, y, z = source.Transform:GetWorldPosition()
    else
        x, y, z = inst.Transform:GetWorldPosition()
    end

    local diefx = SpawnPrefab("die_fx")
    if diefx and x and y and z then
        diefx.Transform:SetPosition(x, y, z)
    end

    -- inst.AnimState:SetBank("wilson")
    -- inst.components.skinner:SetSkinMode("normal_skin")

    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
	inst.AnimState:Hide("HEAD_HAT_NOHELM")
	inst.AnimState:Hide("HEAD_HAT_HELM")

    inst:Show()

    inst:SetStateGraph("SGwilson")

    inst.Physics:Teleport(x, y, z)

    inst.player_classified:SetGhostMode(false)

    -- Resurrector is involved
    if source ~= nil then
        inst.DynamicShadow:Enable(true)
        inst.AnimState:SetBank("wilson")
        inst.ApplySkinOverrides(inst) -- restore skin
        inst.components.bloomer:PopBloom("playerghostbloom")
        inst.AnimState:SetLightOverride(0)

        source:PushEvent("activateresurrection", inst)

        if source.prefab == "amulet" then
            inst.components.inventory:Equip(source)
            inst.sg:GoToState("amulet_rebirth")
        elseif source.prefab == "resurrectionstone" then
            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            inst.sg:GoToState("wakeup")
        elseif source.prefab == "resurrectionstatue" then
            inst.sg:GoToState("rebirth", source)
        elseif source:HasTag("multiplayer_portal") then
            inst.components.health:DeltaPenalty(TUNING.PORTAL_HEALTH_PENALTY)

            source:PushEvent("rez_player")
            inst.sg:GoToState("portal_rez")
        end
    else 
		if item ~= nil and (item.prefab == "pocketwatch_revive" or item.prefab == "pocketwatch_revive_reviver") then
			inst.DynamicShadow:Enable(true)
			inst.AnimState:SetBank("wilson")
			inst.ApplySkinOverrides(inst) -- restore skin
			inst.components.bloomer:PopBloom("playerghostbloom")
			inst.AnimState:SetLightOverride(0)

			item:PushEvent("activateresurrection", inst)

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
			if inst:HasTag("wereplayer") then
	            inst.sg:GoToState("wakeup")
			else
	            inst.sg:GoToState("rewindtime_rebirth")
			end

			SpawnPrefab("pocketwatch_ground_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
		else -- Telltale Heart
	        inst.sg:GoToState("reviver_rebirth", item)
		end
    end

    --Default to electrocute light values
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.65)
    inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
    inst.Light:Enable(false)

    MakeCharacterPhysics(inst, 75, .5)

    CommonActualRez(inst)

    inst:RemoveTag("playerghost")
    inst.Network:RemoveUserFlag(USERFLAGS.IS_GHOST)

    inst:PushEvent("ms_respawnedfromghost")
end

local function DoActualRezFromCorpse(inst, source)
    if not inst:HasTag("corpse") then
        return
    end

    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").entity:SetParent(inst.entity)

    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")

    inst:SetStateGraph("SGwilson")
    inst.sg:GoToState("corpse_rebirth")

    inst.player_classified:SetGhostMode(false)

    local respawn_health_precent = inst.components.revivablecorpse ~= nil and inst.components.revivablecorpse:GetReviveHealthPercent() or 1

    if source ~= nil and source:IsValid() then
        if source.components.talker ~= nil then
            source.components.talker:Say(GetString(source, "ANNOUNCE_REVIVED_OTHER_CORPSE"))
        end

        if source.components.corpsereviver ~= nil then
            respawn_health_precent = respawn_health_precent + source.components.corpsereviver:GetAdditionalReviveHealthPercent()
        end
    end

    --V2C: Let stategraph do it
    --[[inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)]]

    CommonActualRez(inst)

    inst.components.health:SetCurrentHealth(inst.components.health:GetMaxWithPenalty() * math.clamp(respawn_health_precent, 0, 1))
    inst.components.health:ForceUpdateHUD(true)

    inst.components.revivablecorpse:SetCorpse(false)
    if TheWorld.components.lavaarenaevent ~= nil and not TheWorld.components.lavaarenaevent:IsIntermission() then
        inst:AddTag("NOCLICK")
    end

    inst:PushEvent("ms_respawnedfromghost", { corpse = true, reviver = source })
end

local function DoRezDelay(inst, source, delay)
    if not source:IsValid() or source:IsInLimbo() then
        --Revert OnRespawnFromGhost state
        inst:ShowHUD(true)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        inst.rezsource = nil
        inst.remoterezsource = nil
        --Revert DoMoveToRezSource or DoMoveToRezPosition state
        inst:Show()
        inst.Light:Enable(true)
        inst:SetCameraDistance()
        inst.sg:GoToState("haunt")
        --
    elseif delay == nil or delay <= 0 then
        DoActualRez(inst, source)
    elseif delay > .35 then
        inst:DoTaskInTime(.35, DoRezDelay, source, delay - .35)
    else
        inst:DoTaskInTime(delay, DoRezDelay, source)
    end
end

local function DoMoveToRezSource(inst, source, delay)
    if not source:IsValid() or source:IsInLimbo() then
        --Revert OnRespawnFromGhost state
        inst:ShowHUD(true)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        inst.rezsource = nil
        inst.remoterezsource = nil
        --Revert "remoteresurrect" state
        if inst.sg.currentstate.name == "remoteresurrect" then
            inst.sg:GoToState("haunt")
        end
        --
        return
    end

    inst:Hide()
    inst.Light:Enable(false)
    inst.Physics:Teleport(source.Transform:GetWorldPosition())
    inst:SetCameraDistance(24)
    if inst.sg.currentstate.name == "remoteresurrect" then
        inst:SnapCamera()
    end
    if inst.sg.statemem.faded then
        inst.sg.statemem.faded = false
        inst:ScreenFade(true, 1)
    end

    DoRezDelay(inst, source, delay)
end

local PLAYERSKELETON_TAG = {"playerskeleton"}

local function DoMoveToRezPosition(inst, item, delay, fade_in)
    inst:Hide()
    inst.Light:Enable(false)
	if inst.last_death_position ~= nil and inst.last_death_shardid ~= nil then
		if inst.last_death_shardid == TheShard:GetShardId() then
			inst.Physics:Teleport(inst.last_death_position:Get())
			inst:SnapCamera()
			inst:SetCameraDistance(24)

			if inst.sg.statemem.faded or fade_in then
				inst.sg.statemem.faded = false
				inst:ScreenFade(true, 1)
			end

			inst:DoTaskInTime(delay, DoActualRez, nil, item)
		elseif Shard_IsWorldAvailable(inst.last_death_shardid) then
			if inst.sg.statemem.faded or fade_in then
				inst.sg.statemem.faded = false
				inst:ScreenFade(true, 0)
			end
			TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = inst, portalid = nil, worldid = inst.last_death_shardid, x = inst.last_death_position.x, y = inst.last_death_position.y, z = inst.last_death_position.z })
		else
			inst:DoTaskInTime(0, DoActualRez, nil, item)
		end
	else
		inst:DoTaskInTime(0, DoActualRez, nil, item)
	end
end

local function OnRespawnFromGhost(inst, data) -- from ListenForEvent "respawnfromghost"
    if not inst:HasTag("playerghost") then
        return
    end

	inst:AddTag("reviving")

    inst.deathclientobj = nil
    inst.deathcause = nil
    inst.deathpkname = nil
    inst.deathbypet = nil
    inst:ShowHUD(false)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.talker ~= nil then
        inst.components.talker:ShutUp()
    end
    inst.sg:AddStateTag("busy")

    if data == nil or data.source == nil then
        inst:DoTaskInTime(0, DoActualRez)
    elseif inst.sg.currentstate.name == "remoteresurrect" then
        inst:DoTaskInTime(0, DoMoveToRezSource, data.source, 24 * FRAMES)
    elseif data.source.prefab == "reviver" then
        inst:DoTaskInTime(0, DoActualRez, nil, data.source)
    elseif data.source.prefab == "pocketwatch_revive" then
        if not data.from_haunt then
			inst.sg:GoToState("start_rewindtime_revive")
			inst:DoTaskInTime(24*FRAMES, DoMoveToRezPosition, data.source, inst.skeleton_prefab == nil and 15 * FRAMES or 60 * FRAMES)
		else
			inst:ScreenFade(false, 1)
			inst:DoTaskInTime(9*FRAMES, DoMoveToRezPosition, data.source, inst.skeleton_prefab == nil and 15 * FRAMES or 60 * FRAMES, true)
		end
    elseif data.source.prefab == "pocketwatch_revive_reviver" then
        inst:DoTaskInTime(0, DoActualRez, nil, data.source)
    elseif data.source.prefab == "amulet"
        or data.source.prefab == "resurrectionstone"
        or data.source.prefab == "resurrectionstatue"
        or data.source:HasTag("multiplayer_portal") then
        inst:DoTaskInTime(9 * FRAMES, DoMoveToRezSource, data.source, --[[60-9]] 51 * FRAMES)
    else
        --unsupported rez source...
        inst:DoTaskInTime(0, DoActualRez)
    end

    inst.rezsource =
        data ~= nil and (
            (data.source ~= nil and data.source.prefab ~= "reviver" and data.source:GetBasicDisplayName()) or
            (data.user ~= nil and data.user:GetDisplayName())
        ) or
        STRINGS.NAMES.SHENANIGANS

    inst.remoterezsource =
        data ~= nil and
        data.source ~= nil and
        data.source.components.attunable ~= nil and
        data.source.components.attunable:GetAttunableTag() == "remoteresurrector"
end

local function CommonPlayerDeath(inst)
    inst.player_classified.MapExplorer:EnableUpdate(false)

    inst:RemoveComponent("burnable")

    inst.components.freezable:Reset()
    inst:RemoveComponent("freezable")
    inst:RemoveComponent("propagator")

    inst:RemoveComponent("grogginess")
	inst:RemoveComponent("slipperyfeet")

    inst.components.moisture:ForceDry(true, inst)

    inst.components.sheltered:Stop()

    inst.components.debuffable:Enable(false)

    if inst.components.revivablecorpse == nil then
        inst.components.age:PauseAging()
    end

    inst.components.health:SetInvincible(true)
    inst.components.health.canheal = false

    if not GetGameModeProperty("no_sanity") then
        inst.components.sanity:SetPercent(.5, true)
    end
    inst.components.sanity.ignore = true

    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:SetPercent(2 / 3, true)
    end
    inst.components.hunger:Pause()

    if not GetGameModeProperty("no_temperature") then
        inst.components.temperature:SetTemp(TUNING.STARTING_TEMP)
    end
    inst.components.frostybreather:Disable()
end

local function OnMakePlayerGhost(inst, data)
    if inst:HasTag("playerghost") then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    -- Spawn a skeleton
    if inst.skeleton_prefab ~= nil and data ~= nil and data.skeleton and TheSim:HasPlayerSkeletons() then
        local skel = SpawnPrefab(inst.skeleton_prefab)
        if skel ~= nil then
            skel.Transform:SetPosition(x, y, z)
            -- Set the description
            skel:SetSkeletonDescription(inst.prefab, inst:GetDisplayName(), inst.deathcause, inst.deathpkname, inst.userid)
            skel:SetSkeletonAvatarData(inst.deathclientobj)
        end
    end

    if data ~= nil and data.loading then
        -- Set temporary flag for resuming game as a ghost
        -- Used in ghost stategraph as well as below in this function
        inst.loading_ghost = true
    else
        local announcement_string = GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet)
        if announcement_string ~= "" then
            TheNet:AnnounceDeath(announcement_string, inst.entity)
        end

        -- Death FX
        SpawnPrefab("die_fx").Transform:SetPosition(x, y, z)
    end

    inst.AnimState:SetBank("ghost")

    inst.components.skinner:SetSkinMode("ghost_skin")

    inst.components.bloomer:PushBloom("playerghostbloom", "shaders/anim_bloom_ghost.ksh", 100)
    inst.AnimState:SetLightOverride(TUNING.GHOST_LIGHT_OVERRIDE)

    inst:SetStateGraph("SGwilsonghost")

    --Switch to ghost light values
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:SetColour(180/255, 195/255, 225/255)
    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(false)

    CommonPlayerDeath(inst)

    MakeGhostPhysics(inst, 1, .5)
    inst.Physics:Teleport(x, y, z)

    inst:AddTag("playerghost")
    inst.Network:AddUserFlag(USERFLAGS.IS_GHOST)

    inst.components.health:SetCurrentHealth(TUNING.RESURRECT_HEALTH * (inst.resurrect_multiplier or 1))
    inst.components.health:ForceUpdateHUD(true)

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end
    inst.player_classified:SetGhostMode(true)

    ConfigureGhostLocomotor(inst)
    ConfigureGhostActions(inst)

    inst:PushEvent("ms_becameghost")

    if inst.loading_ghost then
        inst.loading_ghost = nil
        inst.components.inventory:Close()
    else
        inst.player_classified:AddMorgueRecord()
        SerializeUserSession(inst)
    end
end

local function OnRespawnFromPlayerCorpse(inst, data)
    if not inst:HasTag("corpse") then
        return
    end

    inst.deathclientobj = nil
    inst.deathcause = nil
    inst.deathpkname = nil
    inst.deathbypet = nil
    if inst.components.talker ~= nil then
        inst.components.talker:ShutUp()
    end

    inst:DoTaskInTime(0, DoActualRezFromCorpse, data and data.source or nil)
    inst.remoterezsource = nil

    inst.rezsource =
        data ~= nil and (
            (data.source ~= nil and data.source.prefab ~= "reviver" and data.source.name) or
            (data.user ~= nil and data.user:GetDisplayName())
        ) or
        STRINGS.NAMES.SHENANIGANS
end

--Player has completed death sequence, and remains as a corpse
local function OnMakePlayerCorpse(inst, data)
    if inst:HasTag("corpse") then
        return
    elseif data == nil or not data.loading then
        local announcement_string = GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet)
        if announcement_string ~= "" then
            TheNet:AnnounceDeath(announcement_string, inst.entity)
        end
    end

    RemovePhysicsColliders(inst)

    inst.components.revivablecorpse:SetCorpse(true)
    inst:RemoveTag("NOCLICK")

    CommonPlayerDeath(inst)

    inst.player_classified:SetGhostMode(true)

    inst:PushEvent("ms_becameghost", { corpse = true })

    if data ~= nil and data.loading then
        inst.components.inventory:Hide()
    else
        inst.player_classified:AddMorgueRecord()
        SerializeUserSession(inst)
    end
end

local function OnDeathTriggerVineSave(inst)
	local announcement_string = GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet)
	if announcement_string ~= "" then
		TheNet:AnnounceDeath(announcement_string, inst.entity)
	end
	inst.player_classified:AddMorgueRecord()
	SerializeUserSession(inst)
end

local function OnRespawnFromVineSave(inst)
	inst.charlie_vinesave = nil

	inst.deathclientobj = nil
	inst.deathcause = nil
	inst.deathpkname = nil
	inst.deathbypet = nil

	inst.rezsource = nil
	inst.remoterezsource = nil

	inst.last_death_position = nil
	inst.last_death_shardid = nil

	if inst.components.talker then
		inst.components.talker:ShutUp()
	end

	inst.components.inventory:Show()

	inst.components.burnable:Extinguish(true, 0)
	inst.components.freezable:Reset()
	inst.components.grogginess:ResetGrogginess()
	inst.components.moisture:ForceDry(true, inst)
	inst.components.moisture:ForceDry(false, inst)
	inst.components.temperature:SetTemperature(TUNING.STARTING_TEMP)

	inst.components.debuffable:Enable(false) --removes all debuffs
	inst.components.debuffable:Enable(true)

	if inst.components.sanity:GetRealPercent() < TUNING.SANITY_BECOME_SANE_THRESH then
		inst.components.sanity:SetPercent(TUNING.SANITY_BECOME_SANE_THRESH, true)
	end

	if inst.components.hunger:GetPercent() < 0.2 then
		inst.components.hunger:SetPercent(0.2, true)
	end

	inst.components.health:SetCurrentHealth(TUNING.RESURRECT_HEALTH * (inst.resurrect_multiplier or 1))
	inst.components.health:ForceUpdateHUD(true)

	local announcement_string = GetNewRezAnnouncementString(inst, STRINGS.NAMES.CHARLIE)
	if announcement_string ~= "" then
		TheNet:AnnounceResurrect(announcement_string, inst.entity)
	end
end

local function GivePlayerStartingItems(inst, items, starting_item_skins)
    if items ~= nil and #items > 0 and inst.components.inventory ~= nil then
        inst.components.inventory.ignoresound = true
        if inst.components.inventory:GetNumSlots() > 0 then
            for i, v in ipairs(items) do
                local skin_name = starting_item_skins and starting_item_skins[v]
                inst.components.inventory:GiveItem(SpawnPrefab(v, skin_name, nil, inst.userid))
            end
        else
            local spawned_items = {}
            for i, v in ipairs(items) do
                local item = SpawnPrefab(v)
                if item.components.equippable ~= nil then
                    inst.components.inventory:Equip(item)
                    table.insert(spawned_items, item)
                else
                    item:Remove()
                end
            end
            for i, v in ipairs(spawned_items) do
                if v.components.inventoryitem == nil or not v.components.inventoryitem:IsHeld() then
                    v:Remove()
                end
            end
        end
        inst.components.inventory.ignoresound = false
    end
end


--------------------------------------------------------------------------

local function DoSpookedSanity(inst)
    inst.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
end

local function OnSpooked(inst)
    if not GetGameModeProperty("no_sanity") then
        --Delay to match bat overlay timing
        inst:DoTaskInTime(1.35, DoSpookedSanity)
    end
end

--------------------------------------------------------------------------

local function OnLearnCookbookRecipe(inst, data)
	local cookbookupdater = data ~= nil and inst.components.cookbookupdater
	if cookbookupdater then
		cookbookupdater:LearnRecipe(data.product, data.ingredients)
	end
end

local function OnLearnCookbookStats(inst, product)
	local cookbookupdater = product and inst.components.cookbookupdater
	if cookbookupdater then
		cookbookupdater:LearnFoodStats(product)
	end
end

local function OnEat(inst, data)
	local product = (data ~= nil and data.food ~= nil and data.food:HasTag("preparedfood")) and (data.food.food_basename or data.food.prefab) or nil
	if product ~= nil then
		OnLearnCookbookStats(inst, product)
	end
end

local function OnLearnPlantStage(inst, data)
    local plantregistryupdater = data ~= nil and inst.components.plantregistryupdater
    if plantregistryupdater then
        plantregistryupdater:LearnPlantStage(data.plant, data.stage)
    end
end

local function OnLearnFertilizer(inst, data)
    local plantregistryupdater = data ~= nil and inst.components.plantregistryupdater
    if plantregistryupdater then
        plantregistryupdater:LearnFertilizer(data.fertilizer)
    end
end

local function OnTakeOversizedPicture(inst, data)
    local plantregistryupdater = data ~= nil and inst.components.plantregistryupdater
    if plantregistryupdater then
        plantregistryupdater:TakeOversizedPicture(data.plant, data.weight, data.beardskin, data.beardlength)
    end
end

local function CanSeeTileOnMiniMap(inst, tx, ty)
    return inst.player_classified.MapExplorer:IsTileSeeable(tx, ty)
end

local function CanSeePointOnMiniMap(inst, px, py, pz) -- Convenience wrapper.
    local tx, ty = TheWorld.Map:GetTileXYAtPoint(px, py, pz)
    return inst.player_classified.MapExplorer:IsTileSeeable(tx, ty)
end

local function GenericCommander_OnAttackOther(inst, data)
    if data and data.target and data.target ~= inst then
        inst.components.commander:ShareTargetToAllSoldiers(data.target)
    end
end

local function MakeGenericCommander(inst)
    if inst.components.commander == nil then
        inst:AddComponent("commander")
        inst:ListenForEvent("onattackother", GenericCommander_OnAttackOther)
    end
end

local function OnMurderCheckForFishRepel(inst, data)
    local victim = data.victim
    if not data.negligent and -- Do not punish neglecting fish in the inventory.
        inst.components.leader and
        victim ~= nil and victim:IsValid() and
        victim:HasTag("fish") and
        not inst.components.health:IsDead() then
        -- This act is not looked too highly upon by anyone, not just Wurt!
        for follower, _ in pairs(inst.components.leader.followers) do
            if follower:HasTag("merm") and not follower:HasTag("mermking") then
                follower.components.follower:StopFollowing()
                if follower.DoDisapproval then
                    follower:DoDisapproval()
                end
            end
        end
    end
end

local function clear_onstage(inst)
    if inst._is_onstage_task then
        inst._is_onstage_task:Cancel()
    end
    inst._is_onstage_task = nil
end

local function OnOnStageEvent(inst, duration)
    duration = duration or FRAMES
    if inst._is_onstage_task then
        inst._is_onstage_task:Cancel()
    end
    inst._is_onstage_task = inst:DoTaskInTime(duration, clear_onstage)
end

local function IsActing(inst)
    return inst.sg:HasStateTag("acting") or (inst._is_onstage_task ~= nil)
end

local function StartStageActing(inst)
    if inst.ShowActions then
        inst:ShowActions(false)
    end
end

local function StopStageActing(inst)
    if inst.ShowActions then
        inst:ShowActions(true)
    end
end

local function SynchronizeOneClientAuthoritativeSetting(inst, variable, value)
    inst:SetClientAuthoritativeSetting(variable, value)
    if not TheWorld.ismastersim then
        SendRPCToServer(RPC.SetClientAuthoritativeSetting, variable, value)
    end
end

local function SynchronizeAllClientAuthoritativeSettings(inst)
    -- NOTES(JBK): We have client settings data that the server should know about because of the server only components.
    inst:SynchronizeOneClientAuthoritativeSetting(CLIENTAUTHORITATIVESETTINGS.PLATFORMHOPDELAY, Profile:GetBoatHopDelay())
end

local function SetClientAuthoritativeSetting(inst, variable, value)
    -- NOTES(JBK): Check passed in variables here using common RPC checks.
    -- Do not trust the data in here at all it could be anything.
    -- This function can be run on both client and server to store the information onto the player entity.
    -- If there are too many variables later add a component and refactor.
    if not checkuint(variable) then
        return
    end

    if variable == CLIENTAUTHORITATIVESETTINGS.PLATFORMHOPDELAY then
        if not checkuint(value) then
            return
        end
        if value ~= TUNING.PLATFORM_HOP_DELAY_TICKS then
            inst.forced_platformhopdelay = value
        else
            inst.forced_platformhopdelay = nil
        end
    end
end

local function OnPostActivateHandshake_Client(inst, state) -- NOTES(JBK): Use PostActivateHandshake.
    --print("[OPA_C]", state)
    if state <= inst._PostActivateHandshakeState_Client or state > POSTACTIVATEHANDSHAKE.READY then -- Forward unique states only.
        print("OnPostActivateHandshake_Client got a bad increment in state:", inst, inst._PostActivateHandshakeState_Client, state)
        return
    end
    inst._PostActivateHandshakeState_Client = state

    if state == POSTACTIVATEHANDSHAKE.CTS_LOADED then
        TheSkillTree:OPAH_DoBackup()
        SynchronizeAllClientAuthoritativeSettings(inst) -- Make this the last call for this if block.
    elseif state == POSTACTIVATEHANDSHAKE.STC_SENDINGSTATE then
        inst:PostActivateHandshake(POSTACTIVATEHANDSHAKE.READY)
    elseif state == POSTACTIVATEHANDSHAKE.READY then
        TheSkillTree:OPAH_Ready()
    else
        print("OnPostActivateHandshake_Client got a bad state:", inst, state)
    end
end
local function OnPostActivateHandshake_Server(inst, state) -- NOTES(JBK): Use PostActivateHandshake.
    --print("[OPA_S]", state)
    if state <= inst._PostActivateHandshakeState_Server or state > POSTACTIVATEHANDSHAKE.READY then -- Forward unique states only.
        print("OnPostActivateHandshake_Server got a bad increment in state:", inst, inst._PostActivateHandshakeState_Server, state)
        return
    end
    inst._PostActivateHandshakeState_Server = state

    if state == POSTACTIVATEHANDSHAKE.CTS_LOADED then
        inst:PostActivateHandshake(POSTACTIVATEHANDSHAKE.STC_SENDINGSTATE)
    elseif state == POSTACTIVATEHANDSHAKE.STC_SENDINGSTATE then
        local skilltreeupdater = inst.components.skilltreeupdater
        skilltreeupdater:SendFromSkillTreeBlob(inst)
    elseif state == POSTACTIVATEHANDSHAKE.READY then
        -- Good state.
		inst:PushEvent("ms_skilltreeinitialized")
    else
        print("OnPostActivateHandshake_Server got a bad state:", inst, state)
    end
end
local function PostActivateHandshake(inst, state)
    if TheWorld.ismastersim then
        if inst.userid and (TheNet:IsDedicated() or (TheWorld.ismastersim and inst ~= ThePlayer)) then
            inst:OnPostActivateHandshake_Server(state)
            SendRPCToClient(CLIENT_RPC.PostActivateHandshake, inst.userid, state)
        else
            inst:DoTaskInTime(0, function() -- Delay each state by a frame to let OnPostActivateHandshake call PostActivateHandshake.
                inst:OnPostActivateHandshake_Client(state)
                inst:OnPostActivateHandshake_Server(state)
            end)
        end
    elseif inst == ThePlayer then
        inst:OnPostActivateHandshake_Client(state)
        SendRPCToServer(RPC.PostActivateHandshake, state)
    end
end

local function OnClosePopups(inst)
    -- NOTES(JBK): These are popups that should be closed that do not have an automatic close handler elsewhere.
    inst:ShowPopUp(POPUPS.PLAYERINFO, false)
end

local SCRAPBOOK_CANT_TAGS = { "FX", "INLIMBO" }
local function UpdateScrapbook(inst)
	--assert(inst = ThePlayer)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SCRAPBOOK_UPDATERADIUS, nil, SCRAPBOOK_CANT_TAGS) 
    for _, ent in ipairs(ents) do
        if IsEntityDead(ent) or ent.scrapbook_inspectonseen then 
            TheScrapbookPartitions:SetInspectedByCharacter(ent, inst.prefab)
        else
            TheScrapbookPartitions:SetSeenInGame(ent)
        end
    end
end

return
{
    ShouldKnockout              = ShouldKnockout,
    ConfigurePlayerLocomotor    = ConfigurePlayerLocomotor,
    ConfigureGhostLocomotor     = ConfigureGhostLocomotor,
    ConfigurePlayerActions      = ConfigurePlayerActions,
    ConfigureGhostActions       = ConfigureGhostActions,
    OnWorldPaused               = OnWorldPaused,
    OnPlayerDeath               = OnPlayerDeath,
    OnPlayerDied                = OnPlayerDied,
    OnMakePlayerGhost           = OnMakePlayerGhost,
    OnMakePlayerCorpse          = OnMakePlayerCorpse,
    OnRespawnFromGhost          = OnRespawnFromGhost,
    OnRespawnFromPlayerCorpse   = OnRespawnFromPlayerCorpse,
	OnDeathTriggerVineSave		= OnDeathTriggerVineSave,
	OnRespawnFromVineSave		= OnRespawnFromVineSave,
    OnSpooked                   = OnSpooked,
	OnLearnCookbookRecipe		= OnLearnCookbookRecipe,
	OnLearnCookbookStats		= OnLearnCookbookStats,
	OnEat						= OnEat,
    OnLearnPlantStage           = OnLearnPlantStage,
    OnLearnFertilizer           = OnLearnFertilizer,
    OnTakeOversizedPicture      = OnTakeOversizedPicture,
	GivePlayerStartingItems		= GivePlayerStartingItems,
    CanSeeTileOnMiniMap         = CanSeeTileOnMiniMap,
    CanSeePointOnMiniMap        = CanSeePointOnMiniMap,
    MakeGenericCommander        = MakeGenericCommander,
    OnMurderCheckForFishRepel   = OnMurderCheckForFishRepel,
    OnOnStageEvent              = OnOnStageEvent,
    IsActing                    = IsActing,
    StartStageActing            = StartStageActing,
    StopStageActing             = StopStageActing,
    OnPostActivateHandshake_Client = OnPostActivateHandshake_Client,
    OnPostActivateHandshake_Server = OnPostActivateHandshake_Server,
    SetClientAuthoritativeSetting = SetClientAuthoritativeSetting,
    SynchronizeOneClientAuthoritativeSetting = SynchronizeOneClientAuthoritativeSetting,
    PostActivateHandshake       = PostActivateHandshake,
    OnClosePopups               = OnClosePopups,
    UpdateScrapbook             = UpdateScrapbook,
}