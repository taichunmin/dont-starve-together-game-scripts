local assets =
{
    Asset("ANIM", "anim/resurrection_stone.zip"),
    Asset("ANIM", "anim/resurrection_stone_fx.zip"),
    Asset("MINIMAP_IMAGE", "resurrection_stone"),
}

local prefabs =
{
    "rocks",
    "marble",
    "nightmarefuel",
}

local COOLDOWN = 20 --delay between uses by different players
local TIMEOUT = 10 --in case resurrection starts but never completes

local function OnTimeout(inst)
    --In case haunt starts, but resurrection never activates
    --Could happen if player disconnects during resurrection
    inst._task = nil
    if inst.AnimState:IsCurrentAnimation("resurrect") or
        inst.AnimState:IsCurrentAnimation("idle_broken") then
        inst.AnimState:PlayAnimation("repair")
        inst.AnimState:PushAnimation("idle_activate", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
        inst._enablelights:set(true)
    end
end

local function OnHaunt(inst, haunter)
    if inst._task == nil and
        haunter:CanUseTouchStone(inst) and
        inst.AnimState:IsCurrentAnimation("idle_activate") then
        inst.AnimState:PlayAnimation("resurrect")
        inst.AnimState:PushAnimation("idle_broken", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_break")
        inst._enablelights:set(false)
        inst._task = inst:DoTaskInTime(TIMEOUT, OnTimeout)
        return true
    end
end

local function OnStartCharging(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_off") then
        inst.AnimState:PlayAnimation("idle_off", false)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        inst._enablelights:set(false)

        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)

        if inst.components.hauntable ~= nil then
            inst:RemoveComponent("hauntable")
        end
    end
end

local function HasPhysics(obj)
    return obj.Physics ~= nil
end

local CHANGED_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost", "ghost", "flying" }
local function OnCharged(inst)
    if inst.AnimState:IsCurrentAnimation("idle_off") then
        local x, y, z = inst.Transform:GetWorldPosition()
        if FindEntity(inst, inst:GetPhysicsRadius(0), HasPhysics, nil, CHANGED_CANT_TAGS) ~= nil then
            --Something is on top of us
            --Reschedule regenration...
            inst.components.cooldown:StartCharging(math.random(5, 8))
            return
        end

        inst.AnimState:PlayAnimation("activate")
        inst.AnimState:PushAnimation("idle_activate", false)
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.AnimState:SetSortOrder(0)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
        inst._enablelights:set(true)
    end
end

local function OnAnimOver(inst)
    if inst.components.hauntable == nil and
        inst.AnimState:IsCurrentAnimation("idle_activate") then
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
        inst.components.hauntable:SetOnHauntFn(OnHaunt)
    end
end

local function OnActivateResurrection(inst, guy)
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
    TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_break")
    inst.components.lootdropper:DropLoot()
    inst.components.cooldown:StartCharging()
    guy:PushEvent("usedtouchstone", inst)
end

-------------------------------------------------------------------------------
--Client-side functions, don't mix logic with server-side functions above

local LIGHT_ANIM_PRE = "idle_pre"
local LIGHT_ANIM_PST = "idle_pst"
local LIGHT_ANIM_LOOP =
{
    "idle_activate",
}

local function OnLightAnimOver(inst)
    if inst._end then
        if not inst.entity:IsVisible() or inst.AnimState:IsCurrentAnimation(LIGHT_ANIM_PST) then
            inst:Remove()
        else
            inst.AnimState:PlayAnimation(LIGHT_ANIM_PST, false)
        end
    elseif inst._parent.AnimState:IsCurrentAnimation("idle_activate") then
        if inst.entity:IsVisible() then
            --randomize
            inst.AnimState:PlayAnimation(LIGHT_ANIM_LOOP[math.random(#LIGHT_ANIM_LOOP)], false)
        else
            inst.AnimState:PlayAnimation(LIGHT_ANIM_PRE, false)
            inst:Show()
        end
    elseif not inst.entity:IsVisible() then
        inst:DoTaskInTime(1, OnLightAnimOver)
    elseif inst.AnimState:IsCurrentAnimation(LIGHT_ANIM_PST) then
        inst:Hide()
    else
        inst.AnimState:PlayAnimation(LIGHT_ANIM_PST, false)
    end
end

local function EndLight(inst)
    inst._end = true
    if not inst.entity:IsVisible() then
        inst:Remove()
    end
end

local function CreateLight(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("resurrection_stone_fx")
    inst.AnimState:SetBuild("resurrection_stone_fx")
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:Hide()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:SetParent(parent.entity)
    inst._parent = parent

    inst._end = false
    inst:ListenForEvent("animover", OnLightAnimOver)
    OnLightAnimOver(inst)

    inst.EndLight = EndLight

    return inst
end

local function TryRandomLightFX(inst)
    inst._lighttask = nil

    if inst._lightplayer:CanUseTouchStone(inst) then
        if inst.AnimState:IsCurrentAnimation("idle_activate") then
            inst._lightfx = CreateLight(inst)
        else
            inst._lighttask = inst:DoTaskInTime(.8 + math.random() * .4, TryRandomLightFX)
        end
    end
end

local function OnSleep(inst)
    if inst._lightplayer ~= nil then
        inst:RemoveEventCallback("ghostvision", inst._onghostvision, inst._lightplayer)
    end
    if inst._lighttask ~= nil then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    if inst._lightfx ~= nil then
        inst._lightfx:Remove()
        inst._lightfx = nil
    end
end

local function OnWake(inst)
    if inst._lightplayer ~= nil then
        inst:ListenForEvent("ghostvision", inst._onghostvision, inst._lightplayer)
        inst._onghostvision(inst._lightplayer, inst._lightplayer.components.playervision:HasGhostVision())
    end
end

local function OnEnableLightsDirty(inst)
    if inst._enablelights:value() then
        inst.OnEntitySleep = OnSleep
        inst.OnEntityWake = OnWake
        if not inst:IsAsleep() then
            OnWake(inst)
        end
    else
        inst.OnEntitySleep = nil
        inst.OnEntityWake = nil
        OnSleep(inst)
    end
end

local function SetupLights(inst)
    inst._lightplayer = nil
    inst._lighttask = nil
    inst._lightfx = nil

    inst._onghostvision = function(player, ghostvision)
        if ghostvision then
            if inst._lighttask == nil and inst._lightfx == nil then
                --In case we need to wait for _touchstoneid initial sync
                --Also staggers the FX if multiple stones are nearby
                inst._lighttask = inst:DoTaskInTime(math.random() * .5, TryRandomLightFX)
            end
        else
            if inst._lighttask ~= nil then
                inst._lighttask:Cancel()
                inst._lighttask = nil
            end
            if inst._lightfx ~= nil then
                inst._lightfx:EndLight()
                inst._lightfx = nil
            end
        end
    end

    local function OnPlayerDeactivated(world, player)
        if inst._lightplayer == player then
            inst._lightplayer = nil
            inst:RemoveEventCallback("enablelightsdirty", OnEnableLightsDirty)
            OnEnableLightsDirty(inst)
        end
    end

    local function OnPlayerActivated(world, player)
        if inst._lightplayer ~= player then
            if inst._lightplayer ~= nil then
                OnPlayerDeactivated(world, inst._lightplayer)
            end
            inst._lightplayer = player
            inst:ListenForEvent("enablelightsdirty", OnEnableLightsDirty)
            if inst._enablelights:value() then
                OnEnableLightsDirty(inst)
            end
        end
    end

    inst:ListenForEvent("playeractivated", OnPlayerActivated, TheWorld)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, TheWorld)

    if ThePlayer ~= nil then
        OnPlayerActivated(TheWorld, ThePlayer)
    end
end

-------------------------------------------------------------------------------

local NEXT_ID = 1
local USED_IDS = {}

local function SetTouchStoneID(inst, id)
    if id > 0 then
        if USED_IDS[id] then
            print("Duplicate Touch Stone ID: "..tostring(id))
        end
        inst._touchstoneid:set(id)
        USED_IDS[id] = true
    end
end

local function GetTouchStoneID(inst)
    return inst._touchstoneid:value()
end

local function OnSave(inst, data)
    data.touchstoneid = inst._touchstoneid:value()
end

local function OnLoad(inst, data)
    if data ~= nil and data.touchstoneid ~= nil then
        SetTouchStoneID(inst, data.touchstoneid)
    end
end

local function OnInit(inst)
    if TheWorld.ismastersim then
        if inst._touchstoneid:value() <= 0 then
            while USED_IDS[NEXT_ID] do
                NEXT_ID = NEXT_ID + 1
            end

            if NEXT_ID < 64 then
                SetTouchStoneID(inst, NEXT_ID)
                NEXT_ID = NEXT_ID + 1
            else
                print("Too many touchstones!")
            end
        end
    end

    if not TheNet:IsDedicated() then
        SetupLights(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.AnimState:SetBank("resurrection_stone")
    inst.AnimState:SetBuild("resurrection_stone")
    inst.AnimState:PlayAnimation("idle_activate", false)
    inst.AnimState:SetLayer(LAYER_WORLD)
    inst.AnimState:SetSortOrder(0)

    inst.MiniMapEntity:SetIcon("resurrection_stone.png")

    inst:AddTag("resurrector")
    inst:AddTag("antlion_sinkhole_blocker")

    inst._touchstoneid = net_smallbyte(inst.GUID, "resurrectionstone._touchstoneid")
    inst._enablelights = net_bool(inst.GUID, "resurrectionstone._enablelights", "enablelightsdirty")
    inst._enablelights:set(true)
    inst.GetTouchStoneID = GetTouchStoneID

    inst.scrapbook_anim = "idle_activate"

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(320)
    end

    inst.entity:SetPristine()

    inst:DoTaskInTime(0, OnInit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "rocks", "rocks", "marble", "nightmarefuel", "marble" })

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = COOLDOWN
    inst.components.cooldown.onchargedfn = OnCharged
    inst.components.cooldown.startchargingfn = OnStartCharging
    inst.components.cooldown.charged = true

    inst._task = nil

    inst:ListenForEvent("animover", OnAnimOver)
    inst:ListenForEvent("activateresurrection", OnActivateResurrection)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    MakeRoseTarget_CreateFuel(inst)

    return inst
end

return Prefab("resurrectionstone", fn, assets, prefabs)
