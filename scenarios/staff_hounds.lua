
local TRAP_MUST_TAGS = { "hound" }
local TRAP_CANT_TAGS = { "pet_hound", "INLIMBO" }
local function settrap_hounds(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local staff_hounds = {}
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 20, TRAP_MUST_TAGS, TRAP_CANT_TAGS)) do
        if v ~= nil and v.sg ~= nil then
            v.components.sleeper.hibernate = true
            v.sg:GoToState("forcesleep")
            table.insert(staff_hounds, v)
        end
    end
    return staff_hounds
end

local function IsValidHound(hound)
    return hound:IsValid()
        and not hound:IsInLimbo()
        and not (hound.components.health ~= nil and hound.components.health:IsDead())
        and hound.entity:IsVisible()
end

local function WakeHound(inst, hound)
    if IsValidHound(hound) and hound.sg ~= nil and hound.sg:HasState("wake") then
        hound.sg:GoToState("wake")
    end
end

local function TriggerTrap(inst, scenariorunner, data, hounds)
    --Here we wake the dogs up if they exist then stop waiting to spring the trap.
    local player = data.player
    if player ~= nil and player.components.sanity ~= nil then
        player.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    end
    TheWorld:PushEvent("ms_forceprecipitation", true)
    for i, v in ipairs(hounds) do
        if IsValidHound(v) then
            if v.components.sleeper ~= nil then
                v.components.sleeper.hibernate = false
            end
            inst:DoTaskInTime(math.random(1, 3), WakeHound, v)
        end
    end
    scenariorunner:ClearScenario()
end

local function OnLoad(inst, scenariorunner)
    local hounds = settrap_hounds(inst)
    inst.scene_putininventoryfn = function(inst, owner)
        TriggerTrap(
            inst,
            scenariorunner,
            { player = owner ~= nil and owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner },
            hounds
        )
    end
    inst:ListenForEvent("onputininventory", inst.scene_putininventoryfn)
end

local function OnDestroy(inst)
    if inst.scene_putininventoryfn ~= nil then
        inst:RemoveEventCallback("onputininventory", inst.scene_putininventoryfn)
        inst.scene_putininventoryfn = nil
    end
end

return
{
    OnLoad = OnLoad,
    OnDestroy = OnDestroy,
}
