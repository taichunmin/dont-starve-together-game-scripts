require "prefabutil"

local assets =
{
	Asset("MINIMAP_IMAGE", "archive_resonator"),
    Asset("ANIM", "anim/archive_resonator.zip"),
}

local prefabs =
{

}

local light_params =
{
    on =
    {
        radius = 2,
        intensity = .4,
        falloff = .6,
        colour = {237/255, 237/255, 209/255},
        time = 0.2,
    },

    off =
    {
        radius = 0,
        intensity = 0,
        falloff = 0.6,
        colour = { 0, 0, 0 },
        time = 1,
    },

    beam =
    {
        radius = 4,
        intensity = .8,
        falloff = .6,
        colour = { 237/255, 237/255, 209/255 },
        time = 0.4,
    },

    idle =
    {
        radius = 1,
        intensity = .4,
        falloff = .6,
        colour = {237/255, 237/255, 209/255},
        time = 0.2,
    },
}

local function pushparams(inst, params)
    inst.Light:SetRadius(params.radius * inst.widthscale)
    inst.Light:SetIntensity(params.intensity)
    inst.Light:SetFalloff(params.falloff)
    inst.Light:SetColour(unpack(params.colour))

    if params.intensity > 0 then
        inst.Light:Enable(true)
    else
        inst.Light:Enable(false)
    end

end

-- Not using deepcopy because we want to copy in place
local function copyparams(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            copyparams(dest[k], v)
        else
            dest[k] = v
        end
    end
end

local function lerpparams(pout, pstart, pend, lerpk)
    for k, v in pairs(pend) do
        if type(v) == "table" then
            lerpparams(pout[k], pstart[k], v, lerpk)
        else
            pout[k] = pstart[k] * (1 - lerpk) + v * lerpk
        end
    end
end

local function OnUpdateLight(inst, dt)
    inst._currentlight.time = inst._currentlight.time + dt
    if inst._currentlight.time >= inst._endlight.time then
        inst._currentlight.time = inst._endlight.time
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    lerpparams(inst._currentlight, inst._startlight, inst._endlight, inst._endlight.time > 0 and inst._currentlight.time / inst._endlight.time or 1)
    pushparams(inst, inst._currentlight)
    inst.AnimState:SetLightOverride(Remap(inst._currentlight.intensity, light_params.off.intensity,light_params.beam.intensity, 0,1))
end

local function beginfade(inst)
    copyparams(inst._startlight, inst._currentlight)
    inst._currentlight.time = 0
    inst._startlight.time = 0

    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, FRAMES)
    end
end

local function ChangeToItem(inst)
    local item = SpawnPrefab("archive_resonator_item")
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    --
    item.components.finiteuses:SetPercent(inst.components.finiteuses:GetPercent())
    return item
end

local MOON_ALTAR_ASTRAL_MARKER_MUST_TAG =  {"moon_altar_astral_marker"}
local MOON_ALTAR_ASTRAL_MARKER_NOT_TAG =  {"marker_found"}
local MOON_RELIC_MUST_TAG =  {"moon_relic"}
local CRAB_KING_MUST_TAG =  {"crabking"}
local function scanfordevice(inst)
	local ent = FindEntity(inst, 9999, nil, MOON_ALTAR_ASTRAL_MARKER_MUST_TAG, MOON_ALTAR_ASTRAL_MARKER_NOT_TAG)

    if not ent then

        inst.registered_devices = {} -- clear, then populate via calling_all_devices
        TheWorld:PushEvent("calling_moon_relics", {caller = inst})

        local ents = inst.registered_devices --TheSim:FindEntities(x, y, z, 9999, MOON_RELIC_MUST_TAG)

        for i,thisent in ipairs(ents) do
            -- find items in water
            if thisent:HasTag("INLIMBO") and thisent.components.submersible and thisent.components.submersible:GetUnderwaterObject() then
                ent = thisent
                break
            end
            -- find the rocks
            if thisent:HasTag("boulder") then
                ent = thisent
                break
            end
        end
    end

    if not ent then
        local crown = false
        inst.registered_devices = {} -- clear, then populate via calling_all_devices
        TheWorld:PushEvent("calling_moon_relics", {caller = inst})
        local ents = inst.registered_devices
        for i, thisent in ipairs(ents)do
            if thisent.prefab == "moon_altar_crown" or thisent.prefab == "moon_altar_cosmic" then
                crown = true
                break
            end
        end

        if not crown then
            ent = FindEntity(inst, 9999, nil, CRAB_KING_MUST_TAG)
        end
    end

	if ent then
		if ent:GetDistanceSqToInst(inst) < 4*4 and ent:HasTag("moon_altar_astral_marker") then
            inst.SoundEmitter:KillSound("locating")
            inst.AnimState:PlayAnimation("drill")
            inst.SoundEmitter:PlaySound("grotto/common/archive_resonator/drill")

            local swap = "swap_altar_wardpiece"
            if ent.product == "moon_altar_icon" then
                swap = "swap_altar_iconpiece"
            end

            inst.AnimState:OverrideSymbol("swap_body", swap, "swap_body")
            inst.product = ent.product
            ent:AddTag("marker_found")
            inst.target = ent
            inst:ListenForEvent("animover", function()
                if inst.AnimState:IsCurrentAnimation("drill") then
                    local artifact = SpawnPrefab(inst.product)
                    inst.product = nil
                    artifact.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.components.finiteuses:Use(1)
                    local item = ChangeToItem(inst)
                    local pt = Vector3(inst.Transform:GetWorldPosition())
                    pt.y = pt.y + 3
                    inst.components.lootdropper:FlingItem(item,pt)
                    inst.target:Remove()
                    inst.target = nil
                    inst:Remove()
                end
            end)
		else
			local x,y,z = inst.Transform:GetWorldPosition()
			local angle = ent:GetAngleToPoint(x,y,z)
            local radius = -3
            local theta = (angle)*DEGREES
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            inst.task3 = inst:DoTaskInTime(30/30, function()
                local base = SpawnPrefab("archive_resonator_base")
                base.Transform:SetPosition(x+offset.x,y,z+offset.z)
			    base.Transform:SetRotation(angle+90)
                base.AnimState:PlayAnimation("beam_marker")
                base.AnimState:PushAnimation("idle_marker",true)

                inst.SoundEmitter:PlaySound("grotto/common/archive_resonator/beam")
            end)
            inst.task4 = inst:DoTaskInTime(20/30, function()
                copyparams( inst._endlight, light_params.beam)
                beginfade(inst)
            end)

            inst.task5 = inst:DoTaskInTime(44/30, function()
                copyparams( inst._endlight, light_params.on)
                beginfade(inst)
            end)
            inst.Transform:SetRotation(angle+180)
            inst.AnimState:PlayAnimation("beam")
            inst.SoundEmitter:KillSound("locating")
		end
    else
        inst.task3 = inst:DoTaskInTime(4, function()
            inst.SoundEmitter:KillSound("locating")
            inst.AnimState:PlayAnimation("idle_pre")
            copyparams( inst._endlight, light_params.idle)
            beginfade(inst)
            inst.AnimState:PushAnimation("idle_loop",true)
            inst.components.finiteuses:Use(1)
        end)
	end


    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("beam") then
            inst.OnDismantle(inst)
             inst.components.finiteuses:Use(1)
        end
    end)
end

local function ondeploy(inst, pt, deployer)
    local at = SpawnPrefab("archive_resonator")
    if at ~= nil then
        at.Physics:SetCollides(false)
        at.Physics:Teleport(pt.x, 0, pt.z)
        at.Physics:SetCollides(true)
        at.AnimState:PlayAnimation("place")

        at.SoundEmitter:PlaySound("grotto/common/archive_resonator/place")
        at.SoundEmitter:PlaySound("grotto/common/archive_resonator/idle_LP", "idle_loop")

        at:ListenForEvent("animover", function()
            if at.AnimState:IsCurrentAnimation("place") then
                at.AnimState:PlayAnimation("locating", true)
                at.SoundEmitter:PlaySound("grotto/common/archive_resonator/locating_LP", "locating")
            end
        end)
        if at._lighttask then
            at._lighttask:Cancel()
            at._lighttask = nil
        end
        copyparams(at._currentlight, light_params.off)
        pushparams(at, at._currentlight)
        at.task1 = at:DoTaskInTime(83/30,function()
                copyparams( at._endlight, light_params.on)
                beginfade(at)
            end)
        at.task2 = at:DoTaskInTime(5,function()
        		scanfordevice(at)
    		end)
        at.components.finiteuses:SetPercent(inst.components.finiteuses:GetPercent())
        inst:Remove()
    end
end

local function OnDismantle(inst)--, doer)
    inst.SoundEmitter:KillSound("idle_loop")
    inst.AnimState:PlayAnimation("pack")
    inst.SoundEmitter:PlaySound("grotto/common/archive_resonator/pack")
    copyparams( inst._endlight, light_params.off)
    beginfade(inst)
    inst:ListenForEvent("animover", function()
    -- inst.SoundEmitter:PlaySound("grotto/common/archive_resonator/pack") Jason (doesn't work)
        if inst.AnimState:IsCurrentAnimation("pack") then
            ChangeToItem(inst)
            inst:Remove()
        end
    end)
end

local function onfinisheduses(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhammered(inst)

    inst.components.lootdropper:DropLoot()
    --close it
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")

    if inst.task1 then
        inst.task1:Cancel()
        inst.task1 = nil
    end

    if inst.task2 then
        inst.task2:Cancel()
        inst.task2 = nil
    end

    if inst.task3 then
        inst.task3:Cancel()
        inst.task3 = nil
    end

    if inst.task4 then
        inst.task4:Cancel()
        inst.task4 = nil
    end

    if inst.task5 then
        inst.task5:Cancel()
        inst.task5 = nil
    end

    inst:Remove()
end

local function onhit(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
end

local function RegisterDevice(inst,device)
    table.insert(inst.registered_devices,device)
end

local function getstatus(inst)
    return inst.AnimState:IsCurrentAnimation("idle_loop") and "IDLE"
        or nil
end

local function onsave_main(inst, data)
   data.product = inst.product
end

local function onloadpostpass_main(inst, ents, data)
    if data and data.product then
        local artifact = SpawnPrefab(data.product)
        artifact.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.components.finiteuses:Use(1)
    end
end

local function mainfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()

    inst.Light:SetFalloff(0.6)
    inst.Light:SetIntensity(.4)
    inst.Light:SetRadius(2)
    inst.Light:SetColour(237/255, 237/255, 209/255)

    inst.Light:EnableClientModulation(true)

    inst.widthscale = 1
    inst._endlight = {}
    inst._startlight = {}
    inst._currentlight = {}

    copyparams(inst._endlight, light_params.idle)
    copyparams(inst._startlight, inst._endlight)
    copyparams(inst._currentlight, inst._endlight)

    pushparams(inst, inst._currentlight)

  --  inst._lightphase = OFF

    inst._lighttask = nil

    inst.DynamicShadow:SetSize(1, .33)

    MakeObstaclePhysics(inst, 0.5)
    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("archive_resonator")
    inst.AnimState:SetBuild("archive_resonator")
    inst.AnimState:PlayAnimation("idle_loop",true)

    inst.candismantle = function()
        if inst.AnimState:IsCurrentAnimation("idle_loop") then
            return true
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinisheduses)
    inst.components.finiteuses:SetMaxUses(TUNING.ARCHIVE_RESONATOR.USES)
    inst.components.finiteuses:SetUses(TUNING.ARCHIVE_RESONATOR.USES)
    inst.OnDismantle = OnDismantle

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)
    inst.components.portablestructure.candismantle = function()
        if inst.AnimState:IsCurrentAnimation("idle_loop") then
            return true
        end
    end

    inst:ListenForEvent("onremove", function()
        if inst.target then
            inst.target:RemoveTag("marker_found")
        end
    end)

    inst.OnSave = onsave_main
    inst.OnLoadPostPass = onloadpostpass_main

    inst:AddComponent("lootdropper")
    inst.RegisterDevice = RegisterDevice

    return inst
end


local function OnTimerDone(inst, data)
    if data.name == "expire" then
        inst:Remove()
    end
end


local function onsave(inst, data)
   data.rotation = inst.Transform:GetRotation()
end

local function onload(inst, data, newents)
    if data ~= nil then
        if data.rotation then
           inst.Transform:SetRotation(data.rotation)
        end
    end
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.entity:AddLight()

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    inst.AnimState:SetBuild("archive_resonator")
    inst.AnimState:SetBank("archive_resonator")
    inst.AnimState:PlayAnimation("idle_marker", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst.components.timer:StartTimer("expire",TUNING.TOTAL_DAY_TIME)

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst:AddTag("usedeploystring")

    inst.AnimState:SetBank("archive_resonator")
    inst.AnimState:SetBuild("archive_resonator")
    inst.AnimState:PlayAnimation("pack_loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunch(inst)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.ARCHIVE_RESONATOR.USES)
    inst.components.finiteuses:SetUses(TUNING.ARCHIVE_RESONATOR.USES)


    return inst
end

return  Prefab("archive_resonator", mainfn, assets,prefabs),
		Prefab("archive_resonator_item", itemfn, assets, prefabs),
		MakePlacer("archive_resonator_item_placer", "archive_resonator", "archive_resonator", "idle_place"),
        Prefab("archive_resonator_base", basefn, assets,prefabs)

