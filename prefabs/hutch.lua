local assets =
{
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/hutch.zip"),
    Asset("ANIM", "anim/hutch_build.zip"),
    Asset("ANIM", "anim/hutch_musicbox_build.zip"),
    Asset("ANIM", "anim/hutch_pufferfish_build.zip"),

    Asset("SOUND", "sound/chester.fsb"),
    Asset("SOUND", "sound/together.fsb"),

    Asset("MINIMAP_IMAGE", "hutch"),
    Asset("MINIMAP_IMAGE", "hutch_musicbox"),
    Asset("MINIMAP_IMAGE", "hutch_pufferfish"),
}

local light_assets =
{
    Asset("ANIM", "anim/hutch_lightfx_base.zip"),
}

local prefabs =
{
    "hutch_fishbowl",
    "hutch_music_light_fx",
    "hutch_move_fx",
    "chester_transform_fx",
    "impact",
    "globalmapiconunderfog",
}

local brain = require "brains/chesterbrain"

local sounds =
{
    sleep = "dontstarve/creatures/together/hutch/sleep",
    hurt = "dontstarve/creatures/together/hutch/hit",
    pant = "dontstarve/creatures/together/hutch/pant",
    death = "dontstarve/creatures/together/hutch/death",
    open = "dontstarve/creatures/together/hutch/open",
    close = "dontstarve/creatures/together/hutch/close",
    pop = "dontstarve/creatures/together/hutch/pop",
    lick = "dontstarve/creatures/together/hutch/lick",
    boing = "dontstarve/creatures/together/hutch/land_hit",
    land = "dontstarve/creatures/together/hutch/land",
    musicbox = "dontstarve/creatures/together/hutch/one_man_band",
}

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function ShouldKeepTarget()
    return false -- hutch can't attack, and won't sleep if he has a target
end

local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end

local function OnClose(inst)
    if not inst.components.health:IsDead() and inst.sg.currentstate.name ~= "morph" then
        inst.sg:GoToState("close")
    end
end

-- eye bone was killed/destroyed
local function OnStopFollowing(inst)
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    inst:AddTag("companion")
end

--------------------------------------------------------------------------------
--Normal and Musicbox Hutch with lightbulb
local LIGHT_RADIUS = 2.5
local LIGHT_INTENSITY = .8
local LIGHT_FALLOFF = .4

--Puffy Hutch with lightbulb
local DIM_LIGHT_RADIUS = 2.1
local DIM_LIGHT_INTENSITY = .6
local DIM_LIGHT_FALLOFF = .55

--Musicbox Hutch with no lightbulb
local FAINT_LIGHT_RADIUS = 1
local FAINT_LIGHT_INTENSITY = .01
local FAINT_LIGHT_FALLOFF = .4

local NORMAL_LIGHT_COLOUR = { 180 / 255, 195 / 255, 150 / 255 }
local MUSIC_LIGHT_COLOUR = { 150 / 255, 150 / 255, 255 / 255 }

local function SetNormalLight(inst)
    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetColour(unpack(NORMAL_LIGHT_COLOUR))
end

local function SetDimLight(inst)
    inst.Light:SetRadius(DIM_LIGHT_RADIUS)
    inst.Light:SetIntensity(DIM_LIGHT_INTENSITY)
    inst.Light:SetFalloff(DIM_LIGHT_FALLOFF)
    inst.Light:SetColour(unpack(NORMAL_LIGHT_COLOUR))
end

local function SetMusicLight(inst)
    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetColour(unpack(MUSIC_LIGHT_COLOUR))
end

--------------------------------------------------------------------------------

local function LightBattery(item)
    return item:HasTag("lightbattery")
end

local function DamageReflectBattery(item)
    return item:HasTag("pointy")
end

local function MusicBattery(item)
    return item:HasTag("band")
end

local function FindBattery(inst, fn)
    return inst.components.container:FindItem(fn)
end

local function OnReflectDamage(inst, data)
    local spear = inst.components.container:FindItem(DamageReflectBattery)
    if spear ~= nil and spear.components.finiteuses ~= nil then
        spear.components.finiteuses:Use(
            spear.components.weapon ~= nil and
            spear.components.weapon.attackwear or
            1
        )
    end
    if data.attacker ~= nil and data.attacker:IsValid() then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            if data.attacker.components.combat ~= nil then
                local follower = impactfx.entity:AddFollower()
                follower:FollowSymbol(data.attacker.GUID, data.attacker.components.combat.hiteffectsymbol, 0, 0, 0)
            else
                impactfx.Transform:SetPosition(data.attacker.Transform:GetWorldPosition())
            end
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end
end

local function CreateGroundGlow(inst, rotrate)
    local groundglow = SpawnPrefab("hutch_music_light_fx")
    local scale = (math.random() * .2 + 1.2) * (math.random() < .5 and 1 or -1)
    groundglow.Transform:SetScale(scale, scale, scale)
    groundglow.Follower:FollowSymbol(inst.GUID, "base_point", 0, 0, 0)
    groundglow:InitFX(
        inst,
        {
            rot = math.random(0, 359),
            rotrate = rotrate,
            alpha = math.random(),
            alphadir = math.random() < .5,
            alpharate = math.random() * .02 + .005,
        }
    )
    return groundglow
end

local function CheckBattery(inst)
    local current_form = inst.components.amorphous:GetCurrentForm()

    local lightbattery = --[[ works for all forms ]] FindBattery(inst, LightBattery)
    local pointybattery = current_form == "FUGU" and FindBattery(inst, DamageReflectBattery) or nil
    local musicbattery = current_form == "MUSIC" and lightbattery ~= nil and FindBattery(inst, MusicBattery) or nil

    if inst._lightbattery ~= lightbattery then
        if lightbattery ~= nil then
            if inst._lightbattery == nil then
                inst.Light:Enable(true)
                inst.AnimState:Show("fx_lure_light")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/light_on")
            end
        elseif inst._lightbattery ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/light_off")
            inst.Light:Enable(false)
            inst.AnimState:Hide("fx_lure_light")
        end
        inst._lightbattery = lightbattery
    end

    if inst._pointybattery ~= pointybattery then
        if pointybattery ~= nil then
            if inst._pointybattery == nil then
                inst:AddComponent("damagereflect")
                inst.components.damagereflect:SetDefaultDamage(TUNING.HUTCH_PRICKLY_DAMAGE)
                inst:ListenForEvent("onreflectdamage", OnReflectDamage)
            end
        elseif inst._pointybattery ~= nil then
            inst:RemoveComponent("damagereflect")
            inst:RemoveEventCallback("onreflectdamage", OnReflectDamage)
        end
        inst._pointybattery = pointybattery
    end

    if inst._musicbattery ~= musicbattery then
        if inst._musicbattery ~= nil and
            inst._musicbattery:IsValid() and
            inst._musicbattery.components.fueled ~= nil then
            inst._musicbattery.components.fueled:StopConsuming()
        end
        if musicbattery ~= nil then
            if inst._musicbattery == nil then
                inst:AddComponent("sanityaura")
                inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
                inst.SoundEmitter:PlaySound(inst.sounds.musicbox, "hutchMusic")
                inst.SoundEmitter:SetParameter("hutchMusic", "intensity", inst.components.container:IsOpen() and 1 or 0)
                inst._groundglows =
                {
                    CreateGroundGlow(inst, .5),
                    CreateGroundGlow(inst, -.5),
                    CreateGroundGlow(inst, 1),
                }
            end
            if musicbattery.components.fueled ~= nil then
                musicbattery.components.fueled:StartConsuming()
            end
        elseif inst._musicbattery ~= nil then
            inst:RemoveComponent("sanityaura")
            inst.SoundEmitter:KillSound("hutchMusic")
            for i, v in ipairs(inst._groundglows) do
                v:Remove()
            end
            inst._groundglows = nil
        end
        inst._musicbattery = musicbattery
    end
end

local function SetBuild(inst)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        local state = ""
        if inst.current_def_build == "hutch_pufferfish_build" then
            state = "_puffer"
        elseif inst.current_def_build == "hutch_musicbox_build" then
            state = "_music"
        end

        inst.AnimState:OverrideItemSkinSymbol("base", skin_build, "base" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_body", skin_build, "hutch_body" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_face", skin_build, "hutch_face" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_foot", skin_build, "hutch_foot" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_lid", skin_build, "hutch_lid" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_lure", skin_build, "hutch_lure" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_tail", skin_build, "hutch_tail" .. state, inst.GUID, inst.current_def_build or "hutch_build")
        inst.AnimState:OverrideItemSkinSymbol("hutch_tongue", skin_build, "hutch_tongue" .. state, inst.GUID, inst.current_def_build or "hutch_build")
    else
        inst.AnimState:ClearAllOverrideSymbols()
        inst.AnimState:SetBuild(inst.current_def_build or "hutch_build")
    end
end

--------------------------------------------------------------------------------
local function CreateForm(name, itemtags, build, icon, onenter, onexit)
    local function enterfn(inst)
        inst.current_def_build = build
        inst.AnimState:SetBuild(build)
        SetBuild(inst)
        inst.MiniMapEntity:SetIcon(icon)
        inst.components.maprevealable:SetIcon(icon)
        if onenter ~= nil then
            onenter(inst)
        end
        CheckBattery(inst)
    end

    return
    {
        name = name,
        itemtags = itemtags,
        enterformfn = function(inst, instant)
            if not instant then
                inst:PushEvent("morph", { morphfn = enterfn })
            elseif enterfn ~= nil then
                enterfn(inst)
            end
        end,
        exitformfn = onexit,
    }
end

--List forms in order of priority
--Final form is the default fallback even if no matching tag
--This is fine because even if you are in that form, the
--battery effect won't turn on if it's not found
local forms =
{
    CreateForm("FUGU", { "lightbattery", "pointy" }, "hutch_pufferfish_build", "hutch_pufferfish.png", SetDimLight, nil),
    CreateForm("MUSIC", { "lightbattery", "band" }, "hutch_musicbox_build", "hutch_musicbox.png", SetMusicLight, nil),
    CreateForm("NORMAL", nil, "hutch_build", "hutch.png", SetNormalLight, nil),
}

CreateForm = nil

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.hauntable.panic = true
        inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL

        return true
    end
    return false
end

local function OnLoadPostPass(inst)
    inst:ListenForEvent("itemget", CheckBattery)
    inst:ListenForEvent("itemlose", CheckBattery)
    if POPULATING then
        CheckBattery(inst)
    end
end


local function create_hutch()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("hutch")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")

    inst.MiniMapEntity:SetIcon("hutch.png")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.AnimState:SetBank("hutch")
    inst.AnimState:SetBuild("hutch_build")
    inst.AnimState:Hide("fx_lure_light")

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetColour(unpack(NORMAL_LIGHT_COLOUR))
    inst.Light:Enable(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------
    inst:AddComponent("maprevealable")
    inst.components.maprevealable:SetIconPrefab("globalmapiconunderfog")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "hutch_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HUTCH_HEALTH)
    inst.components.health:StartRegen(TUNING.HUTCH_HEALTH_REGEN_AMOUNT, TUNING.HUTCH_HEALTH_REGEN_PERIOD)

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "hutch_body")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("hutch")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true


    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    MakeHauntableDropFirstItem(inst)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst.sounds = sounds
    inst.leave_slime = true

    inst:SetStateGraph("SGchester")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

    inst:AddComponent("amorphous")
    for i, v in ipairs(forms) do
        inst.components.amorphous:AddForm(v)
    end
    inst.components.amorphous:MorphToForm(forms[#forms], true)

    inst.OnLoadPostPass = OnLoadPostPass
    if not POPULATING then
        OnLoadPostPass(inst)
    end

    inst.SetBuild = SetBuild
    
    return inst
end

-----------------------------------------------------------------

local STATE_TO_FXANIM =
{
    ["walk"] = "walk1_loop",
    ["walk_start"] = "walk1_pre",
    ["walk_stop"] = "walk1_pst",
    ["morph"] = "transition",
    ["death"] = "death",
    ["hit"] = "hit",
    ["idle"] = "idle_loop",
}

local FXANIMS = {}
local STATE_ID = {}
for k, v in pairs(STATE_TO_FXANIM) do
    table.insert(FXANIMS, v)
    STATE_ID[k] = #FXANIMS
end

local function SerializeFX(inst, data, islocal)
    --[0, 359]
    local rot = data.rot

    --[-.5, .5, 1]
    local rotrate = data.rotrate <= 0 and 0 or (data.rotrate < 1 and 2 or 3)

    --[0.0, 1.0)
    local alpha = math.floor(data.alpha * 255 + .5)

    --[true, false]
    local alphadir = data.alphadir

    --[.005, .025)
    local alpharate = math.floor((data.alpharate - .005) / .02 * 63 + .5)

    if islocal then
        inst._rot:set_local(rot)
        inst._rotrate:set_local(rotrate)
        inst._alpha:set_local(alpha)
        inst._alphadir:set_local(alphadir)
        inst._alpharate:set_local(alpharate)
    else
        inst._rot:set(rot)
        inst._rotrate:set(rotrate)
        inst._alpha:set(alpha)
        inst._alphadir:set(alphadir)
        inst._alpharate:set(alpharate)
    end
end

local function DeserializeFX(inst, data)
    data.rot = inst._rot:value()
    data.rotrate = (inst._rotrate:value() - 1) * .5
    data.alpha = inst._alpha:value() / 255
    data.alphadir = inst._alphadir:value()
    data.alpharate = inst._alpharate:value() / 63 * .02 + .005
end

local function SpawnFX()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("hutch_lightfx_base")
    inst.AnimState:SetBuild("hutch_lightfx_base")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function PushFXParams(inst, data)
    if inst._fx ~= nil then
        local alpha = data.alpha * .2
        inst._fx.AnimState:SetMultColour(alpha, alpha, alpha, alpha)
        inst._fx.Transform:SetRotation(data.rot)
    end
end

local function OnUpdateFX(inst, data)
    data.rot = data.rot + data.rotrate
    if data.rot >= 360 then
        data.rot = data.rot - 360
    elseif data.rot < 0 then
        data.rot = data.rot + 360
    end

    local switchdir = false
    if data.alphadir then
        data.alpha = data.alpha + data.alpharate
        if data.alpha >= 1 then
            data.alpha = 1
            switchdir = true
        end
    else
        data.alpha = data.alpha - data.alpharate
        if data.alpha <= .1 then
            data.alpha = .1
            switchdir = true
        end
    end

    PushFXParams(inst, data)

    if TheWorld.ismastersim then
        --Don't switch dir on client until master sync
        if switchdir then
            data.alphadir = not data.alphadir
        end
        SerializeFX(inst, data, not switchdir)
    end
end

local function OnAnimDirty(inst)
    local anim = FXANIMS[inst._anim:value()]
    if anim ~= nil then
        inst._fx.AnimState:PlayAnimation(anim, true)
    end
end

local function OnFXDirty(inst)
    if inst._fx == nil and not TheNet:IsDedicated() then
        inst._fx = SpawnFX()
        inst._fx.entity:SetParent(inst.entity)
        inst:ListenForEvent("animdirty", OnAnimDirty)
    end

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoPeriodicTask(FRAMES, OnUpdateFX, nil, inst._data)

    DeserializeFX(inst, inst._data)
    PushFXParams(inst, inst._data)
end

local function InitFX(inst, hutch, data)
    SerializeFX(inst, data, false)
    inst:ListenForEvent("newstate", function(hutch, data)
        local animid = STATE_ID[data.statename]
        if animid ~= nil then
            inst._anim:set(animid)
        end
    end, hutch)
    local animid = STATE_ID[hutch.sg.currentstate.name]
    if animid ~= nil then
        inst._anim:set(animid)
    end
end

local function hutch_music_light_fx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst._rot = net_shortint(inst.GUID, "hutch_music_light_fx._rot", "fxdirty")
    inst._rotrate = net_tinybyte(inst.GUID, "hutch_music_light_fx._rotrate", "fxdirty")
    inst._alpha = net_byte(inst.GUID, "hutch_music_light_fx._alpha", "fxdirty")
    inst._alphadir = net_bool(inst.GUID, "hutch_music_light_fx._alphadir", "fxdirty")
    inst._alpharate = net_smallbyte(inst.GUID, "hutch_music_light_fx._alpharate", "fxdirty")
    inst._anim = net_tinybyte(inst.GUID, "hutch_music_light_fx._anim", "animdirty")
    inst._anim:set(STATE_ID["idle"])

    inst._fx = nil
    inst._task = nil
    inst._data = {}
    inst:ListenForEvent("fxdirty", OnFXDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.InitFX = InitFX

    inst.persists = false

    return inst
end

return Prefab("hutch", create_hutch, assets, prefabs),
    Prefab("hutch_music_light_fx", hutch_music_light_fx, light_assets)
