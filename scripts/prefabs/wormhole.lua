local assets =
{
    Asset("ANIM", "anim/teleporter_worm.zip"),
    Asset("ANIM", "anim/teleporter_worm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local function GetStatus(inst)
    return inst.sg.currentstate.name ~= "idle" and "OPEN" or nil
end

local function OnDoneTeleporting(inst, obj)
    if inst.closetask ~= nil then
        inst.closetask:Cancel()
    end
    inst.closetask = inst:DoTaskInTime(1.5, function()
        if not (inst.components.teleporter:IsBusy() or
                inst.components.playerprox:IsPlayerClose()) then
            inst.sg:GoToState("closing")
        end
    end)

    if obj ~= nil and obj:HasTag("player") then
        obj:DoTaskInTime(1, obj.PushEvent, "wormholespit") -- for wisecracker
    end
end

local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)
        AwardPlayerAchievement("wormhole_used", doer)

        local other = inst.components.teleporter.targetTeleporter
        if other ~= nil then
            DeleteCloseEntsWithTag({"WORM_DANGER"}, other, 15)
        end

        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if doer.components.sanity ~= nil and not doer:HasTag("nowormholesanityloss") and not inst.disable_sanity_drain then
            doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
        end

        --Sounds are triggered in player's stategraph
    elseif inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
    end
end

local function OnActivateByOther(inst, source, doer)
    if not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function onnear(inst)
    if inst.components.teleporter:IsActive() and not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function onfar(inst)
    if not inst.components.teleporter:IsBusy() and inst.sg:HasStateTag("open") then
        inst.sg:GoToState("closing")
    end
end

local function onaccept(inst, giver, item)
    inst.components.inventory:DropItem(item)
    inst.components.teleporter:Activate(item)
end

local function StartTravelSound(inst, doer)
    inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
    doer:PushEvent("wormholetravel", WORMHOLETYPE.WORM) --Event for playing local travel sound
end

local function CanResidueBeSpawnedBy(inst, doer)
    local skilltreeupdater = doer and doer.components.skilltreeupdater or nil
    return skilltreeupdater and skilltreeupdater:IsActivated("winona_charlie_2") or false
end

local function OnResidueCreated(inst, residueowner, residue)
    local skilltreeupdater = residueowner.components.skilltreeupdater
    if skilltreeupdater and skilltreeupdater:IsActivated("winona_charlie_2") then
        residue:SetMapActionContext(CHARLIERESIDUE_MAP_ACTIONS.WORMHOLE)
    end
end

local function OnSave(inst, data)
	if inst.disable_sanity_drain then
		data.disable_sanity_drain = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.disable_sanity_drain then
		inst.disable_sanity_drain = true
	end
end

local function CreateHiddenGlobalIcon(inst)
    inst.hiddenglobalicon = SpawnPrefab("globalmapiconseeable")
    inst.hiddenglobalicon.MiniMapEntity:SetPriority(50) -- NOTES(JBK): This could be put to a constant for map actions that should go over everything as a reserved flag.
    inst.hiddenglobalicon.MiniMapEntity:SetRestriction("wormholetracker")
    inst.hiddenglobalicon:AddTag("wormholetrackericon")
    inst.hiddenglobalicon:TrackEntity(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics() -- no collision, this is just for buffered actions
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetSphere(1)

    inst.MiniMapEntity:SetIcon("wormhole.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetBank("teleporter_worm")
    inst.AnimState:SetBuild("teleporter_worm_build")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    inst:AddTag("antlion_sinkhole_blocker")

    inst:AddTag("wormhole")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGwormhole")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 5)
    inst.components.playerprox.onnear = onnear
    inst.components.playerprox.onfar = onfar

    inst:AddComponent("teleporter")
    inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.onActivateByOther = OnActivateByOther
    inst.components.teleporter.offset = 0
    inst:ListenForEvent("starttravelsound", StartTravelSound) -- triggered by player stategraph
    inst:ListenForEvent("doneteleporting", OnDoneTeleporting)

    inst:AddComponent("inventory")

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = onaccept
    inst.components.trader.deleteitemonaccept = false

    local roseinspectable = inst:AddComponent("roseinspectable")
	roseinspectable:SetCanResidueBeSpawnedBy(CanResidueBeSpawnedBy)
    roseinspectable:SetOnResidueCreated(OnResidueCreated)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    inst:DoTaskInTime(0, CreateHiddenGlobalIcon)

    return inst
end

return Prefab("wormhole", fn, assets)
