require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_spotlight.zip"),
    Asset("ANIM", "anim/winona_spotlight_placement.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local assets_head =
{
    Asset("ANIM", "anim/winona_spotlight.zip"),
}

local prefabs =
{
    "winona_spotlight_head",
    "winona_battery_sparks",
    "collapse_small",
}

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WINONA_BATTERY_RANGE) then
        local hp = helperinst:GetPosition()
        local p1 = TheWorld.Map:GetPlatformAtPoint(hp.x, hp.z)

        local pp = helperinst.placerinst:GetPosition()
        local p2 = TheWorld.Map:GetPlatformAtPoint(pp.x, pp.z)

        if p1 == p2 then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        end
    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function CreatePlacerBatteryRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    return inst
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    CreatePlacerBatteryRing().entity:SetParent(inst.entity)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
            if recipename == "winona_spotlight" then
                inst.helper = CreatePlacerRing()
                inst.helper.entity:SetParent(inst.entity)
            else
                inst.helper = CreatePlacerBatteryRing()
                inst.helper.entity:SetParent(inst.entity)
                if placerinst ~= nil and (recipename == "winona_battery_low" or recipename == "winona_battery_high") then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------

local TILTS = { "", "_tilt1", "_tilt2" }

local function SetHeadTilt(headinst, tilt, lightenabled)
    headinst._tilt = tilt
    for i, v in ipairs(TILTS) do
        if i == tilt then
            headinst.AnimState:Show("light"..v)
            if lightenabled then
                headinst.AnimState:Show("light_shaft"..v)
            else
                headinst.AnimState:Hide("light_shaft"..v)
            end
        else
            headinst.AnimState:Hide("light"..v)
            headinst.AnimState:Hide("light_shaft"..v)
        end
    end
end

--------------------------------------------------------------------------

local LIGHT_EASING = .2
local UPDATE_TARGET_PERIOD = .5
local LIGHT_INTENSITY_MAX = .94
local LIGHT_INTENSITY_DELTA = -.1
local LIGHT_OVERRIDE_HEAD = .7
local LIGHT_OVERRIDE_BASE = .25

local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()

    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(LIGHT_INTENSITY_MAX)
    inst.Light:SetRadius(TUNING.WINONA_SPOTLIGHT_RADIUS)
    inst.Light:SetColour(255 / 255, 248 / 255, 198 / 255)
    inst.Light:Enable(false)

    return inst
end

local GLOBAL_TARGETS = {}

local function SetTarget(inst, target)
    if inst._target ~= target then
        if inst._target ~= nil then
            local t = GLOBAL_TARGETS[inst._target]
            t.lights[inst] = nil
            if t.count > 1 then
                t.count = t.count - 1
            else
                GLOBAL_TARGETS[inst._target] = nil
            end
        end
        inst._target = target
        if target ~= nil then
            local t = GLOBAL_TARGETS[target]
            if t == nil then
                GLOBAL_TARGETS[target] = { count = 1, lights = { [inst] = true } }
            else
                t.lights[inst] = true
                t.count = t.count + 1
            end
        end
    end
end

local function HasOtherLight(inst, target)
    local t = GLOBAL_TARGETS[target]
    return t ~= nil and (t.lights[inst] and t.count - 1 or t.count) > 0
end

local function UpdateTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local maxrangesq = TUNING.WINONA_SPOTLIGHT_MAX_RANGE * TUNING.WINONA_SPOTLIGHT_MAX_RANGE
    local startrange = TUNING.WINONA_SPOTLIGHT_MAX_RANGE + TUNING.WINONA_SPOTLIGHT_RADIUS + 2
    local rangesq = startrange * startrange
    local targetIsAlive = nil
    local targetHasOtherLight = nil
    if inst._target ~= nil then
        if not (inst._target:IsValid() and inst._target.entity:IsVisible()) then
            SetTarget(inst, nil)
        else
            rangesq = inst._target:GetDistanceSqToPoint(x, y, z)
            local limit = TUNING.WINONA_SPOTLIGHT_MAX_RANGE + 8
            if rangesq >= limit * limit then
                SetTarget(inst, nil)
                rangesq = startrange * startrange
            else
                targetIsAlive = not (inst._target.components.health:IsDead() or inst._target:HasTag("playerghost"))
                targetHasOtherLight = HasOtherLight(inst, inst._target)
                if targetIsAlive and not targetHasOtherLight and rangesq < maxrangesq then
                    return
                end
            end
        end
    end
    for i, v in ipairs(AllPlayers) do
        if v ~= inst._target and v.entity:IsVisible() then
            local isalive = not (v.components.health:IsDead() or v:HasTag("playerghost"))
            local hasotherlight = HasOtherLight(inst, v)
            if inst._target == nil then
                local distsq = v:GetDistanceSqToPoint(x, y, z)
                if distsq < rangesq then
                    rangesq = distsq
                    SetTarget(inst, v)
                    targetIsAlive = isalive
                    targetHasOtherLight = hasotherlight
                end
            elseif not hasotherlight then
                if isalive and not targetIsAlive or targetHasOtherLight then
                    local distsq = v:GetDistanceSqToPoint(x, y, z)
                    if distsq < maxrangesq then
                        rangesq = distsq
                        SetTarget(inst, v)
                        targetIsAlive = isalive
                        targetHasOtherLight = hasotherlight
                    end
                elseif isalive or not targetIsAlive then
                    local distsq = v:GetDistanceSqToPoint(x, y, z)
                    if distsq < rangesq then
                        rangesq = distsq
                        SetTarget(inst, v)
                        targetIsAlive = isalive
                        targetHasOtherLight = hasotherlight
                    end
                end
            end
        end
    end
end

local function UpdateLightValues(inst, dir, dist)
    local offs = inst._lightoffset:value() * inst._lightoffset:value() / 49
    dir = dir + offs * 15
    dist = dist + offs
    local theta = (dir + 90) * DEGREES
    inst._lightinst.Transform:SetPosition(math.sin(theta) * dist, 0, math.cos(theta) * dist)
    local k = math.clamp((dist - TUNING.WINONA_SPOTLIGHT_MIN_RANGE) / (TUNING.WINONA_SPOTLIGHT_MAX_RANGE - TUNING.WINONA_SPOTLIGHT_MIN_RANGE), 0, 1)
    inst._lightinst.Light:SetIntensity(LIGHT_INTENSITY_MAX + k * k * LIGHT_INTENSITY_DELTA)
end

local function OnUpdateLightCommon(inst)
    if inst._lightoffset:value() > 0 then
        inst._lightoffset:set_local(inst._lightoffset:value() - 1)
    end

    local lightenabled = inst._lightdist:value() > 0

    if inst._curlightdir == nil then
        if not lightenabled then
            return
        end
        inst._curlightdir = inst._lightdir:value()
    else
        if inst._clientheadinst ~= nil then
            --on clients, check to make sure we're predicting the light tween in the correct direction
            --by comparing it against the head transform rotation, which isn't predicted
            local headdir = inst._clientheadinst.Transform:GetRotation()
            local drot = math.abs(inst._curlightdir - headdir)
            if drot > 180 then
                drot = 360 - drot
            end
            if drot >= 90 then
                --differs by over 90 degrees? maybe we're rotating the wrong way, so snap to match the head
                inst._curlightdir = headdir
            end
        end
        local drot = inst._lightdir:value() - inst._curlightdir
        if drot > 180 then
            drot = drot - 360
        elseif drot < -180 then
            drot = drot + 360
        end
        inst._curlightdir = inst._curlightdir + drot * LIGHT_EASING
        if inst._curlightdir > 180 then
            inst._curlightdir = inst._curlightdir - 360
        elseif inst._curlightdir < -180 then
            inst._curlightdir = inst._curlightdir + 360
        end
    end

    if inst._curlightdist == nil then
        inst._curlightdist = math.max(TUNING.WINONA_SPOTLIGHT_MIN_RANGE, inst._lightdist:value())
    else
        inst._curlightdist = inst._curlightdist * (1 - LIGHT_EASING) + math.max(TUNING.WINONA_SPOTLIGHT_MIN_RANGE, inst._lightdist:value()) * LIGHT_EASING
    end

    if lightenabled then
        UpdateLightValues(inst, inst._curlightdir, inst._curlightdist)
    end
end

local function OnUpdateLightServer(inst, dt)
    if inst:IsAsleep() then
        return
    end

    local lightenabled = inst._lightdist:value() > 0
    if lightenabled then
        if inst._updatedelay > 0 then
            inst._updatedelay = inst._updatedelay - dt
        else
            UpdateTarget(inst)
            inst._updatedelay = UPDATE_TARGET_PERIOD
        end
        if inst._target ~= nil then
            if inst._target:IsValid() then
                inst._lightdir:set(inst:GetAngleToPoint(inst._target.Transform:GetWorldPosition()))
                inst._lightdist:set(math.clamp(math.sqrt(inst:GetDistanceSqToInst(inst._target)), TUNING.WINONA_SPOTLIGHT_MIN_RANGE, TUNING.WINONA_SPOTLIGHT_MAX_RANGE))
            else
                SetTarget(inst, nil)
            end
        end
    else
        SetTarget(inst, nil)
    end
    OnUpdateLightCommon(inst)
    if inst._curlightdir ~= nil then
        inst._headinst.Transform:SetEightFaced()
        inst._headinst.Transform:SetRotation(inst._curlightdir)
        local range = TUNING.WINONA_SPOTLIGHT_MAX_RANGE - TUNING.WINONA_SPOTLIGHT_MIN_RANGE
        local tilt = (inst._curlightdist - TUNING.WINONA_SPOTLIGHT_MIN_RANGE) / range
        local t1 = inst._headinst._tilt > 1 and .3 + 3 / range or .3
        local t2 = inst._headinst._tilt > 2 and .003 + 1.5 / range or .003
        SetHeadTilt(inst._headinst, (tilt > t1 and 1) or (tilt > t2 and 2) or 3, lightenabled)
    end
end

local function OnUpdateLightClient(inst)--, dt)
    if inst.components.updatelooper ~= nil then
        if inst:HasTag("burnt") then
            inst:RemoveComponent("updatelooper")
        else
            OnUpdateLightCommon(inst)
        end
    end
end

local function OnLightDistDirty(inst)
    local lightenabled = inst._lightdist:value() > 0
    inst._lightinst.Light:Enable(lightenabled)
    if lightenabled and inst._curlightdir == nil then
        OnUpdateLightClient(inst)
    end
end

local function OnStartHum(inst)
    inst._humtask = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/on_hum_LP", "humloop")
end

local function EnableHum(inst, enable)
    if enable then
        if inst._humtask == nil then
            inst._humtask = inst:DoTaskInTime(0, OnStartHum)
        end
    elseif inst._humtask ~= nil then
        inst._humtask:Cancel()
        inst._humtask = nil
    else
        inst.SoundEmitter:KillSound("humloop")
    end
end

local function EnableLight(inst, enable)
    if not enable then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
            inst._powertask = nil
        end
        if inst._lightdist:value() > 0 then
            SetHeadTilt(inst._headinst, inst._headinst._tilt, false)
            inst._headinst.AnimState:ClearBloomEffectHandle()
            inst._headinst.AnimState:SetLightOverride(0)
            inst.AnimState:SetLightOverride(0)
            inst._lightinst.Light:Enable(false)
            inst._lightdist:set(0)
            if not (inst:HasTag("NOCLICK") or inst:IsAsleep()) then
                inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity")
            end
            EnableHum(inst, false)
        end
    elseif inst._lightdist:value() <= 0 then
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.AnimState:PlayAnimation("idle", true)
            inst._headinst.AnimState:PlayAnimation("idle", true)
        end
        SetHeadTilt(inst._headinst, inst._headinst._tilt, true)
        inst._headinst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst._headinst.AnimState:SetLightOverride(LIGHT_OVERRIDE_HEAD)
        inst.AnimState:SetLightOverride(LIGHT_OVERRIDE_BASE)
        inst._lightinst.Light:Enable(true)
        inst._lightdist:set(TUNING.WINONA_SPOTLIGHT_MIN_RANGE)
        inst._updatedelay = 0
        if not inst:IsAsleep() then
            if inst._curlightdir == nil then
                OnUpdateLightServer(inst, 0)
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/on")
            EnableHum(inst, true)
        end
    end
end

local function OnEntitySleep(inst)
    EnableHum(inst, false)
end

local function OnEntityWake(inst)
    if inst._lightdist:value() > 0 then
        EnableHum(inst, true)
    end
end

--------------------------------------------------------------------------

local function OnBuilt2(inst)
    if inst.components.workable:CanBeWorked() then
        inst:RemoveTag("NOCLICK")
        if not inst:HasTag("burnt") then
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        end
    end
end

local function OnBuilt3(inst)
    inst:RemoveEventCallback("animover", OnBuilt3)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst.AnimState:PlayAnimation("idle", true)
        inst._headinst.AnimState:PlayAnimation("idle", true)
    end
end

local function OnBuilt(inst)--, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:AddTag("NOCLICK")
    EnableLight(inst, false)
    inst._headinst.Transform:SetTwoFaced()
    inst.AnimState:PlayAnimation("place")
    inst._headinst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/place")
    inst:DoTaskInTime(37 * FRAMES, OnBuilt2)
    inst:ListenForEvent("animover", OnBuilt3)
end

--------------------------------------------------------------------------

local function OnWorked(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
    inst._headinst.AnimState:PlayAnimation("hit")
    inst._headinst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
    inst._lightoffset:set(7)
end

local function OnWorkFinished(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.components.workable:SetWorkable(false)
    inst:AddTag("NOCLICK")
    inst.persists = false
    if inst.components.burnable ~= nil then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        inst.components.burnable.canlight = false
    end

    inst.Physics:SetActive(false)
    inst.components.lootdropper:DropLoot()
    inst.AnimState:Show("light")
    EnableLight(inst, false)
    inst._headinst:Hide()
    inst.AnimState:PlayAnimation("death_pst")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/destroy")

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("none")

    inst:DoTaskInTime(2, ErodeAway)
end

local function OnWorkedBurnt(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    EnableLight(inst, false)
    inst._headinst:Hide()

    inst:RemoveComponent("updatelooper")

    inst.Transform:SetRotation(inst._headinst.Transform:GetRotation())
    inst.OnEntityWake = nil
    inst.OnEntitySleep = nil

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
            EnableLight(inst, true)
        end
        inst._powertask = inst:DoTaskInTime(power, EnableLight, false)
    end
end

local function OnUpdateSparks(inst)
    if inst._flash > 0 then
        local k = inst._flash * inst._flash
        inst.components.colouradder:PushColour("wiresparks", .3 * k, .3 * k, 0, 0)
        inst._headinst.components.colouradder:PushColour("wiresparks", .3 * k, .3 * k, 0, 0)
        inst._flash = inst._flash - .15
    else
        inst.components.colouradder:PopColour("wiresparks")
        inst._flash = nil
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateSparks)
    end
end

local function DoWireSparks(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, .5)
    SpawnPrefab("winona_battery_sparks").entity:AddFollower():FollowSymbol(inst.GUID, "wire", 0, 0, 0)
    if inst.components.updatelooper ~= nil then
        if inst._flash == nil then
            inst.components.updatelooper:AddOnUpdateFn(OnUpdateSparks)
        end
        inst._flash = 1
        OnUpdateSparks(inst)
    end
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
    --Notify other connected batteries
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function OnConnectCircuit(inst)--, node)
    if not inst._wired then
        inst._wired = true
        inst.AnimState:ClearOverrideSymbol("wire")
        if not POPULATING then
            DoWireSparks(inst)
        end
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    elseif inst._wired then
        inst._wired = nil
        --This will remove mouseover as well (rather than just :Hide("wire"))
        inst.AnimState:OverrideSymbol("wire", "winona_spotlight", "dummy")
        DoWireSparks(inst)
        EnableLight(inst, false)
    end
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
        data.lightdir = inst.Transform:GetRotation()
        if data.lightdir == 0 then
            data.lightdir = nil
        end
    else
        data.lightdist = inst._lightdist:value() > TUNING.WINONA_SPOTLIGHT_MIN_RANGE and inst._lightdist:value() or nil
        data.lightdir = inst._lightdir:value() ~= 0 and inst._lightdir:value() or nil
        data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
            if data.lightdir ~= nil then
                inst.Transform:SetRotation(data.lightdir)
            end
        else
            local dirty = false
            if data.lightdir ~= nil and data.lightdir ~= inst._lightdir:value() then
                inst._lightdir:set(data.lightdir)
                inst._curlightdir = data.lightdir
                dirty = true
            end
            if data.power ~= nil then
                AddBatteryPower(inst, math.max(2 * FRAMES, data.power / 1000))
            end
            if data.lightdist ~= nil and data.lightdist ~= inst._lightdist:value() and data.lightdist > TUNING.WINONA_SPOTLIGHT_MIN_RANGE and inst._lightdist:value() > 0 then
                inst._lightdist:set(data.lightdist)
                inst._curlightdist = inst._curlightdist ~= nil and data.lightdist or nil
                dirty = true
            end
            if dirty then
                if inst._lightdist:value() > 0 then
                    UpdateLightValues(inst, inst._lightdir:value(), inst._lightdist:value())
                elseif inst._curlightdir ~= nil then
                    inst._headinst.Transform:SetEightFaced()
                    inst._headinst.Transform:SetRotation(inst._curlightdir)
                    SetHeadTilt(inst._headinst, 3, false)
                end
            end
        end
    elseif inst._lightdist:value() <= 0 and inst._headinst._tilt == 1 and inst._headinst.Transform:GetRotation() == 0 then
        --never been turned on
        inst._headinst.Transform:SetTwoFaced()
    end

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if inst.components.workable:CanBeWorked() and not inst:HasTag("burnt") then
        --Enable connections, but leave the initial connection to batteries' OnPostLoad
        inst.components.circuitnode:ConnectTo(nil)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.Transform:SetEightFaced()

    inst:AddTag("engineering")
    inst:AddTag("spotlight")
    inst:AddTag("structure")

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("light")
    inst.AnimState:Hide("light_tilt1")
    inst.AnimState:Hide("light_tilt2")
    inst.AnimState:Hide("light_shaft")
    inst.AnimState:Hide("light_shaft_tilt1")
    inst.AnimState:Hide("light_shaft_tilt2")
    --disable mouseover over light_shaft (hidden layers still contribute to mouseover!)
    inst.AnimState:OverrideSymbol("light_shimmer", "winona_spotlight", "dummy")
    --This will remove mouseover as well (rather than just :Hide("wire"))
    inst.AnimState:OverrideSymbol("wire", "winona_spotlight", "dummy")

    inst.MiniMapEntity:SetIcon("winona_spotlight.png")

    inst._lightinst = CreateLight()
    inst._lightinst.entity:SetParent(inst.entity)
    inst._lightdir = net_float(inst.GUID, "winona_spotlight._lightdir")
    inst._lightdist = net_float(inst.GUID, "winona_spotlight._lightdist", "lightdistdirty")
    inst._lightoffset = net_tinybyte(inst.GUID, "winona_spotlight._lightoffset")
    inst._lightdist:set(0)
    inst._curlightdir = nil
    inst._curlightdist = nil

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(TheWorld.ismastersim and OnUpdateLightServer or OnUpdateLightClient)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdistdirty", OnLightDistDirty)

        return inst
    end

    inst._headinst = SpawnPrefab("winona_spotlight_head")
    inst._headinst.entity:SetParent(inst.entity)

    inst.highlightchildren = { inst._headinst }

    inst._state = 1

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("colouradder")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.AddBatteryPower = AddBatteryPower

    inst._wired = nil
    inst._flash = nil
    inst._target = nil
    inst._updatedelay = 0
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

--------------------------------------------------------------------------

local function OnHeadEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "winona_spotlight" then
        parent.highlightchildren = { inst }
        parent._clientheadinst = inst
    end
end

local function headfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("decor") --no mouse over, let the base prefab handle that
    inst:AddTag("NOCLICK")

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("leg")
    inst.AnimState:Hide("ground_shadow")
    inst.AnimState:Hide("wire")
    inst.AnimState:SetFinalOffset(1)
    SetHeadTilt(inst, 1, false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnHeadEntityReplicated

        return inst
    end

    inst:AddComponent("colouradder")

    return inst
end

--------------------------------------------------------------------------

local function CreatePlacerSpotlight()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("winona_spotlight")
    inst.AnimState:SetBuild("winona_spotlight")
    inst.AnimState:PlayAnimation("idle_placer")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the spotlight placer on top of the spotlight range ground placer
    --Also add the small battery range indicator

    local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    placer2 = CreatePlacerSpotlight()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

--------------------------------------------------------------------------

return Prefab("winona_spotlight", fn, assets, prefabs),
    Prefab("winona_spotlight_head", headfn, assets_head),
    MakePlacer("winona_spotlight_placer", "winona_spotlight_placement", "winona_spotlight_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)
