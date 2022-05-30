local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"

local MIN_GEN_TIME = 9.5

local WorldGenScreen = Class(Screen, function(self, profile, cb, world_gen_data, hidden)
    Screen._ctor(self, "WorldGenScreen")
    self.profile = profile
    self.log = true

	if hidden then
		TheFrontEnd:Fade(FADE_OUT, 0)
		TheFrontEnd:SetFadeLevel(0)
		self:Hide()
		ShowLoading()
	else
		self.bg = self:AddChild(TEMPLATES.BackgroundSpiral())

		self.vignette = self:AddChild(TEMPLATES.BackgroundVignette())

		self.bottom_root = self:AddChild(Widget("root"))
		self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
		self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
		self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

		self.center_root = self:AddChild(Widget("root"))
		self.center_root:SetVAnchor(ANCHOR_MIDDLE)
		self.center_root:SetHAnchor(ANCHOR_MIDDLE)
		self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

		self.worldanim = self.bottom_root:AddChild(UIAnim())

		local hand_scale = 1.5
		self.hand1 = self.bottom_root:AddChild(UIAnim())
		self.hand1:GetAnimState():SetBuild("creepy_hands")
		self.hand1:GetAnimState():SetBank("creepy_hands")
		self.hand1:GetAnimState():SetTime(math.random()*2)
		self.hand1:GetAnimState():PlayAnimation("idle", true)
		self.hand1:SetPosition(400, 0, 0)
		self.hand1:SetScale(hand_scale,hand_scale,hand_scale)

		self.hand2 = self.bottom_root:AddChild(UIAnim())
		self.hand2:GetAnimState():SetBuild("creepy_hands")
		self.hand2:GetAnimState():SetBank("creepy_hands")
		self.hand2:GetAnimState():PlayAnimation("idle", true)
		self.hand2:GetAnimState():SetTime(math.random()*2)
		self.hand2:SetPosition(-425, 0, 0)
		self.hand2:SetScale(-hand_scale,hand_scale,hand_scale)

		self.worldgentext = self.center_root:AddChild(Text(TITLEFONT, 100))
		self.worldgentext:SetPosition(0, 200, 0)
		self.worldgentext:SetColour(unpack(PORTAL_TEXT_COLOUR))

		if world_gen_data and world_gen_data.level_data and world_gen_data.level_data and world_gen_data.level_data.location == "cave" then
			self.bg:SetTint(unpack(BGCOLOURS.PURPLE))
			self.worldanim:GetAnimState():SetBuild("generating_cave")
			self.worldanim:GetAnimState():SetBank("generating_cave")
			self.worldgentext:SetString(STRINGS.UI.WORLDGEN.CAVETITLE)

			TheFrontEnd:GetSound():PlaySound( "dontstarve/HUD/caveGen", "worldgensound" )
		else
			self.worldanim:GetAnimState():SetBuild("generating_forest")
			self.worldanim:GetAnimState():SetBank("generating_forest")
			self.worldgentext:SetString(STRINGS.UI.WORLDGEN.TITLE)

			TheFrontEnd:GetSound():PlaySound( "dontstarve/HUD/worldGen", "worldgensound" )
		end

		self.worldanim:GetAnimState():PlayAnimation("idle", true)

		self.flavourtext= self.center_root:AddChild(Text(UIFONT, 40))
		self.flavourtext:SetPosition(0, 100, 0)
		self.flavourtext:SetColour(unpack(PORTAL_TEXT_COLOUR))

		local time = 1
		TheFrontEnd:Fade(FADE_IN, time, nil, nil, nil, "white")

		self.verbs = shuffleArray(STRINGS.UI.WORLDGEN.VERBS)
		self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS)

		self.verbidx = 1
		self.nounidx = 1
		self:ChangeFlavourText()
	end

	self.total_time = 0
	self.cb = cb

    if TheNet:GetIsServer() then
        assert(world_gen_data.profile_data ~= nil and world_gen_data.level_data ~= nil, "Worldgen must be started with a complete profile and level description.")

        local DLCEnabledTable = {}
        for i,v in pairs(DLC_LIST) do
            DLCEnabledTable[i] = IsDLCEnabled(i)
        end
        world_gen_data.DLCEnabled = DLCEnabledTable
        self.genparam = json.encode(world_gen_data)

        local moddata = {}
        moddata.index = KnownModIndex:CacheSaveData()

        self.modparam = json.encode(moddata)

        TheSim:GenerateNewWorld(self.genparam, self.modparam,
            function(worlddata)
                self.worlddata = worlddata
                self.done = true
            end)
    end
end)

function WorldGenScreen:OnDestroy()
    TheFrontEnd:GetSound():KillSound("worldgensound")
    self._base.OnDestroy(self)
end

function WorldGenScreen:OnUpdate(dt)
    if TheNet:GetIsServer() then
        self.total_time = self.total_time + dt
        if self.done then
            if self.worlddata == "" then
                print("RESTARTING GENERATION")
                self.done = false
                self.worldata = nil
                TheSim:GenerateNewWorld(self.genparam, self.modparam,
                    function(worlddata)
                        self.worlddata = worlddata
                        self.done = true
                    end)
                return
            end

            if string.match(self.worlddata,"^error") then
                self.done = false
                self.cb(self.worlddata)
            elseif self.total_time > 0 --[[ MIN_GEN_TIME ]]and self.cb then
                self.done = false
                --TheFrontEnd:Fade(FADE_OUT, 1, function()
                    self.cb(self.worlddata)
                --end, nil, nil, "white")
            end
        end
    elseif TheNet:GetChildProcessStatus() > 0 then
        if TheNet:GetChildProcessStatus() == 3 and TheFrontEnd:GetActiveScreen() == self then
            TheFrontEnd:PopScreen()
        end
    end
end

function WorldGenScreen:ChangeFlavourText()
    self.flavourtext:SetString(self.verbs[self.verbidx].." "..self.nouns[self.nounidx])

    self.verbidx = (self.verbidx == #self.verbs) and 1 or (self.verbidx + 1)
    self.nounidx = (self.nounidx == #self.nouns) and 1 or (self.nounidx + 1)

    local time = GetRandomWithVariance(2, 1)
    self.inst:DoTaskInTime(time, function() self:ChangeFlavourText() end)
end

function WorldGenScreen:OnBecomeActive()
    if TheNet:GetIsServer() then
        NotifyLoadingState(LoadingStates.Generating)
    end
end

function WorldGenScreen:OnBecomeInactive()
    if TheNet:GetIsServer() then
        NotifyLoadingState(LoadingStates.DoneGenerating)
    end
end

--V2C: For clients, this screen can be just thrown on top of a game
--     in progress while waiting for the server to regenerate world
function WorldGenScreen:OnControl(control, down)
    return WorldGenScreen._base.OnControl(self, control, down) or true
end

return WorldGenScreen
