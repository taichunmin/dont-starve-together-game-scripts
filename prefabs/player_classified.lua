local TIMEOUT = 2
local TechTree = require("techtree")
local INSPIRATION_BATTLESONG_DEFS = require("prefabs/battlesongdefs")

local fns = {} -- a table to store local functions in so that we don't hit the 60 upvalues limit

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

local function SetValue(inst, name, value)
    assert(value >= 0 and value <= 65535, "Player "..tostring(name).." out of range: "..tostring(value))
    inst[name]:set(math.ceil(value))
end

local function SetDirty(netvar, val)
    --Forces a netvar to be dirty regardless of value
    netvar:set_local(val)
    netvar:set(val)
end

local function PushPausePredictionFrames(inst, frames)
    --Force dirty, we just want to trigger an event on the client
    SetDirty(inst.pausepredictionframes, frames)
end

local function OnHealthDelta(parent, data)
    if data.overtime then
        --V2C: Don't clear: it's redundant as player_classified shouldn't
        --     get constructed remotely more than once, and this would've
        --     also resulted in lost pulses if network hasn't ticked yet.
        --parent.player_classified.ishealthpulseup:set_local(false)
        --parent.player_classified.ishealthpulsedown:set_local(false)
    elseif data.newpercent > data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ishealthpulseup, true)
    elseif data.newpercent < data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ishealthpulsedown, true)
    end
end

local function OnHungerDelta(parent, data)
    if data.overtime then
        --V2C: Don't clear: it's redundant as player_classified shouldn't
        --     get constructed remotely more than once, and this would've
        --     also resulted in lost pulses if network hasn't ticked yet.
        --parent.player_classified.ishungerpulseup:set_local(false)
        --parent.player_classified.ishungerpulsedown:set_local(false)
    elseif data.newpercent > data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ishungerpulseup, true)
    elseif data.newpercent < data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ishungerpulsedown, true)
    end
end

local function UpdateAnimOverrideSanity(parent)
    local isinsane = parent.replica.sanity:IsInsanityMode() and (parent.replica.sanity:GetPercentNetworked() <= (parent:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY))
    parent.AnimState:SetClientSideBuildOverrideFlag("insane", isinsane)
    parent:SetClientSideInventoryImageOverrideFlag("insane", isinsane)
end

local function OnSanityDelta(parent, data)
    if data.overtime then
        --V2C: Don't clear: it's redundant as player_classified shouldn't
        --     get constructed remotely more than once, and this would've
        --     also resulted in lost pulses if network hasn't ticked yet.
        --parent.player_classified.issanitypulseup:set_local(false)
        --parent.player_classified.issanitypulsedown:set_local(false)
    elseif data.newpercent > data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.issanitypulseup, true)
    elseif data.newpercent < data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.issanitypulsedown, true)
    end

    if parent.HUD ~= nil then
        UpdateAnimOverrideSanity(parent)
    end
end

local function OnWerenessDelta(parent, data)
    if data.overtime then
        --V2C: Don't clear: it's redundant as player_classified shouldn't
        --     get constructed remotely more than once, and this would've
        --     also resulted in lost pulses if network hasn't ticked yet.
        --parent.player_classified.iswerenesspulseup:set_local(false)
        --parent.player_classified.iswerenesspulsedown:set_local(false)
    elseif data.newpercent > data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.iswerenesspulseup, true)
    elseif data.newpercent < data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.iswerenesspulsedown, true)
    end
end

local function OnAttacked(parent, data)
    parent.player_classified.attackedpulseevent:push()
    parent.player_classified.isattackedbydanger:set(
        data ~= nil and
        data.attacker ~= nil and
        not (data.attacker:HasTag("shadow") or
            data.attacker:HasTag("shadowchesspiece") or
            data.attacker:HasTag("noepicmusic") or
            data.attacker:HasTag("thorny") or
            data.attacker:HasTag("smolder"))
    )
    parent.player_classified.isattackredirected:set(data ~= nil and data.redirected ~= nil)
end

local function OnBuildSuccess(parent)
    parent.player_classified.buildevent:push()
end

local function OnConsumeHealthCost(parent)
    parent.player_classified.builderdamagedevent:push()
end

local function OnLearnRecipeSuccess(parent, data)
    SendRPCToClient(CLIENT_RPC.LearnBuilderRecipe, parent.userid, data.recipe)
    parent.player_classified.learnrecipeevent:push()
end

local function OnLearnMapSuccess(parent)
    parent.player_classified.learnmapevent:push()
end

local function OnRepairSuccess(parent)
    parent.player_classified.repairevent:push()
end

local function OnPerformAction(parent)
    SetDirty(parent.player_classified.isperformactionsuccess, true)
end

local function OnActionFailed(parent)
    SetDirty(parent.player_classified.isperformactionsuccess, false)
end

local function OnCarefulWalking(parent, data)
    parent.player_classified.iscarefulwalking:set(data.careful)
end

local function OnWormholeTravel(parent, wormholetype)
    SetDirty(parent.player_classified.wormholetravelevent, wormholetype)
end

local function OnHoundWarning(parent, houndwarningtype)
    SetDirty(parent.player_classified.houndwarningevent, houndwarningtype)
end

fns.OnPlayThemeMusic = function(parent, data)
	if data ~= nil then
		if data.theme == "farming" then
			parent.player_classified.start_farming_music:push()
		end
	end
end

local function OnMakeFriend(parent)
    parent.player_classified.makefriendevent:push()
end

local function OnFeedInContainer(parent)
    parent.player_classified.feedincontainerevent:push()
end

local function AddMorgueRecord(inst)
    if inst._parent ~= nil then
        SetDirty(inst.isdeathbypk, inst._parent.deathpkname ~= nil)
        inst.deathcause:set(inst._parent.deathpkname or inst._parent.deathcause)
    end
end

--Temperature stuff
local max_precision_temp = 6
local min_precision_temp = -11
local precision_factor = 4
local coarse_factor = 1
local pivot = math.floor((256 - (max_precision_temp + min_precision_temp) * precision_factor) / 2)

local function SetTemperature(inst, temperature)
    if temperature >= max_precision_temp then
        inst.currenttemperaturedata:set(pivot + max_precision_temp * precision_factor + math.floor((temperature - max_precision_temp) * coarse_factor + .5))
    elseif temperature <= min_precision_temp then
        inst.currenttemperaturedata:set(pivot + min_precision_temp * precision_factor + math.floor((temperature - min_precision_temp) * coarse_factor + .5))
    else
        inst.currenttemperaturedata:set(pivot + math.floor(temperature * precision_factor + .5))
    end
end

fns.SetOldagerRate = function(inst, dps)
    assert(dps >= -30 and dps <= 30, "Player oldager_rate out of range: "..tostring(dps))
	inst.oldager_rate:set(dps + 30)
end

fns.GetOldagerRate = function(inst)
	return inst.oldager_rate:value() - 30
end


--TouchStoneTracker stuff
local function SetUsedTouchStones(inst, used)
    inst.touchstonetrackerused:set(used)
end

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------

local function DeserializeTemperature(inst)
    if inst.currenttemperaturedata:value() >= pivot + max_precision_temp * precision_factor then
        inst.currenttemperature = (inst.currenttemperaturedata:value() - pivot - max_precision_temp * precision_factor) / coarse_factor + max_precision_temp
    elseif inst.currenttemperaturedata:value() <= pivot + min_precision_temp * precision_factor then
        inst.currenttemperature = (inst.currenttemperaturedata:value() - pivot - min_precision_temp * precision_factor) / coarse_factor + min_precision_temp
    else
        inst.currenttemperature = (inst.currenttemperaturedata:value() - pivot) / precision_factor
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for player")
    else
        inst._parent:AttachClassified(inst)
        for i, v in ipairs({ "builder", "combat", "health", "hunger", "rider", "sanity" }) do
            if inst._parent.replica[v] ~= nil then
                inst._parent.replica[v]:AttachClassified(inst)
            end
        end
        for i, v in ipairs({ "playercontroller", "playervoter" }) do
            if inst._parent.components[v] ~= nil then
                inst._parent.components[v]:AttachClassified(inst)
            end
        end
    end
end

local function OnHealthDirty(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldhealthpercent
        local percent = inst.currenthealth:value() / inst.maxhealth:value()
        local data =
        {
            oldpercent = oldpercent,
            newpercent = percent,
            overtime =
                not (inst.ishealthpulseup:value() and percent > oldpercent) and
                not (inst.ishealthpulsedown:value() and percent < oldpercent),
        }
        inst._oldhealthpercent = percent
        inst.ishealthpulseup:set_local(false)
        inst.ishealthpulsedown:set_local(false)
        inst._parent:PushEvent("healthdelta", data)
    else
        inst._oldhealthpercent = 1
        inst.ishealthpulseup:set_local(false)
        inst.ishealthpulsedown:set_local(false)
    end
end

local function OnIsTakingFireDamageDirty(inst)
    if inst._parent ~= nil then
        if inst.istakingfiredamage:value() then
            inst._parent:PushEvent("startfiredamage", { low = inst.istakingfiredamagelow:value() })
        else
            inst._parent:PushEvent("stopfiredamage")
        end
    end
end

local function OnIsTakingFireDamageLowDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("changefiredamage", { low = inst.istakingfiredamagelow:value() })
    end
end

local function OnAttackedPulseEvent(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("attacked", { isattackedbydanger = inst.isattackedbydanger:value(), redirected = inst.isattackredirected:value() })
    end
end

local function OnHungerDirty(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldhungerpercent
        local percent = inst.currenthunger:value() / inst.maxhunger:value()
        local data =
        {
            oldpercent = oldpercent,
            newpercent = percent,
            overtime =
                not (inst.ishungerpulseup:value() and percent > oldpercent) and
                not (inst.ishungerpulsedown:value() and percent < oldpercent),
        }
        inst._oldhungerpercent = percent
        inst.ishungerpulseup:set_local(false)
        inst.ishungerpulsedown:set_local(false)
        inst._parent:PushEvent("hungerdelta", data)
        if oldpercent > 0 then
            if percent <= 0 then
                inst._parent:PushEvent("startstarving")
            end
        elseif percent > 0 then
            inst._parent:PushEvent("stopstarving")
        end
    else
        inst._oldhungerpercent = 1
        inst.ishungerpulseup:set_local(false)
        inst.ishungerpulsedown:set_local(false)
    end
end

local function OnSanityDirty(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldsanitypercent
        local percent = inst.currentsanity:value() / inst.maxsanity:value()
        local data =
        {
            oldpercent = oldpercent,
            newpercent = percent,
            overtime =
                not (inst.issanitypulseup:value() and percent > oldpercent) and
                not (inst.issanitypulsedown:value() and percent < oldpercent),
			sanitymode = inst._parent.replica.sanity:GetSanityMode(),
        }
        inst._oldsanitypercent = percent
        inst.issanitypulseup:set_local(false)
        inst.issanitypulsedown:set_local(false)
        inst._parent:PushEvent("sanitydelta", data)

        inst._parent:DoTaskInTime(0, UpdateAnimOverrideSanity)
    else
        inst._oldsanitypercent = 1
        inst.issanitypulseup:set_local(false)
        inst.issanitypulsedown:set_local(false)
    end
end

local function OnWerenessDirty(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldwerenesspercent
        local percent = inst.currentwereness:value() * .01
        local data =
        {
            oldpercent = oldpercent,
            newpercent = percent,
            overtime =
                not (inst.iswerenesspulseup:value() and percent > oldpercent) and
                not (inst.iswerenesspulsedown:value() and percent < oldpercent),
        }
        inst._oldwerenesspercent = percent
        inst.iswerenesspulseup:set_local(false)
        inst.iswerenesspulsedown:set_local(false)
        inst._parent:PushEvent("werenessdelta", data)
    else
        inst._oldwerenesspercent = 0
        inst.iswerenesspulseup:set_local(false)
        inst.iswerenesspulsedown:set_local(false)
    end
end

fns.OnInspirationDirty = function(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldinspirationpercent
        local percent = inst.currentinspiration:value() * .01
        local data =
        {
            newpercent = percent,
			slots_available = nil,
			draining = inst.inspirationdraining:value(),
        }
        inst._oldinspirationpercent = percent
        inst._parent:PushEvent("inspirationdelta", data)
    else
        inst._oldinspirationpercent = 0
    end
end

fns.OnHasInspirationBuffDirty = function(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("hasinspirationbuff", {on = inst.hasinspirationbuff:value()})
	end
end

fns.InMightyGymDirty = function(inst)

    if inst._parent ~= nil then
        inst._parent:PushEvent("inmightygym", {ingym = inst.inmightygym:value() + 1, player=inst._parent})
    end
end

fns.OnGymBellStart = function(inst)
    if inst._parent ~= nil then
        inst._parent:Startbell()
    end
end

fns.OnInspirationSongsDirty = function(inst, slot)
    if inst._parent ~= nil then
		local song_def = INSPIRATION_BATTLESONG_DEFS.GetBattleSongDefFromNetID(inst.inspirationsongs[slot]:value())
		inst._parent:PushEvent("inspirationsongchanged", {songdata = song_def, slotnum = slot})
    end
end

local function OnMightinessDirty(inst)
    if inst._parent ~= nil then
        local percent = inst.currentmightiness:value() * .01
        local data = 
        {
            oldpercent = inst._oldmightinesspercent,
            newpercent = percent,
            delta = inst.currentmightiness:value() - (inst._oldmightinesspercent / .01),
        }
        inst._oldmightinesspercent = percent

        inst._parent:PushEvent("mightinessdelta", data)
    end
end

-- WX78 Upgrade Module UI functions ------------------------------------------

fns.OnEnergyLevelDirty = function(inst)
    if inst._parent ~= nil then
        local energylevel = inst.currentenergylevel:value()
        local data =
        {
            old_level = inst._oldcurrentenergylevel,
            new_level = energylevel,
        }

        inst._oldcurrentenergylevel = energylevel

        inst._parent:PushEvent("energylevelupdate", data)
    end
end

fns.OnUIRobotSparks = function(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("do_robot_spark")
    end
end

fns.OnUpgradeModulesListDirty = function(inst)
    if inst._parent ~= nil then
        local module1 = inst.upgrademodules[1]:value()
        local module2 = inst.upgrademodules[2]:value()
        local module3 = inst.upgrademodules[3]:value()
        local module4 = inst.upgrademodules[4]:value()
        local module5 = inst.upgrademodules[5]:value()
        local module6 = inst.upgrademodules[6]:value()

        if module1 == 0 and module2 == 0 and module3 == 0 and module4 == 0 and module5 == 0 and module6 == 0 then
            inst._parent:PushEvent("upgrademoduleowner_popallmodules")
        else
            inst._parent:PushEvent("upgrademodulesdirty", {module1, module2, module3, module4, module5, module6})
        end
    end
end

------------------------------------------------------------------------------

local function OnMoistureDirty(inst)
    if inst._parent ~= nil then
        local data =
        {
            old = inst._oldmoisture,
            new = inst.moisture:value(),
        }
        inst._oldmoisture = data.new
        inst._parent:PushEvent("moisturedelta", data)
    else
        inst._oldmoisture = 0
    end
end

local function OnTemperatureDirty(inst)
    DeserializeTemperature(inst)
    if inst._parent == nil then
        inst._oldtemperature = TUNING.STARTING_TEMP
    elseif inst._oldtemperature ~= inst.currenttemperature then
        local oldtemperature = inst._oldtemperature
        local temperature = inst.currenttemperature
        local data =
        {
            last = oldtemperature,
            new = temperature,
        }
        inst._oldtemperature = temperature
        if oldtemperature < 0 then
            if temperature >= 0 then
                inst._parent:PushEvent("stopfreezing")
            end
        elseif temperature < 0 then
            inst._parent:PushEvent("startfreezing")
        end
        if oldtemperature > TUNING.OVERHEAT_TEMP then
            if temperature <= TUNING.OVERHEAT_TEMP then
                inst._parent:PushEvent("stopoverheating")
            end
        elseif temperature > TUNING.OVERHEAT_TEMP then
            inst._parent:PushEvent("startoverheating")
        end
        inst._parent:PushEvent("temperaturedelta", data)
    end
end

local function OnTechTreesDirty(inst)
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        inst.techtrees[v] = inst[string.lower(v).."level"]:value()
    end
    if inst._parent ~= nil then
        inst._parent:PushEvent("techtreechange", { level = inst.techtrees })
    end
end

fns.RefreshCrafting = function(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("refreshcrafting")
    end
end

local function OnRecipesDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("unlockrecipe")
    end
end

local function Refresh(inst)
    inst._refreshtask = nil
    for k, v in pairs(inst._bufferedbuildspreview) do
        inst._bufferedbuildspreview[k] = nil
    end
    if inst._parent ~= nil then
        inst._parent:PushEvent("refreshcrafting")
    end
end

local function QueueRefresh(inst, delay)
    if inst._refreshtask == nil then
        inst._refreshtask = inst:DoTaskInTime(delay, Refresh)
    end
end

local function CancelRefresh(inst)
    if inst._refreshtask ~= nil then
        inst._refreshtask:Cancel()
        inst._refreshtask = nil
    end
end

local function OnBufferedBuildsDirty(inst)
    CancelRefresh(inst)
    Refresh(inst)
end

local function BufferBuild(inst, recipename)
    local recipe = GetValidRecipe(recipename)
    local inventory = inst._parent ~= nil and inst._parent.replica.inventory ~= nil and inst._parent.replica.inventory.classified or nil
    if recipe ~= nil and inventory ~= nil and inventory:RemoveIngredients(recipe, INGREDIENT_MOD_LOOKUP[inst.ingredientmod:value()]) then
        inst._bufferedbuildspreview[recipename] = true
        if inst._parent ~= nil then
            inst._parent:PushEvent("refreshcrafting")
        end
        CancelRefresh(inst)
        QueueRefresh(inst, TIMEOUT)
        SendRPCToServer(RPC.BufferBuild, recipe.rpc_id)
    end
end

local function OnIsPerformActionSuccessDirty(inst)
    if inst._parent ~= nil then
        if inst._parent.bufferedaction ~= nil and
            inst._parent.bufferedaction.ispreviewing then
            inst._parent:ClearBufferedAction()
        end
        if inst.isperformactionsuccess:value() then
            inst._parent:PushEvent("performaction")
        end
    end
end

local function CancelPausePrediction(inst)
    if inst._pausepredictiontask ~= nil then
        inst._pausepredictiontask:Cancel()
        inst._pausepredictiontask = nil
        inst.pausepredictionframes:set_local(0)
    end
end

local function OnPausePredictionFramesDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst._pausepredictiontask ~= nil then
            inst._pausepredictiontask:Cancel()
        end
        inst._pausepredictiontask = inst.pausepredictionframes:value() > 0 and inst:DoTaskInTime(inst.pausepredictionframes:value() * FRAMES, CancelPausePrediction) or nil
        inst._parent:PushEvent("cancelmovementprediction")
    end
end

local function OnIsCarefulWalkingDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("carefulwalking", { careful = inst.iscarefulwalking:value() })
    end
end

local function OnPlayerCameraShake(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        TheCamera:Shake(
            inst.camerashakemode:value(),
            (inst.camerashaketime:value() + 1) / 16,
            (inst.camerashakespeed:value() + 1) / 256,
            (inst.camerashakescale:value() + 1) / 32
        )
    end
end

local function OnPlayerScreenFlashDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        TheWorld:PushEvent("screenflash", (inst.screenflash:value() + 1) / 8)
    end
end

local function OnAttunedResurrectorDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("attunedresurrector", inst.attunedresurrector:value())
    end
end

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

local function OnStormLevelDirty(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("stormlevel", { level = inst.stormlevel:value() / 7, stormtype = inst.stormtype:value() }) --
    end
end

local function OnBuildEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
        inst._parent:PushEvent("buildsuccess")
    end
end

local function OnBuilderDamagedEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        inst._parent:PushEvent("damaged")
    end
end

local function OnOpenCraftingMenuEvent(inst)
	local player = inst._parent
    if player ~= nil and TheFocalPoint.entity:GetParent() == player then
		if player.HUD ~= nil then
			player.HUD:OpenCrafting()
		end
    end
end

local function OnInkedEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        inst._parent:PushEvent("inked")
    end
end

local function OnLearnRecipeEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
    end
end

local function OnLearnMapEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/learn_map")
    end
end

local function OnRevealMapSpotEvent(inst)
	local tx, ty, tz = inst.revealmapspot_worldx:value(), 0, inst.revealmapspot_worldz:value()
	local player = inst._parent

	if player ~= nil and player.HUD ~= nil then
		player:DoTaskInTime(0, function()
			if TheFocalPoint.entity:GetParent() == player then
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/learn_map")
			end
			player.HUD.controls:ShowMap(Vector3(tx, ty, tz))
		end)
	end
end

local function OnRepairEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing")
    end
end

local function OnGhostModeDirty(inst)
    if inst._parent ~= nil then
        inst._parent.components.playervision:SetGhostVision(inst.isghostmode:value())
        if inst._parent.HUD ~= nil then
            inst._parent:SetGhostMode(inst.isghostmode:value())
        end
    end
end

local function OnActionMeterDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst.actionmeter:value() < 2 then
            inst._parent.HUD:HideRingMeter(inst.actionmeter:value() == 1)
        else
            inst._parent.HUD:ShowRingMeter(inst._parent:GetPosition(), inst.actionmetertime:value() * .1, (inst.actionmeter:value() - 2) * .1)
        end
    end
end

local function OnPlayerHUDDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst.ishudvisible:value() then
            inst._parent.HUD:Show()
        else
            inst._parent.HUD:Hide()
        end

        if inst.ismapcontrolsvisible:value() and not GetGameModeProperty("no_minimap") then
            inst._parent.HUD.controls.mapcontrols:ShowMapButton()
        else
            if inst._parent.HUD:IsMapScreenOpen() then
                TheFrontEnd:PopScreen()
            end
            inst._parent.HUD.controls.mapcontrols:HideMapButton()
        end
    end
end

local function OnPlayerCameraDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst.iscamerazoomed:value() then
            if inst._prevcameradistance == nil then
                inst._prevcameradistance = TheCamera.distance
                inst._prevcameradistancegain = TheCamera.distancegain
                if inst._prevcameradistance > 18 then
                    TheCamera:SetDistance(18)
                    TheCamera.distancegain = 3
                    TheCamera:SetControllable(false)
                end
            end
        elseif inst._prevcameradistance ~= nil then
            TheCamera:SetDistance(inst.cameradistance:value() > 0 and inst.cameradistance:value() or inst._prevcameradistance)
            TheCamera.distancegain = inst._prevcameradistancegain
            inst._prevcameradistance = nil
            inst._prevcameradistancegain = nil
            TheCamera:SetControllable(true)
        elseif inst.cameradistance:value() > 0 then
            TheCamera:SetDistance(inst.cameradistance:value())
        else
            TheCamera:SetDefault()
        end
    end
end

fns.OnYotbSkinDirty = function(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst.hasyotbskin:value() then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
        end
        inst._parent:PushEvent("yotbskinupdate", {
            active = inst.hasyotbskin:value() or false,
        })
    end
end

local function OnGiftsDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        inst._parent:PushEvent("giftreceiverupdate", {
            numitems = inst.hasgift:value() and 1 or 0,
            active = inst.hasgiftmachine:value(),
        })
    end
end

local function OnMountHurtDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        inst._parent:PushEvent("mounthurt", { hurt = inst.isridermounthurt:value() })
    end
end

local function DoSnapCamera(inst, resetrot)
    if resetrot then
        TheCamera:SetHeadingTarget(45)
    end
    TheCamera:Snap()
end

local function OnPlayerCameraSnap(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if TheWorld.ismastersim then
            DoSnapCamera(inst, inst.camerasnap:value())
        else
            inst:DoTaskInTime(0, DoSnapCamera, inst.camerasnap:value())
        end
    end
end

local function OnPlayerFadeDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        local iswhite = inst.fadetime:value() >= 32
        local time = iswhite and inst.fadetime:value() - 32 or inst.fadetime:value()
        if time > 0 then
            TheFrontEnd:Fade(inst.isfadein:value(), time / 10, nil, nil, nil, iswhite and "white" or "black")
            if inst.isfadein:value() then
                TheWorld.GroundCreep:FastForward()
            end
        else
            TheFrontEnd.fade_type = iswhite and "white" or "black"
            TheFrontEnd:SetFadeLevel(inst.isfadein:value() and 0 or 1)
        end
    end
end

local function OnWormholeTravelDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if inst._parent.player_classified.wormholetravelevent:value() == WORMHOLETYPE.WORM then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/teleportworm/travel")
        elseif inst._parent.player_classified.wormholetravelevent:value() == WORMHOLETYPE.TENTAPILLAR then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/cave/tentapiller_hole_travel")
        end
    end
end

local function OnHoundWarningDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        local soundprefab = nil
        if inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL1 then
            soundprefab = "houndwarning_lvl1"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL2 then
            soundprefab = "houndwarning_lvl2"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL3 then
            soundprefab = "houndwarning_lvl3"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL4 then
            soundprefab = "houndwarning_lvl4"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL1_WORM then
            soundprefab = "wormwarning_lvl1"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL2_WORM then
            soundprefab = "wormwarning_lvl2"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL3_WORM then
            soundprefab = "wormwarning_lvl3"
        elseif inst._parent.player_classified.houndwarningevent:value() == HOUNDWARNINGTYPE.LVL4_WORM then
            soundprefab = "wormwarning_lvl4"
        end
        if soundprefab then
            local sound = SpawnPrefab(soundprefab)
        end
    end
end

fns.StartFarmingMusicEvent = function(inst)
	inst._parent:PushEvent("playfarmingmusic")
end

local function OnMakeFriendEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
    end
end

local function OnFeedInContainerEvent(inst)
    if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/feed")
    end
end

local function OnMorgueDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil and not GetGameModeProperty("no_morgue_record") then
        Morgue:OnDeath({
            pk = inst.isdeathbypk:value() or nil,
            killed_by = inst.deathcause:value(),
            days_survived = inst._parent.Network:GetPlayerAge(),
            character = inst._parent.prefab,
            location = "unknown",
            world = TheWorld.meta ~= nil and TheWorld.meta.level_id or "unknown",
            server = TheNet:GetServerName(),
			date = os.date("%b %d, %y"),
        })
    end
end

--------------------------------------------------------------------------
--Server overriden to handle dirty events immediately
--otherwise server HUD events will be one wall-update late
--and possibly show some flicker
--------------------------------------------------------------------------
fns.SetGhostMode = function(inst, isghostmode)
    inst.isghostmode:set(isghostmode)
    OnGhostModeDirty(inst)
end

fns.ShowActions = function(inst, show)
    inst.isactionsvisible:set(show)
end

fns.ShowHUD = function(inst, show)
    inst.ishudvisible:set(show)
    OnPlayerHUDDirty(inst)
end

fns.EnableMapControls = function(inst, enable)
    inst.ismapcontrolsvisible:set(enable)
    OnPlayerHUDDirty(inst)
end

--------------------------------------------------------------------------

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
        inst:ListenForEvent("healthdelta", OnHealthDelta, inst._parent)
        inst:ListenForEvent("hungerdelta", OnHungerDelta, inst._parent)
        inst:ListenForEvent("sanitydelta", OnSanityDelta, inst._parent)
        inst:ListenForEvent("werenessdelta", OnWerenessDelta, inst._parent)
        inst:ListenForEvent("attacked", OnAttacked, inst._parent)
        inst:ListenForEvent("builditem", OnBuildSuccess, inst._parent)
        inst:ListenForEvent("buildstructure", OnBuildSuccess, inst._parent)
        inst:ListenForEvent("consumehealthcost", OnConsumeHealthCost, inst._parent)
        inst:ListenForEvent("learnrecipe", OnLearnRecipeSuccess, inst._parent)
        inst:ListenForEvent("learnmap", OnLearnMapSuccess, inst._parent)
        inst:ListenForEvent("repair", OnRepairSuccess, inst._parent)
        inst:ListenForEvent("performaction", OnPerformAction, inst._parent)
        inst:ListenForEvent("actionfailed", OnActionFailed, inst._parent)
        inst:ListenForEvent("carefulwalking", OnCarefulWalking, inst._parent)
        inst:ListenForEvent("wormholetravel", OnWormholeTravel, inst._parent)
        inst:ListenForEvent("makefriend", OnMakeFriend, inst._parent)
        inst:ListenForEvent("feedincontainer", OnFeedInContainer, inst._parent)
        inst:ListenForEvent("houndwarning", OnHoundWarning, inst._parent)
        inst:ListenForEvent("play_theme_music", fns.OnPlayThemeMusic, inst._parent)
    else
        inst.ishealthpulseup:set_local(false)
        inst.ishealthpulsedown:set_local(false)
        inst.ishungerpulseup:set_local(false)
        inst.ishungerpulsedown:set_local(false)
        inst.issanitypulseup:set_local(false)
        inst.issanitypulsedown:set_local(false)
        inst.iswerenesspulseup:set_local(false)
        inst.iswerenesspulsedown:set_local(false)
        inst.pausepredictionframes:set_local(0)
        inst:ListenForEvent("healthdirty", OnHealthDirty)
        inst:ListenForEvent("istakingfiredamagedirty", OnIsTakingFireDamageDirty)
        inst:ListenForEvent("istakingfiredamagelowdirty", OnIsTakingFireDamageLowDirty)
        inst:ListenForEvent("combat.attackedpulse", OnAttackedPulseEvent)
        inst:ListenForEvent("hungerdirty", OnHungerDirty)
        inst:ListenForEvent("sanitydirty", OnSanityDirty)
        inst:ListenForEvent("werenessdirty", OnWerenessDirty)
        inst:ListenForEvent("inspirationdirty", fns.OnInspirationDirty)
		inst:ListenForEvent("inspirationsong1dirty", function(_inst) fns.OnInspirationSongsDirty(_inst, 1) end)
		inst:ListenForEvent("inspirationsong2dirty", function(_inst) fns.OnInspirationSongsDirty(_inst, 2) end)
		inst:ListenForEvent("inspirationsong3dirty", function(_inst) fns.OnInspirationSongsDirty(_inst, 3) end)
        inst:ListenForEvent("mightinessdirty", OnMightinessDirty)
        inst:ListenForEvent("upgrademoduleenergyupdate", fns.OnEnergyLevelDirty)
        inst:ListenForEvent("upgrademoduleslistdirty", fns.OnUpgradeModulesListDirty)
        inst:ListenForEvent("uirobotsparksevent", fns.OnUIRobotSparks)
        inst:ListenForEvent("temperaturedirty", OnTemperatureDirty)
        inst:ListenForEvent("moisturedirty", OnMoistureDirty)
        inst:ListenForEvent("techtreesdirty", OnTechTreesDirty)
        inst:ListenForEvent("recipesdirty", OnRecipesDirty)
        inst:ListenForEvent("bufferedbuildsdirty", OnBufferedBuildsDirty)
        inst:ListenForEvent("isperformactionsuccessdirty", OnIsPerformActionSuccessDirty)
        inst:ListenForEvent("pausepredictionframesdirty", OnPausePredictionFramesDirty)
        inst:ListenForEvent("iscarefulwalkingdirty", OnIsCarefulWalkingDirty)
        inst:ListenForEvent("isghostmodedirty", OnGhostModeDirty)
        inst:ListenForEvent("actionmeterdirty", OnActionMeterDirty)
        inst:ListenForEvent("playerhuddirty", OnPlayerHUDDirty)
        inst:ListenForEvent("playercamerashake", OnPlayerCameraShake)
        inst:ListenForEvent("playerscreenflashdirty", OnPlayerScreenFlashDirty)
        inst:ListenForEvent("attunedresurrectordirty", OnAttunedResurrectorDirty)
        
        

        OnIsTakingFireDamageDirty(inst)
        OnTemperatureDirty(inst)
        OnTechTreesDirty(inst)
        if inst._parent ~= nil then
            inst._oldhealthpercent = inst.maxhealth:value() > 0 and inst.currenthealth:value() / inst.maxhealth:value() or 0
            inst._oldhungerpercent = inst.maxhunger:value() > 0 and inst.currenthunger:value() / inst.maxhunger:value() or 0
            inst._oldsanitypercent = inst.maxsanity:value() > 0 and inst.currentsanity:value() / inst.maxsanity:value() or 0
            inst._oldwerenesspercent = inst.currentwereness:value() * .01
            inst._oldinspirationpercent = inst.currentinspiration:value() * .01
            inst._oldmightinesspercent = inst.currentmightiness:value() * .01
            inst._oldmoisture = inst.moisture:value()
            UpdateAnimOverrideSanity(inst._parent)
        end
    end

    inst:ListenForEvent("gym_bell_start", fns.OnGymBellStart)
    inst:ListenForEvent("inmightygymdirty", fns.InMightyGymDirty)
    inst:ListenForEvent("stormleveldirty", OnStormLevelDirty)
    inst:ListenForEvent("hasinspirationbuffdirty", fns.OnHasInspirationBuffDirty)
    inst:ListenForEvent("builder.build", OnBuildEvent)
    inst:ListenForEvent("builder.damaged", OnBuilderDamagedEvent)
    inst:ListenForEvent("builder.opencraftingmenu", OnOpenCraftingMenuEvent)
    inst:ListenForEvent("builder.learnrecipe", OnLearnRecipeEvent)
    inst:ListenForEvent("inked", OnInkedEvent)
    inst:ListenForEvent("MapExplorer.learnmap", OnLearnMapEvent)
	inst:ListenForEvent("MapSpotRevealer.revealmapspot", OnRevealMapSpotEvent)
    inst:ListenForEvent("repair.repair", OnRepairEvent)
    inst:ListenForEvent("giftsdirty", OnGiftsDirty)
    inst:ListenForEvent("yotbskindirty", fns.OnYotbSkinDirty)
    inst:ListenForEvent("ismounthurtdirty", OnMountHurtDirty)
    inst:ListenForEvent("playercameradirty", OnPlayerCameraDirty)
    inst:ListenForEvent("playercamerasnap", OnPlayerCameraSnap)
    inst:ListenForEvent("playerfadedirty", OnPlayerFadeDirty)
    inst:ListenForEvent("wormholetraveldirty", OnWormholeTravelDirty)
    inst:ListenForEvent("leader.makefriend", OnMakeFriendEvent)
    inst:ListenForEvent("eater.feedincontainer", OnFeedInContainerEvent)
    inst:ListenForEvent("morguedirty", OnMorgueDirty)
    inst:ListenForEvent("houndwarningdirty", OnHoundWarningDirty)
	inst:ListenForEvent("startfarmingmusicevent", fns.StartFarmingMusicEvent)
    inst:ListenForEvent("ingredientmoddirty", fns.RefreshCrafting)

    OnStormLevelDirty(inst)
    OnGiftsDirty(inst)
    fns.OnYotbSkinDirty(inst)
    OnMountHurtDirty(inst)
    OnGhostModeDirty(inst)
    OnPlayerHUDDirty(inst)
    OnPlayerCameraDirty(inst)

    --Fade is initialized by OnPlayerActivated in gamelogic.lua
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform() --So we can follow parent's sleep state
    inst.entity:AddMapExplorer()
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    --Health variables
    inst._oldhealthpercent = 1
    inst.currenthealth = net_ushortint(inst.GUID, "health.currenthealth", "healthdirty")
    inst.maxhealth = net_ushortint(inst.GUID, "health.maxhealth", "healthdirty")
    inst.healthpenalty = net_byte(inst.GUID, "health.penalty", "healthdirty")
    inst.istakingfiredamage = net_bool(inst.GUID, "health.takingfiredamage", "istakingfiredamagedirty")
    inst.istakingfiredamagelow = net_bool(inst.GUID, "health.takingfiredamagelow", "istakingfiredamagelowdirty")
    inst.issleephealing = net_bool(inst.GUID, "health.healthsleep")
    inst.ishealthpulseup = net_bool(inst.GUID, "health.dodeltaovertime(up)", "healthdirty")
    inst.ishealthpulsedown = net_bool(inst.GUID, "health.dodeltaovertime(down)", "healthdirty")
    inst.currenthealth:set(100)
    inst.maxhealth:set(100)

    --Hunger variables
    inst._oldhungerpercent = 1
    inst.currenthunger = net_ushortint(inst.GUID, "hunger.current", "hungerdirty")
    inst.maxhunger = net_ushortint(inst.GUID, "hunger.max", "hungerdirty")
    inst.ishungerpulseup = net_bool(inst.GUID, "hunger.dodeltaovertime(up)", "hungerdirty")
    inst.ishungerpulsedown = net_bool(inst.GUID, "hunger.dodeltaovertime(down)", "hungerdirty")
    inst.currenthunger:set(100)
    inst.maxhunger:set(100)

    --Sanity variables
    inst._oldsanitypercent = 1
    inst.currentsanity = net_ushortint(inst.GUID, "sanity.current", "sanitydirty")
    inst.maxsanity = net_ushortint(inst.GUID, "sanity.max", "sanitydirty")
    inst.sanitypenalty = net_byte(inst.GUID, "sanity.penalty", "sanitydirty")
    inst.sanityratescale = net_tinybyte(inst.GUID, "sanity.ratescale")
    inst.issanitypulseup = net_bool(inst.GUID, "sanity.dodeltaovertime(up)", "sanitydirty")
    inst.issanitypulsedown = net_bool(inst.GUID, "sanity.dodeltaovertime(down)", "sanitydirty")
    inst.issanityghostdrain = net_bool(inst.GUID, "sanity.ghostdrain")
    inst.currentsanity:set(100)
    inst.maxsanity:set(100)

    --Wereness variables
    inst._oldwerenesspercent = 0
    inst.currentwereness = net_byte(inst.GUID, "wereness.current", "werenessdirty")
    inst.iswerenesspulseup = net_bool(inst.GUID, "wereness.dodeltaovertime(up)", "werenessdirty")
    inst.iswerenesspulsedown = net_bool(inst.GUID, "wereness.dodeltaovertime(down)", "werenessdirty")
    inst.werenessdrainrate = net_smallbyte(inst.GUID, "wereness.drainrate")

	--inspiration variables
    inst._oldinspirationpercent = 0
    inst.currentinspiration = net_byte(inst.GUID, "inspiration.current", "inspirationdirty")
    inst.inspirationdraining = net_bool(inst.GUID, "inspiration.draining", "inspirationdirty")
    inst.inspirationsongs =
	{
		net_tinybyte(inst.GUID, "inspiration.song1", "inspirationsong1dirty"),
		net_tinybyte(inst.GUID, "inspiration.song2", "inspirationsong2dirty"),
		net_tinybyte(inst.GUID, "inspiration.song3", "inspirationsong3dirty"),
	}
    inst.hasinspirationbuff = net_bool(inst.GUID, "inspiration.hasbuff", "hasinspirationbuffdirty")
    
    -- Mightiness
    --mighty gym variables
    -- this is used to know if someone is on a gym but also what the weight on the gym is when used.
    -- 0 = not on a gym
    -- 1 - 7 .. on a gym and the weight is x + 1. So values of 2 to 8
    inst.inmightygym = net_tinybyte(inst.GUID, "mightygym.in", "inmightygymdirty")
    inst.inmightygym:set(0)


    inst.gym_bell_start = net_event(inst.GUID, "gym_bell_start")
    inst.currentmightiness = net_byte(inst.GUID, "mightiness.current", "mightinessdirty")
    inst.mightinessratescale = net_tinybyte(inst.GUID, "mightiness.ratescale")

    -- Upgrade Module Owner
    inst.uirobotsparksevent = net_event(inst.GUID, "uirobotsparksevent")

    inst._oldcurrentenergylevel = 0
    inst.currentenergylevel = net_smallbyte(inst.GUID, "upgrademodules.currentenergylevel", "upgrademoduleenergyupdate")

    inst.upgrademodules =
    {
        net_smallbyte(inst.GUID, "upgrademodules.mods1", "upgrademoduleslistdirty"),
        net_smallbyte(inst.GUID, "upgrademodules.mods2", "upgrademoduleslistdirty"),
        net_smallbyte(inst.GUID, "upgrademodules.mods3", "upgrademoduleslistdirty"),
        net_smallbyte(inst.GUID, "upgrademodules.mods4", "upgrademoduleslistdirty"),
        net_smallbyte(inst.GUID, "upgrademodules.mods5", "upgrademoduleslistdirty"),
        net_smallbyte(inst.GUID, "upgrademodules.mods6", "upgrademoduleslistdirty"),
    }

	-- oldager
    inst.oldager_yearpercent = net_float(inst.GUID, "oldager.yearpercent")
    inst.oldager_rate = net_smallbyte(inst.GUID, "oldager.rate") -- use the Get and Set functions because this value is a signed value incoded into an unsigned net_var
	inst.GetOldagerRate = fns.GetOldagerRate

    --Temperature variables
    inst._oldtemperature = TUNING.STARTING_TEMP
    inst.currenttemperature = inst._oldtemperature
    inst.currenttemperaturedata = net_byte(inst.GUID, "temperature.current", "temperaturedirty")
    SetTemperature(inst, inst.currenttemperature)

    --Moisture variables
    inst._oldmoisture = 0
    inst.moisture = net_ushortint(inst.GUID, "moisture.moisture", "moisturedirty")
    inst.maxmoisture = net_ushortint(inst.GUID, "moisture.maxmoisture")
    inst.moistureratescale = net_tinybyte(inst.GUID, "moisture.ratescale", "moisturedirty")
    inst.maxmoisture:set(100)

    --StormWatcher variables
    inst.stormlevel = net_tinybyte(inst.GUID, "stormwatcher.stormlevel", "stormleveldirty")
    inst.stormtype = net_tinybyte(inst.GUID, "stormwatcher.stormtype")

    --Inked variables
    inst.inked = net_event(inst.GUID, "inked")

    --PlayerController variables
    inst._pausepredictiontask = nil
    inst.pausepredictionframes = net_tinybyte(inst.GUID, "playercontroller.pausepredictionframes", "pausepredictionframesdirty")
    inst.iscontrollerenabled = net_bool(inst.GUID, "playercontroller.enabled")
    inst.iscontrollerenabled:set(true)

    --PlayerVoter variables
    inst.voteselection = net_tinybyte(inst.GUID, "playervoter.selection", "voteselectiondirty")
    inst.votesquelched = net_bool(inst.GUID, "playervoter.issquelched")

    --Player HUD variables
    inst.ishudvisible = net_bool(inst.GUID, "playerhud.isvisible", "playerhuddirty")
    inst.ismapcontrolsvisible = net_bool(inst.GUID, "playerhud.ismapcontrolsvisible", "playerhuddirty")
    inst.isactionsvisible = net_bool(inst.GUID, "playerhud.isactionsvisible")
    inst.ishudvisible:set(true)
    inst.ismapcontrolsvisible:set(true)
    inst.isactionsvisible:set(true)

    --Player camera variables
    inst.cameradistance = net_smallbyte(inst.GUID, "playercamera.distance", "playercameradirty")
    inst.iscamerazoomed = net_bool(inst.GUID, "playercamera.iscamerazoomed", "playercameradirty")
    inst.camerasnap = net_bool(inst.GUID, "playercamera.snap", "playercamerasnap")
    inst.camerashakemode = net_tinybyte(inst.GUID, "playercamera.shakemode", "playercamerashake")
    inst.camerashaketime = net_byte(inst.GUID, "playercamera.shaketime")
    inst.camerashakespeed = net_byte(inst.GUID, "playercamera.shakespeed")
    inst.camerashakescale = net_byte(inst.GUID, "playercamera.shakescale")

    --Player front end variables
    inst.isfadein = net_bool(inst.GUID, "frontend.isfadein", "playerfadedirty")
    inst.fadetime = net_smallbyte(inst.GUID, "frontend.fadetime", "playerfadedirty")
    inst.screenflash = net_tinybyte(inst.GUID, "frontend.screenflash", "playerscreenflashdirty")
    inst.wormholetravelevent = net_tinybyte(inst.GUID, "frontend.wormholetravel", "wormholetraveldirty")
    inst.houndwarningevent = net_tinybyte(inst.GUID, "frontend.houndwarning", "houndwarningdirty")

	-- busy theme music
    inst.start_farming_music = net_event(inst.GUID, "startfarmingmusicevent")

    inst.isfadein:set(true)

    --Builder variables
    inst.buildevent = net_event(inst.GUID, "builder.build")
    inst.builderdamagedevent = net_event(inst.GUID, "builder.damaged")
    inst.learnrecipeevent = net_event(inst.GUID, "builder.learnrecipe")
    inst.techtrees = deepcopy(TECH.NONE)
    inst.ingredientmod = net_tinybyte(inst.GUID, "builder.ingredientmod", "ingredientmoddirty")
    for i, v in ipairs(TechTree.BONUS_TECH) do
        local bonus = net_tinybyte(inst.GUID, "builder."..string.lower(v).."bonus")
		inst[string.lower(v).."bonus"] = bonus
    end
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        local level = net_tinybyte(inst.GUID, "builder.accessible_tech_trees."..v, "techtreesdirty")
        level:set(inst.techtrees[v])
        inst[string.lower(v).."level"] = level
    end
    inst.isfreebuildmode = net_bool(inst.GUID, "builder.freebuildmode", "recipesdirty")
	inst.current_prototyper = net_entity(inst.GUID, "builder.current_prototyper", "current_prototyper_dirty")
    inst.opencraftingmenuevent = net_event(inst.GUID, "builder.opencraftingmenu")
    inst.recipes = {}
    inst.bufferedbuilds = {}
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) then
            inst.recipes[k] = net_bool(inst.GUID, "builder.recipes["..k.."]", "recipesdirty")
            inst.bufferedbuilds[k] = net_bool(inst.GUID, "builder.buffered_builds["..k.."]", "bufferedbuildsdirty")
        end
    end
    inst.ingredientmod:set(INGREDIENT_MOD[1])

    --MapExplorer variables
    inst.learnmapevent = net_event(inst.GUID, "MapExplorer.learnmap")

	--MapSpotRevealer variables
	inst.revealmapspotevent = net_event(inst.GUID, "MapSpotRevealer.revealmapspot")
	inst.revealmapspot_worldx = net_float(inst.GUID, "MapSpotRevealer.worldx")--note from branch: "second argument?"
	inst.revealmapspot_worldz = net_float(inst.GUID, "MapSpotRevealer.worldz")

    --Repair variables
    inst.repairevent = net_event(inst.GUID, "repair.repair")

    -- Groomer variables
    inst.hasyotbskin = net_bool(inst.GUID, "groomer.hasyotbskin", "yotbskindirty")

    --GiftReceiver variables
    inst.hasgift = net_bool(inst.GUID, "giftreceiver.hasgift", "giftsdirty")
    inst.hasgiftmachine = net_bool(inst.GUID, "giftreceiver.hasgiftmachine", "giftsdirty")

    --Combat variables
    inst.lastcombattarget = net_entity(inst.GUID, "combat.lasttarget")
    inst.canattack = net_bool(inst.GUID, "combat.canattack")
    inst.minattackperiod = net_float(inst.GUID, "combat.minattackperiod")
    inst.attackedpulseevent = net_event(inst.GUID, "combat.attackedpulse")
    inst.isattackedbydanger = net_bool(inst.GUID, "combat.isattackedbydanger")
    inst.isattackredirected = net_bool(inst.GUID, "combat.isattackredirected")
    inst.canattack:set(true)
    inst.minattackperiod:set(4)

    --Leader variables
    inst.makefriendevent = net_event(inst.GUID, "leader.makefriend")

    --Eater variables (more like feeding) (more like an event for playing a client sound)
    inst.feedincontainerevent = net_event(inst.GUID, "eater.feedincontainer")

    --Rider variables
    inst.ridermount = net_entity(inst.GUID, "rider.mount")
    inst.ridersaddle = net_entity(inst.GUID, "rider.saddle")
    inst.isridermounthurt = net_bool(inst.GUID, "rider.mounthurt", "ismounthurtdirty")
    inst.riderrunspeed = net_float(inst.GUID, "rider.runspeed")
    inst.riderfasteronroad = net_bool(inst.GUID, "rider.fasteronroad")
    inst.riderrunspeed:set(TUNING.BEEFALO_RUN_SPEED.DEFAULT) --V2C: just pick the most likely value to be the default for pristine state

    --TouchStoneTracker variables
    inst.touchstonetrackerused = net_smallbytearray(inst.GUID, "touchstonetracker.used")

    --Stategraph variables
    inst.isperformactionsuccess = net_bool(inst.GUID, "sg.isperformactionsuccess", "isperformactionsuccessdirty")
    inst.isghostmode = net_bool(inst.GUID, "sg.isghostmode", "isghostmodedirty")
    inst.actionmeter = net_byte(inst.GUID, "sg.actionmeter", "actionmeterdirty")
    inst.actionmetertime = net_byte(inst.GUID, "sg.actionmetertime", "actionmeterdirty")

    --Locomotor variables
    inst.runspeed = net_float(inst.GUID, "locomotor.runspeed")
    inst.externalspeedmultiplier = net_float(inst.GUID, "locomotor.externalspeedmultiplier")
    inst.runspeed:set(TUNING.WILSON_RUN_SPEED)
    inst.externalspeedmultiplier:set(1)

    --CarefulWalking variables
    inst.iscarefulwalking = net_bool(inst.GUID, "carefulwalking.careful", "iscarefulwalkingdirty")

    --Morgue variables
    inst.isdeathbypk = net_bool(inst.GUID, "morgue.isdeathbypk", "morguedirty")
    inst.deathcause = net_string(inst.GUID, "morgue.deathcause")

    --Delay net listeners until after initial values are deserialized
    inst:DoStaticTaskInTime(0, RegisterNetListeners)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst._refreshtask = nil
        inst._bufferedbuildspreview = {}

        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated
        inst.BufferBuild = BufferBuild

        return inst
    end

    --Server interface
    inst.SetValue = SetValue
    inst.PushPausePredictionFrames = PushPausePredictionFrames
    inst.AddMorgueRecord = AddMorgueRecord
    inst.SetTemperature = SetTemperature
    inst.SetUsedTouchStones = SetUsedTouchStones
    inst.SetGhostMode = fns.SetGhostMode
    inst.ShowActions = fns.ShowActions
    inst.ShowHUD = fns.ShowHUD
    inst.EnableMapControls = fns.EnableMapControls
	inst.SetOldagerRate = fns.SetOldagerRate

    inst.persists = false

    return inst
end

return Prefab("player_classified", fn)
