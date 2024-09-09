local function FindGraves(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20)
    local grave_mounds = {}
    for k,v in pairs(ents) do
        if v:HasTag("grave") and v.mound then
            grave_mounds[v.mound] = v.mound
        end
    end

    return grave_mounds
end

local function SpawnGhostsOnGraves(graves, scenariorunner, data)
    local player = data.owner
    local settarget = function(inst, player)
        if inst and inst.brain then
            inst.brain.followtarget = player
        end
    end
    for k,v in pairs(graves) do
        local ghost = SpawnPrefab("ghost")
        ghost.Transform:SetPosition(v.Transform:GetWorldPosition())
        ghost:DoTaskInTime(1, settarget, player)
    end
end

local function OnLoad(inst, scenariorunner)
    inst.moundlist = FindGraves(inst)
    inst.scene_pickupfn = function(oninst, data)
        SpawnGhostsOnGraves(inst.moundlist, scenariorunner, data)
        scenariorunner:ClearScenario()
    end
    inst:ListenForEvent("onpickup", inst.scene_pickupfn)
end

local function OnDestroy(inst)
    if inst.scene_pickupfn then
        inst:RemoveEventCallback("onpickup", inst.scene_pickupfn)
        inst.scene_pickupfn = nil
    end
end

return
{
    OnLoad = OnLoad,
    OnDestroy = OnDestroy,
}
