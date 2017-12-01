local assets =
{
    Asset("ANIM", "anim/portal_stone.zip"),
    Asset("MINIMAP_IMAGE", "portal_dst"),
}

local function GetVerb()
    return STRINGS.ACTIONS.ACTIVATE.GENERIC
end

local function OnRezPlayer(inst)
    inst.sg:GoToState("spawn_pre")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    local gamemode = TheNet:GetServerGameMode()
    if not GetIsSpawnModeFixed(gamemode) then
        inst.entity:Hide()
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("portal_dst.png")

    inst.AnimState:SetBank("portal_dst")
    inst.AnimState:SetBuild("portal_stone")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("antlion_sinkhole_blocker")

    inst:SetDeployExtraSpacing(2)

    inst.GetActivateVerb = GetVerb

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGmultiplayerportal")

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    if GetPortalRez(gamemode) then
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
        inst:AddTag("resurrector")
    end

    inst:ListenForEvent("ms_newplayercharacterspawned", function(world, data) 
        if data and data.player then
            data.player.AnimState:SetMultColour(0,0,0,1)
            data.player:Hide()
            data.player.components.playercontroller:Enable(false)
            data.player:DoTaskInTime(12*FRAMES, function(inst) 
                data.player:Show()
                data.player:DoTaskInTime(60*FRAMES, function(inst)
                    inst.components.colourtweener:StartTween({1,1,1,1}, 14*FRAMES, function(inst)
                        data.player.components.playercontroller:Enable(true)
                    end)
                end)
            end)
        end
        inst.sg:GoToState("spawn_pre") 
    end, TheWorld)

    inst:ListenForEvent("rez_player", OnRezPlayer)

    return inst
end

return Prefab("multiplayer_portal", fn, assets)
