local assets =
{
    Asset("ANIM", "anim/ds_rabbit_basic.zip"),
    Asset("ANIM", "anim/rabbit_build.zip"),
    Asset("ANIM", "anim/beard_monster.zip"),
    Asset("ANIM", "anim/rabbit_winter_build.zip"),
    Asset("SOUND", "sound/rabbit.fsb"),
	Asset("INV_IMAGE", "beard_monster" ),
	Asset("INV_IMAGE", "rabbit_winter" ),
}

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
    "cookedmonstermeat",
    "beardhair",
    "monstermeat",
    "nightmarefuel",
}

local rabbitsounds =
{
    scream = "dontstarve/rabbit/scream",
    hurt = "dontstarve/rabbit/scream_short",
}

local beardsounds =
{
    scream = "dontstarve/rabbit/beardscream",
    hurt = "dontstarve/rabbit/beardscream_short",
}

local wintersounds =
{
    scream = "dontstarve/rabbit/winterscream",
    hurt = "dontstarve/rabbit/winterscream_short",
}

local rabbitloot = { "smallmeat" }

local brain = require("brains/rabbitbrain")

local function IsWinterRabbit(inst)
    return inst.sounds == wintersounds
end

local function IsCrazyGuy(guy)
    local sanity = guy ~= nil and guy.replica.sanity or nil
    return sanity ~= nil and sanity:IsInsanityMode() and sanity:GetPercentNetworked() <= (guy:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY)
end

local function SetRabbitLoot(lootdropper)
    if lootdropper.loot ~= rabbitloot and not lootdropper.inst._fixedloot then
        lootdropper:SetLoot(rabbitloot)
    end
end

local function SetBeardlingLoot(lootdropper)
    if lootdropper.loot == rabbitloot and not lootdropper.inst._fixedloot then
        lootdropper:SetLoot(nil)
        lootdropper:AddRandomLoot("beardhair", .5)
        lootdropper:AddRandomLoot("monstermeat", 1)
        lootdropper:AddRandomLoot("nightmarefuel", 1)
        lootdropper.numrandomloot = 1
    end
end

local function MakeInventoryRabbit(inst)
    inst._crazyinv = nil
    inst.components.inventoryitem:ChangeImageName(IsWinterRabbit(inst) and "rabbit_winter" or "rabbit")
    inst.components.health.murdersound = inst.sounds.hurt
    SetRabbitLoot(inst.components.lootdropper)
end

local function MakeInventoryBeardMonster(inst)
    inst._crazyinv = true
    SetBeardlingLoot(inst.components.lootdropper)
    inst.components.inventoryitem:ChangeImageName("beard_monster")
    inst.components.health.murdersound = beardsounds.hurt
end

local function UpdateInventoryState(inst)
    local viewer = inst.components.inventoryitem:GetGrandOwner()
    while viewer ~= nil and viewer.components.container ~= nil do
        viewer = viewer.components.container.opener
    end
    if IsCrazyGuy(viewer) then
        MakeInventoryBeardMonster(inst)
    else
        MakeInventoryRabbit(inst)
    end
end

local function BecomeRabbit(inst)
    if inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("rabbit_build")
    inst.sounds = rabbitsounds
    UpdateInventoryState(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable.haunted = false
    end
end

local function BecomeWinterRabbit(inst)
    if inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("rabbit_winter_build")
    inst.sounds = wintersounds
    UpdateInventoryState(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable.haunted = false
    end
end

local function OnIsWinter(inst, iswinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if iswinter then
        if not IsWinterRabbit(inst) then
            inst.task = inst:DoTaskInTime(math.random() * .5, BecomeWinterRabbit)
        end
    elseif IsWinterRabbit(inst) then
        inst.task = inst:DoTaskInTime(math.random() * .5, BecomeRabbit)
    end
end

local function OnWake(inst)
    inst:WatchWorldState("iswinter", OnIsWinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if TheWorld.state.iswinter then
        if not IsWinterRabbit(inst) then
            BecomeWinterRabbit(inst)
        end
    elseif IsWinterRabbit(inst) then
        BecomeRabbit(inst)
    end
end

local function OnSleep(inst)
    inst:StopWatchingWorldState("iswinter", OnIsWinter)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function OnInit(inst)
    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep
    if inst.entity:IsAwake() then
        OnWake(inst)
    end
end

local function CalcSanityAura(inst, observer)
    return IsCrazyGuy(observer) and -TUNING.SANITYAURA_MED or 0
end

local function GetCookProductFn(inst, cooker, chef)
    return IsCrazyGuy(chef) and "cookedmonstermeat" or "cookedsmallmeat"
end

local function OnCookedFn(inst, cooker, chef)
    inst.SoundEmitter:PlaySound(IsCrazyGuy(chef) and beardsounds.hurt or inst.sounds.hurt)
end

local function LootSetupFunction(lootdropper)
    local guy = lootdropper.inst.causeofdeath
    if IsCrazyGuy(guy ~= nil and guy.components.follower ~= nil and guy.components.follower.leader or guy) then
        SetBeardlingLoot(lootdropper)
    else
        SetRabbitLoot(lootdropper)
    end
end

local function OnAttacked(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, { "rabbit" }, { "INLIMBO" })
    local maxnum = 5
    for i, v in ipairs(ents) do
        v:PushEvent("gohome")
        if i >= maxnum then
            break
        end
    end
end

local function StopWatchingSanity(inst)
    if inst._sanitywatching ~= nil then
        inst:RemoveEventCallback("sanitydelta", inst.OnWatchSanityDelta, inst._sanitywatching)
        inst._sanitywatching = nil
    end
end

local function WatchSanity(inst, target)
    StopWatchingSanity(inst)
    if target ~= nil then
        inst:ListenForEvent("sanitydelta", inst.OnWatchSanityDelta, target)
        inst._sanitywatching = target
    end
end

local function StopWatchingForOpener(inst)
    if inst._openerwatching ~= nil then
        inst:RemoveEventCallback("onopen", inst.OnContainerOpened, inst._openerwatching)
        inst:RemoveEventCallback("onclose", inst.OnContainerClosed, inst._openerwatching)
        inst._openerwatching = nil
    end
end

local function WatchForOpener(inst, target)
    StopWatchingForOpener(inst)
    if target ~= nil then
        inst:ListenForEvent("onopen", inst.OnContainerOpened, target)
        inst:ListenForEvent("onclose", inst.OnContainerClosed, target)
        inst._openerwatching = target
    end
end

local function OnPickup(inst, owner)
    if owner.components.container ~= nil then
        WatchForOpener(inst, owner)
        WatchSanity(inst, owner.components.container.opener)
    else
        StopWatchingForOpener(inst)
        WatchSanity(inst, owner)
    end
    UpdateInventoryState(inst)
end

local function OnDropped(inst)
    StopWatchingSanity(inst)
    UpdateInventoryState(inst)
    inst.sg:GoToState("stunned")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("rabbit")
    inst.AnimState:SetBuild("rabbit_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_build", "beard_monster")
    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_winter_build", "beard_monster")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.RABBIT_RUN_SPEED
    inst:SetStateGraph("SGrabbit")

    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    inst:AddComponent("knownlocations")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.RABBIT_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/rabbit").master_postinit(inst)
    else
        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "chest"

        MakeSmallBurnableCharacter(inst, "chest")
        MakeTinyFreezableCharacter(inst, "chest")
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    inst:AddComponent("tradable")

    --declared here so it can be used for event handlers
    inst.OnWatchSanityDelta = function(viewer)
        if IsCrazyGuy(viewer) then
            if not inst._crazyinv then
                MakeInventoryBeardMonster(inst)
            end
        elseif inst._crazyinv then
            MakeInventoryRabbit(inst)
        end
    end

    inst.OnContainerOpened = function(container, data)
        WatchSanity(inst, data.doer)
        UpdateInventoryState(inst)
    end

    inst.OnContainerClosed = function()
        StopWatchingSanity(inst)
        UpdateInventoryState(inst)
    end

    inst._sanitywatching = nil
    inst._openerwatching = nil

    inst.sounds = nil
    inst.task = nil
    BecomeRabbit(inst)
    inst:DoTaskInTime(0, OnInit)

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)

    MakeFeedableSmallLivestock(inst, TUNING.RABBIT_PERISH_TIME, OnPickup, OnDropped)

    return inst
end

return Prefab("rabbit", fn, assets, prefabs)
