local commonfn =  require "prefabs/bernie_common"
local brain = require("brains/berniebrain")

local assets =
{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("SOUND", "sound/together.fsb"),
	Asset("MINIMAP_IMAGE", "bernie"),
    Asset("SCRIPT", "scripts/prefabs/bernie_common.lua"),
}

local prefabs =
{
    "bernie_inactive",
    "bernie_big",
}

local function goinactive(inst)
    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", ""):gsub("_active", "")
    end

    local inactive = SpawnPrefab("bernie_inactive", skin_name, inst.skin_id, nil)
    if inactive ~= nil then
        --Transform health % into fuel.
        inactive.components.fueled:SetPercent(inst.components.health:GetPercent())
        inactive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inactive.Transform:SetRotation(inst.Transform:GetRotation())
        local bigcd = inst.components.timer:GetTimeLeft("transform_cd")
        if bigcd ~= nil then
            inactive.components.timer:StartTimer("transform_cd", bigcd)
        end
        inst:Remove()
        return inactive
    end
end

local function gobig(inst,leader)

    if leader.bigbernies then
        return
    end

    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", ""):gsub("_active", "_big")
    end

    local big = SpawnPrefab("bernie_big", skin_name, inst.skin_id, nil)
    if big ~= nil then
        --Rescale health %
        if not leader.bigbernies then
            leader.bigbernies = {}
        end

        leader.bigbernies[big] = true
        
        big.Transform:SetPosition(inst.Transform:GetWorldPosition())
        big.Transform:SetRotation(inst.Transform:GetRotation())
        big.components.health:SetPercent(inst.components.health:GetPercent())

        big:onLeaderChanged(leader)

        inst:Remove()

        big:CheckForAllegiances(leader)

        return big
    end
end

local function onpickup(inst, owner)
    local inactive = goinactive(inst)
    if inactive ~= nil then
        owner.components.inventory:GiveItem(inactive, nil, owner:GetPosition())
    end
    return true
end

local function OnSleepTask(inst)
    inst._sleeptask = nil
    inst:GoInactive()
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask = inst:DoTaskInTime(.5, OnSleepTask)
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .25)
    inst.DynamicShadow:SetSize(1, .5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.MiniMapEntity:SetIcon("bernie.png")

    inst:AddTag("smallcreature")
    inst:AddTag("companion")
    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_specialinfo = "BERNIE"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BERNIE_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("inspectable")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BERNIE_SPEED
    inst:AddComponent("combat")
    inst:AddComponent("timer")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:SetStateGraph("SGbernie")
    inst:SetBrain(brain)

    inst.GoInactive = goinactive
    inst.GoBig = gobig
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.hotheaded = commonfn.hotheaded
    inst.isleadercrazy = commonfn.isleadercrazy

    return inst
end

return Prefab("bernie_active", fn, assets, prefabs)
