local assets =
{
    Asset("ANIM", "anim/birdtrap.zip"),
    Asset("SOUND", "sound/common.fsb"),

    Asset("ANIM", "anim/crow_build.zip"),
    Asset("ANIM", "anim/robin_build.zip"),
    Asset("ANIM", "anim/robin_winter_build.zip"),
    Asset("ANIM", "anim/canary_build.zip"),
    Asset("ANIM", "anim/bird_mutant_build.zip"),
    Asset("ANIM", "anim/bird_mutant_spitter_build.zip"),

    Asset("SCRIPT", "scripts/prefabs/wortox_soul_common.lua"),

    -- Swapsymbol assets
}

local prefabs =
{
    -- everything it can "produce" and might need symbol swaps from
    "crow",
    "robin",
    "robin_winter",
    "canary",
    "bird_mutant",
    "bird_mutant_spitter",
}

--this should be redone as a periodic test, probably, so that we can control the expected return explicitly
local function CatchOffScreen(inst)
    inst._sleeptask = nil
    if not inst:IsInLimbo() and inst.components.trap ~= nil and inst.components.trap:IsBaited() and math.random() < 0.5 then
        local birdspawner = TheWorld.components.birdspawner
        if birdspawner ~= nil then
            local pos = inst:GetPosition()
            local bird = birdspawner:SpawnBird(pos)
            if bird ~= nil then
                bird.Physics:Teleport(pos:Get())
                bird:ReturnToScene()
                inst.components.trap.target = bird
                inst.components.trap:DoSpring()
                inst.sg:GoToState("full")
            end
        end
    end
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = inst:DoTaskInTime(1, CatchOffScreen)
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local sounds =
{
    close = "dontstarve/common/birdtrap_close",
    rustle = "dontstarve/common/birdtrap_rustle",
}

local function OnHarvested(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

local function SetTrappedSymbols(inst, build)
    inst.trappedbuild = build
    inst.AnimState:OverrideSymbol("trapped", build, "trapped")
end

local function OnSpring(inst, target, bait)
    if target.trappedbuild then
        SetTrappedSymbols(inst, target.trappedbuild)
    end
end

local function OnSave(inst, data)
    if inst.trappedbuild then
        data.trappedbuild = inst.trappedbuild
    end
end

local function OnLoad(inst, data)
    if data and data.trappedbuild then
        SetTrappedSymbols(inst, data.trappedbuild)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("birdtrap.png")

    inst.AnimState:SetBank("birdtrap")
    inst.AnimState:SetBuild("birdtrap")
    inst.AnimState:PlayAnimation("idle")
    inst.sounds = sounds

    inst:AddTag("trap")

    MakeInventoryFloatable(inst, "large", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_animoffsetbgx = 5
    inst.scrapbook_animoffsetbgy = 30

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    if TheNet:GetServerGameMode() ~= "quagmire" then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.TRAP_USES)
        inst.components.finiteuses:SetUses(TUNING.TRAP_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    end

    inst:AddComponent("trap")
    inst.components.trap.targettag = "bird"
    inst.components.trap:SetOnHarvestFn(OnHarvested)
    inst.components.trap:SetOnSpringFn(OnSpring)
    inst.components.trap.baitsortorder = 1

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:SetStateGraph("SGtrap")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("birdtrap", fn, assets, prefabs)
