local PotionCommon = require "prefabs/halloweenpotion_common"

local assets = JoinArrays(PotionCommon.assets,
{
    Asset("ANIM", "anim/livingtree_root.zip"),
    Asset("SCRIPT", "scripts/prefabs/halloweenpotion_common.lua"),
    Asset("INV_IMAGE", "livingtree_root_hallowed_nights")
})

local prefabs = JoinArrays(PotionCommon.prefabs,
{
    "livingtree_sapling",
})

local beat_delay = 15

local function PlayBeatAnimation(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function beat(inst)
    inst:PlayBeatAnimation()
    inst.beattask = inst:DoTaskInTime(beat_delay + math.random() * beat_delay, beat)
end

local function ondropped(inst)
    if inst.beattask ~= nil then
        inst.beattask:Cancel()
    end
    inst.beattask = inst:DoTaskInTime(beat_delay + math.random() * beat_delay, beat)
end

local function onpickup(inst)
    if inst.beattask ~= nil then
        inst.beattask:Cancel()
        inst.beattask = nil
    end
end

local LEIF_TAGS = { "leif" }
local function ondeploy(inst, pt, deployer)
    inst = inst.components.stackable:Get()
    inst.Physics:Teleport(pt:Get())

    local sapling = SpawnPrefab("livingtree_sapling")
    sapling.Transform:SetPosition(inst.Transform:GetWorldPosition())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()

    --tell any nearby leifs to chill out
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.LEIF_PINECONE_CHILL_RADIUS, LEIF_TAGS)

    local played_sound = false
    for i, v in ipairs(ents) do
        local chill_chance =
            v:GetDistanceSqToPoint(pt:Get()) < TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS * TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS and
            TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE or
            TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR

        if math.random() < chill_chance then
            if v.components.sleeper ~= nil then
                v.components.sleeper:GoToSleep(1000)
                AwardPlayerAchievement( "pacify_forest", deployer )
            end
        elseif not played_sound then
            v.SoundEmitter:PlaySound("dontstarve/creatures/leif/taunt_VO")
            played_sound = true
        end
    end
end

local function potion_onputinfire(inst, target)
    if target:HasTag("campfire") then
        PotionCommon.SpawnPuffFx(inst, target)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("deployedplant")

    inst.AnimState:SetBank("livingtree_root")
    inst.AnimState:SetBuild("livingtree_root")
    inst.AnimState:PlayAnimation("idle")
    if not IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        inst.AnimState:Hide("eye")
    end

    MakeInventoryFloatable(inst, "small", 0.2)

    inst.scrapbook_specialinfo = "PLANTABLE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    inst.components.fuel.ontaken = potion_onputinfire

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)
    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        inst.components.inventoryitem:ChangeImageName("livingtree_root_hallowed_nights")
    end

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = ondeploy

    inst.beattask = nil
    ondropped(inst)

    inst.PlayBeatAnimation = PlayBeatAnimation

    return inst
end

return Prefab("livingtree_root", fn, assets, prefabs),
    MakePlacer("livingtree_root_placer", "livingtree_root", "livingtree_root", "placer")
