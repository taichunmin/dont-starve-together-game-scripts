local prefabs =
{
    "sporecloud",
}

local FADE_FRAMES = 10
local FADE_INTENSITY = .8
local FADE_RADIUS = 1
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

local function UpdateBuild(inst, playsound)
    inst._buildtask = nil
    if inst._level < 1 then
        inst.AnimState:ClearOverrideSymbol("trunk")
    else
        inst.AnimState:OverrideSymbol("trunk", inst.prefab.."_upg_build", "trunk"..tostring(inst._level))
    end
    if playsound then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/mushtree_hit")
    end
end

local function Sway(inst)
    if inst._destroy then
        inst.components.workable:Destroy(inst)
    elseif inst._level ~= inst._targetlevel then
        inst.AnimState:PlayAnimation("transform")
        inst._level = inst._targetlevel
        if inst._buildtask == nil then
            inst._buildtask = inst:DoTaskInTime(15 * FRAMES, UpdateBuild, true)
        end
    else
        if inst._buildtask ~= nil then
            inst._buildtask:Cancel()
            UpdateBuild(inst)
        end
        inst.AnimState:PlayAnimation("sway"..math.random(3).."_loop")
    end
end

local function OnBurnt(inst)
    if not inst.persists then
        return
    end

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(nil)
    inst.components.workable:SetWorkable(false)

    RemovePhysicsColliders(inst)

    SpawnPrefab("sporecloud").Transform:SetPosition(inst.Transform:GetWorldPosition())

    if inst._buildtask ~= nil then
        inst._buildtask:Cancel()
        UpdateBuild(inst)
    end
    inst.AnimState:PlayAnimation("burnt_chop")
    inst:RemoveEventCallback("animover", Sway)
    inst:ListenForEvent("animover", inst.Remove)

    FadeOut(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    if inst._link ~= nil then
        inst._link:PushEvent("unlinkmushroomsprout", inst)
        inst._link = nil
    end
end

local function stop_burning(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
end

local function chop_down_tree(inst, worker)
    if inst._destroy then
        inst._destroy = nil
    elseif not inst.persists then
        return
    end

    inst:RemoveComponent("hauntable")

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(nil)
    inst.components.workable:SetWorkable(false)

    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst:DoTaskInTime(28 * FRAMES, stop_burning)
    end

    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if inst._buildtask ~= nil then
        inst._buildtask:Cancel()
        UpdateBuild(inst)
    end
    inst.AnimState:PlayAnimation("fall")
    inst:RemoveEventCallback("animover", Sway)
    inst:ListenForEvent("animover", inst.Remove)

    FadeOut(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    if inst._link ~= nil then
        inst._link:PushEvent("unlinkmushroomsprout", inst)
        inst._link = nil
    end
end

local function chop_tree(inst, chopper)
    if chopper == nil or not chopper:HasTag("playerghost") then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/mushtree_hit")
    if inst._buildtask ~= nil then
        inst._buildtask:Cancel()
        UpdateBuild(inst)
    end
    inst.AnimState:PlayAnimation("chop")
end

local function inspect_tree(inst)
    return inst.components.burnable ~= nil
        and inst.components.burnable:IsBurning()
        and "BURNING"
        or nil
end

local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or nil
end

local function OnLoad(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    if data ~= nil and data.burnt then
        OnBurnt(inst)
    else
        inst._fade:set(FADE_FRAMES)
        OnFadeDirty(inst)
        Sway(inst)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end
end

local function DoLink(inst, link)
    inst._link = link

    inst:ListenForEvent("toadstoollevel", function(link, level)
        if inst._link ~= nil then
            inst._targetlevel = level
            if POPULATING then
                inst._level = level
                if inst._buildtask ~= nil then
                    inst._buildtask:Cancel()
                end
                UpdateBuild(inst)
            end
        end
    end, link)

    local function onlinkdead(link)
        if inst._link ~= nil then
            inst._link = nil
            if inst.persists then
                inst._destroy = true
                inst.persists = false
            end
        end
    end
    inst:ListenForEvent("onremove", onlinkdead, link)
    inst:ListenForEvent("death", onlinkdead, link)

    link:PushEvent("linkmushroomsprout", inst)
end

local function OnLoadPostPass(inst)
    if inst._link == nil then
        local link = inst.components.entitytracker:GetEntity("toadstool")
        if link ~= nil then
            DoLink(inst, link)
        end
    end
end

local function OnLinkToadstool(inst, link)
    if inst._link == nil then
        inst.components.entitytracker:TrackEntity("toadstool", link)
        DoLink(inst, link)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/mushtree_grow")
end

local function MakeSprout(name)
    local assets =
    {
        Asset("ANIM", "anim/mushroomsprout.zip"),
        Asset("ANIM", "anim/"..name.."_upg_build.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        --DO THE PHYSICS STUFF MANUALLY SO THAT WE CAN SHUT OFF THE BOSS COLLISION.
        --don't yell at me plz...
        --MakeObstaclePhysics(inst, .25, 2)
        ----------------------------------------------------
        inst:AddTag("blocker")
        inst.entity:AddPhysics()
        inst.Physics:SetMass(0)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        --inst.Physics:CollidesWith(COLLISION.GIANTS)
        inst.Physics:SetCapsule(.25, 2)
        ----------------------------------------------------

        inst.Light:SetFalloff(FADE_FALLOFF)
        inst.Light:SetIntensity(FADE_INTENSITY)
        inst.Light:SetRadius(FADE_RADIUS)
        inst.Light:SetColour(180 / 255, 60 / 255, 255 / 255)
        inst.Light:Enable(false)
        inst.Light:EnableClientModulation(true)

        --inst:AddTag("shelter")
        inst:AddTag("tree")
        inst:AddTag("mushroomsprout")
        inst:AddTag("cavedweller")

        inst.AnimState:SetBuild(name.."_upg_build")
        inst.AnimState:SetBank("mushroomsprout")
        inst.AnimState:PlayAnimation("shroom_pre")
        inst.AnimState:SetLightOverride(.3)

        inst._fade = net_smallbyte(inst.GUID, "mushroomsprout._fade", "fadedirty")

        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("fadedirty", OnFadeDirty)

            return inst
        end

        inst.scrapbook_specialinfo = "MUSHROOMSPROUT"
        inst.scrapbook_anim = "sway2_loop"

        inst._level = 0
        inst._targetlevel = 0

        MakeSmallPropagator(inst)
        MakeMediumBurnable(inst, TUNING.TREE_BURN_TIME)
        inst.components.burnable:SetOnBurntFn(OnBurnt)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)

        inst:ListenForEvent("animover", Sway)
        inst._inittask = inst:DoTaskInTime(0, OnInit)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        if name ~= "mushroomsprout" then
            inst.components.inspectable.nameoverride = "mushroomsprout"
            inst.components.workable:SetWorkLeft(TUNING.TOADSTOOL_DARK_MUSHROOMSPROUT_CHOPS)
        else
            inst.components.workable:SetWorkLeft(TUNING.TOADSTOOL_MUSHROOMSPROUT_CHOPS)
        end

        inst:AddComponent("entitytracker")

        MakeHauntableWorkAndIgnite(inst)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnLoadPostPass = OnLoadPostPass

        inst:ListenForEvent("linktoadstool", OnLinkToadstool)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeSprout("mushroomsprout"),
    MakeSprout("mushroomsprout_dark")
