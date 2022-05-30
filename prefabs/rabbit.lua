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

local function BecomeRabbit(inst)
    if inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("rabbit_build")
    inst.sounds = rabbitsounds
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

local RABBIT_MUST_TAGS = { "rabbit" }
local RABBIT_CANT_TAGS = { "INLIMBO" }
local function OnAttacked(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, RABBIT_MUST_TAGS, RABBIT_CANT_TAGS)
    local maxnum = 5
    for i, v in ipairs(ents) do
        v:PushEvent("gohome")
        if i >= maxnum then
            break
        end
    end
end

local function OnDropped(inst)
    inst.sg:GoToState("stunned")
end

local function getmurdersound(inst, doer)
    return IsCrazyGuy(doer) and beardsounds.hurt or inst.sounds.hurt
end

local function drawimageoverride(inst, viewer)
    return IsCrazyGuy(viewer) and "beard_monster"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

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
    inst:AddTag("stunnedbybomb")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_build", "beard_monster")
    inst.AnimState:SetClientsideBuildOverride("insane", "rabbit_winter_build", "beard_monster")

    inst:SetClientSideInventoryImageOverride("insane", "rabbit.tex", "beard_monster.tex")
    inst:SetClientSideInventoryImageOverride("insane", "rabbit_winter.tex", "beard_monster.tex")

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
    inst.components.health.murdersound = getmurdersound

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)
    LootSetupFunction(inst.components.lootdropper)

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
    inst.components.sleeper.watchlight = true
    inst:AddComponent("tradable")

    inst.sounds = nil
    inst.task = nil
    BecomeRabbit(inst)
    inst:DoTaskInTime(0, OnInit)

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)

    MakeFeedableSmallLivestock(inst, TUNING.RABBIT_PERISH_TIME, nil, OnDropped)

    inst.drawimageoverride = drawimageoverride

    return inst
end

return Prefab("rabbit", fn, assets, prefabs)
