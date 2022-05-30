local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

local ROWS = 5
local ANIM_IDLES = 7
local POS_INDEX = {
    [1] = -5,
    [2] = -3,
    [3] = -1,
    [4] = 1,
    [5] = 3,
    [6] = 5,
}

POS_INDEX = {
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
    for i=1,#POS_INDEX do
        widget["leavesTop"..row.."_"..i] = widget:AddChild(UIAnim())
        widget["leavesTop"..row.."_"..i]:SetClickable(false)
        widget["leavesTop"..row.."_"..i]:SetHAnchor(ANCHOR_MIDDLE)
        widget["leavesTop"..row.."_"..i]:SetVAnchor(ANCHOR_TOP)
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetBank("leaves_canopy")
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetBuild("leaves_canopy")        
        widget["leavesTop"..row.."_"..i]:SetScaleMode(SCALEMODE_PROPORTIONAL)
        widget["leavesTop"..row.."_"..i]:GetAnimState():UseColourCube(true)
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetUILightParams(2.0, 4.0, 4.0, 20.0)
        widget["leavesTop"..row.."_"..i]:GetAnimState():AnimateWhilePaused(false)
        widget["leavesTop"..row.."_"..i]:Hide()
        widget["leavesTop"..row.."_"..i].x_offset = getxoffset()
        widget["leavesTop"..row.."_"..i]:SetPosition( widget["leavesTop"..row.."_"..i].x_offset + POS_INDEX[i]*x/8,0)        
        widget["leavesTop"..row.."_"..i].depth = ((row-1)*2)/ROWS
        local anim = math.random(1,ANIM_IDLES)

        if ROW_ANIMS[row-1] and ROW_ANIMS[row-1][i] then
            while anim == ROW_ANIMS[row-1][i] do
                anim = math.random(1,ANIM_IDLES)
            end
        end

        widget["leavesTop"..row.."_"..i].animnum = anim
        widget["leavesTop"..row.."_"..i]:GetAnimState():PlayAnimation("idle"..widget["leavesTop"..row.."_"..i].animnum,true)
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetTime(math.random()*2)
        widget["leavesTop"..row.."_"..i].anim_row = row
        widget["leavesTop"..row.."_"..i].anim_pos = i

        local num = Vector3(1,1,1)
        
        widget["leavesTop"..row.."_"..i]:GetAnimState():SetMultColour(num.x,num.y,num.z,1)

        ROW_ANIMS[row][i] = widget["leavesTop"..row.."_"..i].animnum

        local scale = 1
        if math.random() < 0.5 then
            scale = -1
        end
        widget["leavesTop"..row.."_"..i]:SetScale(scale,0,1)

        widget["leavesTop"..row.."_"..i]:GetAnimState():Hide("flower01")
        widget["leavesTop"..row.."_"..i]:GetAnimState():Hide("flower02")
        widget["leavesTop"..row.."_"..i]:GetAnimState():Hide("flower03")
        widget["leavesTop"..row.."_"..i]:GetAnimState():Hide("flower04")
        widget["leavesTop"..row.."_"..i]:GetAnimState():Hide("flower05")
    end
end

local Leafcanopy =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "Leafcanopy")

    for i=1,ROWS do
        addcanopyrow(self,i)    
    end

    self.leavestop_intensity = 0

    self.leavespercent = 0
end)

local function calcdepthmod(depth)
    local mod= 0
    
    depth = depth -1

    mod = math.sqrt(math.sqrt(1) - (depth*depth))    *0.5
    return mod * -450  -- -300
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



local SHADECANOPY_MUST = {"shadecanopy"}
local SHADECANOPY_SMALL_MUST = {"shadecanopysmall"}

function Leafcanopy:OnUpdate(dt)
   if TheNet:IsServerPaused() then return end

    local zoomoffset = 0
    if TheCamera.distance and not TheCamera.dollyzoom then
        zoomoffset = Remap(TheCamera.distance,30,45,0,-75)
        --print("TheCamera.distance",TheCamera.distance)
        if TheCamera.distance < 30 then
            zoomoffset = zoomoffset *1.6
        end
    end

    for set=1,ROWS do
        for i=1,#POS_INDEX do
            self["leavesTop"..set.."_"..i]:GetAnimState():SetWorldSpaceAmbientLightPos(TheCamera.currentpos:Get())
        end
    end

    self.under_leaves = self.owner._underleafcanopy and self.owner._underleafcanopy:value()

    local SEC = 2
    if self.under_leaves then
        self.leavestop_intensity = math.min(1,self.leavestop_intensity+(1/(30 * SEC)) )
    else
        self.leavestop_intensity = math.max(0,self.leavestop_intensity-(1/(30 * SEC)) )
    end    

    if self.leavestop_intensity == 0 then
        hideleaves(self)           
    else
        showleaves(self)

        local ypos = 0

        ypos = ((1-self.leavestop_intensity) *500) + zoomoffset  +300

        local move = false
        local thisframecoords = Vector3(TheCamera.currentpos.x,TheCamera.currentpos.y,TheCamera.currentpos.z)
        local down = TheCamera:GetDownVec()
        local diffcoords = Vector3(0,0,0)
        if self.lastframecoords then
            diffcoords = thisframecoords - self.lastframecoords
            if math.abs(diffcoords.x) > 0.001 or math.abs(diffcoords.z) > 0.001 then
                move = true
            end
        end

        local modx = 0
        local mody = 0

        --(0.71, 0.71)
        if down.x < 0.8 and down.x > 0.6 and down.z < 0.8 and down.z > 0.6 then
            modx = diffcoords:Dot(Vector3(-1,0,1):GetNormalized())
            mody = diffcoords:Dot(Vector3(1,0,1):GetNormalized())
        end

        --(1.00, 0.00)
        if down.x > 0.8 and down.z < 0.1 and down.z > -0.1 then
            modx = diffcoords:Dot(Vector3(0,0,1):GetNormalized())
            mody = diffcoords:Dot(Vector3(1,0,0):GetNormalized())
        end

        --(0.71,-0.71)
        if down.x < 0.8 and down.x > 0.6 and down.z > -0.8 and down.z < -0.6 then
            modx = diffcoords:Dot(Vector3(1,0,1):GetNormalized())
            mody = diffcoords:Dot(Vector3(1,0,-1):GetNormalized())
        end

        --(0.0,-1)
        if down.x < 0.1 and down.x > -0.1 and down.z < -0.8 then
            modx = diffcoords:Dot(Vector3(1,0,0):GetNormalized())
            mody = diffcoords:Dot(Vector3(0,0,-1):GetNormalized())
        end

        --(-0.71, -0.71)
        if down.x > -0.8 and down.x < -0.6 and down.z > -0.8 and down.z < -0.6 then
            modx = diffcoords:Dot(Vector3(1,0,-1):GetNormalized())
            mody = diffcoords:Dot(Vector3(-1,0,-1):GetNormalized())
        end

        --(-1.00, 0.00)
        if down.x < -0.8 and down.z < 0.1 and down.z > -0.1 then
            modx = diffcoords:Dot(Vector3(0,0,-1):GetNormalized())
            mody = diffcoords:Dot(Vector3(-1,0,0):GetNormalized())
        end

        --(-0.71, 0.71)
        if down.x > -0.8 and down.x < -0.6 and down.z < 0.8 and down.z > 0.6 then
            modx = diffcoords:Dot(Vector3(-1,0,-1):GetNormalized())
            mody = diffcoords:Dot(Vector3(-1,0,1):GetNormalized())
        end

        --(0.00, 1.00)
        if down.x < 0.1 and down.x > -0.1 and down.z > 0.9 then
            modx = diffcoords:Dot(Vector3(-1,0,0):GetNormalized())
            mody = diffcoords:Dot(Vector3(0,0,1):GetNormalized())
        end

        modx = modx * 100
        mody = mody * 0.2

        for set=1,ROWS do
            local depthmod = calcdepthmod(self["leavesTop"..set.."_1"].depth)
            for i=1,#POS_INDEX do
                self["leavesTop"..set.."_"..i] = sortdepth(self["leavesTop"..set.."_"..i],mody)

                local pos = self["leavesTop"..set.."_"..i]:GetPosition()
                self["leavesTop"..set.."_"..i]:SetPosition(pos.x-modx, ypos + depthmod)

                local sx,sy = TheSim:GetWindowSize()
                if self["leavesTop"..set.."_"..i]:GetPosition().x > 5*sx/8 then
                    local modx = getxoffset()
                    local adjust = modx - self["leavesTop"..set.."_"..i].x_offset
                    self["leavesTop"..set.."_"..i].x_offset = modx            
                    self["leavesTop"..set.."_"..i]:SetPosition(adjust + self["leavesTop"..set.."_"..i]:GetPosition().x - (sx*5/4), self["leavesTop"..set.."_"..i]:GetPosition().y)
                    setnewanim(self["leavesTop"..set.."_"..i])                    
                end
                if self["leavesTop"..set.."_"..i]:GetPosition().x < -5*sx/8 then
                    local modx = getxoffset()
                    local adjust = modx - self["leavesTop"..set.."_"..i].x_offset   
                    self["leavesTop"..set.."_"..i].x_offset = modx                   
                    self["leavesTop"..set.."_"..i]:SetPosition(adjust + self["leavesTop"..set.."_"..i]:GetPosition().x + (sx*5/4), self["leavesTop"..set.."_"..i]:GetPosition().y)
                    setnewanim(self["leavesTop"..set.."_"..i])
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
