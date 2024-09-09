local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local ROWS = 5
local ANIM_IDLES = 7
local POS_INDEX = {
    [1] = -5,
    [2] = -2.5,
    [3] = 0,
    [4] = 2.5,
    [5] = 5,
}

local function getxoffset()
    return (math.random()*400)-200
end

local ROW_ANIMS = {}

local function setnewanim(widget)
    local newnum = math.random(1,ANIM_IDLES)

    local row1 = widget.anim_row + 1
    local row2 = widget.anim_row - 1
    if row1 > ROWS then row1 = 1 end
    if row2 < 1 then row2 = ROWS end

    while newnum == ROW_ANIMS[row1][widget.anim_pos] or
          newnum == ROW_ANIMS[row2][widget.anim_pos] do
        newnum = math.random(1,ANIM_IDLES)
    end
    widget.animnum = newnum
    widget:GetAnimState():PlayAnimation("idle"..newnum,true)
    widget:GetAnimState():SetTime(math.random()*2)

    if math.random() < 0.3/5 then
        widget:GetAnimState():Show("flower01")
    end

    if math.random() < 0.3/5 then
        widget:GetAnimState():Show("flower02")
    end

    if math.random() < 0.3/5 then
        widget:GetAnimState():Show("flower03")
    end

    if math.random() < 0.3/5 then
        widget:GetAnimState():Show("flower04")
    end

    if math.random() < 0.3/5 then
        widget:GetAnimState():Show("flower05")
    end
end

local function addcanopyrow(widget,row)
    if not ROW_ANIMS[row] then
        ROW_ANIMS[row] = {}
    end
    local x,y = TheSim:GetWindowSize()
    local new_widget
    for i=1,#POS_INDEX do
        new_widget = widget:AddChild(UIAnim())
        local new_widget_AnimState = new_widget:GetAnimState()
        widget["leavesTop"..row.."_"..i] = new_widget
        new_widget:SetClickable(false)
        new_widget:SetHAnchor(ANCHOR_MIDDLE)
        new_widget:SetVAnchor(ANCHOR_TOP)
        new_widget_AnimState:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
        new_widget_AnimState:SetBank("leaves_canopy")
        new_widget_AnimState:SetBuild("leaves_canopy")
        new_widget:SetScaleMode(SCALEMODE_PROPORTIONAL)
        new_widget_AnimState:UseColourCube(true)
        new_widget_AnimState:SetUILightParams(2.0, 4.0, 4.0, 20.0)
        new_widget_AnimState:AnimateWhilePaused(false)
        new_widget:Hide()
        new_widget.x_offset = getxoffset()
        new_widget:SetPosition( new_widget.x_offset + POS_INDEX[i]*x/8,0 )
        new_widget.depth = ((row-1)*2)/ROWS

        local anim = math.random(ANIM_IDLES)
        if ROW_ANIMS[row-1] and ROW_ANIMS[row-1][i] then
            while anim == ROW_ANIMS[row-1][i] do
                anim = math.random(ANIM_IDLES)
            end
        end

        new_widget.animnum = anim
        new_widget_AnimState:PlayAnimation("idle"..new_widget.animnum,true)
        new_widget_AnimState:SetTime(math.random()*2)
        new_widget.anim_row = row
        new_widget.anim_pos = i

        new_widget_AnimState:SetMultColour(1, 1, 1, 1)

        ROW_ANIMS[row][i] = new_widget.animnum

        local scale = (math.random() < 0.5 and -1) or 1
        new_widget:SetScale(scale, 0, 1)

        new_widget_AnimState:Hide("flower01")
        new_widget_AnimState:Hide("flower02")
        new_widget_AnimState:Hide("flower03")
        new_widget_AnimState:Hide("flower04")
        new_widget_AnimState:Hide("flower05")
    end
end

local Leafcanopy = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "Leafcanopy")

    for i=1,ROWS do
        addcanopyrow(self,i)
    end

    self.leavestop_intensity = 0

    self.leavespercent = 0
end)

local function calcdepthmod(depth)
    depth = depth -1

    local mod = 0.5 * math.sqrt(1 - (depth*depth))
    return mod * -450
end

local function sortdepth(widget, mod)
    widget.depth = widget.depth - mod

    if widget.depth > 2 then
        widget.depth = widget.depth -2
        widget:MoveToBack()
        widget:GetAnimState():PlayAnimation("idle"..math.random(1,4),true)
        widget:GetAnimState():SetTime(math.random()*2)

        local x = widget:GetPosition().x - widget.x_offset
        local modx = getxoffset()
        widget.x_offset = modx
        widget:SetPosition(x + widget.x_offset ,widget:GetPosition().y)

    elseif widget.depth < 0 then
        widget.depth = widget.depth +2
        widget:MoveToFront()
        widget:GetAnimState():PlayAnimation("idle"..math.random(1,4),true)
        widget:GetAnimState():SetTime(math.random()*2)

        local x = widget:GetPosition().x - widget.x_offset
        local modx = getxoffset()
        widget.x_offset = modx
        widget:SetPosition(x + widget.x_offset ,widget:GetPosition().y)
    end

    return widget
end

local function showleaves(widget)
    for set=1,ROWS do
        for i=1,#POS_INDEX do
            widget["leavesTop"..set.."_"..i]:Show()
        end
    end
end

local function hideleaves(widget)
    for set=1,ROWS do
        for i=1,#POS_INDEX do
            widget["leavesTop"..set.."_"..i]:Hide()
        end
    end
end

local Normal_1_0_1,  -- = Vector3(1,0,1):GetNormalized()
    Normal_n1_0_1,  -- = Vector3(-1,0,1):GetNormalized()
    Normal_1_0_n1,  -- = Vector3(1,0,-1):GetNormalized()
    Normal_n1_0_n1,  -- = Vector3(-1,0,-1):GetNormalized()
    Normal_0_0_1,  -- = Vector3(0, 0, 1)
    Normal_0_0_n1,  -- = Vector3(0, 0, -1)
    Normal_1_0_0,  -- = Vector3(1, 0, 0)
    Normal_n1_0_0  -- = Vector3(-1, 0, 0)

function Leafcanopy:OnUpdate(dt)
   if TheNet:IsServerPaused() then return end

    local zoomoffset = 0
    if TheCamera.distance and not TheCamera.dollyzoom then
        zoomoffset = Remap(TheCamera.distance,30,45,0,-75)
        if TheCamera.distance < 30 then
            zoomoffset = zoomoffset *1.6
        end
    end

    local current_camera_x, current_camera_y, current_camera_z = TheCamera.currentpos:Get()
    for set=1,ROWS do
        for i=1,#POS_INDEX do
            self["leavesTop"..set.."_"..i]:GetAnimState():SetWorldSpaceAmbientLightPos(current_camera_x, current_camera_y, current_camera_z)
        end
    end

    self.under_leaves = self.owner._underleafcanopy and self.owner._underleafcanopy:value()

    local SEC = 2
    self.leavestop_intensity = (self.under_leaves and math.min(1, self.leavestop_intensity+(1/(30 * SEC)) ))
        or math.max(0, self.leavestop_intensity-(1/(30 * SEC)) )

    if self.leavestop_intensity == 0 then
        hideleaves(self)
    else
        showleaves(self)

        local ypos = ((1-self.leavestop_intensity) *500) + zoomoffset  +300

        local thisframecoords = Vector3(current_camera_x, current_camera_y, current_camera_z)
        local down = TheCamera:GetDownVec()
        local down_x, down_z = down.x, down.z
        local diffcoords = (self.lastframecoords ~= nil and (thisframecoords - self.lastframecoords))
            or Vector3(0,0,0)

        local modx = 0
        local mody = 0

        --(0.71, 0.71)
        if down_x < 0.8 and down_x > 0.6 and down_z < 0.8 and down_z > 0.6 then
            Normal_n1_0_1 = Normal_n1_0_1 or Vector3(-1, 0, 1):GetNormalized()
            modx = diffcoords:Dot(Normal_n1_0_1)

            Normal_1_0_1 = Normal_1_0_1 or Vector3(1, 0, 1):GetNormalized()
            mody = diffcoords:Dot(Normal_1_0_1)
        end

        --(1.00, 0.00)
        if down_x > 0.8 and down_z < 0.1 and down_z > -0.1 then
            Normal_0_0_1 = Normal_0_0_1 or Vector3(0, 0, 1)
            modx = diffcoords:Dot(Normal_0_0_1)

            Normal_1_0_0 = Normal_1_0_0 or Vector3(1, 0, 0)
            mody = diffcoords:Dot(Normal_1_0_0)
        end

        --(0.71,-0.71)
        if down_x < 0.8 and down_x > 0.6 and down_z > -0.8 and down_z < -0.6 then
            Normal_1_0_1 = Normal_1_0_1 or Vector3(1, 0, 1):GetNormalized()
            modx = diffcoords:Dot(Normal_1_0_1)

            Normal_1_0_n1 = Normal_1_0_n1 or Vector3(1, 0, -1):GetNormalized()
            mody = diffcoords:Dot(Normal_1_0_n1)
        end

        --(0.0,-1)
        if down_x < 0.1 and down_x > -0.1 and down_z < -0.8 then
            Normal_1_0_0 = Normal_1_0_0 or Vector3(1, 0, 0)
            modx = diffcoords:Dot(Normal_1_0_0)

            Normal_0_0_n1 = Normal_0_0_n1 or Vector3(0, 0, -1)
            mody = diffcoords:Dot(Normal_0_0_n1)
        end

        --(-0.71, -0.71)
        if down_x > -0.8 and down_x < -0.6 and down_z > -0.8 and down_z < -0.6 then
            Normal_1_0_n1 = Normal_1_0_n1 or Vector3(1, 0, -1):GetNormalized()
            modx = diffcoords:Dot(Normal_1_0_n1)

            Normal_n1_0_n1 = Normal_n1_0_n1 or Vector3(-1, 0, -1):GetNormalized()
            mody = diffcoords:Dot(Normal_n1_0_n1)
        end

        --(-1.00, 0.00)
        if down_x < -0.8 and down_z < 0.1 and down_z > -0.1 then
            Normal_0_0_n1 = Normal_0_0_n1 or Vector3(0, 0, -1)
            modx = diffcoords:Dot(Normal_0_0_n1)

            Normal_n1_0_0 = Normal_n1_0_0 or Vector3(-1, 0, 0)
            mody = diffcoords:Dot(Normal_n1_0_0)
        end

        --(-0.71, 0.71)
        if down_x > -0.8 and down_x < -0.6 and down_z < 0.8 and down_z > 0.6 then
            Normal_n1_0_n1 = Normal_n1_0_n1 or Vector3(-1, 0, -1):GetNormalized()
            modx = diffcoords:Dot(Normal_n1_0_n1)

            Normal_n1_0_1 = Normal_n1_0_1 or Vector3(-1, 0, 1):GetNormalized()
            mody = diffcoords:Dot(Normal_n1_0_1)
        end

        --(0.00, 1.00)
        if down_x < 0.1 and down_x > -0.1 and down_z > 0.9 then
            Normal_n1_0_0 = Normal_n1_0_0 or Vector3(-1, 0, 0)
            modx = diffcoords:Dot(Normal_n1_0_0)

            Normal_0_0_1 = Normal_0_0_1 or Vector3(0, 0, 1)
            mody = diffcoords:Dot(Normal_0_0_1)
        end

        modx = modx * 100
        mody = mody * 0.2

        for set=1,ROWS do
            local depthmod = calcdepthmod(self["leavesTop"..set.."_1"].depth)
            for i=1,#POS_INDEX do
                local widget = sortdepth(self["leavesTop"..set.."_"..i], mody)
                self["leavesTop"..set.."_"..i] = widget

                local widget_position = widget:GetPosition()
                widget:SetPosition(widget_position.x-modx, ypos + depthmod)
                widget_position = widget:GetPosition()

                local sx, _ = TheSim:GetWindowSize()
                if widget_position.x > 5*sx/8 then
                    local modx_offset = getxoffset()
                    local adjust = modx_offset - widget.x_offset
                    widget.x_offset = modx_offset

                    widget:SetPosition(adjust + widget_position.x - (sx*5/4), widget_position.y)
                    setnewanim(widget)
                end
                if widget_position.x < -5*sx/8 then
                    local modx_offset = getxoffset()
                    local adjust = modx_offset - widget.x_offset
                    widget.x_offset = modx_offset

                    widget:SetPosition(adjust + widget_position.x + (sx*5/4), widget_position.y)
                    setnewanim(widget)
                end
            end
        end

        if self.leavesfullyin then
            self.leavespercent = self.leavespercent + mody
            if self.leavespercent > 1 then
                self.leavespercent = self.leavespercent -1
            end
            if self.leavespercent < 0 then
                self.leavespercent = self.leavespercent +1
            end
        else
            self.leavesfullyin = true
        end
        self.lastframecoords = thisframecoords
    end
end

return Leafcanopy
