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

local function ConfigurePlayerLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    inst.components.locomotor.fasteronroad = true
    inst.components.locomotor:SetTriggersCreep(not inst:HasTag("spiderwhisperer"))
end

local function ConfigureGhostLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4 is base
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6 is base
    inst.components.locomotor.fasteronroad = false
    inst.components.locomotor:SetTriggersCreep(false)
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

local function RemoveDeadPlayer(inst, spawnskeleton)
    if spawnskeleton and TheSim:HasPlayerSkeletons() then
        local x, y, z = inst.Transform:GetWorldPosition()

        -- Spawn a skeleton
        local skel = SpawnPrefab("skeleton_player")
        if skel ~= nil then
            skel.Transform:SetPosition(x, y, z)
            -- Set the description
            skel:SetSkeletonDescription(inst.prefab, inst:GetDisplayName(), inst.deathcause, inst.deathpkname)
            skel:SetSkeletonAvatarData(inst.deathclientobj)
        end

        -- Death FX
        SpawnPrefab("die_fx").Transform:SetPosition(x, y, z)
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

    if inst.components.revivablecorpse ~= nil then
        inst.components.inventory:Hide()
    else
        inst.components.inventory:Close()
        inst.components.age:PauseAging()
    end
    inst:PushEvent("ms_closepopups")

    inst.deathclientobj = TheNet:GetClientTableForUser(inst.userid)
    inst.deathcause = data ~= nil and data.cause or "unknown"
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

    if not inst.ghostenabled and inst.components.revivablecorpse == nil then
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

    inst:Show()

    inst:SetStateGraph("SGwilson")

    inst.Physics:Teleport(x, y, z)

    inst.player_classified:SetGhostMode(false)

    -- Resurrector is involved
    if source ~= nil then
        inst.DynamicShadow:Enable(true)
        inst.AnimState:SetBank("wilson")
        inst.components.skinner:SetSkinMode("normal_skin") -- restore skin
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
            inst.sg:GoToState("rebirth")
        elseif source:HasTag("multiplayer_portal") then
            inst.components.health:DeltaPenalty(TUNING.PORTAL_HEALTH_PENALTY)

            source:PushEvent("rez_player")
            inst.sg:GoToState("portal_rez")
        end
    else -- Telltale Heart
        inst.sg:GoToState("reviver_rebirth", item)
    end
 
    --Default to electrocute light values
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.65)
    inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
    inst.Light:Enable(false)

    MakeCharacterPhysics(inst, 75, .5)

    CommonActualRez(inst, source, item)

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
        --Revert DoMoveToRezSource state
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

local function OnRespawnFromGhost(inst, data)
    if not inst:HasTag("playerghost") then
        return
    end

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
    if data ~= nil and data.skeleton and TheSim:HasPlayerSkeletons() then
        local skel = SpawnPrefab("skeleton_player")
        if skel ~= nil then
            skel.Transform:SetPosition(x, y, z)
            -- Set the description
            skel:SetSkeletonDescription(inst.prefab, inst:GetDisplayName(), inst.deathcause, inst.deathpkname)
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

    inst.components.health:SetCurrentHealth(TUNING.RESURRECT_HEALTH)
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

return
{
    ShouldKnockout              = ShouldKnockout,
    ConfigurePlayerLocomotor    = ConfigurePlayerLocomotor,
    ConfigureGhostLocomotor     = ConfigureGhostLocomotor,
    ConfigurePlayerActions      = ConfigurePlayerActions,
    ConfigureGhostActions       = ConfigureGhostActions,
    OnPlayerDeath               = OnPlayerDeath,
    OnPlayerDied                = OnPlayerDied,
    OnMakePlayerGhost           = OnMakePlayerGhost,
    OnMakePlayerCorpse          = OnMakePlayerCorpse,
    OnRespawnFromGhost          = OnRespawnFromGhost,
    OnRespawnFromPlayerCorpse   = OnRespawnFromPlayerCorpse,
    OnSpooked                   = OnSpooked,
}
