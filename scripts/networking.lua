local InputDialogScreen = require "screens/redux/inputdialog"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local ConnectingToGamePopup = require "screens/redux/connectingtogamepopup"

local UserCommands = require("usercommands")

FirstStartupForNetworking = false

function SpawnSecondInstance()
    if FirstStartupForNetworking then
        if TheNet:GetIsServer() then
            local exepath = CWD.."\\..\\bin\\dontstarve_r.exe"
            os.execute("start "..exepath)   -- run it in a separate process, or we'll be frozen until it exits
            FirstStartupForNetworking = false
        end
    end
end


--V2C: This is for server side processing of remote slash command requests
function Networking_SlashCmd(guid, userid, cmd)
    local caller = Ents[guid] or TheNet:GetClientTableForUser(userid) -- NOTES(JBK): Either an actual entity or a table with some data.
    if caller ~= nil then
        UserCommands.RunTextUserCommand(cmd, caller, true)
    end
end

function Networking_Announcement(message, colour, announce_type)
    if message then
        colour = colour or {1, 1, 1, 1}
        if not announce_type or announce_type == "" then
            announce_type = "default"
        end
        ChatHistory:OnAnnouncement(message, colour, announce_type)
    end
end

function Networking_SkinAnnouncement(user_name, user_colour, skin_name)
    if user_name and user_colour and skin_name then
        ChatHistory:OnSkinAnnouncement(user_name, user_colour, skin_name)
    end
end

function Networking_SystemMessage(message)
    if message then
        ChatHistory:OnSystemMessage(message)
    end
end

function Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if message ~= nil and message:utf8len() > MAX_CHAT_INPUT_LENGTH then
        return
    end

	local netid = TheNet:GetNetIdForUser(userid)

    local entity = Ents[guid]
    if not isemote and entity ~= nil and entity.components.talker ~= nil then
        entity.components.talker:Say(not entity:HasTag("mime") and message or "", nil, nil, nil, true, colour, TEXT_FILTER_CTX_CHAT, netid)
    end

    if message then
        ChatHistory:OnSay(guid, userid, netid, name, prefab, message, colour, whisper, isemote, user_vanity)
    end
end

function Networking_ModOutOfDateAnnouncement(mod)
    if IsRail() then
        Networking_Announcement(string.format(STRINGS.MODS.VERSIONING.OUT_OF_DATE_RAIL, mod), nil, "mod")
    else
        Networking_Announcement(string.format(STRINGS.MODS.VERSIONING.OUT_OF_DATE, mod), nil, "mod")
    end
end

function Networking_DeathAnnouncement(message, colour)
    Networking_Announcement(message, colour, "death")
end

function Networking_ResurrectAnnouncement(message, colour)
    Networking_Announcement(message, colour, "resurrect")
end

--For ease of overriding in mods
function Networking_Announcement_GetDisplayName(name)
    return name
end

function Networking_JoinAnnouncement(name, colour)
    Networking_Announcement(string.format(STRINGS.UI.NOTIFICATION.JOINEDGAME, Networking_Announcement_GetDisplayName(name)), colour, "join_game")
end

function Networking_LeaveAnnouncement(name, colour)
    Networking_Announcement(string.format(STRINGS.UI.NOTIFICATION.LEFTGAME, Networking_Announcement_GetDisplayName(name)), colour, "leave_game")
end

function Networking_KickAnnouncement(name, colour)
    Networking_Announcement(string.format(STRINGS.UI.NOTIFICATION.KICKEDFROMGAME, Networking_Announcement_GetDisplayName(name)), colour, "kicked_from_game")
end

function Networking_BanAnnouncement(name, colour)
    Networking_Announcement(string.format(STRINGS.UI.NOTIFICATION.BANNEDFROMGAME, Networking_Announcement_GetDisplayName(name)), colour, "banned_from_game")
end

-- TODO V2C: Call these appropriately from C
-- these should only run on the server. Could also call SendCommandMetricsEvent directly if you prefer.
function Networking_KickMetricsEvent(caller, target) -- source) -- source is where the command was issued, i.e. console, slashcommand, vote
    UserCommands.SendCommandMetricsEvent("kick", target, caller)
end
function Networking_BanMetricsEvent(caller, target) -- source) -- source is where the command was issued, i.e. console, slashcommand, vote
    UserCommands.SendCommandMetricsEvent("ban", target, caller)
end
function Networking_RollbackMetricsEvent(caller) -- source) -- source is where the command was issued, i.e. console, slashcommand, vote
    UserCommands.SendCommandMetricsEvent("rollback", nil, caller)
end
function Networking_RegenerateMetricsEvent(caller) -- source) -- source is where the command was issued, i.e. console, slashcommand, vote
    UserCommands.SendCommandMetricsEvent("regenerate", nil, caller)
end

function Networking_VoteAnnouncement(commandid, targetname, passed)
    local command = UserCommands.GetCommandFromHash(commandid)
    if command ~= nil and command.vote then
        local fmt = ResolveCommandStringProperty(command, "votenamefmt", STRINGS.UI.NOTIFICATION.DEFAULTVOTENAMEFMT)
        local votename = string.format(fmt, targetname:len() > 0 and targetname or "")
        fmt = passed and
            ResolveCommandStringProperty(command, "votepassedfmt", STRINGS.UI.NOTIFICATION.DEFAULTVOTEPASSEDFMT) or
            ResolveCommandStringProperty(command, "votefailedfmt", STRINGS.UI.NOTIFICATION.DEFAULTVOTEFAILEDFMT)
        Networking_Announcement(string.format(fmt, votename), nil, "vote")
        return command.name
    end
end

function Networking_RollAnnouncement(userid, name, prefab, colour, rolls, max)
    Networking_Announcement(string.format(STRINGS.UI.NOTIFICATION.DICEROLLED, ChatHistory:GetDisplayName(name, prefab), table.concat(rolls, ", "), max), colour, "dice_roll")
end

function Networking_Talk(guid, message, duration, text_filter_context, original_author)
    local entity = Ents[guid]
    if entity ~= nil and entity.components.talker ~= nil then
        entity.components.talker:Say(message, duration, nil, nil, true, nil, text_filter_context, original_author)
    end
end

function OnTwitchMessageReceived(username, message, colour)
    if TheWorld ~= nil then
        TheWorld:PushEvent("twitchmessage", {
            username = username,
            message = message,
            colour = colour,
        })
    end
end

function OnTwitchLoginAttempt(success, result)
    if TheWorld ~= nil then
        TheWorld:PushEvent("twitchloginresult", {
            success = success,
            result = result,
        })
    end
end

function OnTwitchChatStatusUpdate(status)
    if TheWorld ~= nil then
        TheWorld:PushEvent("twitchstatusupdate", {
            status = status,
        })
    end
end

function ValidateRecipeSkinRequest(user_id, prefab_name, skin)
    local validated_skin = nil
    if skin ~= nil and skin ~= "" and TheInventory:CheckClientOwnership(user_id, skin) then
        if table.contains( PREFAB_SKINS[prefab_name], skin ) then
            validated_skin = skin
        end
    end
    return validated_skin
end

function VerifySpawnNewPlayerOnServerRequest(user_id)
	if TheWorld == nil or TheWorld.net == nil or (TheWorld.net.components.worldcharacterselectlobby ~= nil and not TheWorld.net.components.worldcharacterselectlobby:CanPlayersSpawn()) then
		TheNet:Kick(user_id)
		return false
	end

	return true
end

function ValidateSpawnPrefabRequest(user_id, prefab_name, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet, allow_seamlessswap_characters)
    local in_mod_char_list = table.contains(MODCHARACTERLIST, prefab_name)

    local valid_chars = ExceptionArrays(DST_CHARACTERLIST, MODCHARACTEREXCEPTIONS_DST)
    local in_valid_char_list = table.contains(valid_chars, prefab_name)

    if table.contains(SEAMLESSSWAP_CHARACTERLIST, prefab_name) and not allow_seamlessswap_characters then
        -- NOTES(JBK): This is not assertion level of importance but it is administrative note worthy level to know someone tried breaking things.
        in_valid_char_list = false
        in_mod_char_list = false
        print(string.format("[WERR] Player with ID %s tried spawning as %s without having permissions to do so!", user_id or "?", prefab_name or "?"))
    end

    local validated_prefab = prefab_name
    local validated_skin_base = nil
    local validated_clothing_body = nil
    local validated_clothing_hand = nil
    local validated_clothing_legs = nil
    local validated_clothing_feet = nil

    if in_valid_char_list then
        if skin_base == prefab_name.."_none" then
            -- If default skin, we do not need to check
            validated_skin_base = skin_base
        elseif TheInventory:CheckClientOwnership(user_id, skin_base) then
            --check if the skin_base actually belongs to the prefab
            if table.contains( PREFAB_SKINS[prefab_name], skin_base ) then
                validated_skin_base = skin_base
            end
        end
    elseif in_mod_char_list then
        --if mod character, don't use a skin
    elseif table.getn(valid_chars) > 0 then
        validated_prefab = valid_chars[1]
    else
        validated_prefab = DST_CHARACTERLIST[1]
    end

    if clothing_body ~= "" and TheInventory:CheckClientOwnership(user_id, clothing_body) and IsClothingItem(clothing_body) then
        validated_clothing_body = clothing_body
    end
    if clothing_hand ~= "" and TheInventory:CheckClientOwnership(user_id, clothing_hand) and IsClothingItem(clothing_hand) then
        validated_clothing_hand = clothing_hand
    end
    if clothing_legs ~= "" and TheInventory:CheckClientOwnership(user_id, clothing_legs) and IsClothingItem(clothing_legs) then
        validated_clothing_legs = clothing_legs
    end
    if clothing_feet ~= "" and TheInventory:CheckClientOwnership(user_id, clothing_feet) and IsClothingItem(clothing_feet) then
        validated_clothing_feet = clothing_feet
    end

    return validated_prefab, validated_skin_base, validated_clothing_body, validated_clothing_hand, validated_clothing_legs, validated_clothing_feet
end

-- NOTES(JBK): [Searchable "SN_SKILLSELECTION"] skillselection 
function SpawnNewPlayerOnServerFromSim(player_guid, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet, starting_item_skins, skillselection)
    local player = Ents[player_guid]
    if player ~= nil then
        local skinner = player.components.skinner
        skinner:SetClothing(clothing_body)
        skinner:SetClothing(clothing_hand)
        skinner:SetClothing(clothing_legs)
        skinner:SetClothing(clothing_feet)
        skinner:SetSkinName(skin_base)
        skinner:SetSkinMode("normal_skin")

        if player.OnNewSpawn ~= nil then
            player:OnNewSpawn(starting_item_skins)
            player.OnNewSpawn = nil
        end

        local skilltreeupdater = player.components.skilltreeupdater
        skilltreeupdater:SetPlayerSkillSelection(skillselection)

        TheWorld.components.playerspawner:SpawnAtNextLocation(TheWorld, player)
        SerializeUserSession(player, true)        
    end
end

--TheNet:SpawnSeamlessPlayerReplacement(userid, prefab_name, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
function SpawnSeamlessPlayerReplacementFromSim(player_guid, old_player_guid, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
    local player = Ents[player_guid]
    if player ~= nil then
        local skinner = player.components.skinner
        skinner:SetClothing(clothing_body)
        skinner:SetClothing(clothing_hand)
        skinner:SetClothing(clothing_legs)
        skinner:SetClothing(clothing_feet)
        skinner:SetSkinName(skin_base)
        skinner:SetSkinMode("normal_skin")

		if player.components.seamlessplayerswapper then
			player.components.seamlessplayerswapper:OnSeamlessCharacterSwap(old_player_guid ~= nil and Ents[old_player_guid] or nil)
		end

        TheWorld:PushEvent("ms_seamlesscharacterspawned", player)

        SerializeUserSession(player, true)
    end
end


function RequestedLobbyCharacter(userid, prefab_name, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
	TheWorld:PushEvent("ms_requestedlobbycharacter", {userid=userid, prefab_name=prefab_name, skin_base=skin_base, clothing_body=clothing_body, clothing_hand=clothing_hand, clothing_legs=clothing_legs, clothing_feet=clothing_feet})
end

--NOTE: this is called from sim as well, so please check it before any
--      interface changes! (NetworkManager)
function SerializeUserSession(player, isnewspawn)
    if player ~= nil and player.userid ~= nil and player.userid:len() > 0 and (player == ThePlayer or TheNet:GetIsServer()) then
        --we don't care about references for player saves
        local playerinfo--[[, refs]] = player:GetSaveRecord()
        local data = DataDumper(playerinfo, nil, BRANCH ~= "dev")

        local metadataStr = ""

        if TheNet:GetIsServer() then
            local metadata = {
                character = player.prefab,
            }
            metadataStr = DataDumper(metadata, nil, BRANCH ~= "dev")
        end

        TheNet:SerializeUserSession(player.userid, data, isnewspawn == true, player.player_classified ~= nil and player.player_classified.entity or nil, metadataStr)
    end
end

function DeleteUserSession(player)
    if player ~= nil and player.userid ~= nil and player.userid:len() > 0 and (player == ThePlayer or TheNet:GetIsServer()) then
        TheNet:DeleteUserSession(player.userid)
    end
end

function SerializeWorldSession(data, session_identifier, callback, metadataStr)
    TheNet:SerializeWorldSession(data, session_identifier, ENCODE_SAVES, callback, metadataStr or "")
end

function ReportAction( userid, items, item_counts, users, cb )
	TheSim:ReportAction( userid, items, item_counts, users,
		function(result_str, isSuccessful, resultCode)
			print(result_str, isSuccessful, resultCode)
			local status, result_data = pcall( function() return json.decode(result_str) end )
			if cb ~= nil then
				local param = (result_data.Result == "NONE" and 2) or
								(result_data.Result == "DONE" and 3) or
								1
				cb(param)
			end
		end
	)
end

function DownloadMods( server_listing )
    local function enable_server_mods()
        print("We now have the required mods, enable them for server")
        for k,mod in pairs(server_listing.mods_description) do
            if mod.all_clients_require_mod then
                print("Temp Enabling " .. mod.mod_name)
                KnownModIndex:TempEnable(mod.mod_name)
            end
        end

        local success, temp_config_data = RunInSandboxSafe(server_listing.mods_config_data)
        if success and temp_config_data then
            KnownModIndex:SetTempModConfigData( temp_config_data )
        end

        print("Mods are setup for server, save the mod index and proceed.")
        KnownModIndex:Save()
    end

    local function server_listing_contains(mod_desc_table, mod_name )
        for _,mod in pairs(mod_desc_table) do
            if mod.mod_name == mod_name then
                return true
            end
        end
        return false
    end

    print("DownloadMods and temp disable")

    KnownModIndex:UpdateModInfo()
    for _,mod_name in pairs(KnownModIndex:GetServerModNames()) do
        local modinfo = KnownModIndex:GetModInfo(mod_name)
        if not modinfo.client_only_mod then
            if server_listing_contains( server_listing.mods_description, mod_name ) then
                --we found it, so leave the mod enabled
            else
                --this mod is required by all clients but the server doesn't have it enabled or it's a server mod, so locally disable it temporarily.
                --print("Temp disabling ",mod_name)
                KnownModIndex:TempDisable(mod_name)
            end
        end
    end
    if server_listing.client_mods_disabled then
		--temp disable all the client enabled mods
		for _,mod_name in pairs(KnownModIndex:GetClientModNames()) do
			print("Temp disabling client mod", mod_name)
			KnownModIndex:TempDisable(mod_name)
		end
    end
    KnownModIndex:Save()

    if server_listing.mods_enabled then
        --verify that you have the same mods enabled as the server
        local have_required_mods = true
        local needed_mods_in_workshop = true
        local mod_count = 0
        for k,mod in pairs(server_listing.mods_description) do
            mod_count = mod_count + 1

            if Profile:GetAutoSubscribeModsEnabled() then
                TheSim:SubscribeToMod(mod.mod_name)
            end

            if mod.all_clients_require_mod then
                if not KnownModIndex:DoesModExist( mod.mod_name, mod.version ) then
                    print("Failed to find mod "..mod.mod_name.." v:"..mod.version )

                    have_required_mods = false
                    local can_dl_mod = TheSim:QueueDownloadTempMod(mod.mod_name, mod.version)
                    if not can_dl_mod then
                        print("Unable to download mod " .. mod.mod_name .. " from ModWorkshop")
                        needed_mods_in_workshop = false
                    end
                end
            end
        end
        if mod_count == 0 then
            print("ERROR: Mods are enabled but the mods_description table has none in it?")
        end

        if have_required_mods then
            enable_server_mods()
            TheNet:ServerModsDownloadCompleted(true, "", "")
        else
            if needed_mods_in_workshop then
                TheSim:StartDownloadTempMods(
                    function( success, msg )
                        if success then
                            --downloading of mods succeeded, now double check if the right versions exists, if it doesn't then we downloaded the wrong version
                            local all_mods_good = true
                            local mod_with_invalid_version = nil
                            KnownModIndex:UpdateModInfo() --Make sure we're verifying against the latest data in the mod folder
                            for k,mod in pairs(server_listing.mods_description) do
                                if mod.all_clients_require_mod then
                                    if not KnownModIndex:DoesModExist( mod.mod_name, mod.version, mod.version_compatible ) then
                                        all_mods_good = false
                                        mod_with_invalid_version = mod
                                    end
                                end
                            end

                            if all_mods_good then
                                enable_server_mods()
                                TheNet:ServerModsDownloadCompleted(true, "", "")
                            else
                                local workshop_version = ""
                                if KnownModIndex:GetModInfo(mod_with_invalid_version.mod_name) ~= nil then
                                    workshop_version = KnownModIndex:GetModInfo(mod_with_invalid_version.mod_name).version
                                else
                                    print("ERROR: " .. (mod_with_invalid_version.mod_name or "") .. " has no modinfo, why???" )
                                end
                                if workshop_version == nil then
                                    workshop_version = ""
                                end
                                local version_mismatch_msg = "The server's version of " .. mod_with_invalid_version.modinfo_name .. " does not match the version on the Steam Workshop. Server version: " .. mod_with_invalid_version.version .. " Workshop version: " .. workshop_version
                                TheNet:ServerModsDownloadCompleted(false, version_mismatch_msg, "SERVER_MODS_WORKSHOP_VERSION_MISMATCH" )
                            end
                        else
                            local sku = ""
                            if IsRail() then
                                sku = "_RAIL"
                            end
                            if msg == "Access to mod denied" then
                                TheNet:ServerModsDownloadCompleted(false, msg, "SERVER_MODS_WORKSHOP_ACCESS_DENIED"..sku)
                            else
                                TheNet:ServerModsDownloadCompleted(false, msg, "SERVER_MODS_WORKSHOP_FAILURE"..sku)
                            end
                        end
                    end
                )
            else
                local error = "SERVER_MODS_NOT_ON_WORKSHOP"
                if IsRail() then
                    error = "SERVER_MODS_NOT_ON_WORKSHOP_RAIL"
                end
                TheNet:ServerModsDownloadCompleted(false, "You don't have the required mods to play on this server and they don't exist on the Workshop. You will need to download them manually.", error )
            end
        end
    else
        TheNet:ServerModsDownloadCompleted(true, "", "")
    end
end

function ShowConnectingToGamePopup()
    local active_screen = TheFrontEnd:GetActiveScreen()
    if active_screen == nil or (active_screen.name ~= "ConnectingToGamePopup" and active_screen.name ~= "QuickJoinScreen" and active_screen.name ~= "HostCloudServerPopup") then
        TheFrontEnd:PushScreen(ConnectingToGamePopup())
    end
end

function JoinServer(server_listing, optional_password_override)
    local function send_response(password)
        -- Just pass the guid in here, the network manager should have this listing
        local start_worked = TheNet:JoinServerResponse( false, server_listing.guid, password )

        if start_worked then
            DisableAllDLC()
        end
        ShowConnectingToGamePopup()
    end

    local function on_cancelled()
        TheNet:JoinServerResponse(true)
        local screen = TheFrontEnd:GetActiveScreen()
        if screen ~= nil and screen.name == "ConnectingToGamePopup" then
            screen:Close()
        end
    end

    local function after_mod_warning()
        if server_listing.has_password and (optional_password_override == "" or optional_password_override == nil) then
            local password_prompt_screen
            password_prompt_screen = InputDialogScreen( STRINGS.UI.SERVERLISTINGSCREEN.PASSWORDREQUIRED,
                                            {
                                                {
                                                    text = STRINGS.UI.SERVERLISTINGSCREEN.JOIN,
                                                    cb = function()
                                                        TheFrontEnd:PopScreen()
                                                        send_response( password_prompt_screen:GetActualString() )
                                                    end
                                                },
                                                {
                                                    text = STRINGS.UI.SERVERLISTINGSCREEN.CANCEL,
                                                    cb = function()
                                                        TheFrontEnd:PopScreen()
                                                        on_cancelled()
                                                    end
                                                },
                                            },
                                        true )
            password_prompt_screen.edit_text.OnTextEntered = function()
                if password_prompt_screen:GetActualString() ~= "" then
                    TheFrontEnd:PopScreen()
                    send_response( password_prompt_screen:GetActualString() )
                else
                    password_prompt_screen.edit_text:SetEditing(true)
                end
            end
            if not Profile:GetShowPasswordEnabled() then
                password_prompt_screen.edit_text:SetPassword(true)
            end
            TheFrontEnd:PushScreen(password_prompt_screen)
            password_prompt_screen.edit_text:SetForceEdit(true)
            password_prompt_screen.edit_text:OnControl(CONTROL_ACCEPT, false)
        else
            send_response( optional_password_override or "" )
        end
    end

    local function after_client_mod_message()
		if server_listing.mods_enabled and
			not IsMigrating() and
			(server_listing.dedicated or not server_listing.owner) and
			Profile:ShouldWarnModsEnabled() then

			local checkbox_parent = Widget("checkbox_parent")
			local checkbox = checkbox_parent:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0}))
			local text = checkbox_parent:AddChild(Text(CHATFONT, 30, STRINGS.UI.SERVERLISTINGSCREEN.SHOW_MOD_WARNING))
			local textW, textH = text:GetRegionSize()
			local imageW, imageH = checkbox:GetSize()
			text:SetVAlign(ANCHOR_LEFT)
			text:SetColour(0,0,0,1)
			local checkbox_x = -textW/2 - (imageW*2)
			local region = 600
			checkbox:SetPosition(checkbox_x, 0)
			text:SetRegionSize(region,50)
			text:SetPosition(checkbox_x + textW/2 + imageW/1.5, -10)
			local bg = checkbox_parent:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
			bg:MoveToBack()
			bg:SetClickable(false)
			bg:ScaleToSize(textW + imageW + 40, 50)
			bg:SetPosition(-75,2)
			checkbox_parent.do_warning = true
			checkbox_parent.focus_forward = checkbox
			checkbox:SetOnClick(function()
				checkbox_parent.do_warning = not checkbox_parent.do_warning
				if checkbox_parent.do_warning then
					checkbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {0,0})
				else
					checkbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {0,0})
				end
			end)
			local menuitems =
			{
				{widget=checkbox_parent, offset=Vector3(250,70,0)},
				{text=STRINGS.UI.SERVERLISTINGSCREEN.CONTINUE,
					cb = function()
						Profile:SetWarnModsEnabled(checkbox_parent.do_warning)
						TheFrontEnd:PopScreen()
						after_mod_warning()
					end, offset=Vector3(-90,0,0)},
				{text=STRINGS.UI.SERVERLISTINGSCREEN.CANCEL,
					cb = function()
						TheFrontEnd:PopScreen()
						on_cancelled()
					end, offset=Vector3(-90,0,0)}
			}

			--let the user know the warning about mods
            local mod_warning = PopupDialogScreen(STRINGS.UI.SERVERLISTINGSCREEN.MOD_WARNING_TITLE, STRINGS.UI.SERVERLISTINGSCREEN.MOD_WARNING_BODY, menuitems)
            mod_warning.dialog.actions.items[1]:SetScale(1)
            mod_warning.dialog.body:SetScale(0.8)
            mod_warning.dialog.body:SetPosition(0, 40, 0)
			mod_warning.dialog.actions.items[1]:SetFocusChangeDir(MOVE_DOWN, mod_warning.dialog.actions.items[2])
			mod_warning.dialog.actions.items[1]:SetFocusChangeDir(MOVE_RIGHT, nil)
			mod_warning.dialog.actions.items[2]:SetFocusChangeDir(MOVE_LEFT, nil)
			mod_warning.dialog.actions.items[2]:SetFocusChangeDir(MOVE_RIGHT, mod_warning.dialog.actions.items[3])
			mod_warning.dialog.actions.items[2]:SetFocusChangeDir(MOVE_UP, mod_warning.dialog.actions.items[1])
			mod_warning.dialog.actions.items[3]:SetFocusChangeDir(MOVE_LEFT, mod_warning.dialog.actions.items[2])
            mod_warning.dialog.actions.items[3]:SetFocusChangeDir(MOVE_UP, mod_warning.dialog.actions.items[1])
			mod_warning.dialog.actions.items[1]:SetPosition(305,55,0)
			mod_warning.dialog.actions.items[2]:SetPosition(105,-10,0)
            mod_warning.dialog.actions.items[3]:SetPosition(355,-10,0)

			TheFrontEnd:PushScreen( mod_warning )
		else
			after_mod_warning()
		end
	end

	if server_listing.client_mods_disabled and
		not IsMigrating() and
		(server_listing.dedicated or not server_listing.owner) and
		AreAnyClientModsEnabled() then

		local client_mod_msg = PopupDialogScreen(STRINGS.UI.SERVERLISTINGSCREEN.CLIENT_MODS_DISABLED_TITLE, STRINGS.UI.SERVERLISTINGSCREEN.CLIENT_MODS_DISABLED_BODY,
			{{ text=STRINGS.UI.SERVERLISTINGSCREEN.CONTINUE, cb = function()
						TheFrontEnd:PopScreen()
						after_client_mod_message()
			end }})

		TheFrontEnd:PushScreen( client_mod_msg )
	else
		after_client_mod_message()
	end

end

function MigrateToServer(serverIp, serverPort, serverPassword, serverNetId)
    local function do_join_server()
        serverNetId = serverNetId or ""

        StartNextInstance({
            reset_action = RESET_ACTION.JOIN_SERVER,
            serverIp = serverIp,
            serverPort = serverPort,
            serverPassword = serverPassword,
            serverNetId = serverNetId,
        })
    end

    if InGamePlay() then
        if ThePlayer ~= nil and TheWorld ~= nil and not TheWorld.ismastersim then
            --Got here before player deactivation, so
            --we will need to save local minimap now.
            SerializeUserSession(ThePlayer)
        end
        do_join_server()
    else
        DoLoadingPortal(do_join_server)
    end
end

function GetAvailablePlayerColours()
    -- -Return an ordered list of player colours, and a default colour.
    --
    -- -Default colour should not be in the list, and it is only used
    --  when data is not available yet or in case of errors.
    --
    -- -Colours are assigned in order as players join, so modders can
    --  prerandomize this list if they want random assignments.
    --
    -- -Players will be reassigned their previous colour on a server if
    --  it hasn't been used, and the server is in the same session.

    --Using a better colour theme to match world tones
    local colours =
    {
        PLAYERCOLOURS.TOMATO,
        PLAYERCOLOURS.TAN,
        PLAYERCOLOURS.PLUM,
        PLAYERCOLOURS.BURLYWOOD,
        PLAYERCOLOURS.RED,
        PLAYERCOLOURS.PERU,
        PLAYERCOLOURS.DARKPLUM,
        PLAYERCOLOURS.EGGSHELL,
        PLAYERCOLOURS.SALMON,
        PLAYERCOLOURS.CHOCOLATE,
        PLAYERCOLOURS.VIOLETRED,
        PLAYERCOLOURS.SANDYBROWN,
        PLAYERCOLOURS.BROWN,
        PLAYERCOLOURS.BISQUE,
        PLAYERCOLOURS.PALEVIOLETRED,
        PLAYERCOLOURS.GOLDENROD,
        PLAYERCOLOURS.ROSYBROWN,
        PLAYERCOLOURS.LIGHTTHISTLE,
        PLAYERCOLOURS.PINK,
        PLAYERCOLOURS.LEMON,
        PLAYERCOLOURS.FIREBRICK,
        PLAYERCOLOURS.LIGHTGOLD,
        PLAYERCOLOURS.MEDIUMPURPLE,
        PLAYERCOLOURS.THISTLE,
    }
    --TODO: forward to a mod function before returning?
    return colours, DEFAULT_PLAYER_COLOUR
end

local function DoReset()
    StartNextInstance({
        reset_action = RESET_ACTION.LOAD_SLOT,
        save_slot = ShardGameIndex:GetSlot()
    })
end

function WorldResetFromSim()
    if TheWorld ~= nil and TheWorld.ismastersim then
        print("Received world reset request")
        TheWorld:PushEvent("ms_worldreset")
        ShardGameIndex:Delete(
            DoReset,
            true -- true causes world gen options to be preserved
        )
    end
end

function WorldRollbackFromSim(count)
    if TheWorld ~= nil and TheWorld.ismastershard then
        print("Received world rollback request: count="..tostring(count))
        if count > 0 then
            if TheWorld.net == nil or
                TheWorld.net.components.autosaver == nil or
                GetTime() - TheWorld.net.components.autosaver:GetLastSaveTime() < 30 then
                count = count + 1
            end
            TheNet:TruncateSnapshots(TheWorld.meta.session_identifier, -count)
        end
        DoReset()
    end
end

function UpdateServerTagsString()
    --V2C: ughh... well at least try to keep this in sync with
    --     servercreationscreen.lua BuildTagsStringHosting()

    local tagsTable = {}

    table.insert(tagsTable, GetGameModeTag(TheNet:GetDefaultGameMode()))

    if TheNet:GetDefaultPvpSetting() then
        table.insert(tagsTable, STRINGS.TAGS.PVP)
    end

    if TheNet:GetDefaultFriendsOnlyServer() then
        table.insert(tagsTable, STRINGS.TAGS.FRIENDSONLY)
    end

    if TheNet:GetDefaultLANOnlyServer() then
        table.insert(tagsTable, STRINGS.TAGS.LOCAL)
    end

    if TheNet:GetDefaultClanID() ~= "" then
        table.insert(tagsTable, STRINGS.TAGS.CLAN)
    end

    local worldoptions = ShardGameIndex:GetGenOptions()
    local worlddata = worldoptions or nil
    if worlddata ~= nil and worlddata.location ~= nil then
        local locationtag = STRINGS.TAGS.LOCATION[string.upper(worlddata.location)]
        if locationtag ~= nil then
            table.insert(tagsTable, locationtag)
        end
    end

    TheNet:SetServerTags(BuildTagsStringCommon(tagsTable))
end

function UpdateServerWorldGenDataString()
    local clusteroptions = {}
    local worldoptions = deepcopy(ShardGameIndex:GetGenOptions())
    table.insert(clusteroptions, worldoptions or {})

    if TheShard:IsMaster() then
        -- Merge secondary shard worldgen data
        for k, v in pairs(Shard_GetConnectedShards()) do
            if v.world ~= nil and v.world[1] ~= nil then
                table.insert(clusteroptions, v.world[1])
            end
        end
    end

    local Customize = require"map/customize"
    for i,world in ipairs(clusteroptions) do
        if world.overrides == nil then
            -- gjans: I'm not sure how we got this far without crashing, but this isn't the right time to crash.
            world.overrides = {}
        else
            for option,value in pairs(world.overrides) do
                -- we can aggressively prune these for network purposes, as the only use after this is the server info screen.
                if value == "default" or not Customize.ValidateOption(option, value, world.location) then
                    world.overrides[option] = nil
                end
            end
        end
    end

    --V2C: TODO: Likely to exceed data size limit with custom multilevel worlds
    TheNet:SetWorldGenData(DataDumper(ZipAndEncodeSaveData(clusteroptions), nil, true))
end

function GetDefaultServerData()
    --V2C: Note for online_mode:
    --     As long as StartServer/StartDedicatedServers has been
    --     called before this, then TheNet:IsOnlineMode() should
    --     return the desired value.
    return
    {
        pvp = TheNet:GetDefaultPvpSetting(),
        game_mode = TheNet:GetDefaultGameMode(),
		playstyle = TheNet:GetServerPlaystyle(),
        online_mode = TheNet:IsOnlineMode(),
        encode_user_path = TheNet:GetDefaultEncodeUserPath(),
        use_legacy_session_path = nil,
        max_players = TheNet:GetDefaultMaxPlayers(),
        name = TheNet:GetDefaultServerName(),
        password = TheNet:GetDefaultServerPassword(),
        description = TheNet:GetDefaultServerDescription(),
        server_language = TheNet:GetDefaultServerLanguage(),
        privacy_type =
            (TheNet:GetDefaultFriendsOnlyServer() and PRIVACY_TYPE.FRIENDS) or
            (TheNet:GetDefaultLANOnlyServer() and PRIVACY_TYPE.LOCAL) or
            (TheNet:GetDefaultClanOnly() and PRIVACY_TYPE.CLAN) or
            PRIVACY_TYPE.PUBLIC,
        clan =
        {
            id = TheNet:GetDefaultClanID(),
            only = TheNet:GetDefaultClanOnly(),
            admin = TheNet:GetDefaultClanAdmins(),
        },
    }
end

function StartDedicatedServer()
    print("Starting Dedicated Server Game")
    local start_in_online_mode = not TheNet:IsDedicatedOfflineCluster()
    local server_started = TheNet:StartServer(start_in_online_mode)
    if server_started == true then
        DisableAllDLC()

        --V2C: From now on, we want to actually write data into
        --     a slot before initiating LOAD_SLOT action on it!

        local slot = ShardGameIndex:GetSlot()
        local serverdata = GetDefaultServerData()

        local function onsaved()
			TheNet:SetServerPlaystyle(ShardGameIndex:GetServerData().playstyle or PLAYSTYLE_DEFAULT)
            UpdateServerTagsString()
            StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot })
        end

        if ShardGameIndex:IsEmpty() then
            ShardGameIndex:SetServerShardData(nil, serverdata, onsaved)
        else
            if TheNet:GetServerIsClientHosted() then
                local slot_server_data = ShardGameIndex:GetServerData(slot)
                --V2C: new flags added, with backward compatibility
                if not serverdata.encode_user_path and slot_server_data.encode_user_path then
                    serverdata.encode_user_path = TheNet:TryDefaultEncodeUserPath()
                end
                serverdata.use_legacy_session_path = slot_server_data.use_legacy_session_path
            end
            ShardGameIndex:SetServerShardData(nil, serverdata, onsaved)
        end
    end
end

function JoinServerFilter()
    return true
end

function CalcQuickJoinServerScore(server)
	-- Return the score for the server.
	-- Highest scored servers will have the highest priority
	-- Return -1 to reject the server

	if (not server.pvp)														-- not PVP
		and server.dedicated												-- is a dedicated server
		and (not server.has_password)										-- not passworded
		and (not server.mods_enabled)										-- not modded
		and string.lower(server.mode) == "survival"							-- survival game mode
		and server.current_players < server.max_players						-- not full
		and (server.ping > 0 and server.ping < 200)							-- filter out bad pings
	then
		local score = 0

		if server.friend_playing then										score = score + 10		end
		if server._has_character_on_server then								score = score + 4		end
		if server.current_players >= 3 then									score = score + 3		end
		if server.current_players > 0 then									score = score + 2		end
		if server.belongs_to_clan then										score = score + 1		end
		if server.season ~= nil and server.season == SEASONS.AUTUMN then	score = score + 2		end

		if server.current_players == 0 then									score = score - 1		end

		return score
	end

	return -1
end

function LookupPlayerInstByUserID(userid)
    for i,v in ipairs(AllPlayers) do
        if v.userid == userid then
            return v
        end
    end
end

-- returns the client table with only the players in it, removing the dedicate host object if needed
function GetPlayerClientTable()
    local ClientObjs = TheNet:GetClientTable()
    if ClientObjs == nil then
        return {}
    elseif TheNet:GetServerIsClientHosted() then
        return ClientObjs
    end

    --remove dedicate host from player list
    for i, v in ipairs(ClientObjs) do
        if v.performance ~= nil then
            table.remove(ClientObjs, i)
            break
        end
    end
    return ClientObjs
end

function ClientAuthenticationComplete(userid)
	if TheWorld ~= nil and TheWorld:IsValid() then
		TheWorld:PushEvent("ms_clientauthenticationcomplete", {userid = userid})
	end
end

function ClientDisconnected(userid)
	if TheWorld ~= nil and TheWorld:IsValid() then
		TheWorld:PushEvent("ms_clientdisconnected", {userid = userid})
	end
end

--------------------------------------------------------------------------
local _friendsmanager = nil

local function UnregisterFriendsManager(inst)
    _friendsmanager = nil
end

function RegisterFriendsManager(widg)
    if _friendsmanager == nil then
        _friendsmanager = widg
        widg.inst:ListenForEvent("onremove", UnregisterFriendsManager)
    end
end

function Networking_PartyInvite(inviter, partyid)
    if _friendsmanager ~= nil then
        _friendsmanager:ReceiveInvite(inviter, partyid)
    end
end

function Networking_JoinedParty()
    if _friendsmanager ~= nil then
        _friendsmanager:SwitchToPartyTab()
    end
end

function Networking_LeftParty()
    if _friendsmanager ~= nil then
        _friendsmanager:SwitchToFriendsTab()
    end
end

function Networking_PartyChanged()
    if _friendsmanager ~= nil then
        _friendsmanager:RefreshPartyTab()
    end
end

function Networking_PartyServer(ip, port)
    print("Party server: "..ip..":"..tostring(port))
end

function Networking_PartyChat(chatline)
    if _friendsmanager ~= nil then
        _friendsmanager:ReceivePartyChat(chatline)
    end
end
