local assets =
{
    Asset("ANIM", "anim/goosemoose_nest.zip"),
}

local prefabs =
{
    "moose_nest_fx_idle",
    "moose_nest_fx_hit",
    "mossling",
}

local function InitEgg(inst)
    inst.sg:GoToState("land")
    inst.components.timer:StartTimer("HatchTimer", TUNING.MOOSE_EGG_HATCH_TIMER)
end

local function OnSummonMoose(inst, guardian)
    local x, y, z = guardian.Transform:GetWorldPosition()
    guardian.Transform:SetPosition(x + math.random(), 20, z + math.random())
    guardian.sg:GoToState("glide")
end

local function OnGuardianDeath(inst, guardian, cause)
    local herd = inst.components.herd.members
    for k,v in pairs(herd) do
        k.mother_dead = true
        k.components.locomotor:SetShouldRun(true)
        if guardian and guardian.components.combat and guardian.components.combat.lastattacker and guardian.components.combat.lastattacker:IsValid() then
            k.components.combat:SetTarget(guardian.components.combat.lastattacker)
        end
    end
end

local function OnDismissMoose(inst, guardian)
    guardian.shouldGoAway = true
end

local function OnSave(inst, data)
	data.has_egg = inst.sg:HasStateTag("egg")
end

local function OnLoadPostPass(inst, ents, data)
	-- data.EggHatched is for old save files
	if data.has_egg and not data.EggHatched then
		if inst.components.timer:TimerExists("HatchTimer") then
	        inst.sg:GoToState("idle_full")
		else
	        inst.sg:GoToState("crack")
		end
	else
		inst.sg:GoToState("idle_empty")
    end
end

local function OnTimerDone(inst, data)
    if data.name == "HatchTimer" then
        inst.sg:GoToState("crack")
    end
end

local function MakeWorkable(inst, bool)
    if bool then
        local function onhammered(inst, worker)
            inst.sg:GoToState("crack")
            inst.components.timer:StopTimer("HatchTimer")
            inst:MakeWorkable(false)
        end
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst.components.workable:SetOnWorkCallback(function(inst, worker)
            if worker.components.combat then
                -- Don't electrocute the worker if they're insulated.
                if worker.components.inventory == nil or not worker.components.inventory:IsInsulated() then
                    worker.components.combat:GetAttacked(inst, TUNING.MOOSE_EGG_DAMAGE, nil, "electric")
                end
            end
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("hit")
            end
        end)
    else
        inst:RemoveComponent("workable")
    end
end

local function rename(inst)
    inst.components.named:PickNewName()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(1.33, 1.33, 1.33)

    inst.AnimState:SetBank("goosemoose_nest")
    inst.AnimState:SetBuild("goosemoose_nest")
    inst.AnimState:PlayAnimation("nest")

    inst:AddTag("lightningrod")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst.scrapbook_workable = ACTIONS.HAMMER

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle"

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("inspectable")
    inst:AddComponent("timer")
    inst:AddComponent("entitytracker")

    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("mossling")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd.updatepos = false
    inst.components.herd.onempty = ErodeAway

    inst:AddComponent("guardian")
    inst.components.guardian.prefab = "moose"
    inst.components.guardian.onsummonfn = OnSummonMoose
    inst.components.guardian.ondismissfn = OnDismissMoose
    inst.components.guardian.onguardiandeathfn = OnGuardianDeath

    inst:AddComponent("named")
    inst.components.named.possiblenames = { STRINGS.NAMES["MOOSEEGG1"], STRINGS.NAMES["MOOSEEGG2"] }
    inst.components.named:PickNewName()
    inst:DoPeriodicTask(5, rename)

    inst.MakeWorkable = MakeWorkable

    inst:SetStateGraph("SGmooseegg")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.InitEgg = InitEgg
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnSave = OnSave

    MakeHauntableWork(inst)

    return inst
end

local nesting_ground_assets =
{
    Asset("ANIM", "anim/nesting_ground.zip"),
}

local function ontimerdone(inst, data)
    if data.name == "CallMoose" then
        --If this happens then the nesting location was asleep for the entire waiting period.
        --Put down a moose and pre-lay an egg.
        TheWorld.components.moosespawner:DoHardSpawn(inst)
    end
end

local function spawnmoose(inst)
    --print(string.format("mooseIncoming = %s", tostring(inst.mooseIncoming)))
    if inst.mooseIncoming then
        TheWorld.components.moosespawner:DoSoftSpawn(inst)
    end
end

local function nest_onsave(inst, data)
    data.mooseIncoming = inst.mooseIncoming
end

local function nest_onload(inst, data)
    if data ~= nil and data.mooseIncoming ~= nil then
        inst.mooseIncoming = data.mooseIncoming
    end
end

local function nesting_ground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("nesting_ground")
    inst.AnimState:SetBuild("nesting_ground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:AddComponent("playerprox")

    inst.components.playerprox:SetDist(15, 20)
    inst.components.playerprox:SetOnPlayerNear(spawnmoose)

    inst.OnSave = nest_onsave
    inst.OnLoad = nest_onload

    return inst
end

return Prefab( "mooseegg", fn, assets, prefabs),
    Prefab("moose_nesting_ground", nesting_ground_fn, nesting_ground_assets)
