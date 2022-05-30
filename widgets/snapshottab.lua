local PopupDialogScreen = require "screens/popupdialog"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local ScrollableList = require "widgets/scrollablelist"

local SnapshotTab = Class(Widget, function(self, cb)
    Widget._ctor(self, "SnapshotTab")

    self.snapshot_page = self:AddChild(Widget("snapshot_page"))

    self.left_line = self.snapshot_page:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.left_line:SetScale(1, .6)
    self.left_line:SetPosition(-530, 5, 0)

    self.save_slot = -1
    self.session_id = nil
    self.online_mode = nil
    self.multi_level = nil
    self.use_cluster_path = nil
    self.cb = cb

    self.snapshots = nil
    self.slotsnaps = {}
    self:ListSnapshots()

    self:MakeSnapshotsMenu()

    self.default_focus = self.snapshot_scroll_list
    self.focus_forward = self.snapshot_scroll_list
end)

function SnapshotTab:RefreshSnapshots()
    if self.snapshots == nil then
        return
    end
    local widgets_per_view = self.snapshot_scroll_list.widgets_per_view
    local has_scrollbar = #self.snapshots > widgets_per_view
    if not has_scrollbar and #self.snapshots < widgets_per_view then
        for i = widgets_per_view - #self.snapshots, 1, -1 do
            table.insert(self.snapshots, { empty = true })
        end
    end
    self.snapshot_scroll_list:SetList(self.snapshots)
end

function SnapshotTab:MakeSnapshotsMenu()
    local function MakeSnapshotTile(data, index, parent)
        local widget = parent:AddChild(Widget("option"))
        widget:SetScale(.8)
        widget.clickoffset = Vector3(0,-3,0)

        widget.white_bg = widget:AddChild(Image("images/ui.xml", "single_option_bg_large.tex"))
        widget.white_bg:SetScale(.63, .9)

        widget.state_bg = widget:AddChild(Image("images/ui.xml", "single_option_bg_large_gold.tex"))
        widget.state_bg:SetScale(.63, .9)
        widget.state_bg:Hide()

        widget.day = widget:AddChild(Text(NEWFONT, 35))
        widget.day:SetColour(0, 0, 0, 1)
        widget.day:SetString(STRINGS.UI.SERVERADMINSCREEN.EMPTY_SLOT)
        widget.day:SetPosition(0, 0, 0)
        widget.day:SetHAlign(ANCHOR_MIDDLE)
        widget.day:SetVAlign(ANCHOR_MIDDLE)

        widget.season = widget:AddChild(Text(NEWFONT, 28))
        widget.season:SetColour(0, 0, 0, 1)
        widget.season:SetString("")
        widget.season:SetPosition(0, 18, 0)
        widget.season:SetHAlign(ANCHOR_MIDDLE)
        widget.season:SetVAlign(ANCHOR_MIDDLE)

        widget.OnGainFocus = function(self)
            if not widget:IsEnabled() then return end
            Widget.OnGainFocus(self)
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            widget.state_bg:Show()
        end

        local screen = self
        widget.OnLoseFocus = function(self)
            if not widget:IsEnabled() then return end
            Widget.OnLoseFocus(self)
            widget.state_bg:Hide()
            if widget.o_pos ~= nil then
                widget:SetPosition(widget.o_pos)
                widget.o_pos = nil
            end
        end

        widget.OnControl = function(self, control, down)
            if not widget:IsEnabled() then return false end
            if widget.empty then return false end

            if control == CONTROL_ACCEPT then
                if down then
                    if widget.o_pos == nil then
                        widget.o_pos = widget:GetLocalPosition()
                        widget:SetPosition(widget.o_pos + widget.clickoffset)
                    end
                else
                    if widget.o_pos ~= nil then
                        widget:SetPosition(widget.o_pos)
                        widget.o_pos = nil
                    end
                    screen:OnClickSnapshot(index)
                end
                return true
            end
        end

        widget.GetHelpText = function(self)
            local controller_id = TheInput:GetControllerID()
            local t = {}
            if not widget.empty then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT).." "..STRINGS.UI.SERVERADMINSCREEN.RESTORE_SNAPSHOT)
            end
            return table.concat(t, "  ")
        end

        if data ~= nil and not data.empty then
            local day_text = STRINGS.UI.SERVERADMINSCREEN.DAY.." "..tostring(data.world_day or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_DAY)
            widget.day:SetString(day_text)
            if data.world_season ~= nil then
                widget.season:SetString(data.world_season)
                widget.day:SetPosition(0, -15, 0)
            else
                widget.season:Hide()
                widget.day:SetPosition(0, 0, 0)
            end
            widget.empty = false
        else
            widget.season:Hide()
            widget.empty = true
        end

        return widget
    end

    local function UpdateSnapshot(widget, data, index)
        if data ~= nil and not data.empty then
            local day_text = STRINGS.UI.SERVERADMINSCREEN.DAY.." "..tostring(data.world_day or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_DAY)
            widget.day:SetString(day_text)
            if data.world_season ~= nil then
                widget.season:SetString(data.world_season)
                widget.season:Show()
                widget.day:SetPosition(0, -15, 0)
            else
                widget.season:Hide()
                widget.day:SetPosition(0, 0, 0)
            end
            widget.empty = false
        else
            widget.day:SetString(STRINGS.UI.SERVERADMINSCREEN.EMPTY_SLOT)
            widget.day:SetPosition(0, 0, 0)
            widget.season:SetString("")
            widget.season:Hide()
            widget.empty = true
        end
    end

    self.snapshot_page_scroll_root = self.snapshot_page:AddChild(Widget("scroll_root"))
    self.snapshot_page_row_root = self.snapshot_page:AddChild(Widget("row_root"))

    self.snapshot_widgets = {}
    for i=1,5 do
        table.insert(self.snapshot_widgets, MakeSnapshotTile(self.snapshots[i], i, self.snapshot_page_row_root))
    end

    local tile_w = 526 --see source art
    local tile_scale_x = .63 * .8 --see above widget and bg scale
    self.snapshot_scroll_list = self.snapshot_page_scroll_root:AddChild(ScrollableList(self.snapshots, tile_w * tile_scale_x, 360, 70, 3, UpdateSnapshot, self.snapshot_widgets, nil, nil, nil, -15))
    self.snapshot_scroll_list:SetPosition(-110, 0)
    self.snapshot_scroll_list:LayOutStaticWidgets(-10)

    self.snapshot_page_row_root.OnControl = function(_self, control, down)
        return Widget.OnControl(_self, control, down)
            or (_self:IsEnabled() and self.snapshot_scroll_list:OnControl(control, down, true))
    end

    self:RefreshSnapshots()
end

function SnapshotTab:OnClickSnapshot(snapshot_num)
    if not self.snapshots[snapshot_num] then
        return
    end

    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

    local day_text = STRINGS.UI.SERVERADMINSCREEN.DAY.." "..tostring(self.snapshots[snapshot_num].world_day or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_DAY)
    local header = string.format(STRINGS.UI.SERVERADMINSCREEN.RESTORE_SNAPSHOT_HEADER, day_text)
    local popup = PopupDialogScreen(header, STRINGS.UI.SERVERADMINSCREEN.RESTORE_SNAPSHOT_BODY, {
        {
            text = STRINGS.UI.SERVERADMINSCREEN.YES,
            cb = function()
                local truncate_to_id = self.snapshots[snapshot_num].snapshot_id
                if truncate_to_id ~= nil and truncate_to_id > 0 then
                    if self.multi_level or self.use_cluster_path then
                        TheNet:TruncateSnapshotsInClusterSlot(self.save_slot, "Master", self.session_id, truncate_to_id)
                        --secondary shards will auto-truncate to synchornize at startup
                    else
                        TheNet:TruncateSnapshots(self.session_id, truncate_to_id)
                    end
                    self:ListSnapshots(true)
                    self:RefreshSnapshots()
                    if self.cb ~= nil then
                        self.cb()
                    end
                end
                TheFrontEnd:PopScreen()
            end,
        },
        {
            text = STRINGS.UI.SERVERADMINSCREEN.NO,
            cb = function()
                TheFrontEnd:PopScreen()
            end,
        },
    })
    TheFrontEnd:PushScreen(popup)
end

function SnapshotTab:ListSnapshots(force)
    if self.save_slot == nil or self.session_id == nil then
        self.snapshots = {}
    elseif not force and self.slotsnaps[self.save_slot] ~= nil then
        self.snapshots = deepcopy(self.slotsnaps[self.save_slot])
    else
        self.snapshots = {}
        local snapshot_infos, has_more
        if self.multi_level or self.use_cluster_path then
            snapshot_infos, has_more = TheNet:ListSnapshotsInClusterSlot(self.save_slot, "Master", self.session_id, self.online_mode, 10)
        else
            snapshot_infos, has_more = TheNet:ListSnapshots(self.session_id, self.online_mode, 10)
        end
        for i, v in ipairs(snapshot_infos) do
            if v.snapshot_id ~= nil then
                local info = { snapshot_id = v.snapshot_id }
                if v.world_file ~= nil then
                    local function onreadworldfile(success, str)
                        if success and str ~= nil and #str > 0 then
                            local success, savedata = RunInSandbox(str)
                            if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                                local worlddata = savedata.world_network ~= nil and savedata.world_network.persistdata or nil
                                if worlddata ~= nil then
                                    if worlddata.clock ~= nil then
                                        info.world_day = (worlddata.clock.cycles or 0) + 1
                                    end

                                    if worlddata.seasons ~= nil and worlddata.seasons.season ~= nil then
                                        info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(worlddata.seasons.season)]
                                        if info.world_season ~= nil and
                                            worlddata.seasons.elapseddaysinseason ~= nil and
                                            worlddata.seasons.remainingdaysinseason ~= nil then
                                            if worlddata.seasons.remainingdaysinseason * 3 <= worlddata.seasons.elapseddaysinseason then
                                                info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..info.world_season..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
                                            elseif worlddata.seasons.elapseddaysinseason * 3 <= worlddata.seasons.remainingdaysinseason then
                                                info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..info.world_season..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
                                            end
                                        end
                                    end
                                else
                                    info.world_day = 1
                                end
                            end
                        end
                    end
                    if self.multi_level or self.use_cluster_path then
                        TheSim:GetPersistentStringInClusterSlot(self.save_slot, "Master", v.world_file, onreadworldfile)
                    else
                        TheSim:GetPersistentString(v.world_file, onreadworldfile)
                    end
                end
                table.insert(self.snapshots, info)
            end
        end
        if #self.snapshots > 0 then
            -- Remove the first element in the table, since that's our current save
            table.remove(self.snapshots, 1)
        end
    end
end

function SnapshotTab:SetSaveSlot(save_slot, prev_slot, fromDelete)
    if not fromDelete and
        (   save_slot == self.save_slot or
            save_slot == prev_slot or
            save_slot == nil or
            prev_slot == nil    ) then
        return
    end

    self.save_slot = save_slot

    if prev_slot ~= nil and prev_slot > 0 then
        -- remember snapshots
        self.slotsnaps[prev_slot] =
            not SaveGameIndex:IsSlotEmpty(prev_slot)
            and deepcopy(self.snapshots)
            or nil
    end

    local server_data = SaveGameIndex:GetSlotServerData(save_slot)
    self.session_id = SaveGameIndex:GetSlotSession(save_slot)
    self.online_mode = server_data.online_mode ~= false
    self.multi_level = SaveGameIndex:IsSlotMultiLevel(save_slot)
    self.use_cluster_path = server_data.use_cluster_path == true

    self:ListSnapshots(fromDelete)
    self:RefreshSnapshots()
end

return SnapshotTab
