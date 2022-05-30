local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/templates"
local UIAnim = require "widgets/uianim"

local DEBUG_MODE = BRANCH == "dev"

-- A widget that tracks the mouse and plays a different animation depending on the mouse position
-- relative to the widget. Used for the joystick on the tradescreen.

local MouseTracker = Class(Widget, function(self, anim, onclickFn)
	Widget._ctor(self, "MouseTracker")

	self.onclickFn = onclickFn

	self.joystick = self:AddChild(UIAnim())
  	self.joystick:GetAnimState():SetBuild(anim)
    self.joystick:GetAnimState():SetBank(anim)
    self.joystick:GetAnimState():PlayAnimation("idle", true)

    -- Add an invisible button to catch mouse events.
    -- On click, call the click function
    -- On mouseover, the joystick starts following the mouse.
    self.joystick.button = self.joystick:AddChild(TEMPLATES.InvisibleButton(50, 50,
    											function() if self.onclickFn then self.onclickFn() end end,
    											function() if not self.started then self:Start() end end ))

end)


function MouseTracker:Start()
	self.started_ever = true -- indicates that this

	if not self.joystickmover then
		self.joystickmover = TheInput:AddMoveHandler(function(mx,my)

			local jpos = self.joystick:GetWorldPosition()
			local xdiff = mx - jpos.x
			local ydiff = my - jpos.y

			local angle = math.atan2(ydiff, xdiff)
			local anim = self:GetAnim(angle)
			self.joystick:GetAnimState():PlayAnimation(anim, true)
		end)
	end
end


function MouseTracker:Stop()
	-- stop the joystick so we can restart it
	if self.joystickmover then
		self.joystickmover:Remove()
		self.joystickmover = nil
	end

	self.joystick:GetAnimState():PlayAnimation("idle", true)
end

function MouseTracker:GetAnim(angle)

	if angle > 0 then

		if angle < math.pi/8 then
			return "3"
		elseif angle < 3*math.pi/8 then
			return "1:30"
		elseif angle < 5*math.pi/8 then
			return "12"
		elseif angle < 7*math.pi/8 then
			return "10:30"
		elseif angle < 9*math.pi/8 then
			return "9"
		elseif angle < 11*math.pi/8 then
			return "7:30"
		elseif angle < 13*math.pi/8 then
			return "6"
		elseif angle < 15*math.pi/8 then
			return "4:30"
		else
			return "3"
		end

	else
		if angle > -1*math.pi/8 then
			return "3"
		elseif angle > -3*math.pi/8 then
			return "4:30"
		elseif angle > -5*math.pi/8 then
			return "6"
		elseif angle > -7*math.pi/8 then
			return "7:30"
		elseif angle > -9*math.pi/8 then
			return "9"
		elseif angle > -11*math.pi/8 then
			return "10:30"
		elseif angle > -13*math.pi/8 then
			return "12"
		elseif angle > -15*math.pi/8 then
			return "1:30"
		else
			return "3"
		end

	end

end


return MouseTracker