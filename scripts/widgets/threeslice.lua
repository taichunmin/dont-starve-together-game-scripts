local Widget = require "widgets/widget"
local Image = require "widgets/image"

local ThreeSlice = Class(Widget, function(self, atlas, cap, filler, end_cap)
    Widget._ctor(self, "ThreeSlice")
    self.inst.entity:AddImageWidget()

    self.atlas = atlas
    self.filler = filler

    end_cap = end_cap or cap
    self.flip_end_cap = (cap == end_cap)

	self.root = self:AddChild(Widget("root"))
    self.startcap = self.root:AddChild(Image(atlas, cap))
    self.endcap = self.root:AddChild(Image(atlas, end_cap))
    self.parts = {}
end)


function ThreeSlice:SetImages(atlas, cap, filler, end_cap)
    self.atlas = atlas
    self.filler = filler

    end_cap = end_cap or cap
    self.flip_end_cap = (cap == end_cap)

	self.startcap:SetTexture(self.atlas, cap)
	self.endcap:SetTexture(self.atlas, end_cap)

	for k,v in pairs(self.parts) do
		v:SetTexture(self.atlas, self.filler)
	end
end


function ThreeSlice:RemoveParts()
	for k,v in pairs(self.parts) do
		v:Kill()
	end
	self.parts = {}
end


function ThreeSlice:Flow(width, height, horizontal)
	self:RemoveParts()

	local dist = horizontal and width or height
	local startcapw, startcaph = self.startcap:GetSize()
	self.start_cap_size = horizontal and startcapw or startcaph
	local endcapw, endcaph = self.endcap:GetSize()
	self.end_cap_size = horizontal and endcapw or endcaph

	local fill_dist = math.max(0, dist - (self.start_cap_size + self.end_cap_size))

	if fill_dist > 0 then
		local start_cap_d = fill_dist/2 + self.start_cap_size/2
		local end_cap_d = fill_dist/2 + self.end_cap_size/2

		if horizontal then
			self.startcap:SetPosition(start_cap_d,0, 0)
			self.endcap:SetPosition(-end_cap_d,0, 0)
			self.endcap:SetScale(-1,1,1)
		else
			self.startcap:SetPosition(0, start_cap_d, 0)
			self.endcap:SetPosition(0, -end_cap_d, 0)
			self.endcap:SetScale(1,-1,1)
		end

		local filler = self.root:AddChild(Image(self.atlas, self.filler))

		local fillerw, fillerh = filler:GetSize()
		self.filler_size = horizontal and fillerw or fillerh

		if horizontal then
			self.root:SetScale(1,height/fillerh,1)
		else
			self.root:SetScale(width/fillerw,1,1)
		end


		local num_filler = math.ceil(fill_dist / self.filler_size)
		local filler_scale = fill_dist / (num_filler*self.filler_size)

		for k = 1, num_filler do
			if filler == nil then
				filler = self.root:AddChild(Image(self.atlas, self.filler))
			end

			if horizontal then
				filler:SetScale(filler_scale, 1, 1)
				filler:SetPosition(fill_dist/2 - filler_scale*self.filler_size*(k-1+.5),0,0 )
			else
				filler:SetScale(1, filler_scale, 1)
				filler:SetPosition(0, fill_dist/2 - filler_scale*self.filler_size*(k-1+.5),0 )
			end
			table.insert(self.parts, filler)
			filler = nil
		end
	else
		if horizontal then
			self.startcap:SetPosition(self.start_cap_size/2, 0, 0)
			self.endcap:SetPosition(-self.end_cap_size/2, 0, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(-1,1,1)
			end
		else
			self.startcap:SetPosition(0, self.start_cap_size/2, 0)
			self.endcap:SetPosition(0, -self.end_cap_size/2, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(1,-1,1)
			end
		end
	end
end

function ThreeSlice:ManualFlow(num_filler, horizontal)
	self:RemoveParts()

	local startcapw, startcaph = self.startcap:GetSize()
	self.start_cap_size = horizontal and startcapw or startcaph
	local endcapw, endcaph = self.endcap:GetSize()
	self.end_cap_size = horizontal and endcapw or endcaph

	if num_filler > 0 then

		local filler = self.root:AddChild(Image(self.atlas, self.filler))

		local fillerw, fillerh = filler:GetSize()
		self.filler_size = horizontal and fillerw or fillerh

		local fill_dist = num_filler*self.filler_size

		for k = 1,num_filler do
			if filler == nil then
				filler = self.root:AddChild(Image(self.atlas, self.filler))
			end

			if horizontal then
				filler:SetPosition( fill_dist/2 - self.filler_size*(k-1+.5), 0, 0 )
			else
				filler:SetPosition( 0, fill_dist/2 - self.filler_size*(k-1+.5), 0 )
			end
			table.insert(self.parts, filler)
			filler = nil
		end

		local start_cap_d = fill_dist/2 + self.start_cap_size/2
		local end_cap_d = fill_dist/2 + self.end_cap_size/2
		if horizontal then
			self.startcap:SetPosition(start_cap_d,0, 0)
			self.endcap:SetPosition(-end_cap_d,0, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(-1,1,1)
			end
		else
			self.startcap:SetPosition(0, start_cap_d, 0)
			self.endcap:SetPosition(0, -end_cap_d, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(1,-1,1)
			end
		end
	else
		if horizontal then
			self.startcap:SetPosition(self.start_cap_size/2, 0, 0)
			self.endcap:SetPosition(-self.end_cap_size/2, 0, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(-1,1,1)
			end
		else
			self.startcap:SetPosition(0, self.start_cap_size/2, 0)
			self.endcap:SetPosition(0, -self.end_cap_size/2, 0)
			if self.flip_end_cap then
				self.endcap:SetScale(1,-1,1)
			end
		end
	end
end

return ThreeSlice
