local Widget = require("widgets/widget")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")
local TextEdit = require("widgets/textedit")
local Image = require("widgets/image")


local SHOW_FRIENDS_MANAGER = false
--------------------------------------------------------------------------
--[[ PartyTab ]]
--------------------------------------------------------------------------

local PartyTab = Class(Widget, function(self, manager)
    Widget._ctor(self, "PartyTab")

    self.manager = manager

    self.console = self:AddChild(Text(CODEFONT, 14))
    self.console:SetRegionSize(manager.contentwidth, manager.contentheight)
    self.console:SetPosition(.5 * manager.contentwidth, -.5 * manager.contentheight)
    self.console:SetHAlign(ANCHOR_LEFT)
    self.console:SetVAlign(ANCHOR_TOP)

    self.btns = self:AddChild(Widget("PartyTabBtns"))

    self.refreshperiod = 1
    self.numchatlines = 0
    self.maxchatlines = 16
    self.maxchatlinechars = 25
    self.delay = nil
    self.party = nil
    self.invite = nil
    self.chatbar = nil
    self.chathistory = nil
    self.chathistory2 = nil
    self.checkediting = false
    self:Hide()
end)

function PartyTab:OnShow()
    self.delay = self.refreshperiod
    self:SetPartyTable(TheNet:GetPartyTable())
    self.checkediting = true
    self:StartUpdating()
end

function PartyTab:OnHide()
    self.party = nil
    self.console:SetString("")
    self.btns:KillAllChildren()
    self.numchatlines = 0
    self.chatbar = nil
    self.chathistory = nil
    self.chathistory2 = nil
    self.checkediting = false
    self:StopUpdating()
end

function PartyTab:Refresh()
    if self.shown then
        self.delay = 0
        self:OnUpdate(0)
    end
end

function PartyTab:OnUpdate(dt)
    if self.delay > dt then
        self.delay = self.delay - dt
    else
        self.delay = self.refreshperiod

        local party = TheNet:GetPartyTable()
        local dirty = #party ~= #self.party
        if not dirty then
            for i, oldrow in ipairs(self.party) do
                local newrow = party[i]
                for k, v in pairs(oldrow) do
                    if v ~= newrow[k] then
                        dirty = true
                        break
                    end
                end
            end
        end

        if dirty then
            self:SetPartyTable(party)
        end
    end

    if self.checkediting then
        self.checkediting = false
        if self.chatbar ~= nil then
            self.chatbar:SetEditing(true)
        end
    end
end

function PartyTab:SetPartyTable(party)
    self.party = party

    local chathistory = self.chathistory ~= nil and self.chathistory:GetString() or ""
    local numchatlines = self.numchatlines

    self.btns:KillAllChildren()
    self.numchatlines = 0
    self.chatbar = nil
    self.chathistory = nil
    self.chathistory2 = nil

    if #party > 1 then
        local str = "Party has "..tostring(#party).." members:\n"
        for i, v in ipairs(party) do
            str = str..string.format(" (%s%s) %s\n",
                (v.myparty and "P") or (v.inparty and "p") or " ",
                (v.mygame and "G") or (v.ingame and "g") or " ",
                v.name
            )
        end

        self.console:SetString(str)
        self.invite = nil

        local btn = self.btns:AddChild(TextButton())
        btn:SetFont(CODEFONT)
        btn:SetTextSize(14)
        btn:SetColour(unpack(btn.textcolour))
        btn:SetText("[Leave]")
        btn:SetPosition(27, (-2.5 - #party) * self.manager.lineheight)
        btn:SetOnClick(function()
            TheNet:LeaveParty()
        end)

        btn = self.btns:AddChild(Image("images/global.xml", "square.tex"))
        btn:SetHRegPoint(ANCHOR_LEFT)
        btn:SetVRegPoint(ANCHOR_TOP)
        btn:SetSize(self.manager.contentwidth + 4, self.manager.lineheight + 4)
        btn:SetTint(0, 0, 0, 1)
        btn:SetPosition(-2, 2 - 21 * self.manager.lineheight)

        self.numchatlines = self.maxchatlines - #party

        self.chathistory = self.btns:AddChild(Text(CODEFONT, self.manager.lineheight, ""))
        self.chathistory:SetPosition(.5 * self.manager.contentwidth, (self.numchatlines * .5 - 9) * self.manager.lineheight - .5 * self.manager.contentheight)
        self.chathistory:SetRegionSize(self.manager.contentwidth, self.numchatlines * self.manager.lineheight)
        self.chathistory:SetHAlign(ANCHOR_LEFT)
        self.chathistory:SetVAlign(ANCHOR_BOTTOM)
        self.chathistory:EnableWordWrap(false)

        self.chathistory2 = self.chathistory:AddChild(Text(CODEFONT, self.manager.lineheight, ""))
        self.chathistory2:SetHAlign(ANCHOR_LEFT)
        self.chathistory2:SetVAlign(ANCHOR_BOTTOM)
        self.chathistory2:EnableWordWrap(false)
        self.chathistory2:Hide()

        if self.numchatlines > numchatlines then
            chathistory = TheNet:GetPartyChatHistory()
            for i = math.max(1, #chathistory - self.numchatlines + 1), #chathistory do
                self:ReceivePartyChat(chathistory[i])
            end
        elseif chathistory:len() > 0 then
            if self.numchatlines < numchatlines then
                self.chathistory2:SetString(chathistory, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
                local w, h = self.chathistory2:GetRegionSize()
                if h > self.numchatlines * self.manager.lineheight then
                    while true do
                        local n = string.find(chathistory, "\n")
                        if n == nil then
                            chathistory = ""
                            break
                        end
                        chathistory = chathistory:sub(n + 1)
                        self.chathistory2:SetString(chathistory, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
                        w, h = self.chathistory2:GetRegionSize()
                        if h <= self.numchatlines * self.manager.lineheight then
                            break
                        end
                    end
                    self.chathistory2:SetString("")
                end
            end
            self.chathistory:SetString(chathistory)
        end

        self.chatbar = self.btns:AddChild(TextEdit(CODEFONT, self.manager.lineheight, ""))
        self.chatbar:SetIdleTextColour(1, 1, 1, 1)
        self.chatbar:SetEditTextColour(1, 1, 1, 1)
        self.chatbar:SetEditCursorColour(1, 1, 1, 1)
        self.chatbar:SetRegionSize(self.manager.contentwidth, self.manager.lineheight)
        self.chatbar:SetHAlign(ANCHOR_LEFT)
        self.chatbar:SetVAlign(ANCHOR_TOP)
        self.chatbar:SetPosition(.5 * self.manager.contentwidth, -21.5 * self.manager.lineheight)
        self.chatbar:SetForceEdit(true)
        self.chatbar.OnTextEntered = function(str)
            if str:len() > 0 then
                TheNet:PartyChat(str)
                self.chatbar:SetString("")
            end
            self.chatbar:SetEditing(true)
        end
        self.chatbar:SetEditing(true)
    elseif self.invite ~= nil then
        self.console:SetString("Invite from "..self.invite.inviter)

        local btn = self.btns:AddChild(TextButton())
        btn:SetFont(CODEFONT)
        btn:SetTextSize(14)
        btn:SetColour(unpack(btn.textcolour))
        btn:SetText("[Accept]")
        btn:SetPosition(32, -2.5 * self.manager.lineheight)
        btn:SetOnClick(function()
            TheNet:JoinParty(self.invite.partyid)
        end)

        btn = self.btns:AddChild(TextButton())
        btn:SetFont(CODEFONT)
        btn:SetTextSize(14)
        btn:SetColour(unpack(btn.textcolour))
        btn:SetText("[Ignore]")
        btn:SetPosition(103, -2.5 * self.manager.lineheight)
        btn:SetOnClick(function()
            self.invite = nil
            self.manager:SwitchToFriendsTab()
        end)
    else
        self.console:SetString("-No party-")
    end
end

function PartyTab:ReceiveInvite(inviter, partyid)
    if self.invite ~= nil then
        local party = TheNet:GetPartyTable()
        if #party <= 1 then
            self.invite = { inviter = inviter, partyid = partyid }
            return true
        end
    end
    return false
end

function PartyTab:ReceivePartyChat(chatline)
    --chatline.netid not used here
    if self.chathistory ~= nil then
        local oldstr = self.chathistory:GetString()
        local str = chatline.name..": "..chatline.message
        self.chathistory2:SetMultilineTruncatedString(str, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
        local w, h = self.chathistory2:GetRegionSize()
        if h > self.numchatlines * self.manager.lineheight then
            while true do
                local n = string.find(self.chathistory2:GetString(), "\n")
                if n == nil then
                    break
                end
                str = str:sub(n)
                self.chathistory2:SetMultilineTruncatedString(str, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
                w, h = self.chathistory2:GetRegionSize()
                if h <= self.numchatlines * self.manager.lineheight then
                    break
                end
            end
            self.chathistory:SetString(self.chathistory2:GetString())
            self.chathistory2:SetString("")
            return
        end

        self.chathistory2:SetMultilineTruncatedString(oldstr.."\n"..str, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
        local w, h = self.chathistory2:GetRegionSize()
        while h > self.numchatlines * self.manager.lineheight do
            local n = string.find(oldstr, "\n")
            if n == nil then
                self.chathistory2:SetMultilineTruncatedString(str, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
                break
            end
            oldstr = oldstr:sub(n + 1)
            self.chathistory2:SetMultilineTruncatedString(oldstr.."\n"..str, self.numchatlines + 2, self.manager.contentwidth, self.maxchatlinechars, false)
            w, h = self.chathistory2:GetRegionSize()
        end
        self.chathistory:SetString(self.chathistory2:GetString())
        self.chathistory2:SetString("")
    end
end


--------------------------------------------------------------------------
--[[ FriendsTab ]]
--------------------------------------------------------------------------

local FriendsTab = Class(Widget, function(self, manager)
    Widget._ctor(self, "FriendsTab")

    self.manager = manager

    self.console = self:AddChild(Text(CODEFONT, manager.lineheight))
    self.console:SetRegionSize(manager.contentwidth, manager.contentheight)
    self.console:SetPosition(.5 * manager.contentwidth, -.5 * manager.contentheight)
    self.console:SetHAlign(ANCHOR_LEFT)
    self.console:SetVAlign(ANCHOR_TOP)

    self.btns = self:AddChild(Widget("FriendsTabBtns"))

    self.refreshperiod = 1
    self.delay = self.refreshperiod
    self.friends = nil
    self:Hide()
end)

function FriendsTab:OnShow()
    self.delay = self.refreshperiod
    self:SetFriendsList(TheNet:GetFriendsList())
    self:StartUpdating()
end

function FriendsTab:OnHide()
    self.friends = nil
    self.console:SetString("")
    self.btns:KillAllChildren()
    self:StopUpdating()
end

function FriendsTab:Refresh()
    if self.shown then
        self.delay = 0
        self:OnUpdate(0)
    end
end

function FriendsTab:OnUpdate(dt)
    if self.delay > dt then
        self.delay = self.delay - dt
    else
        self.delay = self.refreshperiod

        local friends = TheNet:GetFriendsList()
        if #friends == #self.friends then
            local dirty = false
            for i, oldrow in ipairs(self.friends) do
                local newrow = friends[i]
                for k, v in pairs(oldrow) do
                    if v ~= newrow[k] then
                        dirty = true
                        break
                    end
                end
            end
            if not dirty then
                return
            end
        end

        self:SetFriendsList(friends)
    end
end

function FriendsTab:SetFriendsList(friends)
    self.friends = friends

    self.btns:KillAllChildren()

    local str = "Friends playing DST:\n"
    for i, v in ipairs(friends) do
        str = str..string.format("    (%s%s) %s\n",
            (v.myparty and "P") or (v.inparty and "p") or " ",
            (v.mygame and "G") or (v.ingame and "g") or " ",
            v.name
        )
        if not v.inparty then
            local btn = self.btns:AddChild(TextButton("InviteBtn"..tostring(i)))
            btn:SetFont(CODEFONT)
            btn:SetTextSize(14)
            btn:SetColour(unpack(btn.textcolour))
            btn:SetText("[i]")
            btn:SetPosition(12, (-.5 - i) * self.manager.lineheight)
            btn:SetOnClick(function()
                if v.netid == "7656 ... steamid" then --for testing
                    TheNet:InviteToParty(v.netid)
                end
            end)
        end
    end

    self.console:SetString(str)
end


--------------------------------------------------------------------------
--[[ FriendsManager ]]
--------------------------------------------------------------------------

local FriendsManager = Class(Widget, function(self)
    Widget._ctor(self, "FriendsManager")

    self.windowwidth = 220
    self.windowheight = 360
    self.margin = 20
    self.padding = 10
    self.lineheight = 14
    self.buttonheight = 28
    self.contentwidth = self.windowwidth - 2 * self.padding
    self.contentheight = self.windowheight - 2 * self.padding - self.buttonheight

    self.rootx = self.margin
    self.rooty = self.windowheight + self.margin
    self.root = self:AddChild(Widget("FriendsManagerRoot"))
    self.root:SetPosition(self.rootx, self.rooty)

    self.bg = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetHRegPoint(ANCHOR_LEFT)
    self.bg:SetVRegPoint(ANCHOR_TOP)
    self.bg:SetSize(self.windowwidth, self.windowheight)
    self.bg:SetTint(.2, .2, .2, 1)

    self.friendstab = self.root:AddChild(FriendsTab(self))
    self.friendstab:SetPosition(self.padding, -self.padding - self.buttonheight)

    self.partytab = self.root:AddChild(PartyTab(self))
    self.partytab:SetPosition(self.padding, -self.padding - self.buttonheight)

    self.friendsbtn = self.root:AddChild(TextButton("FriendsBtn"))
    self.friendsbtn:SetFont(CODEFONT)
    self.friendsbtn:SetTextSize(self.lineheight)
    self.friendsbtn:SetColour(unpack(self.friendsbtn.textcolour))
    self.friendsbtn:SetText("[Friends]")
    self.friendsbtn:SetPosition(46, -self.lineheight)
    self.friendsbtn:SetOnClick(function()
        self:SwitchToFriendsTab()
    end)

    self.partybtn = self.root:AddChild(TextButton("PartyBtn"))
    self.partybtn:SetFont(CODEFONT)
    self.partybtn:SetTextSize(self.lineheight)
    self.partybtn:SetColour(unpack(self.partybtn.textcolour))
    self.partybtn:SetText("[Party]")
    self.partybtn:SetPosition(117, -self.lineheight)
    self.partybtn:SetOnClick(function()
        self:SwitchToPartyTab()
    end)

    local party = TheNet:GetPartyTable()
    self.tab = #party > 1 and "party" or "friends"
    self:OnShow()

	if not SHOW_FRIENDS_MANAGER then
        self:Hide()
    end

    RegisterFriendsManager(self)
end)

function FriendsManager:Kill()
    if self.parent ~= nil then
        self.parent.children[self] = nil
    end
    self:Hide()
end

function FriendsManager:OnShow()
    if self.tab == "party" then
        self:SwitchToPartyTab()
    else
        self:SwitchToFriendsTab()
    end
end

function FriendsManager:OnHide()
    if self.friendstab.shown then
        self.friendstab:Hide()
    end
    if self.partytab.shown then
        self.partytab:Hide()
    end
end

function FriendsManager:SetHAnchor(anchor)
    self._base.SetHAnchor(self, anchor)
    if anchor == ANCHOR_LEFT then
        self.rootx = self.margin
    elseif anchor == ANCHOR_RIGHT then
        self.rootx = -self.windowwidth - self.margin
    else
        self.rootx = -.5 * self.windowwidth
    end
    self.root:SetPosition(self.rootx, self.rooty)
end

function FriendsManager:SetVAnchor(anchor)
    self._base.SetVAnchor(self, anchor)
    if anchor == ANCHOR_TOP then
        self.rooty = -self.margin
    elseif anchor == ANCHOR_BOTTOM then
        self.rooty = self.windowheight + self.margin
    else
        self.rooty = .5 * self.windowheight
    end
    self.root:SetPosition(self.rootx, self.rooty)
end

function FriendsManager:SwitchToFriendsTab()
    self.tab = "friends"
    if self.shown then
        if self.partytab.shown then
            self.partytab:Hide()
        end
        if not self.friendstab.shown then
            self.friendstab:Show()
        end
    end
end

function FriendsManager:SwitchToPartyTab()
    self.tab = "party"
    if self.shown then
        if self.friendstab.shown then
            self.friendstab:Hide()
        end
        if not self.partytab.shown then
            self.partytab:Show()
        end
    end
end

function FriendsManager:RefreshFriendsTab()
    self.friendstab:Refresh()
end

function FriendsManager:RefreshPartyTab()
    self.partytab:Refresh()
end

function FriendsManager:ReceiveInvite(inviter, partyid)
    if self.partytab:ReceiveInvite(inviter, partyid) then
        self:SwitchToPartyTab()
    end
end

function FriendsManager:ReceivePartyChat(chatline)
    self.partytab:ReceivePartyChat(chatline)
end

--------------------------------------------------------------------------

local _friendsmanager = nil

local function GetFriendsManager()
    if _friendsmanager == nil then
        _friendsmanager = FriendsManager()
    else
        _friendsmanager:Kill()

		if SHOW_FRIENDS_MANAGER then
            _friendsmanager:Show()
        end
    end
    return _friendsmanager
end

return GetFriendsManager
