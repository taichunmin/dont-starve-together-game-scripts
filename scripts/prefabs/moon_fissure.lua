require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/moon_fissure.zip"),
    Asset("ANIM", "anim/moon_fissure_fx.zip"),
}

local assets_plugged =
{
    Asset("ANIM", "anim/plugged_fissure.zip"),
}

local prefabs =
{
	"moon_fissure_fx",
	"moon_altar",
    "moon_altar_idol",
    "moon_altar_cosmic"
}

local prefabs_plugged =
{}

local lightstate_data =
{
    {enabled=false,  radius=  0.0, intensity = 1.0, falloff = 1.0,  sanityaura = 0,                        layers = {low = false, med = false, high = false, full = false} },
    {enabled=true,   radius=  3.0, intensity = 0.3, falloff = 2.25, sanityaura = 100/(TUNING.SEG_TIME*8),  layers = {low = true,  med = false, high = false, full = false} },
    {enabled=true,   radius=  6.0, intensity = 0.4, falloff = 2.0,  sanityaura = 100/(TUNING.SEG_TIME*4),  layers = {low = true,  med = true,  high = false, full = false} },
    {enabled=true,   radius= 11.0, intensity = 0.5, falloff = 1.9,  sanityaura = 100/(TUNING.SEG_TIME*2),  layers = {low = true,  med = true,  high = true,  full = false} },
    {enabled=true,   radius= 11.0, intensity = 0.5, falloff = 1.9,  sanityaura = 100/(TUNING.SEG_TIME*2),  layers = {low = true,  med = true,  high = true,  full = true } },
}

local r, g, b = 130/255, 160/255, 170/255

local MOON_STATES =
{
    new                 = 1,
    quarter             = 2,
    half                = 3,
    threequarter        = 4,
    full                = 5,
}

local LIGHT_RADIUS_RATE = 1 / (12 * FRAMES)

local function OnUpdateLight(inst)
	local lightstate = lightstate_data[inst._level:value()] or lightstate_data[1]
	local world_brightness = TheWorld.components.ambientlighting:GetVisualAmbientValue()

	local dt = FRAMES

	local target_radius = lightstate.radius
	local cur_radius = inst.Light:GetRadius()
	inst.Light:SetRadius(cur_radius + (target_radius - cur_radius) * dt * LIGHT_RADIUS_RATE)

	local target_intensity = lightstate.intensity
	local cur_intensity = inst.Light:GetIntensity()
	inst.Light:SetIntensity(cur_intensity + (target_intensity - cur_intensity) * dt * LIGHT_RADIUS_RATE)

	local target_falloff = lightstate.falloff
	local cur_falloff = inst.Light:GetFalloff()
	inst.Light:SetFalloff(cur_falloff + (target_falloff - cur_falloff) * dt * LIGHT_RADIUS_RATE)

	local cs = (1 - world_brightness*0.25)
	inst.Light:SetColour(r*cs, g*cs, b*cs)
end

local function on_piece_slotted(inst, slotter, slotted_item)
	local x, y, z = inst.Transform:GetWorldPosition()
    local altar = SpawnPrefab(slotted_item._socket_product)
	inst:Remove()
	altar.Transform:SetPosition(x, y, z)
    altar:PushEvent("on_fissure_socket")
end

local function check_piece(inst, piece)
    if piece._socket_product ~= nil then
        return true
    else
        return false, "WRONGPIECE"
    end
end

local function UpdateState(inst)
	local level = MOON_STATES[TheWorld.state.moonphase]
	local lightstate = lightstate_data[level]

	for layer, enable in pairs(lightstate.layers) do
		inst.AnimState:Hide(layer)
		if enable then
			inst.fx.AnimState:Show(layer)
		else
			inst.fx.AnimState:Hide(layer)
		end
    end
	if lightstate.enabled then
		inst.fx.AnimState:Show("backing")
		inst.AnimState:Hide("backing")
	else
		inst.fx.AnimState:Hide("backing")
		inst.AnimState:Show("backing")
	end

	inst.Light:Enable(lightstate.enabled)
    inst.components.sanityaura.max_distsq = lightstate.radius * lightstate.radius * 1.25 * 1.25
	inst._level:set(level)
end

local function delayed_transition(inst)
	inst._level:set(0)
	inst.AnimState:PlayAnimation("transition")
	inst.AnimState:PushAnimation("crack_idle", true)
	inst.fx.AnimState:PlayAnimation("transition")
	inst.fx.AnimState:PushAnimation("crack_idle", true)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_fissure/crack_open")
	inst._transition_task = inst:DoTaskInTime(5*FRAMES, UpdateState)
end

local function onmoonphasechagned(inst, phase)
	if inst._transition_task ~= nil then
		inst._transition_task:Cancel()
	end
	inst._transition_task = inst:DoTaskInTime(math.random(), delayed_transition)
end

local function aurafn(inst, observer)
	return (lightstate_data[inst._level:value()] or lightstate_data[1]).sanityaura
end

local function aurafallofffn(inst, observer, distsq)
	distsq = aurafn(inst, observer) + math.sqrt(math.max(1, distsq))
	return distsq
end

local function OnEntitySleep(inst)
    if inst._lighttask ~= nil then
        inst._lighttask:Cancel()
		inst._lighttask = nil
    end
    inst.SoundEmitter:KillSound("loop")
end

local function OnEntityWake(inst)
    if inst._lighttask == nil then
	    inst._lighttask = inst:DoPeriodicTask(0, OnUpdateLight)
	end
    -- inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_fissure/LP", "loop")
end

local function getstatus(inst)
    return (inst._level:value() == 1 and "NOLIGHT") or
           nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(0.4)

    inst._lighttask = inst:DoPeriodicTask(0, OnUpdateLight)

    inst.AnimState:SetBank("moon_fissure")
    inst.AnimState:SetBuild("moon_fissure")
    inst.AnimState:PlayAnimation("crack_idle", true)    
    inst.AnimState:SetFinalOffset(3)

    inst._level = net_tinybyte(inst.GUID, "moonfissure.level", "leveldirty")
    inst._level:set(MOON_STATES[TheWorld.state.moonphase])

    OnUpdateLight(inst)

    inst:AddTag("antlion_sinkhole_blocker")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_removedeps = { "moon_altar_idol" }
    inst.scrapbook_sanityaura = 100/(TUNING.SEG_TIME*4)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable") -- here for repairable
    inst.components.workable:SetMaxWork(1)
	inst.components.workable.workleft = 0

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.max_distsq = 1
	inst.components.sanityaura.aurafn = aurafn
    inst.components.sanityaura.fallofffn = aurafallofffn

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.MOON_ALTAR
    inst.components.repairable.onrepaired = on_piece_slotted
    inst.components.repairable.checkmaterialfn = check_piece
    inst.components.repairable.noannounce = true

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.fx = SpawnPrefab("moon_fissure_fx")
    inst.fx.entity:SetParent(inst.entity)

    inst:WatchWorldState("moonphase", onmoonphasechagned)
    UpdateState(inst)


    return inst
end

local function fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork() -- this is networked coz we trigger animations on it

    inst.AnimState:SetBank("moon_fissure_fx")
    inst.AnimState:SetBuild("moon_fissure_fx")
    inst.AnimState:PlayAnimation("crack_idle", true)

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function plugged_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork() -- this is networked coz we trigger animations on it
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("plugged_fissure")
    inst.AnimState:SetBuild("plugged_fissure")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("toot",(math.random()*10)* TUNING.SEG_TIME )

    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "toot" then
            inst.AnimState:PlayAnimation("toot_pre")
        end
    end)

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("toot_pre") then
            inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/plugged_fissure/"..math.random(1,3))
            inst.AnimState:PlayAnimation("toot")
            inst.AnimState:PushAnimation("toot_pst",false)
            inst.AnimState:PushAnimation("idle",true)
            inst.components.timer:StartTimer("toot",(6 + (math.random()*4)) * TUNING.SEG_TIME )
            TheWorld:PushEvent("moonfissurevent",inst)
        end
    end)


    return inst
end

return Prefab("moon_fissure", fn, assets, prefabs),
       Prefab("moon_fissure_plugged", plugged_fn, assets_plugged, prefabs_plugged),
	   Prefab("moon_fissure_fx", fx_fn, assets)

