require "fonts"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"

-------------------------------------------------
-- AnimSpinner is based on Spinner.
-----------------
-- To use AnimSpinner, call the constructor just as you would for Spinner.
-- Then call SetAnim with a build filel, anim bank name, animation name, and symbol to be overridden.
-- If it is a skin, then you must pass a final parameter with the value true.
-- eg, spinner_group.spinner:SetAnim("frames_comp", "frames_comp", "idle_on", "SWAP_ICON", true)
--
-- Each item in the options list must have a build name and a symbol name instead of the image value used previously.
-- eg
-- table.insert(skin_options,
--			{
--				text = text_name,
--				data = nil,
--				build = build_name,
--				item = item_type,
--				symbol = "SWAP_ICON",
--			})
-------------------------------------------------------

local AnimSpinner = Class(Spinner, function( self, options, width, height, textinfo, editable, atlas, textures, lean, textwidth, textheight)
    Spinner._ctor(self, options, width, height, textinfo, editable, atlas, textures, lean, textwidth, textheight)

    self.fganim = self:AddChild( UIAnim() )

	self.leftimage:SetOnClick(function()
								if TheInput:IsKeyDown(KEY_SHIFT) then
									for i=1,4 do
										self:Prev(true)
									end
								end

								self:Prev(true)
							end)
	self.rightimage:SetOnClick(function()
								if TheInput:IsKeyDown(KEY_SHIFT) then
									for i=1,4 do
										self:Next(true)
									end
								end

								self:Next(true)
							end)
end)

function AnimSpinner:SetArrowScale(scale)
	self.arrow_scale = scale
	self.leftimage:SetScale( self.arrow_scale, self.arrow_scale, 1 )
    self.rightimage:SetScale( self.arrow_scale, self.arrow_scale, 1 )
end


-- To use an anim spinner, call SetAnim with the bank, animation name,
-- and the symbol name that will be overridden.
--
-- new_anim is the animation state that includes the new indicator, but is optional.
function AnimSpinner:SetAnim(build, bank, anim, old_symbol, skin, new_anim)
	self.fganim:GetAnimState():SetBuild(build)
	self.fganim:GetAnimState():SetBank(bank)
	self.fganim:GetAnimState():PlayAnimation(anim)

	self.old_symbol = old_symbol
	self.bank = bank
	self.anim = anim
	self.skin = skin
	self.new_anim = new_anim
end

function AnimSpinner:Next(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex + 1
			if newSelection > self:MaxIndex() then
				newSelection = self:MinIndex()
			end
		else
			newSelection = math.min( newSelection + 1, self:MaxIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnNext()
		self:SetSelectedIndex(newSelection)
		self:Changed(self:GetSelectedData())
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function AnimSpinner:Prev(noclicksound)
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex - 1
			if newSelection < self:MinIndex() then
				newSelection = self:MaxIndex()
			end
		else
			newSelection = math.max( self.selectedIndex - 1, self:MinIndex() )
		end
	end
	if newSelection ~= oldSelection then
		if not noclicksound then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
		self:OnPrev()
		self:SetSelectedIndex(newSelection)
		self:Changed(self:GetSelectedData())
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

-- returns the build file to use and the symbol name within that build
function AnimSpinner:GetSelectedSymbol()
	return self.options[ self.selectedIndex ].build, self.options[ self.selectedIndex ].symbol, self.options[ self.selectedIndex ].new_indicator
end

function AnimSpinner:GoToEnd()
	self:SetSelectedIndex(self:MaxIndex())
end

function AnimSpinner:SetSelectedIndex( idx )
	self.updating = true
	self.selectedIndex = math.max(self:MinIndex(), math.min(self:MaxIndex(), idx))

	local selected_text, selected_colour = self:GetSelectedText()
	self:UpdateText( selected_text )
	if selected_colour then
		self:SetTextColour( unpack(selected_colour) )
	else
		self:SetTextColour(0, 0, 0, 1)
	end

	if self.old_symbol ~= nil and self.options[ self.selectedIndex ] ~= nil then
		local build, symbol, new_indicator = self:GetSelectedSymbol()
		if build ~= nil and symbol ~= nil then
			--print("Overriding symbol on ", self.fganim, self.fganim:GetAnimState() or nil, self.old_symbol, build, symbol)
			if self.skin then
				self.fganim:GetAnimState():OverrideSkinSymbol(self.old_symbol, build, symbol)

				if new_indicator and self.new_anim then
					self.fganim:GetAnimState():PlayAnimation(self.new_anim)
				end

			else
				self.fganim:GetAnimState():OverrideSymbol(self.old_symbol, build, symbol)

				if new_indicator and self.new_anim then
					self.fganim:GetAnimState():PlayAnimation(self.new_anim)
				end
			end
		end
	end

	self:UpdateState()
	self.updating = false
	self:Changed(self:GetSelectedData()) -- must be done after setting self.updating to false
end

return AnimSpinner
