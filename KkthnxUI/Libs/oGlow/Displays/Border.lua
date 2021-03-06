local K, C, L, _ = unpack(select(2, ...))
local argcheck = oGlow.argcheck

local colorTable = setmetatable(
	{},
	{__index = function(self, val)
		argcheck(val, 2, "number")
		local r, g, b = GetItemQualityColor(val)
		rawset(self, val, {r, g, b})

		return self[val]
	end}
)

local createBorder = function(self, point)
	local bc = self.oGlowBorder
	if(not bc) then
		if(not self:IsObjectType'Frame') then
			bc = self:GetParent():CreateTexture(nil, 'OVERLAY')
		else
			bc = self:CreateTexture(nil, "OVERLAY")
		end

		bc:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		bc:SetBlendMode("ADD")
		bc:SetAlpha(0.8)

		bc:SetSize(70, 70)

		bc:SetPoint("CENTER", point or self)
		self.oGlowBorder = bc
	end

	return bc
end

local borderDisplay = function(frame, color)
	if(color) then
		local bc = createBorder(frame)
		local rgb = colorTable[color]

		if(rgb) then
			bc:SetVertexColor(rgb[1], rgb[2], rgb[3])
			bc:Show()
		end

		return true
	elseif(frame.oGlowBorder) then
		frame.oGlowBorder:Hide()
	end
end

function oGlow:RegisterColor(name, r, g, b)
	argcheck(name, 2, "string", "number")
	argcheck(r, 3, "number")
	argcheck(g, 4, "number")
	argcheck(b, 5, "number")

	if(rawget(colorTable, name)) then
		return nil, string.format("Color [%s] is already registered.", name)
	else
		rawset(colorTable, name, {r, g, b})
	end

	return true
end

oGlow:RegisterDisplay("Border", borderDisplay)