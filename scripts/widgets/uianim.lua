local Widget = require "widgets/widget"

local UIAnim = Class(Widget, function(self)
    Widget._ctor(self, "UIAnim")
    self.inst.entity:AddAnimState()
end)

function UIAnim:GetAnimState()
    return self.inst.AnimState
end

function UIAnim:SetFacing(dir)
	self.inst.UITransform:SetFacing(dir)
end

function UIAnim:GetBoundingBoxSize()
    local x1, y1, x2, y2 = self.inst.AnimState:GetVisualBB()
    local width, height = x2 - x1, y2 - y1
    local scale = self:GetScale()
    return width * scale.x, height * scale.y
end

function UIAnim:GetVisualBB()
    local x1, y1, x2, y2 = self.inst.AnimState:GetVisualBB()
    local scale = self:GetScale()
    return x1 * scale.x, y1 * scale.y, x2 * scale.x, y2 * scale.y
end

function UIAnim:DebugDraw_AddSection(dbui, panel)
    UIAnim._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("UIAnim")
    dbui.Indent() do
        local animstate = self:GetAnimState()
        if animstate then
            dbui.Value("AnimDone", animstate:AnimDone())
            dbui.Value("CurrentFacing", animstate:GetCurrentFacing())
            dbui.ValueColor("AddColour", animstate:GetAddColour())
            dbui.ValueColor("MultColour", animstate:GetMultColour())
            dbui.Value("CurrentAnimationTime", animstate:GetCurrentAnimationTime(), "%.3f")
            if dbui.TreeNode("Might crash") then
                -- If the underlying animation is null, then
                -- GetCurrentAnimationLength will assert. Should be safe to
                -- expand if AnimDone == true, but that's not very helpful.
                dbui.Value("CurrentAnimationLength", animstate:GetCurrentAnimationLength(), "%.3f")
                dbui.TreePop()
            end
        end
    end
    dbui.Unindent()
end

return UIAnim
