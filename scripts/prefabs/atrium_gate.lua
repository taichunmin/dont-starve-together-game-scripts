require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/atrium_gate.zip"),
    Asset("ANIM", "anim/atrium_gate_build.zip"),
    Asset("ANIM", "anim/atrium_floor.zip"),
    Asset("MINIMAP_IMAGE", "atrium_gate_active"),
    Asset("MINIMAP_IMAGE", "atrium_gate_fixed"),
    Asset("MINIMAP_IMAGE", "atrium_gate_fixed_active"),
}

local prefabs =
{
    "atrium_key",
    "atrium_gate_activatedfx",
    "atrium_gate_pulsesfx",
    "atrium_gate_explodesfx",
    "charlie_hand",
}

local EXPLOSION_ANIM_LEN = 86 * FRAMES

--------------------------------------------------------------------------

local ATRIUM_ARENA_SIZE = 14.55

local function IsObjectInAtriumArena(inst, obj)
    if obj == nil then
        return false
    end
    local obj_x, _, obj_z = obj.Transform:GetWorldPosition()
    local inst_x, _, inst_z = inst.Transform:GetWorldPosition()
    return math.abs(obj_x - inst_x) < ATRIUM_ARENA_SIZE
        and math.abs(obj_z - inst_z) < ATRIUM_ARENA_SIZE
end

--------------------------------------------------------------------------

local function OnFocusCamera(inst)
    if inst._camerafocusvalue > FRAMES then
        inst._camerafocusvalue = inst._camerafocusvalue - FRAMES
        local k = math.min(1, inst._camerafocusvalue) / 1
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 10 * k, 28 * k, 4)
    else
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
        inst._camerafocusvalue = nil
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() > 0 then
        if inst._camerafocus:value() <= 1 then
            inst._camerafocusvalue = math.huge
            if inst._camerafocustask == nil then
                inst._camerafocustask = inst:DoPeriodicTask(0, OnFocusCamera)
                OnFocusCamera(inst)
            end
        elseif inst._camerafocustask ~= nil then
            inst._camerafocusvalue = 3
            OnFocusCamera(inst)
        end
    elseif inst._camerafocustask ~= nil then
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
        inst._camerafocusvalue = nil
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function SetCameraFocus(inst, level)
    if level ~= inst._camerafocus:value() then
        inst._camerafocus:set(level)
        if not TheNet:IsDedicated() then
            OnCameraFocusDirty(inst)
        end
    end
end

--------------------------------------------------------------------------

local SUPPRESS_SHADOWS_RANGE = math.ceil(ATRIUM_ARENA_SIZE + 5)
local SUPPRESS_SHADOWS_MUST_TAGS = { "_health" }
local SUPPRESS_SHADOWS_ONEOF_TAGS = { "stalkerminion", "shadowcreature" }

local function OnSuppressShadows(inst, x, z, range)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, range, SUPPRESS_SHADOWS_MUST_TAGS, nil, SUPPRESS_SHADOWS_ONEOF_TAGS)) do
        if not v.components.health:IsDead() then
            local x1, y1, z1 = v.Transform:GetWorldPosition()
            if math.abs(x1 - x) < SUPPRESS_SHADOWS_RANGE and
                math.abs(z1 - z) < SUPPRESS_SHADOWS_RANGE then
                if v.components.lootdropper ~= nil then
                    v.components.lootdropper:SetLoot(nil)
                    v.components.lootdropper:SetChanceLootTable(nil)
                end
                v.components.health:Kill()
            end
        end
    end
end

local function EnableShadowSuppression(inst, enable)
    if enable then
        if inst._shadowsuppressiontask == nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local range = math.sqrt(SUPPRESS_SHADOWS_RANGE * SUPPRESS_SHADOWS_RANGE * 2)
            inst._shadowsuppressiontask = inst:DoPeriodicTask(1, OnSuppressShadows, nil, x, z, range)
            OnSuppressShadows(inst, x, z, range)
        end
    elseif inst._shadowsuppressiontask ~= nil then
        inst._shadowsuppressiontask:Cancel()
        inst._shadowsuppressiontask = nil
    end
end

--------------------------------------------------------------------------

local function IsDestabilizing(inst)
    return inst.components.worldsettingstimer:ActiveTimerExists("destabilizing")
end

local function ShowFx(inst, state)
    if inst._gatefx == nil then
        inst._gatefx = SpawnPrefab("atrium_gate_activatedfx")
        inst._gatefx.entity:SetParent(inst.entity)
        table.insert(inst.highlightchildren, inst._gatefx)
    end

    inst._gatefx:SetFX(state)
end

local function HideFx(inst)
    if inst._gatefx ~= nil then
        inst._gatefx:KillFX()
        inst._gatefx = nil
    end
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "atrium_key" then
        return false, "NOTATRIUMKEY"
    end
    return true
end

local function OnKeyGiven(inst, giver)
    --Disable trading, enable picking.
    inst.components.trader:Disable()
    inst.components.pickable:SetUp("atrium_key", 1000000)
    inst.components.pickable:Pause()
    inst.components.pickable.caninteractwith = true

    inst.AnimState:PlayAnimation("idle_active")

    local repaired = inst.components.charliecutscene:IsGateRepaired()
    inst.MiniMapEntity:SetIcon(repaired and "atrium_gate_fixed_active.png" or "atrium_gate_active.png")

    TheWorld:PushEvent("atriumpowered", true)
    TheWorld:PushEvent("ms_locknightmarephase", "wild")
    TheWorld:PushEvent("pausequakes", { source = inst })
    TheWorld:PushEvent("pausehounded", { source = inst })

    if giver ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")

--      if giver.components.talker ~= nil then
--          giver.components.talker:Say(GetString(giver, "ANNOUNCE_GATE_ON"))
--      end
    end
end

local function OnKeyTaken(inst)
    --Disable picking, enable trading.
    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst:RemoveTag("intense")

    inst.SoundEmitter:KillSound("loop")

    inst.AnimState:PlayAnimation("idle")

    local repaired = inst.components.charliecutscene:IsGateRepaired()
    inst.MiniMapEntity:SetIcon(repaired and "atrium_gate_fixed.png" or "atrium_gate.png")

    HideFx(inst)

    TheWorld:PushEvent("atriumpowered", false)
    TheWorld:PushEvent("ms_locknightmarephase", nil)
    TheWorld:PushEvent("unpausequakes", { source = inst })
    TheWorld:PushEvent("unpausehounded", { source = inst })
end

local function DoPlayerWarning(inst, player)
    if player:IsValid() then
        player.components.talker:Say(GetString(player, "ANNOUNCE_ATRIUM_DESTABILIZING"))
    end
end

local function OnDestabilizingPulse(inst)
    inst.talkertick = inst.talkertick ~= nil and inst.talkertick + 1 or 0

    if not inst:IsDestabilizing() then
        inst.destabilizingnotificationtask:Cancel()
        inst.destabilizingnotificationtask = nil
        return
    end

    for i, player in ipairs(AllPlayers) do
        if player.components.areaaware:CurrentlyInTag("Nightmare") then
            if not IsObjectInAtriumArena(inst, player) then
                player:ShakeCamera(CAMERASHAKE.SIDE, 1, .02, .25)
                if (inst.talkertick % 2) == (i % 2) then
                    inst:DoTaskInTime(1, DoPlayerWarning, player)
                end
            else
                player:ShakeCamera(CAMERASHAKE.SIDE, 2, .06, .25)
                inst:DoTaskInTime(1, DoPlayerWarning, player)
            end
        end
    end

    SpawnPrefab("atrium_gate_pulsesfx").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.AnimState:PlayAnimation("overload_pulse")
    inst.AnimState:PushAnimation("overload_loop")
end

local function StartDestabilizing(inst, onload)
    inst.components.trader:Disable()
    inst.components.pickable.caninteractwith = false
    inst:RemoveTag("intense")
    SetCameraFocus(inst, 2)
    EnableShadowSuppression(inst, true)

    if not inst.components.worldsettingstimer:ActiveTimerExists("destabilizing") then
        inst.components.worldsettingstimer:StartTimer("destabilizing", TUNING.ATRIUM_GATE_DESTABILIZE_TIME)
    end

    if not onload then
        TheWorld:PushEvent("atriumpowered", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/shadow_pulse")
    end

    ShowFx(inst, "overload")
    if inst._disablelighttask ~= nil then
        inst._disablelighttask:Cancel()
        inst._disablelighttask = nil
    end
    inst.Light:Enable(true)
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/destabilize_LP", "loop")
    inst.AnimState:PlayAnimation("overload_pre")
    inst.AnimState:PushAnimation("overload_loop", true)

    inst.destabilizingnotificationtask = inst:DoPeriodicTask(TUNING.ATRIUM_GATE_DESTABILIZE_WARNING_TIME, OnDestabilizingPulse, TUNING.ATRIUM_GATE_DESTABILIZE_WARNING_INITIAL_TIME)
end

local function OnQueueDestabilize(inst, onload)
    if onload then
        ShowFx(inst, "idle")
        inst.AnimState:PlayAnimation("idle_fight", true)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/active_LP", "loop")
    end

    inst.components.trader:Disable()
    inst.components.pickable.caninteractwith = false
    inst:RemoveTag("intense")
    SetCameraFocus(inst, 1)
    EnableShadowSuppression(inst, true)

    if inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay") then
        inst.components.worldsettingstimer:StopTimer("destabilizedelay")
    end

    inst.components.worldsettingstimer:StartTimer("destabilizedelay", TUNING.ATRIUM_GATE_DESTABILIZE_DELAY)
end

local function Destabilize(inst, failed)
    if inst.components.pickable.caninteractwith then
        if not failed then
            OnQueueDestabilize(inst)
        else
            local key = SpawnPrefab("atrium_key")
            LaunchAt(key, inst, nil, 1.5, 1, 1)

            OnKeyTaken(inst)
        end
    end
end

local function DisableLight(inst)
    inst._disablelighttask = nil
    inst.Light:Enable(false)
end

local function OnDestabilizeExplode(inst)
    SetCameraFocus(inst, 0)
    EnableShadowSuppression(inst, false)
    inst.AnimState:PlayAnimation("overload_pst", false)
    SpawnPrefab("atrium_gate_explodesfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    HideFx(inst)
    if inst._disablelighttask ~= nil then
        inst._disablelighttask:Cancel()
    end
    inst._disablelighttask = inst:DoTaskInTime(1.75, DisableLight)

    inst:StartCooldown(false)

    TheWorld:PushEvent("resetruins")

    for _, player in ipairs(AllPlayers) do
        player.components.talker:Say(GetString(player, "ANNOUNCE_RUINS_RESET"))
        player:ShakeCamera(CAMERASHAKE.SIDE, 2, .06, .25)
    end
end

local function ForceDestabilizeExplode(inst)
    -- returns true if a destabilization was actually forced
    if inst:IsDestabilizing() then
        -- Force the atrium gate to finish its destabilization process.
        OnDestabilizeExplode(inst)
        if inst.components.worldsettingstimer:ActiveTimerExists("destabilizing") then
            inst.components.worldsettingstimer:StopTimer("destabilizing")
        end

        return true
    end

    return false
end

local function OnCooldown(inst)
    if inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
        inst.AnimState:PlayAnimation("cooldown", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/cooldown_LP", "loop")
    end
end

local function StartCooldown(inst, immediate)
    if inst.components.worldsettingstimer:ActiveTimerExists("destabilizing") then
        inst.components.worldsettingstimer:StopTimer("destabilizing")
        OnDestabilizeExplode(inst)
    end

    SetCameraFocus(inst, 0)
    EnableShadowSuppression(inst, false)
    inst:RemoveTag("intense")
    inst.components.pickable.caninteractwith = false
    inst.components.trader:Disable()
    inst.SoundEmitter:KillSound("loop")
    TheWorld:PushEvent("ms_locknightmarephase", nil)
    TheWorld:PushEvent("unpausequakes", { source = inst })
    TheWorld:PushEvent("unpausehounded", { source = inst })

    if immediate then
        inst.AnimState:PlayAnimation("cooldown", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/cooldown_LP", "loop")
    else
        inst:DoTaskInTime(EXPLOSION_ANIM_LEN, OnCooldown)
    end

    if not inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
        inst.components.worldsettingstimer:StartTimer("cooldown", TUNING.ATRIUM_GATE_COOLDOWN)
    end
end

local function OnTrackStalker(inst, stalker)
    if stalker.components.health ~= nil and not stalker.components.health:IsDead() then
        inst:ListenForEvent("onremove", inst._onremovestalker, stalker)
        inst:ListenForEvent("death", inst._onstalkerdeath, stalker)
        inst:AddTag("intense")
        SetCameraFocus(inst, 0)
        EnableShadowSuppression(inst, false)
        ShowFx(inst, "idle")
        inst.AnimState:PlayAnimation("idle_fight", true)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/active_LP", "loop")
    else
        --cleanup bad state, shouldn't reach here normally
        --but possible with corrupt or tampering save data
        inst.components.entitytracker:ForgetEntity("stalker")
    end
end

local function TrackStalker(inst, stalker)
    local old = inst.components.entitytracker:GetEntity("stalker")
    if old ~= stalker then
        if old ~= nil then
            inst.components.entitytracker:ForgetEntity("stalker")
            inst:RemoveEventCallback("onremove", inst._onremovestalker, old)
            inst:RemoveEventCallback("death", inst._onstalkerdeath, old)
        end
        inst.components.entitytracker:TrackEntity("stalker", stalker)

        if not inst.components.pickable.caninteractwith then
            OnKeyGiven(inst)
        end

        OnTrackStalker(inst, stalker)
    end
end

local function ontimer(inst, data)
    if data.name == "destabilizedelay" then
        StartDestabilizing(inst)
    elseif data.name == "destabilizing" then
        OnDestabilizeExplode(inst)
    elseif data.name == "cooldown" then
        inst.AnimState:PlayAnimation("idle")
        inst.components.trader:Enable()
        inst.SoundEmitter:KillSound("loop")
    end
end

local function getstatus(inst)
    return (inst:IsDestabilizing() and "DESTABILIZING")
        or (inst.components.worldsettingstimer:ActiveTimerExists("cooldown") and "COOLDOWN")
        or ((inst:HasTag("intense") or inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay")) and "CHARGING")
        or (inst.components.pickable.caninteractwith and "ON")
        or "OFF"
end

local function IsWaitingForStalker(inst)
    return getstatus(inst) == "ON"
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = getstatus(inst) == "ON" and inst:DoTaskInTime(10, function() if getstatus(inst) == "ON" then Destabilize(inst, true) end end) or nil
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function OnLoadPostPass(inst, ents, data)
    if inst:IsDestabilizing() then
        StartDestabilizing(inst, true)
    elseif inst.components.worldsettingstimer:ActiveTimerExists("cooldown") then
        StartCooldown(inst, true)
    elseif inst.components.pickable.caninteractwith or inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay") then
        OnKeyGiven(inst)

        local stalker = inst.components.entitytracker:GetEntity("stalker")
        if stalker ~= nil then
            OnTrackStalker(inst, stalker)
        end

        if inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay") then
            OnQueueDestabilize(inst, true)
        end
    end
end

local function InitializePathFinding(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    TheWorld.Pathfinder:AddWall(x - 0.5, 0, z - 0.5)
    TheWorld.Pathfinder:AddWall(x - 0.5, 0, z + 0.5)
    TheWorld.Pathfinder:AddWall(x + 0.5, 0, z - 0.5)
    TheWorld.Pathfinder:AddWall(x + 0.5, 0, z + 0.5)
end

local function OnRemove(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    TheWorld.Pathfinder:RemoveWall(x - 0.5, 0, z - 0.5)
    TheWorld.Pathfinder:RemoveWall(x - 0.5, 0, z + 0.5)
    TheWorld.Pathfinder:RemoveWall(x + 0.5, 0, z - 0.5)
    TheWorld.Pathfinder:RemoveWall(x + 0.5, 0, z + 0.5)
end

--------------------------------------------------------------------------

local TERRAFORM_BLOCKER_RADIUS = math.ceil(ATRIUM_ARENA_SIZE / 3)

local function CreateTerraformBlocker(parent)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()

    inst:SetTerraformExtraSpacing(TERRAFORM_BLOCKER_RADIUS + 0.01)

    return inst
end

local function AddTerraformBlockers(inst)
    local diameter = 2 * TERRAFORM_BLOCKER_RADIUS
    local rowoffset = 3 * TERRAFORM_BLOCKER_RADIUS
    for row = -rowoffset, rowoffset, diameter do
        for col = -diameter, diameter, diameter do
            local blocker = CreateTerraformBlocker(inst)
            blocker.entity:SetParent(inst.entity)
            blocker.Transform:SetPosition(row, 0, col)

            blocker = CreateTerraformBlocker(inst)
            blocker.entity:SetParent(inst.entity)
            blocker.Transform:SetPosition(col, 0, row)
        end
    end
end

--------------------------------------------------------------------------

local function CreateFloor()
    local inst = CreateEntity()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("atrium_floor")
    inst.AnimState:SetBuild("atrium_floor")
    inst.AnimState:PlayAnimation("idle_active")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    return inst
end

local function OnPreLoad(inst, data)
    WorldSettings_Timer_PreLoad(inst, data, "destabilizing", TUNING.ATRIUM_GATE_DESTABILIZE_TIME)
    WorldSettings_Timer_PreLoad_Fix(inst, data, "destabilizing", 1)
    WorldSettings_Timer_PreLoad(inst, data, "destabilizedelay", TUNING.ATRIUM_GATE_DESTABILIZE_DELAY)
    WorldSettings_Timer_PreLoad_Fix(inst, data, "destabilizedelay", 1)
    WorldSettings_Timer_PreLoad(inst, data, "cooldown", TUNING.ATRIUM_GATE_COOLDOWN)
    WorldSettings_Timer_PreLoad_Fix(inst, data, "cooldown", 1)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.Light:Enable(false)
    inst.Light:SetRadius(8.0)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(0.65)
    inst.Light:SetColour(200 / 255, 140 / 255, 140 / 255)

    inst.AnimState:SetBank("atrium_gate")
    inst.AnimState:SetBuild("atrium_gate")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetSymbolLightOverride("dreadstone_patch_red", 1)

    inst.MiniMapEntity:SetIcon("atrium_gate.png")

    inst:AddTag("gemsocket") -- for "Socket" action string
    inst:AddTag("stargate")

    inst._camerafocus = net_tinybyte(inst.GUID, "atrium_gate._camerafocus", "camerafocusdirty")
    inst._camerafocustask = nil

    inst.scrapbook_specialinfo = "atriumgate"

    --Dedicated server does not need to spawn the flooring
    if not TheNet:IsDedicated() then
        CreateFloor().entity:SetParent(inst.entity)
    end

    --Dedicated servers need this too
    AddTerraformBlockers(inst)

    inst:DoTaskInTime(0, InitializePathFinding)
    inst.OnRemoveEntity = OnRemove

    inst.highlightchildren = {}

    -- Server and Client component.
    inst:AddComponent("charliecutscene")

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(20)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = OnKeyTaken

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = OnKeyGiven

    inst:AddComponent("worldsettingstimer")
    inst.components.worldsettingstimer:AddTimer("destabilizing", TUNING.ATRIUM_GATE_DESTABILIZE_TIME, true)
    inst.components.worldsettingstimer:AddTimer("destabilizedelay", TUNING.ATRIUM_GATE_DESTABILIZE_DELAY, true)
    inst.components.worldsettingstimer:AddTimer("cooldown", TUNING.ATRIUM_GATE_COOLDOWN, true)
    inst:ListenForEvent("timerdone", ontimer)

    inst:AddComponent("entitytracker")
    inst:AddComponent("colourtweener")

    MakeHauntableWork(inst)
    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)

    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnPreLoad = OnPreLoad

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.TrackStalker = TrackStalker
    inst.IsWaitingForStalker = IsWaitingForStalker

    inst.IsDestabilizing = IsDestabilizing
    inst.Destabilize = Destabilize
    inst.StartCooldown = StartCooldown
    inst.ForceDestabilizeExplode = ForceDestabilizeExplode

    inst.IsObjectInAtriumArena = IsObjectInAtriumArena

    inst._onremovestalker = function(stalker)
        local current = inst.components.entitytracker:GetEntity("stalker")
        if current == nil or current == stalker then
            --redundant check in case we're actually tracking another stalker
            --this event should only be reachable by shenanigans in any case
            Destabilize(inst, true)
        end
    end
    inst._onstalkerdeath = function(stalker)
        inst:RemoveEventCallback("onremove", inst._onremovestalker, stalker)
        inst:RemoveEventCallback("death", inst._onstalkerdeath, stalker)
        if inst.components.entitytracker:GetEntity("stalker") == stalker then
            inst.components.entitytracker:ForgetEntity("stalker")
            --IsAtriumDecay means "killed" to reset the fight (off-screen, or moved too far away from gate)
            Destabilize(inst, stalker:IsAtriumDecay())

            if not stalker:IsAtriumDecay() and
                TUNING.SPAWN_RIFTS == 1 and 
                not inst.components.entitytracker:GetEntity("charlie_hand") and
                TheWorld.components.riftspawner ~= nil and
                not TheWorld.components.riftspawner:GetShadowRiftsEnabled()
            then
                inst.components.charliecutscene:SpawnCharlieHand()
            end
        end
    end

    return inst
end

return Prefab("atrium_gate", fn, assets, prefabs)
