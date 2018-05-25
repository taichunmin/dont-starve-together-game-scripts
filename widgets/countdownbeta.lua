local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/templates"
require "os"

local klei_tz = 28800--The time zone offset for vancouver

local FLIP_SCALE = 1  -- set to -1 to flip

local CountdownBeta = Class(Widget, function(self, owner, mode, image, update_name, release_date)
	Widget._ctor(self, "Countdown")

	if mode == "text" then
		--scribble_black
		self.bg = self:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
		self.bg:SetPosition(0, 2)
		self.bg:SetScale(1.25, 1.1, 1)

		self.daysuntiltext = self:AddChild(Text(NUMBERFONT, 35))
		self.daysuntiltext:SetPosition(0, 5, 0)
		self.daysuntiltext:SetRegionSize( 240, 50 )
		self.daysuntiltext:SetClickable(false)
		
		if release_date ~= nil then
			self:SetCountdownDate(release_date)
		else
			self.daysuntiltext:SetString(STRINGS.UI.MAINSCREEN.BETA_LABEL)
		end

	elseif mode == "image" or mode == "reveal" or mode == "released" then
		self.image = self:AddChild(Image("images/anr_silhouettes.xml", image..(mode == "released" and "_reveal" or "")..".tex"))
		self.image:SetScale(FLIP_SCALE, 1, 1)
		self.image:SetPosition(0, 90, 0)
		self.image:SetClickable(false)

		local lableroot = self:AddChild(Widget("LableRoot"))
		lableroot:SetPosition(0, -85)

		self.bg = lableroot:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
		self.bg:SetPosition(0, -2)
		self.bg:SetScale(1.25, 1.6, 1)

		self.title = lableroot:AddChild(Text(NUMBERFONT, 35))
		self.title:SetPosition(0, 18, 0)
		self.title:SetRegionSize( 240, 50 )
		self.title:SetClickable(false)
		self.title:SetString(STRINGS.UI.MAINSCREEN.BETA_LABEL)

		self.daysuntiltext = lableroot:AddChild(Text(NUMBERFONT, 30))
		self.daysuntiltext:SetPosition(0, -18, 0)
		self.daysuntiltext:SetRegionSize( 240, 50 )
		self.daysuntiltext:SetClickable(false)
		
		self:SetCountdownDate(release_date)

		if mode == "reveal" then
			self.title2 = lableroot:AddChild(Text(NUMBERFONT, 25))
			self.title2:SetPosition(0, -3, 0)
			self.title2:SetRegionSize( 240, 50 )
			self.title2:SetClickable(false)
			self.title2:SetString(update_name)

			self.title:SetPosition(0, 28, 0)
			self.daysuntiltext:SetPosition(0, -28, 0)
			self.daysuntiltext:SetSize(25)

			self.reveal_image = self:AddChild(Image("images/anr_silhouettes.xml", image.."_reveal.tex"))
			self.reveal_image:SetScale(FLIP_SCALE, 1, 1)
			self.reveal_image:SetPosition(0, 90, 0)
			self.reveal_image:SetClickable(false)
			self.reveal_image:SetTint(1,1,1,0)

			-- Player portal
			self.smoke = self:AddChild(UIAnim())
			self.smoke:SetScale(1.1)
			self.inst:DoTaskInTime(1.3, function(inst)
				self.smoke:GetAnimState():SetBuild("puff_spawning")
				self.smoke:GetAnimState():SetBank("spawn_fx")
				self.smoke:GetAnimState():PlayAnimation("tiny")
				if TheFrontEnd:GetActiveScreen() == owner then
					TheFrontEnd:GetSound():PlaySound("dontstarve/common/spawn/spawnportal_spawnplayer")
				end

				self.inst:DoTaskInTime(0.4, function(inst)
					self.reveal_image:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, .5 )
				end)
			end)
			
			-- Spore Cloud in/out
			--[[
			self.smoke = self:AddChild(UIAnim())
			self.smoke:SetScale(.8)
			self.smoke:SetPosition(0, -50, 0)
			self.inst:DoTaskInTime(2.8, function(inst)
				self.smoke:GetAnimState():SetBuild("sporecloud")
				self.smoke:GetAnimState():SetBank("sporecloud")
				self.smoke:GetAnimState():PlayAnimation("sporecloud_overlay_pre")
				self.smoke:GetAnimState():PushAnimation("sporecloud_overlay_pst", false)

				if TheFrontEnd:GetActiveScreen() == owner then
					TheFrontEnd:GetSound():PlaySound("dontstarve/creatures/together/toad_stool/infection_attack")
				end

				self.inst:DoTaskInTime(25 * FRAMES, function(inst)
					self.reveal_image:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, .5 )

					self.inst:DoTaskInTime(5 * FRAMES, function(inst)
						if TheFrontEnd:GetActiveScreen() == owner then
							TheFrontEnd:GetSound():PlaySound("dontstarve/creatures/together/toad_stool/infection_post")
						end
					end)
				end)
			end)
			]]
			
			
		elseif mode == "released" then
			self.title2 = lableroot:AddChild(Text(NUMBERFONT, 25))
			self.title2:SetPosition(0, -3, 0)
			self.title2:SetRegionSize( 240, 50 )
			self.title2:SetClickable(false)
			self.title2:SetString(STRINGS.UI.MAINSCREEN.UPDATERELEASED)

			self.title:SetPosition(0, 26, 0)
			self.daysuntiltext:SetPosition(0, -28, 0)
			self.daysuntiltext:SetSize(25)
			self.daysuntiltext:SetString(update_name)
		end
		
	end


end)

local function get_timezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end

function CountdownBeta:SetCountdownDate(date)
	if not date or type(date) ~= "table" then
		return
	end

	local now = os.time() - get_timezone()
	local update_time = os.time(date) - klei_tz
	local build_time = TheSim:GetBuildDate()

	local days_until 		= ((((update_time - now) / 60) / 60) / 24)
	local days_since 		= ((((now - build_time) / 60) / 60) / 24)
	local build_update_diff = ((((build_time - update_time) / 60) / 60) / 24)

	print( "SetCountdownDate:", days_until, days_since, build_update_diff)

	if not days_until and not days_since then return end
	if days_until and days_since then
		if days_until >= 1 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTUPDATEDAYS, math.ceil(days_until)) .. "!"
			--self.daysuntilanim:GetAnimState():PlayAnimation("about", true)
		elseif days_until < 1 and days_until >= -1 and build_update_diff < 0 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTBUILDIMMINENT)
			--self.daysuntilanim:GetAnimState():PlayAnimation("coming", true)
		else
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTBUILDIMMINENT)
			--self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.FRESHBUILD)
			--self.daysuntilanim:GetAnimState():PlayAnimation("fresh", true)
		end
		
		self.daysuntiltext:SetString(self.days_until_string)
	end
end

return CountdownBeta