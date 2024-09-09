local SymbolSwapData = Class(function(self, inst)
	self.inst = inst
end)

function SymbolSwapData:SetData(build, symbol, is_skinned)
	self.build = build
	self.symbol = symbol
	self.is_skinned = is_skinned
end

function SymbolSwapData:GetDebugString()
	return string.format("build:%s, symbol:%s, is_skinned:%s", self.build or "", self.symbol or "", self.is_skinned or "")
end

return SymbolSwapData
