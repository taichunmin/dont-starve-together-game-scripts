require "prefabutil"

local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/winona_battery_placement.zip"),
    Asset("ANIM", "anim/boat_waterpump.zip"),
    Asset("INV_IMAGE", "waterpump_item"),
}

local prefabs =
{
    "waterstreak_projectile",
    "collapse_small",
}

local RANDOM_OFFSET_MAX = TUNING.WATERPUMP.MAXRANGE

local function onhammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()

    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

	local boat = inst:GetCurrentPlatform()
	if boat ~= nil then
		boat:PushEvent("spawnnewboatleak", { pt = Vector3(x, y, z), leak_size = "med_leak", playsoundfx = true })
	end

    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")
    inst:Remove()
end

local function cancel_channeling(inst)
    if inst.channeler ~= nil and inst.channeler:IsValid() then
        inst.channeler:PushEvent("cancel_channel_longaction")
    end
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") and not inst.channeler then
         inst.AnimState:PlayAnimation("use_pst")
    end
end

local function CancelReadyTask(inst)
    if inst._ready_task ~= nil then
        inst._ready_task:Cancel()
        inst._ready_task = nil
    end
end

local function CancelLaunchProjectileTask(inst)
    if inst._launch_projectile_task ~= nil then
        inst._launch_projectile_task:Cancel()
        inst._launch_projectile_task = nil
    end
end

local function onburnt(inst)
    cancel_channeling(inst)

    CancelReadyTask(inst)
    CancelLaunchProjectileTask(inst)
    if inst.channeler then
        inst:OnStopChanneling()
    end

    inst:RemoveComponent("channelable")
end

local NOTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" }
local ONEOFTAGS = { "fire", "smolder" }
local function LaunchProjectile(inst)
    CancelLaunchProjectileTask(inst)

    local x, y, z = inst.Transform:GetWorldPosition()

    if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        local ents = TheSim:FindEntities(x, y, z, TUNING.WATERPUMP.MAXRANGE, nil, NOTAGS, ONEOFTAGS)
        local targetpos
        if #ents > 0 then
            targetpos = ents[1]:GetPosition()
        else
            local theta = math.random() * 2 * PI
            local offset = math.random() * RANDOM_OFFSET_MAX
            targetpos = Point(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)
        end

        local projectile = SpawnPrefab("waterstreak_projectile")
        projectile.Transform:SetPosition(x, 5, z)

        local dx = targetpos.x - x
        local dz = targetpos.z - z
        local rangesq = dx * dx + dz * dz
        local maxrange = TUNING.WATERPUMP.MAXRANGE
        local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
        projectile.components.complexprojectile:SetHorizontalSpeed(speed)
        projectile.components.complexprojectile:SetGravity(-25)
        projectile.components.complexprojectile:Launch(targetpos, inst, inst)
    end
end

local function testforland(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        inst.AnimState:Hide("fx")
    else
        inst.AnimState:Show("fx")
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
        inst:PushEvent("onburnt")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dangerous_sea/common/water_pump/place")
    testforland(inst)
end

local PLACER_SCALE = 1.26

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("winona_battery_placement")
            inst.helper.AnimState:SetBuild("winona_battery_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)
            inst.helper.AnimState:Hide("inner")

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function startprojectilelaunch(inst)
    inst.AnimState:PlayAnimation("use_loop")
    inst.SoundEmitter:PlaySound("dangerous_sea/common/water_pump/LP","pump")

    if inst:GetCurrentPlatform() ~= nil then
        inst._launch_projectile_task = inst:DoTaskInTime(7*FRAMES, LaunchProjectile)
    end
end

local function OnStartChanneling(inst, channeler)
    inst.channeler = channeler
    inst.AnimState:PlayAnimation("use_pre")
    inst:ListenForEvent("animover", startprojectilelaunch)

    testforland(inst)
end

local function OnStopChanneling(inst)
    inst:RemoveEventCallback("animover", startprojectilelaunch)
    inst.channeler = nil
    if inst._launch_projectile_task then
        inst._launch_projectile_task:Cancel()
        inst._launch_projectile_task = nil
    end
    inst.SoundEmitter:KillSound("pump")
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("use_pst",false)
        inst.AnimState:PushAnimation("idle")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, .25)
    inst:SetPhysicsRadiusOverride(0.25)

    inst.AnimState:SetBank("boat_waterpump")
    inst.AnimState:SetBuild("boat_waterpump")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("pump")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnable(inst, nil, nil, true)
	inst:ListenForEvent("onburnt", onburnt)
    MakeMediumPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("channelable")
    inst.components.channelable:SetChannelingFn(OnStartChanneling, OnStopChanneling)
    inst.components.channelable.use_channel_longaction = true
    inst.components.channelable.skip_state_channeling = true
    inst.components.channelable.skip_state_stopchanneling = true
    inst.components.channelable.ignore_prechannel = true

    inst:ListenForEvent("channel_finished", OnStopChanneling)

    inst.OnStopChanneling = OnStopChanneling

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", cancel_channeling)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function placer_postinit_fn(inst)
    --Show the waterpump placer on top of the range ground placer

    inst.AnimState:Hide("inner")

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("boat_waterpump")
    placer2.AnimState:SetBuild("boat_waterpump")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("waterpump", fn, assets, prefabs),
    MakePlacer("waterpump_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
