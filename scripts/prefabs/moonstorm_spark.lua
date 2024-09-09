local assets =
{
    Asset("ANIM", "anim/charged_particle.zip"),
}

local prefabs =
{
    "moonstorm_spark_shock_fx",
}

local brain = require "brains/sporebrain"


local SPARK_CANT_TAGS = { "playerghost", "INLIMBO", "moonstorm_static","wall","structure"}
local SPARK_MUST_TAGS = { "moonsparkchargeable" }

local function dospark(inst)
    if inst:IsInLimbo() then
        print(debugstack())
    end
    local fx = inst:SpawnChild("moonstorm_spark_shock_fx")
    inst.sparktask = inst:DoTaskInTime(5/30, function()
        inst.Light:SetRadius(2)
        local pos = Vector3(inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 4, nil, SPARK_CANT_TAGS)
        if #ents > 0 then
            for i, ent in ipairs(ents)do
                if ent.components.combat ~= nil and (ent.components.inventory == nil or not ent.components.inventory:IsInsulated()) then
                    ent.components.combat:GetAttacked(inst, TUNING.LIGHTNING_DAMAGE, nil, "electric")
                    if ent.components.hauntable ~= nil and ent.components.hauntable.panicable then
                        ent.components.hauntable:Panic(2)
                    end
                end
            end
        end
        ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 4, SPARK_MUST_TAGS)
        if #ents > 0 then
            for i, ent in ipairs(ents)do
                ent.components.fueled:SetPercent(math.min(1,ent.components.fueled:GetPercent()+0.1))
            end
        end
        inst:DoTaskInTime(0.5,function()
            inst.Light:SetRadius(1.5)
        end)
        inst.sparktask = inst:DoTaskInTime(5 + math.random()* 10, dospark)
    end)

end

local function depleted(inst)
    if inst:IsInLimbo() then
        inst:Remove()
    else
        inst.components.workable:SetWorkable(false)
        inst:PushEvent("death")
        inst:RemoveTag("spore") -- so crowding no longer detects it
        inst.persists = false
        -- clean up when offscreen, because the death event is handled by the SG
        inst:DoTaskInTime(3, inst.Remove)
    end
end

local SPORE_TAGS = {"spore"}
local function checkforcrowding(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spores = TheSim:FindEntities(x,y,z, TUNING.MUSHSPORE_MAX_DENSITY_RAD, SPORE_TAGS)
    if #spores > TUNING.MUSHSPORE_MAX_DENSITY then
        inst.components.perishable:SetPercent(0)
    else
        inst.crowdingtask = inst:DoTaskInTime(TUNING.MUSHSPORE_DENSITY_CHECK_TIME + math.random()*TUNING.MUSHSPORE_DENSITY_CHECK_VAR, checkforcrowding)
    end
end

local function onpickup(inst)
    --These last longer when held
    inst.components.perishable:SetLocalMultiplier( TUNING.SEG_TIME * 3/ TUNING.PERISH_SLOW )
    inst.SoundEmitter:KillSound("idle_LP")
    if inst.crowdingtask ~= nil then
        inst.crowdingtask:Cancel()
        inst.crowdingtask = nil
    end
    if inst.sparktask then
        inst.sparktask:Cancel()
        inst.sparktask = nil
    end
    inst.Light:Enable(false)
end

local function ondropped(inst)
    --Disappears faster when floating
    inst.components.perishable:SetLocalMultiplier(1)
    if not inst:IsAsleep() then
        inst.SoundEmitter:PlaySound("moonstorm/common/moonstorm/spark_LP", "idle_LP")
    end
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end

    if inst.components.stackable ~= nil then
        while inst.components.stackable:StackSize() > 1 do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        end
    end

    if inst.crowdingtask == nil then
        inst.crowdingtask = inst:DoTaskInTime(TUNING.MUSHSPORE_DENSITY_CHECK_TIME + math.random()*TUNING.MUSHSPORE_DENSITY_CHECK_VAR, checkforcrowding)
    end
    inst.Light:Enable(true)

    if not inst.sparktask then
        inst.sparktask = inst:DoTaskInTime(5 + math.random()* 10, dospark)
    end
end

local function onload(inst)
    -- If we loaded, then just turn the light on
    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(true)
end

local function onworked(inst, worker)
    if worker.components.inventory ~= nil then

        if TheWorld.components.moonstormmanager then
            TheWorld.components.moonstormmanager:DoTestForSparks()
        end

        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
        inst.SoundEmitter:KillSound("idle_LP")
    end
end

local function OnWake(inst)
    if not inst.sparktask and not inst:IsInLimbo() then
        inst.sparktask = inst:DoTaskInTime(5 + math.random()* 10, dospark)
    end
    if not inst.components.inventoryitem:IsHeld() then
        inst.SoundEmitter:PlaySound("moonstorm/common/moonstorm/spark_LP", "idle_LP")
    end
end

local function OnSleep(inst)
    if inst.sparktask then
        inst.sparktask:Cancel()
        inst.sparktask = nil
    end
    inst.SoundEmitter:KillSound("idle_LP")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

	--MakeCharacterPhysics(inst, 1, .5)
    MakeFlyingCharacterPhysics(inst, 1, .5)

    inst.AnimState:SetBuild("charged_particle")
    inst.AnimState:SetBank("charged_particle")
    inst.AnimState:PlayAnimation("idle_flight_loop", true)

    inst.DynamicShadow:Enable(false)

    inst.Light:SetColour(111/255, 111/255, 227/255)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(1.5)
    inst.Light:Enable(true)

    inst.DynamicShadow:SetSize(.8, .5)

    inst:AddTag("show_spoilage")
    inst:AddTag("moonstorm_spark")

    inst.scrapbook_damage = TUNING.LIGHTNING_DAMAGE
    inst.scrapbook_animpercent = 0.5
    inst.scrapbook_anim = "idle_flight_loop"
    inst.scrapbook_animoffsetx = 20
    inst.scrapbook_animoffsety = 35

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
	inst:AddComponent("tradable")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = 2

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.SetOnPutInInventoryFn = onpickup

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworked)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.SPARK_PERISH_TIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(depleted)

    inst:AddComponent("stackable")

    MakeHauntablePerish(inst, .5)

    inst:ListenForEvent("onputininventory", onpickup)
    inst:ListenForEvent("ondropped", ondropped)

    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep

    inst:SetStateGraph("SGspore")
    inst:SetBrain(brain)

    -- note: the first check is faster, because this might be from dropping a stack
    inst.crowdingtask = inst:DoTaskInTime(1 + math.random()*TUNING.MUSHSPORE_DENSITY_CHECK_VAR, checkforcrowding)

    inst.sparktask = inst:DoTaskInTime(5 + math.random()* 10, dospark)

    inst.OnLoad = onload

    return inst
end

return Prefab("moonstorm_spark", fn, assets, prefabs)
