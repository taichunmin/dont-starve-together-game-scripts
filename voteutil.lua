--[[ Vote utility functions for use in defining user vote commands ]]--

--------------------------------------------------------------------------
--User commands 'voteresultfn' property:
--Required for tallying vote counts to determine the winning result

--voteresults table:
--  total_not_voted  : total abstains after time runs out
--  total_voted      : total votes after everyone votes or time runs out
--  total            : total voters (includes voted and abstained)
--  options[1]       : 'Yes' vote count
--  options[2]       : 'No' vote count

--NOTE: If there is a target user who does not get to vote,
--      that user will not be included in any of the counts

--NOTE: Do not need to validate min player count again

local function DefaultUnanimousVote(params, voteresults)
    local result, count
    for i, v in ipairs(voteresults.options) do
        if v > 0 then
            if result ~= nil then
                return --Not unanimous
            end
            result = i
            count = v
        end
    end
    return result, count
end

local function DefaultMajorityVote(params, voteresults)
    local result, count = nil, 0
    for i, v in ipairs(voteresults.options) do
        if v > count then
            result = i
            count = v
        elseif v == count then
            result = nil
        end
    end
    return result, result ~= nil and count or nil
end

local function YesNoUnanimousVote(params, voteresults)
    local result, count = DefaultUnanimousVote(params, voteresults)
    if result == 1 then
        --Only return 'Yes' results
        return result, count
    end
end

local function YesNoMajorityVote(params, voteresults)
    local result, count = DefaultMajorityVote(params, voteresults)
    if result == 1 then
        --Only return 'Yes' results
        return result, count
    end
end

--------------------------------------------------------------------------
--User commands 'votecanstartfn' property:
--Optional custom checks for whether a vote can start or not

--NOTE: Do not need to validate min player count again
--NOTE: Logic MUST be VALID ON CLIENTS!

--e.g. For votes that you don't want to start at night:

--function CannotStartVoteAtNight(command, caller, targetid)
--    if TheWorld.state.isnight then --this check is valid on clients
--        return false, "NIGHT" --custom fail reason, used for UI tooltip
--    end
--    return true, nil
--end

--Optional tooltip string for the fail reason:
--STRINGS.UI.PLAYERSTATUSSCREEN.VOTECANNOTSTART["NIGHT"] = "Can't start a vote at night."

local function DefaultCanStartVote(command, caller, targetid)
    return true, nil
end

--------------------------------------------------------------------------
return
{
    --voteresultfn:
    DefaultUnanimousVote = DefaultUnanimousVote,
    DefaultMajorityVote = DefaultMajorityVote,
    YesNoUnanimousVote = YesNoUnanimousVote,
    YesNoMajorityVote = YesNoMajorityVote,

    --votecanstartfn:
    DefaultCanStartVote = DefaultCanStartVote,
}
