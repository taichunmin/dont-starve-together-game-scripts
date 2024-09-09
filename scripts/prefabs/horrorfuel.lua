local assets =
{
    Asset("ANIM", "anim/horrorfuel.zip"),
}

local prefabs =
{
    "wurt_merm_planar",
    "horrorfuel_castfx",
    "horrorfuel_castfx_mount",
}
--------------------------------------------------------------------------

local _player = nil
local AWAKELIST = {}

local function CalcTargetLightOverride(player)
    if player ~= nil then
        local sanity = player.replica.sanity
        if sanity ~= nil and sanity:IsInsanityMode() then
            local k = sanity:GetPercent()
            if k < 0.6 then
                k = 1 - k / 0.6
                return k * k
            end
        end
    end
    return 0
end

local function UpdateLightOverride(inst, instant)
    inst.targetlight = CalcTargetLightOverride(_player)
    inst.currentlight = instant and inst.targetlight or inst.targetlight * .1 + inst.currentlight * .9
    inst.AnimState:SetLightOverride(inst.currentlight)
end

local function OnSanityDelta(player, data)
    if data ~= nil and not data.overtime then
        for k in pairs(AWAKELIST) do
            UpdateLightOverride(k, true)
        end
    end
end

local function OnRemovePlayer(player)
    _player = nil
end

local function StopWatchingPlayerSanity(world)
    if _player ~= nil then
        world:RemoveEventCallback("sanitydelta", OnSanityDelta, _player)
        world:RemoveEventCallback("onremove", OnRemovePlayer, _player)
        _player = nil
    end
end

local function WatchPlayerSanity(world, player)
    world:ListenForEvent("sanitydelta", OnSanityDelta, player)
    world:ListenForEvent("onremove", OnRemovePlayer, player)
    _player = player
end

local function OnPlayerActivated(world, player)
    if _player ~= player then
        StopWatchingPlayerSanity(world)
        WatchPlayerSanity(world, player)
        for k in pairs(AWAKELIST) do
            UpdateLightOverride(k, true)
        end
    end
end

local function OnEntityWake(inst)
    if not AWAKELIST[inst] then
        if next(AWAKELIST) == nil then
            if _player ~= ThePlayer then
                StopWatchingPlayerSanity(TheWorld)
                WatchPlayerSanity(TheWorld, ThePlayer)
            end
            TheWorld:ListenForEvent("playeractivated", OnPlayerActivated)
        end
        AWAKELIST[inst] = true
        inst.task = inst:DoPeriodicTask(1, UpdateLightOverride, math.random())
        UpdateLightOverride(inst, true)
    end
end

local function OnEntitySleep(inst)
    if AWAKELIST[inst] then
        AWAKELIST[inst] = nil
        if next(AWAKELIST) == nil then
            StopWatchingPlayerSanity(TheWorld)
            TheWorld:RemoveEventCallback("playeractivated", OnPlayerActivated)
        end
        inst.task:Cancel()
        inst.task = nil
    end
end

local function CreateCore()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("horrorfuel")
    inst.AnimState:SetBuild("horrorfuel")
    inst.AnimState:PlayAnimation("middle_loop", true)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    inst.AnimState:SetFinalOffset(1)

    inst.currentlight = 0
    inst.targetlight = 0
    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnEntitySleep

    return inst
end

local function PushCheerEvent(inst)
    if inst:HasTag("shadowminion") and not inst.components.health:IsDead() then
        inst:PushEvent("cheer")
    end
end

local function Wurt_MermSpellFn(inst, target, pos, doer)
    for follower, _ in pairs(doer.components.leader.followers) do
        if follower:HasTag("shadowminion") and not follower.components.health:IsDead() then
            follower:DoTaskInTime(.3*math.random(), PushCheerEvent)
            follower:AddDebuff("wurt_merm_planar", "wurt_merm_planar")
        end
    end

    if inst.components.stackable ~= nil then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("horrorfuel")
    inst.AnimState:SetBuild("horrorfuel")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    inst.AnimState:UsePointFiltering(true)

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    inst:AddTag("purehorror")
    inst:AddTag("mermbuffcast")

    MakeInventoryFloatable(inst)

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst.core = CreateCore()
        inst.core.entity:SetParent(inst.entity)

        inst.highlightchildren = { inst.core }
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inspectable")
    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL * 2
    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.NIGHTMARE
    inst.components.repairer.finiteusesrepairvalue = TUNING.NIGHTMAREFUEL_FINITEUSESREPAIRVALUE * 2

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellType(SPELLTYPES.WURT_SHADOW)
    inst.components.spellcaster:SetSpellFn(Wurt_MermSpellFn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.canonlyuseonlocomotorspvp = true

    inst.lightcolour = {102/255, 16/255, 16/255}
    inst.fxprefab = "horrorfuel_castfx"
    inst.castsound = "meta4/casting/shadow"

    return inst
end

return Prefab("horrorfuel", fn, assets, prefabs)
