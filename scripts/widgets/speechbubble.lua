local NineSlice = require "widgets/nineslice"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

--
-- Required params: bubble_atlast, face_atlas, face_img, target
--

local BOARDER_SIZE = 32
local FACE_OFFSET = 19

SCREEN_BOARDER_SIDE = 80
SCREEN_BOARDER_BOTTOM = 100
SCREEN_BOARDER_TOP = 40

local SpeechBubble = Class(Widget, function(self, params)
    Widget._ctor(self, "SpeechBubble")
	params = params or {}

	-- Params:
	self.max_width = params.max_width or 350
	self.world_offset = params.offset or Vector3(0,0,0)
	self.target = params.target or nil
	self.target_symbol = params.target_symbol or nil
	self.face_size = params.face_size or {x = 70, y = 70}
	self.face_offset = {x = -self.face_size.x + (params.face_offset_x or FACE_OFFSET), y = -self.face_size.y/2 + (params.face_offset_y or 0)}
	local bubble_atlast = params.bubble_atlast or nil

	self.root = self:AddChild(Widget("root"))

	self.face = self.root:AddChild(Image(params.face_atlas, params.face_img))
	self.face:SetSize(self.face_size.x, self.face_size.y)

	self.dialog_bg = self.root:AddChild(NineSlice(bubble_atlast))
	self.tail = self.dialog_bg:AddTail("tail_horizontal.tex", ANCHOR_LEFT, ANCHOR_TOP, 0, -BOARDER_SIZE)
	self.tailsize = BOARDER_SIZE
	self.text = self.dialog_bg:AddChild(Text(UIFONT, 38, nil, {.9,.9,.9,1}))
	self.text:SetHAlign(ANCHOR_LEFT)
	self.text:SetVAlign(ANCHOR_TOP)

	self:OnUpdate()
end)

function SpeechBubble:SetFaceImage(atlas, tex)
end

function SpeechBubble:SetText(text)
	self.text:SetMultilineTruncatedString(text, 20, self.max_width, nil, false)
	local w, h = self.text:GetRegionSize()

	self.text:SetPosition(0, math.max(self.tailsize - h, 0)/2)

	h = math.max(h, self.tailsize)
	self.dialog_bg:SetSize(w, h)

	self:SetTint(1,1,1,0)
	self:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, .3)

	self:OnUpdate()
end

function SpeechBubble:SetTarget(target, symbol)
    self.target = target
    self.symbol = symbol
end

function SpeechBubble:SetTint(r, g, b, a)
	local cr, cb, cg = unpack(self.text:GetColour())
	self.text:SetColour(cr, cb, cg, a)

	self.dialog_bg:SetTint(r, g, b, a)
end

function SpeechBubble:OnShow()
    self._base.OnShow(self)

    self:StartUpdating()
end

function SpeechBubble:OnHide()
    self:StopUpdating()

    self._base.OnHide(self)
end

function SpeechBubble:OnUpdate()
    if self.target ~= nil and self.target:IsValid() then
 	    local screenWidth, screenHeight = TheSim:GetScreenSize()

        local root_x, root_y = TheSim:GetScreenPos((self.target:GetPosition() + self.world_offset):Get())

        local raw_x, raw_y
        if self.target.AnimState ~= nil then
			if self.target_symbol ~= nil and type(self.target_symbol) == "table" then
				local min_d = nil
				for i, v in ipairs(self.target_symbol) do
					local _x, _y = TheSim:GetScreenPos(self.target.AnimState:GetSymbolPosition(self.target_symbol[i], self.world_offset.x, self.world_offset.y, self.world_offset.z))
					local d = distsq(_x, _y, screenWidth*0.5, screenHeight*0.5)
					if min_d == nil or d < min_d then
						raw_x = _x
						raw_y = _y
						min_d = d
					end
				end
			else
				raw_x, raw_y = TheSim:GetScreenPos(self.target.AnimState:GetSymbolPosition(self.target_symbol and self.target_symbol or "", self.world_offset.x, self.world_offset.y, self.world_offset.z))
			end
		else
			raw_x, raw_y = root_x, root_y
		end

		local screen_scale_x = (screenWidth / RESOLUTION_X) * TheFrontEnd:GetHUDScale()
		local screen_scale_y = (screenHeight / RESOLUTION_Y) * TheFrontEnd:GetHUDScale()

        local x = raw_x
        local y = raw_y

        local raw_size_x, raw_size_y = self.dialog_bg:GetSize()
        local size_x = (BOARDER_SIZE + raw_size_x*0.5) * screen_scale_x
        local size_y = (BOARDER_SIZE + raw_size_y*0.5) * screen_scale_y

        local min_x = size_x + (SCREEN_BOARDER_SIDE * screen_scale_x)
        local max_x = screenWidth - min_x
        local min_y = size_y + (SCREEN_BOARDER_BOTTOM * screen_scale_y)
        local max_y = screenHeight - (size_y + (SCREEN_BOARDER_TOP * screen_scale_y))

		local tail_hAnchor = ANCHOR_LEFT
		local tail_xOffset = 0
		local tail_xScale = 1
		local tail_yOffset = -self.tailsize
		local tail_yScale = 1

		if raw_x < root_x or ((raw_x == root_x) and (raw_x > screenWidth*0.5)) then
			x = raw_x - size_x - self.tailsize * screen_scale_x * 0.5

			tail_hAnchor = ANCHOR_RIGHT
			tail_xOffset = 64
			tail_xScale = -1
		else
			x = raw_x + size_x + self.tailsize * screen_scale_x * 0.5
		end

		y = raw_y - (raw_size_y*0.5 - self.tailsize*0.5) * screen_scale_y

		if raw_x > screenWidth or raw_x < 0 or raw_y > screenHeight or raw_y < 0 then
			self.face:Show()

			local face_y = (self.face_size.y*0.5)- (raw_size_y*0.5)
			self.face:SetPosition((self.face_offset.x - (raw_size_x*0.5 + BOARDER_SIZE)) * tail_xScale, -face_y)

			if tail_hAnchor == ANCHOR_LEFT then
				min_x = min_x + (self.face_size.x + BOARDER_SIZE) * screen_scale_x
				self.face:SetScale(-1, 1)
			else
				max_x = max_x - (self.face_size.x + BOARDER_SIZE) * screen_scale_x
				self.face:SetScale(1, 1)
			end

		else
			self.face:Hide()

			if y > screenHeight then
				tail_yOffset = 0
				tail_yScale = -1
			end
		end

		self.dialog_bg:UpdateTail(tail_hAnchor, ANCHOR_TOP, tail_xOffset, tail_yOffset)
		self.tail:SetScale(tail_xScale, tail_yScale)

        x = math.clamp(x, min_x, max_x)
        y = math.clamp(y, min_y, max_y)

        self.root:SetPosition(x, y, 0)
		self.root:SetScale(screen_scale_x, screen_scale_y)
    end
end


return SpeechBubble
