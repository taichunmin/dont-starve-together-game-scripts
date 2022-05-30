local assets =
{
    Asset("ANIM", "anim/rock_light.zip"),
}

local prefabs =
{
    "character_fire",
    "explode_small",
    "lavalight",
}

local MAXWORK = 6
local MEDIUM  = 4
local LOW     = 2

local function SetWorkLevel(inst, workleft)
    --print(string.format("SetWORKLEVEL: left=%d, state=%d",workleft,inst.state))
    if inst.exploding then
        return
    end
    if workleft == MAXWORK and inst.state == MEDIUM then
        inst.state = MAXWORK
        --print("MED -> MAX")
        inst.AnimState:PlayAnimation("med_grow")
        inst.components.fueled:MakeEmpty()
    elseif workleft <= MEDIUM and inst.state == MAXWORK then
        inst.state = MEDIUM
        --print("MAX -> MED")
        inst.AnimState:PlayAnimation("med")
        inst.components.fueled:ChangeSection(1)
        inst.components.fueled:StartConsuming()
    elseif workleft <= MEDIUM and inst.state == LOW then
        inst.state = MEDIUM
        --print("LOW -> MED")
        inst.AnimState:PlayAnimation("low_grow")
    elseif workleft <= LOW and inst.state == MEDIUM then
        --print("MED -> LOW")
        inst.state = LOW
        inst.AnimState:PlayAnimation("low")
        inst.components.fueled:ChangeSection(1)
    end
    if workleft < 0 then
        inst.components.workable.workleft = 0
    end
end

local function onhammered(inst, worker)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    SetWorkLevel(inst, 0)
end

local function onhit(inst, worker, workleft)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    SetWorkLevel( inst, workleft )
end

local function onextinguish(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:MakeEmpty()
    end
end

local function CalcSanityAura(inst, observer)
    local lightRadius = inst.components.burnable ~= nil and inst.components.burnable:GetLargestLightRadius() or 0
    return lightRadius > 0
        and inst:GetDistanceSqToInst(observer) < .5 * lightRadius
        and (--[[nightmareclock ~= nil and
            nightmareclock:IsCalm() and
            -TUNING.SANITY_SMALL or]]
            TUNING.SANITY_SMALL)
        or 0
end

local function DoShake(inst)
 --           :Shake(shakeType, duration, speed, scale)
    TheCamera:Shake("FULL", 3.0, 0.05, .2)
end

local function SealUp(rock)
    --print("SealUp:",rock)
    rock.exploding = false
    rock.components.workable:SetWorkLeft(MAXWORK)
end

function ExplodeRock(rock)
    --print("Explode:",rock)
    if rock.components.workable.workleft < MAXWORK then
        rock.blastTask = rock:DoTaskInTime(GetRandomWithVariance(120,60), ExplodeRock)
        return
    end
    rock.blastTask = nil
    local x,y,z = rock.Transform:GetWorldPosition()

    rock.exploding = true
    y = y + 2
    rock.lavaLight = SpawnPrefab("lavalight").Transform:SetPosition(x,y,z)
    SpawnPrefab("explode_small").Transform:SetPosition(x,y,z)
    rock.AnimState:PlayAnimation("low")
    DoShake(rock)
    rock:DoTaskInTime(5,SealUp)
end

--local function ontakefuel(inst)
--    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
--end

local function onupdatefueled(inst)
    if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
        --print("fuel Update:", inst.components.fueled:GetCurrentSection()," %=", inst.components.fueled:GetSectionPercent())
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local function onfuelchange(newsection, oldsection, inst)
    --print(string.format("SectionCallback: old=%d, new=%d, perc=%f", oldsection, newsection, inst.components.fueled:GetSectionPercent()))
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
        inst:DoTaskInTime(2, function(inst)
                                 inst.components.workable:SetWorkLeft(MAXWORK)
                                 SetWorkLevel( inst, MAXWORK )
                                 --inst.AnimState:PlayAnimation("med_grow")
                                 inst.components.burnable:SetFXLevel(0,0)
                             end)
    else
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())
        --if not inst.components.burnable:IsBurning() then
        --    inst.components.burnable:Ignite()
        --end
        if newsection == 1 then
            SetWorkLevel(inst, MEDIUM)
            if oldsection == 2 then
                inst.components.workable:SetWorkLeft(MEDIUM)
            end
        elseif newsection == 2 then
            inst.components.workable:SetWorkLeft(LOW)
            SetWorkLevel(inst, LOW)
        end
    end
    inst.prev = newsection
end

local SECTION_STATUS =
{
    [0] = "OUT",
    [1] = "LOW",
    [2] = "NORMAL",
}
local function GetStatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    --inst.MiniMapEntity:SetIcon("rock_light.png")
    --inst.MiniMapEntity:SetPriority(1)

    inst.AnimState:SetBuild("rock_light")
    inst.AnimState:SetBank("rock_light")
    inst.AnimState:PlayAnimation("full")

    inst:AddTag("rocklight")
    inst:AddTag("structure")
    inst:AddTag("stone")

    MakeObstaclePhysics(inst, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(0,0)
    --  campfirefire character_fire  maxwelllight_flame nightlight_flame
    inst.components.burnable:AddBurnFX("character_fire", Vector3(0,1,0) )
    inst:ListenForEvent("onextinguish", onextinguish)

    -------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(MAXWORK)
    inst.components.workable:SetMaxWork(MAXWORK)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = 30  -- TUNING.ROCKLIGHT_FUEL_MAX
    inst.components.fueled.accepting = false
    inst.components.fueled:SetSections(2)
    inst.components.fueled:InitializeFuelLevel(0)
    -- inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT
    -- inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)

    -----------------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    -----------------------------

    inst.blastTask = inst:DoTaskInTime(GetRandomWithVariance(120, 60), ExplodeRock)
    inst.state = MAXWORK

    -----------------------------

    return inst
end

return Prefab("rock_light", fn, assets, prefabs)
