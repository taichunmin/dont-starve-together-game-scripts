------- A NOTE TO INDUSTRIOUS MODDERS --------
-- This system is pretty usable and there is already a mod interface for
-- adding your own commands. However, be aware of a few limitations:
--  1) Shards are not fully supported yet. Specific commands like Kick are
--     shard-aware, but other than that, only local commands or commands which
--     affect master-server components (like seasons.lua) will work correctly for now.
--  2) COMMAND_PERMISSION.MODERATOR doesn't actually do anything yet.
--
-- We would like to resolve these things soon, but until we do, those are the
-- limitations of this system.

local UserCommands = require("usercommands")
local VoteUtil = require("voteutil")

--------------------------------------------------------------------------
--NOTE: For the strings and string fmt properties, it's better
--      NOT to cache them here, when it comes to localization.

AddUserCommand("help", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.HELP.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.HELP.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = true,
    usermenu = false,
    servermenu = false,
    params = {"commandname"},
    paramsoptional = {true},
    vote = false,
    localfn = function(params, caller)
        if caller == nil or caller.HUD == nil then
            return
        end

        local s = {}

        if params.commandname == nil then
            table.insert(s, STRINGS.UI.BUILTINCOMMANDS.HELP.OVERVIEW)
            table.insert(s, STRINGS.UI.BUILTINCOMMANDS.HELP.AVAILABLE)
            local names = UserCommands.GetCommandNames()
            table.sort(names)
            table.insert(s, table.concat(names, ", "))
        else
            local command = UserCommands.GetCommandFromName(params.commandname)
            if command ~= nil and (command.hasaccessfn == nil or command.hasaccessfn(command, caller)) then
                local call = command.name
                local params = deepcopy(command.displayparams or command.params)
                for i,param in ipairs(params) do
                    if command.paramsoptional ~= nil and command.paramsoptional[i] == true then
                        params[i] = "["..param.."]"
                    else
                        params[i] = param
                    end
                end
                table.insert(s, ResolveCommandStringProperty(command, "prettyname", command.displayname or command.name))
                table.insert(s, string.format("/%s %s", command.displayname or command.name, table.concat(params, " ")))
                table.insert(s, ResolveCommandStringProperty(command, "desc", ""))
            else
                table.insert(s, string.format(STRINGS.UI.BUILTINCOMMANDS.HELP.NOTFOUND, params.commandname))
                local names = UserCommands.GetCommandNames()
                table.insert(s, STRINGS.UI.BUILTINCOMMANDS.HELP.AVAILABLE)
                table.sort(names)
                table.insert(s, table.concat(names, ", "))
            end
        end

        ChatHistory:SendCommandResponse(s)
    end,
})

AddUserCommand("emote", {
    aliases = { "e", "me" },
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.EMOTE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.EMOTE.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = true,
    usermenu = false,
    servermenu = false,
    params = {"emotename"},
    paramsoptional = {false},
    vote = false,
    localfn = function(params, caller)
        local trailing = params.rest or ""
        local command = trailing:len() <= 0 and UserCommands.GetCommandFromName(params.emotename) or nil
        if command ~= nil and
            command.emote and
            (command.hasaccessfn == nil or
            command.hasaccessfn(command, caller)) then
            UserCommands.RunUserCommand(params.emotename, {}, caller, false)
        elseif trailing:utf8len() <= MAX_CHAT_INPUT_LENGTH then
            --NOTE: whitespace already trimmed in all params
            TheNet:Say(trailing:len() > 0 and (params.emotename.." "..trailing) or params.emotename, true, true)
        end
    end,
})

AddUserCommand("bug", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = true,
    usermenu = false,
    servermenu = false,
    params = {},
    vote = false,
    localfn = function(params, caller)
        VisitURL("http://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together/")
    end,
})

AddUserCommand("rescue", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = true,
    usermenu = false,
    servermenu = true,
	menusort = 1,
    params = {},
    vote = false,
    serverfn = function(params, caller)
		if caller.PutBackOnGround ~= nil then
	        caller:PutBackOnGround()
		end
    end,
})

AddUserCommand("kick", {
    aliases = {"boot"},
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.KICK.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.KICK.DESC
    permission = COMMAND_PERMISSION.MODERATOR,
    confirm = true,
    slash = true,
    usermenu = true, -- automatically supplies the username as a param called "user"
    cantargetself = false,
    cantargetadmin = false,
    servermenu = false,
    params = {"user"},
    vote = true,
    votetimeout = 30,
    voteminstartage = 20,
    voteminpasscount = 3,
    votecountvisible = true,
    voteallownotvoted = true,
    voteoptions = nil, --default to { "Yes", "No" }
    votetitlefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.KICK.VOTETITLEFMT
    votenamefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.KICK.VOTENAMEFMT
    votecanstartfn = VoteUtil.DefaultCanStartVote,
    voteresultfn = VoteUtil.YesNoMajorityVote,
    localfn = function(params, caller)
        --NOTE: must support nil caller for voting
        if params.user ~= nil then
            TheNet:Kick(UserToClientID(params.user) or params.user, caller == nil and TUNING.VOTE_KICK_TIME or nil)
        end
    end,
})

local ban_info =
{
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BAN.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BAN.DESC
    permission = COMMAND_PERMISSION.ADMIN,
    confirm = true,
    slash = true,
    usermenu = true, -- automatically supplies the username as a param called "user"
    cantargetself = false,
    cantargetadmin = false,
    servermenu = false,
    params = {"user", "seconds"},
    paramsoptional = {false, true}, -- NOTE: all non-optional commands must be before all optional commands
    vote = false,
    localfn = function(params, caller)
        if params.user ~= nil then
            local clientid = UserToClientID(params.user) or params.user
            if params.seconds ~= nil then
                local seconds = tonumber(params.seconds)
                TheNet:BanForTime(clientid, seconds)
            else
                TheNet:Ban(clientid)
            end
        end
    end,
}
if IsConsole() then
    ban_info.desc = STRINGS.UI.BUILTINCOMMANDS.BAN.DESC_CONSOLE
end
AddUserCommand("ban", ban_info)

AddUserCommand("stopvote", {
    aliases = {"veto"},
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.STOPVOTE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.STOPVOTE.DESC
    permission = COMMAND_PERMISSION.ADMIN,
    confirm = false,
    slash = true,
    usermenu = false,
    servermenu = false,
    params = {},
    vote = false,
    localfn = function(params, caller)
        TheNet:StopVote()
    end,
})

AddUserCommand("roll", {
    aliases = { "dice", "random", "diceroll" },
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLL.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLL.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = true,
    usermenu = false,
    servermenu = true,
	menusort = 2,
    params = { "dice" },
    paramsoptional = { true },
    vote = false,
    canstartfn = function(command, caller, targetid)
        if GetTime() <= (caller._dicerollcooldown or 0) then
            return false, "COOLDOWN"
        end
        return true
    end,
    localfn = function(params, caller)
        local t = GetTime()
        if t > (caller._dicerollcooldown or 0) then
            caller._dicerollcooldown = t + TUNING.DICE_ROLL_COOLDOWN
            if params.dice ~= nil then
                local dice, sides = string.match(params.dice, "(%d+)[dD](%d+)")
                if dice ~= nil and sides ~= nil then
                    TheNet:DiceRoll(sides, dice)
                    return
                end

                sides = tonumber(params.dice)
                if sides ~= nil then
                    TheNet:DiceRoll(sides, 1)
                    return
                end
            end

            TheNet:DiceRoll(100, 1)
        end
    end,
})

AddUserCommand("rollback", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLLBACK.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLLBACK.DESC
    permission = COMMAND_PERMISSION.ADMIN,
    confirm = true,
    slash = true,
    usermenu = false,
    servermenu = true,
    params = {"numsaves"},
    paramsoptional = {true},
    vote = true,
    votetimeout = 30,
    voteminstartage = 20,
    voteminpasscount = 3,
    votecountvisible = true,
    voteallownotvoted = true,
    voteoptions = nil, --default to { "Yes", "No" }
    votetitlefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLLBACK.VOTETITLEFMT
    votenamefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLLBACK.VOTENAMEFMT
    votepassedfmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.ROLLBACK.VOTEPASSEDFMT
    votecanstartfn = VoteUtil.DefaultCanStartVote,
    voteresultfn = VoteUtil.YesNoMajorityVote,
    serverfn = function(params, caller)
        --NOTE: must support nil caller for voting
        if caller ~= nil then
            --Wasn't a vote so we should send out an announcement manually
            --NOTE: the vote rollback announcement is customized and still
            --      makes sense even when it wasn't a vote, (run by admin)
            local command = UserCommands.GetCommandFromName("rollback")
            TheNet:AnnounceVoteResult(command.hash, nil, true)
        end
        TheWorld:DoTaskInTime(5, function(world)
            if world.ismastersim then
                TheNet:SendWorldRollbackRequestToServer(params.numsaves ~= nil and tonumber(params.numsaves) or nil)
            end
        end)
    end,
})

AddUserCommand("regenerate", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.DESC
    permission = COMMAND_PERMISSION.ADMIN,
    confirm = true,
    slash = true,
    usermenu = false,
    servermenu = true,
    params = {},
    vote = true,
    votetimeout = 30,
    voteminstartage = 20,
    voteminpasscount = 3,
    votecountvisible = true,
    voteallownotvoted = true,
    voteoptions = nil, --default to { "Yes", "No" }
    votetitlefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTETITLEFMT
    votenamefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTENAMEFMT
    votepassedfmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTEPASSEDFMT
    votecanstartfn = VoteUtil.DefaultCanStartVote,
    voteresultfn = VoteUtil.YesNoMajorityVote,
    serverfn = function(params, caller)
        --NOTE: must support nil caller for voting
        if caller ~= nil then
            --Wasn't a vote so we should send out an announcement manually
            --NOTE: the vote regenerate announcement is customized and still
            --      makes sense even when it wasn't a vote, (run by admin)
            local command = UserCommands.GetCommandFromName("regenerate")
            TheNet:AnnounceVoteResult(command.hash, nil, true)
        end
        TheWorld:DoTaskInTime(5, function(world)
            if world.ismastersim then
                TheNet:SendWorldResetRequestToServer()
            end
        end)
    end,
})
