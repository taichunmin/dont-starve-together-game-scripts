local assets =
{
    Asset("ANIM", "anim/teleporter_worm.zip"),
    Asset("ANIM", "anim/teleporter_sickworm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("MINIMAP_IMAGE", "wormhole_sick"),
}

local function onsave(inst, data)
    data.usesleft = inst.usesleft > 0 and inst.usesleft or nil
end

local function onload(inst, data)
    inst.usesleft = data ~= nil and data.usesleft or 0
end

local function OnDoneTeleporting(inst, obj)
    if inst.closetask ~= nil then
        inst.closetask:Cancel()
    end
    inst.closetask = inst:DoTaskInTime(1.5, function()
        if not inst.components.teleporter:IsBusy() then
            if inst.usesleft <= 0 then
                if inst.components.teleporter:IsTargetBusy() then
                    inst.sg:GoToState("closing")
                else
                    local other = inst.components.teleporter.targetTeleporter
                    if other ~= nil then
                        if other:IsAsleep() then
                            other:Remove()
                        else
                            other.persists = false
                            other.sg:GoToState("death")
                        end
                    end
                    if inst:IsAsleep() then
                        inst:Remove()
                    else
                        inst.sg:GoToState("death")
                    end
                end
            elseif not inst.components.playerprox:IsPlayerClose() then
                inst.sg:GoToState("closing")
            end
        end
    end)

    if obj ~= nil and obj:HasTag("player") then
        obj:DoTaskInTime(1, obj.PushEvent, "wormholespit") -- for wisecracker
    end
end

local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        ProfileStatsSet("wormhole_ltd_used", true)

        local other = inst.components.teleporter.targetTeleporter
        if other ~= nil then
            DeleteCloseEntsWithTag({"WORM_DANGER"}, other, 15)
        end

        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
        end

        if inst.usesleft > 1 and (other == nil or other.usesleft > 1) then
            inst.usesleft = inst.usesleft - 1
            if other ~= nil then
                other.usesleft = other.usesleft - 1
            end
        else
            inst.usesleft = 0
            inst.persists = false
            inst.components.teleporter:SetEnabled(false)
            inst.components.trader:Disable()
            if other ~= nil then
                other.usesleft = 0
                other.persists = false
                other.components.teleporter:SetEnabled(false)
                other.components.trader:Disable()
            end
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
    ProfileStatsSet("wormhole_ltd_accept_item", item.prefab)
    inst.components.inventory:DropItem(item)
    inst.components.teleporter:Activate(item)
end

local function StartTravelSound(inst, doer)
    inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
    doer:PushEvent("wormholetravel", WORMHOLETYPE.WORM) --Event for playing local travel sound
end

local function makewormhole(uses)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon("wormhole_sick.png")

        inst.AnimState:SetBank("teleporter_worm")
        inst.AnimState:SetBuild("teleporter_sickworm_build")
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        --trader, alltrader (from trader component) added to pristine state for optimization
        inst:AddTag("trader")
        inst:AddTag("alltrader")

        inst:AddTag("antlion_sinkhole_blocker")

        inst:SetPrefabNameOverride("wormhole_limited")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.usesleft = uses

        inst:SetStateGraph("SGwormhole_limited")

        inst:AddComponent("inspectable")
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

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab("wormhole_limited_"..uses, fn, assets)
end

return makewormhole(1)
