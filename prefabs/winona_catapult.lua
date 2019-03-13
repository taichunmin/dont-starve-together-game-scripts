require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/winona_catapult.zip"),
    Asset("ANIM", "anim/winona_catapult_placement.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local prefabs =
{
    "winona_catapult_projectile",
    "winona_battery_sparks",
    "collapse_small",
}

local brain = require("brains/winonacatapultbrain")

local KEEP_TARGET_BUFFER_DISTANCE = 5

local function RetargetFn(inst)
    local target = inst.components.combat.target
    if target ~= nil and
        target:IsValid() and
        inst:IsNear(target, TUNING.WINONA_CATAPULT_MAX_RANGE) and
        not inst:IsNear(target, math.max(0, TUNING.WINONA_CATAPULT_MIN_RANGE - TUNING.WINONA_CATAPULT_AOE_RADIUS - target:GetPhysicsRadius(0))) then
        --keep current target
        return
    end

    local playertargets = {}
    for i, v in ipairs(AllPlayers) do
        if v.components.combat.target ~= nil then
            playertargets[v.components.combat.target] = true
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.WINONA_CATAPULT_MAX_RANGE, { "_combat" }, { "INLIMBO", "player", "engineering" })
    local tooclosetarget = nil
    for i, v in ipairs(ents) do
        if v ~= inst and
            v ~= target and
            v.entity:IsVisible() and
            inst.components.combat:CanTarget(v) and
            (   playertargets[v] or
                v.components.combat:TargetIs(inst) or
                (v.components.combat.target ~= nil and v.components.combat.target:HasTag("player"))
            ) then
            if not inst:IsNear(v, math.max(0, TUNING.WINONA_CATAPULT_MIN_RANGE - TUNING.WINONA_CATAPULT_AOE_RADIUS - v:GetPhysicsRadius(0))) then
                --new target between the attackable ranges
                return v, target ~= nil
            elseif tooclosetarget == nil then
                tooclosetarget = v
            end
        end
    end
    return tooclosetarget, target ~= nil
end

local function ShouldKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and inst:IsNear(target, TUNING.WINONA_CATAPULT_MAX_RANGE + KEEP_TARGET_BUFFER_DISTANCE)
end

local function ShareTargetFn(dude)
    return dude:HasTag("catapult")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil then
        if not attacker:HasTag("player") then
            if inst:IsNear(attacker, TUNING.WINONA_CATAPULT_MAX_RANGE) and
                not inst:IsNear(attacker, math.max(0, TUNING.WINONA_CATAPULT_MIN_RANGE - TUNING.WINONA_CATAPULT_AOE_RADIUS - attacker:GetPhysicsRadius(0))) then
                inst.components.combat:SetTarget(attacker)
            end
            inst.components.combat:ShareTarget(attacker, 15, ShareTargetFn, 10)
        elseif data.damage == 0 and inst.components.combat:TargetIs(attacker) then
            --V2C: prevent targeting players when using fire/ice staff on the catapult
            inst.components.combat:DropTarget()
        end
    end
    if data ~= nil and data.damage == 0 and data.weapon ~= nil and (data.weapon:HasTag("rangedlighter") or data.weapon:HasTag("extinguisher")) then
        --V2C: weapon may be invalid by the time it reaches stategraph event handler, so ues a lua property instead
        data.weapon._nocatapulthit = true
    end
end

local function OnWorked(inst, worker, workleft, numworks)
    inst.components.workable:SetWorkLeft(4)
    inst.components.combat:GetAttacked(worker, numworks * TUNING.WINONA_CATAPULT_HEALTH / 4, worker.components.inventory ~= nil and worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil)
end

local function OnWorkedBurnt(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnDeath(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.components.workable:SetWorkable(false)
    if inst.components.burnable ~= nil then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        inst.components.burnable.canlight = false
    end
    inst.Physics:SetActive(false)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("none")
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    inst:SetBrain(nil)
    inst:ClearStateGraph()
    inst.SoundEmitter:KillAllSounds()

    inst:RemoveEventCallback("attacked", OnAttacked)
    inst:RemoveEventCallback("death", OnDeath)

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()

    inst:RemoveComponent("health")
    inst:RemoveComponent("combat")

    inst:AddTag("notarget") -- just in case???
end

local function OnBuilt(inst)--, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.sg:GoToState("place")
end

--------------------------------------------------------------------------

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(TUNING.WINONA_CATAPULT_HEALTH_REGEN, TUNING.WINONA_CATAPULT_HEALTH_REGEN_PERIOD)
    else
        inst.components.health:StopRegen()
    end
end

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    else
        data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
    end
end

local function OnLoad(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
        if data ~= nil and data.power ~= nil then
            inst:AddBatteryPower(math.max(2 * FRAMES, data.power / 1000))
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle", true) --loading = true
            end
        end
        --Enable connections, but leave the initial connection to batteries' OnPostLoad
        inst.components.circuitnode:ConnectTo(nil)
        OnHealthDelta(inst)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WINONA_BATTERY_RANGE) then
        helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
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

    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("inner")
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
            if recipename == "winona_catapult" then
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

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function PowerOff(inst)
    inst._powertask = nil
    inst:SetBrain(nil)
    inst.components.combat:SetTarget(nil)
    inst:PushEvent("togglepower", { ison = false })
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        local doturnon = false
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
            doturnon = true
        end
        inst._powertask = inst:DoTaskInTime(power, PowerOff)
        if doturnon then
            inst:SetBrain(brain)
            if not inst:IsAsleep() then
                inst:RestartBrain()
            end
            inst:PushEvent("togglepower", { ison = true })
        end
    end
end

local function IsPowered(inst)
    return inst._powertask ~= nil
end

local function OnUpdateSparks(inst)
    if inst._flash > 0 then
        local k = inst._flash * inst._flash
        inst.components.colouradder:PushColour("wiresparks", .3 * k, .3 * k, 0, 0)
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
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
            PowerOff(inst)
        end
    end
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

    inst.Transform:SetSixFaced()

    inst:AddTag("companion")
    inst:AddTag("noauradamage")
    inst:AddTag("engineering")
    inst:AddTag("catapult")
    inst:AddTag("structure")

    inst.AnimState:SetBank("winona_catapult")
    inst.AnimState:SetBuild("winona_catapult")
    inst.AnimState:PlayAnimation("idle_off")
    --This will remove mouseover as well (rather than just :Hide("wire"))
    inst.AnimState:OverrideSymbol("wire", "winona_catapult", "dummy")

    inst.MiniMapEntity:SetIcon("winona_catapult.png")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._state = 1

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("updatelooper")
    inst:AddComponent("colouradder")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WINONA_CATAPULT_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
    inst.components.combat:SetRange(TUNING.WINONA_CATAPULT_MAX_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.WINONA_CATAPULT_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    inst:AddComponent("savedrotation")

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)

    MakeHauntableWork(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.AddBatteryPower = AddBatteryPower
    inst.IsPowered = IsPowered

    inst:SetStateGraph("SGwinona_catapult")
    --inst:SetBrain(brain)

    inst._wired = nil
    inst._flash = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

--------------------------------------------------------------------------

local function CreatePlacerCatapult()
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

    inst.AnimState:SetBank("winona_catapult")
    inst.AnimState:SetBuild("winona_catapult")
    inst.AnimState:PlayAnimation("idle_placer")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the catapult placer on top of the catapult range ground placer
    --Also add the small battery range indicator

    local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    placer2 = CreatePlacerCatapult()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:Hide("inner")
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

--------------------------------------------------------------------------

return Prefab("winona_catapult", fn, assets, prefabs),
    MakePlacer("winona_catapult_placer", "winona_catapult_placement", "winona_catapult_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)
