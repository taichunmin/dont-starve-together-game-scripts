local fns = {} -- a table to store local functions in so that we don't hit the 60 upvalues limit

local assets =
{
    Asset("ANIM", "anim/beefalo_basic.zip"),
    Asset("ANIM", "anim/beefalo_actions.zip"),
    Asset("ANIM", "anim/beefalo_actions_domestic.zip"),
    Asset("ANIM", "anim/beefalo_actions_quirky.zip"),
    Asset("ANIM", "anim/beefalo_build.zip"),
    Asset("ANIM", "anim/beefalo_shaved_build.zip"),
    Asset("ANIM", "anim/beefalo_baby_build.zip"),

    Asset("ANIM", "anim/beefalo_domesticated.zip"),
    Asset("ANIM", "anim/beefalo_personality_docile.zip"),
    Asset("ANIM", "anim/beefalo_personality_ornery.zip"),
    Asset("ANIM", "anim/beefalo_personality_pudgy.zip"),

    Asset("ANIM", "anim/beefalo_skin_change.zip"),

    Asset("ANIM", "anim/beefalo_carrat_idles.zip"),
    Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),

    Asset("ANIM", "anim/beefalo_carry.zip"),

    Asset("ANIM", "anim/beefalo_fx.zip"),
    Asset("ANIM", "anim/poop_cloud.zip"),

    Asset("SOUND", "sound/beefalo.fsb"),

    Asset("MINIMAP_IMAGE", "beefalo_domesticated"),
}

local prefabs =
{
    "meat",
    "poop",
    "beefalowool",
    "horn",
    "carrat",
    "explode_reskin",
    "beefalo_carry",
}

local brain = require("brains/beefalobrain")

SetSharedLootTable( 'beefalo',
{
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'beefalowool',     1.00},
    {'beefalowool',     1.00},
    {'beefalowool',     1.00},
    {'horn',            0.33},
})

local sounds =
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",
    sleep = "dontstarve/beefalo/sleep",
}

local tendencies =
{
    DEFAULT =
    {
    },

    ORNERY =
    {
        build = "beefalo_personality_ornery",
    },

    RIDER =
    {
        build = "beefalo_personality_docile",
    },

    PUDGY =
    {
        build = "beefalo_personality_pudgy",
        customactivatefn = function(inst)
            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
        end,
        customdeactivatefn = function(inst)
            inst:RemoveComponent("sanityaura")
        end,
    },
}

local function removecarrat(inst, carrat)
    inst:RemoveTag("HasCarrat")
    carrat._color = inst._carratcolor
    carrat._setcolorfn(carrat, carrat._color)
end

local function canalterbuild(inst, group)
    if inst.components.beard.canshavetest(inst) then
        return true
    end
end

local function setcarratart(inst)
    --[[
    if not inst._carratcolor then
        inst.AnimState:ClearOverrideSymbol("carrat_tail")
        inst.AnimState:ClearOverrideSymbol("carrat_ear")
        inst.AnimState:ClearOverrideSymbol("carrot_parts")
        ]]
    if inst._carratcolor then
        inst.AnimState:OverrideSymbol("carrat_tail", "yotc_carrat_colour_swaps", inst._carratcolor.."_carrat_tail")
        inst.AnimState:OverrideSymbol("carrat_ear", "yotc_carrat_colour_swaps", inst._carratcolor.."_carrat_ear")
        inst.AnimState:OverrideSymbol("carrot_parts", "yotc_carrat_colour_swaps", inst._carratcolor.."_carrot_parts")
    end
end

local function addcarrat(inst, carrat)
    inst:AddTag("HasCarrat")
    inst._carratcolor = carrat._color
    setcarratart(inst)
end

local function createcarrat(inst)
    local carrat = SpawnPrefab("carrat")
    if inst._carratcolor then
        carrat._setcolorfn(carrat, inst._carratcolor)
    end
    carrat.setbeefalocarratrat(carrat)
    return carrat
end

local function testforcarratexit(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 12)
    local carrat = createcarrat(inst)

    local foundfood = nil
    for i,ent in ipairs(ents) do
        if carrat.components.eater:CanEat(ent) and ent.components.bait and not ent:HasTag("planted") and
            not (ent.components.inventoryitem and ent.components.inventoryitem:IsHeld()) and
            ent:IsOnPassablePoint() and
            ent:GetCurrentPlatform() == inst:GetCurrentPlatform() then
                foundfood = ent
                break
        end
    end
    if foundfood then
        removecarrat(inst,carrat)
        carrat.Transform:SetPosition(x,y,z)
    else
        carrat:Remove()
    end
end

fns.ClearBellOwner = function(inst)
    if inst._marked_for_despawn then
        -- We're marked for despawning, so don't disconnect anything,
        -- in case we get saved for real i.e. when despawning in caves.
        return
    end

    fns.RemoveName(inst)

    local bell_leader = inst.components.follower:GetLeader()
    inst:RemoveEventCallback("onremove", inst._BellRemoveCallback, bell_leader)

    inst.components.follower:SetLeader(nil)
    inst.components.rideable:SetShouldSave(true)

    inst.persists = true

    inst:UpdateDomestication()
end

fns.GetBeefBellOwner = function(inst)
    local leader = inst.components.follower:GetLeader()
    return (leader ~= nil
        and leader.components.inventoryitem ~= nil
        and leader.components.inventoryitem:GetGrandOwner())
        or nil
end

fns.SetBeefBellOwner = function(inst, bell, bell_user)
    if inst.components.follower:GetLeader() == nil
            and bell ~= nil and bell.components.leader ~= nil then
        bell.components.leader:AddFollower(inst)
        inst.components.rideable:SetShouldSave(false)

        inst:ListenForEvent("onremove", inst._BellRemoveCallback, bell)

        inst.persists = false
        inst:UpdateDomestication()
        inst.components.knownlocations:ForgetLocation("herd")

        if bell_user ~= nil then
            inst.components.writeable:BeginWriting(bell_user)
        end

        return true
    else
        return false, "ALREADY_USED"
    end
end

local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild("beefalo_build")
    end
    -- this presumes that all the face builds have the same symbols
    animstate:ClearOverrideBuild("beefalo_personality_docile")
end

local function getbasebuild(inst)
    return (inst:HasTag("baby") and "beefalo_baby_build")
            or (not inst:HasTag("has_beard") and "beefalo_shaved_build")
            or (inst:HasTag("domesticated") and "beefalo_domesticated")
            or "beefalo_build"
end

function fns.GetMoodComponent(inst)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    if herd then
        return herd.components.mood
    end
end

function fns.GetIsInMood(inst)
    local mood = fns.GetMoodComponent(inst)
    return mood and mood:IsInMood() or false
end

-- This takes an anim state so that it can apply to itself, or to its rider
local function ApplyBuildOverrides(inst, animstate)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    local basebuild = getbasebuild(inst)
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end

    if fns.GetIsInMood(inst) then
        animstate:Show("HEAT")
    else
        animstate:Hide("HEAT")
    end

    if tendencies[inst.tendency].build ~= nil then
        animstate:AddOverrideBuild(tendencies[inst.tendency].build)
    elseif animstate == inst.AnimState then
        -- this presumes that all the face builds have the same symbols
        animstate:ClearOverrideBuild("beefalo_personality_docile")
    end

    if inst.components.skinner_beefalo then
        local clothing_names = inst.components.skinner_beefalo:GetClothing()
        SetBeefaloSkinsOnAnim( animstate, clothing_names, inst.GUID )
    end
end

local function OnEnterMood(inst)

    if inst.yotb_tempcontestbeefalo then
        return
    end

    inst:AddTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

local function OnLeaveMood(inst)
    inst:RemoveTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable ~= nil and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "beefalo", "wall", "INLIMBO" }

local function Retarget(inst)
    return (fns.GetIsInMood(inst) and not inst.yotb_tempcontestbeefalo)
        and FindEntity(
                inst,
                TUNING.BEEFALO_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                        and (guy.components.rider == nil
                            or guy.components.rider:GetMount() == nil
                            or not guy.components.rider:GetMount():HasTag("beefalo"))
                end,
                RETARGET_MUST_TAGS, --See entityreplica.lua (re: "_combat" tag)
                RETARGET_CANT_TAGS
            )
        or nil
end

local function KeepTarget(inst, target)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd() or nil
    return herd == nil or herd.components.mood == nil or not herd.components.mood:IsInMood() or inst:IsNear(herd, TUNING.BEEFALO_CHASE_DIST)
end

local function OnNewTarget(inst, data)
    if data ~= nil and data.target ~= nil and inst.components.follower ~= nil and data.target == inst.components.follower.leader then
        inst.components.follower:SetLeader(nil)
    end
end

local function CanShareTarget(dude)
    return dude:HasTag("beefalo")
        and not dude:IsInLimbo()
        and not (dude.components.health:IsDead() or dude:HasTag("player"))
end

local function OnAttacked(inst, data)
    if inst._ridersleeptask ~= nil then
        inst._ridersleeptask:Cancel()
        inst._ridersleeptask = nil
    end
    inst._ridersleep = nil
    if inst.components.rideable:IsBeingRidden() then
        if not inst.components.domesticatable:IsDomesticated() or not inst.tendency == TENDENCY.ORNERY then
            inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION)
            inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE)
        end
        inst.components.domesticatable:DeltaTendency(TENDENCY.ORNERY, TUNING.BEEFALO_ORNERY_ATTACKED)
    else
        if data.attacker ~= nil and data.attacker:HasTag("player") then
            inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION)
            inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE)
        end
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, CanShareTarget, 5)
    end
    if inst.components.hitchable and not inst.components.hitchable.canbehitched then
        inst.components.hitchable:Unhitch()
    end
end

local function GetStatus(inst, viewer)
    local leader = inst.components.follower:GetLeader()
    if leader ~= nil then
        return (leader.components.inventoryitem ~= nil
                and leader.components.inventoryitem:GetGrandOwner() == viewer
                and "MYPARTNER")
                or "FOLLOWER"
    else
        return (inst.components.beard ~= nil and inst.components.beard.bits == 0 and "NAKED")
            or (inst.components.domesticatable ~= nil and
                inst.components.domesticatable:IsDomesticated() and
                (inst.tendency == TENDENCY.DEFAULT and "DOMESTICATED" or inst.tendency))
            or nil
    end
end

fns.testforskins = function(inst)
    if inst.components.skinner_beefalo and inst.components.skinner_beefalo.clothing then
        if inst.components.skinner_beefalo.clothing.beef_body ~= "" or
            inst.components.skinner_beefalo.clothing.beef_head ~= "" or
            inst.components.skinner_beefalo.clothing.beef_tail ~= "" or
            inst.components.skinner_beefalo.clothing.beef_horn ~= "" or
            inst.components.skinner_beefalo.clothing.beef_feet ~= "" then
            return true
        end
    end
    return false
end

fns.UnSkin = function(inst)
    if inst.components.skinner_beefalo then
        if inst.components.sleeper:IsAsleep() then

            if fns.testforskins(inst) then
                local fx = SpawnPrefab("explode_reskin")
                fx.Transform:SetScale(2,2,2)
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end

            inst.components.skinner_beefalo:ClearAllClothing()
        else
            if fns.testforskins(inst) then
                inst.sg:GoToState("skin_change", function()
                    inst.components.skinner_beefalo:ClearAllClothing()
                end)
            end
        end
    end
end

local function OnResetBeard(inst)

    inst:RemoveTag("has_beard")
    inst.sg:GoToState("shaved")
    inst.components.brushable:SetBrushable(false)
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE)

    inst:UnSkin()
end

local function CanShaveTest(inst, shaver)
    if inst.components.sleeper:IsAsleep() then
        local partner = fns.GetBeefBellOwner(inst)
        if partner == nil or partner == shaver then
            return true
        else
            return false, "SOMEONEELSESBEEFALO"
        end
    else
        return false, "AWAKEBEEFALO"
    end
end

local function OnShaved(inst)

    inst:ApplyBuildOverrides(inst.AnimState)
end

local function OnHairGrowth(inst)
    if inst.components.beard.bits == 0 then
        inst.hairGrowthPending = true
        if inst.components.rideable ~= nil then
            inst.components.rideable:Buck()
        end
    end
end

fns.RemoveName = function(inst)
    inst.components.writeable:SetText(nil)

    inst.components.named:SetName(nil)
end

local function OnBrushed(inst, doer, numprizes)
    if numprizes > 0 and inst.components.domesticatable ~= nil then
        inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION)
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE)
    end
end

local function ShouldAcceptItem(inst, item)
    return inst.components.eater:CanEat(item)
        and not inst.components.combat:HasTarget()
end

local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.eater:CanEat(item) then
        inst.components.eater:Eat(item, giver)
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnDomesticated(inst, data)
    inst.components.rideable:Buck()
    inst.domesticationPending = true
end

local function DoDomestication(inst)
    inst.components.herdmember:Enable(false)

    inst:SetTendency("domestication")

    inst.MiniMapEntity:SetEnabled(true)
end

local function OnFeral(inst, data)
    inst.components.rideable:Buck()
    if inst.components.domesticatable:IsDomesticated() then
        inst.domesticationPending = true
    end
end

local function DoFeral(inst)
    inst.components.herdmember:Enable(true)

    inst:SetTendency("feral")

    inst.MiniMapEntity:SetEnabled(false)
end

local function UpdateDomestication(inst)
    if inst.components.domesticatable:IsDomesticated() then
        DoDomestication(inst)
    else
        DoFeral(inst)
    end
end

local function SetTendency(inst, changedomestication)
    -- tendency is locked in after we become domesticated
    local tendencychanged = false
    local oldtendency = inst.tendency
    if not inst.components.domesticatable:IsDomesticated() then
        local tendencysum = 0
        local maxtendency = nil
        local maxtendencyval = 0
        for k, v in pairs(inst.components.domesticatable.tendencies) do
            tendencysum = tendencysum + v
            if v > maxtendencyval then
                maxtendencyval = v
                maxtendency = k
            end
        end
        inst.tendency = (tendencysum < .1 or maxtendencyval * 2 < tendencysum) and TENDENCY.DEFAULT or maxtendency
        tendencychanged = inst.tendency ~= oldtendency
    end

    if changedomestication == "domestication" then
        if tendencies[inst.tendency].customactivatefn ~= nil then
            tendencies[inst.tendency].customactivatefn(inst)
        end
    elseif changedomestication == "feral"
        and tendencies[oldtendency].customdeactivatefn ~= nil then
        tendencies[oldtendency].customdeactivatefn(inst)
    end

    if tendencychanged or changedomestication ~= nil then
        if inst.components.domesticatable:IsDomesticated() then
            inst.components.domesticatable:SetMinObedience(TUNING.BEEFALO_MIN_DOMESTICATED_OBEDIENCE[inst.tendency])

            inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE[inst.tendency])
            inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED[inst.tendency]
        else
            inst.components.domesticatable:SetMinObedience(0)

            inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT)
            inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED.DEFAULT
        end

        inst:ApplyBuildOverrides(inst.AnimState)
        if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
            inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
        end
    end
end

local function GetBaseSkin(inst)
    return inst.tendency and tendencies[inst.tendency].build or getbasebuild(inst)
end

local function ShouldBeg(inst)
    return inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication() > 0.0
        and inst.components.hunger ~= nil
        and inst.components.hunger:GetPercent() < TUNING.BEEFALO_BEG_HUNGER_PERCENT
        and (not fns.GetIsInMood(inst))
end

local function CalculateBuckDelay(inst)
    local domestication =
        inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication()
        or 0

    local moodmult = fns.GetIsInMood(inst) and TUNING.BEEFALO_BUCK_TIME_MOOD_MULT or 1

    local beardmult =
        (inst.components.beard ~= nil and inst.components.beard.bits == 0)
        and TUNING.BEEFALO_BUCK_TIME_NUDE_MULT
        or 1

    local domesticmult =
        inst.components.domesticatable:IsDomesticated()
        and 1
        or TUNING.BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT

    local basedelay = Remap(domestication, 0, 1, TUNING.BEEFALO_MIN_BUCK_TIME, TUNING.BEEFALO_MAX_BUCK_TIME)

    return basedelay * moodmult * beardmult * domesticmult
end

local function OnBuckTime(inst)
    --V2C: reschedule because :Buck() is not guaranteed!
    inst._bucktask = inst:DoTaskInTime(1 + math.random(), OnBuckTime)
    inst.components.rideable:Buck()
end

local function OnObedienceDelta(inst, data)
    inst.components.rideable:SetSaddleable(data.new >= TUNING.BEEFALO_SADDLEABLE_OBEDIENCE)

    if data.new > data.old and inst._bucktask ~= nil then
        --Restart buck timer if we gained obedience!
        inst._bucktask:Cancel()
        inst._bucktask = inst:DoTaskInTime(CalculateBuckDelay(inst), OnBuckTime)
    end
end

local function OnDeath(inst, data)
    inst.persists = false
    inst:AddTag("NOCLICK")
    if inst.components.rideable:IsBeingRidden() then
        --SG won't handle "death" event while we're being ridden
        --SG is forced into death state AFTER dismounting (OnRiderChanged)
        inst.components.rideable:Buck(true)
    end

    if inst:HasTag("HasCarrat") and IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        local x,y,z = inst.Transform:GetWorldPosition()
        local carrat = createcarrat(inst)

        if inst._carratcolor then
            carrat._setcolorfn(carrat, inst._carratcolor)
        end
        carrat.Transform:SetPosition(x,y,z)
    end
end

local function DomesticationTriggerFn(inst)
    return inst.components.hunger:GetPercent() > 0
        or inst.components.rideable:IsBeingRidden() == true
end

local function OnStarving(inst, dt)
    -- apply no health damage; the stomach is just used by domesticatable
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_STARVE_OBEDIENCE * dt)
    --inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_STARVE_DOMESTICATION * dt)
end

local function OnHungerDelta(inst, data)
    if data.oldpercent > 0 and data.delta < 0 then
        -- basically, give domestication while we are digesting
        --inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_WELLFED_DOMESTICATION * -data.delta)
        if data.oldpercent > 0.5 then
            inst.components.domesticatable:DeltaTendency(TENDENCY.PUDGY, TUNING.BEEFALO_PUDGY_WELLFED * -data.delta)
        end
    end
end

local function OnEat(inst, food)
    local full = inst.components.hunger:GetPercent() >= 1
    if not full then
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_FEED_OBEDIENCE)

        inst.components.domesticatable:TryBecomeDomesticated()
    else
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE)
        inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION)
        inst.components.domesticatable:DeltaTendency(TENDENCY.PUDGY, TUNING.BEEFALO_PUDGY_OVERFEED)
    end
    inst:PushEvent("eat", { full = full, food = food })
    inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
end

local function OnDomesticationDelta(inst, data)
    inst:SetTendency()
end

local function OnHealthDelta(inst, data)
    if data.oldpercent >= 0.2 and
        data.newpercent < 0.2 and
        inst.components.rideable.rider ~= nil then
        inst.components.rideable.rider:PushEvent("mountwounded")
    end
end

local function OnBeingRidden(inst, dt)
    inst.components.domesticatable:DeltaTendency(TENDENCY.RIDER, TUNING.BEEFALO_RIDER_RIDDEN * dt)
end

local function OnRiderDoAttack(inst, data)
    inst.components.domesticatable:DeltaTendency(TENDENCY.ORNERY, TUNING.BEEFALO_ORNERY_DOATTACK)
end

local function DoRiderSleep(inst, sleepiness, sleeptime)
    inst._ridersleeptask = nil
    inst.components.sleeper:AddSleepiness(sleepiness, sleeptime)
end

local function OnRiderChanged(inst, data)
    if inst._bucktask ~= nil then
        inst._bucktask:Cancel()
        inst._bucktask = nil
    end

    if inst._ridersleeptask ~= nil then
        inst._ridersleeptask:Cancel()
        inst._ridersleeptask = nil
    end

    if data.newrider ~= nil then
        if inst.components.sleeper ~= nil then
            inst.components.sleeper:WakeUp()
        end
        inst._bucktask = inst:DoTaskInTime(CalculateBuckDelay(inst), OnBuckTime)
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
    elseif inst.components.health:IsDead() then
        if inst.sg.currentstate.name ~= "death" then
            inst.sg:GoToState("death")
        end
    elseif inst.components.sleeper ~= nil then
        inst.components.sleeper:StartTesting()
        if inst._ridersleep ~= nil then
            local sleeptime = inst._ridersleep.sleeptime + inst._ridersleep.time - GetTime()
            if sleeptime > 2 then
                inst._ridersleeptask = inst:DoTaskInTime(0, DoRiderSleep, inst._ridersleep.sleepiness, sleeptime)
            end
            inst._ridersleep = nil
        end
    end
end

local function PotentialRiderTest(inst, potential_rider)
    local leader = inst.components.follower:GetLeader()
    if leader == nil or leader.components.inventoryitem == nil then
        return true
    end

    local leader_owner = leader.components.inventoryitem:GetGrandOwner()
    return (leader_owner == nil or leader_owner == potential_rider)
end

local function OnSaddleChanged(inst, data)
    if data.saddle ~= nil then
        inst:AddTag("companion")
    else
        inst:RemoveTag("companion")
    end
end

local function _OnRefuseRider(inst)
    if inst.components.sleeper:IsAsleep() and not inst.components.health:IsDead() then
        -- this needs to happen after the stategraph
        inst.components.sleeper:WakeUp()
    end
end

local function OnRefuseRider(inst, data)
    inst:DoTaskInTime(0, _OnRefuseRider)
end

local function OnRiderSleep(inst, data)
    inst._ridersleep = inst.components.rideable:IsBeingRidden() and {
        time = GetTime(),
        sleepiness = data.sleepiness,
        sleeptime = data.sleeptime,
    } or nil
end

local function dobeefalounhitch(inst)
    if inst.components.hitchable and not inst.components.hitchable.canbehitched then
        inst.components.hitchable:Unhitch()
    end
end

local function OnHitchTo(inst, data)
    inst.hitchingspot = data.target
    inst:ListenForEvent("death", dobeefalounhitch)
    inst:ListenForEvent("gotosleep", dobeefalounhitch)
    inst:ListenForEvent("onignite", dobeefalounhitch)
    inst:ListenForEvent("onremove", dobeefalounhitch)
end

local function OnUnhitch(inst, data)
    inst:RemoveEventCallback("death", dobeefalounhitch)
    inst:RemoveEventCallback("gotosleep", dobeefalounhitch)
    inst:RemoveEventCallback("onignite", dobeefalounhitch)
    inst:RemoveEventCallback("onremove", dobeefalounhitch)
end

fns.OnNamedByWriteable = function(inst, new_name, writer)
    if inst.components.named ~= nil then
        inst.components.named:SetName(new_name, writer ~= nil and writer.userid or nil)
    end
end

fns.OnWritingEnded = function(inst)
    if not inst.components.writeable:IsWritten() then
        local leader = inst.components.follower:GetLeader()
        if leader ~= nil and leader.components.inventoryitem ~= nil then
            inst.components.follower:SetLeader(nil)
        end
    end
end

local WAKE_TO_FOLLOW_DISTANCE = 15
local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst)
        or (inst.components.follower.leader ~= nil
            and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local TWEEN_TARGET = {0, 0, 0, 1}
local TWEEN_TIME = 13 * FRAMES
fns.OnDespawnRequest = function(inst)
    inst._marked_for_despawn = true
    inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
end

local SLEEP_NEAR_LEADER_DISTANCE = 10
local function MountSleepTest(inst)
    return not inst.components.rideable:IsBeingRidden()
        and DefaultSleepTest(inst)
        and not inst:HasTag("hitched")
        and (inst.components.follower.leader == nil
            or inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
end

local function ToggleDomesticationDecay(inst)
    inst.components.domesticatable:PauseDomesticationDecay(inst.components.saltlicker.salted or inst.components.sleeper:IsAsleep())
end

local function onwenthome(inst,data)
    if data.doer and data.doer.prefab == "carrat" then
        addcarrat(inst,data.doer)
        inst:PushEvent("carratboarded")
    end
end

local function OnInit(inst)
    inst:UpdateDomestication()
end

local function CustomOnHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

fns.OnSave = function(inst, data)
    data.tendency = inst.tendency
    data.hascarrat = inst:HasTag("HasCarrat")
    data.carratcolor = inst._carratcolor
end

fns.OnLoad = function(inst, data)
    if data ~= nil and data.tendency ~= nil then
        inst.tendency = data.tendency
    end

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
		if data ~= nil and data.hascarrat then
			inst:AddTag("HasCarrat")
		end
		if data ~= nil and data.carratcolor then
			inst._carratcolor = data.carratcolor
		end
	end
end

fns.OnLoadPostPass = function(inst,data)

    if inst.components.beard and inst.components.beard.bits == 0 then
        inst:RemoveTag("has_beard")
        inst:ApplyBuildOverrides(inst.AnimState)
    end
end

local function CanSpawnPoop(inst)

    if inst.components.hitchable and not inst.components.hitchable.canbehitched then return false end

	return inst.components.rideable == nil or not inst.components.rideable:IsBeingRidden()
end

local function GetDebugString(inst)
    return string.format("tendency %s nextbuck %.2f", inst.tendency, GetTaskRemaining(inst._bucktask))
end

local function onclothingchanged(inst,data)
    if data and data.type then
        inst.skins[data.type]:set(data.name)
    end
end

local function beefalo()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("beefalo")
    inst.AnimState:SetBuild("beefalo_build")
    inst.AnimState:AddOverrideBuild("poop_cloud")
    inst.AnimState:AddOverrideBuild("beefalo_carrat_idles")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("HEAT")

    inst.MiniMapEntity:SetIcon("beefalo_domesticated.png")
    inst.MiniMapEntity:SetEnabled(false)

    inst:AddTag("beefalo")
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    --herdmember (from herdmember component) added to pristine state for optimization
    inst:AddTag("herdmember")

    --saddleable (from rideable component) added to pristine state for optimization
    inst:AddTag("saddleable")

    --domesticatable (from domesticatable component) added to pristine state for optimization
    inst:AddTag("domesticatable")

    --saltlicker (from saltlicker component) added to pristine state for optimization
    inst:AddTag("saltlicker")

    -- used for the function that gets the skin of the beefalo. used by client.
    inst:AddTag("has_beard")

    inst.sounds = sounds

    inst.skins ={}
    inst.skins.base_skin = net_string(inst.GUID, "beefalo._base_skin")
    inst.skins.beef_body = net_string(inst.GUID, "beefalo._beef_body")
    inst.skins.beef_head = net_string(inst.GUID, "beefalo._beef_head")
    inst.skins.beef_horn = net_string(inst.GUID, "beefalo._beef_horn")
    inst.skins.beef_feet = net_string(inst.GUID, "beefalo._beef_feet")
    inst.skins.beef_tail = net_string(inst.GUID, "beefalo._beef_tail")
    inst.GetBaseSkin = GetBaseSkin




    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("bloomer")

    inst:AddComponent("beard")
    -- assume the beefalo has already grown its hair
    inst.components.beard.bits = TUNING.BEEFALO_BEARD_BITS
    inst.components.beard.daysgrowth = TUNING.BEEFALO_HAIR_GROWTH_DAYS + 1
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.canshavetest = CanShaveTest
    inst.components.beard.prize = "beefalowool"
    inst.components.beard:AddCallback(0, OnShaved)
    inst.components.beard:AddCallback(TUNING.BEEFALO_HAIR_GROWTH_DAYS, OnHairGrowth)

    inst:AddComponent("brushable")
    inst.components.brushable.regrowthdays = 1
    inst.components.brushable.max = 1
    inst.components.brushable.prize = "beefalowool"
    inst.components.brushable:SetOnBrushed(OnBrushed)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE }, { FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE })
    inst.components.eater:SetAbsorptionModifiers(4,1,1)
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEFALO_HEALTH)
    inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN, TUNING.BEEFALO_HEALTH_REGEN_PERIOD)
    inst:ListenForEvent("death", OnDeath) -- need to handle this due to being mountable
    inst:ListenForEvent("healthdelta", OnHealthDelta) -- to inform rider

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beefalo')

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("knownlocations")
    inst:ListenForEvent("entermood", OnEnterMood)
    inst:ListenForEvent("leavemood", OnLeaveMood)

    inst:AddComponent("leader")
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = false

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
	inst.components.periodicspawner:SetSpawnTestFn(CanSpawnPoop)
    inst.components.periodicspawner:Start()


    inst:AddComponent("rideable")
    inst.components.rideable:SetRequiredObedience(TUNING.BEEFALO_MIN_BUCK_OBEDIENCE)
    inst.components.rideable:SetCustomRiderTest(PotentialRiderTest)
    inst:ListenForEvent("saddlechanged", OnSaddleChanged)
    inst:ListenForEvent("refusedrider", OnRefuseRider)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.BEEFALO_HUNGER)
    inst.components.hunger:SetRate(TUNING.BEEFALO_HUNGER_RATE)
    inst.components.hunger:SetPercent(0)
    inst.components.hunger:SetOverrideStarveFn(OnStarving)

    inst:AddComponent("domesticatable")
    inst.components.domesticatable:SetDomesticationTrigger(DomesticationTriggerFn)

    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.BEEFALO_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED.DEFAULT

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = MountSleepTest
    inst.components.sleeper.waketestfn = ShouldWakeUp

    inst:AddComponent("timer")
    inst:AddComponent("saltlicker")
    inst.components.saltlicker:SetUp(TUNING.SALTLICK_BEEFALO_USES)
    inst:ListenForEvent("saltchange", ToggleDomesticationDecay)
    inst:ListenForEvent("onwenthome", onwenthome)
    inst.setcarratart = setcarratart

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides

    inst.tendency = TENDENCY.DEFAULT
    inst._bucktask = nil

    --Herdmember component is ONLY used when feral
    inst:AddComponent("herdmember")
    inst.components.herdmember:Enable(true)

    inst.UpdateDomestication = UpdateDomestication
    inst:ListenForEvent("domesticated", OnDomesticated)
    inst.DoFeral = DoFeral
    inst:ListenForEvent("goneferal", OnFeral)
    inst:ListenForEvent("obediencedelta", OnObedienceDelta)
    inst:ListenForEvent("domesticationdelta", OnDomesticationDelta)
    inst:ListenForEvent("beingridden", OnBeingRidden)
    inst:ListenForEvent("riderchanged", OnRiderChanged)
    inst:ListenForEvent("riderdoattackother", OnRiderDoAttack)
    inst:ListenForEvent("hungerdelta", OnHungerDelta)
    inst:ListenForEvent("ridersleep", OnRiderSleep)
    inst:ListenForEvent("hitchto", OnHitchTo)
    inst:ListenForEvent("unhitch", OnUnhitch)
    inst:ListenForEvent("despawn", fns.OnDespawnRequest)
    inst:ListenForEvent("stopfollowing", fns.ClearBellOwner)

    inst:AddComponent("uniqueid")
    inst:AddComponent("beefalometrics")
    inst:AddComponent("drownable")

    inst:AddComponent("skinner_beefalo")
    inst:ListenForEvent("onclothingchanged", onclothingchanged)

    inst:AddComponent("named")

    inst:AddComponent("writeable")
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    inst.components.writeable:SetWriteableDistance(TUNING.BEEFALO_NAMING_DIST)
    inst.components.writeable:SetOnWrittenFn(fns.OnNamedByWriteable)
    inst.components.writeable:SetOnWritingEndedFn(fns.OnWritingEnded)

    inst:AddComponent("hitchable")

    inst:AddComponent("colourtweener")

    inst:AddComponent("markable_proxy")

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    inst.SetTendency = SetTendency
    inst:SetTendency()

    --inst._marked_for_despawn = nil

    inst.ShouldBeg = ShouldBeg
    inst.testforcarratexit = testforcarratexit
    inst.SetBeefBellOwner = fns.SetBeefBellOwner
    inst.GetBeefBellOwner = fns.GetBeefBellOwner
    inst.ClearBeefBellOwner = fns.ClearBellOwner
    inst.GetMoodComponent = fns.GetMoodComponent
    inst.GetIsInMood = fns.GetIsInMood
    inst.UnSkin = fns.UnSkin

    inst._BellRemoveCallback = function(bell)
        fns.ClearBellOwner(inst)
    end

    inst:SetBrain(brain)
    inst:SetStateGraph("SGBeefalo")

    inst:DoTaskInTime(0, OnInit)

    inst.debugstringfn = GetDebugString
    inst.OnSave = fns.OnSave
    inst.OnLoad = fns.OnLoad
    inst.OnLoadPostPass = fns.OnLoadPostPass

    return inst
end

local function beefalo_carry()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("beefalo")
    inst.AnimState:SetBuild("beefalo_build")
    inst.AnimState:PlayAnimation("idle_carry", true)

	inst.Transform:SetNoFaced()

    --inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end


return Prefab("beefalo", beefalo, assets, prefabs),
       Prefab("beefalo_carry", beefalo_carry, assets, prefabs)