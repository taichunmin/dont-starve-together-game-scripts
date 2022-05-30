local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local KitcoonNamePopup = require "screens/kitcoonnamepopup"

local KIT_TYPES = 
{
    "kitcoon_forest_build",
    "kitcoon_savanna_build",
    "kitcoon_deciduous_build",
    "kitcoon_marsh_build",
    "kitcoon_grass_build",
    "kitcoon_rocky_build",
    "kitcoon_desert_build",
    "kitcoon_moon_build",
    "kitcoon_yot_build", 
}

local HUNGER_DELTA_EAT = 0.15
local HUNGER_DRAIN_RATE = 1 / 100

local HAPPINESS_DELTA_PLAY = 0.15
local HAPPINESS_DRAIN_RATE = 1 / 100

local GROWTH_RATE = 1 / 500 --hours until fully grown
local HUNGER_SADNESS_LEVEL = 0.75
local HUNGER_GROW_LEVEL = 0.5

local MIN_SIZE = 0.3
local MAX_SIZE = 1.2

local MAX_POOPS = 6
local POOP_PENALTY_DELTA = 0.12

local PHASE_LENGTH = 60 * 60

function TestKitcoon( hours )
    Profile:SetKitBuild( "kitcoon_forest_build" )
    Profile:SetKitHunger( 0 )
    Profile:SetKitHappiness( 1 )
    Profile:SetKitPoops( 0 )
    RunKitcoonLongUpdate( hours )
end

function RunKitcoonLongUpdate( override_hours )
    if Profile:GetKitBuild() == "" or Profile:GetKitIsHibernating() then
        --don't do an update, there's already no build, or if it's hibernating
        return
    end

    local hunger = Profile:GetKitHunger()
    local happiness = Profile:GetKitHappiness()
    local poops = Profile:GetKitPoops()
    local size = Profile:GetKitSize()

    local now = os.time()
    local last_time = Profile:GetKitLastTime()
    local hours_since = override_hours or math.floor( os.difftime(now, last_time) / PHASE_LENGTH )
    if hours_since > 0 then
        local abandoned = false
        for i=1,hours_since do            
            if hunger < HUNGER_GROW_LEVEL then
                --not hungry, so we can grow
                size = size + GROWTH_RATE
                size = math.clamp( size, MIN_SIZE, MAX_SIZE )
            end

            happiness = happiness - HAPPINESS_DRAIN_RATE
            hunger = hunger + HUNGER_DRAIN_RATE
            if hunger > 1 then
                happiness = 0
            end
            
            if happiness <= 0 then
                --print("abandoned")
                Profile:SetKitAbandonedMessage(true)
                Profile:SetKitBuild("")
                abandoned = true
                break
            end
        end
        if abandoned then
            poops = 0
        else
            poops = poops + math.floor(hours_since / 4)
            poops = math.clamp( poops, 0, MAX_POOPS )
        end
		--print("~~~~ Hours since last visit", hours_since, ", new happiness", happiness)

        Profile:SetKitHunger( hunger )
        Profile:SetKitHappiness( happiness )
        Profile:SetKitSize( size )
        Profile:SetKitPoops( poops )
        Profile:SetKitLastTime( now )
    end
end


local KitcoonPuppet = Class(Widget, function(self, profile_remove_me, interactable, positions, chance_to_show )
    Widget._ctor(self)

    --profile_remove_me remove this and calling functions at a later time when it is safer

    self:StartUpdating()

    self.chance_to_show = chance_to_show or 0.4

    self.anim = self:AddChild(UIAnim())
    self.anim:SetFacing(FACING_DOWNRIGHT)
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank("kitcoon")
    self.animstate:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.animstate:UseColourCube(true)
    self.animstate:SetUILightParams(2.0, 4.0, 4.0, 20.0)
    self.anim:Hide()

    self.nametag_anim = self:AddChild(UIAnim("kitcoon_nametag", "kitcoon_nametag", "idle", "idle" ))
    self.nametag_as = self.nametag_anim:GetAnimState()
    self.nametag_as:SetBank("kitcoon_nametag")
    self.nametag_as:SetBuild("kitcoon_nametag")
    self.nametag_as:PlayAnimation("idle", true)
    self.nametag_as:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.nametag_as:UseColourCube(true)
    self.nametag_as:SetUILightParams(2.0, 4.0, 4.0, 20.0)
    self.nametag_anim:SetScale(0.5)
    self.nametag_anim:Hide()

    RunKitcoonLongUpdate()

    self.interactable = interactable
    if self.interactable then
        self.onclick = function()
            if self.kit_active then
                self:Play()
            else
                --assume it's the nametag
                local kitcoon_name_popup = KitcoonNamePopup(
                    function(name)
                        print("Named", name)
                        Profile:SetKitName(name)
                        self:StartKit()
                        self.nametag_anim:Hide()
                        self.animstate:PlayAnimation("jump_out")
                        self.animstate:PushAnimation("idle_loop", true)
                        staticScheduler:ExecuteInTime( 3*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end )
                    end,
                    function()
                        print("Cancelled")
                    end
                )
                TheFrontEnd:PushScreen(kitcoon_name_popup)
            end
        end
    end

    self.positions = positions
end)

function KitcoonPuppet:PickPosition( positions )
    if positions == nil then
        positions = self.positions
    end

    if positions ~= nil then
        local p = GetRandomItem( positions )
        self:SetPosition( p.x, p.y )
        self:SetScale(p.scale or 1.0)
    end
end

function KitcoonPuppet:InitNewKit()
    local build = GetRandomItem( KIT_TYPES )
    Profile:SetKitBuild(build)
    
    self.size = MIN_SIZE
    Profile:SetKitSize(self.size)

    self.hunger = 0.3
    Profile:SetKitHunger( self.hunger )
    
    self.happiness = 0.7
    Profile:SetKitHappiness( self.happiness )

    Profile:SetKitPoops(0)

    local now = os.time()
    Profile:SetKitLastTime(now)
    Profile:SetKitBirthTime(now - math.random(5, 10) * 60 * 60 * 24 )

    return build
end

function KitcoonPuppet:StartKit()
    self.kit_active = true
    self.anim:Show()

    local build = Profile:GetKitBuild()
    if build == "" then
        build = self:InitNewKit()
    end
	self.animstate:SetBuild( build )
    self:AddShadow()

    self.hunger = Profile:GetKitHunger()
    self.happiness = Profile:GetKitHappiness()
    self.size = Profile:GetKitSize()
    self.poops = Profile:GetKitPoops()
    self.anim:SetScale(self.size)
end


function KitcoonPuppet:DebugReset()
    self:InitNewKit()
end

function KitcoonPuppet:AddShadow()
    if self.shadow == nil then
        self.shadow = self:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	    self.shadow:SetPosition(0,-10)
	    self.shadow:SetScale(0.25)
	    self.shadow:MoveToBack()
    end
end


function KitcoonPuppet:OnUpdate(dt)
    if self:IsEnabled() then
        --if self.interactable then --TODO(Peter): do we actually want to do this only on the main screen?
            if self.intention_task == nil and self.animstate:IsCurrentAnimation("idle_loop") then
                local wait_time = math.random( 2.5, 4.5 )
                --print("intention task started")
                self.intention_task = staticScheduler:ExecuteInTime( wait_time, function()
                    if self.inst.entity:IsValid() then
                        self:DoIntention()
                    end
                    self.intention_task = nil
                end )
            end
        --end
    end
end

local pouch_vec3 = {x=150, y=-75, z=0} --Note(Peter): these hacks are getting laughable. *game jame code*
function KitcoonPuppet:GoToHibernation( cb )
    self:CancelMoveTo(true)
    
    if self.intention_task then
        self.intention_task:Cancel()
        self.intention_task = nil
    end

    Profile:SetKitHibernationStart( os.time() )

    self.home_vec = self:GetPosition() --cache this so we know where to jump back to
    self:MoveTo( self.home_vec, pouch_vec3, 0.3, function() self:Hide() cb() end )
    self.animstate:PlayAnimation("jump_out")
end


function KitcoonPuppet:WakeFromHibernation()
    local time_hibernated = os.time() - Profile:GetKitHibernationStart()
    local bt = Profile:GetKitBirthTime()
    Profile:SetKitBirthTime( bt + time_hibernated ) --don't age while we're hibernated
    Profile:SetKitLastTime( os.time() )

    self:CancelMoveTo(true)
    self:Show()
    
    self:StartKit()
    local vec_home = self.home_vec or self:GetPosition()
    self:MoveTo( pouch_vec3, vec_home, 0.3, function() self:SetPosition(vec_home) end )
    self.animstate:PlayAnimation("jump_out")
    self.animstate:PushAnimation("idle_loop", true)
    self:DoIntention( false )
end


function KitcoonPuppet:OnEnable()
    RunKitcoonLongUpdate()

    self:PickPosition( self.positions )

    if math.random() > self.chance_to_show then
        self:Hide()
    else
        self:Show()
    end

    local build = Profile:GetKitBuild()
    if build == "" then
        if self.interactable then
            self.nametag_anim:Show()
        end
    else
        self:StartKit()
        if Profile:GetKitIsHibernating() then
            self:Hide()
        else
            self:DoIntention( true )
        end
    end
end

function KitcoonPuppet:OnDisable()
    if self.intention_task then
        self.intention_task:Cancel()
        self.intention_task = nil
    end
end

function KitcoonPuppet:DoIntention( on_start )
    if not self.shown or not on_start and (self.eat_queued or not self.animstate:IsCurrentAnimation("idle_loop")) then
        --food coming, don't switch
        return
    end

    if self.hunger < 0.05 and self.happiness > 0.95 then
        local frame_delay = 0
        if not on_start then
            staticScheduler:ExecuteInTime( 15*FRAMES, function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end )
            staticScheduler:ExecuteInTime( 80*FRAMES, function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end )
            frame_delay = 95
            self.animstate:PlayAnimation("emote_stretch")
            self.animstate:PushAnimation("sleep_pre")
        end
        staticScheduler:ExecuteInTime( (frame_delay+31)*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/sleep") end )
        self.animstate:PushAnimation("sleep_loop", true)

    elseif self.happiness < 0.15 or self.hunger > 0.85 then
        staticScheduler:ExecuteInTime( 2*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end )
        self.animstate:PlayAnimation("distress")
        self.animstate:PushAnimation("idle_loop", true)
       
    elseif self.hunger == 0 then
        staticScheduler:ExecuteInTime( 14*FRAMES, function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end )
        staticScheduler:ExecuteInTime( 36*FRAMES, function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end )
        staticScheduler:ExecuteInTime( 58*FRAMES, function() TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end )
        --print("lick")
        self.animstate:PlayAnimation("emote_lick")
        self.animstate:PushAnimation("idle_loop", true)
   
    elseif self.happiness == 1 then
        local choices = {
            function()
                staticScheduler:ExecuteInTime( 2*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end )
                self.animstate:PlayAnimation("emote_playful")
            end,
            function() 
                self.animstate:PlayAnimation("walk_pre")
                for i=1,math.random(1,3) do
                    self.animstate:PushAnimation("walk_loop")
                end
                self.animstate:PushAnimation("walk_pst")
            end,
        }
        local fn = GetRandomItem( choices )
        fn()

        self.animstate:PushAnimation("idle_loop", true)

    else
        if on_start then
            self.animstate:PlayAnimation("idle_loop", true)
        end
    end
end

function KitcoonPuppet:Play()
    if self.animstate:IsCurrentAnimation("idle_loop") then
        if self.intention_task then
            self.intention_task:Cancel()
            self.intention_task = nil
        end

        self.happiness = self.happiness + HAPPINESS_DELTA_PLAY
        self.happiness = math.clamp( self.happiness, 0, 1)
        Profile:SetKitHappiness( self.happiness )

        local choices = {
            function()
                self.animstate:PlayAnimation("emote_pet")
                TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle")
                self.animstate:PushAnimation("idle_loop", true)
            end,
            function() 
                self.animstate:PlayAnimation("emote_nuzzle")
                TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle")
                self.animstate:PushAnimation("idle_loop", true)
            end,
        }
        local fn = GetRandomItem( choices )
        fn()
    end
end

function KitcoonPuppet:TryQueueEat()
    if self.animstate:IsCurrentAnimation("idle_loop") and not Profile:GetKitIsHibernating() then
        self.eat_queued = true
        if self.intention_task then
            self.intention_task:Cancel()
            self.intention_task = nil
        end

        return true
    end
    return false
end
function KitcoonPuppet:Eat()
    self.eat_queued = false
    self.hunger = self.hunger - HUNGER_DELTA_EAT
    self.hunger = math.clamp( self.hunger, 0, 1)
    Profile:SetKitHunger( self.hunger )

--    staticScheduler:ExecuteInTime( 5*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/eat_pre") end )
    staticScheduler:ExecuteInTime( 21*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/creatures/together/kittington/eat") end )
    self.animstate:PlayAnimation("eat_pre")
    for i=1,math.random(1,5) do
        self.animstate:PushAnimation("eat_loop")
    end
    self.animstate:PushAnimation("eat_pst")
    self.animstate:PushAnimation("idle_loop", true)
end


function KitcoonPuppet:RemovePoop()
    self.poops = self.poops - 1
    Profile:SetKitPoops(self.poops)
end

function KitcoonPuppet:LeaveGameScreen()
    if self.kit_active and not Profile:GetKitIsHibernating() then
        --do poop penalty
        self.happiness = self.happiness - self.poops * POOP_PENALTY_DELTA
        Profile:SetKitHappiness( self.happiness )
    end
end

function KitcoonPuppet:OnGainFocus()
	self._base.OnGainFocus(self)
end

function KitcoonPuppet:OnControl(control, down)
	if self._base.OnControl(self, control, down) then return true end

    if self.interactable then
        if not down then
            if control == CONTROL_ACCEPT then
                self:onclick()
            end
        end
    end
end

return KitcoonPuppet
