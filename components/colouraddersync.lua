local function OnColourDirty(inst)
	local self = inst.components.colouraddersync
	if self.colourchangedfn ~= nil then
		local a = self.colour:value()
		local r = math.floor(a / 16777216)
		a = a - r * 16777216
		local g = math.floor(a / 65536)
		a = a - g * 65536
		local b = math.floor(a / 256)
		a = a - b * 256
		self.colourchangedfn(inst, r / 255, g / 255, b / 255, a / 255)
	end
end

local ColourAdderSync = Class(function(self, inst)
	self.inst = inst
	self.colour = net_uint(inst.GUID, "colouraddersync.colour", "colourdirty")
	self.colourchangedfn = nil

	if not TheWorld.ismastersim then
		inst:ListenForEvent("colourdirty", OnColourDirty)
	end
end)

function ColourAdderSync:SetColourChangedFn(fn)
	self.colourchangedfn = fn
	OnColourDirty(self.inst)
end

--Called from colouradder component
function ColourAdderSync:SyncColour(r, g, b, a)
	self.colour:set(
		math.floor(r * 255 + .5) * 0x1000000 +
		math.floor(g * 255 + .5) * 0x10000 +
		math.floor(b * 255 + .5) * 0x100 +
		math.floor(a * 255 + .5)
	)
	if self.inst.AnimState ~= nil then
		self.inst.AnimState:SetAddColour(r, g, b, a)
	end
	if self.colourchangedfn ~= nil then
		self.colourchangedfn(self.inst, r, g, b, a)
	end
end

return ColourAdderSync
