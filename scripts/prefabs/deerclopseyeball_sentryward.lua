local sentryward_assets =
{
    Asset("ANIM", "anim/deerclopseyeball_sentryward.zip"),
    Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("MINIMAP_IMAGE", "deerclopseyeball_sentryward_enabled"),
    Asset("MINIMAP_IMAGE", "deerclopseyeball_sentryward_disabled"),
}

local fx_assets =
{
    Asset("ANIM", "anim/deer_ice_circle.zip"),
}

local sentryward_prefabs =
{
    "collapse_small",
    "globalmapicon",
    "deerclops_eyeball",
    "deerclopseyeball_sentryward_fx",
    "deerclopseyeball_sentryward_kit",
    "deerclopseyeball_sentryward_kit_placer",
    "rock_ice",
    "rock_ice_temperature",
}

local fx_prefabs =
{

}

local ICE_SOUNDNAME = "ice_spawn"
local AMB_SOUNDNAME = "amb"

---------------------------------------------------------------------------------------------------------------

local SENTRYWARD_SCALE = 1.3
local DEPLOYHELPER_SCALE = 1/SENTRYWARD_SCALE

local EYEBALL_FACE_PLAYER_TASK_PERIOD = 1

local BLOOMED_SYMBOLS_MULTCOLOUR = {0.7, 0.7, 0.7, 1}

local LIGHT_PARAMS =
{
    ON =
    {
        radius = 1.5,
        intensity = .6,
        falloff = .6,
        colour = {237/255, 237/255, 209/255},
        time = 1.5,
    },
    OFF =
    {
        radius = 0,
        intensity = 0,
        falloff = 0.6,
        colour = { 0, 0, 0 },
        time = 1,
    },
}

---------------------------------------------------------------------------------------------------------------

local CIRCLE_RADIUS_SCALE = 1888 / 150 / 2 -- Source art size / anim_scale / 2 (halved to get radius).

local function CreateHelperRadiusCircle()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    local scale = TUNING.DEERCLOPSEYEBALL_SENTRYWARD_RADIUS / CIRCLE_RADIUS_SCALE -- Convert to rescaling for our desired range.

    inst.AnimState:SetScale(scale, scale)

    -- NOTE(DiogoW): We are fighting against the parent's scale, which is considerably non-optimal...
    inst.Transform:SetScale(DEPLOYHELPER_SCALE, DEPLOYHELPER_SCALE, DEPLOYHELPER_SCALE)

    return inst
end

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateHelperRadiusCircle()

            inst.helper.entity:SetParent(inst.entity)
        end

    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

---------------------------------------------------------------------------------------------------------------

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")

    if inst.components.inventoryitemholder ~= nil then
        inst.components.inventoryitemholder:TakeItem()
    end

    inst:Remove()
end

local function OnHit(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation(inst._active:value() and "idle_full_loop" or "idle_loop", true)

    inst._onhit:push()
    inst:PlayEyeballHitAnim()
end

local function OnBuilt(inst)
    inst.SoundEmitter:PlaySound("rifts3/oculus_ice_radius/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_loop", false)
end

---------------------------------------------------------------------------------------------------------------

local function CreateGlobalIcon(inst)
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon.MiniMapEntity:SetIsFogRevealer(true)
    inst.icon:AddTag("fogrevealer")
    inst.icon:TrackEntity(inst)
end

local function OnEyeballGiven(inst, item, giver)
    if not POPULATING then
        inst.SoundEmitter:PlaySound("rifts3/oculus_ice_radius/eyeball_place")
    end

    inst.SoundEmitter:PlaySound("rifts3/oculus_ice_radius/ambient_lp", AMB_SOUNDNAME)

    inst.components.temperatureoverrider:Enable()

    inst.MiniMapEntity:SetIcon("deerclopseyeball_sentryward_enabled.png")

    inst._active:set(true)
    inst:OnActiveDirty()

    inst.AnimState:SetLightOverride(0.1)

    inst.AnimState:Show("crystal_hand_ice")

    inst.AnimState:SetSymbolLightOverride("crystal_hand", 0.4)
    inst.AnimState:SetSymbolLightOverride("base_crystal", 0.2)

    inst.AnimState:PlayAnimation("place_eyeball")
    inst.AnimState:PushAnimation("idle_full_loop", true)

    if inst.ice == nil then
        inst.ice = SpawnPrefab("deerclopseyeball_sentryward_fx")
        inst.ice.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    inst.components.maprevealer:Start()
    inst.components.periodicspawner:SafeStart()

    if inst.icon == nil then
        inst:DoTaskInTime(0, inst.CreateGlobalIcon)
    end
end

local function TurnLightOffCallback(inst)
    if TheWorld.ismastersim then
        inst.Light:Enable(false)
    end
end

local function OnEyeballTaken(inst, item, taker)
    inst.SoundEmitter:KillSound(AMB_SOUNDNAME)

    inst.components.temperatureoverrider:Disable()

    inst.MiniMapEntity:SetIcon("deerclopseyeball_sentryward_disabled.png")

    inst._active:set(false)
    inst:OnActiveDirty()

    inst.AnimState:SetLightOverride(0)

    inst.AnimState:Hide("crystal_hand_ice")

    inst.AnimState:SetSymbolLightOverride("crystal_hand", 0)
    inst.AnimState:SetSymbolLightOverride("base_crystal", 0)

    inst.AnimState:PlayAnimation("idle_loop", false)

    if inst.ice ~= nil then
        inst.ice:KillFX()
        inst.ice = nil
    end

    inst.components.maprevealer:Stop()
    inst.components.periodicspawner:Stop()

    if inst.icon ~= nil then
        inst.icon:Remove()
        inst.icon = nil
    end
end

---------------------------------------------------------------------------------------------------------------

local function GetStatus(inst)
    return not inst._active:value() and "NOEYEBALL" or nil
end

local function OnRemoveEntity(inst)
    if inst.ice ~= nil then
        inst.ice:KillFX()
    end
end

---------------------------------------------------------------------------------------------------------------

local function CLIENT_EyeballFacePlayer(inst)
    if ThePlayer ~= nil and ThePlayer:IsValid() then
        inst:ForceFacePoint(ThePlayer.Transform:GetWorldPosition())
    end
end

local function CLIENT_PlayEyeballHitAnim(inst)
    if inst.eyeball ~= nil then
        inst.eyeball.AnimState:PlayAnimation("hit")
        inst.eyeball.AnimState:PushAnimation("idle_eyeball_loop", true)
    end
end

local function CLIENT_CreateEyeball(inst)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
        inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    if PostProcessor == nil or PostProcessor:IsBloomEnabled() then
        inst.AnimState:SetMultColour(unpack(BLOOMED_SYMBOLS_MULTCOLOUR))
    end

    inst.Transform:SetFourFaced()

    inst.AnimState:SetFinalOffset(2)

    inst.AnimState:SetBank("deerclopseyeball_sentryward")
    inst.AnimState:SetBuild("deerclopseyeball_sentryward")
    inst.AnimState:PlayAnimation("place_eyeball", false)
    inst.AnimState:PushAnimation("idle_eyeball_loop", true)

    inst.AnimState:Hide("sentryward")
    inst.AnimState:Hide("grimmer")
    inst.AnimState:Hide("crystal_hand_ice")
    inst.AnimState:Hide("cold_fx")

    inst:AddTag("FX")

    inst.FacePlayer = CLIENT_EyeballFacePlayer
    inst._faceplayertask = inst:DoPeriodicTask(EYEBALL_FACE_PLAYER_TASK_PERIOD, inst.FacePlayer, 0)

    return inst
end

local function OnActiveDirty(inst)
    if inst._active:value() then
        local p = LIGHT_PARAMS.ON

        if TheWorld.ismastersim then
            inst.Light:Enable(true)
        end

        inst.components.lighttweener:StartTween(inst.Light, p.radius, p.intensity, p.falloff, p.colour, p.time)

        inst.AnimState:SetSymbolBloom("crystal_hand")
        inst.AnimState:SetSymbolBloom("base_crystal")

        if PostProcessor == nil or PostProcessor:IsBloomEnabled() then
            inst.AnimState:SetSymbolMultColour("crystal_hand", unpack(BLOOMED_SYMBOLS_MULTCOLOUR))
            inst.AnimState:SetSymbolMultColour("base_crystal", unpack(BLOOMED_SYMBOLS_MULTCOLOUR))
        end

        if not TheNet:IsDedicated() and inst.eyeball == nil then
            inst.eyeball = CLIENT_CreateEyeball()
            inst.eyeball.entity:SetParent(inst.entity)
            inst.highlightchildren = { inst.eyeball }
        end

        inst.MiniMapEntity:SetCanUseCache(false)
        inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    else
        local p = LIGHT_PARAMS.OFF

        inst.components.lighttweener:StartTween(inst.Light, p.radius, p.intensity, p.falloff, p.colour, p.time, TurnLightOffCallback)

        inst.AnimState:ClearSymbolBloom("crystal_hand")
        inst.AnimState:ClearSymbolBloom("base_crystal")

        inst.AnimState:SetSymbolMultColour("crystal_hand", 1, 1, 1, 1)
        inst.AnimState:SetSymbolMultColour("base_crystal", 1, 1, 1, 1)

        if inst.eyeball ~= nil then
            inst.eyeball:Remove()
            inst.eyeball = nil
            inst.highlightchildren = nil
        end

        inst.MiniMapEntity:SetCanUseCache(true)
        inst.MiniMapEntity:SetDrawOverFogOfWar(false)
    end
end

---------------------------------------------------------------------------------------------------------------

local function OnRockIceSpawned(spawner, ice)
    ice:SetStage("short")

    local scale = GetRandomMinMax(0.85, 1)
    ice.Transform:SetScale(scale, scale, scale)
end

local POSITION_CANT_TAGS = { "INLIMBO", "NOBLOCK", "FX" }
local IS_CLEAR_AREA_RADIUS = 2

local function IsValidPosition(pos)
    local x, y, z = pos:Get()

    return TheSim:CountEntities(x, 0, z, IS_CLEAR_AREA_RADIUS, nil, POSITION_CANT_TAGS) <= 0 and TheWorld.Map:IsSurroundedByLand(x, 0, z, 2)
end

local function GetRockIceSpawnPoint(inst)
    local pos = inst:GetPosition()
    local dist = GetRandomMinMax(5, TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_MAX_DENSITY_RAD)

    local offset = FindWalkableOffset(pos, math.random()*TWOPI, dist, 16, nil, nil, IsValidPosition)

    if offset ~= nil then
        return pos + offset
    end
end

---------------------------------------------------------------------------------------------------------------

local function sentrywardfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    local p = LIGHT_PARAMS.OFF

    inst.Light:Enable(false)
    inst.Light:SetFalloff(p.falloff)
    inst.Light:SetIntensity(p.intensity)
    inst.Light:SetRadius(p.radius)
    inst.Light:SetColour(unpack(p.colour))

    inst.Light:EnableClientModulation(true)

    inst.MiniMapEntity:SetIcon("deerclopseyeball_sentryward_disabled.png")

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
    MakeObstaclePhysics(inst, .1)

    inst.Transform:SetScale(SENTRYWARD_SCALE, SENTRYWARD_SCALE, SENTRYWARD_SCALE)

    inst.AnimState:SetBank("deerclopseyeball_sentryward")
    inst.AnimState:SetBuild("deerclopseyeball_sentryward")
    inst.AnimState:PlayAnimation("idle_loop", false)

    inst.AnimState:SetSymbolLightOverride("cold_fx", 0.5)
    inst.AnimState:SetSymbolLightOverride("SparkleBit", 1)

    --maprevealer (from maprevealer component) added to pristine state for optimization
    inst:AddTag("maprevealer")

    inst:AddTag("structure")

    inst.AnimState:Hide("eyeball")

    -- Dedicated server does not need deployhelper.
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst:AddComponent("lighttweener")

    -- Must be added client-side, but configured server-side.
    inst:AddComponent("temperatureoverrider")

    inst._active =  net_bool(inst.GUID, "deerclopseyeball_sentryward._active", "activedirty")
    inst._onhit  = net_event(inst.GUID, "deerclopseyeball_sentryward._onhit")

    inst.OnActiveDirty = OnActiveDirty
    inst.PlayEyeballHitAnim = CLIENT_PlayEyeballHitAnim

    inst._LIGHT_PARAMS = LIGHT_PARAMS -- Mods.

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("activedirty", inst.OnActiveDirty)
        inst:ListenForEvent("deerclopseyeball_sentryward._onhit", inst.PlayEyeballHitAnim)

        inst:DoTaskInTime(0, inst.OnActiveDirty)

        return inst
    end

    inst.scrapbook_anim = "hit"
    inst.scrapbook_animpercent = 1
    inst.scrapbook_hide = { "eyeball", "crystal_hand_ice" }

    inst.OnEyeballGiven = OnEyeballGiven
    inst.OnEyeballTaken = OnEyeballTaken
    inst.CreateGlobalIcon = CreateGlobalIcon

    inst.OnBuilt = OnBuilt
    inst:ListenForEvent("onbuilt", inst.OnBuilt)

    inst:AddComponent("maprevealer")
    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:AddComponent("inventoryitemholder")
    inst.components.inventoryitemholder:SetAllowedTags({ "deerclops_eyeball" })
    inst.components.inventoryitemholder:SetOnItemGivenFn(inst.OnEyeballGiven)
    inst.components.inventoryitemholder:SetOnItemTakenFn(inst.OnEyeballTaken)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("rock_ice_temperature")
    inst.components.periodicspawner:SetOnSpawnFn(OnRockIceSpawned)
    inst.components.periodicspawner:SetGetSpawnPointFn(GetRockIceSpawnPoint)
    inst.components.periodicspawner:SetRandomTimes(TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_SPAWN_BASETIME, TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_SPAWN_VARIANCE)
    inst.components.periodicspawner:SetMinimumSpacing(TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_MIN_SPACING)
    inst.components.periodicspawner:SetDensityInRange(TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_MAX_DENSITY_RAD, TUNING.DEERCLOPSEYEBALL_SENTRYWARD_ROCK_ICE_MAX_DENSITY)

    inst.components.temperatureoverrider:SetRadius(TUNING.DEERCLOPSEYEBALL_SENTRYWARD_RADIUS)
    inst.components.temperatureoverrider:SetTemperature(TUNING.DEERCLOPSEYEBALL_SENTRYWARD_TEMPERATURE_OVERRIDE)

    inst:OnEyeballTaken()

    -----------------------------

    inst.OnRemoveEntity = OnRemoveEntity

    MakeHauntableWork(inst)

    return inst
end

--------------------------------------------------------------------------------------------------------------------------

local function placer_postinit_fn(inst)
    local helper = CreateHelperRadiusCircle()

    inst.Transform:SetScale(SENTRYWARD_SCALE, SENTRYWARD_SCALE, SENTRYWARD_SCALE)

    helper.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(helper)
end

--------------------------------------------------------------------------------------------------------------------------

local function KillFX(inst)
    if not inst.killed then
        inst._radius = 0

        inst.killed = true
        inst.AnimState:PlayAnimation("pst")

        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + .25, inst.Remove)

        if inst._task ~= nil then
            inst._task:Cancel()
            inst._task = nil
        end
    end
end

local NOTAGS = { "playerghost", "INLIMBO", "flight", "invisible" }
for k, v in pairs(FUELTYPE) do
    table.insert(NOTAGS, v.."_fueled")
end

local FREEZETARGET_ONEOF_TAGS = { "heatrock", "freezable", "fire", "smolder" }
local function OnUpdateIceCircle(inst, x, z)
    inst._radius = inst._radius * .98 + TUNING.DEERCLOPSEYEBALL_SENTRYWARD_GROUND_ICE_RADIUS * .02

    for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst._radius, nil, NOTAGS, FREEZETARGET_ONEOF_TAGS)) do
        if v:IsValid() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            if v.components.burnable ~= nil and v.components.fueled == nil then
                v.components.burnable:Extinguish()
            end
            if v.components.freezable ~= nil then
                if not v.components.freezable:IsFrozen()
                    and v.components.freezable.coldness < v.components.freezable:ResolveResistance() * .7 then
                    v.components.freezable:AddColdness(.1, 1, true)
                end
            end
            if v.components.temperature ~= nil then
                local newtemp = math.max(v.components.temperature.mintemp, TUNING.DEER_ICE_TEMPERATURE)
                if newtemp < v.components.temperature:GetCurrent() then
                    v.components.temperature:SetTemperature(newtemp)
                end
            end
            if v.components.grogginess ~= nil and not v.components.grogginess:IsKnockedOut() then
                local curgrog = v.components.grogginess.grog_amount
                if curgrog < TUNING.DEER_ICE_FATIGUE then
                    v.components.grogginess:AddGrogginess(TUNING.DEER_ICE_FATIGUE)
                end
            end
        end
    end
end

local function OnInitIceCircle(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst._task = inst:DoPeriodicTask(0, OnUpdateIceCircle, nil, x, z)
    OnUpdateIceCircle(inst, x, z)
end

local function OnAnimOverIceCircle(inst)
    inst.SoundEmitter:KillSound(ICE_SOUNDNAME)
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    -- To be visually close to TUNING.DEERCLOPSEYEBALL_SENTRYWARD_GROUND_ICE_RADIUS.
    inst.Transform:SetScale(1.1, 1.1, 1.1)

    inst.AnimState:SetBank("deer_ice_circle")
    inst.AnimState:SetBuild("deer_ice_circle")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:SetFinalOffset(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._radius = POPULATING and TUNING.DEERCLOPSEYEBALL_SENTRYWARD_GROUND_ICE_RADIUS or 0.25

    inst.KillFX = KillFX
    inst.OnAnimOverIceCircle = OnAnimOverIceCircle

    inst._task = inst:DoTaskInTime(0, OnInitIceCircle)

    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/fx/ice_circle_LP", ICE_SOUNDNAME)
        inst.SoundEmitter:SetVolume(ICE_SOUNDNAME, 0.8)

        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + FRAMES, inst.OnAnimOverIceCircle)
    else
        inst.AnimState:SetFrame(inst.AnimState:GetCurrentAnimationNumFrames() - 1)
    end

    inst.persists = false

    return inst
end

local function Kit_CanDeployFn(inst, pt, mouseover, deployer, rot)
    return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsSurroundedByLand(pt.x, 0, pt.z, 3.5)
end

--------------------------------------------------------------------------------------------------------------------------

return
        Prefab("deerclopseyeball_sentryward", sentrywardfn, sentryward_assets, sentryward_prefabs),
        MakePlacer("deerclopseyeball_sentryward_kit_placer", "deerclopseyeball_sentryward", "deerclopseyeball_sentryward", "idle_loop", nil, nil, nil, nil, nil, nil, placer_postinit_fn),
        MakeDeployableKitItem("deerclopseyeball_sentryward_kit", "deerclopseyeball_sentryward", "deerclopseyeball_sentryward", "deerclopseyeball_sentryward", "kit", sentryward_assets, nil, nil, nil, {deploymode = DEPLOYMODE.CUSTOM, custom_candeploy_fn=Kit_CanDeployFn}),
        Prefab("deerclopseyeball_sentryward_fx", fxfn, fx_assets, fx_prefabs)
