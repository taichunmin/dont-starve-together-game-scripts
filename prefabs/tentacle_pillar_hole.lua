local assets =
{
    Asset("ANIM", "anim/tentacle_pillar.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
    Asset("MINIMAP_IMAGE", "tentacle_pillar"),
}

local prefabs =
{
    "tentacle_pillar",
}

local function DoEmerge(inst)
    local other = inst.components.teleporter.targetTeleporter
    local x, y, z = inst.Transform:GetWorldPosition()

    inst:Remove()

    inst = SpawnPrefab("tentacle_pillar")
    inst.Transform:SetPosition(x, y, z)
    inst:OnEmerge()
    if other ~= nil then
        inst.components.teleporter:Target(other)
        other.components.teleporter:Target(inst)
        if other.prefab == "tentacle_pillar_hole" then
            DoEmerge(other)
        end
    end
end

local function TryEmerge(inst)
    if not (inst.components.teleporter:IsBusy() or
            inst.components.teleporter:IsTargetBusy()) and
        inst.emergetime <= GetTime() then
        DoEmerge(inst)
    end
end

local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)
        AwardPlayerAchievement("tentacle_pillar_hole_used", doer)

        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end

        --Sounds are triggered in player's stategraph
    elseif inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/cave/tentapiller_hole_throw_item")
    end
end

local function StartTravelSound(inst, doer)
    inst.SoundEmitter:PlaySound("dontstarve/cave/tentapiller_hole_enter")
    doer:PushEvent("wormholetravel", WORMHOLETYPE.TENTAPILLAR) --Event for playing local travel sound
end

local function OnDoneTeleporting(inst, obj)
    if inst.emergetask ~= nil then
        inst.emergetask:Cancel()
    end

    inst.SoundEmitter:PlaySound("dontstarve/cave/tentapiller_hole_travel_emerge")

    inst.emergetask = inst:DoTaskInTime(1.5, TryEmerge)

    if obj ~= nil and obj:HasTag("player") then
        obj:DoTaskInTime(1, obj.PushEvent, "wormholespit") -- for wisecracker
    end
end

local function OnAccept(inst, giver, item)
    inst.components.inventory:DropItem(item)
    inst.components.teleporter:Activate(item)
end

local function OnLongUpdate(inst, dt)
    inst.emergetime = inst.emergetime - dt
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnSave(inst, data)
    data.emergetime = inst.emergetime > GetTime() and inst.emergetime - GetTime() or nil
end

local function OnLoad(inst, data)
    inst.emergetime = (data ~= nil and data.emergetime ~= nil and data.emergetime or 0) + GetTime()
end

local function OnLoadPostPass(inst)
    local other = inst.components.teleporter.targetTeleporter
    if other ~= nil and other.prefab == "tentacle_pillar" then
        other:OnLoadPostPass()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, 2, 24)

    -- HACK: this should really be in the c side checking the maximum size of the anim or the _current_ size of the anim instead
    -- of frame 0
    inst.entity:SetAABB(60, 20)

    inst:AddTag("tentacle_pillar")
    inst:AddTag("rocky")
    inst:AddTag("wet")

    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    inst.MiniMapEntity:SetIcon("tentacle_pillar.png")

    inst.AnimState:SetBank("tentaclepillar")
    inst.AnimState:SetBuild("tentacle_pillar")
    inst.AnimState:PlayAnimation("idle_hole")

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --------------------
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 30)
    inst.components.playerprox:SetOnPlayerNear(TryEmerge)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)

    --------------------
    inst:AddComponent("inspectable")

    --------------------
    inst:AddComponent("teleporter")
    inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.offset = 0
    inst:ListenForEvent("starttravelsound", StartTravelSound) -- triggered by player stategraph
    inst:ListenForEvent("doneteleporting", OnDoneTeleporting)

    --------------------
    inst:AddComponent("inventory")
    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = OnAccept
    inst.components.trader.deleteitemonaccept = false

    --------------------

    inst.emergetime = GetTime() + TUNING.TENTACLE_PILLAR_ARM_EMERGE_TIME

    inst.OnLongUpdate = OnLongUpdate
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("tentacle_pillar_hole", fn, assets, prefabs)
