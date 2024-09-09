SetSharedLootTable("gargoyles_loot",
{
    { "moonrocknugget", 1 },
    { "moonrocknugget", .5 },
})

SetSharedLootTable("brokenhound_loot",
{
    { "monstermeat", 1 },
    { "moonrocknugget", .5 },
})

SetSharedLootTable("brokenwerepig_loot",
{
    { "meat", 1 },
    { "pigskin", .5 },
    { "moonrocknugget", .5 },
})

local function makegargoyle(data)
    local assets =
    {
        Asset("ANIM", "anim/sculpture_"..data.name..".zip"),
        Asset("ANIM", "anim/sculpture_"..data.name.."_moonrock_build.zip"),
    }

    local prefabs =
    {
        "moonrocknugget",
        data.petrify_prefab,
        "gargoyle_"..data.name..data.anim.."_fx",
    }

    local function crumble(inst)
        if inst._petrifytask ~= nil then
            inst._petrifytask:Cancel()
            inst._petrifytask = nil
        end
        if inst._reanimatetask ~= nil then
            inst._reanimatetask:Cancel()
        end
        inst.AnimState:PlayAnimation("transform_"..data.anim.."2")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot(inst:GetPosition())
        RemovePhysicsColliders(inst)
        inst:AddTag("NOCLICK")
        inst.persists = false
        inst._reanimatetask = inst:DoTaskInTime(1, ErodeAway)
    end

    local function onwork(inst, worker, workleft)
        if workleft <= 0 then
            crumble(inst)
        else
            inst.AnimState:PlayAnimation(workleft > TUNING.GARGOYLE_MINE_LOW and data.anim or (data.anim.."2"))
        end
    end

    local function onworkload(inst)
        inst.AnimState:PlayAnimation(inst.components.workable.workleft > TUNING.GARGOYLE_MINE_LOW and data.anim or (data.anim.."2"))
    end

    local function OnSettled(inst)
        inst._petrifytask = nil
        inst.components.workable:SetWorkable(true)
    end

    local function OnPetrified(inst)
        local fx = SpawnPrefab("gargoyle_"..data.name..data.anim.."_fx")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.AnimState:SetBank("sculpture_"..data.name)
        inst.AnimState:SetBuild("sculpture_"..data.name.."_moonrock_build")
        inst.AnimState:PlayAnimation(data.anim.."_pre")
        inst._petrifytask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), OnSettled)
    end

    local function Petrify(inst)
        if inst:IsAsleep() then
            if inst._petrifytask ~= nil then
                inst._petrifytask:Cancel()
                inst._petrifytask = nil
            end
            inst.components.workable:SetWorkable(true)
            inst.AnimState:SetBank("sculpture_"..data.name)
            inst.AnimState:SetBuild("sculpture_"..data.name.."_moonrock_build")
            inst.AnimState:PlayAnimation(data.anim)
        elseif inst._petrifytask == nil then
            inst.components.workable:SetWorkable(false)
            inst.AnimState:SetBank(data.petrify_bank)
            inst.AnimState:SetBuild(data.petrify_build)
            inst.AnimState:PlayAnimation(data.petrify_anim)
            inst._petrifytask = inst:DoTaskInTime(data.petrify_time, OnPetrified)
        end
    end

    local function OnReanimate(inst, moonbase)
        inst.AnimState:PlayAnimation("transform_"..data.anim)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        RemovePhysicsColliders(inst)
        inst:AddTag("NOCLICK")
        inst.persists = false
        inst._reanimatetask = inst:DoTaskInTime(1, ErodeAway)

        local creature = SpawnPrefab(data.petrify_prefab)
        if data.named then
            creature.components.named:SetName(inst.components.named.name)
        end
        creature.Transform:SetPosition(inst.Transform:GetWorldPosition())
        creature.Transform:SetRotation(inst.Transform:GetRotation())
        if moonbase ~= nil and moonbase:IsValid() then
            creature.components.entitytracker:TrackEntity("moonbase", moonbase)
        end
        local dead = data.petrify_anim == "death"
		creature.sg:GoToState("reanimate", { anim = data.reanimate_anim, time = data.reanimate_time, frame = data.reanimate_frame, dead = dead })
        if dead then
            creature.components.health:Kill()
        end
    end

    local function Struggle(inst, moonbase, count)
        inst.AnimState:PlayAnimation(data.anim.."_pre")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/sculptures/shake")
        if count == nil then
            inst._reanimatetask = inst:DoTaskInTime(math.random() * .5 + .5, Struggle, moonbase, math.random(2))
        elseif count > 1 then
            inst._reanimatetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), Struggle, moonbase, count - 1)
        else
            inst._reanimatetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - 5 * FRAMES, OnReanimate, moonbase)
        end
    end

    local function Reanimate(inst, moonbase)
        if inst._petrifytask ~= nil then
            inst._petrifytask:Cancel()
            inst._petrifytask = nil
        end
        if inst._reanimatetask == nil then
            if inst.components.workable.workleft > TUNING.GARGOYLE_MINE_LOW then
                inst.components.workable:SetWorkable(false)
                inst._reanimatetask = inst:DoTaskInTime(math.random() * 1.5 + .5, Struggle, moonbase)
            else
                inst.components.lootdropper:SetChanceLootTable("broken"..data.name.."_loot")
                crumble(inst)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("gargoyle")

        if data.named then
            --Sneak these into pristine state for optimization
            inst:AddTag("_named")
        end

        MakeObstaclePhysics(inst, .9)

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("sculpture_"..data.name)
        inst.AnimState:SetBuild("sculpture_"..data.name.."_moonrock_build")
        inst.AnimState:PlayAnimation(data.anim)
        inst.AnimState:SetFinalOffset(1)

        inst:SetPrefabNameOverride("gargoyle_"..data.name)

        inst.scrapbook_proxy = "gargoyle_"..data.name.."death"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_adddeps = { "moonbase" }

        if data.named then
            --Remove these tags so that they can be added properly when replicating components below
            inst:RemoveTag("_named")

            inst:AddComponent("named")
        end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable("gargoyles_loot")

        inst:AddComponent("inspectable")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(TUNING.GARGOYLE_MINE)
        inst.components.workable:SetOnWorkCallback(onwork)
        inst.components.workable:SetOnLoadFn(onworkload)
        inst.components.workable.savestate = true

        MakeHauntableWork(inst)

        inst:AddComponent("savedrotation")

        inst._petrifytask = nil
        inst._reanimatetask = nil
        inst.Petrify = Petrify
        inst.Reanimate = Reanimate

        return inst
    end

    return Prefab("gargoyle_"..data.name..data.anim, fn, assets, prefabs)
end

local function makefx(data)
    local assets =
    {
        Asset("ANIM", "anim/sculpture_fx.zip"),
        Asset("ANIM", "anim/petrified_tree_fx.zip"),
    }

    local function PlayFX(proxy)
        local inst = CreateEntity()

        inst:AddTag("FX")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst.Transform:SetFromProxy(proxy.GUID)

        inst.AnimState:SetBank("sculpture_fx")
        inst.AnimState:SetBuild("petrified_tree_fx")
        inst.AnimState:PlayAnimation(data.name..data.anim)
        --I think we like 'em behind
        --inst.AnimState:SetFinalOffset(3)

        inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")

        inst:ListenForEvent("animover", inst.Remove)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayFX)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab("gargoyle_"..data.name..data.anim.."_fx", fn, assets)
end

local data =
{
    {
        name = "hound",
        anim = "atk",
        petrify_prefab = "moonhound",
        petrify_bank = "hound",
        petrify_build = "hound",
        petrify_anim = "atk_petrify",
        petrify_time = 14 * FRAMES,
        reanimate_anim = "atk_reanimate",
    },
    {
        name = "hound",
        anim = "death",
        petrify_prefab = "moonhound",
        petrify_bank = "hound",
        petrify_build = "hound",
        petrify_anim = "death",
        petrify_time = 14 * FRAMES,
        reanimate_anim = "death",
		--reanimate_time = 14 * FRAMES,
		reanimate_frame = 14,
    },
    {
        name = "werepig",
        anim = "atk",
        petrify_prefab = "moonpig",
        petrify_bank = "pigman",
        petrify_build = "werepig_build",
        petrify_anim = "were_atk_petrify",
        petrify_time = 16 * FRAMES,
        reanimate_anim = "were_atk_reanimate",
        named = true,
    },
    {
        name = "werepig",
        anim = "death",
        petrify_prefab = "moonpig",
        petrify_bank = "pigman",
        petrify_build = "werepig_build",
        petrify_anim = "death",
        petrify_time = 13 * FRAMES,
        reanimate_anim = "death",
		--reanimate_time = 13 * FRAMES,
		reanimate_frame = 13,
        named = true,
    },
    {
        name = "werepig",
        anim = "howl",
        petrify_prefab = "moonpig",
        petrify_bank = "pigman",
        petrify_build = "werepig_build",
        petrify_anim = "howl",
        petrify_time = 29 * FRAMES,
        reanimate_anim = "howl",
		--reanimate_time = 29 * FRAMES,
		reanimate_frame = 29,
        named = true,
    },
}

local t = {}
for i, v in ipairs(data) do
    table.insert(t, makegargoyle(v))
    table.insert(t, makefx(v))
end
data = nil
return unpack(t)
