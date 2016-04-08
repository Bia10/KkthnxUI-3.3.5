local K, C, L = unpack(select(2, ...));
if C["unitframe"].enable ~= true then return end

local Castbars = CreateFrame("Frame");

-- Anchor
local PlayerCastbarAnchor = CreateFrame("Frame", "PlayerCastbarAnchor", UIParent)
PlayerCastbarAnchor:SetSize(CastingBarFrame:GetWidth() * C["unitframe"].cbscale, CastingBarFrame:GetHeight() * 2)
PlayerCastbarAnchor:SetPoint(unpack(C["position"].playercastbar))

local function MoveCastBars()
	-- Move Cast Bar
	CastingBarFrame:ClearAllPoints();
	CastingBarFrame:SetScale(C["unitframe"].cbscale);
	CastingBarFrame:SetPoint("CENTER", PlayerCastbarAnchor, "CENTER", 0, -3);
	CastingBarFrame.SetPoint = K.Dummy
	
	-- CastingBarFrame Icon
	CastingBarFrameIcon:Show();
	CastingBarFrameIcon:SetSize(30, 30);
	CastingBarFrameIcon:ClearAllPoints();
	CastingBarFrameIcon:SetPoint("CENTER", CastingBarFrame, "TOP", 0, 24);
	CastingBarFrameIcon.SetPoint = K.Dummy
	
	-- Target Castbar
	TargetFrameSpellBar:ClearAllPoints();
	TargetFrameSpellBar:SetScale(C["unitframe"].cbscale);
	TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 10, 150);
	TargetFrameSpellBar.SetPoint = K.Dummy
end

local function Castbars_HandleEvents( self, event, ... )
	
	if(event == "PLAYER_ENTERING_WORLD") then
		MoveCastBars();
	end
	if(event == "UNIT_EXITED_VEHICLE" or event == "UNIT_ENTERED_VEHICLE") then
		if(UnitControllingVehicle("player") or UnitInVehicle("player")) then
			MoveCastBars();
		end
	end
end

local function Castbars_Load()
	Castbars:SetScript("OnEvent", Castbars_HandleEvents);
	
	Castbars:RegisterEvent("PLAYER_ENTERING_WORLD");
	Castbars:RegisterEvent("UNIT_EXITED_VEHICLE");
end

CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
CastingBarFrame.timer:SetFont(C.font.basic_font, C.font.basic_font_size)
CastingBarFrame.timer:SetShadowOffset(1, -1)
CastingBarFrame.timer:SetPoint("TOP", CastingBarFrame, "BOTTOM", 0, -3)
CastingBarFrame.update = 0.1;

TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
TargetFrameSpellBar.timer:SetFont(C.font.basic_font, C.font.basic_font_size)
TargetFrameSpellBar.timer:SetShadowOffset(1, -1)
TargetFrameSpellBar.timer:SetPoint("TOP", TargetFrameSpellBar, "BOTTOM", 0, -3)
TargetFrameSpellBar.update = 0.1;

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

-- Blizzard Tradeskills Castbar Mod
-- This will modify the (target) castbar to also show tradeskills
-- Override the Castbar
if TargetFrameSpellBar then
	TargetFrameSpellBar.showTradeSkills = C["unitframe"].tradeskill_cast
end

-- Double check the target castbar hasn't lost the tradeskill setting (another mod may change it)
hooksecurefunc("CastingBarFrame_OnEvent", function(self, event, ...)
	if self and self:GetName() == "TargetFrameSpellBar" then
		if TargetFrameSpellBar.showTradeSkills ~= C["unitframe"].tradeskill_cast then
			TargetFrameSpellBar.showTradeSkills = C["unitframe"].tradeskill_cast
		end
	end
end)

-- Run Initialisation
Castbars_Load();