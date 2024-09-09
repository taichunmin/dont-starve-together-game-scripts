local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local Widget = require "widgets/widget"


local item_width = 900
local item_height = 65

local SnapshotTab = Class(Widget, function(self, cb)
    Widget._ctor(self, "SnapshotTab")

    self.snapshot_page = self:AddChild(Widget("snapshot_page"))

    self.save_slot = -1
    self.session_id = nil
    self.online_mode = nil
    self.multi_level = nil
    self.use_legacy_session_path = nil
    self.cb = cb

    self.snapshots = nil
    self.slotsnaps = {}
    self:ListSnapshots()

    self:MakeSnapshotsMenu()

    self.focus_forward = self.snapshot_scroll_list
end)

function SnapshotTab:RefreshSnapshots()
    if self.snapshots == nil then
        return
    end

    --Fill with empty options if we don't have enough saved
    local widgets_per_view = self.snapshot_scroll_list.visible_rows
    local has_scrollbar = #self.snapshots > widgets_per_view
    if not has_scrollbar and #self.snapshots < widgets_per_view then
        for i = widgets_per_view - #self.snapshots, 1, -1 do
            table.insert(self.snapshots, { empty = true })
        end
    end
    self.snapshot_scroll_list:SetItemsData(self.snapshots)
end

function SnapshotTab:MakeSnapshotsMenu()
    local function MakeSnapshotTile(context, index)
        local widget = Widget("option")

        widget.btn = widget:AddChild(TEMPLATES.ListItemBackground(
                item_width,
                item_height,
                function()
                    if widget.empty then return end

                    self:OnClickSnapshot(index)
                end))
        widget.btn.move_on_click = true
        widget.focus_forward = widget.btn

        widget.day_and_season = widget.btn:AddChild(Text(NEWFONT, 34))
        widget.day_and_season:SetColour(UICOLOURS.GOLD)
        widget.day_and_season:SetString(STRINGS.UI.SERVERADMINSCREEN.EMPTY_SLOT)
        widget.day_and_season:SetPosition(0, 0, 0)
        widget.day_and_season:SetHAlign(ANCHOR_MIDDLE)
        widget.day_and_season:SetVAlign(ANCHOR_MIDDLE)

        widget.ongainfocusfn = function(is_btn_enabled)
            self.snapshot_scroll_list:OnWidgetFocus(widget)
        end

        return widget
    end

    local function UpdateSnapshot(context, widget, data, index)
        widget.btn:Show()

        if not data then
            widget.btn:Hide()

        elseif not data.empty then
            local day_text = ""
            if data.world_day ~= nil then
                day_text = subfmt(STRINGS.UI.SERVERADMINSCREEN.DAY_V2, {day_count = data.world_day} )
            else
                day_text = STRINGS.UI.SERVERADMINSCREEN.DAY_UNKNOWN
            end


            if data.world_season ~= nil then
                day_text = day_text .. " - " .. data.world_season
            end

            widget.day_and_season:SetString(day_text)
            widget.empty = false

        elseif data.empty then
            widget.day_and_season:SetString(STRINGS.UI.SERVERADMINSCREEN.EMPTY_SLOT)
            widget.day_and_season:SetPosition(0, 0, 0)
            widget.empty = true
        end
    end

    self.snapshot_page_scroll_root = self.snapshot_page:AddChild(Widget("scroll_root"))

    local extra_rows = 0

    self.snapshot_scroll_list = self.snapshot_page_scroll_root:AddChild(TEMPLATES.ScrollingGrid(
            self.snapshots,
            {
                scroll_context = {
                },
                widget_width  = item_width,
                widget_height = item_height,
                num_visible_rows = 5,
                num_columns = 1,
                item_ctor_fn = MakeSnapshotTile,
                apply_fn = UpdateSnapshot,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60,
                peek_percent = 0.25,
                extra_rows = extra_rows,
            }
        ))

    self:RefreshSnapshots()
end

function SnapshotTab:OnClickSnapshot(snapshot_num)
    if not self.snapshots[snapshot_num] then
        return
    end

    local day_text_header = ""
    if self.snapshots[snapshot_num].world_day ~= nil then
        day_text_header = subfmt(STRINGS.UI.SERVERADMINSCREEN.HEADER_DAY, {day_count = self.snapshots[snapshot_num].world_day} )
    else
        day_text_header = STRINGS.UI.SERVERADMINSCREEN.HEADER_DAY_UNKNOWN
    end

    local popup = PopupDialogScreen(day_text_header, STRINGS.UI.SERVERADMINSCREEN.RESTORE_SNAPSHOT_BODY, {
        {
            text = STRINGS.UI.SERVERADMINSCREEN.YES,
            cb = function()
                local truncate_to_id = self.snapshots[snapshot_num].snapshot_id
                if truncate_to_id ~= nil and truncate_to_id > 0 then
                    if self.multi_level or not self.use_legacy_session_path then
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

function SnapshotTab:ListSnapshots()
    if self.save_slot == nil or self.session_id == nil then
        self.snapshots = {}
    else
        self.snapshots = {}
        local snapshot_infos, has_more
        if self.multi_level or not self.use_legacy_session_path then
            snapshot_infos, has_more = TheNet:ListSnapshotsInClusterSlot(self.save_slot, "Master", self.session_id, self.online_mode, 10)
        else
            snapshot_infos, has_more = TheNet:ListSnapshots(self.session_id, self.online_mode, 10)
        end
        for i, v in ipairs(snapshot_infos) do
            if v.snapshot_id ~= nil then
                local info = { snapshot_id = v.snapshot_id }
                if v.world_file ~= nil then
                    local function onreadmetafile(success, str, slot, shard, file)
                        if success then
                            if str ~= nil and #str > 0 then
                                local success, metadata = RunInSandbox(str)
                                if success and metadata ~= nil and GetTableSize(metadata) > 0 then
                                    if metadata.clock ~= nil then
                                        info.world_day = (metadata.clock.cycles or 0) + 1
                                    end

                                    if metadata.seasons ~= nil and metadata.seasons.season ~= nil then
                                        info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(metadata.seasons.season)]
                                        if info.world_season ~= nil and
                                            metadata.seasons.elapseddaysinseason ~= nil and
                                            metadata.seasons.remainingdaysinseason ~= nil then
                                            if metadata.seasons.remainingdaysinseason * 3 <= metadata.seasons.elapseddaysinseason then
                                                info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..info.world_season..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
                                            elseif metadata.seasons.elapseddaysinseason * 3 <= metadata.seasons.remainingdaysinseason then
                                                info.world_season = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..info.world_season..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
                                            end
                                        end
                                    end
                                else
                                    info.world_day = 1
                                end
                            end
                        else
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

                            if slot and shard then
                                TheSim:GetPersistentStringInClusterSlot(slot, shard, file, onreadworldfile)
                            else
                                TheSim:GetPersistentString(file, onreadworldfile)
                            end
                        end
                    end

                    if self.multi_level or not self.use_legacy_session_path then
                        TheSim:GetPersistentStringInClusterSlot(self.save_slot, "Master", v.world_file..".meta", function(success, str)
                            onreadmetafile(success, str, self.save_slot, "Master", v.world_file)
                        end)
                    else
                        TheSim:GetPersistentString(v.world_file..".meta", function(success, str)
                            onreadmetafile(success, str, nil, nil, v.world_file)
                        end)
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

function SnapshotTab:UpdateSaveSlot(save_slot)
    self.save_slot = save_slot
end

function SnapshotTab:SetDataForSlot(save_slot)
    self.save_slot = save_slot

    local server_data = ShardSaveGameIndex:GetSlotServerData(save_slot)
    self.session_id = ShardSaveGameIndex:GetSlotSession(save_slot, "Master")
    self.online_mode = server_data.online_mode ~= false
    self.multi_level = ShardSaveGameIndex:IsSlotMultiLevel(save_slot)
    self.use_legacy_session_path = server_data.use_legacy_session_path == true

    self:ListSnapshots()
    self:RefreshSnapshots()
end

return SnapshotTab
