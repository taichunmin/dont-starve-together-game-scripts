require "events"
local Text = require "widgets/text"

--V2C: WELL! this should've been local... =(
--     TheInput is the correct global to reference
--     At this point, gotta leave it in case MODs are using the wrong one =/

Input = Class(function(self)
    self.onkey = EventProcessor()     -- all keys, down and up, with key param
    self.onkeyup = EventProcessor()   -- specific key up, no parameters
    self.onkeydown = EventProcessor() -- specific key down, no parameters
    self.onmousebutton = EventProcessor()

    self.position = EventProcessor()
    self.oncontrol = EventProcessor()
    self.ontextinput = EventProcessor()
    self.ongesture = EventProcessor()

    self.hoverinst = nil
    self.enabledebugtoggle = true

    self.mouse_enabled = IsNotConsole() and not TheNet:IsDedicated()

    self.overridepos = nil
    self.controllerid_cached = nil

    self:DisableAllControllers()
end)

function Input:DisableAllControllers()
    for i = 1, TheInputProxy:GetInputDeviceCount() - 1 do
        if TheInputProxy:IsInputDeviceEnabled(i) and TheInputProxy:IsInputDeviceConnected(i) then
            TheInputProxy:EnableInputDevice(i, false)
        end
    end
end

function Input:EnableAllControllers()
    for i = 1, TheInputProxy:GetInputDeviceCount() - 1 do
        if TheInputProxy:IsInputDeviceConnected(i) then
            TheInputProxy:EnableInputDevice(i, true)
        end
    end
end

function Input:IsControllerLoggedIn(controller)
    if IsXB1() then
        return TheInputProxy:IsControllerLoggedIn(controller)
    end
    return true
end

function Input:LogUserAsync(controller,cb)
    if IsXB1() then
        TheInputProxy:LogUserAsync(controller,cb)
    else
        cb(true)
    end
end

function Input:LogSecondaryUserAsync(controller,cb)
    if IsXB1() then
        TheInputProxy:LogSecondaryUserAsync(controller,cb)
    else
        cb(true)
    end
end

function Input:EnableMouse(enable)
    self.mouse_enabled = enable and IsNotConsole() and not TheNet:IsDedicated()
end

function Input:ClearCachedController()
    self.controllerid_cached = nil
end

function Input:CacheController()
    self.controllerid_cached = IsNotConsole() and (TheInputProxy:GetLastActiveControllerIndex() or 0) or nil
    return self.controllerid_cached
end

function Input:TryRecacheController()
    return self.controllerid_cached ~= nil and self.controllerid_cached ~= self:CacheController()
end

function Input:GetControllerID()
    return self.controllerid_cached or TheInputProxy:GetLastActiveControllerIndex() or 0
end

function Input:ControllerAttached()
    if self.controllerid_cached ~= nil then
        return self.controllerid_cached > 0
    end
    --Active means connected AND enabled
    return IsConsole() or TheInputProxy:IsAnyControllerActive()
end

function Input:ControllerConnected()
    --V2C: didn't cache this one because it's not used regularly
    return IsConsole() or TheInputProxy:IsAnyControllerConnected()
end

-- Get a list of connected input devices and their ids
function Input:GetInputDevices()
    local devices = {}
    for i = 0, TheInputProxy:GetInputDeviceCount() - 1 do
        if TheInputProxy:IsInputDeviceConnected(i) then
            local device_type = TheInputProxy:GetInputDeviceType(i)
            table.insert(devices, { text = STRINGS.UI.CONTROLSSCREEN.INPUT_NAMES[device_type + 1], data = i })
        end
    end
    return devices
end

function Input:AddTextInputHandler(fn)
    return self.ontextinput:AddEventHandler("text", fn)
end

function Input:AddKeyUpHandler(key, fn)
    return self.onkeyup:AddEventHandler(key, fn)
end

function Input:AddKeyDownHandler(key, fn)
    return self.onkeydown:AddEventHandler(key, fn)
end

function Input:AddKeyHandler(fn)
    return self.onkey:AddEventHandler("onkey", fn)
end

function Input:AddMouseButtonHandler(fn)
    return self.onmousebutton:AddEventHandler("onmousebutton", fn)
end

function Input:AddMoveHandler(fn)
    return self.position:AddEventHandler("move", fn)
end

function Input:AddControlHandler(control, fn)
    return self.oncontrol:AddEventHandler(control, fn)
end

function Input:AddGeneralControlHandler(fn)
    return self.oncontrol:AddEventHandler("oncontrol", fn)
end

function Input:AddControlMappingHandler(fn)
    return self.oncontrol:AddEventHandler("onmap", fn)
end

function Input:AddGestureHandler(gesture, fn)
    return self.ongesture:AddEventHandler(gesture, fn)
end

function Input:UpdatePosition(x, y)
    if self.mouse_enabled then
        self.position:HandleEvent("move", x, y)
    end
end

-- Is for all the button devices (mouse, joystick (even the analog parts), keyboard as well, keyboard
function Input:OnControl(control, digitalvalue, analogvalue)
    if (self.mouse_enabled or
        (control ~= CONTROL_PRIMARY and control ~= CONTROL_SECONDARY)) and
        not TheFrontEnd:OnControl(control, digitalvalue) then
        self.oncontrol:HandleEvent(control, digitalvalue, analogvalue)
        self.oncontrol:HandleEvent("oncontrol", control, digitalvalue, analogvalue)
    end
end

function Input:OnMouseMove(x, y)
    if self.mouse_enabled then
        TheFrontEnd:OnMouseMove(x, y)
    end
end

function Input:OnMouseButton(button, down, x, y)
    if self.mouse_enabled then
        TheFrontEnd:OnMouseButton(button, down, x,y)
        self.onmousebutton:HandleEvent("onmousebutton", button, down, x, y)
    end
end

function Input:OnRawKey(key, down)
    self.onkey:HandleEvent("onkey", key, down)
    if down then
        self.onkeydown:HandleEvent(key)
    else
        self.onkeyup:HandleEvent(key)
    end
end

function Input:OnText(text)
    self.ontextinput:HandleEvent("text", text)
end

-- Specifically for floating text input on Steam Deck
function Input:OnFloatingTextInputDismissed()			-- called from C++
	if self.vk_text_widget then
		self.vk_text_widget:OnVirtualKeyboardClosed()
		self.vk_text_widget = nil
	end
end

function Input:AbortVirtualKeyboard(for_text_widget)
	if for_text_widget ~= nil and self.vk_text_widget == for_text_widget then
		self.vk_text_widget = nil
		TheInputProxy:CloseVirtualKeyboard()
	end
end

function Input:OpenVirtualKeyboard(text_widget)
	if not self.vk_text_widget then
		local x, y = text_widget.inst.UITransform:GetWorldPosition()
		local w, h = text_widget:GetRegionSize()

		--local _split = text_widget:GetString():split(",")
		--x = _split[1] ~= nil and tonumber(_split[1]) or 0
		--y = _split[2] ~= nil and tonumber(_split[2]) or 0
		--print("_split", x, y)

		if TheInputProxy:OpenVirtualKeyboard(x, y, w, h, self.allow_newline) then	
			self.vk_text_widget = text_widget
			return true
		end
	end

	return false
end

function Input:OnGesture(gesture)
    self.ongesture:HandleEvent(gesture)
end

function Input:OnControlMapped(deviceId, controlId, inputId, hasChanged)
    self.oncontrol:HandleEvent("onmap", deviceId, controlId, inputId, hasChanged)
end

function Input:OnFrameStart()
    self.hoverinst = nil
    self.hovervalid = false
end

function Input:GetScreenPosition()
    local x, y = TheSim:GetPosition()
    return Vector3(x, y, 0)
end

function Input:GetWorldPosition()
    local x, y, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
    return x ~= nil and y ~= nil and z ~= nil and Vector3(x, y, z) or nil
end

function Input:GetAllEntitiesUnderMouse()
    return self.mouse_enabled and self.entitiesundermouse or {}
end

function Input:GetWorldEntityUnderMouse()
    return self.mouse_enabled and
        self.hoverinst ~= nil and
        self.hoverinst.entity:IsValid() and
        self.hoverinst.entity:IsVisible() and
        self.hoverinst.Transform ~= nil and
        self.hoverinst or nil
end

function Input:EnableDebugToggle(enable)
    self.enabledebugtoggle = enable
end

function Input:IsDebugToggleEnabled()
    return self.enabledebugtoggle
end

function Input:GetHUDEntityUnderMouse()
    return self.mouse_enabled and
        self.hoverinst ~= nil and
        self.hoverinst.entity:IsValid() and
        self.hoverinst.entity:IsVisible() and
        self.hoverinst.Transform == nil and
        self.hoverinst or nil
end

function Input:IsMouseDown(button)
    return TheSim:GetMouseButtonState(button)
end

function Input:IsKeyDown(key)
    return TheSim:IsKeyDown(key)
end

function Input:IsControlPressed(control)
    return TheSim:GetDigitalControl(control)
end

function Input:GetAnalogControlValue(control)
    return TheSim:GetAnalogControl(control)
end

function Input:IsPasteKey(key)
    if key == KEY_V then
        if PLATFORM == "OSX_STEAM" then
            return self:IsKeyDown(KEY_LSUPER) or self:IsKeyDown(KEY_RSUPER)
        end
        return self:IsKeyDown(KEY_CTRL)
    end
    return key == KEY_INSERT and PLATFORM == "LINUX_STEAM" and self:IsKeyDown(KEY_SHIFT)
end

function Input:UpdateEntitiesUnderMouse()
	self.entitiesundermouse = TheSim:GetEntitiesAtScreenPoint(TheSim:GetPosition())
end

function Input:OnUpdate()
    if self.mouse_enabled then
        self.entitiesundermouse = TheSim:GetEntitiesAtScreenPoint(TheSim:GetPosition())

        local inst = self.entitiesundermouse[1]
        if inst ~= nil and inst.CanMouseThrough ~= nil then
            local mousethrough, keepnone = inst:CanMouseThrough()
            if mousethrough then
                for i = 2, #self.entitiesundermouse do
                    local nextinst = self.entitiesundermouse[i]
                    if nextinst == nil or
                        nextinst:HasTag("player") or
                        (nextinst.Transform ~= nil) ~= (inst.Transform ~= nil) then
                        if keepnone then
                            inst = nextinst
                            mousethrough, keepnone = false, false
                        end
                        break
                    end
                    inst = nextinst
                    if nextinst.CanMouseThrough == nil then
                        mousethrough, keepnone = false, false
                    else
                        mousethrough, keepnone = nextinst:CanMouseThrough()
                    end
                    if not mousethrough then
                        break
                    end
                end
                if mousethrough and keepnone then
                    inst = nil
                end
            end
        end

        if inst ~= self.hoverinst then
            if inst ~= nil and inst.Transform ~= nil then
                inst:PushEvent("mouseover")
            end

            if self.hoverinst ~= nil and self.hoverinst.Transform ~= nil then
                self.hoverinst:PushEvent("mouseout")
            end

            self.hoverinst = inst
        end
    end
end

function Input:GetLocalizedControl(deviceId, controlId, use_default_mapping, use_control_mapper)
    local device, numInputs, input1, input2, input3, input4, intParam = TheInputProxy:GetLocalizedControl(deviceId, controlId, use_default_mapping == true, use_control_mapper ~= false)

    if device == nil then
        return STRINGS.UI.CONTROLSSCREEN.INPUTS[9][1]
    elseif numInputs < 1 then
        return ""
    end

    local inputs = { input1, input2, input3, input4 }
    local text = STRINGS.UI.CONTROLSSCREEN.INPUTS[device][input1]
    -- concatenate the inputs
    for idx = 2, numInputs do
        text = text.." + "..STRINGS.UI.CONTROLSSCREEN.INPUTS[device][inputs[idx]]
    end

    -- process string format params if there are any
    return intParam ~= nil and string.format(text, intParam) or text
end

function Input:GetControlIsMouseWheel(controlId)
    if self:ControllerAttached() then
        return false
    end
    local localized = self:GetLocalizedControl(0, controlId)
    local stringtable = STRINGS.UI.CONTROLSSCREEN.INPUTS[1]
    return localized == stringtable[1003] or localized == stringtable[1004]
end

function Input:GetStringIsButtonImage(str)
    return table.contains(STRINGS.UI.CONTROLSSCREEN.INPUTS[2], str)
        or table.contains(STRINGS.UI.CONTROLSSCREEN.INPUTS[4], str)
        or table.contains(STRINGS.UI.CONTROLSSCREEN.INPUTS[5], str)
        or table.contains(STRINGS.UI.CONTROLSSCREEN.INPUTS[7], str)
        or table.contains(STRINGS.UI.CONTROLSSCREEN.INPUTS[8], str)
end

function Input:PlatformUsesVirtualKeyboard()
	if IsConsole() or IsSteamDeck() then
		return true
	end

	return false
end


---------------- Globals

TheInput = Input()

function OnFloatingTextInputDismissed() -- called from C++
    TheInput:OnFloatingTextInputDismissed()
end

function OnPosition(x, y)
    TheInput:UpdatePosition(x, y)
end

function OnControl(control, digitalvalue, analogvalue)
    TheInput:OnControl(control, digitalvalue, analogvalue)
end

function OnMouseButton(button, is_up, x, y)
    TheInput:OnMouseButton(button, is_up, x, y)
end

function OnMouseMove(x, y)
    TheInput:OnMouseMove(x, y)
end

function OnInputKey(key, is_up)
    TheInput:OnRawKey(key, is_up)
end

function OnInputText(text)
    TheInput:OnText(text)
end

function OnGesture(gesture)
    TheInput:OnGesture(gesture)
end

function OnControlMapped(deviceId, controlId, inputId, hasChanged)
    TheInput:OnControlMapped(deviceId, controlId, inputId, hasChanged)
end

return Input
