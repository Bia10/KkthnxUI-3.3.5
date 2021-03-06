local K, C, L, _ = unpack(select(2, ...))
if C["unitframe"].enable ~= true then return end

local unpack = unpack
local format = string.format
local max = math.max

local CreateFrame = CreateFrame
local UIParent = UIParent
local hooksecurefunc = hooksecurefunc

-- Anchor
local PlayerCastbarAnchor = CreateFrame("Frame", "PlayerCastbarAnchor", UIParent)
PlayerCastbarAnchor:SetSize(CastingBarFrame:GetWidth() * C["unitframe"].cbscale, CastingBarFrame:GetHeight() * 2)
PlayerCastbarAnchor:SetPoint(unpack(C["position"].playercastbar))

local Castbars = CreateFrame("Frame")
Castbars:RegisterEvent("ADDON_LOADED")
Castbars:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "KkthnxUI" then

		-- Move Cast Bar
		CastingBarFrame:ClearAllPoints()
		CastingBarFrame:SetScale(C["unitframe"].cbscale)
		CastingBarFrame:SetPoint("CENTER", PlayerCastbarAnchor, "CENTER", 0, -3)
		CastingBarFrame.SetPoint = K.Dummy

		-- CastingBarFrame Icon
		CastingBarFrameIcon:Show()
		CastingBarFrameIcon:SetSize(30, 30)
		CastingBarFrameIcon:ClearAllPoints()
		CastingBarFrameIcon:SetPoint("CENTER", CastingBarFrame, "TOP", 0, 24)

		-- Target Castbar
		TargetFrameSpellBar:ClearAllPoints()
		TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
		TargetFrameSpellBar:SetScale(C["unitframe"].cbscale)
		TargetFrameSpellBar.SetPoint = K.Dummy

		-- Castbar Timer.
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		CastingBarFrame.timer:SetFont(C.font.basic_font, C.font.basic_font_size)
		CastingBarFrame.timer:SetShadowOffset(K.mult, -K.mult)
		CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, -3)
		CastingBarFrame.update = 0.1

		TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
		TargetFrameSpellBar.timer:SetFont(C.font.basic_font, C.font.basic_font_size)
		TargetFrameSpellBar.timer:SetShadowOffset(K.mult, -K.mult)
		TargetFrameSpellBar.timer:SetPoint("TOP", TargetFrameSpellBar, "BOTTOM", 0, -3)
		TargetFrameSpellBar.update = 0.1

		self:UnregisterEvent("ADDON_LOADED")
	end

end)

hooksecurefunc("CastingBarFrame_OnUpdate", function(self, elapsed)
	if not self.timer then return end
	if self.update and self.update < elapsed then
		if self.casting then
			self.timer:SetText(format("%2.1f/%1.1f", max(self.maxValue - self.value, 0), self.maxValue))
		elseif self.channeling then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = .1
	else
		self.update = self.update - elapsed
	end
end)