local easing = require("easing")


local UIAnim = Class(function(self, inst)
    self.inst = inst
    self.update_while_paused = true
end)

function UIAnim:UpdateWhilePaused(update_while_paused)
    self.update_while_paused = update_while_paused
end

function UIAnim:FinishCurrentTint()
    if not self.inst or not self.inst:IsValid() then
        -- sometimes the ent becomes invalid during a "finished" callback, but this gets run anyways.
        return
    end

    local val = self.tint_dest
    self.tint_t = nil

    self.inst.widget:SetTint(val.r, val.g, val.b, val.a)

    if self.tint_whendone then
		local whendone = self.tint_whendone
        self.tint_whendone = nil
        whendone()
    end
end

function UIAnim:CancelTintTo( run_complete_fn )
	self.tint_t = nil
	if run_complete_fn ~= nil and self.tint_whendone then
		self.tint_whendone()
    end
	self.tint_whendone = nil
end

function UIAnim:TintTo(start, dest, duration, whendone)
    if not self.inst.widget.SetTint then
        return
    end

    self.tint_start = start
    self.tint_dest = dest
    self.tint_duration = duration
    self.tint_t = 0

    self.tint_whendone = whendone
    self.inst:StartWallUpdatingComponent(self)
end

function UIAnim:FinishCurrentScale()
    if not self.inst or not self.inst:IsValid() then
        -- sometimes the ent becomes invalid during a "finished" callback, but this gets run anyways.
        return
    end

    local sx, sy, sz = self.inst.UITransform:GetScale()

    local val = self.scale_dest
    self.scale_t = nil

    self.inst.UITransform:SetScale(sx >= 0 and val or -val, sy >= 0 and val or -val, sz >= 0 and val or -val)

    if self.scale_whendone then
		local whendone = self.scale_whendone
        self.scale_whendone = nil
        whendone()
    end
end

function UIAnim:CancelScaleTo( run_complete_fn )
	self.scale_t = nil
	if run_complete_fn ~= nil and self.scale_whendone then
		self.scale_whendone()
    end
	self.scale_whendone = nil
end

function UIAnim:ScaleTo(start, dest, duration, whendone)
    if self.scale_t then
        self:FinishCurrentScale()
    end

    self.scale_start = start
    self.scale_dest = dest
    self.scale_duration = duration
    self.scale_t = 0

    self.scale_whendone = whendone
    self.inst:StartWallUpdatingComponent(self)
end

function UIAnim:CancelMoveTo( run_complete_fn )
	self.pos_t = nil
	if run_complete_fn ~= nil and self.pos_whendone then
		self.pos_whendone()
    end
	self.pos_whendone = nil
end

function UIAnim:MoveTo(start, dest, duration, whendone)
    self.pos_start = start
    self.pos_dest = dest
    self.pos_duration = duration
    self.pos_t = 0

    if self.pos_whendone then
		self.pos_whendone()
    end
    self.pos_whendone = whendone


    self.inst:StartWallUpdatingComponent(self)
    self.inst.UITransform:SetPosition(start.x, start.y, start.z)
end

function UIAnim:CancelRotateTo( run_complete_fn )
	self.rot_t = nil
	if run_complete_fn ~= nil and self.rot_whendone then
		self.rot_whendone()
    end
	self.rot_whendone = nil
end

function UIAnim:RotateTo(start, dest, duration, whendone, infinite )
    self.rot_start = start
    self.rot_dest = dest
    self.rot_duration = duration
    self.rot_t = 0

    if self.rot_whendone then
        self.rot_whendone()
    end
    self.rot_whendone = whendone

    self.rot_infinite = false
    if infinite then
        self.rot_infinite = infinite
    end

    self.inst:StartWallUpdatingComponent(self)
    self.inst.UITransform:SetRotation(start)
end


function UIAnim:OnWallUpdate(dt)
    if not self.inst:IsValid() then
		self.inst:StopWallUpdatingComponent(self)
		return
    end

    if not self.update_while_paused and TheNet:IsServerPaused() then return end

    local done = false

    if self.scale_t then
        local val = 1
        local sx, sy, sz = self.inst.UITransform:GetScale()
        if sx and sy and sz then

			self.scale_t = self.scale_t + dt
			if self.scale_t < self.scale_duration then
				val = easing.outCubic( self.scale_t, self.scale_start, self.scale_dest - self.scale_start, self.scale_duration)
			    self.inst.UITransform:SetScale(sx >= 0 and val or -val, sy >= 0 and val or -val, sz >= 0 and val or -val)
            else
                self:FinishCurrentScale()
            end
		end
    end

    if self.pos_t then

        self.pos_t = self.pos_t + dt
        if self.pos_t < self.pos_duration then
            local valx = easing.outCubic( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
            local valy = easing.outCubic( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
            local valz = easing.outCubic( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
            self.inst.UITransform:SetPosition(valx, valy, valz)
        else
            local valx = self.pos_dest.x
            local valy = self.pos_dest.y
            local valz = self.pos_dest.z
            self.inst.UITransform:SetPosition(valx, valy, valz)

            self.pos_t = nil
            if self.pos_whendone then
                local pos_whendonefn = self.pos_whendone
				self.pos_whendone = nil -- reset this here so that self.pos_whendone can call MoveTo
                pos_whendonefn()
            end
        end
    end

    if self.tint_t then
        self.tint_t = self.tint_t + dt

        if self.tint_t < self.tint_duration then
            local r = easing.outCubic( self.tint_t, self.tint_start.r, self.tint_dest.r - self.tint_start.r, self.tint_duration)
            local g = easing.outCubic( self.tint_t, self.tint_start.g, self.tint_dest.g - self.tint_start.g, self.tint_duration)
            local b = easing.outCubic( self.tint_t, self.tint_start.b, self.tint_dest.b - self.tint_start.b, self.tint_duration)
            local a = easing.outCubic( self.tint_t, self.tint_start.a, self.tint_dest.a - self.tint_start.a, self.tint_duration)
            self.inst.widget:SetTint(r,g,b,a)
        else
            self:FinishCurrentTint()
        end
    end

    if self.rot_t then
        self.rot_t = self.rot_t + dt
        if self.rot_infinite then
            self.inst.UITransform:SetRotation( self.inst.UITransform:GetRotation() + self.rot_dest )
        elseif self.rot_t < self.rot_duration then
            local rot = easing.outCubic( self.rot_t, self.rot_start, self.rot_dest - self.rot_start, self.rot_duration)
            self.inst.UITransform:SetRotation(rot)
        else
            local rot = self.rot_dest
            self.inst.UITransform:SetRotation(rot)

            self.rot_t = nil
            if self.rot_whendone then
                local rot_whendonefn = self.rot_whendone
                self.rot_whendone = nil -- reset this here so that self.rot_whendone can call RotateTo
                rot_whendonefn()
            end
        end
    end

    if not self.scale_t and not self.pos_t and not self.tint_t and not self.rot_t then
        self.inst:StopWallUpdatingComponent(self)
    end
end

return UIAnim
