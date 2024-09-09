local EMOTES =
{
    ["wave"] = {
        aliases = { "waves", "hi", "bye", "goodbye" },
        data = { anim = { "emoteXL_waving1", "emoteXL_waving2", "emoteXL_waving3" }, randomanim = true, sitting = true, mounted = true },
    },

    ["rude"] = {
        aliases = { "goaway", "threaten" },
        data = { anim = { "emoteXL_waving4" }, randomanim = true, sitting = true, mounted = true, mountsound = "angry" },
    },

    ["happy"] = {
        data = { anim = "emoteXL_happycheer", sitting = true, mounted = true, mountsound = "yell" },
    },

    ["angry"] = {
        aliases = { "anger", "grimace", "grimaces", "frustrate", "frustrated", "frustration" },
        data = { anim = "emoteXL_angry", sitting = true, mounted = true, mountsound = "angry", mountsounddelay = 7 * FRAMES },
    },

    ["cry"] = {
        aliases = { "sad", "cries" },
        data = { anim = "emoteXL_sad", fx = "tears", fxdelay = 17 * FRAMES, sitting = true, mounted = true, mountsound = "grunt" },
    },

    ["no"] = {
        aliases = { "annoyed", "annoy", "shakehead", "shake", "confuse", "confused" },
        data = { anim = "emoteXL_annoyed", sitting = true, mounted = true, mountsound = "grunt", mountsounddelay = 12 * FRAMES },
    },

    ["joy"] = {
        aliases = { "click", "heelclick", "heels", "celebrate", "celebration" },
        data = { anim = "research", fx = false, mounted = true, mountsound = "curious" },
    },

    ["dance"] = {
        data = { anim = { "emoteXL_pre_dance0", "emoteXL_loop_dance0" }, loop = true, fx = false, beaver = true, moose = true, goose = true, mounted = true, mountsound = "curious", tags = { "dancing" } },
    },

    ["sit"] = {
        data = { anim = { { "emote_pre_sit2", "emote_loop_sit2" }, { "emote_pre_sit4", "emote_loop_sit4" } }, randomanim = true, loop = true, fx = false, mounted = true, mountsound = "walk", mountsounddelay = 6 * FRAMES },
    },

    ["squat"] = {
        data = { anim = { { "emote_pre_sit1", "emote_loop_sit1" }, { "emote_pre_sit3", "emote_loop_sit3" } }, randomanim = true, loop = true, fx = false, mounted = true, mountsound = "walk", mountsounddelay = 10 * FRAMES },
    },

    ["bonesaw"] = {
        aliases = { "ready", "goingnowhere", "playtime", "threeminutes" },
        data = { anim = "emoteXL_bonesaw", mounted = true, mountsound = "angry" },
    },

    ["facepalm"] = {
        aliases = { "doh", "slapintheface" },
        data = { anim = "emoteXL_facepalm", sitting = true, mounted = true, mountsound = "grunt" },
    },

    ["kiss"] = {
        aliases = { "blowkiss", "smooch", "mwa", "mwah" },
        data = { anim = "emoteXL_kiss", sitting = true, mounted = true, mountsound = "curious" },
    },

    ["pose"] = {
        aliases = { "strut", "strikepose" },
        data = { anim = "emote_strikepose", zoom = true, soundoverride = "pose", mounted = true },
    },

    ["toast"] = {
        aliases = { "toasting", "cheers" },
        data = { anim = { "emote_pre_toast", "emote_loop_toast" }, sitting = true, mounted = true, soundoverride = "pose", loop = true, fx = false, sounddelay = 0.55, },
    },

    ["pet"] = {
        aliases = { "pat" },
        data = {
            anim = { "pet_small" },
            mounted = true,
            mountonly = true,
            mountsound = "curious",
            mountsounddelay = 25 * FRAMES,
            soundoverride = "pose",
            sounddelay = 11 * FRAMES,
            fx = false,
        },
    },

    ["bigpet"] = {
        aliases = { "bigpat" },
        data = {
            anim = { "pet_big" },
            mounted = true,
            mountonly = true,
            mountsound = "curious",
            mountsounddelay = 25 * FRAMES,
            soundoverride = "pose",
            sounddelay = 11 * FRAMES,
            fx = false,
            zoom = true,
        },
    },
}

local function CreateEmoteCommand(emotedef)
    return {
        aliases = emotedef.aliases,
        prettyname = function(command) return string.format(STRINGS.UI.BUILTINCOMMANDS.EMOTES.PRETTYNAMEFMT, FirstToUpper(command.name)) end,
        desc = function() return STRINGS.UI.BUILTINCOMMANDS.EMOTES.DESC end,
        permission = COMMAND_PERMISSION.USER,
        params = {},
        emote = true,
        slash = true,
        usermenu = false,
        servermenu = false,
        vote = false,
        serverfn = function(params, caller)
            local player = UserToPlayer(caller.userid)
            if player ~= nil then
                player:PushEvent("emote", emotedef.data)
            end
        end,
        displayname = emotedef.displayname
    }
end

for k, v in pairs(EMOTES) do
    AddUserCommand(k, CreateEmoteCommand(v))
end

--------------------------------------------------------------------------
for item_type, v in pairs(EMOTE_ITEMS) do
    local cmd_data = CreateEmoteCommand(v)
    cmd_data.requires_item_type = item_type
    cmd_data.hasaccessfn = function(command, caller)
        if caller == nil or TheWorld == nil then
            return false
        elseif TheWorld.ismastersim then
            return TheInventory:CheckClientOwnership(caller.userid, item_type)
        else
            return caller.userid == TheNet:GetUserID() and TheInventory:CheckOwnership(item_type)
        end
    end
    AddUserCommand(v.cmd_name, cmd_data)
end

--------------------------------------------------------------------------
CreateEmoteCommand = nil
