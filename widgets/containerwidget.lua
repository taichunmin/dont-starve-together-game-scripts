require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"

local ContainerWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "Container")
    local scale = .6
    self:SetScale(scale,scale,scale)
    self.open = false
    self.inv = {}
    self.owner = owner
    self:SetPosition(0, 0, 0)
    self.slotsperrow = 3

    self.bganim = self:AddChild(UIAnim())
    self.bgimage = self:AddChild(Image())
    self.bganim:GetAnimState():AnimateWhilePaused(false)
    self.isopen = false
end)

function ContainerWidget:Open(container, doer)
    self:Close()

    local widget = container.replica.container:GetWidget()

    if widget.bgatlas ~= nil and widget.bgimage ~= nil then
        self.bgimage:SetTexture(widget.bgatlas, widget.bgimage)
    end

    if widget.animbank ~= nil then
        self.bganim:GetAnimState():SetBank(widget.animbank)
    end

    if widget.animbuild ~= nil then
        self.bganim:GetAnimState():SetBuild(widget.animbuild)
    end

    if widget.pos ~= nil then
        self:SetPosition(widget.pos)
    end

    if widget.buttoninfo ~= nil then
        if doer ~= nil and doer.components.playeractionpicker ~= nil then
            doer.components.playeractionpicker:RegisterContainer(container)
        end

        self.button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, {1,1}, {0,0}))
        self.button.image:SetScale(1.07)
        self.button.text:SetPosition(2,-2)
        self.button:SetPosition(widget.buttoninfo.position)
        self.button:SetText(widget.buttoninfo.text)
        if widget.buttoninfo.fn ~= nil then
            self.button:SetOnClick(function()
                if doer ~= nil then
                    if doer:HasTag("busy") then
                        --Ignore button click when doer is busy
                        return
                    elseif doer.components.playercontroller ~= nil then
                        local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                        if not (iscontrolsenabled or ishudblocking) then
                            --Ignore button click when controls are disabled
                            --but not just because of the HUD blocking input
                            return
                        end
                    end
                end
                widget.buttoninfo.fn(container, doer)
            end)
        end
        self.button:SetFont(BUTTONFONT)
        self.button:SetDisabledFont(BUTTONFONT)
        self.button:SetTextSize(33)
        self.button.text:SetVAlign(ANCHOR_MIDDLE)
        self.button.text:SetColour(0, 0, 0, 1)

        if widget.buttoninfo.validfn ~= nil then
            if widget.buttoninfo.validfn(container) then
                self.button:Enable()
            else
                self.button:Disable()
            end
        end

        if TheInput:ControllerAttached() then
            self.button:Hide()
        end

        self.button.inst:ListenForEvent("continuefrompause", function()
            if TheInput:ControllerAttached() then
                self.button:Hide()
            else
                self.button:Show()
            end
        end, TheWorld)
    end

    self.isopen = true
    self:Show()

    if self.bgimage.texture then
        self.bgimage:Show()
    else
        self.bganim:GetAnimState():PlayAnimation("open")
    end

    self.onitemlosefn = function(inst, data) self:OnItemLose(data) end
    self.inst:ListenForEvent("itemlose", self.onitemlosefn, container)

    self.onitemgetfn = function(inst, data) self:OnItemGet(data) end
    self.inst:ListenForEvent("itemget", self.onitemgetfn, container)

    self.onrefreshfn = function(inst, data) self:Refresh() end
    self.inst:ListenForEvent("refresh", self.onrefreshfn, container)

    local constructionsite = doer.components.constructionbuilderuidata ~= nil and doer.components.constructionbuilderuidata:GetContainer() == container and doer.components.constructionbuilderuidata:GetConstructionSite() or nil
    local constructionmats = constructionsite ~= nil and constructionsite:GetIngredients() or nil

    for i, v in ipairs(widget.slotpos or {}) do
        local bgoverride = widget.slotbg ~= nil and widget.slotbg[i] or nil
        local slot = InvSlot(i,
            bgoverride ~= nil and bgoverride.atlas or "images/hud.xml",
            bgoverride ~= nil and bgoverride.image or (constructionmats ~= nil and "inv_slot_construction.tex" or "inv_slot.tex"),
            self.owner,
            container.replica.container
        )
        self.inv[i] = self:AddChild(slot)

        slot:SetPosition(v)

        if not container.replica.container:IsSideWidget() then
            if widget.top_align_tip ~= nil then
                slot.top_align_tip = widget.top_align_tip
            else
                slot.side_align_tip = (widget.side_align_tip or 0) - v.x
            end
        end

        if constructionmats ~= nil then
            slot:ConvertToConstructionSlot(constructionmats[i], constructionsite:GetSlotCount(i))
        end
    end

    self.container = container

    self:Refresh()
end

function ContainerWidget:Refresh()
    local items = self.container.replica.container:GetItems()
    for k, v in pairs(self.inv) do
        local item = items[k]
        if item == nil then
            if v.tile ~= nil then
                v:SetTile(nil)
            end
        elseif v.tile == nil or v.tile.item ~= item then
            v:SetTile(ItemTile(item))
        else
            v.tile:Refresh()
        end
    end
end

local function RefreshButton(inst, self)
    if self.isopen then
        local widget = self.container.replica.container:GetWidget()
        if widget ~= nil and widget.buttoninfo ~= nil and widget.buttoninfo.validfn ~= nil then
            if widget.buttoninfo.validfn(self.container) then
                self.button:Enable()
            else
                self.button:Disable()
            end
        end
    end
end

function ContainerWidget:OnItemGet(data)
    if data.slot and self.inv[data.slot] then
        local tile = ItemTile(data.item)
        self.inv[data.slot]:SetTile(tile)
        tile:Hide()
        tile.ignore_stacksize_anim = data.ignore_stacksize_anim

        if data.src_pos ~= nil then
            local dest_pos = self.inv[data.slot]:GetWorldPosition()
            local im = Image(data.item.replica.inventoryitem:GetAtlas(), data.item.replica.inventoryitem:GetImage())
            im:MoveTo(Vector3(TheSim:GetScreenPos(data.src_pos:Get())), dest_pos, .3, function() tile:Show() im:Kill() end)
        else
            tile:Show()
        end
    end

    if self.button ~= nil and self.container ~= nil then
        RefreshButton(self.inst, self)
        self.inst:DoTaskInTime(0, RefreshButton, self)
    end
end

function ContainerWidget:OnItemLose(data)
    local tileslot = self.inv[data.slot]
    if tileslot then
        tileslot:SetTile(nil)
    end

    if self.button ~= nil and self.container ~= nil then
        RefreshButton(self.inst, self)
        self.inst:DoTaskInTime(0, RefreshButton, self)
    end
end

function ContainerWidget:Close()
    if self.isopen then
        if self.button ~= nil then
            self.button:Kill()
            self.button = nil
        end

        if self.container ~= nil then
            if self.owner ~= nil and self.owner.components.playeractionpicker ~= nil then
                self.owner.components.playeractionpicker:UnregisterContainer(self.container)
            end
            if self.onitemlosefn ~= nil then
                self.inst:RemoveEventCallback("itemlose", self.onitemlosefn, self.container)
                self.onitemlosefn = nil
            end
            if self.onitemgetfn ~= nil then
                self.inst:RemoveEventCallback("itemget", self.onitemgetfn, self.container)
                self.onitemgetfn = nil
            end
            if self.onrefreshfn ~= nil then
                self.inst:RemoveEventCallback("refresh", self.onrefreshfn, self.container)
                self.onrefreshfn = nil
            end
        end

        for k,v in pairs(self.inv) do
            v:Kill()
        end

        self.container = nil
        self.inv = {}
        if self.bgimage.texture then
            self.bgimage:Hide()
        else
            self.bganim:GetAnimState():PlayAnimation("close")
        end

        self.isopen = false

        self.inst:DoSimTaskInTime(.3, function() self.should_close_widget = true end)
    end
end

return ContainerWidget
