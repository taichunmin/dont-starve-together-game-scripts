local FADE_FRAMES = 5
local FADE_INTENSITY = .8
local FADE_RADIUS = 1.5
local FADE_FALLOFF = .5

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetRadius(FADE_RADIUS * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeOut(inst)
    inst._fade:set(FADE_FRAMES + 1)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
end

local function CreateGroundFX(bomb)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("mushroombomb_base")
    inst.AnimState:SetBuild("mushroombomb_base")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:ListenForEvent("animover", inst.Remove)

    inst.Transform:SetPosition(bomb.Transform:GetWorldPosition())
end

local EXPLODETARGET_MUST_TAGS = { "_health", "_combat" }
local EXPLODETARGET_CANT_TAGS = { "INLIMBO", "toadstool" }

local function Explode(inst)
    inst._growtask = nil

    inst.AnimState:PlayAnimation("explode")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_explode")
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), inst.Remove)
    inst.persists = false

    inst._explode:push()
    FadeOut(inst)

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        CreateGroundFX(inst)
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.TOADSTOOL_MUSHROOMBOMB_RADIUS, EXPLODETARGET_MUST_TAGS, EXPLODETARGET_CANT_TAGS)
    if #ents > 0 then
        local toadstool = inst.components.entitytracker:GetEntity("toadstool")
        local damage =
            (toadstool ~= nil and toadstool.components.combat ~= nil and toadstool.components.combat.defaultdamage) or
            (inst.prefab ~= "mushroombomb" and TUNING.TOADSTOOL_DARK_DAMAGE_LVL[0]) or
            TUNING.TOADSTOOL_DAMAGE_LVL[0]

        for i, v in ipairs(ents) do
            if v:IsValid() and not v:IsInLimbo() and
                v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
                v.components.combat:GetAttacked(inst, damage)
            end
        end
    end
end

local function PlayGrowSound(inst)
    inst._soundtask = nil
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_grow")
end

local function CancelGrowSound(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    end
end

local function QueueGrowSound(inst, delay)
    CancelGrowSound(inst)
    inst._soundtask = inst:DoTaskInTime(delay, PlayGrowSound)
end

local function Grow(inst, level)
    if level > 2 then
        inst.AnimState:PlayAnimation("explode_pre")
        local len = inst.AnimState:GetCurrentAnimationLength()
        inst._growtask = inst:DoTaskInTime(GetRandomMinMax(len * .5, len), Explode)
        CancelGrowSound(inst)
    else
        inst.AnimState:PlayAnimation("grow"..tostring(level))
        inst._growtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), Grow, level + 1)
        QueueGrowSound(inst, 8 * FRAMES)
    end
end

local function OnSave(inst, data)
    data.lifetime = math.floor(((inst._lifetime or 0) + inst:GetTimeAlive()) * 10) * .1
end

local function OnLoad(inst, data)
    if data ~= nil and data.lifetime ~= nil and inst._growtask ~= nil then
        inst._growtask:Cancel()
        CancelGrowSound(inst)

        local dt = math.max(0, data.lifetime)
        inst._lifetime = dt

        local fade = math.max(math.floor(dt / FRAMES + .5), FADE_FRAMES)
        if fade > 0 then
            inst._fade:set(fade - 1)
            OnFadeDirty(inst)
        end

        inst.AnimState:PlayAnimation("land")
        local len = inst.AnimState:GetCurrentAnimationLength()
        if dt < len then
            inst.AnimState:SetTime(dt)
            inst._growtask = inst:DoTaskInTime(len - dt, Grow, 1)
            if dt < 4 * FRAMES then
                QueueGrowSound(inst, 4 * FRAMES - dt)
            end
            return
        end

        for level = 1, 2 do
            dt = math.max(0, dt - len)
            inst.AnimState:PlayAnimation("grow"..tostring(level))
            len = inst.AnimState:GetCurrentAnimationLength()
            if dt < len then
                inst.AnimState:SetTime(dt)
                inst._growtask = inst:DoTaskInTime(len - dt, Grow, level + 1)
                if dt < 8 * FRAMES then
                    QueueGrowSound(inst, 8 * FRAMES - dt)
                end
                return
            end
        end

        dt = math.max(0, dt - len)
        inst.AnimState:PlayAnimation("explode_pre")
        len = inst.AnimState:GetCurrentAnimationLength()
        inst.AnimState:SetTime(math.min(dt, len))
        inst._growtask = inst:DoTaskInTime(math.max(0, GetRandomMinMax(.5 * len, len) - dt), Explode)
    end
end

local function MakeBomb(name)
    local assets =
    {
        Asset("ANIM", "anim/mushroombomb.zip"),
        Asset("ANIM", "anim/mushroombomb_base.zip"),
    }
    if name ~= "mushroombomb" then
        table.insert(assets, Asset("ANIM", "anim/"..name.."_build.zip"))
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("mushroombomb")
        inst.AnimState:SetBuild(name == "mushroombomb" and "mushroombomb" or (name.."_build"))
        inst.AnimState:PlayAnimation("land")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        inst.Light:SetFalloff(FADE_FALLOFF)
        inst.Light:SetIntensity(FADE_INTENSITY)
        inst.Light:SetRadius(FADE_RADIUS)
        inst.Light:SetColour(200 / 255, 100 / 255, 170 / 255)
        inst.Light:Enable(false)
        inst.Light:EnableClientModulation(true)

        inst:AddTag("explosive")

        inst._explode = net_event(inst.GUID, "mushroombomb._explode")
        inst._fade = net_smallbyte(inst.GUID, "mushroombomb._fade", "fadedirty")

        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("mushroombomb._explode", CreateGroundFX)
            inst:ListenForEvent("fadedirty", OnFadeDirty)

            return inst
        end

        inst:AddComponent("inspectable")
        if name ~= "mushroombomb" then
            inst.components.inspectable.nameoverride = "mushroombomb"
        end

        inst:AddComponent("entitytracker")

        inst._soundtask = nil
        inst._growtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), Grow, 1)
        QueueGrowSound(inst, 4 * FRAMES)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end

    return Prefab(name, fn, assets)
end

local function MakeProjectile(name, bombname)
    local assets =
    {
        Asset("ANIM", "anim/mushroombomb.zip"),
    }
    if bombname ~= "mushroombomb" then
        table.insert(assets, Asset("ANIM", "anim/"..bombname.."_build.zip"))
    end

    local prefabs =
    {
        bombname,
    }

    local function OnProjectileHit(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        inst:Remove()
        local bomb = SpawnPrefab(bombname)
        bomb.Transform:SetPosition(x, y, z)
        bomb.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_land")
        local toadstool = inst.components.entitytracker:GetEntity("toadstool")
        if toadstool ~= nil then
            bomb.components.entitytracker:TrackEntity("toadstool", toadstool)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.entity:AddPhysics()
        inst.Physics:SetMass(1)
        inst.Physics:SetFriction(0)
        inst.Physics:SetDamping(0)
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:SetCapsule(.2, .2)

        inst.AnimState:SetBank("mushroombomb")
        inst.AnimState:SetBuild(bombname == "mushroombomb" and "mushroombomb" or (bombname.."_build"))
        inst.AnimState:PlayAnimation("projectile_loop", true)

        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor")

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-25)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
        inst.components.complexprojectile:SetOnHit(OnProjectileHit)

        inst:AddComponent("entitytracker")

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeBomb("mushroombomb"),
    MakeBomb("mushroombomb_dark"),
    MakeProjectile("mushroombomb_projectile", "mushroombomb"),
    MakeProjectile("mushroombomb_dark_projectile", "mushroombomb_dark")
