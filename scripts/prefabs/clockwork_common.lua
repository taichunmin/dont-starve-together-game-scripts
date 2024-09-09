
local SLEEP_DIST_FROMHOME_SQ = 1 * 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST_SQ = 40 * 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local CHARACTER_TAGS = {"character"}
local function _BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        or GetClosestInstWithTag(CHARACTER_TAGS, inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
        and not _BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or _BasicWakeCheck(inst)
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local CHESSFRIEND_RANGE_PERCENT = 0.5
local function Retarget(inst, range)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil

    return not (homePos ~= nil and
                inst:GetDistanceSqToPoint(homePos:Get()) >= range * range and
                (inst.components.follower == nil or inst.components.follower.leader == nil))
        and FindEntity(
            inst,
            range,
            function(guy)
                if myLeader == guy then
                    return false
                end
                if myLeader ~= nil and myLeader.isplayer and guy.isplayer then
                    return false  -- don't automatically attack other players, wait for the leader's insturctions
                end

                local theirLeader = (guy.components.follower ~= nil and guy.components.follower.leader) or nil
                local bothFollowingSamePlayer = (myLeader ~= nil and myLeader == theirLeader and myLeader.isplayer)
                if bothFollowingSamePlayer or (guy:HasTag("chess") and theirLeader == nil) then
                    return false
                end

                if not guy:IsNear(inst, range * CHESSFRIEND_RANGE_PERCENT) and guy:HasTag("chessfriend") then
                    return false
                end

                return inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
        or nil
end

local function KeepTarget(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (inst.components.follower ~= nil and inst.components.follower.leader ~= nil)
        or (homePos ~= nil and target:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ)
end

local function _ShareTargetFn(dude)
    return dude:HasTag("chess")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("chess") then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, _ShareTargetFn, MAX_TARGET_SHARES)
end

return {
    ShouldWake = ShouldWake,
    ShouldSleep = ShouldSleep,
    Retarget = Retarget,
    KeepTarget = KeepTarget,
    OnAttacked = OnAttacked,
}
