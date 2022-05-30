local Widget = Class(function(self, name)
	name = name or "widget"
    self.children = {}
    self.callbacks = {}
    self.name = name

    self.inst = CreateEntity()
    --if your widget does something that is based on gameplay, use these over the default, so that pausing freezes the effect.
    self.inst.DoSimPeriodicTask = self.inst.DoPeriodicTask
    self.inst.DoSimTaskInTime = self.inst.DoTaskInTime
    self.inst.widget = self
	self.inst.name = name

    self.inst:AddTag("widget")
    self.inst:AddTag("UI")
    self.inst.entity:SetName(name)
    self.inst.entity:AddUITransform()
    self.inst.entity:CallPrefabConstructionComplete()

    self.inst:AddComponent("uianim")

    self:UpdateWhilePaused(true)

    self.enabled = true
    self.shown = true
    self.focus = false
    self.focus_target = false
    self.can_fade_alpha = true

    self.focus_flow = {}
    self.focus_flow_args = {}
end)

function Widget:UpdateWhilePaused(update_while_paused)
    if update_while_paused then
        --widgets run all their tasks on StaticUpdate instead of Update so pausing the server doesn't pause widget tasks.
        self.inst.DoPeriodicTask = self.inst.DoStaticPeriodicTask
        self.inst.DoTaskInTime = self.inst.DoStaticTaskInTime
    else
        self.inst.DoPeriodicTask = self.inst.DoSimPeriodicTask
        self.inst.DoTaskInTime = self.inst.DoSimTaskInTime
    end
    self.inst.components.uianim:UpdateWhilePaused(update_while_paused)
end

function Widget:IsDeepestFocus()
    if self.focus then
        for k,v in pairs(self.children) do
            if v.focus then return false end
        end
    end

    return true
end

function Widget:OnMouseButton(button, down, x, y)
    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnMouseButton(button, down, x, y) then return true end
    end
end

function Widget:MoveToBack()
    self.inst.entity:MoveToBack()
end

function Widget:MoveToFront()
    self.inst.entity:MoveToFront()
end

function Widget:OnFocusMove(dir, down)
    --print ("OnFocusMove", self.name or "?", self.focus, dir, down)
    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnFocusMove(dir, down) then return true end
    end

    if down and self.focus_flow[dir] then
        local dest = FunctionOrValue(self.focus_flow[dir], self)

        -- Can we pass the focus down the chain if we are disabled/hidden?
        if dest and dest:IsVisible() and dest.enabled then
            if self.focus_flow_args[dir] then
                dest:SetFocus(unpack(self.focus_flow_args[dir]))
            else
                dest:SetFocus()
            end
            return true
        end
    end

    if self.parent_scroll_list then
        return self.parent_scroll_list:OnFocusMove(dir, down)
    end

    return false
end

function Widget:IsVisible()
    return self.shown and (self.parent == nil or self.parent:IsVisible())
end

function Widget:OnRawKey(key, down)
    if not self.focus then return false end
    for k,v in pairs (self.children) do
        if v.focus and v:OnRawKey(key, down) then return true end
    end
end

function Widget:OnTextInput(text)
    --print ("text", self, text)
    if not self.focus then return false end
    for k,v in pairs (self.children) do
        if v.focus and v:OnTextInput(text) then return true end
    end
end

function Widget:OnStopForceProcessTextInput()
end

function Widget:OnControl(control, down)
--    print("oncontrol", self, control, down, self.focus)

    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnControl(control, down) then return true end
    end

    if self.parent_scroll_list and (control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD) then
        return self.parent_scroll_list:OnControl(control, down, true)
    end

    return false
end

function Widget:SetParentScrollList(list)
    self.parent_scroll_list = list
end

function Widget:IsEditing()
    --recursive check to see if anything has text edit focus
    if self.editing then
        return true
    end

    for k, v in pairs(self.children) do
        if v:IsEditing() then
            return true
        end
    end

    return false
end

function Widget:CancelScaleTo(run_complete_fn)
    if self.inst.components.uianim ~= nil then
        self.inst.components.uianim:CancelScaleTo(run_complete_fn)
    end
end

function Widget:ScaleTo(from, to, time, fn)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ScaleTo(from, to, time, fn)
end

function Widget:CancelMoveTo(run_complete_fn)
    if self.inst.components.uianim ~= nil then
        self.inst.components.uianim:CancelMoveTo(run_complete_fn)
    end
end

function Widget:MoveTo(from, to, time, fn)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:MoveTo(from, to, time, fn)
end

function Widget:CancelRotateTo(run_complete_fn)
    if self.inst.components.uianim ~= nil then
        self.inst.components.uianim:CancelRotateTo(run_complete_fn)
    end
end

function Widget:RotateTo(from, to, time, fn, infinite)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:RotateTo(from, to, time, fn, infinite)
end

function Widget:CancelTintTo(run_complete_fn)
    if self.inst.components.uianim ~= nil then
        self.inst.components.uianim:CancelTintTo(run_complete_fn)
    end
end

function Widget:TintTo(from, to, time, fn)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:TintTo(from, to, time, fn)
end

function Widget:ForceStartWallUpdating()
    if IsConsole() then
        return --disabled for console
    end
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ForceStartWallUpdating(self)
end

function Widget:ForceStopWallUpdating()
    if IsConsole() then
        return --disabled for console
    end
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ForceStopWallUpdating(self)
end


function Widget:IsEnabled()
    if not self.enabled then return false end

    if self.parent then
        return self.parent:IsEnabled()
    end

    return true
end

function Widget:GetParent()
    return self.parent
end

function Widget:GetParentScreen()
    --check for a cached version
    if self.parent_screen then
        return self.parent_screen
    end

    local parent = self.parent
    while( not parent.is_screen )
    do
        parent = parent:GetParent()
    end
    self.parent_screen = parent
    return self.parent_screen
end

function Widget:GetChildren()
    return self.children
end

function Widget:Enable()
    self.enabled = true
    self:OnEnable()
end

function Widget:Disable()
    self.enabled = false
    self:OnDisable()
end

function Widget:OnEnable()
end

function Widget:OnDisable()
end

function Widget:RemoveChild(child)
    if child then
        self.children[child] = nil
        child.parent = nil
        child.inst.entity:SetParent(nil)
    end

end

function Widget:KillAllChildren()
    for k,v in pairs(self.children) do
        self:RemoveChild(k)
        k:Kill()
    end

    self:ClearHoverText()
end

function Widget:AddChild(child)
    if child.parent then
        child.parent.children[child] = nil
    end

    self.children[child] = child
    child.parent = self
    child.inst.entity:SetParent(self.inst.entity)
    return child
end

function Widget:Hide()
    self.inst.entity:Hide(false)
    local was_visible = self.shown == true
    self.shown = false
    self:OnHide(was_visible)
end

function Widget:Show()
    self.inst.entity:Show(false)
    local was_hidden = self.shown == false
    self.shown = true
    self:OnShow(was_hidden)
end

function Widget:Kill()
    self:StopUpdating()
    self:KillAllChildren()
    if self.parent then
        self.parent.children[self] = nil
    end
    self.inst.widget = nil
    self:StopFollowMouse()
    self.inst:Remove()
end

function Widget:GetWorldPosition()
    return Vector3(self.inst.UITransform:GetWorldPosition())
end

function Widget:GetPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:GetPositionXYZ()
    return self.inst.UITransform:GetLocalPosition()
end

function Widget:GetWorldScale()
    return Vector3(self.inst.UITransform:GetWorldScale())
end

function Widget:Nudge(offset)
    local o_pos = self:GetLocalPosition()
    local n_pos = o_pos + offset
    self:SetPosition(n_pos)
end

function Widget:GetLocalPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:SetPosition(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetPosition(pos, y, z or 0)
    else
        if not self.inst:IsValid() then
            print(debugstack())
        end
        self.inst.UITransform:SetPosition(pos:Get())
    end
end

function Widget:SetRotation(angle)
    self.inst.UITransform:SetRotation(angle)
end

function Widget:SetMaxPropUpscale(val)
    self.inst.UITransform:SetMaxPropUpscale(val)
end

function Widget:SetScaleMode(mode)
    self.inst.UITransform:SetScaleMode(mode)
end

function Widget:SetScale(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetScale(pos, y or pos, z or pos)
    else
        self.inst.UITransform:SetScale(pos.x,pos.y,pos.z)
    end
end

function Widget:HookCallback(event, fn)
    if self.callbacks[event] then
        self.inst:RemoveEventCallback(event, self.callbacks[event])
    end
    self.callbacks[event] = fn
    self.inst:ListenForEvent(event, fn)
end

function Widget:UnhookCallback(event)
    if self.callbacks[event] then
        self.inst:RemoveEventCallback(event, self.callbacks[event])
        self.callbacks[event] = nil
    end
end

function Widget:SetVAnchor(anchor)
    self.inst.UITransform:SetVAnchor(anchor)
end

function Widget:SetHAnchor(anchor)
    self.inst.UITransform:SetHAnchor(anchor)
end

function Widget:OnShow(was_hidden)
end

function Widget:OnHide(was_visible)
end

function Widget:SetTooltip(str)
    self.tooltip = str
end

function Widget:SetTooltipPos(pos, pos_y, pos_z)
    if type(pos) == "number" then
        self.tooltip_pos = Vector3(pos, pos_y, pos_z)
    else
        if not self.inst:IsValid() then
            print(debugstack())
        end
        self.tooltip_pos = pos
    end
end

function Widget:SetTooltipColour(r, g, b, a)
    self.tooltipcolour = { r, g, b, a }
end

function Widget:GetTooltipColour()
    if self.focus then
        for k, v in pairs(self.children) do
            local col = k:GetTooltipColour()
            if col ~= nil then
                return col
            end
        end
        return self.tooltipcolour
    end
end

function Widget:GetTooltip()
    if self.focus then
        for k, v in pairs(self.children) do
            local str = k:GetTooltip()
            if str ~= nil then
                return str
            end
        end
        return self.tooltip
    end
end

function Widget:GetTooltipPos()
   if self.focus then
        for k, v in pairs(self.children) do
            local t_pos = k:GetTooltipPos()
            if t_pos ~= nil then
                return t_pos
            end
        end
        return self.tooltip_pos
    end
end

function Widget:StartUpdating()
    TheFrontEnd:StartUpdatingWidget(self)
end

function Widget:StopUpdating()
    TheFrontEnd:StopUpdatingWidget(self)
end

--[[function Widget:Update(dt)
    if not self.enabled then return end
    if self.OnUpdate ~= nil then
        self:OnUpdate(dt)
    end

    for k, v in pairs(self.children) do
        if v.OnUpdate ~= nil or #v.children > 0 then
            v:Update(dt)
        end
    end
end--]]

function Widget:SetFadeAlpha(alpha, skipChildren)
    if not self.can_fade_alpha then return end

    if not skipChildren and self.children then
        for k,v in pairs(self.children) do
            v:SetFadeAlpha(alpha, skipChildren)
        end
    end
end

function Widget:SetCanFadeAlpha(fade, skipChildren)
    self.can_fade_alpha = fade

    if not skipChildren and self.children then
        for k,v in pairs(self.children) do
            v:SetCanFadeAlpha(fade, skipChildren)
        end
    end
end

function Widget:SetClickable(val)
    self.inst.entity:SetClickable(val)
end

function Widget:UpdatePosition(x, y)
    self:SetPosition(x, y, 0)
end

function Widget:FollowMouse()
    if self.followhandler == nil then
        self.followhandler = TheInput:AddMoveHandler(function(x, y) self:UpdatePosition(x, y) end)
        self:SetPosition(TheInput:GetScreenPosition())
    end
end

function Widget:StopFollowMouse()
    if self.followhandler ~= nil then
        self.followhandler:Remove()
        self.followhandler = nil
    end
end

function Widget:GetScale()
    if self.parent ~= nil then
        local sx, sy, sz = self.inst.UITransform:GetScale()
        local scale = self.parent:GetScale()
        return Vector3(sx * scale.x, sy * scale.y, sz * scale.z)
    end
    return Vector3(self.inst.UITransform:GetScale())
end

function Widget:GetLooseScale()
    return self.inst.UITransform:GetScale()
end

---------------------------focus management

function Widget:OnGainFocus()
end

function Widget:OnLoseFocus()
end

function Widget:SetOnGainFocus( fn )
    self.ongainfocusfn = fn
end

function Widget:SetOnLoseFocus( fn )
    self.onlosefocusfn = fn
end

function Widget:ClearFocusDirs()
    self.focus_flow = {}
	self.focus_flow_args = {}
	self.next_in_tab_order = nil
end

function Widget:SetFocusChangeDir(dir, widget, ...)
    if not next(self.focus_flow) then
        self.next_in_tab_order = widget
    end

    self.focus_flow[dir] = widget
    self.focus_flow_args[dir] = toarrayornil(...)
end

function Widget:GetDeepestFocus()
    if self.focus then
        for k,v in pairs(self.children) do
            if v.focus then
                return v:GetDeepestFocus()
            end
        end

        return self
    end
end

function Widget:GetFocusChild()
    if self.focus then
        for k,v in pairs(self.children) do
            if v.focus then
                return v
            end
        end
    end
    return nil
end

function Widget:ClearFocus()
    if self.focus then
        self.focus = false
        if self.OnLoseFocus then
            self:OnLoseFocus()
        end
        if self.onlosefocusfn then
            self.onlosefocusfn()
        end
        for k,v in pairs(self.children) do
            if v.focus then
                v:ClearFocus()
            end
        end
    end
end

function Widget:SetFocusFromChild(from_child)
    if self.parent == nil and not self.is_screen then
        print("Warning: Widget:SetFocusFromChild is happening on a widget outside of the screen/widget hierachy. This will cause focus moves to fail. Is ", self.name, "not a screen?")
        print(debugstack())
    end
    for k,v in pairs(self.children) do
        if v ~= from_child and v.focus then
            v:ClearFocus()
        end
    end

    if not self.focus then
        self.focus = true
        if self.OnGainFocus then
             self:OnGainFocus()
        end

        if self.ongainfocusfn then
            self.ongainfocusfn()
        end

        if self.parent then
            self.parent:SetFocusFromChild(self)
        end
    end
end

function Widget:SetFocus()
  --  print ("SET FOCUS ", self)
    local focus_forward = FunctionOrValue(self.focus_forward)
    if focus_forward then
        focus_forward:SetFocus()
        return
    end

    if not self.focus then
        self.focus = true

        if self.OnGainFocus then
            self:OnGainFocus()
        end

        if self.ongainfocusfn then
            self.ongainfocusfn()
        end

        if self.parent then
            self.parent:SetFocusFromChild(self)
        end
    end

    for k,v in pairs(self.children) do
        v:ClearFocus()
    end

    --print(debugstack())
end

function Widget:GetStr(indent)
    indent = indent or 0
    local indent_str = string.rep("\t",indent)

    local str = {}
    table.insert(str, string.format("%s%s%s%s\n", indent_str, tostring(self), self.focus and " (FOCUS) " or "", self.enabled and " (ENABLE) " or "" ))

    for k,v in pairs(self.children) do
        table.insert(str, v:GetStr(indent + 1))
    end

    return table.concat(str)
end

function Widget:__tostring()
    return tostring(self.name)
end

function Widget:SetHoverText(text, params)
    if text and text ~= "" then
        if not self.hovertext then
            local ImageButton = require "widgets/imagebutton"
            local Text = require "widgets/text"

            if params == nil then
                params = {}
            end

			if params.attach_to_parent ~= nil then
				self.hovertext_root = params.attach_to_parent:AddChild(Widget("hovertext_root"))
			else
			    self.hovertext_root = Widget("hovertext_root")
				self.hovertext_root.global_widget = true
				self.hovertext_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
			end
			self.hovertext_root:Hide()

            if params.bg ~= false then
                self.hovertext_bg = self.hovertext_root:AddChild(Image(params.bg_atlas or "images/frontend.xml", params.bg_texture or "scribble_black.tex"))
                self.hovertext_bg:SetTint(1,1,1,.8)
                self.hovertext_bg:SetClickable(false)
            end

			self.hovertext = self.hovertext_root:AddChild(Text(params.font or NEWFONT_OUTLINE, params.font_size or 22, text))
            self.hovertext:SetClickable(false)
            self.hovertext:SetScale(1.1,1.1)

            if params.region_h ~= nil or params.region_w ~= nil then
                self.hovertext:SetRegionSize(params.region_w or 1000, params.region_h or 40)
            end

            if params.wordwrap ~= nil then
                --print("Enabling word wrap", params.wordwrap)
                self.hovertext:EnableWordWrap(params.wordwrap)
            end

            if params.colour then
                self.hovertext:SetColour(params.colour)
            end

            if params.bg == nil or params.bg == true then
                local w, h = self.hovertext:GetRegionSize()
                self.hovertext_bg:SetSize(w*1.5, h*2.0)
            end


            local hover_parent = self.text or self
            if hover_parent.GetString ~= nil and hover_parent:GetString() ~= "" then
                --Note(Peter): This block is here because Text widgets don't receive OnGainFocus calls.
                self.hover = hover_parent:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", nil, nil, {1,1}, {0,0}))
                self.hover.image:ScaleToSize(hover_parent:GetRegionSize())

                self.hover.OnGainFocus = function()
                    local world_pos = self:GetWorldPosition()
                    local x_pos = world_pos.x + (params.offset_x or 0)
                    local y_pos = world_pos.y + (params.offset_y or 26)
                    self.hovertext_root:SetPosition(x_pos, y_pos)
                    self.hovertext_root:Show()
                end
                self.hover.OnLoseFocus = function()
                    self.hovertext_root:Hide()
                end
            else
                self._OnGainFocus = self.OnGainFocus --save these fns so we can undo the hovertext on focus when clearing the text
                self._OnLoseFocus = self.OnLoseFocus

                self.OnGainFocus = function()
					if params.attach_to_parent ~= nil then
						local world_pos = self:GetWorldPosition() - params.attach_to_parent:GetWorldPosition()
						local parent_scale = params.attach_to_parent:GetScale()

						local x_pos = world_pos.x / parent_scale.x + (params.offset_x or 0)
						local y_pos = world_pos.y / parent_scale.y + (params.offset_y or 26)
						self.hovertext_root:SetPosition(x_pos, y_pos)

						self.hovertext_root:MoveToFront()
					else
						local world_pos = self:GetWorldPosition()
						local x_pos = world_pos.x + (params.offset_x or 0)
						local y_pos = world_pos.y + (params.offset_y or 26)
						self.hovertext_root:SetPosition(x_pos, y_pos)
					end
					self.hovertext_root:Show()

                    self._OnGainFocus( self )
                end
                self.OnLoseFocus = function()
                    self.hovertext_root:Hide()
                    self._OnLoseFocus( self )
                end
            end
        else
            self.hovertext:SetString(text)
            if params and params.colour then
                self.hovertext:SetColour(params.colour)
            end
            if self.hovertext_bg then
                local w, h = self.hovertext:GetRegionSize()
                self.hovertext_bg:SetSize(w*1.5, h*2.0)
            end
        end
    end
end


function Widget:ClearHoverText()
    if self.hovertext_root ~= nil then
        self.hovertext_root:Kill()
        self.hovertext_root = nil
        self.hovertext = nil
        self.hovertext_bg = nil

        if self._OnGainFocus then
            self.OnGainFocus = self._OnGainFocus
            self.OnLoseFocus = self._OnLoseFocus

			self._OnGainFocus = nil
			self._OnLoseFocus = nil
        end
    end
    if self.hover ~= nil then
        self.hover:Kill()
        self.hover = nil
    end
end

function Widget:SetScissor(x, y, w, h)
    self.inst.UITransform:SetScissor(x, y, w, h)
end

return Widget
