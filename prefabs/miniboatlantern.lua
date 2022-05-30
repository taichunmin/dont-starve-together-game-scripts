local assets =
{
    Asset("ANIM", "anim/yotc_lantern_boat.zip"),
}

local prefabs =
{
    "miniboatlanternlight",
    "miniboatlantern_loseballoon",
    "small_puff",
}

local brain = require "brains/miniboatlanternbrain"

local LIGHT_RADIUS = 1.2
local LIGHT_COLOUR = Vector3(235 / 255, 150 / 255, 100 / 255)
local LIGHT_INTENSITY = .8
local LIGHT_FALLOFF = .5

local sounds =
{
    active_loop = "dontstarve/wilson/lantern_LP",
}

local balloon_layers =
{
    "balloon",
    "string",
    "string_base",
}

local function OnUpdateFlicker(inst, starttime)
    local time = starttime ~= nil and (GetTime() - starttime) * 15 or 0
    local flicker = (math.sin(time) + math.sin(time + 2) + math.sin(time + 0.7777)) * .5 -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetRadius(LIGHT_RADIUS + .1 * flicker)
    flicker = flicker * 2 / 255
    inst.Light:SetColour(LIGHT_COLOUR.x + flicker, LIGHT_COLOUR.y + flicker, LIGHT_COLOUR.z + flicker)
end

local function HasFuel(inst)
    return inst.components.fueled ~= nil and not inst.components.fueled:IsEmpty() or false
end

local function OnTimerDone(inst, data)
    if data.name == "self_combustion" then
        if not inst.components.burnable:IsBurning() and HasFuel(inst) then
            inst.components.burnable:Ignite()
        end
    end
end

local function StartSelfCombustionTimer(inst, time_to_combustion)
    if not inst.components.timer:TimerExists("self_combustion") then
        time_to_combustion = time_to_combustion or
            math.max(1, math.min(math.random(inst.components.fueled.maxfuel * 0.45, inst.components.fueled.maxfuel), inst.components.fueled.currentfuel - 10))

        inst.components.timer:StartTimer("self_combustion", time_to_combustion)
    end
end

local function TurnOn(inst)
	if HasFuel(inst) then
		inst.components.fueled:StartConsuming()

        if inst._light == nil then
            inst._light = SpawnPrefab("miniboatlanternlight")
        end
		inst.AnimState:Show("glow")
        inst._light.entity:SetParent(inst.entity)

        inst.components.timer:ResumeTimer("self_combustion")

        inst.SoundEmitter:PlaySound(sounds.active_loop, "lp")
	end
end

local function TurnOff(inst)
	if inst._light ~= nil then
		inst._light:Remove()
		inst._light = nil
	end

    inst.AnimState:Hide("glow")

    inst.components.locomotor:Stop()

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

	if inst._acceleration_task ~= nil then
		inst._acceleration_task:Cancel()
		inst._acceleration_task = nil
    end

    inst.components.timer:PauseTimer("self_combustion")

    inst:PushEvent("onturnoff")

    inst.SoundEmitter:KillSound("lp")
end

local function SpawnBalloonFX(inst, hide_symbols)
    if not POPULATING then
        local balloon = SpawnPrefab("miniboatlantern_loseballoon")
        balloon.Transform:SetPosition(inst.Transform:GetWorldPosition())
        balloon.Transform:SetRotation(inst.Transform:GetRotation())
    end
    if hide_symbols then
        for _,v in pairs(balloon_layers) do
            inst.AnimState:Hide(v)
        end
    end
end

local function nofuel(inst)
    SpawnBalloonFX(inst, true)
    TurnOff(inst)
    inst.components.timer:StopTimer("self_combustion")
    if inst.components.burnable:IsBurning() then
        inst.components.burnable:Ignite()
    end
end

local function OnDropped(inst)
    TurnOn(inst)
end

local function OnPutInInventory(inst)
    TurnOff(inst)
end

local function AccelerationTick(inst)
	inst.components.locomotor.walkspeed = inst.components.locomotor.walkspeed + TUNING.MINIBOATLANTERN_ACCELERATION

	if inst.components.locomotor.walkspeed >= TUNING.MINIBOATLANTERN_SPEED then
		inst.components.locomotor.walkspeed = TUNING.MINIBOATLANTERN_SPEED

		inst._acceleration_task:Cancel()
		inst._acceleration_task = nil
	end
end

local function OnInventoryLanded(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.knownlocations:RememberLocation("home", Point(x, y, z))

	if TheWorld.Map:IsPassableAtPoint(x, y, z) then
        if HasFuel(inst) then
            inst.components.locomotor.walkspeed = 0

            if inst._acceleration_task ~= nil then
                inst._acceleration_task:Cancel()
            end
            inst._acceleration_task = inst:DoPeriodicTask(FRAMES, AccelerationTick)
        end
	else
        if inst._acceleration_task ~= nil then
            inst._acceleration_task:Cancel()
            inst._acceleration_task = nil
        end
    end

    inst.sg:GoToState("idle")
end

local function OnBurnt(inst)
    SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if HasFuel(inst) then
        SpawnBalloonFX(inst)
    end
end

local function OnExtinguish(inst)
    OnBurnt(inst)
    inst:Remove()
end

local function OnHaunt(inst)
    if math.random() < TUNING.HAUNT_CHANCE_RARE then
        if not inst.components.burnable:IsBurning() then
            inst.components.burnable:Ignite()
        end
    end
    return false
end

local function OnSave(inst, data)
    if inst.components.fueled == nil or inst.components.fueled:IsEmpty() then
        data.nofuel = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.nofuel then
            nofuel(inst)
        end
    end
end

local function lanternlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(LIGHT_INTENSITY)
    --inst.Light:SetColour(LIGHT_COLOUR.x, LIGHT_COLOUR.y, LIGHT_COLOUR.z)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    --inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:EnableClientModulation(true)

    inst:DoPeriodicTask(.1, OnUpdateFlicker, nil, GetTime())
    OnUpdateFlicker(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lantern_boat")
    inst.AnimState:SetBuild("yotc_lantern_boat")
	--inst.AnimState:PlayAnimation("idle", true)

    inst.Transform:SetSixFaced()

    MakeInventoryFloatable(inst, "small", 0.165, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	--inst._acceleration_task = nil
    --inst._light = nil

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.MINIBOATLANTERN_SPEED
	inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC -- no associated fuel, and not burnable fuel, since we want this item to be lit on fire
    inst.components.fueled:InitializeFuelLevel(TUNING.MINIBOATLANTERN_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

	inst:AddComponent("knownlocations")

	inst:SetStateGraph("SGminiboatlantern")
	inst:SetBrain(brain)

    MakeSmallBurnable(inst, TUNING.MINIBOATLANTERN_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable.ignorefuel = true -- igniting/extinguishing should not start/stop fuel consumption

    inst:AddComponent("timer")
    StartSelfCombustionTimer(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    TurnOn(inst)

    inst:ListenForEvent("on_landed", OnInventoryLanded)
    inst:ListenForEvent("onburnt", OnBurnt)
    inst:ListenForEvent("onextinguish", OnExtinguish)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("miniboatlantern", fn, assets, prefabs),
	Prefab("miniboatlanternlight", lanternlightfn)
