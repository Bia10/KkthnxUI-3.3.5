local K, C, L = unpack(select(2, ...));
----------------------------------------------------------------------------------------
--	Copy Chat
----------------------------------------------------------------------------------------
local lines = {}
local frame = nil
local editBox = nil
local isf = nil
local sizes = {
	":14:14",
	":15:15",
	":16:16",
	":12:20",
	":14"
}

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	frame:SetBackdrop(K.Backdrop)
	frame:SetBackdropBorderColor(.7, .7, .7, 1)
	frame:SetBackdropColor(0.05, 0.05, 0.05, .9)
	frame:SetWidth(540)
	frame:SetHeight(300)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	frame:SetFrameStrata("DIALOG")
	tinsert(UISpecialFrames, "CopyFrame")
	frame:Hide()
	
	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(500)
	editBox:SetHeight(300)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	
	scrollArea:SetScrollChild(editBox)
	
	editBox:SetScript("OnTextSet", function(self)
		local text = self:GetText()
		
		for _, size in pairs(sizes) do
			if string.find(text, size) and not string.find(text, size.."]") then
				self:SetText(string.gsub(text, size, ":12:12"))
			end
		end
	end)
	
	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)
	
	isf = true
end

local scrollDown = function()
	CopyScroll:SetVerticalScroll((CopyScroll:GetVerticalScrollRange()) or 0)
end

local function Copy(cf)
	local text = ""
	for i = 1, cf:GetNumMessages() do
		text = text..cf:GetMessageInfo(i).."\n"
	end
	text = text:gsub("|[Tt]Interface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d):0|[Tt]", "{rt%1}")
	text = text:gsub("|[Tt][^|]+|[Tt]", "")

	if not isf then CreatCopyFrame() end
	if frame:IsShown() then frame:Hide() return end
	frame:Show()
	editBox:SetText(text)
end

for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G[format("ChatFrame%d", i)]
	local button = CreateFrame("Button", format("ButtonCF%d", i), cf)
	button:SetPoint("TOPRIGHT", 3, 22)
	button:SetHeight(18)
	button:SetWidth(18)
	CreateStyle(button, 2)
	button:SetAlpha(0.1)
	
	local buttontexture = button:CreateTexture(nil, "BORDER")
	buttontexture:SetPoint("CENTER")
	buttontexture:SetTexture("Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
	buttontexture:SetHeight(16)
	buttontexture:SetWidth(16)
	
	button:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			ToggleFrame(ChatMenu)
		elseif btn == "MiddleButton" then
			RandomRoll(1, 100)
		else
			Copy(cf)
		end
	end)
	button:HookScript("OnEnter", function() button:FadeIn() end)
	button:HookScript("OnLeave", function() button:FadeOut() end)
	
	SlashCmdList.COPY_CHAT = function()
		Copy(_G["ChatFrame1"])
	end
end