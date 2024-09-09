local Image = require("widgets/image")
local ImageButton = require("widgets/imagebutton")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local UIAnim = require("widgets/uianim")
local UIAnimButton = require("widgets/uianimbutton")

local TEMPLATES = require("widgets/redux/templates")

require("util")

local BANK = "UI_inspectacles"
local BUILD = "inspectacles"

local DIR_UP = "up"
local DIR_LEFT = "left"
local DIR_DOWN = "down"
local DIR_RIGHT = "right"
local DIRS = {
    DIR_UP,
    DIR_LEFT,
    DIR_DOWN,
    DIR_RIGHT,
}
local DIRS_OPPOSITE = {
    [DIR_UP] = DIR_DOWN,
    [DIR_LEFT] = DIR_RIGHT,
    [DIR_DOWN] = DIR_UP,
    [DIR_RIGHT] = DIR_LEFT,
}

local ROTATION_UP = 0
local ROTATION_RIGHT = 90
local ROTATION_DOWN = 180
local ROTATION_LEFT = 270
local DIRS_ROTATION = {
    [DIR_UP] = ROTATION_UP,
    [DIR_LEFT] = ROTATION_LEFT,
    [DIR_DOWN] = ROTATION_DOWN,
    [DIR_RIGHT] = ROTATION_RIGHT,
}

local TYPE_PLUG = "plug"
local TYPE_PIPE = "pipe"
local TYPE_BEND = "bend"
local TYPE_TEE = "tee" -- hee
local TYPE_CROSS = "cross"

-------------------------------------------------------------------------------------------------------
local InspectaclesWidget = Class(Widget, function(self, owner, parentscreen, inspectaclesparticipant)
    Widget._ctor(self, "InspectaclesWidget")

    self.root = self:AddChild(Widget("root"))
    self.owner = owner
    self.parentscreen = parentscreen -- NOTES(JBK): Set self.parentscreen.solution for each thing changed in this game widget.

    self.WIDTH = 300
    self.HEIGHT = 300
    self.PADDING = 5
    self.SOLVEDTIMETOANIMATE = 1.25
    self.GRIDSIZE = inspectaclesparticipant.GRIDSIZE -- Inherit from inspectaclesparticipant to keep game data and UI in sync.
    self.VALIDVALUEMAX = inspectaclesparticipant.VALIDVALUEMAX
    self.BUTTONSCALE = 2.7 / math.sqrt(self.GRIDSIZE * self.GRIDSIZE * 1.8) -- NOTES(JBK): Magic constants created by equation of almost good fit.
    self.FRAMESCALE = 1 - 0.01 / self.BUTTONSCALE
    self.ORIGINX = 0
    self.thingstohide = {}
    if IsSplitScreen() then
        self.ORIGINX = -RESOLUTION_X * 0.25
        if not IsGameInstance(Instances.Player1) then
            self.ORIGINX = -self.ORIGINX
        end
    end

    self.ELEMENTSIZEX = (self.WIDTH - self.PADDING * (self.GRIDSIZE - 1)) / self.GRIDSIZE
    self.ELEMENTSIZEY = (self.HEIGHT - self.PADDING * (self.GRIDSIZE - 1)) / self.GRIDSIZE

    local game, puzzle, puzzledata = inspectaclesparticipant:GetCLIENTDetails()
    puzzledata:Reset()
    local gameroot, addedui = self:ConstructGame(game, puzzledata)
    if not addedui then
        gameroot:AddChild(Text(HEADERFONT, 18, "ERROR MISSING GAME: " .. game, UICOLOURS.BLACK))
    end

    self.root:AddChild(gameroot)
    local center = math.floor(self.GRIDSIZE * 0.5)
    self.focus_forward = self.gameroot.buttons[self:GetIndex(center, center)]
end)

function InspectaclesWidget:MakeProjectionEffects(widget)
    if self.projectioneffects == nil then
        self.projectioneffects = {}
        local holo_time = 0
        self.inst:DoPeriodicTask(FRAMES, function()
            holo_time = holo_time + FRAMES
            for _, widget in ipairs(self.projectioneffects) do
                local animstate = widget.animstate or widget:GetAnimState()
                animstate:SetErosionParams(0.01, holo_time, -0.15)
            end
        end)
    end
    local animstate = widget.animstate or widget:GetAnimState()
    table.insert(self.projectioneffects, widget)
end

function InspectaclesWidget:GetIndex(x, y)
    return string.format("%d_%d", x, y) -- Good for debugging at the price of some performance.
end

function InspectaclesWidget:CheckSolvedState()
    if not self.solved and next(self.parentscreen.solution) == nil then
        TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/connect_success")
        self.solved = true
        self.solvedt = -0.4 -- Negative time to allow pending animations to play to finish.
        self:StartUpdating()
    end
end

function InspectaclesWidget:CloseWithAnimations()
    for _, thing in ipairs(self.thingstohide) do
        thing.inst:Hide()
    end
    self.gameroot.bg:GetAnimState():PlayAnimation("close")
    self.gameroot.fg:GetAnimState():PlayAnimation("close")
    self.gameroot.bg.inst:ListenForEvent("animover", function()
        TheFrontEnd:PopScreen(self.parentscreen)
    end)
end

function InspectaclesWidget:OnUpdate(dt)
    if self.solved then
        self.solvedt = self.solvedt + dt
        if not self.solvedrev and self.solvedt > 0 then
            self.solvedrev = true
            TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/powerup_rev")
        end
        local percent = self.solvedt / self.SOLVEDTIMETOANIMATE
        local duty_cycle_background = 0.75 -- Percentage of time needed to get to max brightness.
        local max_brightness_background = 0.25
        local percent_clamped = math.max(math.min(percent / duty_cycle_background, 1), 0) * max_brightness_background
        self.gameroot.bg:GetAnimState():SetAddColour(percent_clamped, percent_clamped, 0, 0)
        if percent >= 1 then
            self:StopUpdating()
            self:CloseWithAnimations()
        end
    end
end

function InspectaclesWidget:ConstructGame(game, puzzledata)
    local gameroot = Widget("gameroot")
    self.gameroot = gameroot
    gameroot:SetPosition(self.ORIGINX, 0)
    gameroot:SetScale(1 / self.FRAMESCALE)

    local FRAME_SCALE = 0.835 * self.FRAMESCALE -- NOTES(JBK): Manually adjusted to fit grid scheme.
    local FRAME_X = 3
    local FRAME_Y = 2
    local bg = gameroot:AddChild(UIAnim())
    gameroot.bg = bg
    self:MakeProjectionEffects(bg)
    bg:GetAnimState():SetBank(BANK)
    bg:GetAnimState():SetBuild(BUILD)
    bg:GetAnimState():PlayAnimation("open")
    bg:SetScale(FRAME_SCALE, FRAME_SCALE, 1) 
    bg:SetPosition(FRAME_X, FRAME_Y)
    bg:GetAnimState():Hide("UIframe")

    gameroot.buttons = {}
    local function CheckFocusedButtons()
        -- NOTES(JBK): The UI focus code can change the order of focus stack pops so we have to check if there are any focused still.
        for _, button in pairs(gameroot.buttons) do
            if button.focus then
                return false
            end
        end
        return true -- Nothing in focus safe to clear.
    end
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local button = gameroot:AddChild(UIAnimButton(BANK, BUILD, "exitnode"))
            table.insert(self.thingstohide, button)
            button:SetScale(self.BUTTONSCALE, self.BUTTONSCALE, 1)
            local index = self:GetIndex(x, y)
            gameroot.buttons[index] = button
            self:MakeProjectionEffects(button)
            button.index = index
            button.index_x = x
            button.index_y = y
            button:SetPosition((self.ELEMENTSIZEX + self.PADDING) * x + self.ELEMENTSIZEX * 0.5 - self.WIDTH * 0.5, (self.ELEMENTSIZEY + self.PADDING) * y + self.ELEMENTSIZEY * 0.5 - self.HEIGHT * 0.5)
            button.scale_on_focus = false
            button.clickoffset = Vector3(0, 0, 0)
            button:SetOnGainFocus(function()
                gameroot.buttonfocus = button
                button.animstate:SetAddColour(0.3, 0.3, 0.3, 0.2)
                if button.OnGainFocus ~= nil then
                    button:OnGainFocus()
                end
            end)
            button:SetOnLoseFocus(function()
                if CheckFocusedButtons() then
                    gameroot.buttonfocus = nil
                end
                button.animstate:SetAddColour(0, 0, 0, 0)
                if button.OnLoseFocus ~= nil then
                    button:OnLoseFocus()
                end
            end)
            local ROTATION_TIME = 0.3
            local SCALE_TIME = 0.25
            local SCALE_OFF = 0.75
            local SCALE_ON = 1.0
            local SCALE_CLICK = 0.85
            local UPDATE_DELAY = ROTATION_TIME + 0.05
            button.AddRotationHookups = function(button, onprimaryclick, onsecondaryclick)
                self.hookups_rotation = true
                button.tilerotation = 0
                button.SetTileRotation = function(button, rotation)
                    button:SetRotation(rotation)
                    button.tilerotation = rotation
                end
                local function DelayUpdate() -- NOTES(JBK): This is used to stop UI updates happening rapidly if someone keeps clicking on the thing and making it spin.
                    if button.delayupdatetask ~= nil then
                        button.delayupdatetask:Cancel()
                        button.delayupdatetask = nil
                    end
                    if button.OnAnimOver then
                        button.delayupdatetask = button.inst:DoTaskInTime(UPDATE_DELAY, button.OnAnimOver)
                    end
                end
                button.RotateLeft = function(button)
                    DelayUpdate()
                    button:RotateTo(button.tilerotation, button.tilerotation - 90, ROTATION_TIME)
                    button.tilerotation = (button.tilerotation - 90) % 360
                end
                button.RotateRight = function(button)
                    DelayUpdate()
                    button:RotateTo(button.tilerotation, button.tilerotation + 90, ROTATION_TIME)
                    button.tilerotation = (button.tilerotation + 90) % 360
                end
                button.OnPrimaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:RotateLeft()
                    if onprimaryclick then
                        onprimaryclick(self, button)
                    end
                end
                button.OnSecondaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:RotateRight()
                    if onsecondaryclick then
                        onsecondaryclick(self, button)
                    end
                end
                button:SetOnClick(function()
                    if self.solved then
                        return
                    end
                    button:OnPrimaryClick()
                end)
            end
            button.AddToggleHookups = function(button, onprimaryclick, onsecondaryclick)
                self.hookups_toggle = true
                button.tiletoggle = false
                button.rotationdirection = 1
                button.TileSpin = function(button)
                    button:RotateTo(button:GetRotation(), -3 * button.rotationdirection, 0, nil, true)
                end
                button.TileToggle = function(button)
                    button.tiletoggle = not button.tiletoggle
                    if button.tiletoggle then
                        button:CancelRotateTo()
                        button:ScaleTo(SCALE_ON * self.BUTTONSCALE, SCALE_OFF * self.BUTTONSCALE, SCALE_TIME)
                    else
                        button:ScaleTo(SCALE_OFF * self.BUTTONSCALE, SCALE_ON * self.BUTTONSCALE, SCALE_TIME, function()
                            button:TileSpin()
                        end)
                    end
                    self.parentscreen.solution[button.index] = button.tiletoggle or nil
                end
                button.SetTileToggled = function(button)
                    button.tiletoggle = true
                    button:SetScale(SCALE_OFF * self.BUTTONSCALE)
                    self.parentscreen.solution[button.index] = true
                end
                button.OnPrimaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:TileToggle()
                    if onprimaryclick then
                        onprimaryclick(self, button)
                    end
                end
                button.OnSecondaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:TileToggle()
                    if onsecondaryclick then
                        onsecondaryclick(self, button)
                    end
                end
                button:SetOnClick(function()
                    if self.solved then
                        return
                    end
                    button:OnPrimaryClick()
                end)
            end
            button.AddClickHookups = function(button, onprimaryclick, onsecondaryclick)
                self.hookups_click = true
                button.tileclicked = true
                button.TileClicked = function(button)
                    if not button.tileclicked then
                        button.tileclicked = true
                        button:ScaleTo(SCALE_ON * self.BUTTONSCALE, SCALE_CLICK * self.BUTTONSCALE, SCALE_TIME * 0.5, function()
                            button:ScaleTo(SCALE_CLICK * self.BUTTONSCALE, SCALE_ON * self.BUTTONSCALE, SCALE_TIME * 0.5)
                        end)
                        self.parentscreen.solution[button.index] = nil
                        button:SetTextures("images/hud.xml", "inv_slot.tex")
                    end
                end
                button.SetTileUnclicked = function(button)
                    button:SetTextures("images/hud.xml", "resource_needed.tex")
                    button.tileclicked = false
                    self.parentscreen.solution[button.index] = true
                end
                button.OnPrimaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:TileClicked()
                    if onprimaryclick then
                        onprimaryclick(self, button)
                    end
                end
                button.OnSecondaryClick = function(button)
                    if self.solved then
                        return
                    end
                    button:TileClicked()
                    if onsecondaryclick then
                        onsecondaryclick(self, button)
                    end
                end
                button:SetOnClick(function()
                    if self.solved then
                        return
                    end
                    button:OnPrimaryClick()
                end)
            end
        end
    end
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local button = gameroot.buttons[self:GetIndex(x, y)]
            if x > 0 then
                button:SetFocusChangeDir(MOVE_LEFT, gameroot.buttons[self:GetIndex(x - 1, y)])
            end
            if x < self.GRIDSIZE then
                button:SetFocusChangeDir(MOVE_RIGHT, gameroot.buttons[self:GetIndex(x + 1, y)])
            end
            if y > 0 then
                button:SetFocusChangeDir(MOVE_DOWN, gameroot.buttons[self:GetIndex(x, y - 1)])
            end
            if y < self.GRIDSIZE then
                button:SetFocusChangeDir(MOVE_UP, gameroot.buttons[self:GetIndex(x, y + 1)])
            end
        end
    end

    local addedui = false
    if game == "WIRES" then
        addedui = true
        self:AddGameUI_WIRES(puzzledata)
    elseif game == "GEARS" then
        addedui = true
        self:AddGameUI_GEARS(puzzledata)
    elseif game == "TAPE" then
        addedui = true
        self:AddGameUI_TAPE(puzzledata)
    end

    for _, button in pairs(gameroot.buttons) do
        button:MoveToFront()
    end

    local fg = gameroot:AddChild(UIAnim())
    gameroot.fg = fg
    self:MakeProjectionEffects(fg)
    fg:GetAnimState():SetBank(BANK)
    fg:GetAnimState():SetBuild(BUILD)
    fg:GetAnimState():PlayAnimation("open")
    fg:SetScale(FRAME_SCALE, FRAME_SCALE, 1) 
    fg:SetPosition(FRAME_X, FRAME_Y)
    fg:GetAnimState():Hide("UIback")

    return gameroot, addedui
end

function InspectaclesWidget:GetWireDirection(button, direction)
    -- NOTES(JBK): Remap the direction to the appropriate direction for the button.wiretype.
    -- It will return nil if no direction is appropriate.
    if button == nil then
        return nil
    end

    local is_up = button.tilerotation == ROTATION_UP
    local is_right = button.tilerotation == ROTATION_RIGHT
    local is_down = button.tilerotation == ROTATION_DOWN
    local is_left = button.tilerotation == ROTATION_LEFT
    local want_up = direction == DIR_UP
    local want_left = direction == DIR_LEFT
    local want_down = direction == DIR_DOWN
    local want_right = direction == DIR_RIGHT

    if button.wiretype == TYPE_PLUG then
        -- up
        if want_up then
            if is_up then
                return DIR_UP
            end
            return nil
        elseif want_left then
            if is_left then
                return DIR_UP
            end
            return nil
        elseif want_down then
            if is_down then
                return DIR_UP
            end
            return nil
        else -- want_right
            if is_right then
                return DIR_UP
            end
            return nil
        end
    elseif button.wiretype == TYPE_PIPE then
        -- up + down
        if want_up then
            if is_up then
                return DIR_UP
            elseif is_left then
                return nil
            elseif is_down then
                return DIR_DOWN
            else -- is_right
                return nil
            end
        elseif want_left then
            if is_up then
                return nil
            elseif is_left then
                return DIR_UP
            elseif is_down then
                return nil
            else -- is_right
                return DIR_DOWN
            end
        elseif want_down then
            if is_up then
                return DIR_DOWN
            elseif is_left then
                return nil
            elseif is_down then
                return DIR_UP
            else -- is_right
                return nil
            end
        else -- want_right
            if is_up then
                return nil
            elseif is_left then
                return DIR_DOWN
            elseif is_down then
                return nil
            else -- is_right
                return DIR_UP
            end
        end
    elseif button.wiretype == TYPE_BEND then
        -- up + left
        if want_up then
            if is_up then
                return DIR_UP
            elseif is_left then
                return nil
            elseif is_down then
                return nil
            else -- is_right
                return DIR_LEFT
            end
        elseif want_left then
            if is_up then
                return DIR_LEFT
            elseif is_left then
                return DIR_UP
            elseif is_down then
                return nil
            else -- is_right
                return nil
            end
        elseif want_down then
            if is_up then
                return nil
            elseif is_left then
                return DIR_LEFT
            elseif is_down then
                return DIR_UP
            else -- is_right
                return nil
            end
        else -- want_right
            if is_up then
                return nil
            elseif is_left then
                return nil
            elseif is_down then
                return DIR_LEFT
            else -- is_right
                return DIR_UP
            end
        end
    elseif button.wiretype == TYPE_TEE then
        -- up + left + down
        if want_up then
            if is_up then
                return DIR_UP
            elseif is_left then
                return nil
            elseif is_down then
                return DIR_DOWN
            else -- is_right
                return DIR_LEFT
            end
        elseif want_left then
            if is_up then
                return DIR_LEFT
            elseif is_left then
                return DIR_UP
            elseif is_down then
                return nil
            else -- is_right
                return DIR_DOWN
            end
        elseif want_down then
            if is_up then
                return DIR_DOWN
            elseif is_left then
                return DIR_LEFT
            elseif is_down then
                return DIR_UP
            else -- is_right
                return nil
            end
        else -- want_right
            if is_up then
                return nil
            elseif is_left then
                return DIR_DOWN
            elseif is_down then
                return DIR_LEFT
            else -- is_right
                return DIR_UP
            end
        end
    elseif button.wiretype == TYPE_CROSS then
        -- up + left + down + right
        if want_up then
            if is_up then
                return DIR_UP
            elseif is_left then
                return DIR_RIGHT
            elseif is_down then
                return DIR_DOWN
            else -- is_right
                return DIR_LEFT
            end
        elseif want_left then
            if is_up then
                return DIR_LEFT
            elseif is_left then
                return DIR_UP
            elseif is_down then
                return DIR_RIGHT
            else -- is_right
                return DIR_DOWN
            end
        elseif want_down then
            if is_up then
                return DIR_DOWN
            elseif is_left then
                return DIR_LEFT
            elseif is_down then
                return DIR_UP
            else -- is_right
                return DIR_RIGHT
            end
        else -- want_right
            if is_up then
                return DIR_RIGHT
            elseif is_left then
                return DIR_DOWN
            elseif is_down then
                return DIR_LEFT
            else -- is_right
                return DIR_UP
            end
        end
    end

    return nil
end

function InspectaclesWidget:TurnWireOn(button, direction, loading)
    if direction and (button.offwires[direction] or loading) then
        button.wires[direction]:GetAnimState():PlayAnimation(loading and "wire_extend_idle" or "wire_extend")
        if not loading then
            local t = GetStaticTime()
            if t ~= self.lastsoundtime then
                self.lastsoundtime = t
                TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/wire_connect")
            end
        end
        button.offwires[direction] = nil
        if not loading and next(button.offwires) == nil then
            self.parentscreen.solution[button.index] = nil
            self:CheckSolvedState()
        end
    end
end

function InspectaclesWidget:TurnWireOff(button, direction, loading)
    if direction and (not button.offwires[direction] or loading) then
        button.wires[direction]:GetAnimState():PlayAnimation(loading and "wire_retract_idle" or "wire_retract")
        if not loading then
            local t = GetStaticTime()
            if t ~= self.lastsoundtime then
                self.lastsoundtime = t
                TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/wire_disconnect")
            end
        end
        button.offwires[direction] = true
        self.parentscreen.solution[button.index] = true
    end
end

function InspectaclesWidget:AddWireVisual(button, direction)
    local wire = button:AddChild(UIAnim())
    wire:GetAnimState():SetBank(BANK)
    wire:GetAnimState():SetBuild(BUILD)
    wire:SetRotation(DIRS_ROTATION[direction])
    button.wires[direction] = wire
    self:MakeProjectionEffects(wire)
end

function InspectaclesWidget:SetWireType(button, wiretype)
    button.wiretype = wiretype
    button:SetIdleAnim("wire_" .. wiretype, false)
    button.offwires = {}
    button.wires = {}
    if wiretype == TYPE_PLUG then
        self:AddWireVisual(button, DIR_UP)
    elseif wiretype == TYPE_PIPE then
        self:AddWireVisual(button, DIR_UP)
        self:AddWireVisual(button, DIR_DOWN)
    elseif wiretype == TYPE_BEND then
        self:AddWireVisual(button, DIR_UP)
        self:AddWireVisual(button, DIR_LEFT)
    elseif wiretype == TYPE_TEE then
        self:AddWireVisual(button, DIR_UP)
        self:AddWireVisual(button, DIR_LEFT)
        self:AddWireVisual(button, DIR_DOWN)
    elseif wiretype == TYPE_CROSS then
        self:AddWireVisual(button, DIR_UP)
        self:AddWireVisual(button, DIR_LEFT)
        self:AddWireVisual(button, DIR_DOWN)
        self:AddWireVisual(button, DIR_RIGHT)
    end
end

function InspectaclesWidget:UpdateButton_WIRES(button, secondary, immediately)
    local x, y = button.index_x, button.index_y
    local bui = self:GetIndex(x, y + 1)
    local bli = self:GetIndex(x - 1, y)
    local bdi = self:GetIndex(x, y - 1)
    local bri = self:GetIndex(x + 1, y)
    local bu = self.gameroot.buttons[bui]
    local bl = self.gameroot.buttons[bli]
    local bd = self.gameroot.buttons[bdi]
    local br = self.gameroot.buttons[bri]

    for _, DIR in ipairs(DIRS) do
        local DIR_OPPOSITE = DIRS_OPPOSITE[DIR]
        local direction = self:GetWireDirection(button, DIR)
        if direction then
            local button_adjacent = nil
            local is_exit_node = false
            if DIR == DIR_UP then
                button_adjacent = bu
                is_exit_node = self.wireexits[bui]
            elseif DIR == DIR_LEFT then
                button_adjacent = bl
                is_exit_node = self.wireexits[bli]
            elseif DIR == DIR_DOWN then
                button_adjacent = bd
                is_exit_node = self.wireexits[bdi]
            else -- DIR == DIR_RIGHT
                button_adjacent = br
                is_exit_node = self.wireexits[bri]
            end
            if is_exit_node or self:GetWireDirection(button_adjacent, DIR_OPPOSITE) ~= nil then
                self:TurnWireOn(button, direction, immediately)
            else
                self:TurnWireOff(button, direction, immediately)
            end
        end
    end
    if not secondary then
        if bl then
            self:UpdateButton_WIRES(bl, true)
        end
        if br then
            self:UpdateButton_WIRES(br, true)
        end
        if bu then
            self:UpdateButton_WIRES(bu, true)
        end
        if bd then
            self:UpdateButton_WIRES(bd, true)
        end
    end
end

function InspectaclesWidget:CreateExitNode_WIRES(x, y, maze)
    self.wireexits[self:GetIndex(x, y)] = true
    local exitnode = self.gameroot:AddChild(UIAnim())
    self:MakeProjectionEffects(exitnode)
    table.insert(self.thingstohide, exitnode)
    exitnode:GetAnimState():SetBank(BANK)
    exitnode:GetAnimState():SetBuild(BUILD)
    exitnode:GetAnimState():PlayAnimation("exitnode")
    exitnode:SetScale(self.BUTTONSCALE, self.BUTTONSCALE, 1)
    exitnode:SetPosition((self.ELEMENTSIZEX + self.PADDING) * x + self.ELEMENTSIZEX * 0.5 - self.WIDTH * 0.5, (self.ELEMENTSIZEY + self.PADDING) * y + self.ELEMENTSIZEY * 0.5 - self.HEIGHT * 0.5)
    if x == -1 then
        exitnode:SetRotation(ROTATION_RIGHT)
        local spot = maze[maze[self:GetIndex(x + 1, y)]]
        self:UpdateWireDirections(spot, DIR_LEFT)
    elseif x == self.GRIDSIZE then
        exitnode:SetRotation(ROTATION_LEFT)
        local spot = maze[maze[self:GetIndex(x - 1, y)]]
        self:UpdateWireDirections(spot, DIR_RIGHT)
    elseif y == -1 then
        exitnode:SetRotation(ROTATION_UP)
        local spot = maze[maze[self:GetIndex(x, y + 1)]]
        self:UpdateWireDirections(spot, DIR_DOWN)
    elseif y == self.GRIDSIZE then
        exitnode:SetRotation(ROTATION_DOWN)
        local spot = maze[maze[self:GetIndex(x, y - 1)]]
        self:UpdateWireDirections(spot, DIR_UP)
    end
end

function InspectaclesWidget:OnRotatedWire(button)
    TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/rotate")
    for _, DIR in ipairs(DIRS) do
        if button.wires[DIR] then
            self:TurnWireOff(button, DIR)
        end
    end
    local x, y = button.index_x, button.index_y
    local bui = self:GetIndex(x, y + 1)
    local bli = self:GetIndex(x - 1, y)
    local bdi = self:GetIndex(x, y - 1)
    local bri = self:GetIndex(x + 1, y)
    local bu = self.gameroot.buttons[bui]
    local bl = self.gameroot.buttons[bli]
    local bd = self.gameroot.buttons[bdi]
    local br = self.gameroot.buttons[bri]
    if bl then
        self:TurnWireOff(bl, self:GetWireDirection(bl, DIR_RIGHT))
    end
    if br then
        self:TurnWireOff(br, self:GetWireDirection(br, DIR_LEFT))
    end
    if bu then
        self:TurnWireOff(bu, self:GetWireDirection(bu, DIR_DOWN))
    end
    if bd then
        self:TurnWireOff(bd, self:GetWireDirection(bd, DIR_UP))
    end
end

function InspectaclesWidget:UpdateWireDirections(spot, direction)
    spot.directions[direction] = true
    spot.directionscount = spot.directionscount + 1
    if spot.directionscount == 1 then
        spot.wiretype = TYPE_PLUG
    elseif spot.directionscount == 2 then
        if spot.directions[DIR_UP] and spot.directions[DIR_DOWN] or spot.directions[DIR_LEFT] and spot.directions[DIR_RIGHT] then
            spot.wiretype = TYPE_PIPE
        else
            spot.wiretype = TYPE_BEND
        end
    elseif spot.directionscount == 3 then
        spot.wiretype = TYPE_TEE
    else
        spot.wiretype = TYPE_CROSS
    end
end

function InspectaclesWidget:CalculatePerimeterSpot(numindex)
    -- NOTES(JBK): This converts a linear index into a wrapped perimeter index around a square in a cycle.
    numindex = numindex % (self.VALIDVALUEMAX * self.GRIDSIZE)
    local side = math.floor(numindex / self.GRIDSIZE) % (self.GRIDSIZE + 3)
    local position = numindex % self.GRIDSIZE
    if side == 0 then
        return position , -1
    elseif side == 1 then
        return self.GRIDSIZE, position
    elseif side == 2 then
        return self.GRIDSIZE - position - 1, self.GRIDSIZE
    else
        return -1, self.GRIDSIZE - position - 1
    end
end

function InspectaclesWidget:AddGameUI_WIRES(puzzledata)
    TheFrontEnd:GetSound():PlaySound("meta4/wires_minigame/minigame_popup")
    self.wireexits = {}
    -- Maze generation code is the same as this minigame for creating paths.
    -- We will use hunt and kill for the simplicity of implementation and the grid size being small.
    local maze = {}
    local mazecount = 0
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            mazecount = mazecount + 1
            local index = self:GetIndex(x, y)
            maze[mazecount] = {x = x, y = y, index = index, directions = {}, directionscount = 0,}
            maze[index] = mazecount -- Reverse lookups.
        end
    end
    local moves = {}
    local movescount = 0
    for i = 1, mazecount do
        local spot = maze[i]
        if i > 1 and not spot.visited then
            local x, y, index = spot.x, spot.y, spot.index
            local spot_up = maze[maze[self:GetIndex(x, y + 1)]]
            local spot_right = maze[maze[self:GetIndex(x + 1, y)]]
            local spot_down = maze[maze[self:GetIndex(x, y - 1)]]
            local spot_left = maze[maze[self:GetIndex(x - 1, y)]]
            if spot_up and spot_up.visited then
                self:UpdateWireDirections(spot_up, DIR_DOWN)
                self:UpdateWireDirections(spot, DIR_UP)
                --print(spot.index, " <=> ", spot_up.index)
            elseif spot_right and spot_right.visited then
                self:UpdateWireDirections(spot_right, DIR_LEFT)
                self:UpdateWireDirections(spot, DIR_RIGHT)
                --print(spot.index, " <=> ", spot_right.index)
            elseif spot_down and spot_down.visited then
                self:UpdateWireDirections(spot_down, DIR_UP)
                self:UpdateWireDirections(spot, DIR_DOWN)
                --print(spot.index, " <=> ", spot_down.index)
            elseif spot_left and spot_left.visited then
                self:UpdateWireDirections(spot_left, DIR_RIGHT)
                self:UpdateWireDirections(spot, DIR_LEFT)
                --print(spot.index, " <=> ", spot_left.index)
            end
        end
        while not spot.visited do
            spot.visited = true
            local x, y, index = spot.x, spot.y, spot.index
            local spot_up = maze[maze[self:GetIndex(x, y + 1)]]
            local spot_right = maze[maze[self:GetIndex(x + 1, y)]]
            local spot_down = maze[maze[self:GetIndex(x, y - 1)]]
            local spot_left = maze[maze[self:GetIndex(x - 1, y)]]
            movescount = 0
            if spot_up and not spot_up.visited then
                movescount = movescount + 1
                moves[movescount] = {spot = spot_up, direction = DIR_UP,}
            end
            if spot_right and not spot_right.visited then
                movescount = movescount + 1
                moves[movescount] = {spot = spot_right, direction = DIR_RIGHT,}
            end
            if spot_down and not spot_down.visited then
                movescount = movescount + 1
                moves[movescount] = {spot = spot_down, direction = DIR_DOWN,}
            end
            if spot_left and not spot_left.visited then
                movescount = movescount + 1
                moves[movescount] = {spot = spot_left, direction = DIR_LEFT,}
            end
            if movescount > 0 then
                local spot_to_pick = nil
                while spot_to_pick == nil do
                    local selected = puzzledata:GetNext() + 1
                    if selected <= movescount then
                        spot_to_pick = moves[selected]
                    end
                end
                local new_spot = spot_to_pick.spot
                self:UpdateWireDirections(new_spot, DIRS_OPPOSITE[spot_to_pick.direction])
                self:UpdateWireDirections(spot, spot_to_pick.direction)
                --print(spot.index, " <-> ", new_spot.index)
                spot = new_spot
            end
        end
    end
    -- Place exits randomly around the perimeter.
    for i = 0, self.GRIDSIZE - 1 do
        local numindex = i * self.VALIDVALUEMAX + puzzledata:GetNext()
        local x, y = self:CalculatePerimeterSpot(numindex)
        self:CreateExitNode_WIRES(x, y, maze)
    end
    -- Update all of the features for the minigame onto the created puzzle.
    local function OnGainFocus(button)
        for _, wire in pairs(button.wires) do
            wire:GetAnimState():SetAddColour(0.2, 0.2, 0.2, 0.1)
        end
        TheFrontEnd:GetSound():PlaySound("meta4/winona_UI/hover")
    end
    local function OnLoseFocus(button)
        for _, wire in pairs(button.wires) do
            wire:GetAnimState():SetAddColour(0, 0, 0, 0)
        end
    end
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local index = self:GetIndex(x, y)
            local button = self.gameroot.buttons[index]
            self:SetWireType(button, maze[maze[index]].wiretype)
            button.OnAnimOver = function()
                self:UpdateButton_WIRES(button)
            end
            button.OnGainFocus = OnGainFocus
            button.OnLoseFocus = OnLoseFocus
            button:AddRotationHookups(self.OnRotatedWire, self.OnRotatedWire)
            button.stopclicksound = true
            local rotation = puzzledata:GetNext() * 90
            button:SetTileRotation(rotation)
        end
    end
    -- Update all wire states.
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local index = self:GetIndex(x, y)
            local button = self.gameroot.buttons[index]
            self:UpdateButton_WIRES(button, true, true)
        end
    end
    -- Check for a solution in case it is already solved through chance.
    self:CheckSolvedState()
end

function InspectaclesWidget:AddGameUI_GEARS(puzzledata)
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local button = self.gameroot.buttons[self:GetIndex(x, y)]
            button:AddToggleHookups()
            --button:SetTextures("images/hud.xml", "tab_seafaring.tex")
            button:SetRotation(-math.random() * 360)
            if (x + y) % 2 == 0 then
                button.rotationdirection = -1
            end
            local state = (puzzledata:GetNext() % 2) == 0
            if state then
                button:SetTileToggled()
            else
                button:TileSpin()
            end
        end
    end
end

function InspectaclesWidget:AddGameUI_TAPE(puzzledata)
    for x = 0, self.GRIDSIZE - 1 do
        for y = 0, self.GRIDSIZE - 1 do
            local button = self.gameroot.buttons[self:GetIndex(x, y)]
            button:AddClickHookups()
            local state = (puzzledata:GetNext() % 2) == 0
            if state then
                button:SetTileUnclicked()
            else
                button:SetTextures("images/hud.xml", "inv_slot.tex")
            end
        end
    end
end

function InspectaclesWidget:OnControl(control, down)
    if InspectaclesWidget._base.OnControl(self, control, down) then
        return true
    end
    if self.solved then
        return false
    end

    if not down then
        local hascontroller = TheInput:ControllerAttached()
        local button = self.gameroot.buttonfocus
        if button ~= nil then
            local doprimaryclick, dosecondaryclick
            if control == CONTROL_ACTION then
                if not hascontroller then
                    doprimaryclick = true
                end
            elseif control == CONTROL_SECONDARY then
                dosecondaryclick = true
            elseif hascontroller then
                if self.hookups_rotation then
                    if control == CONTROL_SCROLLBACK then
                        doprimaryclick = true
                    elseif control == CONTROL_SCROLLFWD then
                        dosecondaryclick = true
                    end
                end
            end

            if doprimaryclick and button.OnPrimaryClick then
                button:OnPrimaryClick()
            end
            if dosecondaryclick and button.OnSecondaryClick then
                button:OnSecondaryClick()
            end
            if doprimaryclick or dosecondaryclick then
                return true
            end
        end
    end

    return false
end

function InspectaclesWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.hookups_rotation then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK) .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD) .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
    end

    return table.concat(t, "  ")
end


return InspectaclesWidget
